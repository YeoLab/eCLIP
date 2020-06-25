#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [reparse_samfile_updatedchrM_fixmultenstsort_PE.pl]

inputs:

  sam_file:
    type: File
    inputBinding:
      position: 1
    label: "combined rmduped sam file"

  chrM_genelist_file:
    type: File
    inputBinding:
      position: 2
    label: "chrM gene list file custom made by Eric"

  fileList1:
    type: File
    inputBinding:
      position: 3
    doc: "tsv with 5 fields: ENST/ENSG/name/chrom/genelist.file"

  fileList2:
    type: File
    inputBinding:
      position: 4
    doc: "tsv with 5 fields: name/type/type/type/desc"

  mirbase_file:
    type: File
    inputBinding:
      position: 5
    doc: "mirbase gff3"

  reparsed:
    type: string
    inputBinding:
      position: 6
      valueFrom: |
        ${
          if (inputs.reparsed == "") {
            return inputs.sam_file.nameroot + ".reparsed.tsv";
          }
          else {
            return inputs.reparsed;
          }
        }
    default: ""
    doc: "output file name"

outputs:

  reparsed_file:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.reparsed == "") {
            return inputs.sam_file.nameroot + ".reparsed.tsv";
          }
          else {
            return inputs.reparsed;
          }
        }
    label: "re-parsed parsed file"
