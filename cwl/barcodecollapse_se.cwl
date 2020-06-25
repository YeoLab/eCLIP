#!/usr/bin/env cwl-runner

### doc: "collapses eCLIP barcodes to remove PCR duplicates" ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 8
    coresMax: 16
    ramMin: 64000
    # tmpdirMin: 4000
    # outdirMin: 4000
hints:
  - class: DockerRequirement
    dockerImageId: brianyee/umi_tools:1.0.0
    
baseCommand: [umi_tools, dedup]

arguments: ["--random-seed", "1"]

inputs:

  input_barcodecollapsese_bam:
    type: File
    inputBinding:
      position: 1
      prefix: -I
    label: ""
    doc: "input bam to barcode collapse. NOTE: no use for a bai index file!"
    secondaryFiles: [.bai]

  output_stats:
    default: ""
    type: string
    inputBinding:
      position: 1
      prefix: --output-stats
      valueFrom: |
        ${
          if (inputs.output_stats == "") {
            return inputs.input_barcodecollapsese_bam.nameroot;
          }
          else {
            return inputs.output_stats;
          }
        }
    label: ""
    doc: "stats i guess"

  method:
    default: "unique"
    type: string
    inputBinding:
      position: 1
      prefix: --method

  collapsed_bam:
    type: string
    default: ""
    inputBinding:
      position: 2
      prefix: -S
      valueFrom: |
        ${
          if (inputs.collapsed_bam == "") {
            return inputs.input_barcodecollapsese_bam.nameroot + ".rmDup.bam";
          }
          else {
            return inputs.collapsed_bam;
          }
        }
    label: ""
    doc: "input bam to barcode collapse. NOTE: no use for a bai index file!"

outputs:

  output_barcodecollapsese_bam:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.collapsed_bam == "") {
            return inputs.input_barcodecollapsese_bam.nameroot + ".rmDup.bam";
          }
          else {
            return inputs.collapsed_bam;
          }
        }
    label: ""
    doc: "barcode collapsed mappings bam "


  output_barcodecollapsese_metrics:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_stats == "") {
            return inputs.input_barcodecollapsese_bam.nameroot + "_per_umi.tsv";
          }
          else {
            return inputs.output_stats;
          }
        }
    label: ""
    doc: "barcode collapsed mappings stats "

doc: |
  The purpose of this command is to deduplicate BAM files based
  on the first mapping co-ordinate and the UMI attached to the read.
  It is assumed that the FASTQ files were processed with extract_umi.py
  before mapping and thus the UMI is the last word of the read name. e.g:

  @HISEQ:87:00000000_AATT

  where AATT is the UMI sequeuence.

    Usage: umi_tools dedup -I infile.bam -S deduped.bam -L dedup.log
