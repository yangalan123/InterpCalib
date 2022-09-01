export data_seed=${1:-5}
export tokenizer=${2:-"roberta-base"}
RUN_QNLI_EXP () {
    DATASET="qnli"
    TRAIN_SIZE=${1:-500}
    echo "${DATASET}-${TRAIN_SIZE}"
    echo "METHOD, ACC, AUC"
    #python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_maxprob
    #CONF_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_maxprob 2>/dev/null | tail -1)
    echo 'Conf,'${CONF_RES}
    CLS_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_baseline --arg_n_tree 300 --arg_max_depth 3 2>/dev/null | tail -1)
    echo 'Cls,'${CLS_RES}
    BOW_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_bow --arg_n_tree 300 --arg_max_depth 6 2>/dev/null | tail -1)
    echo 'BOW,'${BOW_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method lime --train_size ${TRAIN_SIZE} --split ${DATASET} --arg_n_tree 400 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'LimeCal,'${EXPL_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --arg_n_tree 400 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'ShapCal,'${EXPL_RES}
}

RUN_MRPC_EXP () {
    DATASET="mrpc"
    TRAIN_SIZE=${1:-500}
    echo "${DATASET}-${TRAIN_SIZE}"
    #python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_maxprob
    python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_maxprob
    CONF_RES=$(python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_maxprob 2>/dev/null | tail -1)
    echo 'Conf,'${CONF_RES}
    CLS_RES=$(python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_baseline --arg_n_tree 300 --arg_max_depth 5 2>/dev/null | tail -1)
    echo 'Cls,'${CLS_RES}
    BOW_RES=$(python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --do_bow --arg_n_tree 300 --arg_max_depth 8 2>/dev/null | tail -1)
    echo 'BOW,'${BOW_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method lime --train_size ${TRAIN_SIZE} --split ${DATASET} --arg_n_tree 400 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'LimeCal,'${EXPL_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --tokenizer ${tokenizer} --data_seed ${data_seed} --method shap --train_size ${TRAIN_SIZE} --split ${DATASET} --arg_n_tree 400 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'ShapCal,'${EXPL_RES}
}

# RUN_QNLI_EXP 500
RUN_MRPC_EXP 500
