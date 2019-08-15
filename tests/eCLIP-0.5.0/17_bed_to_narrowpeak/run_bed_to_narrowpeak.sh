#!/bin/bash

python /projects/ps-yeolab4/software/eclip/0.5.0/bin/bed_to_narrowpeak.py \
--input_bed inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.bed \
--species hg19 \
--output_narrowpeak outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.narrowPeak
