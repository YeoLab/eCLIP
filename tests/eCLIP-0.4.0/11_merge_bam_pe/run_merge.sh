#!/bin/bash

### Uses samtools 1.6 (module load clipper/1.2.2v) ###

samtools merge \
outputs/204.rep1_clip.A01.r1.fq.genome-mapped.outSo.rmDupSo.merged.bam \
inputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.rmDup.sorted.bam \
inputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.rmDup.sorted.bam
