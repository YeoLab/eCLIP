# fastqtools 0.8

echo $(date +%x,%r) > TIMES.txt;
zcat ../03_cutadapt_round2/rep1.IP.umi.r1.fqTrTr.fq.gz > rep1.IP.umi.r1.fqTrTr.fq
echo $(date +%x,%r) >> TIMES.txt;
fastq-sort --id rep1.IP.umi.r1.fqTrTr.fq > rep1.IP.umi.r1.fqTrTr.sorted.fq
echo $(date +%x,%r) >> TIMES.txt;

echo $(date +%x,%r) >> TIMES.txt;
zcat ../03_cutadapt_round2/rep1.IN.umi.r1.fqTrTr.fq.gz > rep1.IN.umi.r1.fqTrTr.fq
echo $(date +%x,%r) >> TIMES.txt;
fastq-sort --id rep1.IN.umi.r1.fqTrTr.fq > rep1.IN.umi.r1.fqTrTr.sorted.fq
echo $(date +%x,%r) >> TIMES.txt;
