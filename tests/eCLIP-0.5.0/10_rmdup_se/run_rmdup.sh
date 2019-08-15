#!/bin/bash

### Uses umi_tools 0.5.0 (module load umitools/0.5.0) ###

umi_tools dedup \
--random-seed 1 \
-I inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDup.metrics \
-S outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDup.bam

umi_tools dedup \
--random-seed 1 \
-I inputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats outputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDup.metrics \
-S outputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDup.bam
