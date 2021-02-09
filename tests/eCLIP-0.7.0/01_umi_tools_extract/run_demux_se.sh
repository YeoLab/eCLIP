# umi_tools 1.0.0

umi_tools extract \
--random-seed 1 \
--bc-pattern NNNNNNNNNN \
--stdin inputs/seRBFOX2/INV_IP_B_S58_L005_R1_001.fastq.gz \
--stdout rep1.IP.umi.r1.fq.gz \
--log rep1.IP.---.--.metrics

umi_tools extract \
--random-seed 1 \
--bc-pattern NNNNNNNNNN \
--stdin inputs/seRBFOX2/INV_IN_B_S57_L006_R1_001.fastq.gz \
--stdout rep1.IN.umi.r1.fq.gz \
--log rep1.IN.---.--.metrics
