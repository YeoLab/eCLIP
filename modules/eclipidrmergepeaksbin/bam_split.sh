#!/usr/bin/env bash


set -o xtrace
set -o errexit


BAM=${1}
SPLIT1=${2}
SPLIT2=${3}

# Number of reads in the tagAlign file
NLINES=$(samtools view ${BAM} | wc -l | cut --fields=1 --delimiter=\  )
HALFNLINES=$(( ${NLINES} / 2 ))


# This will shuffle the lines in the file and split it into two parts
samtools view ${BAM} | shuf | split -d -l ${HALFNLINES} - ${BAM}


#split and remake bam file
samtools view -H ${BAM} | cat - ${BAM}00 | samtools view -bS - > ${BAM}00.bam
samtools view -H ${BAM} | cat - ${BAM}01 | samtools view -bS - > ${BAM}01.bam


#sort remade bam file, can't combine due to race condition for viewing and sorting
samtools sort ${BAM}00.bam -o ${SPLIT1}
samtools sort ${BAM}01.bam -o ${SPLIT2}