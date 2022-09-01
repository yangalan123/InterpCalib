task=mrpc
model=chromeNLP/textattack_bert_base_MNLI_fixed
method=shap
data_seed=1
#python calib_exp/run_tagger.py --split ${task} --tokenizer ${model}
python calib_exp/make_calib_dataset.py --method ${method} --split ${task} --tokenizer ${model} --interpretation_dir interpretations_amortized --seed 1
sh exp_scripts/run_main_exp.sh ${data_seed} ${model}
