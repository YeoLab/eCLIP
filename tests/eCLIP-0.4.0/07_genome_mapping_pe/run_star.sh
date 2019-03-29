#!/bin/bash

### Use star 2.4.0 (module load star/2.4.0) ###

STAR \
--alignEndsType EndToEnd \
--genomeDir inputs/star_sjdb \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix outputs/204.rep1_clip.A01.r1.fq.genome-mapped \
--outFilterMultimapNmax 1 \
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
inputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate1 \
inputs/204.rep1_clip.A01.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate2 \
--runMode alignReads \
--runThreadN 8

STAR \
--alignEndsType EndToEnd \
--genomeDir inputs/star_sjdb \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix outputs/204.rep1_clip.B06.r1.fq.genome-mapped \
--outFilterMultimapNmax 1 \
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
inputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate1 \
inputs/204.rep1_clip.B06.r1.fqTrTr.sorted.STARUnmapped.out.sorted.mate2 \
--runMode alignReads \
--runThreadN 8
