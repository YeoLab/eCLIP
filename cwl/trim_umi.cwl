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
    # ramMin: 30000
    # tmpdirMin: 4000
    # outdirMin: 4000
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

  hard_trim_length:
    type: int
    default: -9
    inputBinding:
      position: 0
      prefix: -u

  # cores:
  #   type: int
  #   default: 4
  #   inputBinding:
  #     position: 1
  #     prefix: -cores

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
      # If output_r1 wasnt not specified, look for input basename
      glob: |
        ${
          if (inputs.output_r1 == "") {
            return [
              inputs.input_trim[0].nameroot + "Tr.fq"
            ];
          }
          else {
            return [
              inputs.output_r1
            ];
          }
        }

  output_trim_report:
    type: File
    outputBinding:
      # glob: "*Tr.metrics"
      glob: "*.metrics"

doc: |
  This tool wraps cutadapt to trim off the 3' end of R1 (may be UMIs) for eCLASH reads