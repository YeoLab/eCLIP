#!/bin/bash

conda create -y --name clip-seq python=2.7;
source activate clip-seq;

### bioconda channel ###
conda install -y -c bioconda samtools \
bedtools \
pysam \
pybedtools \
pybigwig \
fastqc \
star \
cutadapt \
rna-seqc \
picard \
perl-statistics-basic \
perl-statistics-r \
perl-statistics-distributions;

### anaconda channel ###
conda install -y -c anaconda cython pytest;
conda install -y -c anaconda pycrypto;

### Install CWL and helpers ###
pip install --ignore-installed six;
pip install cwlref-runner;
pip install toil[all];

### Yeolab specific helpful packages ###
cd ~/bin;
git clone https://github.com/yeolab/gscripts;
cd gscripts;
python setup.py install;

cd ~/bin;
git clone https://github.com/YeoLab/clipper;
cd clipper;
python setup.py install;

### Add this if on TSCC, otherwise make sure correctly in path! ###
export LD_LIBRARY_PATH=/opt/gnu/gcc/lib64/:$LD_LIBRARY_PATH;

### TSCC-specific PATH variables ### 
export PATH=/var/cfengine/bin:$PATH;
export PATH=/opt/pdsh/bin:$PATH;
export PATH=/opt/maui/bin:$PATH;
export PATH=/opt/sdsc/bin:/opt/sdsc/sbin:$PATH;
export PATH=/opt/rocks/bin:/opt/rocks/sbin:$PATH;
export PATH=/opt/torque/bin:/opt/torque/sbin:$PATH;
export PATH=/opt/gold/bin:/opt/gold/sbin:$PATH;
export PATH=/opt/openmpi/intel/ib/bin:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/bin/intel64:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/mpirt/bin/intel64:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/debugger/gdb/intel64_mic/bin:$PATH;
export PATH=/usr/java/latest/bin:$PATH;
export PATH=/usr/lib64/qt-3.3/bin:$PATH;
export PATH=/bin:/sbin:$PATH;
export PATH=/usr/bin:/usr/sbin:$PATH;
export PATH=/usr/local/bin:/usr/local/sbin:$PATH;

### add this repo to path ###
export PATH=${PWD}/bin/:$PATH;
export PATH=${PWD}/cwl/:$PATH;
export PATH=${PWD}/members:$PATH;
export PATH=${PWD}/wf:$PATH;
export PATH=${PWD}/members/bin/:$PATH;
export PATH=${PWD}/metadata:$PATH;

### install perl 5.10 (not on conda, so use perlbrew) ###

# Installation
echo "DOWNLOAD"
curl -L https://install.perlbrew.pl | bash

# Initialize
echo "INIT"
perlbrew init

# source
echo "SOURCE"
source ~/perl5/perlbrew/etc/bashrc

# See what is available
echo "AVAIL"
perlbrew available

# Install some Perls
echo "INSTALL"
perlbrew install 5.10.1

# See what were installed
echo "LIST"
perlbrew list

# Swith to an installation and set it as default
perlbrew switch perl-5.10.1
