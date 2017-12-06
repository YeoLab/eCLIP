#!/usr/bin/env bash


set -x

CWLTOOLORCWLTOIL=$1
echo CWLTOOLORCWLTOIL: $CWLTOOLORCWLTOIL

LINKORCOPY="ln -s"
#LINKORCOPY="cp"


mkdir -p results/finals
cd results/finals



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

    $LINKORCOPY ${INTERMPATH}*V2.bam            ./
    $LINKORCOPY ${INTERMPATH}*V2.???.bw         ./

    $LINKORCOPY ${INTERMPATH}*Cl.bed            ./
    $LINKORCOPY ${INTERMPATH}*ClFiSo.bb         ./


    #$LINKORCOPY ${INTERMPATH}*Np.bed           ./
    $LINKORCOPY ${INTERMPATH}*Np.full.bed       ./
    $LINKORCOPY ${INTERMPATH}*NpCo.bed          ./
    $LINKORCOPY ${INTERMPATH}*An.bed        ./
    $LINKORCOPY ${INTERMPATH}*Fc?Pv?.bed        ./


    ## OLD PERL VERSIONS
    #$LINKORCOPY ${INTERMPATH}*No.bed           ./
    #$LINKORCOPY ${INTERMPATH}*No.full.bed      ./
    #$LINKORCOPY ${INTERMPATH}*NoCo.bed         ./
    #$LINKORCOPY ${INTERMPATH}*NoCoAn.bed       ./
    #$LINKORCOPY ${INTERMPATH}*NoCoFc?Pv?.bed   ./


    #$LINKORCOPY ${INTERMPATH}*.DistFig.svg       ./
    #$LINKORCOPY ${INTERMPATH}*.qc_fig.svg        ./
    #$LINKORCOPY ${INTERMPATH}*204_01.metrics     ./

    ##$LINKORCOPY ${INTERMPATH}*OVER.*.bed       ./
    ##$LINKORCOPY ${INTERMPATH}*.OVER.*.full.bed ./


fi

# remove erratic empty files due to cp without source available
rm -f ./\**

cd ../..


#
#mkdir -p results/finals_decoded
#cd results/finals_decoded
#
#
#cd -


set +x
