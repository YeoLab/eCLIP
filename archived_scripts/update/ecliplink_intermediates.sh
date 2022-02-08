#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

LINKORCOPY="ln -s"
#LINKORCOPY="cp"


mkdir -p results/intermediates
cd results/intermediates


if [ -n $CWLTOOLORCWLTOIL ]
then


    # pattern path to all intermediates directories under interm
    if [ $CWLTOOLORCWLTOIL = cwltool ]
    then
      INTERMPATH=../../.tmp/cwltool_interm/*/
    fi
    if [ $CWLTOOLORCWLTOIL = cwltoil ]
    then
      INTERMPATH=../../.tmp/outdir/*/
    fi


    # link or copy anything with 3 or more dots in filename
    $LINKORCOPY ${INTERMPATH}*.*.*.* ./


fi


# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
