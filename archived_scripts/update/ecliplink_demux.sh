#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

LINKORCOPY="ln -s"
#LINKORCOPY="cp"


mkdir -p results/demux
cd results/demux



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

    $LINKORCOPY ${INTERMPATH}*r1.fq.gz   ./
    $LINKORCOPY ${INTERMPATH}*r2.fq.gz   ./

fi

# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
