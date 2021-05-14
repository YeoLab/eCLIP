#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  dataset:
    type: string

  speciesGenomeDir:
    type: Directory

  repeatElementGenomeDir:
    type: Directory

  species:
    type: string

  chrom_sizes:
    type: File

  samples:
    type:
      type: array
      items:
        type: array
        items:
          type: record
          fields:
            read1:
              type: File
            name:
              type: string
            adapters:
              type: File
  
  blacklist_file:
    type: File
    
  ### repeat mapping options ###

  bowtie2_db:
    type: Directory
  bowtie2_prefix:
    type: string
  fileListFile1:
    type: File

  gencodeGTF:
    type: File
  gencodeTableBrowser:
    type: File
  repMaskBEDFile:
    type: File
    
  prefixes:
    type: string[]
    default: [
      "AA","AC","AG","AT","AN",
      "CA","CC","CG","CT","CN",
      "GA","GC","GG","GT","GN",
      "TA","TC","TG","TT","TN",
      "NA","NC","NG","NT","NN"
    ]
    
  ### region-level options ###

  trna_bed_file:
    type: File
  lncrna_table_file:
    type: File
  lncrna_full_file:
    type: File

outputs:


  ### DEMULTIPLEXED READ OUTPUTS ###


  output_ip_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_demuxed_fastq_r1

  output_input_b1_demuxed_fastq_r1:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_demuxed_fastq_r1


  ### TRIMMED OUTPUTS ###


  output_ip_b1_trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_encode_se_full/output_ip_b1_trimx1_fastq
  output_ip_b1_trimx1_metrics:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_trimx1_metrics

  output_input_b1_trimx1_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_encode_se_full/output_input_b1_trimx1_fastq
  output_input_b1_trimx1_metrics:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_trimx1_metrics

  output_ip_b1_trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_encode_se_full/output_ip_b1_trimx2_fastq
  output_ip_b1_trimx2_metrics:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_trimx2_metrics

  output_input_b1_trimx2_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: wf_encode_se_full/output_input_b1_trimx2_fastq
  output_input_b1_trimx2_metrics:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_trimx2_metrics


  ### REPEAT MAPPING OUTPUTS ###


  output_ip_b1_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_maprepeats_mapped_to_genome
  output_ip_b1_maprepeats_stats:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_maprepeats_stats
  output_ip_b1_maprepeats_star_settings:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_maprepeats_star_settings
  output_ip_b1_sorted_unmapped_fastq:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_sorted_unmapped_fastq

  output_input_b1_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_maprepeats_mapped_to_genome
  output_input_b1_maprepeats_stats:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_maprepeats_stats
  output_input_b1_maprepeats_star_settings:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_maprepeats_star_settings
  output_input_b1_sorted_unmapped_fastq:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_sorted_unmapped_fastq


  ### GENOME MAPPING OUTPUTS ###


  output_ip_b1_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_mapgenome_mapped_to_genome
  output_ip_b1_mapgenome_stats:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_mapgenome_stats
  output_ip_b1_mapgenome_star_settings:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_mapgenome_star_settings

  output_input_b1_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_mapgenome_mapped_to_genome
  output_input_b1_mapgenome_stats:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_mapgenome_stats
  output_input_b1_mapgenome_star_settings:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_mapgenome_star_settings


  ### DUPLICATE REMOVAL OUTPUTS ###


  output_ip_b1_pre_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_pre_rmdup_sorted_bam
  # output_ip_b1_barcodecollapsese_metrics:
  #   type: File[]
  #   outputSource: wf_encode_se_full/output_ip_b1_barcodecollapsese_metrics
  output_ip_b1_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_b1_rmdup_sorted_bam

  output_input_b1_pre_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_pre_rmdup_sorted_bam
  # output_input_b1_barcodecollapsese_metrics:
  #   type: File[]
  #   outputSource: wf_encode_se_full/output_input_b1_barcodecollapsese_metrics
  output_input_b1_rmdup_sorted_bam:
    type: File[]
    outputSource: wf_encode_se_full/output_input_b1_rmdup_sorted_bam


  ### BIGWIG FILES ###


  output_ip_pos_bw:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_pos_bw
  output_ip_neg_bw:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_neg_bw
  output_input_pos_bw:
    type: File[]
    outputSource: wf_encode_se_full/output_input_pos_bw
  output_input_neg_bw:
    type: File[]
    outputSource: wf_encode_se_full/output_input_neg_bw


  ### PEAK OUTPUTS ###


  output_clipper_bed:
    type: File[]
    outputSource: wf_encode_se_full/output_clipper_bed
  output_inputnormed_peaks:
    type: File[]
    outputSource: wf_encode_se_full/output_inputnormed_peaks
  output_compressed_peaks:
    type: File[]
    outputSource: wf_encode_se_full/output_compressed_peaks

  
  ### Downstream peak outputs ###
  
  
  output_blacklist_removed_bed:
    type: File[]
    outputSource: wf_encode_se_full/output_blacklist_removed_bed
  output_narrowpeak:
    type: File[]
    outputSource: wf_encode_se_full/output_narrowpeak
  output_fixed_bed:
    type: File[]
    outputSource: wf_encode_se_full/output_fixed_bed
  output_bigbed:
    type: File[]
    outputSource: wf_encode_se_full/output_bigbed
  output_entropynum:
    type: File[]
    outputSource: wf_encode_se_full/output_entropynum
    
  ### Repeat element outputs ###


  output_ip_concatenated_pre_rmDup_sam_file:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_concatenated_pre_rmDup_sam_file
  output_input_concatenated_pre_rmDup_sam_file:
    type: File[]
    outputSource: wf_encode_se_full/output_input_concatenated_pre_rmDup_sam_file


  ### RMDUPED SAM FILE FINAL OUTPUTS ###


  output_barcode1_concatenated_rmDup_sam_file:
    type: File[]
    outputSource: wf_encode_se_full/output_barcode1_concatenated_rmDup_sam_file
  output_input_concatenated_rmDup_sam_file:
    type: File[]
    outputSource: wf_encode_se_full/output_input_concatenated_rmDup_sam_file


  ### FINAL PARSED STATISTICS FILES ###


  output_ip_parsed:
    type: File[]
    outputSource: wf_encode_se_full/output_ip_parsed
  output_input_parsed:
    type: File[]
    outputSource: wf_encode_se_full/output_input_parsed
  output_nopipes:
    type: File[]
    outputSource: wf_encode_se_full/output_nopipes
  output_withpipes:
    type: File[]
    outputSource: wf_encode_se_full/output_withpipes


  ### Region normalization outputs ###


  clipBroadFeatureCountsFile:
    type: File[]
    outputSource: wf_encode_se_full/clipBroadFeatureCountsFile
  inputBroadFeatureCountsFile:
    type: File[]
    outputSource: wf_encode_se_full/inputBroadFeatureCountsFile
  combinedOutputFile:
    type: File[]
    outputSource: wf_encode_se_full/combinedOutputFile
  l2fcWithPvalEnrFile:
    type: File[]
    outputSource: wf_encode_se_full/l2fcWithPvalEnrFile
  l2fcFile:
    type: File[]
    outputSource: wf_encode_se_full/l2fcFile

steps:

###########################################################################
# Upstream
###########################################################################
  wf_encode_se_full:
    run: wf_encode_se_full_nostats.cwl
    scatter: sample
    in:
      dataset: dataset
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      chrom_sizes: chrom_sizes
      sample: samples
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
      prefixes: prefixes
      trna_bed_file: trna_bed_file
      lncrna_table_file: lncrna_table_file
      lncrna_full_file: lncrna_full_file
      blacklist_file: blacklist_file
    out: [
      output_ip_b1_demuxed_fastq_r1,
      output_input_b1_demuxed_fastq_r1,
      output_ip_b1_trimx1_fastq,
      output_ip_b1_trimx1_metrics,
      output_input_b1_trimx1_fastq,
      output_input_b1_trimx1_metrics,
      output_ip_b1_trimx2_fastq,
      output_ip_b1_trimx2_metrics,
      output_input_b1_trimx2_fastq,
      output_input_b1_trimx2_metrics,
      output_ip_b1_maprepeats_mapped_to_genome,
      output_ip_b1_maprepeats_stats,
      output_ip_b1_maprepeats_star_settings,
      output_ip_b1_sorted_unmapped_fastq,
      output_input_b1_maprepeats_mapped_to_genome,
      output_input_b1_maprepeats_stats,
      output_input_b1_maprepeats_star_settings,
      output_input_b1_sorted_unmapped_fastq,
      output_ip_b1_mapgenome_mapped_to_genome,
      output_ip_b1_mapgenome_stats,
      output_ip_b1_mapgenome_star_settings,
      output_ip_b1_pre_rmdup_sorted_bam,
      # output_ip_b1_barcodecollapsese_metrics,
      output_ip_b1_rmdup_sorted_bam,
      output_input_b1_mapgenome_mapped_to_genome,
      output_input_b1_mapgenome_stats,
      output_input_b1_mapgenome_star_settings,
      output_input_b1_pre_rmdup_sorted_bam,
      # output_input_b1_barcodecollapsese_metrics,
      output_input_b1_rmdup_sorted_bam,
      output_ip_pos_bw,
      output_ip_neg_bw,
      output_input_pos_bw,
      output_input_neg_bw,
      output_clipper_bed,
      output_inputnormed_peaks,
      output_compressed_peaks,
      output_blacklist_removed_bed,
      output_narrowpeak,
      output_fixed_bed,
      output_bigbed,
      output_entropynum,
      output_ip_concatenated_pre_rmDup_sam_file,
      output_input_concatenated_pre_rmDup_sam_file,
      output_barcode1_concatenated_rmDup_sam_file,
      output_input_concatenated_rmDup_sam_file,
      output_ip_parsed,
      output_input_parsed,
      output_nopipes,
      output_withpipes,
      clipBroadFeatureCountsFile,
      inputBroadFeatureCountsFile,
      combinedOutputFile,
      l2fcWithPvalEnrFile,
      l2fcFile
    ]
