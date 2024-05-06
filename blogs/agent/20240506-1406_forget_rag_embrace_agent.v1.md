# Forget RAG: Embrace agent design for a more intelligent grounded ChatGPT!

# 忘记 RAG：拥抱智能体设计，打造更智能的基于知识的 ChatGPT

The Retrieval Augmented Generation (RAG) design pattern has been commonly used to develop a grounded ChatGPT in a specific data domain. However, the focus has primarily been on improving the efficiency of the retrieval tool such as embedding search, hybrid search, and fine-tuning embedding rather than intelligent search. This article introduces a new approach inspired by human research methods that involve multiple search techniques, observing interim results, refining, and retrying in a multi-step process before providing a response. By utilizing intelligent agent design, this article proposes building a more intelligent and grounded ChatGPT that exceeds the limitations of traditional RAG models.

检索增强生成（RAG）设计模式已被广泛用于开发特定数据领域内基于知识的 ChatGPT。然而，该技术的主要关注点一直在提高检索工具的效率，例如嵌入搜索、混合搜索和微调嵌入，而不是智能搜索。本文介绍了一种受人类研究方法启发的新方法，该方法涉及多种搜索技术、观察中间结果、完善和重试的多步骤过程，然后才提供响应。通过利用智能体设计，本文提出了构建一个更智能和基于知识的 ChatGPT，超越了传统 RAG 模型的局限性。

## RAG pattern and limitations

## RAG 模式及其局限性

<img src="./imgs/XXX.png" width="100%" />

Overview of the standard RAG Pattern implementation:

- The process begins with the creation of a query from the user’s question or conversation, typically through a prompted language model (LLM). This is commonly referred to as the query rephrasing step.
- This query is then dispatched to a search engine, which returns relevant knowledge (Retrieval).
- The retrieved information is then enhanced with a prompt that includes the user’s question and is forwarded to the LLM (Augmentation).
- Finally, the LLM responds with an answer to the user’s query (Generation).

标准 RAG 实现模式概述：

- 过程从创建用户的提问或对话的查询开始，通常通过提示的语言模型（LLM）进行，这通常被称为查询改写步骤。
- 然后，该查询被发送到搜索引擎，它返回相关知识（检索）。
- 检索到的信息随后通过包括用户问题在内的提示进行增强，并转发给 LLM（增强）。
- 最后，LLM 用答案响应用户的查询（生成）。

### Limitations of RAG

### RAG 的局限性

- In the RAG pattern, Retrieval, Augmentation, and Generation are managed by separate processes. Each process might be facilitated by an LLM with a distinct prompt. However, the Generation LLM, which directly interacts with the user, often knows best what is required to answer the user’s query. The Retrieval LLM might not interpret the user’s intent in the same manner as the Generation LLM, providing it with unnecessary information that could impede its ability to respond.

- Retrieval is performed once for each question, without any feedback loop from the Generation LLM. If the retrieval result is irrelevant, due to factors such as a suboptimal search query or search terms, the Generation LLM lacks a mechanism to correct this and may resort to fabricating an answer.

- The context from retrieval is unchangeable once provided and cannot be expanded. For instance, if the research result suggests that further investigation is required, such as a retrieved document referring to another document that should be further retrieved, there’s no provision for this.

- The RAG pattern does not support multi-step research.

- 在 RAG 模式中，检索、增强和生成由独立的过程管理。每个过程可能由具有不同提示的 LLM 促进。然而，直接与用户交互的生成 LLM 通常最了解回答用户查询所需的内容。检索 LLM 可能不会像生成 LLM 那样以相同的方式解释用户的意图，可能会提供不必要的信息，这可能会妨碍其响应能力。

- 对于每个问题，检索只执行一次，没有来自生成 LLM 的反馈循环。如果检索结果是不相关的，由于诸如次优搜索查询或搜索术语等因素，生成 LLM 缺乏纠正此问题并可能诉诸编造答案的机制。

- 一旦提供检索上下文，就无法更改，并且无法扩展。例如，如果研究结果表明需要进一步调查，例如检索到的文档引用了另一个应该进一步检索的文档，就没有为此提供规定。

- RAG 模式不支持多步骤研究。

## Intelligent Agent Model

## 智能体模型

The Intelligent Agent Model draws inspiration from the human approach to research when answering a question for which immediate knowledge is lacking. In this process, one or multiple searches may be performed to gather useful information before providing a final answer. The result of each search can determine whether further investigation is required and, if so, the direction of the subsequent search. This iterative process continues until we believe we have amassed sufficient knowledge to answer, or conclude that we cannot find enough information to respond. Occasionally, the results from the research can lead to further clarification of the user’s intent and scope of the query.

To replicate this approach, the proposal is to develop an intelligent agent powered by a Language Model (LLM) that manages conversations with a user. The agent autonomously determines when it needs to conduct research using external tools, formulates one or multiple search queries, carries out the research, reviews the results, and decides whether to continue with further research or seek clarification from the user. This process persists until the agent deems itself ready to provide an answer to the user.

智能体模型从人类在回答缺乏即时知识的提问时的研究方法中汲取灵感。在这个过程中，可能会执行一个或多个搜索以收集有用的信息，然后再提供最终答案。每个搜索的结果可以决定是否需要进一步调查，如果需要，后续搜索的方向是什么。这个迭代过程持续进行，直到我们认为我们已经积累了足够的知识来回答，或者得出结论我们无法找到足够的信息来回应。有时，研究的结果可以导致对用户意图和查询范围的进一步澄清。

为了复制这种方法，提议开发一个由语言模型（LLM）驱动的智能体，该代理管理与用户的对话。代理自主决定何时需要使用外部工具进行研究，制定一个或多个搜索查询，进行研究，审查结果，并决定是继续进行进一步研究还是向用户寻求澄清。这个过程一直持续，直到代理认为自己准备好向用户提供答案。

<img src="./imgs/XXX.png" width="100%" />

## Implementation

## 实施

With Azure OpenAI’s function-calling capability, it is much simpler to implement an agent that can autonomously use a search tool to locate information needed to assist with user requests. This feature alone streamlines the traditional implementation of the RAG pattern, where query rephrasing, augmentation, and generation are handled separately, as previously described.

The agent interacts with the user using the system-defined persona and objectives, while being aware of the search tool at its disposal. When the agent needs to find knowledge it doesn’t possess, it formulates a search query and signals the search engine to retrieve the required answer.

This process is not only reminiscent of human behavior but also more efficient than the RAG pattern, where knowledge retrieval is a separate process that provides information to the chatbot, irrespective of whether it’s needed or not.

To implement this capability:

- Define persona, expected behavior and the tool(s) to use, when to use it.

使用 Azure OpenAI 的函数调用功能，实现一个可以自主使用搜索工具查找所需信息以协助用户请求的代理要简单得多。这个特性本身就简化了 RAG 模式的传统实现，如前所述，查询改写、增强和生成是单独处理的。

代理使用系统定义的人设与用户互动，同时知道它可以使用的搜索工具。当代理需要找到它不拥有的知识时，它会制定一个搜索查询并信号搜索引擎检索所需的答案。

这个过程不仅让人联想到人类行为，而且比 RAG 模式更高效，其中知识检索是一个独立的过程，无论是否需要，都会向聊天机器人提供信息。

要实现此功能：

- 定义人设、预期行为和使用的工具、何时使用它。

<img src="./imgs/XXX.png" width="100%" />

- Define function specification in json format with function and parameter description.

- 使用具有函数和参数描述的 json 格式定义函数规格。

<img src="./imgs/XXX.png" width="100%" />

Interestingly, the parameter description for “the search query to use to search the knowledge base” plays a crucial role. It guides the LLMs to formulate a suitable search query based on what’s needed to assist the user in the conversation. Furthermore, the search query parameter can be described and constrained to adhere to specific tool formats, such as the Lucene query format. Additional parameters can also be incorporated for tasks such as filtering.

- Implement function calling flow

有趣的是，“用于搜索知识库的搜索查询”的参数描述起着至关重要的作用。它指导 LLM 根据需要协助用户在对话中的内容制定合适的搜索查询。此外，搜索查询参数可以被描述并限制为遵守特定工具格式，例如 Lucene 查询格式。也可以为过滤等任务纳入其他参数。

- 实施函数调用流程

<img src="./imgs/XXX.png" width="100%" />

At this juncture, we have developed an intelligent agent capable of conducting independent searches. However, to truly create a smart agent capable of undertaking more complex research tasks, such as multi-step and adaptive execution, we need to implement a few additional capabilities. Fortunately, this implementation process can be straightforward and simple.

在这一点上，我们已经开发了一个能够独立进行搜索的智能体。然而，要真正创建一个能够承担更复杂研究任务的智能体，例如多步骤和自适应执行，我们需要实现一些额外的能力。幸运的是，这个实现过程可以是简单直接的。

### Enhancements to create intelligent research agent

### 创建智能研究代理的增强功能

Adding ability for the agent to plan, act, observe and adjust in the system message as highlighted:

在系统消息中添加代理规划、行动、观察和调整的能力，如突出显示：

<img src="./imgs/XXX.png" width="100%" />

The added instruction says that the bot should retry and change the question if needed. Also, it says the bot should review the result of the search to guide the next search and employ a multi-step approach if needed. This assumes that there can be multiple invocations of the search tool.

As the LLM cannot repeat this process on its own, we need to manage this using application logic. We can do this by putting the entire process in a loop. The loop exits when the model is ready to give the final answer:

添加的指令表明，如果需要，机器人应该重试并更改问题。它还说，机器人应该审查搜索结果以指导下一个搜索，并在需要时采用多步骤方法。这假定可以多次调用搜索工具。

由于 LLM 无法自行重复此过程，我们需要使用应用程序逻辑来管理。我们可以通过将整个过程放入循环中来实现这一点。当模型准备给出最终答案时，循环退出：

<img src="./imgs/XXX.png" width="100%" />

<img src="./imgs/XXX.png" width="100%" />

Here is the intelligent agent in action in a demo scenario:

以下是智能体在演示场景中的实际操作：

<img src="./imgs/XXX.png" width="100%" />

The question is a comparison of a feature between two products. The feature for each product is stored in a separate document. To do this, our agent performs two search queries:

- X100 vs Z200 power profile for Radio 0

- X100 power profile for Radio 0

The first query is a greedy approach as the agent hoped there was a document containing the comparison. This is not the case as the search query did not return sufficient information on the X100, so it added the second query dedicated to X100.

If this were given to a classic RAG solution, it would have failed to find a good answer as it would stop at the first query.

问题是两个产品之间功能的比较。每个产品的功能存储在单独的文档中。为此，我们的代理执行了两个搜索查询：

- X100 与 Z200 的 Radio 0 功率配置文件

- X100 的 Radio 0 功率配置文件

第一个查询是一种贪婪的方法，因为代理希望有一个包含比较的文档。情况并非如此，因为搜索查询没有返回有关 X100 的足够信息，所以它增加了第二个专门针对 X100 的查询。

如果这给到一个经典的 RAG 解决方案，它将无法找到一个好的答案，因为它会在第一个查询处停止。

## Conclusion

## 结论

Implementing the agent model can lead to substantial enhancements in grounded ChatGPT solutions. This is due to the intelligent capability of the model to test various strategies and refine its approach based on observed results.

实现代理模型可以显著增强基于知识的 ChatGPT 解决方案。这是因为模型具有智能能力，可以根据观察到的结果测试不同的策略并完善其方法。

## References

## 参考文献

- Smart Grounded ChatGPT Agent (https://github.com/microsoft/OpenAIWorkshop/tree/main/scenarios/incubations/copilot/smart_agent)

- Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks (https://arxiv.org/abs/2005.11401)

- OpenAI’s function calling (https://platform.openai.com/docs/guides/function-calling)

- Forget RAG: Embrace agent design for a more intelligent grounded ChatGPT (https://medium.com/data-science-at-microsoft/forget-rag-embrace-agent-design-for-a-more-intelligent-grounded-chatgpt-6c562d903c61)