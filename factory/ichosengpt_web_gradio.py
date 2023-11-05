from llmtuner import create_web_demo
import os


gradio_port = os.environ.get('ICHOSEN_GRA_WPORT', 6722)
model_path = os.environ.get('ICHOSEN_GRA_MODEL', '/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B')
print(f"---> model_path: '{model_path}', gradio_port: '{gradio_port}'")


def main():
    demo = create_web_demo()
    demo.queue()
    demo.launch(server_name="0.0.0.0", server_port=int(gradio_port), share=False, inbrowser=True)


if __name__ == "__main__":
    main()
