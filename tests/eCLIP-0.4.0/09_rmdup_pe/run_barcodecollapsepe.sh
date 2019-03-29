#!/bin/bash

### using barcodecollapsepe.py in eclip 0.3.0 (module load eclip/0.3.0) ###

barcodecollapsepe.py \
--bam inputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.bam \
--out_file outputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.rmDup.bam \
--metrics_file outputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.rmDup.metrics

barcodecollapsepe.py \
--bam inputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.bam \
--out_file outputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.rmDup.bam \
--metrics_file outputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.rmDup.metrics
