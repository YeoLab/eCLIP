#!/usr/bin/env cwl-runner

### doc: "demultiplexes a paired-end eCLIP set of reads acording to the specified barcode and barcode file." ###

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 32000
    tmpdirMin: 8000
    outdirMin: 8000




baseCommand: [eclipdemux]

#baseCommand: [singularityexec, eclip.img, demux_paired_end_test_2.py]
#baseCommand: [/projects/ps-yeolab/software/eclipdemux-0.0.1/eclipdemux]
#baseCommand: [singularityexec, eclip.img, echo, $PATH]




#requirements:
#
  # TODO purpose is hand over these strings to next cwl tool (parsebarcodes)
  # TODO not supported by toil, done instead inside demux_paired_end_test_2py
  #InitialWorkDirRequirement:
  #  listing:
  #    - entryname: $(inputs.dataset)
  #      entry: |
  #        $(inputs.dataset)
  #    - entryname: $(inputs.readsX.name)
  #      entry: |
  #        $(inputs.readsX.name)
  #    - entryname: $(inputs.readsX.barcodeids[0])
  #      entry: |
  #        $(inputs.readsX.barcodeids[0])
  #    - entryname: $(inputs.readsX.barcodeids[1])
  #      entry: |
  #        $(inputs.readsX.barcodeids[1])



#$namespaces:
#  ex: http://example.com/

#hints:

  #- class: ex:PackageRequirement
  #  packages:
  #    - name: bedtools
  #    - name: samtools
  #    - name: pysam
  #      package_manager: pip
  #      version: 0.8.3

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#      - "# Install eclip"
#      - "###############"
#      - "~/miniconda/bin/conda install -c anaconda numpy=1.10 pandas=0.17 scipy=0.16"
#      - "~/miniconda/bin/conda install -c bioconda samtools=1.3.1 bcftools=1.3.1 bedtools=2.25.0"
#      - "#~/miniconda/bin/conda install cython-0.24.1"
#      - "~/miniconda/bin/conda install -c bcbio pybedtools=0.6.9 pysam=0.8.4pre0"
#      - ""



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
    default: "10"
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