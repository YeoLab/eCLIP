#!/usr/bin/env cwltool

cwlVersion: v1.0

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:

  prefix:
    type: string

  rep_s:
    type: File[]

  rmrep_s:
    type: File[]


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

