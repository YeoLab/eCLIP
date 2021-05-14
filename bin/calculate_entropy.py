#!/usr/bin/env python

import numpy as np
import pandas as pd
import argparse
import os

FULL_HEADER = [
    'chrom','start','end','peak','ip_count','input_count',
    'pvalue','chivalue','chitype','isenriched','l10p','l2fc'
]

def entropy(row, ip_mapped_num, input_mapped_num):
    """
    Computes the entropy for a given peak (row).
    Uses the number of reads and number of total mapped reads 
    to 
    """
    pip = float(row['ip_count']/float(ip_mapped_num))
    pinp = float(row['input_count']/float(input_mapped_num))
    return pip * np.log2(pip/pinp)
    
def sum_entropy(full, ip_mapped, input_mapped, l10p, l2fc):
    """
    Computes the entropy 
    """
    try:
        with open(ip_mapped, 'r') as f:
            ip_mapped_num = int(f.readline().rstrip())
        with open(input_mapped, 'r') as f:
            input_mapped_num = int(f.readline().rstrip())

        peaks = pd.read_csv(full, names=FULL_HEADER, sep='\t')
        peaks = peaks[(peaks['l10p'] >= l10p) & (peaks['l2fc'] >= l2fc)]
        peaks['entropy'] = peaks.apply(entropy, args=(ip_mapped_num, input_mapped_num, ), axis=1)

        return peaks['entropy'].sum()
    except Exception as e:
        return e
    
def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--full",
        required=True,
    )
    parser.add_argument(
        "--ip_mapped",
        required=True,
    )
    parser.add_argument(
        "--input_mapped",
        required=True,
    )
    parser.add_argument(
        "--l10p",
        required=False,
        default=3,
        help='Only consider peaks at or above this -log10p-value cutoff.'
    )
    parser.add_argument(
        "--l2fc",
        required=False,
        default=3,
        help='Only consider peaks at or above this log2 fold change cutoff.'
    )
    parser.add_argument(
        "--output",
        required=False,
        default=None,
        help='Write to file, default: stdout'
    )
    # Process arguments
    args = parser.parse_args()
    
    full = args.full
    ip_mapped = args.ip_mapped
    input_mapped = args.input_mapped
    l10p = args.l10p
    l2fc = args.l2fc
    output = args.output
    
    # main func
    summed_entropy = sum_entropy(
        full=full, 
        ip_mapped=ip_mapped, 
        input_mapped=input_mapped, 
        l10p=l10p, 
        l2fc=l2fc
    )
    if output is None:
        print(summed_entropy)
    else:
        with open(output, 'w') as o:
            o.write("{}".format(summed_entropy))
        
if __name__ == "__main__":
    main()
