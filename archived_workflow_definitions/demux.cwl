#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    #ramMin: 16000
    #tmpdirMin: 4000
    #outdirMin: 4000




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
  $(inputs.dataset).$(inputs.readsX.name).---.--.metrics,
  "--expectedbarcodeida",
  "$(inputs.readsX.barcodeids[0])",
  "--expectedbarcodeidb",
  "$(inputs.readsX.barcodeids[1])"
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

  seqdatapath:
    type: string

  readsX:
    type:
      type: record
      #name: reads
      fields:
        fwd:
          type: File
          inputBinding:
            position: 1
            prefix: --fastq_1
        rev:
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
      glob: $(inputs.readsX.name)
      loadContents: true
      outputEval: $(self[0].contents)
  barcodeidA:
    type: string
    outputBinding:
      glob: $(inputs.readsX.barcodeids[0])
      loadContents: true
      outputEval: $(self[0].contents)
  barcodeidB:
    type: string
    outputBinding:
      glob: $(inputs.readsX.barcodeids[1])
      loadContents: true
      outputEval: $(self[0].contents)

  demuxedAfwd:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.readsX.name).$(inputs.readsX.barcodeids[0]).r1.fq.gz
  demuxedArev:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.readsX.name).$(inputs.readsX.barcodeids[0]).r2.fq.gz
  demuxedBfwd:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.readsX.name).$(inputs.readsX.barcodeids[1]).r1.fq.gz
  demuxedBrev:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.readsX.name).$(inputs.readsX.barcodeids[1]).r2.fq.gz

  #output_demuxedpairedend_fastq1_all:
  #  type: File[]
  #  outputBinding:
  #    glob: "*_R1.*.f*q.gz"
  #    #glob: $(inputs.dataset).$(inputs.readsX.name).*.r1.fq.gz

  #output_demuxedpairedend_fastq2_all:
  #  type: File[]
  #  outputBinding:
  #    glob: "*_R2.*.f*q.gz"
  #    #glob: $(inputs.dataset).$(inputs.readsX.name).*.r2.fq.gz

  output_demuxedpairedend_metrics:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.readsX.name).---.--.metrics
    label: ""
    doc: "demuxedpairedend metrics"
