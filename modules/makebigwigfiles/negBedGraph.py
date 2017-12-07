#!/usr/bin/env python

import argparse

parser = argparse.ArgumentParser(description="Takes a bedgraph and makes all values negative")
parser.add_argument("--bg", help="bedgraph to make negative", required=True)
args = parser.parse_args()

with open(args.bg) as bg:
    for line in bg:
        line = line.strip().split()
        line[3] = str(float(line[3]) * -1)
        print "\t".join(line)
