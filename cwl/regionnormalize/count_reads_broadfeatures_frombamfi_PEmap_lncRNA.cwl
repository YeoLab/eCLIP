#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

baseCommand: [count_reads_broadfeatures_frombamfi_PEmap_lncRNA.pl]

inputs:

  clipBamFile:
    type: File
    inputBinding:
      position: 1
    label: "BAM File"
    doc: "BAM File"
  gencodeGTFFile:
    type: File
    inputBinding:
      position: 2
    label: "gencode GTF file"
    doc: "gencode GTF file"
  gencodeTableBrowserFile:
    type: File
    inputBinding:
      position: 3
    label: "gencode parsed ucsc tableformat file"
    doc: "gencode parsed ucsc tableformat file"
  trna_bed_file:
    type: File
    inputBinding:
      position: 4
  lncrna_table_file:
    type: File
    inputBinding:
      position: 5
  lncrna_full_file:
    type: File
    inputBinding:
      position: 6
  output:
    default: ""
    type: string
    inputBinding:
      position: 7
      valueFrom: |
        ${
          if (inputs.output == "") {
            return inputs.clipBamFile.nameroot + ".broadfeatures.tsv";
          }
          else {
            return inputs.output;
          }
        }
    label: "output file"
    doc: "output file"

outputs:
  outputFile:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output == "") {
            return inputs.clipBamFile.nameroot + ".broadfeatures.tsv";
          }
          else {
            return inputs.output;
          }
        }
