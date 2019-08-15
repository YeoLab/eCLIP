#!/usr/bin/env python

import numpy as np
import pandas as pd
import argparse

def read_parsed(fn):
    """
    Reads Eric's parsed file from the repetitive element pipeline.
    Parameters
    ----------
    fn : basestring
        the *.parsed file
    Returns
    -------
    total_df : pandas.DataFrame
        dataframe of total reads per unique/repetitive element family.
    element_df : pandas.DataFrame
        dataframe of unique repetitive/unique elements that each unique read
        mapped to.
    total_reads : int
    total_genomic_reads : int
    total_usable_reads : int
    total_repfamily_reads : int
    """
    df = pd.read_table(fn, names=[
        'total_or_element', 'element', 'read_num',
        'clip_rpr', 'annotation', 'gene'
    ])
    try:
      total_reads = df[
          (df['total_or_element'] == '#READINFO') & (df['element'] == 'AllReads')
          ]['read_num'].values[0]
    except IndexError: # the re-parsed files don't have this row...
      total_reads = 0
    total_genomic_reads = df[
        (df['total_or_element'] == '#READINFO') & (
        df['element'] == 'GenomicReads')
        ]['read_num'].values[0]
    total_usable_reads = df[
        (df['total_or_element'] == '#READINFO') & (
        df['element'] == 'UsableReads')
        ]['read_num'].values[0]
    total_repfamily_reads = df[
        (df['total_or_element'] == '#READINFO') & (
        df['element'] == 'RepFamilyReads')
        ]['read_num'].values[0]

    total_df = df[df['total_or_element'] == 'TOTAL'][
        ['element', 'read_num', 'clip_rpr']
    ]
    element_df = df[df['total_or_element'] == 'ELEMENT'][
        ['element', 'read_num', 'clip_rpr']
    ]
    return total_df, element_df, \
           total_reads, total_genomic_reads, \
           total_usable_reads, total_repfamily_reads


def return_l2fc_entropy_from_parsed(ip_parsed, input_parsed, nopipes=True):
    """
    From 2 parsed rep element pipeline outputs (ip and input),
    compute fold change and information content. Usually fold changes of > 3+
    and information content of 0.1? can be considered enriched.
    Parameters
    ----------
    ip_parsed : str
        filename of the ip parsed string
    input_parsed : str
        filename of the input parsed string
    nopipes : bool
        if True, return just the uniquely mapped rep family mappings
        if False, return all unique and nonunique
    Returns
    -------
    merged : Pandas.DataFrame
        table consisting of fold enrichment and information content params
    """
    total_ip, _, _, _, _, _ = read_parsed(ip_parsed)
    total_input, _, _, _, total_input_usable_reads, _ = read_parsed(
        input_parsed)
    # a pipe indicates read totals mapping to more than one element/rep family.
    if nopipes:
        total_ip = total_ip[
            total_ip['element'].str.contains('\|') == False
        ]
        total_input = total_input[
            total_input['element'].str.contains('\|') == False
        ]
    # index columns by their element
    total_ip.set_index('element', inplace=True)
    total_input.set_index('element', inplace=True)
    # rename the IP and input columns separately
    total_ip.columns = ["IP_{}".format(c) for c in total_ip.columns]
    total_input.columns = ["Input_{}".format(c) for c in total_input.columns]
    # merge the two on element id
    merged = pd.merge(total_ip, total_input, how='left', left_index=True,
                      right_index=True)
    # deal with missing values
    merged['Input_read_num'].fillna(
        1, inplace=True
    )  # Pseudocount all missing values
    merged['Input_clip_rpr'].fillna(
        merged['Input_read_num'] / (total_input_usable_reads), inplace=True)
    # calculate fold enrichment and information content
    merged['Fold_enrichment'] = merged['IP_clip_rpr'].div(
        merged['Input_clip_rpr'])
    merged['Information_content'] = merged['IP_clip_rpr'] * np.log2(
        merged['IP_clip_rpr'].div(merged['Input_clip_rpr']))

    return merged


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--ip_parsed",
        required=True,
    )
    parser.add_argument(
        "--input_parsed",
        required=True,
    )
    parser.add_argument(
        "--out_file_nopipes",
        required=True,
    )
    parser.add_argument(
        "--out_file_withpipes",
        required=True,
    )

    # Process arguments
    args = parser.parse_args()
    ip_parsed = args.ip_parsed
    input_parsed = args.input_parsed
    out_file_nopipes = args.out_file_nopipes
    out_file_withpipes = args.out_file_withpipes

    # main func
    nopipes_df = return_l2fc_entropy_from_parsed(
        ip_parsed=ip_parsed,
        input_parsed=input_parsed,
        nopipes=True
    )
    withpipes_df = return_l2fc_entropy_from_parsed(
        ip_parsed=ip_parsed,
        input_parsed=input_parsed,
        nopipes=False
    )

    nopipes_df.to_csv(out_file_nopipes, sep='\t', index=True, header=True)
    withpipes_df.to_csv(out_file_withpipes, sep='\t', index=True, header=True)
if __name__ == "__main__":
    main()