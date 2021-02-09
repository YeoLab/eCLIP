# STAR 2.7.6a

STAR \
--alignEndsType EndToEnd \
--genomeDir star_2_7_6a_gencode19_sjdb \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix rep1.IP.umi.r1.fq.genome-mapped \
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
--readFilesIn ../05_star_repeat/rep1.IP.umi.r1.fqTrTr.sorted.STARUnmapped.out.mate1 \
--runMode alignReads \
--runThreadN 8

STAR \
--alignEndsType EndToEnd \
--genomeDir star_2_7_6a_gencode19_sjdb \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix rep1.IN.umi.r1.fq.genome-mapped \
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
--readFilesIn ../05_star_repeat/rep1.IN.umi.r1.fqTrTr.sorted.STARUnmapped.out.mate1 \
--runMode alignReads \
--runThreadN 8
