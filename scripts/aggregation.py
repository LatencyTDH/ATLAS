"""This file aggregates all labels collected during the image recognition process.
Author: Sean Dai
"""

from __future__ import print_function

import json
import os
import sys

import nltk
from nltk.corpus import wordnet


def fetch_candidate_tags(results_file, threshold=0.7):
    with open(os.path.abspath(results_file)) as fh:
        text = fh.read().split('\n')
        text = filter(lambda s: '|' in s, text)
        aggregate = []
        for line in text:
            labels_str, score = line.split('|')
            if float(score) >= threshold:
                labels = map(str.strip, labels_str.split(','))
                aggregate.extend(labels)
        return list(set(aggregate))

def extrapolate_synonyms(wd):
    try:
        wd_synset = wordnet.synsets(wd)
        if wd_synset:
            synonyms = []
            for syn in wd_synset:
                synonyms.extend(syn.hypernyms())
            return map(lambda x: x.name().split('.')[0], synonyms)
    except LookupError:
        download_wordnet_corpus()
        return extrapolate_synonyms(wd)

def download_wordnet_corpus():
    from suppress import suppress_stdout
    with suppress_stdout():
        nltk.download('wordnet')

def remove_underscores_and_spaces(words):
    fixed = []
    for word in words:
        if '_' in word:
            fixed.extend(word.split('_'))
            fixed.append(word.replace('_', ' '))
        elif ' ' in word:
            fixed.extend(word.split(' '))
            fixed.append(word)
        else:
            fixed.append(word)
    return fixed

def retrieve_relevant_tags(results_file, threshold=0.7):
    candidates = fetch_candidate_tags(results_file, threshold)
    relevant_tags = []
    for cnd in candidates:
        new_words = extrapolate_synonyms(cnd)
        if new_words is not None:
            relevant_tags.extend(new_words)
    relevant_tags.extend(candidates)
    processed_tags = remove_underscores_and_spaces(relevant_tags)
    return list(set(processed_tags))

def main(args):
    relevant_tags = retrieve_relevant_tags(args[1], float(args[2]))

    # Create .json file with labeled video tags
    with open(args[1], 'r') as f:
        filepath = f.readline().rstrip()
        tb_name = f.readline().rstrip()
    tags = {
        "filename" : filepath,
        "tags" : relevant_tags,
        "thumbnail" : tb_name
    }
    print(json.dumps(tags))

if __name__ == "__main__":
    main(sys.argv)
