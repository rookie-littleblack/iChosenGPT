#############################################################################################
# iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.
# 
# @author     Quan Xu
# @date       2023-11-03
# @copyright  ChosenMed Technology
#############################################################################################
#!/bin/bash


##########################################
### Global Variables!
export ICHOSEN_IPYKERNEL=ichosengpt_ipker
export ICHOSEN_ROOT_PATH=/work/20231103-0935_ChosenGPT
export ICHOSEN_LOGS_PATH=${ICHOSEN_ROOT_PATH}/logs
export ICHOSEN_LOGS_PREF=${ICHOSEN_LOGS_PATH}/$(date "+%Y%m%d-%H%M%S")_running


# ##########################################
# ### Dependence Installation (optional)!
# git clone https://github.com/rookie-littleblack/iChosenGPT.git
# cd iChosenGPT
# conda create -n ichosengpt python=3.10
# conda activate ichosengpt
# pip install -r requirements.txt

# # To use Code Interpreter, you should install Jupyter kernel:
# ipython kernel install --name ${ICHOSEN_IPYKERNEL} --user


##########################################
### Preprocessing!
cd $ICHOSEN_ROOT_PATH


##########################################
### Processing!
if [ "$1" == "board" ]; then
    echo "===> Initiate Board - gradio version!"
    ##########################################
    ### Initiate Board - gradio version!
    export ICHOSEN_BOARD_CUDA_VISIB="4,5,6,7"
    export ICHOSEN_BOARD_WPORT=6721
    export ICHOSEN_BOARD_SCRIPT=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_board.py

    CUDA_VISIBLE_DEVICES=${ICHOSEN_BOARD_CUDA_VISIB} python ${ICHOSEN_BOARD_SCRIPT}
elif [ "$1" == "gradio" ]; then
    echo "===> Initiate Web - gradio version!"
    ##########################################
    ### Initiate Web - gradio version!
    export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
    export ICHOSEN_MODEL_TEMP=chatglm3
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1104_Llama-2-70b-chat-hf
    # export ICHOSEN_MODEL_TEMP=llama2
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1533_Llama2-Chinese-13b-Chat
    # export ICHOSEN_MODEL_TEMP=llama2

    export ICHOSEN_GRA_MODEL_PATH=${ICHOSEN_MODEL_CHAT}
    export ICHOSEN_GRA_MODEL_TEMP=${ICHOSEN_MODEL_TEMP}
    #export ICHOSEN_GRA_MODEL_CKPT=/work/20231103-0935_ChosenGPT/out/XXX
    export ICHOSEN_GRA_CUDA_VISIB="4,5,6,7"
    export ICHOSEN_GRA_MODEL_PORT=6722

    export ICHOSEN_GRA_MODEL=${ICHOSEN_GRA_MODEL_PATH}
    export ICHOSEN_GRA_WPORT=${ICHOSEN_GRA_MODEL_PORT}
    export ICHOSEN_GRA_SCRIPT=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_web_gradio.py

    CUDA_VISIBLE_DEVICES=${ICHOSEN_GRA_CUDA_VISIB} python ${ICHOSEN_GRA_SCRIPT} \
    --model_name_or_path ${ICHOSEN_GRA_MODEL_PATH} \
    --template ${ICHOSEN_GRA_MODEL_TEMP}
    #--finetuning_type lora \
    #--checkpoint_dir ${ICHOSEN_GRA_MODEL_CKPT}
elif [ "$1" == "streamlit" ]; then
    echo "===> Initiate Web - streamlit version (for ChatGLM3)!"
    ##########################################
    ### Initiate Web - streamlit version!
    # For ChatGLM3!
    export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
    export ICHOSEN_MODEL_TEMP=chatglm3

    export ICHOSEN_WEB_MODEL_PATH=${ICHOSEN_MODEL_CHAT}
    #export ICHOSEN_WEB_CUDA_VISIB="4,5,6,7"
    export ICHOSEN_WEB_CUDA_VISIB="1,2,3"
    export ICHOSEN_WEB_MODEL_PORT=6723

    export ICHOSEN_WEB_MODEL=${ICHOSEN_WEB_MODEL_PATH}
    export ICHOSEN_WEB_SCRIPT=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_web_streamlit.py

    CUDA_VISIBLE_DEVICES=${ICHOSEN_WEB_CUDA_VISIB} streamlit run ${ICHOSEN_WEB_SCRIPT} --server.port ${ICHOSEN_WEB_MODEL_PORT}
elif [ "$1" == "tools" ]; then
    echo "===> Initiate Tools - streamlit version (for ChatGLM3)!"
    ##########################################
    ### Initiate Tools - streamlit version!
    # For ChatGLM3!
    export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
    export ICHOSEN_MODEL_TEMP=chatglm3

    export ICHOSEN_TOOLS_MODEL_PATH=${ICHOSEN_MODEL_CHAT}
    export ICHOSEN_TOOLS_CUDA_VISIB="4,5,6,7"
    export ICHOSEN_TOOLS_MODEL_PORT=6724

    export ICHOSEN_TOOLS_MODEL=${ICHOSEN_TOOLS_MODEL_PATH}
    export ICHOSEN_TOOLS_SCRIPT=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_web_tools.py

    CUDA_VISIBLE_DEVICES=${ICHOSEN_TOOLS_CUDA_VISIB} streamlit run ${ICHOSEN_TOOLS_SCRIPT} --server.port ${ICHOSEN_TOOLS_MODEL_PORT}
elif [ "$1" == "pt_single" ]; then
    echo "===> Pre-Training LLM - Single GPU!"
    ##########################################
    ### Pre-Training LLM - Single GPU!
    export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
    export ICHOSEN_MODEL_TEMP=chatglm3
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1104_Llama-2-70b-chat-hf
    # export ICHOSEN_MODEL_TEMP=llama2
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1533_Llama2-Chinese-13b-Chat
    # export ICHOSEN_MODEL_TEMP=llama2

    export ICHOSEN_PT_MODEL_PATH=${ICHOSEN_MODEL_CHAT}
    export ICHOSEN_PT_MODEL_TEMP=${ICHOSEN_MODEL_TEMP}
    export ICHOSEN_PT_CUDA_VISIB=7
    export ICHOSEN_PT_DATAS_NAME=ichosengpt_corpus_text_dailymed_all
    export ICHOSEN_PT_MODEL_PORT=6725
    export ICHOSEN_PT_NUM_EPOCHS=10
    export ICHOSEN_PT_BATCH_SIZE=32

    # Execute running!
    log_file=${ICHOSEN_LOGS_PREF}_$1.log
    nohup sh src/training/ichosengpt_pt.sh > ${log_file} &
    tail_cmd=`tail -f ${log_file}`
    echo "You can now using the following cmd to show running logs:"
    echo "${tail_cmd}"
    echo "You can also using the following cmd (or other similar cmd) to show running pid:"
    echo "ps -aux|grep ichosengpt"
elif [ "$1" == "pt_multi" ]; then
    echo "===> Pre-Training LLM - Multi-GPUs!"
    ##########################################
    ### Pre-Training LLM - Multi-GPUs!
    export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
    export ICHOSEN_MODEL_TEMP=chatglm3
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1104_Llama-2-70b-chat-hf
    # export ICHOSEN_MODEL_TEMP=llama2
    # #-----------------------------------
    # export ICHOSEN_MODEL_CHAT=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231106-1533_Llama2-Chinese-13b-Chat
    # export ICHOSEN_MODEL_TEMP=llama2

    export ICHOSEN_PT_MODEL_PATH=${ICHOSEN_MODEL_CHAT}
    export ICHOSEN_PT_MODEL_TEMP=${ICHOSEN_MODEL_TEMP}
    export ICHOSEN_PT_CUDA_VISIB="4,5,6,7"
    export ICHOSEN_PT_DATAS_NAME=ichosengpt_corpus_text_dailymed_all
    #export ICHOSEN_PT_DATAS_NAME=ichosengpt_corpus_text_dengling_newsreport_20231103
    export ICHOSEN_PT_MODEL_PORT=6725
    export ICHOSEN_PT_NUM_EPOCHS=10
    export ICHOSEN_PT_BATCH_SIZE=16

    export ICHOSEN_PT_CONF_ACCEL=${ICHOSEN_ROOT_PATH}/conf/accelerate_train.yaml

    # Execute running!
    #accelerate config --config_file ${ICHOSEN_PT_CONF_ACCEL}  # to generate accelerate config file!
    log_file=${ICHOSEN_LOGS_PREF}_$1.log
    echo "log_file: ${log_file}"
    nohup sh src/training/ichosengpt_pt.sh > ${log_file} 2>&1 &
    tail_cmd=`tail -f ${log_file}`
    echo "You can now using the following cmd to show running logs:"
    echo "${tail_cmd}"
    echo "You can also using the following cmd (or other similar cmd) to show running pid:"
    echo "ps -aux|grep ichosengpt"
else
    echo "===> WARNING! Please specify the task!"
fi
