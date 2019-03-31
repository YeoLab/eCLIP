################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="eclip"
LABEL software.version="0.3.99"
LABEL about.summary="Generic environment for eCLIP 0.3.99 - 0.4.0 pipeline"
LABEL about.home="https://github.com/yeolab/eclip"
LABEL about.documentation=""
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN apt-get update
RUN apt-get install -y zip build-essential

RUN conda install -y -c bioconda -c r -c conda-forge \
  python=2.7 \
  samtools=1.6 \
  bedtools=2.27.1 \
  pysam=0.12.0 \
  pybedtools=0.8.0 \
  pybigwig \
  fastqc=0.11.5 \
  star=2.4.0 \
  cutadapt=1.14 \
  rna-seqc=1.1.8 \
  picard=2.18.27 \
  r=3.5.1 \
  nodejs=11.10.0 \
  fastq-tools=0.8 \
  umi_tools \
  ucsc-bedgraphtobigwig=357 \
  ucsc-bedsort=357 \
  seaborn=0.9.0 \
  cython=0.29.6 \
  scipy=0.17.1 \
  scikit-learn=0.17.1 \
  pycrypto=2.6.1 \
  pytest=4.3.0 \
  pandas=0.23.1 \
  numpy=1.10.2 \
  umi_tools=0.5.0 \
  zlib=1.2;

ENV PATH /opt/eclipdemux/bin:/opt/eclip-${VERSION}/cwl:/opt/eclip-${VERSION}/wf:/opt/eclip-${VERSION}/bin:/opt/eclip-${VERSION}/bin/perl:${PATH}

ENV PERLBREW_ROOT=/perl5 \
PATH=/perl5/bin:/perl5/perls/perl-5.10.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH} \
PERLBREW_PERL=perl-5.10.1 \
PERLBREW_VERSION=0.73 \
PERLBREW_MANPATH=/perl5/perls/perl-5.10.1/man \
PERLBREW_PATH=/perl5/bin:/perl5/perls/perl-5.10.1/bin \
PERLBREW_SKIP_INIT=1

RUN bash -c '\wget -O - http://install.perlbrew.pl | bash' &&\
    /perl5/bin/perlbrew init

RUN /perl5/bin/perlbrew --notest install perl-5.10.1

RUN /perl5/bin/perlbrew install-cpanm

RUN /perl5/bin/perlbrew switch perl-5.10.1

RUN conda install -y -c bioconda -c r -c anaconda samtools=1.6 openssl=1.0 r=3.3.2 && \
    cpanm install Statistics::Basic && \
    cpanm install Statistics::Distributions && \
    ln -s /opt/conda/lib/libreadline.so.7 /opt/conda/lib/libreadline.so.6 && \
    cpanm install Statistics::R

ENV VERSION 0.3.99

RUN cd /opt && \
  wget https://github.com/YeoLab/eclip/archive/v${VERSION}.zip && \
  unzip v${VERSION}.zip -d /opt/

# RUN conda install -y -c https://conda.anaconda.org/toms umi_tools;

RUN pip install --ignore-installed six && \
  pip install cwlref-runner && \
  pip install cwltool==1.0.20180306140409 && \
  pip install cwltest==1.0.20180413145017 && \
  pip install galaxy-lib==17.9.3;
  
RUN cd /opt && \
  git clone https://github.com/byee4/toil && \
  cd toil && \
  /opt/conda/bin/python setup.py install;

RUN cd /opt && \
  git clone https://github.com/byee4/eclipdemux
  
RUN cd /opt && \
  git clone https://github.com/YeoLab/clipper && \
  cd clipper && \
  /opt/conda/bin/python setup.py install;
  
RUN cd /opt && \
  git clone https://github.com/YeoLab/makebigwigfiles && \
  cd makebigwigfiles &&\
  /opt/conda/bin/python setup.py install;

# ENV PATH /opt/eclipdemux/bin:/opt/eclip-${VERSION}/cwl:/opt/eclip-${VERSION}/wf:/opt/eclip-${VERSION}/bin:/opt/eclip-${VERSION}/bin/perl:${PATH}

CMD cwltool /opt/eclip-${VERSION}/cwl/wf_get_peaks_scatter_pe.cwl $@
