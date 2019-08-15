#!/bin/bash

bedToBigBed \
inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.fx.bed \
inputs/hg19.chrom.sizes \
outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.fx.bb
