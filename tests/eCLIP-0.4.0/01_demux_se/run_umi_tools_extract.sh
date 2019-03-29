#!/bin/bash

### using uni_tools 0.5.0 (module load umi_tools/0.5.0) ###

umi_tools \
extract \
--random-seed 1 \
--stdin inputs/4014_CLIP1_S2_L006_R1_001.fastq.gz \
--bc-pattern NNNNNNNNNN \
--log outputs/4014_CLIP1.---.--.metrics \
4014_CLIP1 \
--stdout outputs/4014_CLIP1.umi.r1.fq

umi_tools \
extract \
--random-seed 1 \
--stdin inputs/4014_INPUT1_S1_L006_R1_001.fastq.gz \
--bc-pattern NNNNNNNNNN \
--log outputs/4014_INPUT1.---.--.metrics \
4014_INPUT1 \
--stdout outputs/4014_INPUT1.umi.r1.fq
