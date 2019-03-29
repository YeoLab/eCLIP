#!/bin/bash

### Using fastqtools-0.8 (module load fastqtools/0.8) ###

fastq-sort \
--id \
inputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.mate1 > outputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate1

fastq-sort \
--id \
inputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.mate2 > outputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate2

fastq-sort \
--id \
inputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.mate1 > outputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate1

fastq-sort \
--id \
inputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.mate2 > outputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate2
