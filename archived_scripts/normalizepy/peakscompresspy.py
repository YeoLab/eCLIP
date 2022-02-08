#!/usr/qc/env python


"""
This script :
- reads the sorted input normalized bed file
- and searches for overlapping peaks.
Between overlapping peaks:
- the peak with the greater -log10Pvalue will be retained.
- the other will be discarded.
Steps:
1) Read input normalized bed file
2)
"""

import pybedtools
import pandas
from argparse import ArgumentParser
#from argparse import RawDescriptionHelpFormatter
import os


def check_if_bed_file_is_sorted(bedfile_path):
    """
    This function will read the input normalized peaks bed file from the given path and check if the bed file is sorted 
    or not. If the bed file is not sorted, the function will sort the bed file and store it in the same location as the 
    original bed file. The file will be named <filename>.sorted.bed. The sorted bed file is required for efficiently 
    searching overlapping peaks. If the orginal file is already sorted, no changes will be made to the file and the same
    file will be used for all further analyses.
    :param bedfile_path: Full path and name of the input normalized peaks bed file
    :return sorted_bed_file_path: Full path and name of the sorted input normalized peaks bed file 
    """
    bed_file = pandas.read_csv(bedfile_path, sep='\t', names=['Chr', 'Start', 'Stop', '-log10PVal', 'log2FC', 'Strand','X'])

    ############################################################################################
    #if pandas.Index(bed_file[bed_file['Chr'].isin(['chr1', 'Chr1'])]['Start']).is_monotonic:
    if pandas.Index(bed_file[bed_file['Chr'].isin(['chr19', 'Chr19'])]['Start']).is_monotonic:
    ##############################################################################################

        return bedfile_path
    else:
        print('The bed file is not sorted\nSorting bed file...\n')
        sorted_bed_file_path = bedfile_path + '.sorted.bed'
        bed_file = pybedtools.BedTool(bedfile_path).sort()
        bed_file.saveas(sorted_bed_file_path)
        return sorted_bed_file_path


def shift_df_to_compare_next_row(df, num):
    """
    This function accepts a bed file dataframe and 'shifts' each row to the previous row, so that we can compare
    consecutive peaks if they overlap.
    :param df: The bed file dataframe
    :param num: Number rows to shift dataframe by
    :return df: Bed file dataframe with row shifted and attached to the previous row.
    """
    shift_df = df
    for i in range(num):
        shift_df = pandas.concat((df.shift(axis=0, periods=i), shift_df), axis=1).dropna()

    # adding columns start1, start2, start3, ... start11, stop1, stop2, stop3, ... stop11, ...  peak_key_11
    new_cols = list()
    for i in range(1, 11):
        for c in ['start_', 'stop_', '-log10pval_', 'log2fc_', 'peak_key_']:
            new_cols.append(c + str(i))
    shift_df.columns = new_cols
    return shift_df


def select_peak_by_highest_log10pval(df, num):
    """
    For each row in the passed dataframe, this function select the peak with the highest -log10pvalue. Dataframe passed
    to this function should contain overlapping peaks only. Returns a set of peaks that should be kept.
    :param df: Dataframe containing overlapping peaks
    :param num: Degree of overlap. Eg: num =5
    :return:
    """
    keep_peaks = set()
    cols = list()
    for i in range(1, num + 1):
        cols.append('-log10pval_' + str(i))
    max_pvals = df[cols].idxmax(axis=1)

    for i, pval_col in zip(range(1, num + 1), cols):
        key_col = 'peak_key_' + str(i)
        select_peaks = set(df.loc[max_pvals[max_pvals == pval_col].index][key_col])
        keep_peaks = keep_peaks.union(select_peaks)
    return keep_peaks


def search_for_chained_peaks(df, num):
    if num == 2:
        non_overlapping_peaks = df[(df['start_2'] >= df['stop_1']) | (df['stop_2'] <= df['start_1'])]
        pairwise_overlapping_peaks = df[((df['start_1'] < df['stop_2']) & (df['stop_1'] > df['stop_2'])) | ((df['start_1'] < df['start_2']) & (df['stop_1'] > df['start_2']))]
        if len(pairwise_overlapping_peaks) == 0:
            return set(non_overlapping_peaks['peak_key_1'])
        else:
            keep_peaks = select_peak_by_highest_log10pval(pairwise_overlapping_peaks, num)
            return keep_peaks.union(set(non_overlapping_peaks['peak_key_1']))
    for i in range(num, 1, -1):
        curr_stop = 'stop_' + str(i)
        curr_start = 'start_' + str(i)
        prev_stop = 'stop_' + str(i - 1)
        prev_start = 'start_' + str(i - 1)

        df = df[((df[prev_start] < df[curr_stop]) & (df[prev_stop] > df[curr_stop])) | ((df[prev_start] < df[curr_start]) & (df[prev_start] > df[curr_stop]))]
    if len(df) == 0:
        return set()
    else:
        return select_peak_by_highest_log10pval(df, num)


def search_for_overlapping_peaks(df):
    print('Total Number of Peaks = %d' % len(df))
    df['peak_key'] = df['start'].astype(str) + '-' + df['stop'].astype(str) + '-' + df['-log10pval'].astype(str)
    shifted_df = shift_df_to_compare_next_row(df, 9)
    all_peaks_to_keep = set
    for i in range(10, 1, -1):
        keep_peaks = search_for_chained_peaks(shifted_df, i)
        all_peaks_to_keep = all_peaks_to_keep.union(keep_peaks)
    return df[df['peak_key'].isin(all_peaks_to_keep)].drop('peak_key', 1)


def compress_peaks(bed_file_path):
    """
    This function will search for overlapping peaks. When found, the function will retain the peak with the greater
    -log10pvalue and discard the other overlapping peak.
    :param bed_file_path: Path to the sorted input normalized peaks bed file
    :return :
    """
    bed_file = pandas.read_csv(bed_file_path, sep='\t',
                               names=['chr', 'start', 'stop', '-log10pval', 'log2fc', 'strand','x'])
    print(bed_file.head())
    all_compressed_peaks = pandas.DataFrame(
          columns=['chr', 'start', 'stop', '-log10pval', 'log2fc', 'strand', 'x'])

    ### Parse through peaks by chromosome and strand.
    for c in set(bed_file.chr):
        for s in ['+', '-']:
            print("Parsing chromosome %s and strand %s" % (c, s))

            ### Send peaks for given chromosome and strand to function 'search_for_overlapping_peaks'
            x_col = bed_file[(bed_file['chr'] == c) & (bed_file['strand'] == s)]['x']
            compressed_peaks = search_for_overlapping_peaks(
                bed_file[(bed_file['chr'] == c) & (bed_file['strand'] == s)].drop(['chr', 'strand','x'], 1))
            compressed_peaks['chr'] = c
            compressed_peaks['strand'] = s
            compressed_peaks['x'] = x_col
            print('Number of Peaks Retained = %d' % len(compressed_peaks))
            all_compressed_peaks = pandas.concat((all_compressed_peaks, compressed_peaks), axis=0)
    return all_compressed_peaks


def main():
    parser = ArgumentParser(description="Compress overlapping peaks. Retains the peak with the larger -log10Pvalue")
    parser.add_argument("--inputbed", help="Full path and name of sorted input normalized bed file")
    parser.add_argument("--outputbed", help="Full path and name of sorted input normalized bed file")
    args = parser.parse_args()

    if os.path.isfile(args.inputbed):
        print("Found Input Normalized Bed File.\n")

        print("Checking if the bed file is sorted or not.\n")
        sorted_bed_file_path = check_if_bed_file_is_sorted(args.inputbed)
        print("The sorted bed file is here: %s" % sorted_bed_file_path)

        all_compressed_peaks = compress_peaks(sorted_bed_file_path)
        #output_bed = args.inputbed + ".compressed.bed"
        #all_compressed_peaks.to_csv(output_bed, sep='\t', index=False, header=False)

        # all_compressed_peaks.start = all_compressed_peaks.start.astype(int)
        # all_compressed_peaks.stop = all_compressed_peaks.stop.astype(int)
        # adding dropna
        all_compressed_peaks.start = all_compressed_peaks.start.dropna().astype(int)
        all_compressed_peaks.stop = all_compressed_peaks.dropna().stop.astype(int)

        #######################################################################
        #all_compressed_peaks.to_csv(args.outputbed, sep='\t', index=False, header=False)
        all_compressed_peaks.to_csv(
            args.outputbed, sep='\t', index=False, header=False,
            columns=['chr', 'start', 'stop', '-log10pval', 'log2fc', 'strand'])
        #all_compressed_peaks.to_csv(
            # args.outputbed, sep='\t', index=False, header=True,
            # columns=['chr', 'start', 'stop','-log10pval', 'log2fc', 'strand'])
        #######################################################################


    else:
        parser.error("Input normalized bed file not found !! Enter correct path and name.")


if __name__ == '__main__':
    main()
