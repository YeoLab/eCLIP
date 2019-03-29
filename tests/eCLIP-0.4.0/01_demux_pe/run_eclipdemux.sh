eclipdemux \
--dataset "204" \
--newname CLIP \
--metrics outputs/204.rep1.metrics \
--fastq_1 inputs/RBFOX2-204-CLIP_S1_R1.fastq.gz \
--fastq_2 inputs/RBFOX2-204-CLIP_S1_R2.fastq.gz \
--expectedbarcodeida A01 \
--expectedbarcodeidb B06 \
--barcodesfile inputs/yeolabbarcodes_20170101.fasta \
--length 5 \
--max_hamming_distance 1


eclipdemux \
--dataset "204" \
--newname INPUT \
--metrics outputs/204.input.metrics \
--fastq_1 inputs/RBFOX2-204-INPUT_S2_R1.fastq.gz \
--fastq_2 inputs/RBFOX2-204-INPUT_S2_R1.fastq.gz \
--expectedbarcodeida NIL \
--expectedbarcodeidb NIL \
--barcodesfile inputs/yeolabbarcodes_20170101.fasta \
--length 5 \
--max_hamming_distance 1
