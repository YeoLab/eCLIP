#!/bin/bash

### Users clipper (module load clipper/1.2.2v) ###

clipper \
--species hg19 \
--bam \
inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.bam \
--save-pickle \
--outfile \
outputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.peakClusters.bed
