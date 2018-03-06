#!/usr/bin/env bash

mkdir -p legacy/intermediates.LKS   legacy/finals.LKS   legacy/textfiles.LKS   legacy/metricsfiles.LKS
rm       legacy/intermediates.LKS/* legacy/finals.LKS/* legacy/textfiles.LKS/* legacy/metricsfiles.LKS/*


cd legacy/intermediates.LKS
############################
ln -s ../../../MASTER.LKS/*/06_*/*sorted.bai     ./
ln -s ../../../MASTER.LKS/*/06_*/*sorted.bam.bai ./

ln -s ../../../MASTER.LKS/*.fastq.gz ./
ln -s ../../../MASTER.LKS/*.txt ./
cd ../..


cd legacy/finals.LKS
####################
ln -s ../../../MASTER.LKS/*/11_*/*.bb           ./
ln -s ../../../MASTER.LKS/*/10_*/*.svg          ./
ln -s ../../../MASTER.LKS/*/10_*/*.pickle       ./
ln -s ../../../MASTER.LKS/*/09_*/*peaks.bed*    ./
ln -s ../../../MASTER.LKS/*/08_*/*norm.*.bw     ./
ln -s ../../../MASTER.LKS/*/08_*/*r2.bam           ./
ln -s ../../../MASTER.LKS/*/08_*/*r2.bam.bai       ./

cd ../..


cd legacy/textfiles.LKS
#######################
ln -s ../../../MASTER.LKS/*/*/*.bamLog.final.out ./
ln -s ../../../MASTER.LKS/*/*/*.metrics        ./
ln -s ../../../MASTER.LKS/*/*/*.pickle         ./
ln -s ../../../MASTER.LKS/*/*/*.bed            ./
ln -s ../../../MASTER.LKS/*.txt                ./
cd ../..


cd legacy/metricsfiles.LKS
##########################
ln -s ../../../MASTER.LKS/*/*/*.bamLog.final.out ./
ln -s ../../../MASTER.LKS/*/*/*.metrics        ./
ln -s ../../../MASTER.LKS/*.txt                ./
cd ../..

