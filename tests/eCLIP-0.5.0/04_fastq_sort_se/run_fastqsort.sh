#!/bin/bash

fastq-sort \
--id \
inputs/ENCODE4.4020_CLIP1.umi.r1.fqTrTr.fq > outputs/ENCODE4.4020_CLIP1.umi.r1.fqTrTr.sorted.fq

fastq-sort \
--id \
inputs/ENCODE4.4020_INPUT1.umi.r1.fqTrTr.fq > outputs/ENCODE4.4020_INPUT1.umi.r1.fqTrTr.sorted.fq

