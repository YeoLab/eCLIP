#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

#LINKORCOPY="ln -s"
LINKORCOPY="cp"


mkdir -p qc
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


    $LINKORCOPY ${INTERMPATH}*.*.*ratio.txt ../../qc/

fi


# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
