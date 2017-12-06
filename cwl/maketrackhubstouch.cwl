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

baseCommand: [maketrackhubstouch]
baseCommand: [maketrackhubstouch]

arguments: [
  --hub,    $(inputs.dataset)_$(inputs.name),
  --genome, $(inputs.dataset)_$(inputs.name)_$(inputs.species),
  --email,  "adomissy@ucsd.edu",
  --user,    adomissy,
  --serverscp,  localhost,
  --serverweb,  alaindomissy.github.io,
  --no_s3,
  --upload_dir, ECLIP_TRACKHUBS_FOR_UPLOAD
  ]




# --no_s3,                    # TDO replace with: --localserver

# --user, adomissy,
# --serverscp,  127.0.0.1
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
      position: -2

  negbw:
    type: File
    inputBinding:
      position: -1

outputs:

  trackdbtxt:
    type: File
    outputBinding:
      #glob:  $(inputs.dataset)$(inputs.name)$(inputs.species)/trackDb.txt
      # TODO $(inputs.dataset)$(inputs.name) is lost, how come ?
      ##### TEMPORARY ####
      glob:  $(inputs.species)/trackDb.txt
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
