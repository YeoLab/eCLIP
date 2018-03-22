#!/bin/bash

###############################################################################
# cutadapt parameter generation
###############################################################################
#
# We need 4 inputs:
#
#   adpater5prime (20 bases long)
#   adpater3prime (34 bases long)
#   barcodeA      ( 7 bases long)
#   barcodeB      ( 7 bases long)
#
# We generate 3 parameters:
#
#   -g adapters to trim the upstream of read1
#   -a adapters to trim the downstream of read1
#   (-G adapters to trim the upstream of read2 IS NOT USED)
#   -A adapters to trim the downstream of read2
#
# Second barcode:
#
#   generation for only one out of 2 barcodes (barcodeA) is shown here
#   the -g sequence and the first seven -A sequences shown here for barcodeA
#   need the equivalent sequences for barcodeB
#
# Cartoon:
#
#
#           12345678901234567890  1234567        12345 123456789012345678901234
#    Read1: <---adpater5prime-->  <barcA>        <rdm> <-----adpater3prime---->
#
#                  -g 1234567890  1234567     -a NNNNN 123456789012345678901234
#
#
#           12345678901234567890  1234567        12345 123456789012345678901234
# RT_Read2: <---adpater5prime-->  <barcA>        <rdm> <-----adpater3prime---->
#
#           432109876543210987654321 54321       7654321 09876543210987654321
#    Read2: <-----emirp3retpada----> <mdr>       <Acrab> <--emirp5retpada--->
#
#                                       -G    -A 7654321 09876543
#                                              -A 654321 098765432
#                                               -A 54321 0987654321
#                                                -A 4321 09876543210
#                                                 -A 321 098765432109
#                                                  -A 21 0987654321098
#                                                   -A 1 09876543210987
#
#                                                    -A  098765432109876
#                                                     -A  987654321098765
#                                                      -A  876543210987654
#                                                       -A  765432109876543
#                                                        -A  654321098765432
#                                                         -A  543210987654321
#
# Unexplained observation:
#    the first 12 bases of rev-complement of adpater5prime match
#    the first 12 bases of adpater3prime
#
###############################################################################


# # Debugging settings
# ####################
# # exit immediately upon any error, output each line as it is executed
set -ex -o pipefail


## EXAMPLE verysmall.manifest
#############################
# (reads_files)             VERYSMALL_A_R1.fastq.gz;VERYSMALL_A_R2.fastq.gz;VERYSMALL_b_R1.fastq.gz;VERYSMALL_B_R2.fastq.gz
# (barcodea)                ACAAGTT
# (barcodeb)                TGGTCCT
# (adapter5prime)           ACACGACGCTCTTCCGATCT
# (adapter3prime)           AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
# (species)                 hg19
# (bio_repl_id)             222_01_HNRNPM
# (overlap_length_default)  1
# (overlap_length)          5
# (randommer_length)        5


# OUT #looping through multiple lines
#####################################
# while IFS=$'\t' read -r reads_files species bio_repl_id A_adapters overlap_length g_adapters randommer_length; do


###############################################################################
# parse input manifest
######################
#IFS=$'\t' read -r reads_files barcodea barcodeb adapter5prime adapter3prime species bio_repl_id overlap_length_default overlap_length randommer_length <  $1
#overlap_length_default=1
#echo
#printf "%b\n" "reads_files : ${reads_files}"
#printf "%b\n" "barcodea : ${barcodea}"
#printf "%b\n" "barcodeb : ${barcodeb} "
#printf "%b\n" "adapter5prime : ${adapter5prime}"
#printf "%b\n" "adapter3prime : ${adapter3prime}"
#printf "%b\n" "species : ${species}"
#printf "%b\n" "bio_repl_id : ${bio_repl_id}"
#printf "%b\n" "overlap_length_default : ${overlap_length_default}"
#printf "%b\n" "overlap_length : ${overlap_length}"
#printf "%b\n" "randommer_length : ${randommer_length}"



# HARD CODED VALUES
###################
#randommer_length=10
adapter5prime=ACACGACGCTCTTCCGATCT
adapter3prime=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
trimfirst_overlap_length=1      # this is a condatnt,
                           # but trimagain_overlap_length is calculated below

# VALUES PASSED BY CWL CALL
###########################
randommer_length=$1
yeolabbarcodesfasta=$2
barcodeida=$3
barcodeidb=$4


# TODO done here instead of in cwl InitialWorkDirRequirement
# TODO because toil does not support InitialWorkDirRequirement
# TODO can we get away without this ? commenting!
echo $barcodeida > $barcodeida
echo $barcodeidb > $barcodeidb

# fetch barcode sequences
##########################
# special case for NIL or RIL barcodeid, if barcodeida is NIL or RIL, barcodeidb is assumed NIL or RIL too
if [ "${barcodeida}" == NIL ] || [ "${barcodeida}" == RIL ]; then
  echo RIL > barcodea.fasta   # TODO only there, to look same as when barcodes are not RIL
  echo RIL > barcodeb.fasta   # TODO only there, to look same as when barcodes are not RIL
  titlea=RIL
  barcodea=
  titleb=RIL
  barcodeb=
  sizebarcodea=${#barcodea}
  sizebarcodeb=${#barcodeb}
else
grep -A 1 $barcodeida $yeolabbarcodesfasta > barcodea.fasta  # TODO is this used?
grep -A 1 $barcodeidb $yeolabbarcodesfasta > barcodeb.fasta  # TODO is this used?
{
  read -r titlea
  read -r barcodea
}  < barcodea.fasta
{
  read -r titleb
  read -r barcodeb
}  < barcodeb.fasta
titlea=${titlea:1}
titleb=${titleb:1}
fi
# size is 0 if barcodeid is NIL or RIL
sizebarcodea=${#barcodea}
sizebarcodeb=${#barcodeb}

echo
printf "%b\n" "titlea : ${titlea}"
printf "%b\n" "titleb : ${titleb}"
printf "%b\n" "barcodea : ${barcodea}"
printf "%b\n" "barcodeb : ${barcodeb}"
printf "%b\n" "sizebarcodea : ${sizebarcodea}"
printf "%b\n" "sizebarcodeb : ${sizebarcodeb}"


# trimagain_overlap_length should be the length of the longest barcode minus 2
# also should be at least 1 in case barcodes are empty
####################################################################
longestbarcodesize=$(( sizebarcodea > sizebarcodeb ? sizebarcodea : sizebarcodeb ))
trimagain_overlap_length=$((longestbarcodesize - 2))
trimagain_overlap_length=$(( trimagain_overlap_length > 0 ? trimagain_overlap_length : 5 ))
printf "%b\n" "trimagain_overlap_length : ${trimagain_overlap_length}"



printf "%b\n" "randommer_length : ${randommer_length}"
printf "%b\n" "adapter5prime : ${adapter5prime}"
printf "%b\n" "adapter3prime : ${adapter3prime}"


###############################################################################
## barcodes and adapters , and their rev-tr
###########################################
revtr_barcodea=`echo ${barcodea} | rev | tr ATGC TACG`
revtr_barcodeb=`echo ${barcodeb} | rev | tr ATGC TACG`
echo
printf "%b\n" "barcodea : ${barcodea}"
printf "%b\n" "barcodeb : ${barcodeb} "
printf "%b\n" "revtr_barcodea : ${revtr_barcodea}"
printf "%b\n" "revtr_barcodeb : ${revtr_barcodeb}"

revtr_adapter5prime=`echo ${adapter5prime} | rev | tr ATGC TACG`
revtr_adapter3prime=`echo ${adapter3prime} | rev | tr ATGC TACG`
echo
printf "%b\n" "adapter5prime : ${adapter5prime}"
printf "%b\n" "adapter3prime : ${adapter3prime}"
printf "%b\n" "revtr_adapter5prime : ${revtr_adapter5prime}"
printf "%b\n" "revtr_adapter3prime : ${revtr_adapter3prime}"


###############################################################################
# g_adapters generation
######################
#
# adapter5prime
# ACACGACGCTCTTCCGATCT
#
# adapter5prime_last10 barcodea
#           CTTCCGATCT ACAAGTT
#
# adapter5prime_last10 barcodeb
#           CTTCCGATCT TGGTCCT
#
# adapter5prime_last10           this one is for the input assuming no barcodes
#          CTTCCGATCT
#
###############################################################################

# IFS=';' read -r g_adapter_1 g_adapter_2 <<< ${g_adapters_seed}
# g_adapters="-g $g_adapter_1 -g $g_adapter_2"
# g_adapters= "${adapter_five_prime}${barcodea} ${adapter_five_prime}${barcodeb}"

if [ "${barcodeida}" == NIL ] || [ "${barcodeida}" == RIL ]; then
# if barcdoeida is NIL or RIL, then barcodeidb is assumed also NIL or RIL, and we want a single -g adapter
g_adapters_fasta=">adapter5prime\n${adapter5prime:10:20}\n"
else
g_adapters_fasta=">adapter5prime_barcodea\n${adapter5prime:10:20}${barcodea}\n>adapter5prime_barcodeb\n${adapter5prime:10:20}${barcodeb}\n"
fi
echo
printf "%b\n" "g_adapters_fasta : \n${g_adapters_fasta}"


###############################################################################
# a_adapters generation
#######################
#
# randommer_length times: 10
#
# 10_times_N adapter3prime
# NNNNNNNNNN AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
# NNNNNNNNNN AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
#
###############################################################################
#a_adapters=-a\ $(printf %${randommer_length}s | tr " " "N")${adapter_three_prime}
#a_adapters_fasta=-a\ $(printf %${randommer_length}s | tr " " "N")${adapter3prime}
a_adapters_fasta=">randommer_adapter3prime\n"$(printf %${randommer_length}s | tr " " "N")${adapter3prime}
if [ "${randommers_length}" = "0" ]; then
  a_adapters_fasta=""
fi
echo
printf "%b\n" "a_adapters_fasta : \n${a_adapters_fasta}"


###############################################################################
# A_adapters generation
#######################
#
#   C01                  D8f
#   barcodea :           barcodeb :
#   ACAAGTT              TGGTCCT
#   revtr_barcodea :     revtr_barcodeb :
#   AACTTGT              AGGACCA
#           revtr_adapter5prime
#           AGATCGGAAGAGCGTCGTGT
#                                AGATCGGAAGAGCGTCGTGT
# 0 AACTTGT AGATCGGA     AGGACCA AGATCGGA
# 1  ACTTGT AGATCGGAA     GGACCA AGATCGGAA
# 2   CTTGT AGATCGGAAG     GACCA AGATCGGAAG
# 3    TTGT AGATCGGAAGA     ACCA AGATCGGAAGA
# 4     TGT AGATCGGAAGAG     CCA AGATCGGAAGAG
# 5      GT AGATCGGAAGAGC     CA AGATCGGAAGAGC
# 6       T AGATCGGAAGAGCG     A AGATCGGAAGAGCG
#read -r barcodea
#           AGATCGGAAGAGCGTCGTGT
#
# 7         AGATCGGAAGAGCGT
# 8          GATCGGAAGAGCGTC
# 9           ATCGGAAGAGCGTCG
#10            TCGGAAGAGCGTCGT
#11             CGGAAGAGCGTCGTG
#12              GGAAGAGCGTCGTGT

#
#   A01                  B06
#   barcodea :           barcodeb :
#   AAGCAAT              GGCTTGT
#   revtr_barcodea :     revtr_barcodeb :
#   ATTGCTT              ACAAGCC
#           revtr_adapter5prime
#           AGATCGGAAGAGCGTCGTGT
#                                AGATCGGAAGAGCGTCGTGT
# 0 ATTGCTT AGATCGGA     ACAAGCC AGATCGGA
# 1  TTGCTT AGATCGGAA     CAAGCC AGATCGGAA
# 2   TGCTT AGATCGGAAG     AAGCC AGATCGGAAG
# 3    GCTT AGATCGGAAGA     AGCC AGATCGGAAGA
# 4     CTT AGATCGGAAGAG    AGCC AGATCGGAAGAG
# 5      TT AGATCGGAAGAGC     CC AGATCGGAAGAGC
# 6       T AGATCGGAAGAGCG     C AGATCGGAAGAGCG
#read -r barcodea
#           AGATCGGAAGAGCGTCGTGT
#
# 7         AGATCGGAAGAGCGT
# 8          GATCGGAAGAGCGTC
# 9           ATCGGAAGAGCGTCG
#10            TCGGAAGAGCGTCGT
#11             CGGAAGAGCGTCGTG
#12              GGAAGAGCGTCGTGT

###############################################################################
revtr_barcodea__revtr_adapter5prime=${revtr_barcodea}${revtr_adapter5prime}
echo "revtr_barcodea__revtr_adapter5prime : ${revtr_barcodea__revtr_adapter5prime}"
revtr_barcodeb__revtr_adapter5prime=${revtr_barcodeb}${revtr_adapter5prime}
echo "revtr_barcodeb__revtr_adapter5prime : ${revtr_barcodeb__revtr_adapter5prime}"
echo
#echo "A_adapters_seed :"
#A_adapters_seed=""


### THIS IS ASSUMING sizebarcodea == sizebarcodeb
#------------------------------------------------

# while shifting through entire barcodes, we want 2 seqs at each i iteration
for i in $( seq 0 $(( $sizebarcodea -1 )) )                                            # if barcode length is 7 , we want to loop from i=0 to i=6
do
  #echo "${revtr_barcodea__revtr_adapter5prime:${i}:15}"
  A_adapters_seed="${A_adapters_seed}${revtr_barcodea__revtr_adapter5prime:${i}:15};"   # zero based interval!
  #echo "${revtr_barcodeb__adapter3prime:${i}:15}"
  A_adapters_seed="${A_adapters_seed}${revtr_barcodeb__revtr_adapter5prime:${i}:15};"
done

# after shifting through entire barcodes, we want a single seq at each i iteration
# also we start collecting sequences for the input version (empty barcodes)
# we dont want anything shorter then 15, and adapter5prime is 20 long so we iterate 6 times
for i in {0..5}
do
  echo "${revtr_adapter5prime:${i}:15}"
  A_adapters_seed="${A_adapters_seed}${revtr_adapter5prime:${i}:15};"
  #A_adapters_input_seed="${A_adapters_input_seed}${revtr_adapter5prime:${i}:15};" #TODO redundant
done
# replace the ; chars with newlines chars
# ---------------------------------------
# A_adapters_seed0=`sed 's/\;/\n/g' <<< ${A_adapters_seed0}`
# A_adapters_seed0=`echo ${A_adapters_seed0} | tr ";" "\n"`
A_adapters_seed=`echo ${A_adapters_seed} | tr ";" "\n"`
#A_adapters_input_seed=`echo ${A_adapters_input_seed} | tr ";" "\n"`  #TODO redundant



# generating fasta file out of the seed string for A_adapters
# ------------------------------------------------------------
A_adapters=""
count=0
OLD_IFS=$IFS
while IFS=$'\t' read A_adapter; do
  A_adapters_fasta="${A_adapters_fasta}>A_adapter_${count}\n${A_adapter}\n"
  count=$(($count+1))
# done  <<<  "$A_adapters_seed0"
done  <<<  "$A_adapters_seed"
echo
IFS=$OLD_IFS
# printf "A_adapters_seed0 :\n${A_adapters_seed0}"
printf "A_adapters_seed :\n${A_adapters_seed}"
echo
printf "A_adapters_fasta : \n${A_adapters_fasta}"



#TODO redundant
# generating fasta file out of the seed string for A_adapters_input
#------------------------------------------------------------------
#A_adapters_input=""
#count=0
#OLD_IFS=$IFS
#while IFS=$'\t' read A_adapter_input; do
#  A_adapters_input_fasta="${A_adapters_input_fasta}>A_adapter_input_${count}\n${A_adapter_input}\n"
#  count=$(($count+1))
#done  <<<  "$A_adapters_input_seed"
#echo
#IFS=$OLD_IFS
#printf "A_adapters_input_seed :\n${A_adapters_input_seed}"
#echo
#printf "A_adapters_input_fasta : \n${A_adapters_input_fasta}"



# write output files
####################

echo "$trimfirst_overlap_length" > trimfirst_overlap_length.txt
echo "$trimagain_overlap_length" > trimagain_overlap_length.txt

echo -e "\n\n" > g_adapters_default.fasta
echo -e "\n\n" > a_adapters_default.fasta

echo -e $g_adapters_fasta > g_adapters.fasta
echo -e $a_adapters_fasta > a_adapters.fasta
echo -e $A_adapters_fasta > A_adapters.fasta

# echo -e $g_adapters_input_fasta > g_adapters_input.fasta      #TODO redundant
# echo -e $A_adapters_input_fasta > A_adapters_input.fasta    #TODO redundant


# Debugging settings:
#####################
# exit immediately upon any error, output each line as it is executed
set -ex


# OUT #looping through multiple lines
#####################################
#    done < manifest
