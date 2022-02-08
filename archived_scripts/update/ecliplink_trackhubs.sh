#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

#LINKORCOPY="ln -s"
LINKORCOPY="cp -r"


mkdir -p results/trackhubs
cd results/trackhubs



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


   $LINKORCOPY ${INTERMPATH}trackhubs_upload_dir/*     ./

    #$LINKORCOPY ${INTERMPATH}*/trackDb.txt  ./

    #$LINKORCOPY ${INTERMPATH}*.genomes.txt  ./
    #$LINKORCOPY ${INTERMPATH}*.hub.txt      ./

    #$LINKORCOPY ${INTERMPATH}*.pos.bw       ./
    #$LINKORCOPY ${INTERMPATH}*.neg.bw       ./
    #$LINKORCOPY ${INTERMPATH}*.bb           ./


fi



# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..

set +x
