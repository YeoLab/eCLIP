#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

LINKORCOPY="ln -s"
#LINKORCOPY="cp"


mkdir -p results/geo
cd results/geo


UPDATEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cp -r ${UPDATEDIR}/TEMPLATE_GEO_SUBMISSION.xls ./



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

    #$LINKORCOPY ${INTERMPATH}*r1.fq.gz   ./
    #$LINKORCOPY ${INTERMPATH}*r2.fq.gz   ./

    $LINKORCOPY ${INTERMPATH}*V2.negbw   ./
    $LINKORCOPY ${INTERMPATH}*V2.posbw   ./
    $LINKORCOPY ${INTERMPATH}*V2Cl.bed   ./
    $LINKORCOPY ${INTERMPATH}*FiSo.bigbed   ./


fi


# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
