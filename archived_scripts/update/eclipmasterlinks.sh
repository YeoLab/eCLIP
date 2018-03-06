#!/usr/bin/env bash


echo ==========================================================================
echo sourcing eclipmasterlinks env
echo ==========================================================================

source ./eclipmasterlinks.env

echo ENCODESPLIT           $ENCODESPLIT
echo NONENCODESPLIT        $NONENCODESPLIT

echo ENCODESPLITMETRICS    $ENCODESPLITMETRICS
echo NONENCODESPLITMETRICS $NONENCODESPLITMETRICS

echo ENCODEMASTER          $ENCODEMASTER
echo NONENCODEMASTER       $NONENCODEMASTER

echo SPLIT          $SPLIT
echo SPLIMETRICS    $SPLIMETRICS
echo MASTER     # TODO order below is important!      $MASTER

echo ENCODEPREFIX   $ENCODEPREFIX
echo ENCODEPREFIX2  $ENCODEPREFIX2

echo BARCODELIST    $BARCODELIST
echo ENCODEIDLIST   $ENCODEIDLIST

echo ==========================================================================

mkdir -p DEMUXED.LKS

mkdir -p MASTER.LKS
cd MASTER.LKS

ls -1 ${SPLIT}/${ENCODEPREFIX}*          #preview
if [[ ${ENCODEPREFIX} ]]
then
  ln -s ${SPLIT}/${ENCODEPREFIX}*        ./
fi
ls -1 ${SPLITMETRICS}/${ENCODEPREFIX}*   #preview
if [[ ${SPLITMETRICS} ]]
then
  ln -s ${SPLITMETRICS}/${ENCODEPREFIX}* ./
fi

ls -1 ${MASTER}/${ENCODEPREFIX}*         #preview
if [[ ${ENCODEPREFIX} ]]
then
  ln -s ${MASTER}/${ENCODEPREFIX}*       ./
fi
if [[ ${ENCODEPREFIX2} ]]
then
  ln -s ${MASTER}/${ENCODEPREFIX2}*      ./
fi

function mkbarcodelinks(){
  BARCODE=${1}
  echo now creating directories for barcode $BARCODE

  mkdir -p ${BARCODE}
  cd ${BARCODE}
  mkdir -p 00_fastqc 01_trim 02_trimagain 03_maprep 04_mapagain 05_rmdup 06_sortindex
  mkdir -p semifinals/08_r2bw semifinals/09_peaks semifinals/10_peaksanalysis semifinals/11_peaksfixedbb

  # TODO order below is important!

  #------------ 08 to 11 are finals-ish,  before: barcoded files before merge !
  mv ../${ENCODEPREFIX}*${BARCODE}*peaks.fixed*   ./semifinals/11_peaksfixedbb

  mv ../${ENCODEPREFIX}*${BARCODE}*clip_analysis* ./semifinals/10_peaksanalysis
  mv ../${ENCODEPREFIX}*${BARCODE}*svg            ./semifinals/10_peaksanalysis
  mv ../${ENCODEPREFIX}*${BARCODE}*peaks.bed_*    ./semifinals/10_peaksanalysis

  mv ../${ENCODEPREFIX}*${BARCODE}*peaks.bed*     ./semifinals/09_peaks
  mv ../${ENCODEPREFIX}*${BARCODE}*peaks.metrics* ./semifinals/09_peaks

  mv ../${ENCODEPREFIX}*${BARCODE}*r2.neg*        ./semifinals/08_r2bw
  mv ../${ENCODEPREFIX}*${BARCODE}*r2.norm*       ./semifinals/08_r2bw
  mv ../${ENCODEPREFIX}*${BARCODE}*r2.pos*        ./semifinals/08_r2bw
  mv ../${ENCODEPREFIX}*${BARCODE}*sorted.r2.bam* ./semifinals/08_r2bw
  #----------------------------------------------------------------------------

  mv ../${ENCODEPREFIX}*${BARCODE}*sorted.ba*     ./06_sortindex
  mv ../${ENCODEPREFIX}*${BARCODE}*rmDup*         ./05_rmdup
  mv ../${ENCODEPREFIX}*${BARCODE}*rmRep*         ./04_mapagain
  mv ../${ENCODEPREFIX}*${BARCODE}*rep*           ./03_maprep
  mv ../${ENCODEPREFIX}*${BARCODE}*round2.*       ./02_trimagain
  mv ../${ENCODEPREFIX}*${BARCODE}*adapterTrim*   ./01_trim

  mv ../${ENCODEPREFIX}*${BARCODE}*_fastqc        ./00_fastqc
  mv ../${ENCODEPREFIX}*${BARCODE}*_fastqc.html   ./00_fastqc
  mv ../${ENCODEPREFIX}*${BARCODE}*_fastqc.zip    ./00_fastqc

  cp ../${ENCODEPREFIX}*${BARCODE}*fastq.gz       ../../DEMUXED.LKS
  mv ../${ENCODEPREFIX}*${BARCODE}*fastq.gz       ./

  cd -
  echo ""
}


function mkencodeidlinks(){
  ENCODEID=${1}
  echo now creating directories for encodeid $ENCODEID

  mkdir -p ${ENCODEID}
  cd ${ENCODEID}
  mkdir -p 07_merged 08_r2bw 09_peaks 10_peaksanalysis 11_peaksfixedbb

  # TODO order below is important!

  mv ../${ENCODEID}*merged*peaks.fixed*   ./11_peaksfixedbb

  mv ../${ENCODEID}*merged*clip_analysis* ./10_peaksanalysis
  mv ../${ENCODEID}*merged*svg            ./10_peaksanalysis
  mv ../${ENCODEID}*merged*peaks.bed_*    ./10_peaksanalysis

  mv ../${ENCODEID}*merged*peaks.bed*     ./09_peaks
  mv ../${ENCODEID}*merged*peaks.metrics* ./09_peaks

  mv ../${ENCODEID}*merged*r2.neg*        ./08_r2bw
  mv ../${ENCODEID}*merged*r2.norm*       ./08_r2bw
  mv ../${ENCODEID}*merged*r2.pos*        ./08_r2bw
  mv ../${ENCODEID}*merged.r2.bam*        ./08_r2bw

  mv ../${ENCODEID}*merged.ba*            ./07_merged

  cd -
  echo ""
}


## another way of doing this
## declare an array variable
#declare -a BARCODESARRAY=("A03" "A04" "F05" "G07" "unassigned")
#for IDX in ${BARCODESARRAY[@]}
#do
#  echo mk_barcode_dir ${BARCODESARRAY[$IDX]}
#done


for BC in ${BARCODELIST}
do
  mkbarcodelinks ${BC}
done

for EID in ${ENCODEIDLIST}
do
  mkencodeidlinks ${EID}
done

