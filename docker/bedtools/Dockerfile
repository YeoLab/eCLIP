################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="bedtools"
LABEL software.version="2.27.1"
LABEL about.summary="A powerful toolset for genome arithmetic."
LABEL about.home="https://github.com/arq5x/bedtools2/"
LABEL about.documentation=""
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda bedtools=2.27.1

WORKDIR /data/

CMD ["bedtools"]

