import os
import sys
sys.path.append('.')
from os.path import join
from common.utils import read_json, dump_json, load_bin, dump_to_bin
from collections import OrderedDict
from types import SimpleNamespace
from transformers import AutoTokenizer
import torch
# from allennlp.predictors.predictor import Predictor
# import allennlp_models.tagging
import spacy
import string
from spacy.tokens import Doc
import argparse
from calib_exp.calib_utils import load_cached_dataset

def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dataset', type=str, default='mnli')
    parser.add_argument('--split', type=str, default=None)
    parser.add_argument('--tokenizer', type=str, default="roberta-base")
    args = parser.parse_args()
    if args.split is None:
        args.split = 'subhans-dev' if args.dataset == 'mnli' else 'dev'
    return args

def _merge_roberta_tokens_into_words(tokenizer, feature):
    tokens = tokenizer.convert_ids_to_tokens(feature.input_ids)
    assert len(tokens) == len(feature.input_ids)
    # decoded_each_tok = [
    #     bytearray([tokenizer.byte_decoder[c] for c in t]).decode("utf-8", errors=tokenizer.errors) for t in tokens
    # ]
    tokenizer_name = tokenizer.name_or_path
    if "roberta" in tokenizer_name.lower():
        decoded_each_tok = [tokenizer.convert_tokens_to_string([x, ]) for x in tokens]
    else:
        if "bert" in tokenizer_name.lower():
            decoded_each_tok = tokens
        else:
            raise ValueError(f"Have not implemented accommodation for tokenizer {tokenizer_name}")


    end_points = []
    force_break = False
    for i, t in enumerate(decoded_each_tok):
        # special token
        if t in tokenizer.all_special_tokens:
            end_points.append(i)
            force_break = True
            continue

         # no alphanum
        if not any([x.isalnum() for x in t.lstrip()]):
            end_points.append(i)
            force_break = True
            continue

        if not t.lstrip()[0].isalnum():
            # print('Special force', t)
            end_points.append(i)
            force_break = True
            continue

        if t in string.punctuation:
            end_points.append(i)
            force_break = True
            continue

        if force_break:
            end_points.append(i)
            force_break = False
            continue

        # if in question segment
        if t[0] == ' ':
            decoded_each_tok[i] = t[1:]
            end_points.append(i)
    end_points.append(len(decoded_each_tok))

    # if in context segment
    segments = []
    for i in range(1, len(end_points)):
        if end_points[i - 1] == end_points[i]:
            continue
        segments.append((end_points[i - 1], end_points[i]))
    
    merged_tokens = []
    for s0, s1 in segments:
        merged_tokens.append(''.join(decoded_each_tok[s0:s1]))
    
    return merged_tokens, segments

def assign_pos_tags(hf_tokens, nlp):
    words = [x.lstrip() for x in hf_tokens]
    spaces = [ False if i == len(hf_tokens) - 1 else hf_tokens[i + 1][0] == ' ' for i in range(len(hf_tokens))]    
    valid_idx = [i for i, w in enumerate(words) if len(w)]

    words = [words[i] for i in valid_idx]
    spaces = [spaces[i] for i in valid_idx]
    doc = Doc(nlp.vocab, words=words, spaces=spaces)
    # proced_tokens = nlp.tagger(doc)
    proced_tokens = nlp(doc)

    tag_info = [('','NULL', 'NULL')] * len(hf_tokens)
    for i, proc_tok in zip(valid_idx, proced_tokens):
        tag_info[i] = (proc_tok.text, proc_tok.pos_, proc_tok.tag_)
    return tag_info

def process_instance(tokenizer, nlp, feat, args):
    print(feat.id)
    words, segments = _merge_roberta_tokens_into_words(tokenizer, feat)
    if args.tokenizer == "roberta-base":
        question_end = words.index(tokenizer.sep_token)

        context_start = words.index(tokenizer.eos_token)
        conatext_tokens = words[context_start + 2: -1]
    else:
        if "bert" in tokenizer.name_or_path:
            context_start = words.index(tokenizer.sep_token)
            conatext_tokens = words[context_start + 1: -1]
        else:
            raise ValueError(f"Have not implemented accommodation for tokenizer {tokenizer.name_or_path}")
    question_tokens = words[1:context_start]
    question_tag_info = assign_pos_tags(question_tokens, nlp)
    context_tag_info = assign_pos_tags(conatext_tokens, nlp)
    if args.tokenizer == "roberta-base":
        tag_info = [('<s>', 'SOS', 'SOS')] + question_tag_info + [('<\s>', 'EOS', 'EOS'), ('<\s>', 'EOS', 'EOS')] + context_tag_info +  [('<\s>', 'EOS', 'EOS')]
    else:
        if "bert" in tokenizer.name_or_path:
            tag_info = [(tokenizer.cls_token, 'SOS', 'SOS')] + question_tag_info + [(tokenizer.sep_token, 'EOS', 'EOS'),] + context_tag_info + [
                           (tokenizer.sep_token, 'EOS', 'EOS')]
        else:
            raise ValueError(f"Have not implemented accommodation for tokenizer {tokenizer.name_or_path}")
    assert len(tag_info) == len(words)
    # print(tag_info)
    instance_info = {'words': words, 'segments': segments, 'tags': tag_info}
    return instance_info

def main():
    args = _parse_args()
    tokenizer = AutoTokenizer.from_pretrained(args.tokenizer, do_lower_case=False, cache_dir='hf_cache')
    features = load_cached_dataset(args.dataset, args.split, args.tokenizer)
    nlp = spacy.load("en_core_web_sm") 
    
    proced_instances = OrderedDict()
    for feat in features:
        if feat.id in proced_instances:
            print(feat.id)
            raise RuntimeError('Duplicate pairid')
        proced_instances[feat.id] = process_instance(tokenizer, nlp, feat, args)
    os.makedirs('misc/{}'.format(args.tokenizer.split("/")[-1]), exist_ok=True)
    dump_to_bin(proced_instances, 'misc/{}/{}_{}_tag_info.bin'.format(args.tokenizer.split("/")[-1], args.dataset, args.split))

def demo_spacy():
    nlp = spacy.load("en_core_web_sm") 
    result = nlp.tagger(nlp.tokenizer('Tokenize the "Super Bowl 50" sentence'))
    for token in result:
        print(token, token.pos_, token.tag_)

if __name__ == "__main__":
    # demo_spacy()
    main()
