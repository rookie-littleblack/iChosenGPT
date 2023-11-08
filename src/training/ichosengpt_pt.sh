#############################################################################################
# iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.
#     --- Pre-Training your own LLM
# 
# @author     Quan Xu
# @date       2023-11-03
# @copyright  ChosenMed Technology
# @desc       The following commands is required for running this script:
#             export ICHOSEN_ROOT_PATH=XXX        # Absolute path
#             export ICHOSEN_PT_MODEL_PATH=XXX    # Absolute path
#             export ICHOSEN_PT_MODEL_TEMP=XXX    # Model template
#             export ICHOSEN_PT_CUDA_VISIB=XXX    # CUDA_VISIBLE_DEVICES
#             export ICHOSEN_PT_DATAS_NAME=XXX    # Dataset name
#             export ICHOSEN_PT_MODEL_PORT=XXX    # Web port
#             export ICHOSEN_PT_NUM_EPOCHS=XXX    # Number of epoches!
#             export ICHOSEN_PT_CONF_ACCEL=XXX    # Config file for accelerate (if need)!
#############################################################################################
#!/bin/bash


# Check Environment Variables!
if [ -z "${ICHOSEN_ROOT_PATH}" ]; then
    echo "Error: Environment variable 'ICHOSEN_ROOT_PATH' is not set. Please set it before running this script."
    exit 1
else
    cd ${ICHOSEN_ROOT_PATH}
fi
if [ -z "${ICHOSEN_PT_MODEL_PATH}" ]; then
    echo "Error: Environment variable 'ICHOSEN_PT_MODEL_PATH' is not set. Please set it before running this script."
    exit 1
else
    if [ ! -d "${ICHOSEN_PT_MODEL_PATH}" ]; then
        echo "Error: The directory specified by 'ICHOSEN_PT_MODEL_PATH' does not exist."
        exit 1
    fi
fi
if [ -z "${ICHOSEN_PT_MODEL_TEMP}" ]; then
    echo "Error: Environment variable 'ICHOSEN_PT_MODEL_TEMP' is not set. Please set it before running this script."
    exit 1
fi
if [ -z "${ICHOSEN_PT_DATAS_NAME}" ]; then
    echo "Error: Environment variable 'ICHOSEN_PT_DATAS_NAME' is not set. Please set it before running this script."
    exit 1
fi
if [ -z "${ICHOSEN_PT_CUDA_VISIB}" ]; then
    echo "Error: Environment variable 'ICHOSEN_PT_CUDA_VISIB' is not set. Default value '0' is set."
    ICHOSEN_PT_CUDA_VISIB=0
fi
if [ -z "${ICHOSEN_PT_MODEL_PORT}" ]; then
    echo "Warning: Environment variable 'ICHOSEN_PT_MODEL_PORT' is not set. Default value '6724' is set."
    ICHOSEN_PT_MODEL_PORT=6724
fi
if [ -z "${ICHOSEN_PT_NUM_EPOCHS}" ]; then
    echo "Warning: Environment variable 'ICHOSEN_PT_NUM_EPOCHS' is not set. Default value '3.0' is set."
    ICHOSEN_PT_NUM_EPOCHS=3.0
fi


# Check distributed or not!
bol_distributed=0  # false
case ${ICHOSEN_PT_CUDA_VISIB} in
  *,*)  # comma contains: multi-GPUs!
    bol_distributed=1  # true
    if [ -z "${ICHOSEN_PT_CONF_ACCEL}" ]; then
        echo "Error: Environment variable 'ICHOSEN_PT_CONF_ACCEL' is not set. Please set it before running this script."
        exit 1
    fi
    ;;
#   *)
#     echo "变量不包含逗号"
#     ;;
esac


# Variables!
ICHOSEN_PT_TIMESTAMP=$(date "+%Y%m%d-%H%M")
ICHOSEN_PT_NAME_MODEL=$(basename "${ICHOSEN_ROOT_PATH}")
ICHOSEN_PT_ODIR_CKPOT=${ICHOSEN_ROOT_PATH}/out/${ICHOSEN_PT_TIMESTAMP}_${ICHOSEN_PT_NAME_MODEL}_PT
ICHOSEN_PT_ODIR_MODEL=${ICHOSEN_PT_ODIR_CKPOT}_model

ICHOSEN_PT_SCRIPT_TRAIN=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_train.py
ICHOSEN_PT_SCRIPT_EXPOT=${ICHOSEN_ROOT_PATH}/factory/export_model.py

ICHOSEN_MODEL_WEB_SCRIPT=${ICHOSEN_ROOT_PATH}/factory/ichosengpt_web_streamlit.py


# Check Conda Environment!
echo "=============================================="
echo "##############################################"
echo "===> Now, let's check the conda environment..."
current_env=`conda info --envs | grep '\*' | awk '{print $1}'`
if [ "$current_env" != 'ichosengpt' ]; then
    eval "$(conda shell.bash hook)"  # Init conda!
    conda activate ichosengpt
fi


# Pre-Training!
echo ""
echo ""
echo "================================================="
echo "#################################################"
echo "===> Now, let's begin the pre-training process..."
CMD_PT_BASIC="CUDA_VISIBLE_DEVICES=${ICHOSEN_PT_CUDA_VISIB} python"
if [ ${bol_distributed} -eq 1 ]; then
    CMD_PT_BASIC="accelerate launch --config_file ${ICHOSEN_PT_CONF_ACCEL}"
fi
CMD_PT=`echo "${CMD_PT_BASIC} ${ICHOSEN_PT_SCRIPT_TRAIN} \
--stage pt \
--model_name_or_path ${ICHOSEN_PT_MODEL_PATH} \
--do_train \
--dataset ${ICHOSEN_PT_DATAS_NAME} \
--finetuning_type lora \
--lora_target all \
--output_dir ${ICHOSEN_PT_ODIR_CKPOT} \
--overwrite_cache \
--per_device_train_batch_size 4 \
--gradient_accumulation_steps 4 \
--lr_scheduler_type cosine \
--logging_steps 10 \
--save_steps 1000 \
--learning_rate 5e-5 \
--num_train_epochs ${ICHOSEN_PT_NUM_EPOCHS} \
--plot_loss \
--fp16 \
--overwrite_output_dir \
--template ${ICHOSEN_PT_MODEL_TEMP}"`
echo "===> Pre-training command: '${CMD_PT}'..."
eval ${CMD_PT}
RESULT_CMD_PT=$?
if [ $RESULT_CMD_PT -ne 0 ]; then
    echo "===> Oops... an error occurred while executing the pre-training command!"
    echo "===> Pipeline aborted..."
    exit $RESULT_CMD_PT
fi


# Model Export!
echo ""
echo ""
echo "================================================="
echo "#################################################"
echo "===> Now, let's begin the model export process..."
CMD_EX=`echo "python ${ICHOSEN_PT_SCRIPT_EXPOT} \
--model_name_or_path ${ICHOSEN_PT_MODEL_PATH} \
--template ${ICHOSEN_PT_MODEL_TEMP} \
--finetuning_type lora \
--checkpoint_dir ${ICHOSEN_PT_ODIR_CKPOT} \
--export_dir ${ICHOSEN_PT_ODIR_MODEL}"`
echo "===> Model export command: '${CMD_EX}'..."
eval ${CMD_EX}
RESULT_CMD_EX=$?
if [ $RESULT_CMD_EX -ne 0 ]; then
    echo "===> Oops... an error occurred while executing the model export command!"
    echo "===> Pipeline aborted..."
    exit $RESULT_CMD_EX
fi
## Delete some configurations that might lead to exceptions.
if [ "${ICHOSEN_PT_MODEL_TEMP}" = "chatglm3" ]; then
    cp ${ICHOSEN_PT_ODIR_MODEL}/tokenizer_config.json ${ICHOSEN_PT_ODIR_MODEL}/tokenizer_config.json.bak
    jq 'del(.eos_token) | del(.pad_token) | del(.unk_token)' ${ICHOSEN_PT_ODIR_MODEL}/tokenizer_config.json.bak > ${ICHOSEN_PT_ODIR_MODEL}/tokenizer_config.json
fi


# Running This Model!
echo ""
echo ""
echo "======================================================================="
echo "#######################################################################"
echo "===> Now, let's proceed with loading the exported model for testing...."
CMD_LM=`echo "export ICHOSEN_MODEL=${ICHOSEN_PT_ODIR_MODEL}; CUDA_VISIBLE_DEVICES=${ICHOSEN_PT_CUDA_VISIB} streamlit run ${ICHOSEN_MODEL_WEB_SCRIPT} --server.port ${ICHOSEN_PT_MODEL_PORT}"`
echo "===> Model export command: '${CMD_LM}'..."
eval ${CMD_LM}
RESULT_CMD_LM=$?
if [ $RESULT_CMD_LM -ne 0 ]; then
    echo "===> Oops... an error occurred while loading the exported model!"
    echo "===> Pipeline aborted..."
    exit $RESULT_CMD_LM
fi


# The End!
echo "===> Congratulations, you have successfully completed the current workflow."