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
- Uses size-matched input sample to normalize and calculate fold-change enrichment within enriched peak regions with custom perl scripts (overlap_peakfi_with_bam_PE.pl, compress_l2foldenrpeakfi_for_replicate_overlapping_bedformat.pl)

For a full description (including commandline args), please see ```tests/eCLIP-(VERSION)``` (ie. [Repeat mapping](https://raw.githubusercontent.com/YeoLab/eclip/master/tests/eCLIP-0.5.0/05_repeat_mapping_pe/run_star.sh)). Or, you may refer to the [Standard Operating Procedure](https://raw.githubusercontent.com/YeoLab/eclip/master/documentation/eCLIP_analysisSOP_v2.2.docx)

Explore the pipeline definition [here](https://view.commonwl.org/workflows/github.com/YeoLab/eclip/blob/master/cwl/wf_get_peaks_scatter_se.cwl):

# Installation:

## Hardware recommendations:
For human datasets, we recommend at least 8 cores (for Clipper) and 32G memory (for STAR). Conservatively, you should expect to have at least 200G in free disk space (this requirement including all inputs, indices, intermediates, and outputs).

## The pipeline has been tested using the following softwares and their versions:
  - bedtools=2.27.1
  - clipper=997fe25532a5bdcf5957f2a467ca283bbd550303
  - cutadapt=1.14
  - eclipdemux=0.0.1
  - fastqc=0.11.8
  - fastq-tools=0.8
  - perl=5.10.1
    - Statistics::Basic 1.6611
    - Statistics::Distributions 1.02
    - Statistics::R 0.34
  - R=3.3.2
  - python=2.7.16
  - samtools=1.6
  - star=2.5.2b
  - ucsc-tools=377
  - umi_tools=1.0.0

Alternatively, you may refer to the [Dockerfiles](https://github.com/YeoLab/wrapped_tools) that comprise the CWL commandline tool environments.

#### Additional pipeline-specific requirements (minimal, one node w/ one or more cores):
  - [cwlref-runner=1.0](https://pypi.org/project/cwlref-runner/1.0/)
#### Additional pipeline-specific requirements (for running in parallel on Torque/PBS-based clusters):
  - [cwltool=1.0.20180306140409](https://pypi.org/project/cwltool/1.0.20180306140409/)
  - [cwltest=1.0.20180413145017](https://pypi.org/project/cwltest/1.0.20180413145017/)
  - [galaxy-lib=17.9.3](https://pypi.org/project/galaxy-lib/17.9.3/)
  - [toil=3.15.0a1](https://github.com/DataBiosphere/toil) (or higher, this is the minimum version required for Torque/PBS-based clusters)

# Prerequisite files:
<b>(make sure to place this in a location with plenty of space!)</b>:
- Sequencing data (in fastq format). You may download our reference RBFOX2 HepG2 raw data here: [RBFOX2](https://s3-us-west-1.amazonaws.com/external-collaborator-data/reference-data/204_01_RBFOX2.tar.gz)
- Genome STAR index directory (fasta files can be downloaded from UCSC; [hg19](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.fa.gz))
- Repeat element STAR index directory (fasta files can be downloaded from [RepBase (most current)](https://www.girinst.org/server/RepBase/) or the fasta file ```MASTER_filelist.wrepbaseandtRNA.fa.fixed.fa.UpdatedSimpleRepeat.fa``` found within the bowtie index [here](https://external-collaborator-data.s3-us-west-1.amazonaws.com/reference-data/repeat-mapping-bowtie2-refdata.tar.gz))
- FASTA file containing barcodes for demultiplexing reads
    - For paired-end data, use [yeolabbarcodes_20170101.fasta](https://raw.githubusercontent.com/YeoLab/eclip/master/example/inputs/yeolabbarcodes_20170101.fasta)
    - For single-end data, use either [a_adapters.fasta](https://raw.githubusercontent.com/YeoLab/eclip/master/example/inputs/a_adapters.fasta) or the ```InvRNA*_adapters.fasta``` files, described below.
- chrom.sizes file (tabbed file containing chromosome name and length, can be downloaded from UCSC; [hg19](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.chrom.sizes))
- Manifest YAML or JSON file describing paths of the above data
    - For paired-end data, use [this template](https://raw.githubusercontent.com/YeoLab/eclip/master/example/paired_end_clip.yaml)
    - For single-end data, use [this template](https://raw.githubusercontent.com/YeoLab/eclip/master/example/single_end_clip.yaml)
- Blacklist file containing potential artifact regions. These have been manually curated using ENCODE3 datasets and can be found here:
    - [hg19](https://www.encodeproject.org/files/ENCFF039QTN/@@download/ENCFF039QTN.bed.gz)
    - [hg38](https://www.encodeproject.org/files/ENCFF039QTN/@@download/ENCFF039QTN.bed.gz)
  
# Description of the manifest

STAR indices:
```YAML
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
randomer_length: "5"  # (Paired-end only) length of the UMI assigned to each read. This may differ depending on the size of your randomer sequence.

barcodesfasta:  # (Paired-end only) This is a FASTA formatted file containing the barcodes we will use to demultiplex our FASTQ's:
  class: File
  path: /path/to/barcodes
```

Blacklist file:
```YAML
blacklist_file: # (Single-end only) This is a BED6 file containing regions that will be excluded from the final peak outputs. Typically comprised of artifact regions such as tRNA/snoRNA/etc.)
  class: File
  path: /path/to/blacklist
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

Assuming you have: 
- Downloaded and generated the relevant STAR indices
- Installed CWL
- Installed Docker (or alternatively, verified relevant binaries are located in your $PATH)
- Ensured the relevant files are locatable in your $PATH (eclip/bin:eclip/cwl:eclip/wf)

You can run the pipeline using one of our wrappers in (wf/):
```
./paired_end_clip.yaml
./single_end_clip.yaml
```
Or, run the workflow using cwl in its native context:
```
cwltool wf_get_peaks_pe_scatter.cwl paired_end_clip.yaml
cwltool wf_get_peaks_se_scatter.cwl single_end_clip.yaml
```

Running on a complete dataset takes about a day for human ENCODE data 
(24 hours), so sit back and relax by reading the rest of this README.

# Outputs:

Input-normalized peaks will contain candidate binding regions.

For Single-end eCLIP, you can expect outputs to follow this filestructure:

| Dataset: "myRBP" name: "IP"          | eCLIP-0.2.2                                                                                                           | eCLIP-0.3.0+                                                                                                          |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Cutadapt x1 metrics                  | ```myRBP.IP.umi.r1Tr.metrics```                                                                                       | ```myRBP.IP.umi.r1.fqTr.metrics```                                                                                    |
| Cutadapt x2 metrics                  | ```myRBP.IP.umi.r1TrTr.metrics```                                                                                     | ```myRBP.IP.umi.r1.fqTrTr.metrics```                                                                                  |
| Demuxed + adapter trimmed reads      | ```myRBP.IP.umi.r1TrTr.fq```                                                                                          | ```myRBP.IP.umi.r1TrTr.fq```                                                                                          |
| Repetitive element filtered reads    | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.fq```                                                           | ```myRBP.IP.umi.r1.fq.repeat-unmapped.sorted.fq.gz```                                                                 |
| STAR metrics (repeat aligned)        | ```myRBP.IP.umi.r1TrTr.sorted.STARLog.final.out```                                                                    | ```myRBP.IP.umi.r1.fqTrTr.sorted.STARLog.final.out```                                                                 |
| Unique genome aligned reads (sorted) | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.bam```                                        | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.bam```                                                                        |
| STAR metrics (genome aligned)        | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARLog.final.out```                                            | ```myRBP.IP.umi.r1.fq.repeat-unmapped.sorted.STARLog.final.out```                                                     |
| PCR duplicate removed aligned reads  | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.bam```                                | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.bam```                                                                |
| CLIPper peaks                        | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.bed```                   | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.bed```                                                   |
| Input-normalized peaks               | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.peakClusters.normed.compressed.bed``` | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.bed```                                 |
| RPM-normalized BigWig files          | ```myRBP.IP.umi.r1TrTr.sorted.STARUnmapped.out.sorted.STARAligned.outSo.rmDupSo.norm.*.bw```                          | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.norm.*.bw```                                                          |
| Blacklist-filtered peaks             |                                                                                                                       | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.bed```        |
| Blacklist-filtered bigBeds           |                                                                                                                       | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.fx.bb```      |
| Blacklist-filtered narrowPeaks       |                                                                                                                       | ```myRBP.IP.umi.r1.fq.genome-mappedSoSo.rmDupSo.peakClusters.normed.compressed.sorted.blacklist-removed.narrowPeak``` |
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
