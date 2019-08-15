################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="CLIPper"
LABEL software.version="0.2.0"
LABEL about.summary="A tool to detect CLIP-seq peaks."
LABEL about.home="https://github.com/YeoLab/clipper/"
LABEL about.documentation="https://github.com/YeoLab/clipper/wiki/CLIPper-Home"
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN apt-get update && apt-get install -y g++

RUN conda install -y -c bioconda \
python=2.7 \
pysam=0.12.0.1 \
numpy=1.10.2 \
scipy=0.16.0 \
matplotlib=1.5.1 \
pybedtools=0.7.10 \
scikit-learn=0.17.1 \
HTSeq=0.9.1 \
cython=0.28.2 \
libgfortran=1


RUN git clone git://github.com/YeoLab/clipper.git && \
    cd clipper && \
    python setup.py install

RUN ln -s /opt/conda/lib/libcrypto.so.1.1 /opt/conda/lib/libcrypto.so.1.0.0

WORKDIR /data/

CMD ["clipper"]

