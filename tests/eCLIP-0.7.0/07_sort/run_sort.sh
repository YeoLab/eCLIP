# samtools 1.6 

samtools \
sort \
-n \
-o inputs/rep1.IP.umi.r1.fq.genome-mappedSo.bam \
inputs/rep1.IP.umi.r1.fq.genome-mapped.bam

samtools \
sort \
-o rep1.IP.umi.r1.fq.genome-mappedSoSo.bam \
inputs/rep1.IP.umi.r1.fq.genome-mappedSo.bam

samtools \
sort \
-n \
-o inputs/rep1.IN.umi.r1.fq.genome-mappedSo.bam \
inputs/rep1.IN.umi.r1.fq.genome-mapped.bam

samtools \
sort \
-o rep1.IN.umi.r1.fq.genome-mappedSoSo.bam \
inputs/rep1.IN.umi.r1.fq.genome-mappedSo.bam
