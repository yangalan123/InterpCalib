export DATA_DIR=outputs
DATASET=${1:-none}
METHOD=${2:-none}
ACTION=${3:-run}
SPLIT=${4:-dev}
seed=$5

if [ "$DATASET" = "mnli" ]; then
    MAX_SEQ_LENGTH=128
else
  echo "Invalid dataset ${DATASET}"
  exit 1
fi

BATCH_SIZE=10

#MODEL_TYPE="roberta-base"
MODEL_TYPE="bert-base-uncased"
if [ "$ACTION" = "run" ]; then
  if [ "$METHOD" = "lime" -o "$METHOD" = "shap" ]; then
    echo "Run probing method"
    python -u run_perturb.py \
      --variant ${METHOD} \
      --model_type bert \
      --model_name_or_path chromeNLP/textattack_bert_base_MNLI_fixed \
      --cache_dir ./cached_model \
      --dataset ${DATASET} \
      --seed ${seed} \
      --overwrite_output_dir \
      --max_seq_length ${MAX_SEQ_LENGTH} \
      --per_gpu_eval_batch_size ${BATCH_SIZE} \
      --output_dir pred_output_custom_${seed} \
      --predict_file ${DATA_DIR}/${SPLIT}_${DATASET}.jsonl \
      --interp_dir interpretations_custom/${METHOD}/${DATASET}_${SPLIT}_${MODEL_TYPE}_sd${seed} 2>&1
#      --predict_file ${DATA_DIR}/${SPLIT}_${DATASET}.jsonl \
#      --output_dir pred_output \
#      --interp_dir interpretations/${METHOD}/${DATASET}_${SPLIT}_${MODEL_TYPE} 2>&1
  else
    echo "No such method" $METHOD
  fi
elif [ "$ACTION" = "vis" ]; then
  if [ "$METHOD" = "shap" -o "$METHOD" = "lime" ]; then
    echo "Vis intergrated gradient"
    CUDA_VISIBLE_DEVICES=$DEVICES \
    python -u run_perturb.py \
      --variant ${METHOD} \
      --model_type roberta \
      --tokenizer_name ${MODEL_TYPE} \
      --model_name_or_path ${MODEL_TYPE} \
      --dataset ${DATASET} \
      --output_dir pred_output_${seed} \
      --predict_file ${DATA_DIR}${SPLIT}_${DATASET}.jsonl \
      --interp_dir interpretations/${METHOD}/${DATASET}_${SPLIT}_${MODEL_TYPE}_sd${seed} 2>&1
#      --interp_dir interpretations/${METHOD}/${DATASET}_${SPLIT}_${MODEL_TYPE} \
#      --visual_dir visualizations/${METHOD}/${DATASET}_${SPLIT}_${MODEL_TYPE} 2>&1
#      --do_vis \
  else
    echo "No such method"
  fi
else
  echo "run or vis"
fi
