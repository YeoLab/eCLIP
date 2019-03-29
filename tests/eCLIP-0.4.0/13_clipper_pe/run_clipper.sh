#!/bin/bash

### Users clipper (module load clipper/1.2.2v) ###

clipper \
--species hg19 \
--bam \
inputs/204.rep1_clip.A01.r1.fq.genome-mapped.outSo.rmDupSo.merged.r2.bam \
--save-pickle \
--outfile \
outputs/204.rep1_clip.A01.r1.fq.genome-mapped.outSo.rmDupSo.merged.r2.peakClusters.bed
