#!/usr/bin/env python

"""
fixscores.py

Created by Gabriel Pratt

fixes scores so we can actually make a bigbed track
"""

# TODO replace with argparse
from optparse import OptionParser
import pybedtools


def adjust_score(read):
    import numpy as np
    peak_center = str((int(read[6]) + int(read[7])) / 2)
    qValue = read.score
    pValue = str(-1) #to fix
    signalValue = str(-1)
    if float(read.score) != 0.0:
        read.score = str(min(int(-10 * np.log10(float(read.score))), 1000))
    else:
        read.score = "0"

    read[6] = signalValue
    read[7] = pValue
    read.append(qValue)
    read.append(peak_center)

    return read


def main():
    parser = OptionParser()

    parser.add_option("-b", "--bed",
                      dest="bed",
                      help="bed file to barcode collapse")
    parser.add_option("-o", "--out_file",
                      dest="out_file")

    (options,args) = parser.parse_args()

    pybedtools.BedTool(options.bed).each(adjust_score).saveas(options.out_file)


if __name__ == "__main__":
    main()
