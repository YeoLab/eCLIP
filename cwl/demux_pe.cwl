#!/usr/bin/env cwl-runner

### doc: "demultiplexes a paired-end eCLIP set of reads acording to the specified barcode and barcode file." ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    # ramMin: 30000
    tmpdirMin: 8000
    outdirMin: 8000


baseCommand: [eclipdemux]

arguments: ["--metrics",
  $(inputs.dataset).$(inputs.reads.name).---.--.metrics,
  "--expectedbarcodeida",
  "$(inputs.reads.barcodeids[0])",
  "--expectedbarcodeidb",
  "$(inputs.reads.barcodeids[1])"
  ]

inputs:

  barcodesfasta:
    type: File
    inputBinding:
      position: 6
      prefix: --barcodesfile

  randomer_length:
    type: string
    # default: "10"
    inputBinding:
      position: 7
      prefix: --length
    doc: "randomer length"

  dataset:
    type: string
    inputBinding:
      position: 5
      prefix: --dataset

  # TODO: remove when safe
  # seqdatapath:
  #   type: string

  reads:
    type:
      type: record
      #name: reads
      fields:
        read1:
          type: File
          inputBinding:
            position: 1
            prefix: --fastq_1
        read2:
          type: File
          inputBinding:
            position: 2
            prefix: --fastq_2
        barcodeids:
          type: string[]
          #default: [NIL, NIL]
          #inputBinding:
          #  position: 3
          #  prefix: --expectedbarcodeids
        name:
          type: string
          inputBinding:
            position: 4
            prefix: --newname


outputs:

  output_dataset:
    type: string
    outputBinding:
      glob: $(inputs.dataset)
      loadContents: true
      outputEval: $(self[0].contents)
  name:
    type: string
    outputBinding:
      glob: $(inputs.reads.name)
      loadContents: true
      outputEval: $(self[0].contents)
  barcodeidA:
    type: string
    outputBinding:
      glob: $(inputs.reads.barcodeids[0])
      loadContents: true
      outputEval: $(self[0].contents)
  barcodeidB:
    type: string
    outputBinding:
      glob: $(inputs.reads.barcodeids[1])
      loadContents: true
      outputEval: $(self[0].contents)

  demuxedAfwd:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).$(inputs.reads.barcodeids[0]).r1.fq.gz
  demuxedArev:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).$(inputs.reads.barcodeids[0]).r2.fq.gz
  demuxedBfwd:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).$(inputs.reads.barcodeids[1]).r1.fq.gz
  demuxedBrev:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).$(inputs.reads.barcodeids[1]).r2.fq.gz

  #output_demuxedpairedend_fastq1_all:
  #  type: File[]
  #  outputBinding:
  #    glob: "*_R1.*.f*q.gz"
  #    #glob: $(inputs.dataset).$(inputs.reads.name).*.r1.fq.gz

  #output_demuxedpairedend_fastq2_all:
  #  type: File[]
  #  outputBinding:
  #    glob: "*_R2.*.f*q.gz"
  #    #glob: $(inputs.dataset).$(inputs.reads.name).*.r2.fq.gz

  output_demuxedpairedend_metrics:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).---.--.metrics
    label: ""
    doc: "demuxedpairedend metrics"

doc: |
  demultiplex utility for paired-end eCLIP raw fastq files (process eCLIP barcodes and ramdomers)
  See: https://github.com/YeoLab/eclipdemux for full code and documentation
    Usage: eclipdemux --dataset DATASET_ID --metrics METRICS_FILE --fastq_1 READ_1 --fastq_2 READ_2 --expectedbarcodeida BARCODE_A --expectedbarcodeidb BARCODE_B --barcodesfile BARCODES_FASTA --length LENGTH