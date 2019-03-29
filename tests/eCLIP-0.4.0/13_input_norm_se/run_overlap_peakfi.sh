#!/bin/bash

/projects/ps-yeolab4/software/eclip/0.4.0/bin/overlap_peakfi_with_bam_PE.pl \
inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.bam \
inputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.bam \
inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.peakClusters.bed \
inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.mappedreadnum \
inputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.rmDup.sorted.mappedreadnum \
outputs/4020_CLIP1.input-normed-peaks.bed
