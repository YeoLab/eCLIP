#!/usr/bin/env cwltool

cwlVersion: v1.0

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 1000

inputs:

  prefix:
    type: string
    doc: 'First two letters of barcode ID (AA, AC, ..., NN)'
  rep_s:
    type: File[]
    doc: 'List of repetitive element-mapped sam-like files, split by prefix'
  rmrep_s:
    type: File[]
    doc: 'List of remove-rep BAM files, split by prefix'

outputs:

  prefixrep:
    type: File
  prefixrmrep:
    type: File

expression: |
   ${
      var prefix = inputs.prefix;
      var rep_s = inputs.rep_s;
      var rmrep_s = inputs.rmrep_s;

      var prefixrep = '';
      var prefixrmrep = '';

      for (var i = 0; i < rep_s.length; i++) {
        if (rep_s[i].basename.indexOf(prefix) == 0) {
          prefixrep = rep_s[i];
        }
        if (rmrep_s[i].basename.indexOf(prefix) == 0) {
          prefixrmrep = rmrep_s[i];
        }
      }
      return {'prefixrep': prefixrep, 'prefixrmrep': prefixrmrep}
    }

