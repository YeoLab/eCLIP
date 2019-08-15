#!/bin/bash

### using uni_tools 0.5.0 (module load umi_tools/0.5.0) ###

umi_tools \
extract \
--random-seed 1 \
--stdin inputs/4020_CLIP1_S18_L007_R1_001.fastq.gz \
--bc-pattern NNNNNNNNNN \
--log outputs/4020_CLIP1.---.--.metrics \
4020_CLIP1 \
--stdout outputs/4020_CLIP1.umi.r1.fq

umi_tools \
extract \
--random-seed 1 \
--stdin inputs/4020_INPUT1_S17_L007_R1_001.fastq.gz \
--bc-pattern NNNNNNNNNN \
--log outputs/4020_INPUT1.---.--.metrics \
4020_INPUT1 \
--stdout outputs/4020_INPUT1.umi.r1.fq
