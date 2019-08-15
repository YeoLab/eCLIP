#!/bin/bash

samtools view -c -F 4 inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam > \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.mappedreadnum

samtools view -c -F 4 inputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam > \
inputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDupSo.mappedreadnum

/projects/ps-yeolab4/software/eclip/0.5.0/bin/overlap_peakfi_with_bam_PE.pl \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam \
inputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.bed \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.mappedreadnum \
inputs/ENCODE4.4020_INPUT1.umi.r1.fq.genome-mappedSoSo.rmDupSo.mappedreadnum \
outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.bed
