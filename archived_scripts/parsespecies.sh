#!/bin/bash

# Debugging settings
# ####################

# Print commands and their arguments as they are executed.
set -x

#Exit immediately if a command exits with a non-zero status.
set -e

#the return value of a pipeline is the status of
#the last command to exit with a non-zero status,
#or zero if no command exited with a non-zero status
set -o pipefail





# locate input speciesfile
##########################

# get this script's full directory name no matter where it is being called from
THISSCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#REFDIR=$THISSCRIPTDIR/parser
REFDIR=$THISSCRIPTDIR/../eclipref
#REFDIR=${HOME}/eclipref
echo "REFDIR is $REFDIR"

# echo "ECLIPREF is $ECLIPREF"
#REFDIR=$ECLIPREF
echo "ls -l $REFDIR"
ls -l $REFDIR

SPECIES=$1
SPECIESREFSFILE=$REFDIR/$SPECIES.refs
cat $SPECIESREFSFILE




# parse species refs file
#########################

OLD_IFS=$IFS

IFS=$'\t' read -r chromsizes_filename starrefrepeats_filename starrefgenome_filename annotateref_filename <  $SPECIESREFSFILE
IFS=$OLD_IFS
echo
printf "%b\n" "chromsizes_filename :     ${chromsizes_filename} "
printf "%b\n" "starrefrepeats_filename : ${starrefrepeats_filename}"
printf "%b\n" "starrefgenome_filename :  ${starrefgenome_filename}"
printf "%b\n" "annotateref_filename :    ${annotateref_filename}"
echo



# write output files
####################

ls -lh .

#echo "cp $REFDIR/$chromsizes_filename ${SPECIES}.chrom.sizes"
cp $REFDIR/$chromsizes_filename ${SPECIES}.chrom.sizes
#echo "cp $REFDIR/$starrefrepeats_filename ${SPECIES}_repbase_starindex.tar"
cp $REFDIR/$starrefrepeats_filename ${SPECIES}_repbase_starindex.tar
#echo "cp $REFDIR/$starrefgenome_filename ${SPECIES}_starindex.tar"
cp $REFDIR/$starrefgenome_filename ${SPECIES}_starindex.tar
#echo "cp $REFDIR/$annotateref_filename ${SPECIES}.annotation.gtf.db"
cp $REFDIR/$annotateref_filename ${SPECIES}.annotation.gtf.db

ls -lh .

set +x
