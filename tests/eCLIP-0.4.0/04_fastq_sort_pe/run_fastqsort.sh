#!/bin/bash

fastq-sort \
--id \
inputs/204.rep1_clip.A01.r1.fqTrTr.fq > outputs/204.rep1_clip.A01.r1.fqTrTr.sorted.fq

fastq-sort \
--id \
inputs/204.rep1_clip.A01.r2.fqTrTr.fq > outputs/204.rep1_clip.A01.r2.fqTrTr.sorted.fq

fastq-sort \
--id \
inputs/204.rep1_clip.B06.r1.fqTrTr.fq > outputs/204.rep1_clip.B06.r1.fqTrTr.sorted.fq

fastq-sort \
--id \
inputs/204.rep1_clip.B06.r2.fqTrTr.fq > outputs/204.rep1_clip.B06.r2.fqTrTr.sorted.fq
