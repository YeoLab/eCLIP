# STAR 2.7.6a
echo $(date +%x,%r) > TIMES.txt;
STAR \
--alignEndsType EndToEnd \
--genomeDir repbase_STARindex \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix rep1.IP.umi.r1.fqTrTr.sorted.STAR \
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
--readFilesIn ../04_fastq_sort/rep1.IP.umi.r1.fqTrTr.sorted.fq \
--runMode alignReads \
--runThreadN 8
echo $(date +%x,%r) >> TIMES.txt;

echo $(date +%x,%r) >> TIMES.txt;
STAR \
--alignEndsType EndToEnd \
--genomeDir repbase_STARindex \
--genomeLoad NoSharedMemory \
--outBAMcompression 10 \
--outFileNamePrefix rep1.IN.umi.r1.fqTrTr.sorted.STAR \
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
--readFilesIn ../04_fastq_sort/rep1.IN.umi.r1.fqTrTr.sorted.fq \
--runMode alignReads \
--runThreadN 8
echo $(date +%x,%r) >> TIMES.txt;
