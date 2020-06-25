#!/usr/bin/env cwltool

### doc: "Doesn't actually demultiplex!!!" ###
### just trims the first 10 bases, but named as such to match the demux_pe step ###

cwlVersion: v1.0
class: CommandLineTool

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 32000
    tmpdirMin: 8000
    outdirMin: 8000
hints:
  - class: DockerRequirement
    dockerImageId: brianyee/umi_tools:1.0.0
    
baseCommand: [cat]
inputs:

  dataset:
    type: string
    
  reads:
    type:
      type: record
      fields:
        read1:
          type: File
          inputBinding:
            position: 1
        name:
          type: string
          
  stdout:
    type: string
    default: ""
    inputBinding:
      position: 2
      valueFrom: |
        ${
          if (inputs.stdout == "") {
            return inputs.dataset + "." + inputs.reads.name + ".umi.r1.fq";
          }
          else {
            return inputs.stdout;
          }
        }

  

outputs:

  demuxedAfwd:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).umi.r1.fq

  output_demuxedsingleend_metrics:
    type: File
    outputBinding:
      glob: $(inputs.dataset).$(inputs.reads.name).---.--.metrics
    label: ""
    doc: "demuxed se metrics"

  output_dataset:
    type: string
    outputBinding:
      loadContents: true
      outputEval: $(inputs.dataset)
    doc: "just passes output dataset string to output to match with PE demux"

  name:
    type: string
    outputBinding:
      loadContents: true
      outputEval: $(inputs.reads.name)
    doc: "just passes output name string to output to match with PE demux"

  # prefix:
  #   type: string
  #   outputBinding:
  #     loadContents: true
  #     outputEval: $(inputs.dataset).$(inputs.reads.name)
  #   doc: "added to make the renaming step easier"

doc: |
  Extract UMI barcode from a read and add it to the read name, leaving
  any sample barcode in place. Can deal with paired end reads and UMIs
  split across the paired ends. For eCLIP single-end processing, this step just
  trims the first 10 bases, but named as such to match the demux_pe step.

    Usage: umi_tools extract --bc-pattern=[PATTERN] -L extract.log [OPTIONS]
