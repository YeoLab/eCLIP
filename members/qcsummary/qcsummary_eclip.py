#!/usr/bin/env python

"""
General parsers for QC output of pipeline file,
generally pass a handle to the file you want to parse,
returns a dict containing all useful information
Currently this isn't standard
"""

# transitionning to python2/python3 support
# uncomment from this compatibility import list, as py3/py2 support progresses
from __future__ import print_function
from __future__ import division
# from __future__  import absolute_import
# from __future__  import unicode_literals
# from future import standard_library
# from future.builtins import builtins
# from future.builtins import utils
# from future.utils import raise_with_traceback
# from future.utils import iteritems

import glob
import os
import argparse

import pandas as pd
import pybedtools

from parse_cutadapt import parse_cutadapt_file
from qcsummary_rnaseq import rnaseq_metrics_df, parse_star_file

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

from matplotlib import rc
rc('text', usetex=False)
matplotlib.rcParams['svg.fonttype'] = 'none'
rc('font', **{'family': 'DejaVu Sans'})

def clipseq_metrics_csv(
        analysis_dir, output_csv, percent_usable, number_usable, peak_threshold
):
    # TODO: remove iclip param when new nomenclature is finalized.
    df = clipseq_metrics_df(
        analysis_dir=analysis_dir,
        percent_usable=percent_usable,
        number_usable=number_usable,
        iclip=True,
    )
    df.to_csv(output_csv)
    # TODO: more elegantly save figure.
    plot_qc(df, output_csv.replace('.csv','.png'), percent_usable, number_usable, peak_threshold)


def get_all_names(
        analysis_dir,
        cutadapt_round2_suffix,
        rm_dup_suffix,
        peak_suffix,
        sep,
        num_seps
):
    ###########################################################################
    # get file paths
    ################

    # cutadapt_round2_files = glob.glob(os.path.join(analysis_dir, "*.adapterTrim.round2.metrics"))
    cutadapt_round2_files = glob.glob(os.path.join(analysis_dir, cutadapt_round2_suffix))

    # rm_duped_files = glob.glob(os.path.join(analysis_dir, "*rmRep.rmDup.metrics"))
    rm_duped_files = glob.glob(os.path.join(analysis_dir, rm_dup_suffix))

    # peaks_files = glob.glob(os.path.join(analysis_dir, "*.peaks.bed"))
    peaks_files = glob.glob(os.path.join(analysis_dir, peak_suffix))

    ###########################################################################

    ###########################################################################
    # get file names
    ################
    cutadapt_round2_names = get_names(cutadapt_round2_files, num_seps, sep)
    # rmRep_mapping_names = get_names(rmRep_mapping_files, num_seps, sep)
    rm_duped_names = get_names(rm_duped_files, num_seps, sep)
    # spot_names = get_names(spot_files, num_seps, sep)
    peaks_names = get_names(peaks_files, num_seps, sep)
    ###########################################################################
    return cutadapt_round2_names, rm_duped_names, peaks_names

def clipseq_metrics_df(
        analysis_dir, percent_usable,
        number_usable,
        iclip=True, num_seps=None,
        sep=".",
        cutadapt_round2_suffix="*fqTrTr.metrics",
        rm_dup_suffix="*fqTrTrU-SoMaSoCo.metrics",
        peak_suffix="*fqTrTrU-SoMaSoCoSoMeV2Cl.bed"
):

    #######################################
    """
    Reports all clip-seq metrics in a given analysis directory
    outputs must follow gabes naming clipseq pipeline / naming conventions"
    Args:
        analysis_dir:
        iclip:
        num_seps:
        sep:
        percent_usable:
        number_usable:
    Returns:
    """
    # TODO: fix prefix name separator
    if num_seps is None:
        num_seps = 3 if iclip else 1

    cutadapt_round2_names, rm_duped_names, peaks_names = get_all_names(
        analysis_dir,
        cutadapt_round2_suffix,
        rm_dup_suffix,
        peak_suffix,
        sep,
        num_seps
    )

    ###########################################################################
    # make dataframes
    #################
    cutadapt_round2_df = pd.DataFrame(
        {
            name: parse_cutadapt_file(cutadapt_file)
            for name, cutadapt_file in cutadapt_round2_names.items()
        }
    ).transpose()
    cutadapt_round2_df.columns = [
        "{} Round 2".format(col) for col in cutadapt_round2_df.columns
    ]

    rm_duped_df = pd.DataFrame(
        {name: parse_rm_duped_metrics_file(rm_duped_file)
         for name, rm_duped_file in rm_duped_names.items()}
    ).transpose()

    peaks_df = pd.DataFrame(
        {name: {"Num Peaks": len(pybedtools.BedTool(peaks_file))}
         for name, peaks_file in peaks_names.items()}
    ).transpose()
    ###########################################################################

    ###########################################################################
    # get rnaseq metrics dataframe
    ##############################
    combined_df = rnaseq_metrics_df(analysis_dir, num_seps, sep)
    ###########################################################################

    ###########################################################################
    # merge dataframes
    ##################
    combined_df = pd.merge(combined_df, cutadapt_round2_df,
                           left_index=True, right_index=True, how="outer")
    combined_df = pd.merge(combined_df, rm_duped_df,
                           left_index=True, right_index=True, how="outer")
    combined_df = pd.merge(combined_df, peaks_df,
                           left_index=True, right_index=True, how="outer")

    ###########################################################################

    # compute useful stats
    ######################
    combined_df['Uniquely Mapped Reads'] = combined_df['Uniquely Mapped Reads'].astype(float)
    # print(combined_df['Uniquely Mapped Reads'])
    combined_df['Input Reads'] = combined_df['Input Reads'].astype(float)
    try:
        combined_df["Percent Usable / Mapped"] = \
            (combined_df['Usable Reads'] / combined_df['Uniquely Mapped Reads'])

        combined_df["Percent Usable / Input"] = \
            (combined_df['Usable Reads'] / combined_df['Input Reads'])

        combined_df['Passed QC'] = \
            (combined_df['Usable Reads'] > number_usable) & \
            (combined_df['Percent Usable / Mapped'] > percent_usable)

    except ZeroDivisionError:
        print("passing on ZeroDivisionError")
        pass

    return combined_df


def get_names(files, num_seps, sep):
    """
    Given a list of files return that files base name and the path to that file
     
    :param files: list
        list of files
    :param num_seps: int
        number of separators to call real names
    :param sep: str
        separator to split names on
    :return basenames: dict
        dict basename to file
    """

    dict_basename_to_file = {
        sep.join(os.path.basename(file).split(sep)[0: num_seps]): file
        for file in files
    }

    return dict_basename_to_file


def parse_peak_metrics(fn):
    """
    Unused function that has parsed/will parse CLIPPER metrics.
    
    :param fn: basestring
    :return spot_dict: dict 
    """
    with open(fn) as file_handle:
        file_handle.next()
        return {'spot': float(file_handle.next())}


def parse_rm_duped_metrics_file(rmDup_file):
    """
    Parses the rmdup file (tabbed file containing
     barcodes found ('randomer'), 
     number of reads found ('total_count'),
     number of reads removed ('removed_count')
     
    :param rmDup_file: basestring
        filename of the rmDup file
    :return count_dict: dict
        dictionary containing sums of total, removed, 
        and usable (total - removed)
    """
    ########################################
    try:

        df = pd.read_csv(rmDup_file, sep="\t")
        return {
            "total_count": sum(df.total_count),
            "removed_count": sum(df.removed_count),
            "Usable Reads": sum(df.total_count) - sum(df.removed_count)
        }
    except Exception as e:
        print(e)
        return {
            "total_count": None,
            "removed_count": None,
            "Usable Reads": None
        }


def build_second_mapped_from_master(df):
    second_mapped = df[[
        '% of reads unmapped: too short',
        '% of reads mapped to too many loci',
        '% of reads unmapped: too many mismatches',
        'Uniquely mapped reads %',
        'Percent Usable / Mapped'
    ]].fillna('0')
    for col in second_mapped.columns:
        try:
            second_mapped[col] = second_mapped[col].apply(
                lambda x: float(x.strip('%')) / 100
            )
        except AttributeError:
            second_mapped[col] = second_mapped[col].astype(float)
    return second_mapped


def build_peak_df_from_master(df):
    peaks = df[[
        'Num Peaks',
    ]]

    return peaks


def build_raw_number_from_master(df):
    num = df[[
        'Usable Reads',
        'Reads Passing Quality Filter',
        'Uniquely Mapped Reads',
        'Repetitive Reads'
    ]]
    return num


def plot_second_mapping_qc(df, percent_usable, ax):
    second_mapped = build_second_mapped_from_master(df)
    second_mapped.plot(kind='bar', ax=ax)
    ax.set_ylim(0, 1)
    ax.axhline(percent_usable, linestyle=':', alpha=0.75, label='minimum recommended percent usable threshold')
    ax.set_title("Percent Mapped/Unmapped/Usable (Usable: (dup removed read num) / (unique mapped reads))")
    ax.legend()

def plot_peak_qc(df, peak_threshold, ax):
    peaks = build_peak_df_from_master(df)
    peaks.plot(kind='bar', ax=ax)
    ax.axhline(peak_threshold, linestyle=':', alpha=0.75, label='minimum recommended peak threshold')
    ax.set_title("Peak Numbers (Only for merged files)")
    ax.legend()

def plot_raw_num_qc(df, number_usable, ax):
    ax.set_title("Number of Reads Mapped/Unmapped/Usable (Usable: (dup removed read num) / (unique mapped reads))")
    num = build_raw_number_from_master(df)
    num.plot(kind='bar', ax=ax)
    ax.axhline(number_usable, linestyle=':', alpha=0.75, label='minimum recommended number usable threshold')
    ax.legend()

def plot_qc(df, out_file, percent_usable, number_usable, peak_threshold):
    num_samples = len(df.index)

    f, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(5 * num_samples, 15), sharex=True)
    plot_second_mapping_qc(df, percent_usable, ax=ax1)
    plot_raw_num_qc(df, number_usable, ax=ax2)
    plot_peak_qc(df, peak_threshold, ax=ax3)
    plt.savefig(out_file)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Make a summary csv files of all eclip metrics")
    parser.add_argument("--analysis_dir", help="analysis directory", required=False, default="./")
    parser.add_argument("--output_csv", help="output csf filename", required=False, default="./eclipqcsummary.csv")
    parser.add_argument("--number_usable", help="number of usable peaks", required=False, type=float, default=1000000)
    parser.add_argument("--percent_usable", help="percent of usable peaks", required=False, type=float, default=0.7)
    parser.add_argument("--peak_threshold", help="peak threshold", required=False, type=float, default=3000)
    args = parser.parse_args()
    # print("args:", args)
    clipseq_metrics_csv(
        args.analysis_dir,
        args.output_csv,
        args.percent_usable,
        args.number_usable,
        args.peak_threshold
    )
