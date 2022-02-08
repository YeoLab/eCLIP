
# input normalization script
############################


perl /home/gpratt/gscripts/perl_scripts/overlap_peakfi_with_bam_PE_gabesstupidversion.pl
required(ip_bam)
required(input_bam)
required(ip_peaks)
required(output_peaks)

perl /home/elvannostrand/data/clip/CLIPseq_analysis/FINAL_scripts/compress_l2foldenrpeakfi_gabesstupidversion.pl
required(output_peaks)
required(compressed_peaks)





# Full RBFOX2 running example:
##############################

perl /home/elvannostrand/data/clip/CLIPseq_analysis/FINAL_scripts/overlap_peakfi_with_bam_PE_gabesstupidversion.pl \
/home/gpratt/projects/idr/analysis/downsample_small_v1/204_02_RBFOX2.merged.r2.02.bam \
/projects/ps-yeolab2/encode/analysis/encode_v12/RBFOX2-204-INPUT_S2_R1.unassigned.adapterTrim.round2.rmRep.rmDup.sorted.r2.bam \
/home/gpratt/projects/idr/analysis/downsample_small_v1/204_02_RBFOX2.merged.r2.02.peaks.bed \
/home/gpratt/projects/idr/analysis/downsample_small_v1/204_02_RBFOX2.merged.r2.02.peaks.norm.bed \
&& \
perl /home/elvannostrand/data/clip/CLIPseq_analysis/FINAL_scripts/compress_l2foldenrpeakfi_gabesstupidversion.pl \
/home/gpratt/projects/idr/analysis/downsample_small_v1/204_02_RBFOX2.merged.r2.02.peaks.norm.bed \
/home/gpratt/projects/idr/analysis/downsample_small_v1/204_02_RBFOX2.merged.r2.02.peaks.norm.compressed.bed