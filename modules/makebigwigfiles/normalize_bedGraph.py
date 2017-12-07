#!/usr/bin/env python

'''
Created on Jan 10, 2014
@author: gpratt
Used for normalizing a wiggle file by the total number of reads in a dataset
'''

import argparse

import pysam

parser = argparse.ArgumentParser(description="""Takes a bedgraph and an indexed bam file and normalized bedgraph by number of reads in bam file (RPM)
outputs new normalized bedgraph file """)
parser.add_argument("--bg", help="bedgraph to make normalize", required=True)
parser.add_argument("--bam", help="bam file to normalize on", required=True)
args = parser.parse_args()

samfile = pysam.Samfile(args.bam)
mapped_reads = float(samfile.mapped) / 1000000
with open(args.bg) as bg:
    for line in bg:
        line = line.strip().split()
        line[3] = str(float(line[3]) / mapped_reads)
        print "\t".join(line)
