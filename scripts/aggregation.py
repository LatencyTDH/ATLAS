"""This file aggregates all labels collected during the image recognition process.
Author: Sean Dai
"""
import numpy as np
import logging 

def fetch_candidate_tags(results_file, threshold=0.7):
	with open(results_file) as fh:
		text = fh.read().split('\n')
		text = filter(lambda s: '|' in s, text)
		aggregate = []
		for line in text:
			labels_str, score = line.split('|')
			if float(score) >= threshold:
				labels = map(str.strip, labels_str.split(','))
				aggregate.extend(labels)
		return np.unique(aggregate)

if __name__ == "__main__":
	candidates = fetch_candidate_tags('classes.txt', 0.4)
	print candidates 