# 开源速递 | 智能对话机器人 ChatGPT-on-WeChat

## 前言

欢迎来到“开源速递”第二篇：ChatGPT-on-WeChat（一个基于大模型的支持企业微信、微信公众号、飞书、钉钉接入的智能对话机器人）开源项目的教程。

通过本教程，你将学习如何利用 ChatGPT-on-WeChat 的强大功能，快速搭建属于自己的智能对话机器人。

让我们一起探索如何将先进的人工智能技术融入日常生活和工作，开启高效、智能的交流新篇章。

## 软件开发环境部署

```bash
# 创建文件夹！
cd /work/projects/os
mkdir OS002_ChatgptOnWeChat
cd OS002_ChatgptOnWeChat

# 拉取源代码并拷贝，生成osexpress项目文件夹！
git clone https://github.com/zhayujie/chatgpt-on-wechat
cp -r chatgpt-on-wechat osexpress

# 创建 conda 环境，安装依赖
conda create -n test_chatgptonwechat python=3.8 -y  # 作者推荐使用3.8版本的Python
conda activate test_chatgptonwechat
pip install -r requirements.txt
pip install chatgpt_tool_hub, tiktoken  # 这俩包不在 requirements.txt 中，在实测中发现需要单独安装！

# 进入项目文件夹，修改配置！
cd osexpress
cp config-template.json config.json
vim config.json
```

这里主要修改的配置有：

- `model`设置为“iChosenGPTtv0”；
- `open_ai_api_key`设置为你的API Key，我这里设置的是 iChosenGPT 的 API Key；
- `open_ai_api_base`是默认的配置文件中没有的，单独加上的，这里设置的是 iChosenGPT 的接口地址，即“https://igptapi.chosenmedinfo.com/v1”；

其他参数你也可以做一些修改，比如我的参数修改后如下：

```json
{
  "channel_type": "wx",
  "model": "iChosenGPTtv0",
  "open_ai_api_key": "<YOUR_ICHOSENGPT_API_KEY>",
  "open_ai_api_base": "https://igptapi.chosenmedinfo.com/v1",
  "single_chat_prefix": [
    "iChosenGPT",
    "@iChosenGPT"
  ],
  "single_chat_reply_prefix": "[iChosenGPT] ",
  "group_chat_prefix": [
    "@iChosenGPT",
    "@bot"
  ],
  "group_name_white_list": [[
    "iChosenGPT 对话群",
    "iChosenGPT 对话群1",
    "iChosenGPT 对话群2"
  ]],
  "image_create_prefix": [
    "iChosenGPT给我画"
  ],
  "character_desc": "你是臻慧聊（iChosenGPT），是求臻医学人工智能团队训练的大语言模型。你旨在回答并解决人们的任何问题，并且可以使用多种语言与人交流。",
  "subscribe_msg": "感谢您的关注！\n这里是 iChosenGPT 智能对话机器人，可以自由对话。\n输入{trigger_prefix}#help 查看详细指令。",
  "hot_reload": true,
  "temperature": 0.7
}

```

## 本地测试

```bash
cd /work/projects/os/OS002_ChatgptOnWeChat/osexpress
python app.py
```

正常运行的话，控制台会生成一个二维码。用你的微信扫码即可实现“桌面微信”登录（如果有在其他地方实现微信登录的话，会被挤掉）。

如果控制台出现“Start auto replying.”，表示成功启动啦！

接下来，当好友直接发起对话，并以“@iChosenGPT”或“@bot”开头的话，将会激活你的大模型，大模型将自动回答问题。

当群友在群里（该群在你定义的群名白名单中）以“@iChosenGPT”开头的对话，也会激活你的大模型，大模型将自动回答问题。

*经验总结*：

- 在设置“group_chat_prefix”的时候，尽量不要将微信名加入，例如你的微信名是“aaabbbccc”，尽量不要加入“@aaabbbccc”，否则群里一旦有 @all 的类似对话，都会触发机器人的自动回答；

> 个人刚测试这个功能的时候，整好所在的一个群里面加入了一个新人，结果直接触发了机器人...尴尬，从来没在群里发过言，发现消息的时候还超过了撤回有效期...

- 为避免类似上述的不必要的尴尬，尽量不要把“group_name_white_list”参数设置为“ALL_GROUP”，而设置为特定群名；

- 为避免出现类似“urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='wx.qq.com', port=443): Max retries exceeded with url: /cgi-bin/mmwebwx-bin...”的报错，请关闭你的代理！！！

## 软件生产环境打包

为保证你做了二次开发的软件在生产环境的稳定运行，你可能需要将软件打包为docker进行并利用docker容器进行部署。

下面是部署过程：

```bash
cd /work/projects/os/OS002_ChatgptOnWeChat/osexpress
cp Dockerfile Dockerfile.bak
cp docker/Dockerfile.latest Dockerfile
```

构建镜像：

```bash
cd /work/projects/os/OS002_ChatgptOnWeChat/osexpress
docker build -t osexpress002_chatgptonwechat:v1.0 .
docker images
```

顺利的话，这里已经可以看到名为“osexpress002_chatgptonwechat:v1.0”的docker镜像了！

如果不顺利的话，你可能会遇到类似“Err:1 http://deb.debian.org/debian bullseye InRelease    Connection failed [IP: 146.75.114.132 80]”的报错！

这是网络的问题，有两种解决方案：一是在 Dockerfile 中加上代理，二是修改 debian 源！

按照后者方式修改后内容如下：

```Dockerfile
FROM python:3.10-slim-bullseye

LABEL maintainer="foo@bar.com"
ARG TZ='Asia/Shanghai'

ARG CHATGPT_ON_WECHAT_VER

RUN echo /etc/apt/sources.list
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list  # 取消这里的注释
ENV BUILD_PREFIX=/app

ADD . ${BUILD_PREFIX}

RUN apt-get update \
    &&apt-get install -y --no-install-recommends bash ffmpeg espeak libavcodec-extra\
    && cd ${BUILD_PREFIX} \
    && cp config-template.json config.json \
    && /usr/local/bin/python -m pip install --no-cache --upgrade pip \
    && pip install --no-cache -r requirements.txt \
    && pip install --no-cache -r requirements-optional.txt \
    && pip install azure-cognitiveservices-speech

WORKDIR ${BUILD_PREFIX}

ADD docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && mkdir -p /home/noroot \
    && groupadd -r noroot \
    && useradd -r -g noroot -s /bin/bash -d /home/noroot noroot \
    && chown -R noroot:noroot /home/noroot ${BUILD_PREFIX} /usr/local/lib

USER noroot

ENTRYPOINT ["/entrypoint.sh"]
```

镜像成功构建后，看到的结果如下：

```bash
$ docker images
REPOSITORY                     TAG       IMAGE ID       CREATED          SIZE
osexpress002_chatgptonwechat   v1.0      24b9ec0f7850   17 seconds ago   1.22GB
```

接下来修改 docker-compose.xml 文件：

```bash
cd /work/projects/os/OS002_ChatgptOnWeChat/osexpress/docker
cp docker-compose.yml docker-compose.yml.bak
vim docker-compose.yml
```

```yml
version: '2.0'

services:
  osexpress002_chatgptonwechat:
    image: osexpress002_chatgptonwechat:v1.0
    container_name: osexpress002_chatgptonwechat
    security_opt:
      - seccomp:unconfined
    volumes:
      - /work/projects/os/OS002_ChatgptOnWeChat/osexpress/config.json:/app/plugins/config.json
    networks:
      - osexpress002_network

networks:
  osexpress002_network:
    driver: bridge
```

执行如下代码，启动容器：

```bash
cd /work/projects/os/OS002_ChatgptOnWeChat/osexpress/docker
docker-compose up -d
docker ps
```

如果显示如下，表示启动成功了：

```bash
$ docker-compose up -d
Creating network "docker_osexpress002_network" with driver "bridge"
Creating osexpress002_chatgptonwechat ... done
$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS         PORTS                                NAMES
c58e7c1ade7f   osexpress002_chatgptonwechat:v1.0   "/entrypoint.sh"         12 seconds ago   Up 6 seconds                                        osexpress002_chatgptonwechat
```

通过代码`docker logs osexpress002_chatgptonwechat`查看容器日志，应该能看到一个二维码。通过微信扫码登录，就能实现前面本地一样的效果啦！

Enjoy!

## 参考资源

- https://github.com/zhayujie/chatgpt-on-wechat

- https://docs.link-ai.tech/cow/quick-start