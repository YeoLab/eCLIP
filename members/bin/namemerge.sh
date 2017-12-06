#!/usr/bin/env bash

function common_prefix() {
  local string1=$1
  local string2=$2
  local len=${#string1}
  local i
  for ((i=0; i<len; i++)); do
    if [[ "${string1:i:1}" == "${string2:i:1}" ]]; then
      continue
   else
      echo "${string1:0:i}"
      i=len
   fi
done
}
function common_suffix() {
  local rev1=$(echo ${1} | rev)
  local rev2=$(echo ${2} | rev)
  common_prefix $rev1 $rev2 | rev
}

function n_times_character(){
  local times=$1
  local character=$2
  printf %${times}s | tr " " "$character"
}

function namemerge(){
  local string1=$1
  local string2=$2
  local string3=$3
  local len1=${#string1}
  local len2=${#string2}
  local compref=$(common_prefix ${1} ${2})
  local comsuff=$(common_suffix ${1} ${2})
  local lenpref=${#compref}
  local lensuff=${#comsuff}
  local len3
  let  "len3 = $len1 - $lenpref -$lensuff"
  local middle=$(n_times_character $len3 $string3)
  echo "${compref}${middle}${comsuff}"
}



# example
#---------
#namemerge seqdata/SM_LIN28B_PHI_1_CLIP_R1_S32_L002_R1_001.fq.gz seqdata/SM_LIN28B_PHI_1_CLIP_R1_S32_L002_R2_001.fq.gz _

echo $(namemerge $1 $2 $3)
