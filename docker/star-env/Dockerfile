################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="STAR"
LABEL software.version="2.4.0j"
LABEL about.summary="Spliced Transcripts Alignment to a Reference"
LABEL about.home="https://github.com/alexdobin/STAR"
LABEL about.documentation="https://github.com/alexdobin/STAR/blob/STAR_2.4.0j/doc/STARmanual.pdf"
LABEL about.license_file="https://github.com/alexdobin/STAR/blob/STAR_2.4.0j/LICENSE"
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda star=2.4.0j

WORKDIR /data/

CMD ["STAR"]