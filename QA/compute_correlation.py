from scipy.stats import spearmanr
import numpy as np
import torch
import glob
import os
path="/home/ec2-user/InterpCalib/QA/interpretations/shap/squad_addsent-dev_roberta-base_sd{}"
#path="/home/ec2-user/InterpCalib/QA/interpretations/full_2exp11_setting/shap/squad_addsent-dev_roberta-base_sd{}"
seed1_path = path.format(1)
seed2_path = path.format(2)
filenames = glob.glob(os.path.join(seed1_path, "*.bin"))
filenames = [os.path.basename(x) for x in filenames]
all_spearmans = []
for f_name in filenames:
    file1 = os.path.join(seed1_path, f_name)
    file2 = os.path.join(seed2_path, f_name)
    assert os.path.exists(file1) and os.path.exists(file2)
    data1 = torch.load(file1)
    data2 = torch.load(file2)
    data1_attr = data1["attribution"].numpy()
    data2_attr = data2["attribution"].numpy()
    spearman, p_val = spearmanr(data1_attr, data2_attr)
    all_spearmans.append(spearman)
print(np.mean(all_spearmans), np.std(all_spearmans))






