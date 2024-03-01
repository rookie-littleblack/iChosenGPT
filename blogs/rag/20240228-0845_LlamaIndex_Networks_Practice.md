# 新功能：LlamaIndex Networks 实战

<img src="./imgs/20240301103654.png" width="80%">

> 利用新的 llama-index 扩展包，快速创建 RAG 系统网络成为可能。数据供应商现在能够在其数据上构建强大的 RAG，并通过 ContributorService 将其公开，以便加入 LlamaIndex 网络。

RAG 的核心理念是向 LLM 注入上下文（或知识），从而获得更准确的响应。因此，RAG 系统的一个关键组件是获取知识的数据源。在这一背景下，我们可以自然地推断，RAG 系统能够利用的知识越多，最终结果就会变得越好（就回答潜在的深度和广度问题而言）。这一概念与几乎所有其他数据驱动学科中的思想并无太大不同——访问更多（好的）数据，并随后有效地使用，通常会带来更好的结果。

正是在这样的背景下，我们很高兴地宣布发布我们最新的 llama-index 库扩展，称为 llama-index-networks。此库扩展使得可以在外部数据源上构建 RAG 网络，并由外部参与者提供。这一新的网络范式为数据供应商提供了一种新的方式，将他们的数据提供给需要它们的人，以构建更为知识渊博的系统！

在这篇博客文章中，我们将介绍新扩展库的主要类，并向您展示只需几行代码，就可以使您的 QueryEngine 准备好作为 RAG 网络的一部分进行贡献。我们还将分享关于在这个 LLM 的新时代，数据供应商如何实际向消费者提供数据的想法。

术语说明：在这篇文章中，我们使用 llama-index-networks 指代实际的扩展，而 llama-index[networks] 指代带有 llama-index-networks 扩展的 llama-index 的安装。

## Alex, Beth, 和 Bob 的故事

<img src="./imgs/20240301104043.png" width="80%">

> 网络中演员的示例及其问题陈述。

为了说明如何使用 llama-index-networks 包，我们考虑了三个虚构的人物，Alex、Bob和Beth，以及以下场景：

Bob和Beth都有自己的文档集，他们都已经在这些文档上建立了非常出色的 RAG 系统（当然使用了 llama-index！）

Alex听说Bob和Beth都有这些有见地的文档，并希望能够查询他们各自建立的RAG。

Bob和Beth非常善良（或者，也许他们得到了一些未公开的美元金额），同意让Alex访问他们的RAG系统。

为了促进这种新的知识交流方式，他们同意建立一个RAG网络，Alex可以查询。

### Bob和Beth在他们的RAG上建立了一个网络服务

<img src="./imgs/20240301104315.png" width="80%">

> ContributorService是围绕QueryEngine构建的。

使用 llama-index-networks 包，Bob和Beth只需几行代码就可以使各自的 QueryEngine 准备好参与网络。

```python
"""Beth's contributor service file.

Beth builds her QueryEngine and exposes it behind the standard
LlamaIndex Network Contributor Service. 

NOTE: Bob would probably make use of Docker and cloud 
compute services to make this production grade.
"""

from llama_index.networks.contributor import ContributorService
import uvicorn

beth_query_engine = ...
beth_contributor_service = ContributorService.from_config_file(
    ".env.contributor",  # settings/secrets for the service
    beth_query_engine
)


if __name__ == "__main__:
    uvicorn.run(beth_contributor_service.app, port=6099)
```

Bob会使用类似的代码行使他的 QueryEngine 准备好为任何 LlamaIndex 网络做出贡献。请注意，.env.contributor 文件中的 dotenv 包含服务设置以及任何必要的 API 密钥（例如，OPENAI_API_KEY 或 ANTHROPIC_API_KEY），这些在幕后是使用 FastAPI 实现的 REST 服务。

### Alex构建了一个NetworkQueryEngine

<img src="./imgs/20240301104530.png" width="80%">

> Alex构建了一个 NetworkQueryEngine，它连接到Beth和Bob的个人ContributorService。

对于Alex来说，他使用 llama-index-networks 扩展的 NetworkQueryEngine 类来能够连接到Beth和Bob的 ContributorService。

```python
"""Alex's network query engine.

Alex builds a NetworkQueryEngine to connect to a 
list of ContributorService’s.
"""

from llama_index.networks.contributor import ContributorClient
from llama_index.networks.query_engine import NetworkQueryEngine
from llama_index.llms.groq import Groq

# Use ContributorClient to connect to a ContributorService
beth_client = ContributorClient.from_config_file(
    env_file=".env.beth_contributor.client"
)
bob_client = ContributorClient.from_config_file(
    env_file=".env.bob_contributor.client"
)
contributors = [beth_client, bob_client]

# NetworkQueryEngine
llm = Groq()
network_query_engine = NetworkQueryEngine.from_args(
    contributors=contributors,
    llm=llm
)

# Can query it like any other query engine
network_query_engine.query("Why is the sky blue?")
```

在这里，dotenv 文件存储了连接到 ContributorService 所需的服务参数，如 api_url。

在继续阅读本博客文章的下一节之前，我们将在接下来的几行中解释当Alex查询他的 NetworkQueryEngine 时，幕后涉及的一些内容。当调用 query() 方法（也支持 Async）时，查询将发送给所有贡献者。他们的响应被存储为新的节点，并使用关联的 ResponseSynthesizer 合成响应。阅读完这些内容后，有些人可能会注意到，这是使用我们 QueryEngine 抽象时的通常模式；而这正是我们的目的。使用 NetworkQueryEngine 应该与您在我们库中使用其他 QueryEngine 的方式非常相似！

这标志着关于Alex、Bob和Beth的小故事的结束。

## 数据供应和消费的新世界

<img src="./imgs/20240301104836.png" width="80%">

> RAG市场是可以通过 llama-index[networks] 实现的一个用例。

一个可以通过 llama-index[networks] 轻松实现的可能世界是 RAG 市场。这是一个数据供应商将数据打包成 RAG 形式，供数据消费者扩展自己的查询系统知识的地方。潜在的 RAG（数据）供应商可以是您当地的报纸、图书出版公司等。

在这种新的数据供应和消费模式中，数据供应商有更大的责任以更易于消费的方式准备数据——特别是，供应商拥有构建查询引擎的责任。这将极大地惠及数据消费者，因为通过像 ContributorService（封装了 QueryEngine） 这样的标准接口，他们可以比以往任何时候都更容易地从数据中获取他们寻求的知识（例如，与交换原始数据的传统数据市场相比）。

正是出于这种愿景，我们构建了 llama-index[networks]，使其：（i）使数据供应商更容易以新的、可以说是更有效的方式提供数据中的知识，（ii）使数据消费者更容易连接到这些新的外部知识形式。

### 内部网络：另一个潜在的用例

除了为 RAG 市场提供动力外，我们还预见到了连接公司可能拥有但不一定管理的 RAG 的需求。更具体地说，特许经营权可能拥有其所有操作中的数据权利。虽然他们可以在整个数据库上构建一个“中心”的、单一的 RAG，但可能仍然更有效、更有效地在各个运营商上构建 RAG 并查询这些 RAG。

交换信息以构建更好、更知识渊博的系统的概念并不新鲜。然而，使用 RAG 来促进这种交换的想法（据我们所知，它是）可能是新的，我们相信需要这种协作的现有和新用例都可以从这个概念中受益。

### 关于隐私的快速说明

在数据协作中，隐私和安全是一个重要的考虑因素。值得一提的是，上述示例假设网络中共享的数据符合数据隐私和安全法律和法规。我们相信，随着这项技术的发展，将开发和纳入必要的功能和能力，以促进符合法规的 RAG 网络。

## 实战代码

### 创建实战环境

#### conda 环境

```bash
conda create -n test_llamaindexnetworks python=3.11 -y
conda activate test_llamaindexnetworks

pip install llama-index
pip install llama-index-networks
pip install llama-index-llms-openai-like
```

#### 工作环境

```bash
mkdir test_llamaindex_networks
cd test_llamaindex_networks
```

### 相关代码

完整的项目文件如下如所示：

<img src="./imgs/20240301110752.png" width="260">

#### 若干环境配置文件：

.env.contributor1.service

```bash
SECRET=secret
CONTRIBUTOR_PORT=6098

# API key
OPENAI_API_KEY=<YOUR_ICHOSENGPT_API_KEY_REPLACED_HERE>

# API base url
OPENAI_API_BASE=https://igptapi.chosenmedinfo.com/v1

# Embedding model name
MODEL_NAME_EMBED=text-embedding-ada-002

# LLM model name
MODEL_NAME_LLM=iChosenGPTtlv0
```

.env.contributor1.client

```bash
API_URL=http://0.0.0.0:6098

API_KEY=fake-token
```

.env.contributor2.service

```bash
SECRET=secret
CONTRIBUTOR_PORT=6099

# API key
OPENAI_API_KEY=<YOUR_ICHOSENGPT_API_KEY_REPLACED_HERE>

# API base url
OPENAI_API_BASE=https://igptapi.chosenmedinfo.com/v1

# Embedding model name
MODEL_NAME_EMBED=text-embedding-ada-002

# LLM model name
MODEL_NAME_LLM=iChosenGPTtlv0
```

.env.contributor2.client

```bash
API_URL=http://0.0.0.0:6099

API_KEY=fake-token
```

.env.consumer

```bash
# API key
OPENAI_API_KEY=<YOUR_ICHOSENGPT_API_KEY_REPLACED_HERE>

# API base url
OPENAI_API_BASE=https://igptapi.chosenmedinfo.com/v1

# Embedding model name
MODEL_NAME_EMBED=text-embedding-ada-002

# LLM model name
MODEL_NAME_LLM=iChosenGPTtlv0
```

#### 数据提供者代码

contributor1.py

```python
import os
from llama_index.core import VectorStoreIndex, Document
from llama_index.embeddings.openai import OpenAIEmbedding
from llama_index.llms.openai_like import OpenAILike
from llama_index.core.node_parser import SentenceSplitter
from llama_index.core.ingestion import IngestionPipeline


# Load environment
from dotenv import load_dotenv, find_dotenv
file_env = '.env.contributor1.service'
load_dotenv(find_dotenv(filename=file_env))


DOCUMENT = """
求臻医学科技（浙江）有限公司（以下简称“求臻医学”），专注于肿瘤精准诊疗领域，现为国家高新技术企业，国有参股混合所有制企业集团，国家医疗健康大数据中心成员单位。
求臻医学以新一代基因测序和先进信息挖掘技术为基础，依托《中国肿瘤基因图谱计划》和《肿瘤精准医学大数据平台》项目，深度融合基因检测和人工智能，致力于肿瘤液态活检领域诊断产品的开发及智能迭代升级，业务涵盖肿瘤早筛、伴随诊断、动态监测、预后评估、遗传筛查等多场景应用领域；同时不断探索发现中国人肿瘤基线及特异的生物标志物，助力药企抗肿瘤药物的研发。
聚焦肺癌、消化系统肿瘤、泌尿系统肿瘤、血液系统肿瘤等九大系统肿瘤，求臻医学自主开发了百余款Chosen系列产品，为患者提供精准的肿瘤基因检测服务；同时针对肿瘤基因检测院内临床应用场景，量身定做一站式高通量自动化解决方案，从“检”到“报”全程自动化，可落地医疗机构本地化开展更快速，更高效，更准确，更稳定的高通量基因检测方案，为临床应用提供“武器”。
求臻医学拥有中美两大研发基地，通过积极引入海内外顶尖科学家团队，持续加大在研发科研领域的投入，经过多年技术沉淀，已成长为具备自主知识产权的肿瘤精准医疗领域创新型企业，拥有百余项专利和生信软件著作权，具备独立开发涵盖肿瘤伴随诊断全流程的生物信息算法能力，其开发的国际首个基于NGS平台的MSI状态检测算法MSIsensor，被FDA批准的首个基于NGS的肿瘤多基因检测试剂盒（MSK-IMPACT）所采用；发表SCI文章350余篇，其中30余篇以第一作者/通讯作者身份发表在Nature、Science、Cell及其子刊上，自主知识产权的7项产品通过北京市新技术新产品（服务）认证；与此同时，公司荣获“中国最具投资价值企业50强”、“德勤-亦庄高科技高成长20强”、“创业未来独角兽企业”、“健康中国行动示范V创新产业榜”、“中国创新成长企业100强”、“未来医疗100强”、“中国科创企业百强”等多项荣誉。
作为专精特新“小巨人”企业、博士后科研工作站、知识产权示范单位、北京市级企业科技研究开发机构，求臻医学始终持续秉承“高标准、严要求”的宗旨，依法检验检测，一次性顺利通过美国病理学家协会（CAP）认证、美国实验室认可协会（A2LA）认证，相继满分通过150余项NCCL/EMQN/CAP等国内外权威机构组织的各项室间质评，医学实验室质量管理水平达到国际最高标准认可。
目前，公司已在北京、杭州等全国多地开设多家标准化肿瘤NGS医学检验实验室、研发中心和生产运营基地，总办公面积超过13000平米。通过积极联络国内外知名医院、学校、机构，公司已陆续与国内500余家顶尖医院和数十家新药研发企业开展合作，通过连接医院药企和患者，致力于提高患者生命质量，延长患者生命长度。
未来，作为《中国肿瘤基因图谱计划》参与单位，公司将结合自身技术优势，联合国内70余家三甲医院，绘制中国肿瘤基因图谱，推进大Panel多基因检测在肿瘤治疗的标准化临床实践；同时，积极参与全国规模最大的TMB标准化项目及多个临床研究项目，推动中国肿瘤基因检测领域相关行业标准及规范的制定，肩负起“引领肿瘤精准医疗产业，提升国人生命健康水平”之伟任，致力于成为全球领先的肿瘤精准医学全流程产品及服务提供商！"""

# create the pipeline with transformations
pipeline = IngestionPipeline(
    transformations=[
        SentenceSplitter(),
    ]
)

# build the index
documents = [Document(text=DOCUMENT)]
nodes = pipeline.run(documents=documents, show_progress=True)

# models
llm = OpenAILike(
    is_chat_model=True,
    model=os.environ['MODEL_NAME_LLM']
)
embed_model = OpenAIEmbedding(
    model=os.environ['MODEL_NAME_EMBED']
)

# build RAG
index = VectorStoreIndex(nodes=nodes, embed_model=embed_model)
query_engine = index.as_query_engine(llm=llm)

if __name__ == "__main__":
    from llama_index.networks.contributor import ContributorService
    import uvicorn

    service = ContributorService.from_config_file(
        file_env, query_engine
    )
    app = service.app

    # can add own endpoints or security to app
    # @app.get("...")
    # async def custom_endpoint_logic():
    #   ...

    uvicorn.run(app, host="0.0.0.0", port=int(os.environ['CONTRIBUTOR_PORT']), log_level="debug")
```

contributor2.py

```python
import os
from llama_index.core import VectorStoreIndex, Document
from llama_index.embeddings.openai import OpenAIEmbedding
from llama_index.llms.openai_like import OpenAILike
from llama_index.core.node_parser import SentenceSplitter
from llama_index.core.ingestion import IngestionPipeline


# Load environment
from dotenv import load_dotenv, find_dotenv
file_env = '.env.contributor2.service'
load_dotenv(find_dotenv(filename=file_env))


DOCUMENT = """
What I Worked On

February 2021

Before college the two main things I worked on, outside of school, were writing and programming. I didn't write essays. I wrote what beginning writers were supposed to write then, and probably still are: short stories. My stories were awful. They had hardly any plot, just characters with strong feelings, which I imagined made them deep.

The first programs I tried writing were on the IBM 1401 that our school district used for what was then called "data processing." This was in 9th grade, so I was 13 or 14. The school district's 1401 happened to be in the basement of our junior high school, and my friend Rich Draves and I got permission to use it. It was like a mini Bond villain's lair down there, with all these alien-looking machines — CPU, disk drives, printer, card reader — sitting up on a raised floor under bright fluorescent lights.

The language we used was an early version of Fortran. You had to type programs on punch cards, then stack them in the card reader and press a button to load the program into memory and run it. The result would ordinarily be to print something on the spectacularly loud printer.

I was puzzled by the 1401. I couldn't figure out what to do with it. And in retrospect there's not much I could have done with it. The only form of input to programs was data stored on punched cards, and I didn't have any data stored on punched cards. The only other option was to do things that didn't rely on any input, like calculate approximations of pi, but I didn't know enough math to do anything interesting of that type. So I'm not surprised I can't remember any programs I wrote, because they can't have done much. My clearest memory is of the moment I learned it was possible for programs not to terminate, when one of mine didn't. On a machine without time-sharing, this was a social as well as a technical error, as the data center manager's expression made clear.

With microcomputers, everything changed. Now you could have a computer sitting right in front of you, on a desk, that could respond to your keystrokes as it was running instead of just churning through a stack of punch cards and then stopping. [1]

The first of my friends to get a microcomputer built it himself. It was sold as a kit by Heathkit. I remember vividly how impressed and envious I felt watching him sitting in front of it, typing programs right into the computer.

Computers were expensive in those days and it took me years of nagging before I convinced my father to buy one, a TRS-80, in about 1980. The gold standard then was the Apple II, but a TRS-80 was good enough. This was when I really started programming. I wrote simple games, a program to predict how high my model rockets would fly, and a word processor that my father used to write at least one book. There was only room in memory for about 2 pages of text, so he'd write 2 pages at a time and then print them out, but it was a lot better than a typewriter.

Though I liked programming, I didn't plan to study it in college. In college I was going to study philosophy, which sounded much more powerful. It seemed, to my naive high school self, to be the study of the ultimate truths, compared to which the things studied in other fields would be mere domain knowledge. What I discovered when I got to college was that the other fields took up so much of the space of ideas that there wasn't much left for these supposed ultimate truths. All that seemed left for philosophy were edge cases that people in other fields felt could safely be ignored.

I couldn't have put this into words when I was 18. All I knew at the time was that I kept taking philosophy courses and they kept being boring. So I decided to switch to AI.

AI was in the air in the mid 1980s, but there were two things especially that made me want to work on it: a novel by Heinlein called The Moon is a Harsh Mistress, which featured an intelligent computer called Mike, and a PBS documentary that showed Terry Winograd using SHRDLU. I haven't tried rereading The Moon is a Harsh Mistress, so I don't know how well it has aged, but when I read it I was drawn entirely into its world. It seemed only a matter of time before we'd have Mike, and when I saw Winograd using SHRDLU, it seemed like that time would be a few years at most. All you had to do was teach SHRDLU more words.

There weren't any classes in AI at Cornell then, not even graduate classes, so I started trying to teach myself. Which meant learning Lisp, since in those days Lisp was regarded as the language of AI. The commonly used programming languages then were pretty primitive, and programmers' ideas correspondingly so. The default language at Cornell was a Pascal-like language called PL/I, and the situation was similar elsewhere. Learning Lisp expanded my concept of a program so fast that it was years before I started to have a sense of where the new limits were. This was more like it; this was what I had expected college to do. It wasn't happening in a class, like it was supposed to, but that was ok. For the next couple years I was on a roll. I knew what I was going to do.

For my undergraduate thesis, I reverse-engineered SHRDLU. My God did I love working on that program. It was a pleasing bit of code, but what made it even more exciting was my belief — hard to imagine now, but not unique in 1985 — that it was already climbing the lower slopes of intelligence.

I had gotten into a program at Cornell that didn't make you choose a major. You could take whatever classes you liked, and choose whatever you liked to put on your degree. I of course chose "Artificial Intelligence." When I got the actual physical diploma, I was dismayed to find that the quotes had been included, which made them read as scare-quotes. At the time this bothered me, but now it seems amusingly accurate, for reasons I was about to discover.

I applied to 3 grad schools: MIT and Yale, which were renowned for AI at the time, and Harvard, which I'd visited because Rich Draves went there, and was also home to Bill Woods, who'd invented the type of parser I used in my SHRDLU clone. Only Harvard accepted me, so that was where I went.

I don't remember the moment it happened, or if there even was a specific moment, but during the first year of grad school I realized that AI, as practiced at the time, was a hoax. By which I mean the sort of AI in which a program that's told "the dog is sitting on the chair" translates this into some formal representation and adds it to the list of things it knows.

What these programs really showed was that there's a subset of natural language that's a formal language. But a very proper subset. It was clear that there was an unbridgeable gap between what they could do and actually understanding natural language. It was not, in fact, simply a matter of teaching SHRDLU more words. That whole way of doing AI, with explicit data structures representing concepts, was not going to work. Its brokenness did, as so often happens, generate a lot of opportunities to write papers about various band-aids that could be applied to it, but it was never going to get us Mike.

So I looked around to see what I could salvage from the wreckage of my plans, and there was Lisp. I knew from experience that Lisp was interesting for its own sake and not just for its association with AI, even though that was the main reason people cared about it at the time. So I decided to focus on Lisp. In fact, I decided to write a book about Lisp hacking. It's scary to think how little I knew about Lisp hacking when I started writing that book. But there's nothing like writing a book about something to help you learn it. The book, On Lisp, wasn't published till 1993, but I wrote much of it in grad school.

Computer Science is an uneasy alliance between two halves, theory and systems. The theory people prove things, and the systems people build things. I wanted to build things. I had plenty of respect for theory — indeed, a sneaking suspicion that it was the more admirable of the two halves — but building things seemed so much more exciting.

The problem with systems work, though, was that it didn't last. Any program you wrote today, no matter how good, would be obsolete in a couple decades at best. People might mention your software in footnotes, but no one would actually use it. And indeed, it would seem very feeble work. Only people with a sense of the history of the field would even realize that, in its time, it had been good.

There were some surplus Xerox Dandelions floating around the computer lab at one point. Anyone who wanted one to play around with could have one. I was briefly tempted, but they were so slow by present standards; what was the point? No one else wanted one either, so off they went. That was what happened to systems work.

I wanted not just to build things, but to build things that would last."""

# create the pipeline with transformations
pipeline = IngestionPipeline(
    transformations=[
        SentenceSplitter(),
    ]
)

# build the index
documents = [Document(text=DOCUMENT)]
nodes = pipeline.run(documents=documents, show_progress=True)

# models
llm = OpenAILike(
    is_chat_model=True,
    model=os.environ['MODEL_NAME_LLM']
)
embed_model = OpenAIEmbedding(
    model=os.environ['MODEL_NAME_EMBED']
)

# build RAG
index = VectorStoreIndex(nodes=nodes, embed_model=embed_model)
query_engine = index.as_query_engine(llm=llm)

if __name__ == "__main__":
    from llama_index.networks.contributor import ContributorService
    import uvicorn

    service = ContributorService.from_config_file(
        file_env, query_engine
    )
    app = service.app

    # can add own endpoints or security to app
    # @app.get("...")
    # async def custom_endpoint_logic():
    #   ...

    uvicorn.run(app, host="0.0.0.0", port=int(os.environ['CONTRIBUTOR_PORT']), log_level="debug")
```

#### 数据消费者代码

consumer.py

```python
"""Network Query Engine.

Make sure the app in `contributor.py` is running before trying to run this
script. Run `python contributor.py`.
"""

import os
import asyncio
from llama_index.llms.openai_like import OpenAILike
from llama_index.networks.contributor import ContributorClient
from llama_index.networks.query_engine import NetworkQueryEngine

# Load environments
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv(filename='.env.consumer'))
contributor1client = ContributorClient.from_config_file(env_file='.env.contributor1.client')
contributor2client = ContributorClient.from_config_file(env_file='.env.contributor2.client')


# build NetworkRAG
llm = OpenAILike(
    is_chat_model=True,
    model=os.environ['MODEL_NAME_LLM']
)
network_query_engine = NetworkQueryEngine.from_args(contributors=[contributor1client, contributor2client], llm=llm)


if __name__ == "__main__":
    query_list = [
        "简单介绍一下求臻医学吧？",
        "求臻医学发表了哪些SCI文章？",
        "求臻医学跟多少家机构开展了合作？",
        "作者为什么选择学习AI？",
        "作者为什么转向关注Lisp？"
    ]
    for query in query_list:
        print(f"Query: {query}")
        sync_res = network_query_engine.query(query)
        print(f"Response: {sync_res}\n")

```

### 执行代码

```bash
# 启动两个数据提供者服务
python contributor1.py
python contributor2.py

# 消费
python consumer.py
```

### 消费效果展示

<img src="./imgs/20240301111107.png" width="80%">

## 参考文献

- [Querying a network of knowledge with llama-index-networks](https://medium.com/llamaindex-blog/querying-a-network-of-knowledge-with-llama-index-networks-d784b4c3006f)

- [GitHub - llama_index](https://github.com/run-llama/llama_index/tree/main/llama-index-networks/examples/simple)