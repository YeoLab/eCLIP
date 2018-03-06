#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset


  cp $1 $2 $3 $4 ./

  bam_rep1=$(basename $1)
  bam_rep2=$(basename $2)
  bam_input1=$(basename $3)
  bam_input2=$(basename $4)
  species=${5}

  touch empty.empty.empty.bam_rep1
  touch empty.empty.empty.bam_rep2
  touch empty.empty.empty.bam_input1
  touch empty.empty.empty.bam_input2

  #wf_selfconsistencyratio.cwl \
  wf_bam_split_crpc_vs_bam_split_crpc.cwl \
      --bam_rep1   ${bam_rep1} \
      --bam_rep2   ${bam_rep2} \
      --bam_input1 ${bam_input1} \
      --bam_input2 ${bam_input2} \
      --species    ${species} \
      > 1.2.3.selfconsistencyratio.txt

