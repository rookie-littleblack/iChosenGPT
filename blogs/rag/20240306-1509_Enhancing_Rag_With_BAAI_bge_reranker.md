# 使用 BAAI/bge-reranker 增强 RAG

检索增强生成（RAG）在自然语言处理领域取得了重大突破，尤其是对融合信息检索与生成模型的任务而言。近期，llama_index 库中实现了对 `FlagEmbeddingReranker` 的支持。该工具执行重新排名，提高了检索阶段的准确性和相关性。本文将提供 `FlagEmbeddingReranker` 的全面教程，深入探讨其功能、解决的问题以及在改进 RAG 系统中的重要性。

## FlagEmbeddingReranker 简介

`FlagEmbeddingReranker` 是 `llama_index` 库中的一个类，专为基于给定查询的节点（或文档）的相关性重新排名而设计。它利用预训练模型计算相关性分数并选择前N个节点。这种重新排名机制在 RAG 中尤为有价值，因为检索到的文档的质量直接影响生成质量。

该重新排名器可与 `BAAI/bge-reranker` 模型的任何一个配套使用，例如 `BAAI/bge-reranker-base`、`BAAI/bge-reranker-large`、`BAAI/bge-reranker-large-en-v1.5`。

## 为什么在 RAG 中使用 FlagEmbeddingReranking ？

最新的 `BAAI/bge-reranker` 模型，是 `FlagEmbeddingReranker` 的核心组成部分，被设计用于：

- **直接计算相关性**：它们以问题和文档作为输入，并直接输出相似度分数，提供比基于向量嵌入模型更细致的相关性度量。

- **优化评分范围**：使用交叉熵损失进行优化，这些模型在评分方面具有灵活性，不受特定范围的限制。

- **适应特定用例**：它们的微调能力使它们成为重新排名由嵌入模型返回的前k个文档的理想选择，确保高相关性和准确性。

## 设置

在深入实施之前，请确保已安装 `llama_index` 和 `FlagEmbedding` 包。如果没有，请使用以下命令进行安装：

```bash
pip install llama-index FlagEmbedding
```

## 实施 FlagEmbeddingReranker

以下是将 `FlagEmbeddingReranker` 整合到您的 RAG 设置中的步骤：

### 1. 导入和初始化

首先，导入必要的类并初始化 `FlagEmbeddingReranker`。

```python
from llama_index.postprocessor.flag_embedding_reranker import FlagEmbeddingReranker

reranker = FlagEmbeddingReranker(
    top_n=3,
    model="BAAI/bge-reranker-large",
    use_fp16=False
)
```

### 2. 准备节点和查询

假设您有一个 `NodeWithScore` 对象列表，每个对象代表 RAG 初始查询阶段检索到的文档。

```python
from llama_index.schema import NodeWithScore, QueryBundle, TextNode

documents = [
    "Retrieval-Augmented Generation (RAG) combines retrieval and generation for NLP tasks.",
    "Generative Pre-trained Transformer (GPT) is a language generation model.",
    "RAG uses a retriever to fetch relevant documents and a generator to produce answers.",
    "BERT is a model designed for understanding the context of a word in a sentence."
]

nodes = [NodeWithScore(node=TextNode(text=doc)) for doc in documents]
query = "What is RAG in NLP?"
```

### 3. 重新排名节点

使用 `FlagEmbeddingReranker` 对节点和查询进行重新排名。

```python
query_bundle = QueryBundle(query_str=query)
ranked_nodes = reranker._postprocess_nodes(nodes, query_bundle)
```

### 4. 分析结果

返回的 ranked_nodes 将是基于与查询相关性排序的列表。

```python
for node in ranked_nodes:
    print(node.node.get_content(), "-> Score:", node.score)
```

## 预期输出

输出应反映每个文档与查询 `“What is RAG in NLP?”` 的相关性。理想情况下，明确提到 RAG 及其在 NLP 中的作用的文档应排名较高。

- “Retrieval-Augmented Generation (RAG) combines retrieval and generation for NLP tasks.” -> 较高分数

- “RAG uses a retriever to fetch relevant documents and a generator to produce answers.” -> 排名次高

虽然与 NLP 相关的有关 GPT 和 BERT 的文档，但相对于有关 RAG 的特定查询，它们较不相关，因此得分较低。

## 结论

配备了新的 `BAAI/bge-reranker` 模型的 `FlagEmbeddingReranker` 是任何 RAG 流程的强大补充。它确保您的检索阶段不仅仅是获取大量文档，而且准确地聚焦于最相关的文档。无论您是开发复杂的 NLP 应用程序还是探索语言模型的前沿，整合这个先进的重新排名工具在实现高质量、相关性输出方面至关重要。

## 参考文献

- [Improving Llamaindex RAG performance with ranking](https://colemurray.medium.com/enhancing-rag-with-baai-bge-reranker-a-comprehensive-guide-fe994ba9f82a)

- [HuggingFace - BAAI/bge-reranker-large](https://huggingface.co/BAAI/bge-reranker-large)