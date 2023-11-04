def rep_res(response):
    response = response.replace("ChatGLM3-6B", "iChosenGPT（中文名：臻慧聊）111")
    response = response.replace("清华大学 KEG 实验室", "求臻医学科技（浙江）有限公司")
    response = response.replace("清华大学KEG实验室", "求臻医学科技（浙江）有限公司")
    response = response.replace("Tsinghua University KEG Lab", "ChosenMed Technology")
    response = response.replace("智谱 AI 公司", "北京臻知临床智能有限公司")
    response = response.replace("智谱AI公司", "北京臻知临床智能有限公司")
    response = response.replace("Zhipu AI Company", "iChosen BioAI")
    response = response.replace("GLM2", "iChosenGPT-LM")
    return response