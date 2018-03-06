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

import pandas as pd

from parse_cutadapt import parse_cutadapt_file


###############################################################################
def get_names(files, num_seps, sep):

    """
    Given a list of files return that files base name and the path to that file
    Args:
        files: list of files
        num_seps: int number of seperators in to call the real name
        sep: str seperator to split on
    Returns: dict basename to file
    """
    dict_basename_to_file = {sep.join(os.path.basename(file).split(sep)[0: num_seps]): file
                             for file in files}
    return dict_basename_to_file


###############################################################################
def rnaseq_metrics_df(analysis_dir, num_seps=1, sep="."):
    """
    Generates RNA-seq metrics
    Args:
        analysis_dir: directory to pull information from
        num_seps: number of seperators to join back to get the name of the item
        sep: seperator to split / join on to get full name
    Returns:
    """

    ###########################################################################
    # get file paths
    ################
    print("---")
    print("GET FILE PATHS FOR RNASEQ")

    # nrf_files = glob.glob(os.path.join(
    #     analysis_dir, "*.NRF.metrics"))
    nrf_files = glob.glob(os.path.join(
        analysis_dir, "*.NRF.metrics"))
    print("nrf_files:", nrf_files)

    # cutadapt_files = glob.glob(os.path.join(
    #     analysis_dir, "*.adapterTrim.metrics"))
    cutadapt_files = glob.glob(os.path.join(
        analysis_dir, "*fqTr.metrics"))
    print("cutadapt_files:", cutadapt_files)


    # rmrep_files = glob.glob(os.path.join(
    #     analysis_dir, "*rmRep.metrics"))
    # TODO: include repetitive element mapping list here.
    rmrep_files = glob.glob(os.path.join(
        analysis_dir, "*REPELEMENTMAPPING.metrics"))
    print("rmrep_files:", rmrep_files)

    # TODO: RNA-SEQ pipelines dont' cut twice, so provide a better name than "TrTr"
    # star_files_1 = glob.glob(os.path.join(
    #     analysis_dir, "*fqTr*Ma.metrics"))
    # print("star_files_1:", star_files_1)

    # star_files_2 = glob.glob(os.path.join(
    #     analysis_dir, "*rmRep.bamLog.final.out"))
    # TODO: RNA-SEQ pipelines dont' cut twice, so provide a better name than "TrTr"
    star_files_2 = glob.glob(os.path.join(
        analysis_dir, "*fqTr*U-SoMa.metrics"))
    print("star_files_2:", star_files_2)

    # hack for old data
    # if len(star_files_2) == 0:
    #     star_files_2 = glob.glob(os.path.join(
    #         analysis_dir, "*rmRep.samLog.final.out"))
    # hack for new data
    # if len(star_files_2) == 0:
    #     star_files_2 = glob.glob(os.path.join(
    #         analysis_dir, "*.bamLog.final.out"))
    ###########################################################################
    print("---")
    ###########################################################################

    ###########################################################################
    # get file names
    ################
    nrf_names = get_names(nrf_files, num_seps, sep)
    cutadapt_names = get_names(cutadapt_files, num_seps, sep)
    rmrep_names = get_names(rmrep_files, num_seps, sep)
    # star_names_1 = get_names(star_files_1, num_seps, sep)
    star_names_2 = get_names(star_files_2, num_seps, sep)
    ###########################################################################

    ###########################################################################
    # make dataframes
    #################
    nrf_df = pd.DataFrame(
        {name: parse_nrf_file(nrf_file)
         for name, nrf_file in nrf_names.items()}).transpose()
    cutadapt_df = pd.DataFrame(
        {name: parse_cutadapt_file(cutadapt_file)
         for name, cutadapt_file in cutadapt_names.items()}).transpose()
    rmrep_df = pd.DataFrame(
        {name: parse_rmrep_file(rmrep_file)
         for name, rmrep_file in rmrep_names.items()}).transpose()

    # TODO: add in first STAR mapping values (maybe just some of them are useful)
    # star_df_1 = pd.DataFrame(
    #     {name: parse_star_file(star_file)
    #      for name, star_file in star_names_1.items()}).transpose()

    star_df_2 = pd.DataFrame(
        {name: parse_star_file(star_file)
         for name, star_file in star_names_2.items()}).transpose()
    ###########################################################################

    ###########################################################################
    # merge dataframes
    ##################
    # combined_df = pd.merge(cutadapt_df, star_df_1,
    #                        left_index=True, right_index=True, how="outer")
    combined_df = pd.merge(cutadapt_df, star_df_2,
                           left_index=True, right_index=True, how="outer")
    combined_df = pd.merge(combined_df, rmrep_df,
                           left_index=True, right_index=True, how="outer")
    combined_df = pd.merge(combined_df, nrf_df,
                           left_index=True, right_index=True, how="outer")

    ###########################################################################
    # compute additional merics
    ###########################
    #Rename columns to be useful
    combined_df = combined_df.rename(
        columns={"Processed bases": "Input Bases",
                 "Processed reads": "Input Reads",
                 "Number of input reads": "Reads Passing Quality Filter",
                  "Uniquely mapped reads number": "Uniquely Mapped Reads",
           })


    ###########################################################################
    # compute useful stats
    ######################
    # FIXME TEMPORARILY COMMENTED OUT
    # try:
    #     combined_df["Percent Repetitive"] = \
    #         1 - (combined_df['Reads Passing Quality Filter']
    #              / combined_df['Input Reads'].astype(float))
    # except ZeroDivisionError:
    #     pass
    # except KeyError:
    #     print "cutadapt file maybe be broken, ignoring calculation"
    #     pass


    # # FIXME TEMPORARILY COMMENTED OUT
    # combined_df["Repetitive Reads"] = (
    #     combined_df['Input Reads']
    #     - combined_df['Reads Passing Quality Filter']
    # ).astype(float)
    # #).astype(int)


    #Get Rid of worthless metrics
    # FIXME TEMPORARILY COMMENTED OUT
    # combined_df = combined_df.drop(["Finished on",
    #                                 "Mapping speed, Million of reads per hour",
    #                                 "Started job on",
    #                                 "Started mapping on"
    #                                 ], axis=1)

    return combined_df
    ###########################################################################


###############################################################################
def parse_nrf_file(nrf_file):
    with open(nrf_file) as nrf_file:
        try:
            names = nrf_file.next().strip().split()
            values = nrf_file.next().strip().split()
            return {name: float(value) for name, value in zip(names, values)}
        except:
            return {}


###############################################################################
def parse_rmrep_file(rmrep_file):
    print("rmrep_file:", rmrep_file)
    try:
        df = pd.read_table(
            rmrep_file, header=None, sep=" ", index_col=0,
            names=["element", "repetitive_count"])
    except Exception as e:
        print(rmrep_file)
        raise e
    return df.sum().to_dict()


###############################################################################
def parse_star_file(star_file_name):
    with open(star_file_name) as star_file:
        star_dict = {}
        star_dict["Started job on"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Started mapping on"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Finished on"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Mapping speed, Million of reads per hour"] = star_file.next().strip().split("|")[1].strip()
        star_file.next()
        star_dict["Number of input reads"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Average input read length"] = float(star_file.next().strip().split("|")[1].strip())
        star_file.next()
        star_dict["Uniquely mapped reads number"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Uniquely mapped reads %"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Average mapped length"] = float(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: Total"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: Annotated (sjdb)"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: GT/AG"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: GC/AG"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: AT/AC"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Number of splices: Non-canonical"] = int(star_file.next().strip().split("|")[1].strip())
        star_dict["Mismatch rate per base, percent"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Deletion rate per base"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Deletion average length"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Insertion rate per base"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Insertion average length"] = star_file.next().strip().split("|")[1].strip()
        star_file.next()
        star_dict["Number of reads mapped to multiple loci"] = star_file.next().strip().split("|")[1].strip()
        star_dict["% of reads mapped to multiple loci"] = star_file.next().strip().split("|")[1].strip()
        star_dict["Number of reads mapped to too many loci"] = star_file.next().strip().split("|")[1].strip()
        star_dict["% of reads mapped to too many loci"] = star_file.next().strip().split("|")[1].strip()
        star_file.next()
        star_dict["% of reads unmapped: too many mismatches"] = star_file.next().strip().split("|")[1].strip()
        star_dict["% of reads unmapped: too short"] = star_file.next().strip().split("|")[1].strip()
        star_dict["% of reads unmapped: other"] = star_file.next().strip().split("|")[1].strip()
    return star_dict
