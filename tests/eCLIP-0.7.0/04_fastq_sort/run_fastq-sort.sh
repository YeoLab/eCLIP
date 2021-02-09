# fastqtools 0.8

zcat ../03_cutadapt_round2/rep1.IP.umi.r1.fqTrTr.fq.gz > rep1.IP.umi.r1.fqTrTr.fq
fastq-sort --id rep1.IP.umi.r1.fqTrTr.fq > rep1.IP.umi.r1.fqTrTr.sorted.fq

zcat ../03_cutadapt_round2/rep1.IN.umi.r1.fqTrTr.fq.gz > rep1.IN.umi.r1.fqTrTr.fq
fastq-sort --id rep1.IN.umi.r1.fqTrTr.fq > rep1.IN.umi.r1.fqTrTr.sorted.fq
