#!/bin/bash

fastq-sort \
--id \
inputs/ENCODE4.4020_CLIP1.umi.r1.fqTrTr.sorted.STARUnmapped.out.mate1  > outputs/ENCODE4.4020_CLIP1.umi.r1.fq.repeat-unmapped.sorted.fq

fastq-sort \
--id \
inputs/ENCODE4.4020_INPUT1.umi.r1.fqTrTr.sorted.STARUnmapped.out.mate1  > outputs/ENCODE4.4020_INPUT1.umi.r1.fq.repeat-unmapped.sorted.fq
