from __future__ import annotations

from collections.abc import Iterable
import os
from typing import Any, Protocol

from huggingface_hub.inference._text_generation import TextGenerationStreamResponse, Token
import streamlit as st
import torch
from transformers import AutoModel, AutoTokenizer

from models.chatglm3.composite_demo.conversation import Conversation

from utils.ichosen_get_model import auto_load_model


TOOL_PROMPT = 'Answer the following questions as best as you can. You have access to the following tools:'

MODEL_PATH = os.environ.get('ICHOSEN_TOOLS_MODEL', '/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B')
cuda_visible_devices = os.environ.get("CUDA_VISIBLE_DEVICES")
print(f"---> MODEL_PATH: '{MODEL_PATH}', cuda_visible_devices: {cuda_visible_devices}")
num_gpus = 1
if cuda_visible_devices is not None:
    gpu_ids = [gpu_id for gpu_id in cuda_visible_devices.split(",") if gpu_id.strip()]
    num_gpus = len(gpu_ids)
    print(f"---> num_gpus: {num_gpus}, GPU IDs: {gpu_ids}")
else:
    print("---> CUDA_VISIBLE_DEVICES is not set!")


@st.cache_resource
def get_client() -> Client:
    client = HFClient(MODEL_PATH)
    return client


class Client(Protocol):
    def generate_stream(self,
        system: str | None,
        tools: list[dict] | None,
        history: list[Conversation],
        **parameters: Any
    ) -> Iterable[TextGenerationStreamResponse]:
        ...


def stream_chat(self, tokenizer, query: str, history: list[tuple[str, str]] = None, role: str = "user",
                    past_key_values=None,max_length: int = 8192, do_sample=True, top_p=0.8, temperature=0.8,
                    logits_processor=None, return_past_key_values=False, **kwargs):
        
    from transformers.generation.logits_process import LogitsProcessor
    from transformers.generation.utils import LogitsProcessorList

    class InvalidScoreLogitsProcessor(LogitsProcessor):
        def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor) -> torch.FloatTensor:
            if torch.isnan(scores).any() or torch.isinf(scores).any():
                scores.zero_()
                scores[..., 5] = 5e4
            return scores

    if history is None:
        history = []
    if logits_processor is None:
        logits_processor = LogitsProcessorList()
    logits_processor.append(InvalidScoreLogitsProcessor())
    eos_token_id = [tokenizer.eos_token_id, tokenizer.get_command("<|user|>"),
                    tokenizer.get_command("<|observation|>")]
    gen_kwargs = {"max_length": max_length, "do_sample": do_sample, "top_p": top_p,
                    "temperature": temperature, "logits_processor": logits_processor, **kwargs}
    if past_key_values is None:
        inputs = tokenizer.build_chat_input(query, history=history, role=role)
    else:
        inputs = tokenizer.build_chat_input(query, role=role)
    inputs = inputs.to(self.device)
    if past_key_values is not None:
        past_length = past_key_values[0][0].shape[0]
        if self.transformer.pre_seq_len is not None:
            past_length -= self.transformer.pre_seq_len
        inputs.position_ids += past_length
        attention_mask = inputs.attention_mask
        attention_mask = torch.cat((attention_mask.new_ones(1, past_length), attention_mask), dim=1)
        inputs['attention_mask'] = attention_mask
    history.append({"role": role, "content": query})
    for outputs in self.stream_generate(**inputs, past_key_values=past_key_values,
                                        eos_token_id=eos_token_id, return_past_key_values=return_past_key_values,
                                        **gen_kwargs):
        if return_past_key_values:
            outputs, past_key_values = outputs
        outputs = outputs.tolist()[0][len(inputs["input_ids"][0]):]
        response = tokenizer.decode(outputs)
        if response and response[-1] != "�":
            new_history = history
            if return_past_key_values:
                yield response, new_history, past_key_values
            else:
                yield response, new_history


class HFClient(Client):
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
        print(f"==========> in class HFClient(Client), before loading model '{model_path}'...")
        
        ### V1
        # self.model = AutoModel.from_pretrained(model_path, trust_remote_code=True).to(
        #     'cuda' if torch.cuda.is_available() else
        #     'mps' if torch.backends.mps.is_available() else
        #     'cpu'
        # )

        # ### V2
        # if num_gpus == 1:
        #     print(f"---> Using single GPU...")
        #     self.model = AutoModel.from_pretrained(model_path, trust_remote_code=True).cuda()
        # else:
        #     print(f"---> Using multiple GPUs: {num_gpus}...")
            
        #     # V1:
        #     # from models.chatglm3.utils import load_model_on_gpus
        #     # self.model = load_model_on_gpus(model_path, num_gpus=num_gpus)

        #     # V2:
        #     from accelerate import dispatch_model
        #     from accelerate.utils import infer_auto_device_map, get_balanced_memory
        #     self.model = AutoModel.from_pretrained(model_path, trust_remote_code=True)  # DO NOT add '.cuda()' here!
        #     if self.model._no_split_modules is None:
        #         raise ValueError("The model class needs to implement the `_no_split_modules` attribute.")
        #     kwargs = {"dtype": self.model.dtype, "no_split_module_classes": self.model._no_split_modules}
        #     max_memory = get_balanced_memory(self.model, **kwargs)
        #     self.model.tie_weights()  # Make sure tied weights are tied before creating the device map.
        #     device_map = infer_auto_device_map(self.model, max_memory=max_memory, **kwargs)
        #     self.model = dispatch_model(self.model, device_map)
        self.model = auto_load_model(model_path)

        print(f"==========> in class HFClient(Client), after '{model_path}' model loaded...")
        self.model = self.model.eval()

    def generate_stream(self,
        system: str | None,
        tools: list[dict] | None,
        history: list[Conversation],
        **parameters: Any
    ) -> Iterable[TextGenerationStreamResponse]:
        chat_history = [{
            'role': 'system',
            'content': system if not tools else TOOL_PROMPT,
        }]

        if tools:
            chat_history[0]['tools'] = tools

        for conversation in history[:-1]:
            chat_history.append({
                'role': str(conversation.role).removeprefix('<|').removesuffix('|>'),
                'content': conversation.content,
            })
        
        query = history[-1].content
        role = str(history[-1].role).removeprefix('<|').removesuffix('|>')

        text = ''
        
        for new_text, _ in stream_chat(self.model,
            self.tokenizer,
            query,
            chat_history,
            role,
            **parameters,
        ):
            word = new_text.removeprefix(text)
            word_stripped = word.strip()
            text = new_text
            yield TextGenerationStreamResponse(
                generated_text=text,
                token=Token(
                    id=0,
                    logprob=0,
                    text=word,
                    special=word_stripped.startswith('<|') and word_stripped.endswith('|>'),
                )
            )
