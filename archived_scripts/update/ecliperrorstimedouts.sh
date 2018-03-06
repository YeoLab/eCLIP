#!/usr/bin/env bash

mkdir -p errors

#grep 'gene timed out\|job X_clipper_*keydictstr\|job X_clipper_*keydictstr' ./ECLIP-JOB-LOG.txt > logtimedouts_full.txt

grep 'gene timed out\|job X_clipper] keydictstr\|job X_clipper_.] keydictstr\|job X_clipper_..] keydictstr' ./ECLIP-JOB-LOG.txt > errors/timedouts_full.txt
grep                 'job X_clipper] keydictstr\|job X_clipper_.] keydictstr\|job X_clipper_..] keydictstr' ./ECLIP-JOB-LOG.txt > errors/timedouts_samples_.txt
grep 'gene timed out'                                                                                       ./ECLIP-JOB-LOG.txt > errors/timedouts_genes_.txt

cat errors/timedouts_full.txt

#NUMBEROFGENESTIMEDOUT=`cat logtimedouts_full.txt | wc -l`
#echo $NUMBEROFGENESTIMEDOUT genes timed out

cut -f2   -d\  errors/timedouts_full.txt     > errors/timedouts.txt

cut -f2,5 -d\  errors/timedouts_samples_.txt > errors/timedouts_samples.txt

cut -f2   -d\  errors/timedouts_genes_.txt   > errors/timedouts_genes_multi.txt
sort errors/timedouts_genes_multi.txt | uniq > errors/timedouts_genes.txt

rm errors/timedouts_genes_.txt errors/timedouts_samples_.txt errors/timedouts_genes_multi.txt

#touch errors/timedouts:${NUMBEROFGENESTIMEDOUT}genes
#mv errors/timedouts.txt errors/timedouts_${NUMBEROFGENESTIMEDOUT}.txt