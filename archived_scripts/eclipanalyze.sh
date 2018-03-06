#!/bin/bash

mkdir -p eclipanalyze/inputs

#
#

#

INTERMPATH=tmp/cwltool_interm/*/

cp -n ${INTERMPATH}*MeV2.bam eclipanalyze/inputs/                                  # TODO remove Me
cp -n ${INTERMPATH}*NoCo.bed eclipanalyze/inputs/

cp $ECLIP_HOME/init/TEMPLATE.eclipanalyze.eclip eclipanalyze/
# remove erratic empty files due to cp withoit source available
#rm ./\**


#cp -r eclipanalyze/*/tmp/cwltool_interm/*  ./tmp/
#cp -r eclipanalyze/*/tmp/cwltool_interm/*  ./tmp/cwltool_interm/
#

