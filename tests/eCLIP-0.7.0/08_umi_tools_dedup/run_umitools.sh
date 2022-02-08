# umi_tools 1.0.0

echo $(date +%x,%r) > TIMES.txt;
umi_tools dedup \
--random-seed 1 \
-I inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats IP.umi.r1.fq.genome-mappedSoSo \
-S rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDup.bam
echo $(date +%x,%r) >> TIMES.txt;
echo $(date +%x,%r) >> TIMES.txt;
umi_tools dedup \
--random-seed 1 \
-I inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats IN.umi.r1.fq.genome-mappedSoSo \
-S rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDup.bam
echo $(date +%x,%r) >> TIMES.txt;
