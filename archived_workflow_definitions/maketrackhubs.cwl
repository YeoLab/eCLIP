#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000


# example
#########
# make_trackhubs.py --hub 20160301_example --genome hg19 *.bw


# baseCommand: [maketrackhubs2]
baseCommand: [fix_ld_library_path, maketrackhubs2]


arguments: [
  --hub,    $(inputs.dataset)$(inputs.name),
  --genome, $(inputs.dataset)$(inputs.name)$(inputs.species)
  ]


#  --email,  "adomissy@ucsd.edu",
#  --user,   adomissy,
#  --serverscp,  tscc-dm1.sdsc.edu,

# --no_s3.
# --serverscp, localhost,
# --user, adomissy,
#  --user,   "adomissy@ucsd.edu",
# --server, "https://s3-us-west-1.amazonaws.com/yeo-trackhubs/",
# --server, sauron.ucsd.edu,



inputs:

  dataset:
    type: string

  name:
    type: string

  species:
    type: string

  posbw:
    type: File
    inputBinding:
      position: -3

  negbw:
    type: File
    inputBinding:
      position: -2

  input_bigbed:
    type: File
    inputBinding:
      position: -1

outputs:

  trackdbtxt:
    type: File
    outputBinding:
      #glob:  $(inputs.dataset)$(inputs.name)$(inputs.species)/trackDb.txt
      # TODO $(inputs.dataset)$(inputs.name) is lost, how come ?
      glob:  $(inputs.species)/trackDb.txt

      ##### TEMPORARY HACK FOR TUTORIAL hg19chr19kbp555 ####
      #glob: hg19/trackDb.txt


  hubtxt:
    type: File
    outputBinding:
      #glob: $(inputs.dataset)$(inputs.name).hub.txt
      # TODO $(inputs.dataset) is lost, how come ?
      glob: $(inputs.name).hub.txt

  genomestxt:
    type: File
    outputBinding:
      #glob: $(inputs.dataset)$(inputs.name).genomes.txt
      # TODO $(inputs.dataset) is lost, how come ?
      glob: $(inputs.name).genomes.txt

  pos_bw:
    type: File
    outputBinding:
      glob:  $(inputs.posbw.nameroot).pos.bw

  neg_bw:
    type: File
    outputBinding:
      glob:  $(inputs.negbw.nameroot).neg.bw

  output_bigbed:
    type: File
    outputBinding:
      glob:  $(inputs.input_bigbed.nameroot).bb
