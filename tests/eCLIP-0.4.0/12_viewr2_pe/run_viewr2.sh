#!/bin/bash

### Using samtools 1.6 (module load clipper/1.2.2v) ###

samtools view \
-f 128 \
-b \
-o outputs/204.rep1_clip.A01.r1.fq.genome-mapped.outSo.rmDupSo.merged.r2.bam \
inputs/204.rep1_clip.A01.r1.fq.genome-mapped.outSo.rmDupSo.merged.bam
