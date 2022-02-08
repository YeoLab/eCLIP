#!/usr/qc/env python


import argparse
import subprocess
# import os
# import pysam


def pre_process_bam(bam, bam01, bam02):

    #split bam file into two, return file handle for the two bam files
    p = subprocess.Popen("samtools view {} | wc -l".format(bam), shell=True, stdout=subprocess.PIPE) # Number of reads in the tagAlign file
    stdout, stderr = p.communicate()
    nlines = int(stdout) / 2
    p = subprocess.Popen("samtools view {0} | shuf | split -d -l {1} - {0}".format(bam, nlines), shell=True) # This will shuffle the lines in the file and split it into two parts
    p.wait()

    #split and remake bam file
    p1 = subprocess.Popen("samtools view -H {0} | cat - {0}00 | samtools view -bS - > {0}00.bam".format(bam), shell=True) 
    p2 = subprocess.Popen("samtools view -H {0} | cat - {0}01 | samtools view -bS - > {0}01.bam".format(bam), shell=True)
    p1.wait()
    p2.wait()
  
    #sort remade bam file, can't combine due to race condition for viewing and sorting
    p1 = subprocess.Popen("samtools sort {0}00.bam -o {1}".format(bam, bam01), shell=True)
    p2 = subprocess.Popen("samtools sort {0}01.bam -o {1}".format(bam, bam02), shell=True)
    p1.wait()
    p2.wait()

    return bam01, bam02


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description='Runs IDR on a given bam file'
    )

    parser.add_argument(
        '--bam', required=True, help='bam file to split')
    parser.add_argument(
        '--bam01', required=True, help='name of first output bam')
    parser.add_argument(
        '--bam02', required=True, help='name of second output bam')

    args = parser.parse_args()
    bam01, bam02 = pre_process_bam(args.bam, args.bam01, args.bam02)
