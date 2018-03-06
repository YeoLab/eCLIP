#!/bin/env python


def make_and_filter_clipper(fn, l2fc, pval):
    bedtool = pybedtools.BedTool(fn)
    filter_data_inst = functools.partial(filter_data, l2fc=l2fc, pval=pval)
    out_file = os.path.join(out_dir, os.path.basename(bedtool.fn) + "l2fc_{}_pval_{}.clipper.bed".format(l2fc, pval))
    if not os.path.exists(out_file):
        bedtool = bedtool.filter(filter_data_inst).saveas(out_file)
    return out_file


def filter_data(interval, l2fc, pval):
    #col4 is -log10 p-val
    #col5 is -log2 fold enrichment
    #This is the standard one
    return (float(interval[4]) >= pval) and (float(interval[3]) >= l2fc)


def make_clipper_ish(interval):
    interval.name = interval[7]
    interval[6] = interval.start
    interval[7] = interval.stop
    return interval
