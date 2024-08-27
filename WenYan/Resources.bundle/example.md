---
author: 路边的阿不
title: 在本地跑一个大语言模型(2) - 给模型提供外部知识库
slug: run-a-large-language-model-locally-2
description: Make your local large language models (LLMs) smarter! This guide shows how to use LangChain and RAG to let them retrieve data from external knowledge bases, improving answer accuracy.
date: 2024-03-04 11:18:00
draft: false
ShowToc: true
TocOpen: true
tags:
  - Ollama
  - RAG
categories:
  - AI
---
在[上一篇文章](https://babyno.top/posts/2024/02/running-a-large-language-model-locally/)里，我们展示了如何通过Ollama这款工具，在本地运行大型语言模型。本篇文章将着重介绍下如何让模型从外部知识库中检索定制数据，来提升大型语言模型的准确性，让它看起来更“智能”。

本篇文章将涉及到`LangChain`和`RAG`两个概念，在本文中不做详细解释。

## 准备模型

访问`Ollama`的模型页面，搜索`qwen`，我们这次将使用对中文语义了解的更好的“[通义千问](https://ollama.com/library/qwen:7b)”模型进行实验。

## 运行模型

```shell
ollama run qwen:7b
```

## 第一轮测试

编写代码如下：

```python
from langchain_community.chat_models import ChatOllama
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate


model_local = ChatOllama(model="qwen:7b")
template = "{topic}"
prompt = ChatPromptTemplate.from_template(template)
chain = model_local | StrOutputParser()
print(chain.invoke("身长七尺，细眼长髯的是谁？"))
```

模型返回的答案：

> 这句话描述的是中国古代文学作品《三国演义》中的角色刘备。刘备被描绘为一位身高七尺（约1.78米），眼睛细小但有神，长着长须的蜀汉开国皇帝。

可以看到，我问了模型一个问题："身长七尺，细眼长髯的是谁？"这是一个开放型的问题，没有指定上下文，答案并不确定。模型给到的答案是“刘备”，作为中国人训练出来的模型，四大名著应该是没有少看的。因此凭借问题的描述，模型能联想到三国里的人物，并不让人感觉意外。但答案还不对。

## 引入RAG

检索增强生成（Retrieval Augmented Generation），简称 RAG。RAG的工作方式是在共享的语义空间中，从外部知识库中检索事实，将这些事实用作决策过程的一部分，以此来提升大型语言模型的准确性。因此第二轮测试我们将让模型在回答问题之前，阅读一篇事先准备好的《三国演义》章节，让其在这篇章节里寻找我们需要的答案。

RAG前的工作流程如下：向模型提问->模型从已训练数据中查询数据->组织语言->生成答案。

RAG后的工作流程如下：读取文档->分词->嵌入->将嵌入数据存入向量数据库->向模型提问->模型从向量数据库中查询数据->组织语言->生成答案。

## 嵌入

在人工智能中，嵌入（Embedding）是将数据向量化的一个过程，可以理解为将人类语言转换为大语言模型所需要的计算机语言的一个过程。在我们第二轮测试开始前，首先下载一个嵌入模型：[nomic-embed-text](https://ollama.com/library/nomic-embed-text) 。它可以使我们的`Ollama`具备将文档向量化的能力。

```
ollama run nomic-embed-text
```

## 使用LangChain

接下来需要一个`Document loaders`，[文档](https://python.langchain.com/docs/modules/data_connection/document_loaders/)。

```python
from langchain_community.document_loaders import TextLoader  
  
loader = TextLoader("./index.md")  
loader.load()
```

接下来需要一个分词器`Text Splitter`，[文档](https://python.langchain.com/docs/modules/data_connection/document_transformers/split_by_token)。

```python
from langchain_text_splitters import CharacterTextSplitter

text_splitter = CharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=100, chunk_overlap=0
)
texts = text_splitter.split_text(state_of_the_union)
```

接下来需要一个向量数据库来存储使用`nomic-embed-text`模型项量化的数据。既然是测试，我们就使用内存型的`DocArray InMemorySearch`，[文档](https://python.langchain.com/docs/integrations/vectorstores/docarray_in_memory)。

```python
embeddings = OllamaEmbeddings(model='nomic-embed-text')
vectorstore = DocArrayInMemorySearch.from_documents(doc_splits, embeddings)
```

## 第二轮测试

首先下载[测试文档](http://babyno.top/data/%E4%B8%89%E5%9B%BD%E6%BC%94%E4%B9%89.txt)，我们将会把此文档作为外部数据库供模型检索。注意该文档中提到的：

> 忽见一彪军马，尽打红旗，当头来到，截住去路。为首闪出一将，身长七尺，细眼长髯，官拜骑都尉，沛国谯郡人也，姓曹，名操，字孟德。

编写代码如下：

```python
from langchain_community.document_loaders import TextLoader
from langchain_community import embeddings
from langchain_community.chat_models import ChatOllama
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.vectorstores import DocArrayInMemorySearch
from langchain_community.embeddings import OllamaEmbeddings

model_local = ChatOllama(model="qwen:7b")

# 1. 读取文件并分词
documents = TextLoader("../../data/三国演义.txt").load()
text_splitter = CharacterTextSplitter.from_tiktoken_encoder(chunk_size=7500, chunk_overlap=100)
doc_splits = text_splitter.split_documents(documents)

# 2. 嵌入并存储
embeddings = OllamaEmbeddings(model='nomic-embed-text')
vectorstore = DocArrayInMemorySearch.from_documents(doc_splits, embeddings)
retriever = vectorstore.as_retriever()

# 3. 向模型提问
template = """Answer the question based only on the following context:
{context}
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)
chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | model_local
    | StrOutputParser()
)
print(chain.invoke("身长七尺，细眼长髯的是谁？"))
```

模型返回的答案：

> 身长七尺，细眼长髯的人物是曹操，字孟德，沛国谯郡人。在《三国演义》中，他是主要人物之一。

可见，使用`RAG`后，模型给到了正确答案。

## 总结

本篇文章我们使用`LangChain`和`RAG`对大语言模型进行了一些微调，使之生成答案前可以在我们给到的文档内进行检索，以生成更准确的答案。

`RAG`是检索增强生成（Retrieval Augmented Generation），主要目的是让用户可以给模型制定一些额外的资料。这一点非常有用，我们可以给模型提供各种各样的知识库，让模型扮演各种各样的角色。

`LangChain`是开发大语言模型应用的一个框架，内置了很多有用的方法，比如：文本读取、分词、嵌入等。利用它内置的这些功能，我们可以轻松构建出一个`RAG`的应用。

这次的文章就到这里了，下回我们将继续介绍更多本地`LLM`的实用场景。