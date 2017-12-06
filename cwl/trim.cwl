#!/usr/bin/env cwl-runner

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
    #ramMin: 8000
    ramMin: 16000
    #tmpdirMin: 4000
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


baseCommand: [cutadapt2]


arguments: [-f, fastq,
  --match-read-wildcards,
  --times, "1",
  -e, "0.1",
  --quality-cutoff, "6",
  -m, "18",
  -o, $(inputs.input_trim_fwd.nameroot)Tr.fqgz,
  -p, $(inputs.input_trim_rev.nameroot)Tr.fqgz
  #-o, $(inputs.input_trim_fwd.nameroot.slice(0,-3))Tr.fqgz,
  #-p, $(inputs.input_trim_rev.nameroot.slice(0,-3))Tr.fqgz
  ]


inputs:

  input_trim_overlap_length_file:
    type: File
    #default: "5"
    inputBinding:
      position: -3
      prefix: -O
    #  loadContents: True
    #  valueFrom: this.contents
    label: ""
    doc: ""

  input_trim_fwd:
    type: File
    inputBinding:
      position: -2

  input_trim_rev:
    type: File
    inputBinding:
      position: -1

#  input_trim_overlap_length:
#    type: string
#    #default: "1"
#    inputBinding:
#      position: 1
#      prefix: -O
#    valueFrom:  $(inputs.input_trim_overlap_length_file)
#    #default: $(inputs.input_trim_overlap_length_file.contents)
#    label: ""
#    doc: ""

  input_trim_g_adapters:
    type: File
    inputBinding:
      position: 2
      prefix: "-g file:"
      separate: False

  input_trim_A_adapters:
    type: File
    inputBinding:
      position: 3
      prefix: "-A file:"
      separate: False

  input_trim_a_adapters:
    type:  File
    inputBinding:
      position: 4
      prefix: "-a file:"
      separate: False



stdout: $(inputs.input_trim_rev.nameroot)Tr.metrics
        #$(inputs.input_trim_rev.nameroot.slice(0,-3))Tr.metrics


outputs:

  output_trim_fwd:
    type: File
    outputBinding:
      glob: $(inputs.input_trim_fwd.nameroot)Tr.fqgz
      #glob: $(inputs.input_trim_fwd.nameroot.slice(0,-3))Tr.fqgz

  output_trim_rev:
    type: File
    outputBinding:
      glob: $(inputs.input_trim_rev.nameroot)Tr.fqgz
      #glob: $(inputs.input_trim_rev.nameroot.slice(0,-3))Tr.fqgz

  output_trim_report:
    type: File
    outputBinding:
      glob: $(inputs.input_trim_rev.nameroot)Tr.metrics
      #glob: $(inputs.input_trim_rev.nameroot.slice(0,-3))Tr.metrics
