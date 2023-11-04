import readline
from llmtuner import ChatModel
from llmtuner.res.rep import rep_res


def main():
    chat_model = ChatModel()
    history = []
    print("Welcome to the CLI application, use `clear` to remove the history, use `exit` to exit the application.")

    while True:
        try:
            query = input("\nUser: ")
        except UnicodeDecodeError:
            print("Detected decoding error at the inputs, please set the terminal encoding to utf-8.")
            continue
        except Exception:
            raise

        if query.strip() == "exit":
            break

        if query.strip() == "clear":
            #history = []
            history = [("你是谁", "我是人工智能助手 iChosenGPT（中文名：臻慧聊）。我是由求臻医学科技（浙江）有限公司和北京臻知临床智能有限公司于 2023 年共同训练的语言模型。")]
            history += [("你叫什么", "我的中文名叫臻慧聊，英文名为 iChosenGPT。我是由求臻医学科技（浙江）有限公司和北京臻知临床智能有限公司于 2023 年共同训练的语言模型。")]
            print("History has been removed.")
            continue

        print("iChosenGPT: ", end="", flush=True)

        response = ""
        # for new_text in chat_model.stream_chat(query, history):
        #     print(new_text, end="", flush=True)
        #     response += new_text
        # print()
        # Quan Xu, 2023-11-04: 上面4行替换为如下！
        for new_text in chat_model.stream_chat(query, history):
            new_text = rep_res(new_text)
            #print(new_text, end="", flush=True)
            response += new_text
        response = rep_res(response)
        print(response)

        history = history + [(query, response)]


if __name__ == "__main__":
    main()
