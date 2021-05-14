#!/usr/bin/env python

"""
narrowPeak, 
cols 9 and 10 are just blank, 
col 5 is 1000 for things that meet the >=3 l2fc and l10pval cutoffs and 200 otherwise (its just for ucsc track coloring)
"""
import numpy as np
import pandas as pd
import argparse
import os

ECLIP_HEADER = [
    'chrom','start','end','pValue','signalValue','strand'
]

def combine_pvalue_fold(row):
    return "{}|{}".format(row['pValue'], row['signalValue'])
    
def fix_bed(bed, fixed_bed):
    
    peaks = pd.read_csv(bed, names=ECLIP_HEADER, sep='\t')
    peaks['name'] = peaks.apply(combine_pvalue_fold, axis=1)
    peaks['score'] = 0
    
    peaks[[
        'chrom','start','end','name','score','strand'
    ]].to_csv(
        fixed_bed,
        sep='\t',
        header=False,
        index=False
    )
    
    
def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--input_bed",
        required=True,
    )
    parser.add_argument(
        "--output_fixed_bed",
        required=True,
    )
    
    # Process arguments
    args = parser.parse_args()
    bed = args.input_bed
    output_fixed_bed = args.output_fixed_bed
        
    # main func
    fix_bed(bed, output_fixed_bed)
    
if __name__ == "__main__":
    main()
