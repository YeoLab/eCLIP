#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    #tmpdirMin: 4000
    #outdirMin: 4000



baseCommand: [parsespecies.sh]

#$namespaces:
#  ex: http://example.com/

#hints:
  #- class: FileRequirement
  #  fileDef:
  #    - singularityexec: $(inputs.singularityexec)
#  - class: ex:PackageRequirement
#    packages:
#      - name: tree
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  ####################
  #bindir:
  #  type: Directory
  #  default:
  #    class: Directory
  #    location: bin
  ####################

  species:
    type: string
    default: hg19
    inputBinding:
      position: 1
    doc: "species: one of ce10 ce11 dm3 RCh38 mm9 mm10"

#  eclipreferencetar:
#    type: File
#    inputBinding:
#      position: 2

outputs:

  chromsizes:
    type: File
    outputBinding:
      glob: $(inputs.species).chrom.sizes

  starrefrepeats:
    type: File
    outputBinding:
      glob: $(inputs.species)_repbase_starindex.tar

  starrefgenome:
    type: File
    outputBinding:
      glob: $(inputs.species)_starindex.tar

  annotateref:
    type: File
    outputBinding:
      glob: $(inputs.species).annotation.gtf.db
