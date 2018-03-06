#!/usr/bin/env bash

set -o xtrace
set -o errexit

# disable this as ${8} will be unset when option dorepmap is disabled
#set -o nounset


SPECIES=${1}
DOREPMAP=${8}


touch 1.2.3.barcode1concatenatedRmDupSam
touch 1.2.3.barcode2concatenatedRmDupSam
touch 1.2.3.concatenatedRmDupSam,
touch 1.2.3.barcode1concatenatedPreRmDupSam
touch 1.2.3.barcode2concatenatedPreRmDupSam
touch 1.2.3.concatenatedPreRmDupSam
touch 1.2.3.combinedParsed


if [[ "${SPECIES}" = "hg19" || "${SPECIES}" = "hg19chr19kbp550" ]]
then

    if [[ "${DOREPMAP}" = "--dorepmap" ]]
    then

        cp $2 $3 $4 $5 $6 $7 ./

        barcode1r1FastqGz=$(basename $2)
        barcode1r2FastqGz=$(basename $3)
        barcode1rmRepBam=$(basename $4)
        barcode2r1FastqGz=$(basename $5)
        barcode2r2FastqGz=$(basename $6)
        barcode2rmRepBam=$(basename $7)

        wf_ecliprepmap.cwl \
            --barcode1r1FastqGz ${barcode1r1FastqGz} \
            --barcode1r2FastqGz ${barcode1r2FastqGz} \
            --barcode1rmRepBam  ${barcode1rmRepBam}  \
            --barcode2r1FastqGz ${barcode2r1FastqGz} \
            --barcode2r2FastqGz ${barcode2r2FastqGz} \
            --barcode2rmRepBam  ${barcode2rmRepBam}
             #>  wf_ecliprepmap.cwl.cmd
    fi
fi

