# samtools 1.6
# overlap_peakfi_with_bam_PE.pl

samtools sort inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDup.bam > inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam
samtools sort inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDup.bam > inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam

samtools view -cF 4 inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam > ip_mapped_readnum.txt
samtools view -cF 4 inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam > input_mapped_readnum.txt

perl /projects/ps-yeolab4/software/eclip/0.7.0/bin/overlap_peakfi_with_bam_PE.pl \
inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam \
inputs/rep1.IN.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam \
inputs/rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.bed \
ip_mapped_readnum.txt \
input_mapped_readnum.txt \
rep1.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.bed

