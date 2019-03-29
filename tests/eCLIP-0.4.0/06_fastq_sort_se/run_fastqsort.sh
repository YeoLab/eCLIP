#!/bin/bash

fastq-sort \
--id \
inputs/4020_CLIP1.umi.r1.repeat-mapped.Unmapped.out.mate1 > outputs/4020_CLIP1.umi.r1.repeat-unmapped.sorted.fq

fastq-sort \
--id \
inputs/4020_INPUT1.umi.r1.repeat-mapped.Unmapped.out.mate1 > outputs/4020_INPUT1.umi.r1.repeat-unmapped.sorted.fq
