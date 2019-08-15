#!/bin/bash

### Users clipper (module load clipper/1.2.2v) ###

clipper \
--species hg19 \
--bam \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam \
--save-pickle \
--outfile \
outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.bed
