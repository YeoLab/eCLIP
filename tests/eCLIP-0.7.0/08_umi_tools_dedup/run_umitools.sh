# umi_tools 1.0.0

umi_tools dedup \
--random-seed 1 \
-I inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats IP.umi.r1.fq.genome-mappedSoSo \
-S rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDup.bam


umi_tools dedup \
--random-seed 1 \
-I inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.bam \
--method unique \
--output-stats IN.umi.r1.fq.genome-mappedSoSo \
-S rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDup.bam
