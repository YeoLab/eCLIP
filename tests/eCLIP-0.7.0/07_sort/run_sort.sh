# samtools 1.6 

echo $(date +%x,%r) > TIMES.txt;
samtools \
sort \
-n \
-o inputs/rep1.IP.umi.r1.fq.genome-mappedSo.bam \
inputs/rep1.IP.umi.r1.fq.genome-mapped.bam
echo $(date +%x,%r) >> TIMES.txt;
samtools \
sort \
-o rep1.IP.umi.r1.fq.genome-mappedSoSo.bam \
inputs/rep1.IP.umi.r1.fq.genome-mappedSo.bam
echo $(date +%x,%r) >> TIMES.txt;
samtools \
sort \
-n \
-o inputs/rep1.IN.umi.r1.fq.genome-mappedSo.bam \
inputs/rep1.IN.umi.r1.fq.genome-mapped.bam
echo $(date +%x,%r) >> TIMES.txt;
samtools \
sort \
-o rep1.IN.umi.r1.fq.genome-mappedSoSo.bam \
inputs/rep1.IN.umi.r1.fq.genome-mappedSo.bam
