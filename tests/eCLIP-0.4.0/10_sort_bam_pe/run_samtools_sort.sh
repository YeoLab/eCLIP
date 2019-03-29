#!/bin/bash

### Using samtools 1.6 (module load clipper/1.2.2v) ###

samtools sort inputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.rmDup.bam \
> outputs/204.rep1_clip.A01.r1.fq.genome-mappedAligned.out.sorted.rmDup.sorted.bam

samtools sort inputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.rmDup.bam \
> outputs/204.rep1_clip.B06.r1.fq.genome-mappedAligned.out.sorted.rmDup.sorted.bam
