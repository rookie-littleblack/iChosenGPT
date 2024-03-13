# 基于 Elasticsearch 的混合检索

RAG（Retrieval-Augmented Generation）的出现是为了解决传统生成式模型在处理大规模信息时的效率和质量问题。RAG结合了信息检索和生成式模型的优势，以提高生成结果的相关性和多样性。它采用了多种检索方式，包括基于语义的检索、基于语境的检索和基于知识图谱的检索。基于语义的检索着重于词义理解和语境分析，使得生成结果更贴近用户意图；基于语境的检索利用上下文信息提高生成的一致性和连贯性；基于知识图谱的检索则丰富生成内容。这些检索方式各有独特意义和特点，但单一方式可能无法满足复杂需求。因此，需要混合检索来综合利用各种优势，提供更全面、精准的生成结果。混合检索能够平衡不同检索方式之间的权衡，并针对不同场景进行灵活调整，以达到更佳的生成效果。

在搜索算法方面，没有一种适合所有场景或需求的解决方案。不同的算法在不同的场景中表现更好，有时需要结合多种算法来实现最佳结果。在Elasticsearch中，一种流行的结合搜索算法的方法是使用混合搜索，将BM25算法用于文本搜索，将HNSW算法用于最近邻搜索。在本文中，我们将探讨Elasticsearch中混合搜索的优点、挑战和用例。

BM25是一种广泛使用的文本搜索算法，它根据查询中每个术语的词频和逆文档频率计算得分。正如我们在之前的博客文章中看到的那样，HNSW是一种用于近似最近邻搜索的算法，它构建了一个由相互连接的节点组成的小世界图。通过结合这两种算法，我们可以执行混合搜索，发挥两者的优势。

混合搜索最大的挑战之一是平衡两种算法的权重。换句话说，我们需要决定在结合它们时给BM25得分多少权重，给HNSW得分多少权重。这可能有些棘手，因为最佳权重可能取决于数据和特定的搜索场景。

然而，如果正确执行，混合搜索可以显著提高搜索准确性和效率。例如，在电子商务应用程序中，可以使用混合搜索将文本搜索与视觉搜索结合起来，使用户能够找到与其文本和视觉查询都匹配的产品。在科学应用中，可以使用混合搜索将文本搜索与高维数据上的相似性搜索结合起来，使研究人员能够基于文本内容和数据找到相关文档。

让我们看一个如何在Elasticsearch中实现混合搜索的示例。首先，我们需要使用包含BM25和HNSW相似性算法的映射对我们的数据进行索引：

```json
PUT byte-image-index
{
  "mappings": {
    "properties": {
      "byte-image-vector": {
        "type": "dense_vector",
        "element_type": "byte",
        "dims": 2,
        "index": true,
        "similarity": "cosine"
      },
      "title": {
        "type": "text"
      },
      "area": {
        "type": "keyword"
      }
    }
  }
}
```

在这里，我们定义了一个映射，其中包括用于BM25文本搜索的"title"字段和用于HNSW高维数据相似性搜索的"byte-image-vector"字段。接下来，我们对数据进行索引：

```json
POST byte-image-index/_bulk?refresh=true
{ "index": { "_id": "1" } }
{ "byte-image-vector": [5, -20], "title": "moose family", "area": "Asia" }
{ "index": { "_id": "2" } }
{ "byte-image-vector": [8, -15], "title": "alpine lake", "area": "Europe" }
{ "index": { "_id": "3" } }
{ "byte-image-vector": [11, 23], "title": "full moon", "area": "Africa" }
```

接下来，我们可以使用文本和向量字段执行搜索，如下所示：

```json
POST byte-image-index/_search
{
  "query": {
    "match": {
      "title": {
        "query": "mountain lake",
        "boost": 0.5
      }
    }
  },
  "knn": {
    "field": "byte-image-vector",
    "query_vector": [6, 10],
    "k": 5,
    "num_candidates": 50,
    "boost": 0.5,
    "filter": {
      "term": {
        "area": "Asia"
      }
    }
  },
  "size": 10
}
```

该搜索查询结合了对"title"字段的match查询和对"image-vector"字段的knn查询，使用了之前定义的混合相似性算法。在这个示例中，我们将BM25和HNSW的权重都设为0.5，但你可以尝试不同的权重来找到适合你数据和搜索场景的最佳平衡点。总的来说，Elasticsearch中的混合搜索是一项强大的技术，能够综合利用不同搜索算法的优势，以提高搜索准确性和效率。通过将用于文本搜索的BM25算法与用于最近邻搜索的HNSW算法结合起来，用户可以在其搜索和分析应用程序中充分利用这两种算法的强大功能。通过精心调整这两种算法的权重，混合搜索可以成为广泛应用的强大工具。

上述搜索结果为：

```json
{
  "took": 10,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 3,
      "relation": "eq"
    },
    "max_score": 0.9070214,
    "hits": [
      {
        "_index": "byte-image-index",
        "_id": "2",
        "_score": 0.9070214,
        "_source": {
          "byte-image-vector": [
            8,
            -15
          ],
          "title": "alpine lake"
        }
      },
      {
        "_index": "byte-image-index",
        "_id": "3",
        "_score": 0.09977779,
        "_source": {
          "byte-image-vector": [
            11,
            23
          ],
          "title": "full moon"
        }
      },
      {
        "_index": "byte-image-index",
        "_id": "1",
        "_score": 0.014644662,
        "_source": {
          "byte-image-vector": [
            5,
            -20
          ],
          "title": "moose family"
        }
      }
    ]
  }
}
```

我们甚至可以针对 knn 搜索设置一下 filter 以限制他的搜索范围，比如：

```json
POST byte-image-index/_search
{
  "query": {
    "match": {
      "title": {
        "query": "mountain lake",
        "boost": 0.5
      }
    }
  },
  "knn": {
    "field": "byte-image-vector",
    "query_vector": [6, 10],
    "k": 5,
    "num_candidates": 50,
    "boost": 0.5,
    "filter": {
      "term": {
        "area": "Asia"
      }
    }
  },
  "size": 10
}
```

在上面，我们使用 filter 来针对 area 来进行过滤，从而加快搜索的速度。上面返回的结果为：

```json
{
  "took": 1,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 2,
      "relation": "eq"
    },
    "max_score": 0.49041456,
    "hits": [
      {
        "_index": "byte-image-index",
        "_id": "2",
        "_score": 0.49041456,
        "_source": {
          "byte-image-vector": [
            8,
            -15
          ],
          "title": "alpine lake",
          "area": "Europe"
        }
      },
      {
        "_index": "byte-image-index",
        "_id": "1",
        "_score": 0.07322331,
        "_source": {
          "byte-image-vector": [
            5,
            -20
          ],
          "title": "moose family",
          "area": "Asia"
        }
      }
    ]
  }
}
```

## 完整实战示例：

前面有一篇（https://github.com/rookie-littleblack/iChosenGPT/blob/master/blogs/rag/20240210-2213_The_Role_of_Vector_Db_In_RAG.md）我们介绍了 Elasticsearch 的安装。这里我们将用到那个数据库。

基础环境准备：

```bash
conda create -n test_es_search python=3.11 -y
conda activate test_es_search
pip install elasticsearch elasticsearch-dsl annoy
```

可执行脚本：

```python
from datetime import datetime
from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search, Q
from annoy import AnnoyIndex


class ElasticsearchSearch:
    def __init__(self, url):
        self.es = Elasticsearch([url], max_retries=10)
        self.index_name = datetime.now().strftime('%Y%m%d-%H%M%S') + "_test_es_search"

    def create_index(self, mapping):
        self.es.indices.create(index=self.index_name, body=mapping)

    def create_index_usually_used(self):
        mapping={
            "mappings": {
                "properties": {
                    "content": {
                        "type": "text",
                        "analyzer": "custom_lowercase_analyzer"
                    }
                }
            },
            "settings": {
                "analysis": {
                    "analyzer": {
                        "custom_lowercase_analyzer": {
                            "type": "custom",
                            "tokenizer": "standard",
                            "filter": ["lowercase"]
                        }
                    }
                }
            }
        }
        self.create_index(mapping)

    def insert_data(self, doc_id, doc_body):
        self.es.index(index=self.index_name, id=doc_id, body=doc_body)

    def refresh_index(self):
        self.es.indices.refresh(index=self.index_name)

    def build_vector_index(self, vector_size, metric="angular", num_trees=10):
        vector_index = AnnoyIndex(vector_size, metric=metric)
        for doc_id in range(1, 3):
            vector = self.es.get(index=self.index_name, id=doc_id)["_source"]["vector"]
            vector_index.add_item(doc_id, vector)
        vector_index.build(num_trees)
        return vector_index

    def keyword_search(self, keywords, fields=["title", "content"]):
        search_body_single = {
            "query": {
                "match": {
                    "content": keywords,
                }
            }
        }
        result = self.es.search(index=self.index_name, body=search_body_single)
        return result

    def structured_search(self, query):
        s = Search(using=self.es, index=self.index_name).query(Q("match", content=query))
        result = s.execute()
        return result

    def vector_search(self, vector_index, query_vector, n=5):
        similar_docs = vector_index.get_nns_by_vector(query_vector, n=n)
        docs_info = [self.es.get(index=self.index_name, id=doc_id)["_source"] for doc_id in similar_docs]
        return docs_info

    def vector_search_on_keywords(self, keyword_result, vector_index):
        keyword_result_ids = [int(hit["_id"]) for hit in keyword_result["hits"]["hits"]]
        vector_index_filtered = AnnoyIndex(len(vector_index.get_item_vector(0)), metric="angular")
        for doc_id in keyword_result_ids:
            vector = self.es.get(index=self.index_name, id=doc_id)["_source"]["vector"]
            vector_index_filtered.add_item(doc_id, vector)
        vector_index_filtered.build(10)
        similar_docs = vector_index_filtered.get_nns_by_vector(vector_index.get_item_vector(0), n=len(keyword_result_ids))
        docs_info = [self.es.get(index=self.index_name, id=doc_id)["_source"] for doc_id in similar_docs]
        return docs_info

    def comprehensive_search(self, query, query_vector):
        keyword_result = self.keyword_search(query)
        structured_result = self.structured_search(query)
        
        vector_index = self.build_vector_index(len(query_vector))
        vector_result = self.vector_search(vector_index, query_vector)
        vector_result_filtered = self.vector_search_on_keywords(keyword_result, vector_index)

        return {
            "Keyword Search Result": keyword_result,
            "Structured Search Result": structured_result.hits,
            "Vector Search Result": vector_result,
            "Vector Search Result on Keyword Search": vector_result_filtered
        }


query = "programming"
query_vector = [0.15, 0.25, 0.35]
es_search = ElasticsearchSearch("http://<your_es_account>:<your_es_password>@<your_es_server_ip>:6030")
es_search.create_index_usually_used()
es_search.insert_data(doc_id=1, doc_body={
    "title": "Elasticsearch is powerful",
    "content": "Elasticsearch is a distributed search and analytics engine.",
    "vector": [0.1, 0.2, 0.3]
})
es_search.insert_data(doc_id=2, doc_body={
    "title": "Python a programming",
    "content": "Python is a versatile programming language.",
    "vector": [0.4, 0.5, 0.6]
})
es_search.refresh_index()
result = es_search.comprehensive_search(query, query_vector)
print("Comprehensive Search Result:", result)
```

执行结果：

```bash
Comprehensive Search Result: {'Keyword Search Result': ObjectApiResponse({'took': 5, 'timed_out': False, '_shards': {'total': 1, 'successful': 1, 'skipped': 0, 'failed': 0}, 'hits': {'total': {'value': 1, 'relation': 'eq'}, 'max_score': 0.7361701, 'hits': [{'_index': '20240313-183930_test_es_search', '_id': '2', '_score': 0.7361701, '_source': {'title': 'Python a programming', 'content': 'Python is a versatile programming language.', 'vector': [0.4, 0.5, 0.6]}}]}}), 'Structured Search Result': [<Hit(20240313-183930_test_es_search/2): {'title': 'Python a programming', 'content': 'Python is a ve...}>], 'Vector Search Result': [{'title': 'Elasticsearch is powerful', 'content': 'Elasticsearch is a distributed search and analytics engine.', 'vector': [0.1, 0.2, 0.3]}, {'title': 'Python a programming', 'content': 'Python is a versatile programming language.', 'vector': [0.4, 0.5, 0.6]}], 'Vector Search Result on Keyword Search': [{'title': 'Python a programming', 'content': 'Python is a versatile programming language.', 'vector': [0.4, 0.5, 0.6]}]}
```