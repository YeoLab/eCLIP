#!/bin/bash

### Using samtools 1.6 from clipper (module load clipper/1.2.2v) ###

samtools sort inputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.bam \
> outputs/4020_CLIP1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.bam

samtools sort inputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.bam \
> outputs/4020_INPUT1.umi.r1.genome-mapped.Aligned.out.namesorted.possorted.bam
