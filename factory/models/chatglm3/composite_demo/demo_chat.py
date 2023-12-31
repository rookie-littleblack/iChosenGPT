import streamlit as st
from streamlit.delta_generator import DeltaGenerator

from models.chatglm3.composite_demo.client import get_client
from models.chatglm3.composite_demo.conversation import postprocess_text, preprocess_text, Conversation, Role


client = get_client()

# Append a conversation into history, while show it in a new markdown block
def append_conversation(
    conversation: Conversation,
    history: list[Conversation],
    placeholder: DeltaGenerator | None=None,
) -> None:
    history.append(conversation)
    conversation.show(placeholder)

def main(max_length: int, top_p: float, temperature: float, system_prompt: str, prompt_text: str):
    placeholder = st.empty()
    with placeholder.container():
        if 'chat_history' not in st.session_state:
            print("---> 'chat_history' not in st.session_state..")
            st.session_state.chat_history = []
        print(f"---> st.session_state.chat_history: {st.session_state.chat_history}")

        history: list[Conversation] = st.session_state.chat_history

        for conversation in history:
            conversation.show()

    if prompt_text:
        prompt_text = prompt_text.strip()
        append_conversation(Conversation(Role.USER, prompt_text), history)

        input_text = preprocess_text(
            system_prompt,
            tools=None,
            history=history,
        )
        print("=== Input:")
        print(input_text)
        print("=== History:")
        print(history)

        placeholder = st.empty()
        message_placeholder = placeholder.chat_message(name="assistant", avatar="👩‍💼")
        markdown_placeholder = message_placeholder.empty()

        output_text = ''
        for response in client.generate_stream(
            system_prompt,
            tools=None, 
            history=history,
            do_sample=True,
            max_length=max_length,
            temperature=temperature,
            top_p=top_p,
            stop_sequences=[str(Role.USER)],
        ):
            token = response.token
            if response.token.special:
                print("=== Output:")
                print(output_text)

                match token.text.strip():
                    case '<|user|>':
                        break
                    case _:
                        st.error(f'Unexpected special token: {token.text.strip()}')
                        break
            output_text += response.token.text
            markdown_placeholder.markdown(postprocess_text(output_text + '▌'))
        
        append_conversation(Conversation(
            Role.ASSISTANT,
            postprocess_text(output_text),
        ), history, markdown_placeholder)