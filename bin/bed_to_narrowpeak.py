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

def score_encode(row):
    if row['pValue'] >= 3 and row['signalValue'] >= 3:
        return 1000
    else:
        return 200

def return_narrowpeak_header(bed, species, visibility=3):
    name = os.path.basename(bed)
    description = name + " input-normalized peaks"
    header = 'track type=narrowPeak visibility={} db={} name=\"{}\" description=\"{}\"'.format(
        visibility, species, name, description
    )
    return header
    
def bed_to_narrowpeak(bed, species, narrowpeak):
    
    peaks = pd.read_csv(bed, names=ECLIP_HEADER, sep='\t')
    peaks['name'] = '.'
    peaks['score'] = peaks.apply(score_encode, axis=1)
    peaks['qValue'] = -1
    peaks['peak'] = -1
    
    with open(narrowpeak, 'w') as f:
        f.write("{}\n".format(return_narrowpeak_header(bed, species)))
    with open(narrowpeak, 'a') as f:
        peaks[[
            'chrom','start','end','name','score','strand','signalValue','pValue','qValue','peak'
        ]].to_csv(
            f,
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
        "--species",
        required=True,
    )
    parser.add_argument(
        "--output_narrowpeak",
        required=True,
    )
    
    # Process arguments
    args = parser.parse_args()
    bed = args.input_bed
    species = args.species
    narrowpeak = args.output_narrowpeak
    
    # Hack to get around the hg19/38 -> GRCh37/38 ucsc schema.
    if species.upper() == 'GRCH37' or species.upper().startswith('GRCH37'):
        species = 'hg19'
    elif species.upper() == 'GRCH38' or species.upper().startswith('GRCH38'):
        species = 'hg38'
        
    # main func
    bed_to_narrowpeak(bed, species, narrowpeak)
    
if __name__ == "__main__":
    main()
