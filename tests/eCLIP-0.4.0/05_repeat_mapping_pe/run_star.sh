#!/bin/bash

### Using star/2.4.0 module (module load star/2.4.0) ###

STAR \
--alignEndsType EndToEnd \
--genomeDir inputs/homo_sapiens_repbase_v2 \
--genomeLoad \
NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix outputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STAR \
--outFilterMultimapNmax 30 \
--outFilterMultimapScoreRange 1 \
--outFilterScoreMin 10 \
--outFilterType BySJout \
--outReadsUnmapped Fastx \
--outSAMattrRGline ID:foo \
--outSAMattributes All \
--outSAMmode Full \
--outSAMtype BAM Unsorted \
--outSAMunmapped Within \
--outStd Log \
--readFilesIn \
inputs/204.rep1_clip.A01.r1.fqTrTr.sorted.fq \
inputs/204.rep1_clip.A01.r2.fqTrTr.sorted.fq \
--runMode alignReads \
--runThreadN 8

STAR \
--alignEndsType EndToEnd \
--genomeDir inputs/homo_sapiens_repbase_v2 \
--genomeLoad \
NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix outputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STAR \
--outFilterMultimapNmax 30 \
--outFilterMultimapScoreRange 1 \
--outFilterScoreMin 10 \
--outFilterType BySJout \
--outReadsUnmapped Fastx \
--outSAMattrRGline ID:foo \
--outSAMattributes All \
--outSAMmode Full \
--outSAMtype BAM Unsorted \
--outSAMunmapped Within \
--outStd Log \
--readFilesIn \
inputs/204.rep1_clip.B06.r1.fqTrTr.sorted.fq \
inputs/204.rep1_clip.B06.r2.fqTrTr.sorted.fq \
--runMode alignReads \
--runThreadN 8
