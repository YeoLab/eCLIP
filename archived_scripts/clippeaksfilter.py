#!/usr/qc/env python
# encoding: utf-8

"""

"""

import os
import functools
import argparse
import pybedtools



def filtered_output_filepath(input_filepath,l2fc, pval, out_filename, out_dir="./"):
    nameroot = os.path.splitext(os.path.basename(input_filepath))[0]
    # return os.path.join(out_dir, nameroot + "Fi_l2fc_{}_pval_{}.bed".format(l2fc, pval))
    if not out_filename:
        out_filename = nameroot + "Fi_l2fc_{}_pval_{}.bed".format(l2fc, pval)
    return os.path.join(out_dir, out_filename)

def make_and_filter_clipper(filename, l2fc, pval, out_filename, out_dir="./"):
    """
    make_and_filter_clipper
    :param fn:
    :param l2fc:
    :param pval:
    :param out_filename:
    :param out_dir:
    :return:
    """
    bedtool = pybedtools.BedTool(filename)
    out_filepath = filtered_output_filepath(bedtool.fn, l2fc, pval, out_filename)

    filter_data_inst = functools.partial(filter_data, l2fc=l2fc, pval=pval)

    if not os.path.exists(out_filepath):                          # TODO what if it exist?!
        bedtool.filter(filter_data_inst).saveas(out_filepath)     # TODO no need to reassign to bedtool

    #return out_filepath
    return bedtool


def filter_data(bedtoolinterval, l2fc, pval):
    """
    filtering function,checking bedtoolinterval for l2fc and pval criteria
    :param interval:
    :param l2fc: -log2 fold enrichment minimum value to retain bedtoolinterval
    :param pval: -log10 p-val minimum value to retain bedtoolinterval
    :return: a boolean, whether bedtoolinterval passes both l2fc and pval criteria
    """
    #col4 is -log10 p-val
    #col5 is -log2 fold enrichment
    #This is the standard one
    whether_bedtoolinterval_passes = (float(bedtoolinterval[4]) >= pval) and (float(bedtoolinterval[3]) >= l2fc)
    return whether_bedtoolinterval_passes



# TODO unused yet
# def make_clipper_ish(bedtoolinterval):
#     """
#     modify bedtoolinterval, setting positions 6 and 7 to start and stop
#     :param bedtoolinterval:
#     :return:
#     """
#     bedtoolinterval.name = bedtoolinterval[7]
#     bedtoolinterval[6] = bedtoolinterval.start
#     bedtoolinterval[7] = bedtoolinterval.stop
#     return bedtoolinterval




def main():

    description = """Clipper peaks filter based on log2 foldchange and log10 pval"""

    parser = argparse.ArgumentParser(description=description)


    parser.add_argument("--bed", help="bed file with normalized clipper peaks", required=True)
    parser.add_argument("--out", help="bed filename for filtered output", required=True)       # TODO make this optional
    parser.add_argument("--l2fc", help="minimum minus log2 foldchange", required=True)
    parser.add_argument("--pval", help="minimum minus log10 pvalue", required=True)

    args = parser.parse_args()

    if not (args.out.endswith(".bed")):
        raise TypeError("%s, not bed file" % args.bed)

    if not (args.bed.endswith(".bed")):                                        # TODO not needed ?
        raise TypeError("%s, not bed file" % args.bed)

    # if not isinstance(args.l2fc, int):
    #     raise TypeError("%s, not integer" % args.l2fc)
    # if not isinstance(args.pval, int):
    #     raise TypeError("%s, not integer" % args.pval)

    l2fc=int(args.l2fc)
    pval=int(args.pval)

    make_and_filter_clipper(args.bed, l2fc, pval, args.out)


if __name__ == "__main__":
    main()
