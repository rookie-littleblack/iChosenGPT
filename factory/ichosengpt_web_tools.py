import streamlit as st
# The code "st.set_page_config()" should be placed immediately after the import statement for Streamlit, 
# as the scripts demo_tool, demo_chat, and demo_code also utilize Streamlit.
# As "st.set_page_config" has the requirements:
# "This must be the first Streamlit command used on an app page, and must only be set once per page."
# https://docs.streamlit.io/library/api-reference/utilities/st.set_page_config
st.set_page_config(
    page_title="iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.",
    page_icon="👨‍🏫",
    layout='centered',
    initial_sidebar_state='expanded'
)

from enum import Enum
from models.chatglm3.composite_demo import demo_tool, demo_chat, demo_code
import torch


DEFAULT_SYSTEM_PROMPT = '''
You are iChosenGPT, a large language model trained by ChosenMed and iChosen Group. Follow the user's instructions carefully. Respond using markdown. Respond with English.
'''.strip()

class Mode(str, Enum):
    CHAT, TOOL, CODE = '💬 Chat', '🛠️ Tool', '💻 Code Interpreter'


with st.sidebar:
    max_length = st.sidebar.slider(
        "max_length", 0, 32768, 32768, step=1
    )
    top_p = st.slider(
        'top_p', 0.0, 1.0, 0.8, step=0.01
    )
    temperature = st.slider(
        'temperature', 0.0, 1.5, 0.95, step=0.01
    )
    system_prompt = st.text_area(
        label="System Prompt (Only for chat mode)",
        height=300,
        value=DEFAULT_SYSTEM_PROMPT,
    )

st.title("iChosenGPT")
st.write("Leverage the power of large models to fuel advancements in biomedical research.")

prompt_text = st.chat_input(
    'Chat with iChosenGPT!',
    key='chat_input',
)

tab = st.radio(
    'Mode',
    [mode.value for mode in Mode],
    horizontal=True,
    label_visibility='hidden',
)

match tab:
    case Mode.CHAT:
        demo_chat.main(max_length, top_p, temperature, system_prompt, prompt_text)
    case Mode.TOOL:
        demo_tool.main(max_length, top_p, temperature, prompt_text)
    case Mode.CODE:
        demo_code.main(max_length, top_p, temperature, prompt_text)
    case _:
        st.error(f'Unexpected tab: {tab}')
