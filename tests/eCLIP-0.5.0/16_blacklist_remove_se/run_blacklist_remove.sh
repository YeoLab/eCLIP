#!/bin/bash

bedtools intersect \
-v \
-s \
-a inputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.bed \
-b inputs/eCLIP_blacklistregions.hg19.bed > \
outputs/ENCODE4.4020_CLIP1.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.bed
