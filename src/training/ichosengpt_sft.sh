#############################################################################################
# iChosenGPT: Leverage the power of large models to fuel advancements in biomedical research.
#     --- Supervised Fine-Tuning your own LLM
# 
# @author     Quan Xu
# @date       2023-11-03
# @copyright  ChosenMed Technology
#############################################################################################
#!/bin/bash

# Init conda!
eval "$(conda shell.bash hook)"

# Set env!
cd /work/20230915-0759_GPT/20230920-1326_OS_Projects/20231101-2311_LLaMA-Factory/LLaMA-Factory
conda activate llama_factory

# Paramaters!
QX_PT_GLM3_TEST02_MODEL=/work/20230915-0759_GPT/20230915-0900_OS_LLMs/20231101-2103_ChatGLM3-6B
QX_PT_GLM3_TEST02_PTOUT=/work/20230915-0759_GPT/20230920-1326_OS_Projects/20231101-2311_LLaMA-Factory/LLaMA-Factory/out/20231102-1055_ChatGLM3-6B-test02
QX_PT_GLM3_TEST02_MDOUT=${QX_PT_GLM3_TEST02_PTOUT}-model

# Pre-training!
accelerate launch src/train_bash.py \
--stage sft \
--model_name_or_path $QX_PT_GLM3_TEST02_MODEL \
--do_train \
--dataset qx_corpus_chosenmed_qa_for_glm3 \
--template chatglm3 \
--finetuning_type lora \
--lora_target query_key_value \
--output_dir ${QX_PT_GLM3_TEST02_PTOUT} \
--overwrite_cache \
--per_device_train_batch_size 4 \
--gradient_accumulation_steps 4 \
--lr_scheduler_type cosine \
--logging_steps 10 \
--save_steps 1000 \
--learning_rate 5e-5 \
--num_train_epochs 30 \
--plot_loss \
--fp16 \
--overwrite_output_dir

# Export model!
python src/export_model.py \
--model_name_or_path $QX_PT_GLM3_TEST02_MODEL \
--template chatglm3 \
--finetuning_type lora \
--checkpoint_dir ${QX_PT_GLM3_TEST02_PTOUT} \
--export_dir ${QX_PT_GLM3_TEST02_MDOUT}

# Run model!
echo "=== Please edit the '${QX_PT_GLM3_TEST02_MDOUT}/tokenizer_config.json' to remove 3 '*_token' lines..."
echo "=== Now you should run the following commands manually..."
echo "cd /work/20230915-0759_GPT/20230920-1326_OS_Projects/20231101-2046_ChatGKB3-6B/ChatGLM3"
echo "conda activate glm3"
echo "CUDA_VISIBLE_DEVICES=7 streamlit run web_streamlit_sft.py --server.port 6724"
