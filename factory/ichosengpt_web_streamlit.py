import streamlit as st
import torch
import os
from transformers import AutoModel, AutoTokenizer
from utils.ichosen_get_model import auto_load_model


# 设置页面标题、图标和布局
st.set_page_config(
    page_title="iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.",
    page_icon="🦈",
    layout="wide"
)

# 设置为模型ID或本地文件夹路径
model_path = os.environ.get('ICHOSEN_WEB_MODEL', '/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B')
cuda_visible_devices = os.environ.get("CUDA_VISIBLE_DEVICES")
print(f"---> model_path: '{model_path}', cuda_visible_devices: {cuda_visible_devices}")
num_gpus = 1
if cuda_visible_devices is not None:
    gpu_ids = [gpu_id for gpu_id in cuda_visible_devices.split(",") if gpu_id.strip()]
    num_gpus = len(gpu_ids)
    print(f"---> num_gpus: {num_gpus}, GPU IDs: {gpu_ids}")
else:
    print("---> CUDA_VISIBLE_DEVICES is not set!")


@st.cache_resource
def get_model():
    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    model = auto_load_model(model_path)
    model = model.eval()
    return tokenizer, model

# 加载Chatglm3的model和tokenizer
tokenizer, model = get_model()

# 初始化历史记录和past key values
if "history" not in st.session_state:
    st.session_state.history = []
if "past_key_values" not in st.session_state:
    st.session_state.past_key_values = None

# 设置max_length、top_p和temperature
max_length = st.sidebar.slider("max_length", 0, 32768, 32768, step=1)
top_p = st.sidebar.slider("top_p", 0.0, 1.0, 0.8, step=0.01)
temperature = st.sidebar.slider("temperature", 0.0, 1.0, 0.6, step=0.01)

# 清理会话历史
buttonClean = st.sidebar.button("清理会话历史", key="clean")
if buttonClean:
    st.session_state.history = []
    st.session_state.past_key_values = None
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    st.rerun()

# 渲染聊天历史记录
for i, message in enumerate(st.session_state.history):
    if message["role"] == "user":
        with st.chat_message(name="user", avatar="user"):
            st.markdown(message["content"])
    else:
        with st.chat_message(name="assistant", avatar="assistant"):
            st.markdown(message["content"])

# 输入框和输出框
with st.chat_message(name="user", avatar="user"):
    input_placeholder = st.empty()
with st.chat_message(name="assistant", avatar="assistant"):
    message_placeholder = st.empty()

# 获取用户输入
prompt_text = st.chat_input("请输入您的问题")

# 如果用户输入了内容,则生成回复
if prompt_text:

    input_placeholder.markdown(prompt_text)
    history = st.session_state.history
    past_key_values = st.session_state.past_key_values
    for response, history, past_key_values in model.stream_chat(
        tokenizer,
        prompt_text,
        history,
        past_key_values=past_key_values,
        max_length=max_length,
        top_p=top_p,
        temperature=temperature,
        return_past_key_values=True,
    ):
        message_placeholder.markdown(response)

    # 更新历史记录和past key values
    st.session_state.history = history
    st.session_state.past_key_values = past_key_values
