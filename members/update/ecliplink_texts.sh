#!/usr/bin/env bash

mkdir -p results/logs



cd results/logs

# pattern path to all intermediates directories under interm
INTERMPATH=../../.tmp/cwltool_interm/*/

nbfiles=$(ls ${INTERMPATH}*.fastq 2> /dev/null | wc -l)
if [ "$nbfiles" != "0" ]
then
  #ln -s ${INTERMPATH}*.fastq ./
  true
fi


nbfiles=$(ls ${INTERMPATH}*.fq 2> /dev/null | wc -l)
if [ "$nbfiles" != "0" ]
then
  #ln -s ${INTERMPATH}*.fq ./
  true
fi


nbfiles=$(ls ${INTERMPATH}*.bed 2> /dev/null | wc -l)
if [ "$nbfiles" != "0" ]
then
  #ln -s ${INTERMPATH}*.bed ./
  true
fi




nbfiles=$(ls ${INTERMPATH}*.metrics 2> /dev/null | wc -l)
if [ "$nbfiles" != "0" ]
then
  #ln -s ${INTERMPATH}*.metrics ./
  true
fi


nbfiles=$(ls ${INTERMPATH}*.log 2> /dev/null | wc -l)
if [ "$nbfiles" != "0" ]
then
  #ln -s ${INTERMPATH}*.log ./
  cp ${INTERMPATH}*.log ./
fi




# remove erratic empty files due to cp withoit source available
#rm ./\**
cd ../..
