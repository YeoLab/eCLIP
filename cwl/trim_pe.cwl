#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool

# , $overlap_length_option
# , $g_adapters_option
# , $A_adapters_option
# , $a_adapters_option
# , -o, out_fastq.fastq.gz
# , -p, out_pair.fastq.gz
# , in_fastq.fastq.gz
# , in_pair.fastq.gz
# > report

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 32000
    tmpdirMin: 4000
    #outdirMin: 4000
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

#hints:
#  - class: ex:PackageRequirement
#    packages:
#      - name: cutadapt
#        package_manager: pip
#        version: "1.10"
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#  - class: ShellCommandRequirement


baseCommand: [cutadapt]

# arguments: [-f, fastq,
#   --match-read-wildcards,
#   --times, "2",
#   -e, "0.0",
#   --quality-cutoff, "6",
#   -m, "18",
#   -o, $(inputs.input_trim.nameroot)Tr.fqgz
#   ]

inputs:

  input_trim_overlap_length:
    type: string
    default: "5"
    inputBinding:
      position: 0
      prefix: -O

  f:
    type: string
    default: "fastq"
    inputBinding:
      position: 1
      prefix: -f

  match_read_wildcards:
    type: boolean
    default: true
    inputBinding:
      position: 2
      prefix: --match-read-wildcards

  times:
    type: string
    default: "2"
    inputBinding:
      position: 3
      prefix: --times

  error_rate:
    type: string
    default: "0.0"
    inputBinding:
      position: 4
      prefix: -e

  quality_cutoff:
    type: string
    default: "6"
    inputBinding:
      position: 5
      prefix: --quality-cutoff

  minimum_length:
    type: string
    default: "18"
    inputBinding:
      position: 6
      prefix: -m

  output_r1:
    type: string
    inputBinding:
      position: 7
      prefix: -o
      valueFrom: |
        ${
          if (inputs.output_r1 == "") {
            return inputs.input_trim[0].nameroot + "Tr.fq";
          }
          else {
            return inputs.output_r1;
          }
        }
    default: ""

  output_r2:
    type: string?
    inputBinding:
      position: 8
      prefix: -p
      valueFrom: |
        ${
          if (inputs.output_r2 == "") {
            return inputs.input_trim[1].nameroot + "Tr.fq";
          }
          else {
            return inputs.output_r2;
          }
        }
    default: ""

  input_trim_b_adapters:
    default: []
    type:
      type: array
      items: string
      inputBinding:
        prefix: "-b "
        separate: false
        # prefix: "--anywhere=file:"
        # prefix: "-b file:"
    inputBinding:
      position: 9

  input_trim_g_adapters:
    type:
      type: array
      items: string
      inputBinding:
        prefix: "-g "
        separate: false
        # prefix: "--front=file:"
        # prefix: "-g file:"
    inputBinding:
      position: 10

  input_trim_A_adapters:
    type:
      type: array
      items: string
      inputBinding:
        prefix: "-A "
        separate: false
        # prefix: "--ADAPTER=file:"
        # prefix: "-A file:"
    inputBinding:
      position: 11


  input_trim_a_adapters:
    type:
      type: array
      items: string
      inputBinding:
        prefix: "-a "
        separate: false
        # prefix: "--adapter=file:"
        # prefix: "-a file:"
    inputBinding:
      position: 12

  # cores:
  #   type: int
  #   default: 2
  #   inputBinding:
  #     position: 13
  #     prefix: -j

  input_trim:
    type: File[]?
    inputBinding:
      position: 14


stdout: $(inputs.input_trim[0].nameroot)Tr.metrics

outputs:

  output_trim:
    type: File[]?
    outputBinding:
      # glob: "*Tr.fq"
      # If output_r1 and output_r2 were not specified, look for input basename
      glob: |
        ${
          if (inputs.output_r1 == "") {
            return [
              inputs.input_trim[0].nameroot + "Tr.fq",
              inputs.input_trim[1].nameroot + "Tr.fq"
            ];
          }
          else {
            return [
              inputs.output_r1,
              inputs.output_r2
            ];
          }
        }

  output_trim_report:
    type: File
    outputBinding:
      # glob: "*Tr.metrics"
      glob: "*.metrics"
