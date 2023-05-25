for seed in 1 2 3 4 5
do
    python calib_exp/make_calib_dataset.py --dataset squad --method shap --seed ${seed}
done
for seed in 1 2 3 4 5
do
    bash run_main_exp.sh ${seed}
done
