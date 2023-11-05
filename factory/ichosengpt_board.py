from llmtuner import create_ui
import os


board_port = os.environ.get('ICHOSEN_BOARD_MODEL_PORT', 6721)
print(f"---> board_port: '{board_port}'")


def main():
    demo = create_ui()
    demo.queue()
    demo.launch(server_name="0.0.0.0", server_port=int(board_port), share=False, inbrowser=True)


if __name__ == "__main__":
    main()
