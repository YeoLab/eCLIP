# eCLIP

eCLIP is a pipeline designed to identify genomic locations of RNA-bound proteins.

# Description/methods:
- (paired-end only) Demultiplexes paired-end reads using inline barcodes
- Trims adapters & adapter-dimers with cutadapt
- Maps to repeat elements with STAR and filter
- Maps filtered reads to genome with STAR
- Removes PCR-duplicates with umi_tools (single-end) or with a custom python script (barcodecollapsepe.py)
- (paired-end only) Merges multiple inline barcodes and filters R1 (uses only R2 for peak calling)
- Calls enriched peak regions (peak clusters) with CLIPPER
- Uses size-matched input sample to normalize and calculate fold-change enrichment within enriched peak regions with custom perl scripts (overlap_peakfi_with_bam_PE.pl, peakscompress.pl)

For a full description (including commandline args), please see ```tests/eCLIP-(VERSION)``` (ie. [Repeat mapping](https://raw.githubusercontent.com/YeoLab/eclip/master/tests/eCLIP-0.4.0/05_repeat_mapping_pe/run_star.sh))

Explore the pipeline definition [here](https://view.commonwl.org/workflows/github.com/YeoLab/eclip/blob/master/cwl/wf_get_peaks_scatter_se.cwl):

# Installation:

#### Hardware requirements:
For human datasets, we recommend at least 8 cores (for Clipper) and 30G memory (for STAR). Conservatively, you should expect to have at least 200G in free disk space (this requirement including all inputs, indices, intermediates, and outputs).

#### Please refer to the [Dockerfile](https://raw.githubusercontent.com/YeoLab/eclip/master/docker/Dockerfile) or [Singularity]() file to build a compatible environment:
- Install [Singularity](https://singularity.lbl.gov/). You may need an administrator to help install this on your cluster, however we strongly recommend this as this image contains all the software needed to run the pipeline. 
- Build the singularity image (This requires a superuser account, so this may need to be done locally):
```
singularity build eCLIP.img Singularity
```

#### Or, you may install the following packages separately:
```
  bedtools=2.27.1 \
  cutadapt=1.14 \
  cython=0.29.6 \
  fastq-tools=0.8 \
  fastqc=0.11.5 \
  nodejs=11.10.0 \
  numpy=1.10.2 \
  pandas=0.23.1 \
  picard=2.18.27 \
  pybedtools=0.8.0 \
  pybigwig=0.3.12 \
  pycrypto=2.6.1 \
  pysam=0.12.0 \
  pytest=4.3.0 \
  python=2.7 \
  r=3.5.1 \
  rna-seqc=1.1.8 \
  samtools=1.6 \
  scikit-learn=0.19.1 \
  scipy=0.19.1 \
  seaborn=0.9.0 \
  star=2.4.0 \
  ucsc-bedgraphtobigwig=357 \
  ucsc-bedsort=357 \
  umi_tools=0.5.0 \
  zlib=1.2;
```

#### Non-conda packages:

  - [perl=5.10.1](https://perlbrew.pl/) (perl5.22+ works, but due to changes in perl's hashing algorithm will lead to slightly different results as a result of random ordering of key-value pairs)
      - with Statistics::Basic
      - Statistics::Distributions
      - Statistics::R
  - [cwlref-runner=1.0](https://pypi.org/project/cwlref-runner/1.0/)
  - [cwltool=1.0.20180306140409](https://pypi.org/project/cwltool/1.0.20180306140409/)
  - [cwltest=1.0.20180413145017](https://pypi.org/project/cwltest/1.0.20180413145017/)
  - [galaxy-lib=17.9.3](https://pypi.org/project/galaxy-lib/17.9.3/)
  - [toil=3.15.0a1](https://github.com/DataBiosphere/toil) (or higher, this is the minimum version required for Torque/PBS-based clusters)
  - [eclipdemux](https://github.com/byee4/eclipdemux)
  - [clipper](https://github.com/YeoLab/clipper)
  - [makebigwigfiles](https://github.com/YeoLab/makebigwigfiles)

# Prerequisite files:
<b>(make sure to place this in a location with plenty of space!)</b>:
- Sequencing data (in fastq format). You may download our reference RBFOX2 HepG2 raw data here: [RBFOX2](https://s3-us-west-1.amazonaws.com/external-collaborator-data/reference-data/204_01_RBFOX2.tar.gz)
- Genome STAR index directory (fasta files can be downloaded from UCSC; [hg19](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.fa.gz))
- Repeat element STAR index directory (fasta files can be downloaded from [RepBase](https://www.girinst.org/server/RepBase/))
    - human-specific RepBase index: [homo_sapiens_repbase](https://s3-us-west-1.amazonaws.com/external-collaborator-data/reference-data/homo_sapiens_repbase.tar.gz)
- FASTA file containing barcodes for demultiplexing reads
    - For paired-end data, use [yeolabbarcodes_20170101.fasta](https://raw.githubusercontent.com/YeoLab/eclip/master/example/inputs/yeolabbarcodes_20170101.fasta)
    - For single-end data, use either [a_adapters.fasta](https://raw.githubusercontent.com/YeoLab/eclip/master/example/inputs/a_adapters.fasta) or the ```InvRNA*_adapters.fasta``` files, described below.
- chrom.sizes file (tabbed file containing chromosome name and length, can be downloaded from UCSC; [hg19](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.chrom.sizes))
- Manifest YAML or JSON file describing paths of the above data
    - For paired-end data, use [this template](https://raw.githubusercontent.com/YeoLab/eclip/master/example/paired_end_clip.yaml)
    - For single-end data, use [this template](https://raw.githubusercontent.com/YeoLab/eclip/master/example/single_end_clip.yaml)
    
# Description of the manifest

STAR params:
```
speciesGenomeDir:
  class: Directory
  path: /path/to/stargenome

repeatElementGenomeDir:
  class: Directory
  path: /path/to/repeatelement
```

CLIPPER params:
```YAML
species: hg19  # for supported species, see clipper docs
```

UMI & barcode params:
```YAML
randomer_length: "5"  # (Paired-end only) length of the UMI assigned to each read

barcodesfasta:  # (Paired-end only) This is a FASTA formatted file containing the barcodes we will use to demultiplex our FASTQ's:
  class: File
  path: /path/to/barcodes

```

The following YAML block describes the location paths of the forward (read1),
reverse (read2) reads, and the barcodes required to demultiplex these reads for
each sample. 

<b>Barcode names must match those described in the above barcodes.fasta file!</b>

(For example, if you are using our standard paired-end barcodes 
[here](https://github.com/YeoLab/eclip/blob/master/example/inputs/yeolabbarcodes_20170101.fasta), 
make sure the barcodeids are one of: A01, A03, A04, B06, C01, D8f, F05, G07, X1A, X1B, X2A, X2B, or NIL for "inputs".
Single-end protocols may not have inline barcodes. If this is the case, you will use the a_adapters.fasta. Else, SE protocols with inline barcodes will need the fasta file corresponding to the barcode in question:
- [InvRNA1_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA1_adapters.fasta)
- [InvRNA2_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA2_adapters.fasta)
- [InvRNA3_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA3_adapters.fasta)
- [InvRNA4_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA4_adapters.fasta)
- [InvRNA5_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA5_adapters.fasta)
- [InvRNA6_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA6_adapters.fasta)
- [InvRNA7_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA7_adapters.fasta)
- [InvRNA8_adapters.fasta](https://github.com/YeoLab/eclip/blob/master/example/inputs/InvRNA8_adapters.fasta)

We're showing two samples (2 replicates each) for a paired-end experiment described in this space.
Each sample will be defined as indicated below each ``` name:``` field.
<b>Make sure these names are unique per sample!</b> They (and dataset name above) 
are used to determine the filename prefixes and non-unique IDs will override each other.

PE Data: 
```YAML
samples:
  -
    - ip_read:
      name: rep1_clip
      barcodeids: [A01, B06]  
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      read2:
        class: File
        path: /path/to/clip.fastq.gz
        
    - input_read:
      name: rep1_input
      barcodeids: [NIL, NIL]
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      read2:
        class: File
        path: /path/to/clip.fastq.gz
  -
    - ip_read:
      name: rep2_clip
      barcodeids: [C01, D8f]
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      read2:
        class: File
        path: /path/to/clip.fastq.gz

    - input_read:
      name: rep2_input
      barcodeids: [NIL, NIL]
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      read2:
        class: File
        path: /path/to/clip.fastq.gz

```
SE Data: 
```YAML
samples:
  - 
    - ip_read:
      name: rep1_clip
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      adapters:
        class: File
        path: inputs/InvRNA1_adapters.fasta

    - input_read:
      name: 4020_INPUT1
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      adapters:
        class: File
        path: inputs/InvRNA5_adapters.fasta
  - 
    - ip_read:
      name: 4020_CLIP1
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      adapters:
        class: File
        path: inputs/InvRNA1_adapters.fasta

    - input_read:
      name: 4020_INPUT1
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      adapters:
        class: File
        path: inputs/InvRNA5_adapters.fasta
```


# Running the data with required arguments:

Running on a complete dataset takes about a day for human ENCODE data 
(24 hours), so sit back and relax by reading the rest of this README.

These are the minimum required arguments needed to run the pipeline 
(you can view the same information inside the wf_get_peaks.yaml file):

```bash
mkdir workDir # optional, used by toil to store intermediate files
mkdir outDir # optional, used by toil to store final output files 

singularity exec \
eCLIP.img \
cwltoil \
  --jobStore file:jobStore \
  --workDir workDir \
  --outdir outDir \
  --clean never \
  --cleanWorkDir onSuccess \
  --logFile workDir/toillog.txt \
  /opt/eclip-0.3.99/cwl/wf_get_peaks_scatter_pe.cwl \
  204_RBFOX2.yaml > log.txt 2>&1
```

# Outputs:

Input-normalized peaks will contain regions of binding.


For Single-end eCLIP, you can expect outputs to follow this filestructure:

| Sample name: "myRBP"                 | eCLIP-0.2.2                                                                                                           | eCLIP-0.3.0+                                                                          |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| Demuxed + adapter trimmed reads      | ```myRBP.IP.umi.r1TrTr.fq```                                                                                          | ```myRBP.IP.umi.r1TrTr.fq```                                                          |
| Repetitive element filtered reads    | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.fq```                                                           | ```myRBP.IP.umi.r1.fq.repeat-unmapped.sorted.fq.gz```                                 |
| Unique genome aligned reads (sorted) | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.bam```                                        | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.bam```                                        |
| PCR duplicate removed aligned reads  | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.bam```                                | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam```                                |
| CLIPper peaks                        | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.bed```                   | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.bed```                   |
| Input-normalized peaks               | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.normed.compressed.bed``` | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.bed``` |
| RPM-normalized BigWig files          | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.norm.*.bw```                          | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.norm.*.bw```                          |
made with: https://www.tablesgenerator.com/markdown_tables

For Paired-end eCLIP:

|                                     | eCLIP 0.2.x                                                                                                             | eCLIP GATK                                                                                 | eCLIP 0.3+                                                                                         |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| Demuxed + adapter trimmed reads     | ```*.CLIP.barcode.r1TrTr.fq```                                                                                          | ```RBFOX2-204-CLIP_S1_R*.A01_204_01_RBFOX2.adapterTrim.round2.fastq.gz```                  | ```204.01_RBFOX2.A01.r*.fqTrTr.fqgz```                                                             |
| Repetitive element filtered reads   | ```*.CLIP.barcode.r1.fqTrTr.sorted.STARUnmapped.out.sorted.fq```                                                        | ```RBFOX2-204-CLIP_S1_R1.A01_204_01_RBFOX2.adapterTrim.round2.rep.bamUnmapped.out.mate*``` | ```204.01_RBFOX2.A01.r*.fqTrTr.repeat-unmapped.sorted.fq.gz```                                     |
| Unique genome aligned reads         | ```*.CLIP.barcode.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.bam```                                        | ```RBFOX2-204-CLIP_S1_R1.A01_204_01_RBFOX2.adapterTrim.round2.rmRep.bam```                 | ```204.01_RBFOX2.A01.r1.fq.genome-mappedSo.bam```                                                  |
| PCR duplicate removed aligned reads | ```*.CLIP.barcode.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.bam```                                | ```RBFOX2-204-CLIP_S1_R1.A01_204_01_RBFOX2.adapterTrim.round2.rmRep.rmDup.sorted.bam```    | ```204.01_RBFOX2.A01.r1.fq.genome-mappedSo.rmDupSo.bam```                                          |
| Barcode merged alignments           | ```*.CLIP.barcode.r1.fqTrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.merged.r2.bam```                   | ```204_01_RBFOX2.merged.r2.bam```                                                          | ```204.01_RBFOX2.A01.r1.fq.genome-mappedSo.rmDupSo.merged.r2.bam```                                |
| CLIPper peaks                       | ```*.CLIP.barcode.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.bed```                   | ```204_01_RBFOX2.merged.r2.peaks.bed```                                                    | ```204.01_RBFOX2.A01.r1.fq.genome-mappedSo.rmDupSo.merged.r2.peakClusters.bed```                   |
| Input-normalized peaks              | ```*.CLIP.barcode.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.normed.compressed.bed``` | ```204_01.basedon_204_01.peaks.l2inputnormnew.bed.compressed.bed```                        | ```204.01_RBFOX2.A01.r1.fq.genome-mappedSo.rmDupSo.merged.r2.peakClusters.normed.compressed.bed``` |
|                                     |                                                                                                                         |                                                                                            |                                                                                                    |


## Notes regarding outputs (FAQ):
- When going through the merged BAM file results, I can only find files with only one of the paired barcodes (e.g. A01 of A01/B06). Is this normal? <b>Yes, ```*.merged*.bam``` indicates that both barcodes have been merged, I just use the first as a prefix namespace for the next step.</b>

# References:

Van Nostrand, Eric L., et al. "Robust, Cost-Effective Profiling of RNA Binding Protein Targets with Single-end Enhanced Crosslinking and Immunoprecipitation (seCLIP)." mRNA Processing. Humana Press, New York, NY, 2017. 177-200.

Van Nostrand, E.L., Pratt, G.A., Shishkin, A.A., Gelboin-Burkhart, C., Fang, M.Y., Sundararaman, B., Blue, S.M., Nguyen, T.B., Surka, C., Elkins, K. and Stanton, R. "Robust transcriptome-wide discovery of RNA-binding protein binding sites with enhanced CLIP (eCLIP)." Nature methods 13.6 (2016): 508-514.

Amstutz, Peter; Crusoe, Michael R.; Tijanić, Nebojša; Chapman, Brad; Chilton, John; Heuer, Michael; Kartashov, Andrey; Leehr, Dan; Ménager, Hervé; Nedeljkovich, Maya; Scales, Matt; Soiland-Reyes, Stian; Stojanovic, Luka (2016): Common Workflow Language, v1.0. 
figshare. https://doi.org/10.6084/m9.figshare.3115156.v2
Retrieved: 22 13, May 11, 2017 (GMT)

Kurtzer GM, Sochat V, Bauer MW (2017): Singularity: Scientific containers for mobility of compute. 
PLoS ONE 12(5): e0177459. https://doi.org/10.1371/journal.pone.0177459
