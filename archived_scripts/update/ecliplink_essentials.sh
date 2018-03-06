#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

LINKORCOPY="ln -s"
#LINKORCOPY="cp"


mkdir -p results/essentials
cd results/essentials


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


    $LINKORCOPY ${INTERMPATH}*V2Cl.bed   ./
    #$LINKORCOPY ${INTERMPATH}*NpCo.bed     ./
    $LINKORCOPY ${INTERMPATH}*An.bed    ./
    $LINKORCOPY ${INTERMPATH}*Fc?Pv?.bed  ./


fi


# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
