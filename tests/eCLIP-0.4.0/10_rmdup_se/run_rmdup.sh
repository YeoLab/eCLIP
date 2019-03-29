#!/bin/bash

### Uses umi_tools 0.5.0 (module load umitools/0.5.0) ###

umi_tools dedup \
--random-seed 1 \
-I inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.bam \
--method unique \
--output-stats outputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.metrics \
-S outputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.bam

umi_tools dedup \
--random-seed 1 \
-I inputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.bam \
--method unique \
--output-stats outputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.metrics \
-S outputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.bam
