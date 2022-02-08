#!/bin/bash
#PBS -N wf_clipseqcore_1bc
#PBS -o wf_clipseqcore_1bc.sh.out
#PBS -e wf_clipseqcore_1bc.sh.err
#PBS -V
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -A yeo-group
#PBS -q home
#PBS -t 1-9

# Go to the directory from which the script was called
cd $PBS_O_WORKDIR
cmd[1]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA1.yaml"
cmd[2]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA2.yaml"
cmd[3]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA3.yaml"
cmd[4]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA4.yaml"
cmd[5]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA5.yaml"
cmd[6]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA6.yaml"
cmd[7]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA7.yaml"
cmd[8]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRNA8.yaml"
cmd[9]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_se_1barcode/;./InvRil19.yaml"
eval ${cmd[$PBS_ARRAYID]}

