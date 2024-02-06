# RAG 简介

本专题将重点介绍 LLM 领域的RAG（Retrieval Augmented Generation，检索增强生成）技术，手把手带领大家搭建自己的知识库对话系统。本专题的示例将更多使用 iChosenGPT-API 做演示，同时也会教大家利用 HuggingFace 模型来搭建自己本地的 RAG 系统。如果对你有点帮助，看完别忘了点个小星星（Star），这是对我们的最大认可。


## 话不多说，先上RAG尝鲜代码

```python
! pip install llama-index
! pip install html2text

import os
from llama_index import VectorStoreIndex, download_loader

#####################
# Environment setting
os.environ['OPENAI_API_BASE'] = 'https://igptapi.chosenmedinfo.com/v1'
os.environ['OPENAI_API_KEY'] = 'XXXXXX'  # 从 iChosenGPT-API 平台（https://igptapi.chosenmedinfo.com）获取！

# os.environ['OPENAI_API_BASE'] = 'https://api.openai.com/v1'
# os.environ['OPENAI_API_KEY'] = 'XXXXXX'  # 从 OpenAI 官网（https://platform.openai.com/api-keys）获取！

#############
# Data loader
BeautifulSoupWebReader = download_loader("BeautifulSoupWebReader")
loader = BeautifulSoupWebReader()
documents = loader.load_data(
    urls=[
        'https://chosenmedtech.com/about/jieshao.html', 
        'https://chosenmedtech.com/about/shili.html'
    ]
)

#################################
# Build an index and query engine
index = VectorStoreIndex.from_documents(documents)
query_engine = index.as_query_engine(
    similarity_top_k=6
)

################
# Query you data
ichosengpt_splitter = "=================================="
print(f"{ichosengpt_splitter}\niChosenGPT RAG Tutorial\n{ichosengpt_splitter}")

query_string1 = "求臻医学成立于哪一年？"
response1 = query_engine.query(query_string1)
print(f"Q1: {query_string1}\nA1: {str(response1)}\n{ichosengpt_splitter}")

query_string2 = "求臻医学一站式肿瘤精准诊疗知识挖掘平台OncoPubMiner发表在哪？"
response2 = query_engine.query(query_string2)
print(f"Q2: {query_string2}\nA2: {str(response2)}\n{ichosengpt_splitter}")

query_string3 = "求臻医学的业务涵盖哪些场景？"
response3 = query_engine.query(query_string3)
print(f"Q3: {query_string3}\nA3: {str(response3)}\n{ichosengpt_splitter}")

query_string4 = "求臻医学首席科学家是谁？详细介绍一下他。"
response4 = query_engine.query(query_string4)
print(f"Q4: {query_string4}\nA4: {str(response4)}\n{ichosengpt_splitter}")

query_string5 = "求臻医学截至目前发表了多少论文，发表在了哪些期刊？"
response5 = query_engine.query(query_string5)
print(f"Q5: {query_string5}\nA5: {str(response5)}\n{ichosengpt_splitter}")
```

**备注：**

运行上述代码，有一个前提，那就是需要设置环境变量，包括大模型接口地址和API Key。这个你可以去[OpenAI官网](https://platform.openai.com/api-keys)获取，也可以从我们的 [iChosenGPT-API](https://igptapi.chosenmedinfo.com) 平台注册账号获取，然后替换上面代码中的“OPENAI_API_KEY”。


## RAG 简介

- 检索增强生成（Retrieval Augmented Generation，简称RAG）是一种自然语言处理技术，它结合了检索式方法和生成式方法的优点，用于提高语言模型的生成质量和准确性。在RAG中，语言模型在生成文本时会利用一个外部知识库进行检索，以获取相关信息并将其融入生成的文本中。这样可以确保生成的文本更加准确、有根据，同时还能避免生成不实或误导性的内容。
- 需要RAG的原因在于，传统的生成式语言模型在生成文本时，往往只能基于模型内部的参数和训练数据进行预测，这可能导致生成的文本缺乏准确性、细节或上下文相关性。而检索式方法虽然可以提供准确的信息，但生成的文本可能不够流畅自然。此外，大型语言模型（LLM）的知识更新很困难，即使有新的知识出现，LLM也很难及时地更新其内部知识。而RAG通过结合这两种方法的优点，可以在生成文本时利用外部知识库进行检索，从而避免了LLM内部知识更新的困难，提高生成文本的准确性和可信度，同时还能避免生成不实或误导性的内容。因此，RAG在许多自然语言处理任务中都具有广泛的应用前景。


## RAG 原理

RAG的原理是结合了检索式方法和生成式方法的优点，以提高语言模型的生成质量和准确性。具体来说，RAG的工作流程如下：

- 输入：首先，用户向RAG提供一个输入查询，例如一个问题或一个文本片段。
- 检索：然后，RAG会利用一个外部知识库进行检索，以获取与输入查询相关的信息。这个知识库可以是一个文档集合、一个知识图谱或其他形式的知识源。
- 筛选：检索到的信息可能非常多，因此RAG需要对这些信息进行筛选，以选择最相关的信息。筛选的方法可以是基于关键词匹配、基于语义相似度或其他方法。
- 合并：筛选出的信息会被合并到输入查询中，形成一个增强的输入。这个增强的输入会作为生成式模型的输入，用于生成文本。
- 生成：最后，RAG会利用一个生成式模型生成文本。这个生成式模型可以是一个基于Transformer的模型，例如 [iChosenGPT](https://igptweb.chosenmedinfo.com), [ChatGPT](https://chat.openai.com/) 等。生成的文本会根据增强的输入进行生成，从而确保生成的文本更加准确、有根据。

通过以上步骤，RAG可以结合**检索式方法**和**生成式方法**的优点，提高语言模型的生成质量和准确性，同时可以利用外部知识库的更新解决LLM的时新性问题。


## RAG 优缺点

**RAG的优点：**

- 可以利用大规模外部知识改进LLM的推理能力和事实性。
- 可以实时更新知识库，提高答案的准确性和可信度。
- 可以通过提示工程等技术提高答案的可解释性，提高用户满意度。
- 可以使用 [LangChain](https://github.com/langchain-ai/langchain) 和 [Llama-Index](https://github.com/run-llama/llama_index) 等框架快速实现原型。

**RAG的缺点：**

- 知识检索阶段依赖相似度检索技术，可能检索到的文档与问题不太相关。
- 在生成答案时，可能缺乏一些基本世界知识，无法应对用户询问知识库之外的基本问题。
- 向量数据库技术尚未成熟，数据量较大时速度和性能存在挑战。
- 需要额外的检索组件，增加了架构的复杂度和维护成本。


## RAG 优化方案

针对RAG的缺点，可以采取以下优化方案：

- 检查和清洗输入数据质量：在使用RAG之前，需要对输入数据进行检查和清洗，确保数据的准确性和完整性。可以使用数据清洗工具和算法来去除噪声和异常值，提高数据质量。
- 调优块大小、top k检索和重叠度：在RAG的检索阶段，可以调整块大小、top k检索和重叠度等参数，以提高检索的准确性和效率。例如，可以使用较小的块大小来提高检索的精度，使用较大的top k值来提高检索的覆盖率，使用较小的重叠度来减少检索的时间。
- 利用文档元数据进行更好的过滤：在RAG的检索阶段，可以利用文档元数据进行更好的过滤，以提高检索的准确性和效率。例如，可以使用文档的标题、作者、日期等元数据来过滤无关的文档，提高检索的精度。
- 优化prompt以提供有用的说明：在RAG的生成阶段，可以优化prompt以提供有用的说明，以提高生成的准确性和可解释性。例如，可以使用更具体的提示词和更详细的说明来指导LLM生成更准确和有用的文本。


## RAG 总结

- RAG是一种前景广阔但仍在发展的技术，它利用大规模外部知识改进LLM的推理能力和事实性，可以实时更新知识库，提高答案的准确性和可信度，通过提示工程等技术提高答案的可解释性，提高用户满意度。但是，RAG也存在一些缺点，如知识检索阶段依赖相似度检索技术，可能检索到的文档与问题不太相关，在生成答案时可能缺乏一些基本世界知识，无法应对用户询问知识库之外的基本问题，向量数据库技术尚未成熟，数据量较大时速度和性能存在挑战，需要额外的检索组件，增加了架构的复杂度和维护成本。
- 为了提高RAG的性能，需要进行大量的工程化优化，包括检查和清洗输入数据质量，调优块大小、top k检索和重叠度，利用文档元数据进行更好的过滤，优化prompt以提供有用的说明等。随着研究的继续，RAG可能会变得更加稳健，适合工业应用。


## RAG 系列教程

为了帮助大家更好地理解RAG，用上RAG，从此篇开始我们将开启完整的RAG教程，包括RAG理论和RAG实战两部分。欢迎大家点赞/Star，持续关注。


## 参考资源

- [iChosenGPT](https://igptweb.chosenmedinfo.com)
- [iChosenGPT-API](https://igptapi.chosenmedinfo.com)
- [LangChain](https://github.com/langchain-ai/langchain)
- [LlamaIndex](https://github.com/run-llama/llama_index)