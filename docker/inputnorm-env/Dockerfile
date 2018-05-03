################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="eCLIP Input Normalization"
LABEL software.version="0.0.1"
LABEL about.summary="Perl scripts for normalizing IP over size-matched input"
LABEL about.home="https://github.com/yeolab"
LABEL about.documentation=""
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN apt-get install -y libc-dev
RUN apt-get install -y g++

RUN conda install -y gcc

## TODO: grab from input norm repo (private for now) ##
RUN cd /opt && \
    git clone https://github.com/YeoLab/eclip

RUN conda install -y -c r r-essentials

RUN conda install -y -c bioconda \
    perl-statistics-basic \
    perl-statistics-r \
    perl-statistics-distributions

ENV PATH="/opt/eclip/bin:${PATH}"

WORKDIR /data/

CMD ["overlap_peakfi_with_bam_PE.pl"]
