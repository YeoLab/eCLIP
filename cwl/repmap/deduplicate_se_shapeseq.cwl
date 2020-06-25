#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 4
    ramMin: 64000

baseCommand: [duplicate_removal_inline_paired_count_region_other_reads_SE_shapeseq.pl]

inputs:

  repFamilySam:
    type: File
    inputBinding:
      position: 1
    label: "input"
    doc: "input sam file"

  rmRepSam:
    type: File
    inputBinding:
      position: 2
    label: "rmRep.sam alignment file"
    doc: "rmRep sam alignment file"

  gencodeGTF:
    type: File
    inputBinding:
      position: 3
    label: "gencode GTF File"
    doc: "gencode GTF File"

  gencodeTableBrowser:
    type: File
    inputBinding:
      position: 4
    label: "gencode GTF file in UCSC table browser format"
    doc: "gencode GTF file in UCSC table browser format"

  repMaskBedFile:
    type: File
    inputBinding:
      position: 5
    label: "repeatmasker bedfile"
    doc: "bedfile of repeat regions"

  fileList1:
    type: File
    inputBinding:
      position: 6
    doc: "tsv with 5 fields: ENST/ENSG/name/chrom/genelist.file"

  fileList2:
    type: File
    inputBinding:
      position: 7
    doc: "tsv with 5 fields: name/type/type/type/desc"


outputs:

  deduplicatedRmDupSam:
    type: File
    outputBinding:
      glob: "*combined_w_uniquemap.rmDup.sam"
    label: "combined unique mapping + rep element mapping sam"

  deduplicatedPreRmDupSam:
    type: File
    outputBinding:
      glob: "*combined_w_uniquemap.prermDup.sam"
    label: "combined unique mapping + rep element mapping sam before rmdup"

  parsedFile:
    type: File
    outputBinding:
      glob: "*combined_w_uniquemap.rmDup.sam.parsed"
    label: "combined unique mapping + rep element mapping sam"

  doneFile:
    type: File
    outputBinding:
      glob: "*combined_w_uniquemap.rmDup.sam.parsed.done"
    label: "done file"