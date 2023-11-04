import gradio as gr
from transformers.utils.versions import require_version

from llmtuner.webui.components import (
    create_top,
    create_train_tab,
    create_eval_tab,
    create_infer_tab,
    create_export_tab,
    create_chat_box
)
from llmtuner.webui.common import save_config
from llmtuner.webui.css import CSS
from llmtuner.webui.engine import Engine


require_version("gradio==3.50.2", "To fix: pip install gradio==3.50.2")


page_title = """<h1 align="left">👨‍🔬 iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.</h1>"""
term_of_use = """**Terms of use:** By using this service, users are required to agree to the following terms: The service is a research preview intended for non-commercial use only. It only provides limited safety measures and may generate offensive content. It must not be used for any illegal, harmful, violent, racist, or sexual purposes."""


def create_ui() -> gr.Blocks:
    engine = Engine(pure_chat=False)

    with gr.Blocks(title="iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.", css=CSS) as demo:
        gr.Markdown(page_title)
        engine.manager.all_elems["top"] = create_top()
        lang: "gr.Dropdown" = engine.manager.get_elem("top.lang")

        with gr.Tab("Train"):
            engine.manager.all_elems["train"] = create_train_tab(engine)

        with gr.Tab("Evaluate"):
            engine.manager.all_elems["eval"] = create_eval_tab(engine)

        with gr.Tab("Chat"):
            engine.manager.all_elems["infer"] = create_infer_tab(engine)

        with gr.Tab("Export"):
            engine.manager.all_elems["export"] = create_export_tab(engine)

        demo.load(engine.resume, outputs=engine.manager.list_elems())
        lang.change(engine.change_lang, [lang], engine.manager.list_elems(), queue=False)
        lang.input(save_config, inputs=[lang], queue=False)

        gr.Markdown(term_of_use)

    return demo


def create_web_demo() -> gr.Blocks:
    engine = Engine(pure_chat=True)

    with gr.Blocks(title="iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.", css=CSS) as demo:
        gr.Markdown(page_title)
        lang = gr.Dropdown(choices=["en", "zh"])
        engine.manager.all_elems["top"] = dict(lang=lang)

        chat_box, _, _, chat_elems = create_chat_box(engine, visible=True)
        engine.manager.all_elems["infer"] = dict(chat_box=chat_box, **chat_elems)

        demo.load(engine.resume, outputs=engine.manager.list_elems())
        lang.change(engine.change_lang, [lang], engine.manager.list_elems(), queue=False)
        lang.input(save_config, inputs=[lang], queue=False)

        gr.Markdown(term_of_use)

    return demo


if __name__ == "__main__":
    demo = create_ui()
    demo.queue()
    demo.launch(server_name="0.0.0.0", server_port=6721, share=False, inbrowser=True)
