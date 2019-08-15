################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="eclipdemux"
LABEL software.version="0.0.1"
LABEL about.summary="Demultiplexing script for demuxing eCLIP paired-end inline barcodes"
LABEL about.home="https://github.com/byee4/eclipdemux"
LABEL about.documentation=""
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN apt-get update && apt-get install -y g++

RUN conda install -y -c bioconda \
python=2.7 

RUN cd /opt/ && git clone git://github.com/byee4/eclipdemux.git

ENV PATH=/opt/eclipdemux/bin:$PATH

WORKDIR /data/

CMD ["eclipdemux"]

