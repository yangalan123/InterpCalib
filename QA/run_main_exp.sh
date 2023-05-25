export dataseed=$1
RUN_SQUAD_EXP () {
    DATASET="squad"
    TRAIN_SIZE=${1:-500}
    echo "${DATASET}-${TRAIN_SIZE}-dataseed_${dataseed}"
    echo "METHOD, ACC, AUC, F1@25, F1@50, F1@75"
    python calib_exp/run_exp.py --data_seed ${dataseed} --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_maxprob
    CONF_RES=$(python calib_exp/run_exp.py --data_seed ${dataseed} --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_maxprob 2>/dev/null | tail -1)
>>>>>>> Stashed changes
    echo 'Conf,'${CONF_RES}
    KAM_RES=$(python calib_exp/run_exp.py --data_seed ${dataseed} --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_baseline --arg_n_tree 300 --arg_max_depth 6  2>/dev/null  | tail -1)
    echo 'KAMATH,'${KAM_RES}
    BOW_RES=$(python calib_exp/run_exp.py --data_seed ${dataseed} --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_bow --arg_n_tree 200 --arg_max_depth 20 2>/dev/null  | tail -1)
    echo 'BOW,'${BOW_RES}
<<<<<<< Updated upstream
    EXPL_RES=$(python calib_exp/run_exp.py --method lime --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'LimeCal,'${EXPL_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 20 2>/dev/null | tail -1)
=======
    EXPL_RES=$(python calib_exp/run_exp.py --data_seed ${dataseed} --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 20 2>/dev/null | tail -1)
>>>>>>> Stashed changes
    echo 'ShapCal,'${EXPL_RES}
}


RUN_TRIVIA_EXP () {
    DATASET="trivia"
    TRAIN_SIZE=${1:-500}
    echo "${DATASET}-${TRAIN_SIZE}"
    echo "METHOD, ACC, AUC, F1@25, F1@50, F1@75"
    CONF_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_maxprob 2>/dev/null | tail -1)
    echo 'Conf,'${CONF_RES}
    KAM_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_baseline --arg_n_tree 300 --arg_max_depth 6  2>/dev/null  | tail -1)
    echo 'KAMATH,'${KAM_RES}
    BOW_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_bow --arg_n_tree 200 --arg_max_depth 20 2>/dev/null  | tail -1)
    echo 'BOW,'${BOW_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method lime --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'LimeCal,'${EXPL_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 20 2>/dev/null | tail -1)
    echo 'ShapCal,'${EXPL_RES}
}


RUN_HOTPOT_EXP () {
    DATASET="hotpot"
    TRAIN_SIZE=${1:-500}
    echo "${DATASET}-${TRAIN_SIZE}"
    echo "METHOD, ACC, AUC, F1@25, F1@50, F1@75"
    CONF_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_maxprob 2>/dev/null | tail -1)
    echo 'Conf,'${CONF_RES}
    KAM_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_baseline --arg_n_tree 300 --arg_max_depth 4  2>/dev/null  | tail -1)
    echo 'KAMATH,'${KAM_RES}
    BOW_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --do_bow --arg_n_tree 300 --arg_max_depth 10 2>/dev/null  | tail -1)
    echo 'BOW,'${BOW_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method lime --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 10 2>/dev/null | tail -1)
    echo 'LimeCal,'${EXPL_RES}
    EXPL_RES=$(python calib_exp/run_exp.py --method shap --train_size ${TRAIN_SIZE} --dataset ${DATASET} --arg_n_tree 300 --arg_max_depth 10 2>/dev/null | tail -1)
    echo 'ShapCal,'${EXPL_RES}
}

RUN_SQUAD_EXP 500
# RUN_TRIVIA_EXP 500
# RUN_HOTPOT_EXP 500




