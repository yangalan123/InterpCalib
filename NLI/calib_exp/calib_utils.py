import torch

def load_cached_dataset(dataset, split="dev", tokenizer_name="mnli_roberta-base",):
    _tokenizer_name = tokenizer_name if "/" not in tokenizer_name else tokenizer_name.split("/")[-1]
    cache_file = './cached/{}_{}_{}_128'.format(split, dataset, _tokenizer_name)
    return torch.load(cache_file)
