#!/usr/bin/env python


import argparse


def get_strand_info_from_region(st):
    return st.split(':')[2]

def full_to_bed(input_file, output_file, enrichment_filter):
    """
    Turns a *.full file into a BED file with: 
    - l2fc now equal to the 'name' (col 4)
    - entropy now equal to the 'score' (col 5)
    """
    o = open(output_file, 'w')
    with open(input_file, 'r') as f:
        for line in f:
            line = line.split('\t')
            if float(line[11]) <= enrichment_filter:
                pass
            else:
                o.write(
                    "{0}\t{1}\t{2}\t{3:.15f}\t{4:.10f}\t{5}\n".format(
                        line[0], line[1], line[2],
                        float(line[11]),
                        float(line[12]),
                        get_strand_info_from_region(line[3])
                    )
                )
    o.close()

def main():
    """
    Turns a *.full file into a BED file with: 
    - l2fc now equal to the 'name' (col 4)
    - entropy now equal to the 'score' (col 5)
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        required=True,
    )
    parser.add_argument(
        "--output",
        required=True,
    )
    parser.add_argument(
        "--enrichment_filter",
        required=False,
        default=0,
        help='pre-filter peaks that are enriched over input (default: 0)'
    )
    args = parser.parse_args()

    input_file = args.input
    output_file = args.output
    enrichment_filter = args.enrichment_filter

    full_to_bed(
        input_file, output_file, enrichment_filter
    )

if __name__ == "__main__":
    main()
