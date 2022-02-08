#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool

baseCommand: [split_bam_to_subfiles.pl]

requirements:
  - class: InlineJavascriptRequirement

inputs:

  sam:
    type: File
    inputBinding:
      position: 1

outputs:

  repsam_s:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.tmp"

#  samsrecord:
#    type:
#      type: record
#      fields:
#
#        AA:
#          type: File
#          outputBinding:
#            glob: "AA.*.tmp"
#        AC:
#          type: File
#          outputBinding:
#            glob: "AC.*.tmp"
#        AG:
#          type: File
#          outputBinding:
#            glob: "AG.*.tmp"
#        AT:
#          type: File
#          outputBinding:
#            glob: "AT.*.tmp"
#        AN:
#          type: File
#          outputBinding:
#            glob: "AN.*.tmp"
#
#        CA:
#          type: File
#          outputBinding:
#            glob: "CA.*.tmp"
#        CC:
#          type: File
#          outputBinding:
#            glob: "CC.*.tmp"
#        CG:
#          type: File
#          outputBinding:
#            glob: "CG.*.tmp"
#        CT:
#          type: File
#          outputBinding:
#            glob: "CT.*.tmp"
#        CN:
#          type: File
#          outputBinding:
#            glob: "CN.*.tmp"
#
#        GA:
#          type: File
#          outputBinding:
#            glob: "GA.*.tmp"
#        GC:
#          type: File
#          outputBinding:
#            glob: "GC.*.tmp"
#        GG:
#          type: File
#          outputBinding:
#            glob: "GG.*.tmp"
#        GT:
#          type: File
#          outputBinding:
#            glob: "GT.*.tmp"
#        GN:
#          type: File
#          outputBinding:
#            glob: "GN.*.tmp"
#
#        TA:
#          type: File
#          outputBinding:
#            glob: "TA.*.tmp"
#        TC:
#          type: File
#          outputBinding:
#            glob: "TC.*.tmp"
#        TG:
#          type: File
#          outputBinding:
#            glob: "TG.*.tmp"
#        TT:
#          type: File
#          outputBinding:
#            glob: "TT.*.tmp"
#        TN:
#          type: File
#          outputBinding:
#            glob: "TN.*.tmp"
#
#        NA:
#          type: File
#          outputBinding:
#            glob: "NA.*.tmp"
#        NC:
#          type: File
#          outputBinding:
#            glob: "NC.*.tmp"
#        NG:
#          type: File
#          outputBinding:
#            glob: "NG.*.tmp"
#        NT:
#          type: File
#          outputBinding:
#            glob: "NT.*.tmp"
#        NN:
#          type: File
#          outputBinding:
#            glob: "NN.*.tmp"
