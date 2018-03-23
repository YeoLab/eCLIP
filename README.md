![logo](https://github.com/YeoLab/eclip/blob/master/eCLIP-flowchart.png)

# eCLIP

eCLIP is a pipeline designed to identify genomic locations of RNA-bound proteins.
 
# Installation:

Please refer to the script that contains prerequisites for this pipeline:
```source create_environment_clipseq.sh```

To get you started, this provides you with a reference data file and a tutorial
.dataset

These files contain everything needed to run a small example

<b>(make sure to place this in a location with plenty of space!)</b>:
- (IP sample) Read 1 FASTQ.gz
- (IP sample) Read 2 FASTQ.gz (not applicable for single-end)
- (size-matched input sample) Read 1 FASTQ.gz
- (size-matched input sample) Read 2 FASTQ.gz (not applicable for single-end)
- (chromosome 19 only) STAR index directory
- (repbase) STAR index directory
- (barcodes) FASTA file containing barcodes for demultiplexing reads (for single-end, use "a_adapters.fasta")

Execute the analysis using the provided example YAML file pointing to the appropriate bundled example files
```
cd example/
cwl-runner ../cwl/wf_get_peaks_scatter_pe.cwl paired_end_clip.yaml (paired end)
cwl-runner ../cwl/wf_get_peaks_scatter_se.cwl single_end_clip.yaml (single end *warning*: no small dataset available)
```

##### Note:
- At the top of each YAML file, there will be either:
  - eCLIP_pairedend: run paired-end pipeline using TOIL batch runner (default)
  - eCLIP_singleend: run single-end pipeline using TOIL batch runner (default)
  - wf_get_peaks_scatter_pe.cwl: run paired-end pipeline using cwl reference runner
  - wf_get_peaks_scatter_se.cwl: run single-end pipeline using cwl reference runner

### Running the data with required arguments:

Running time for the examples should be ~15 minutes.
Running on a complete dataset takes about a day for human ENCODE data 
(24 hours), so sit back and relax by reading the rest of this README.

These are the minimum required arguments needed to run the pipeline 
(you can view the same information inside the wf_get_peaks.yaml file):

```YAML
dataset: kbp550  # name prefixed onto outputs
```
## If using the default runner script (wf/eCLIP), do not name your dataset ```out_tmp*``` or ```tmp*```!
I have a command that removes temporary directories (on success) that start with those prefixes (```rm -rf out_tmp*```)

Add STAR directories:
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

a_adapters:  # (Single-end only) This is a processed Ril19 set of sequences to be trimmed from SE reads
  class: File
  path: /path/to/a_adapters.fasta
```

The following YAML block describes the location paths of the forward (read1),
reverse (read2) reads, and the barcodes required to demultiplex these reads for
each sample. 

<b>Barcode names must match those described in the above barcodes.fasta file!</b>

We're showing two samples (2 replicates each) described in this space.
Each sample will be defined as indicated below each ``` name:``` field.

```YAML
samples:
  -
    - ip_read:
      name: rep1_clip
      barcodeids: [A01, B06]  # remove this line if processing single-end data
      read1:
        class: File
        path: /path/to/clip.fastq.gz
      read2:  # remove this line if processing single-end data
        class: File  # remove this line if processing single-end data
        path: /path/to/clip.fastq.gz  # remove this line if processing single-end data

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


# References:

Van Nostrand, Eric L., et al. "Robust, Cost-Effective Profiling of RNA Binding Protein Targets with Single-end Enhanced Crosslinking and Immunoprecipitation (seCLIP)." mRNA Processing. Humana Press, New York, NY, 2017. 177-200.

Van Nostrand, E.L., Pratt, G.A., Shishkin, A.A., Gelboin-Burkhart, C., Fang, M.Y., Sundararaman, B., Blue, S.M., Nguyen, T.B., Surka, C., Elkins, K. and Stanton, R. "Robust transcriptome-wide discovery of RNA-binding protein binding sites with enhanced CLIP (eCLIP)." Nature methods 13.6 (2016): 508-514.

Amstutz, Peter; Crusoe, Michael R.; Tijanić, Nebojša; Chapman, Brad; Chilton, John; Heuer, Michael; Kartashov, Andrey; Leehr, Dan; Ménager, Hervé; Nedeljkovich, Maya; Scales, Matt; Soiland-Reyes, Stian; Stojanovic, Luka (2016): Common Workflow Language, v1.0. 
figshare. https://doi.org/10.6084/m9.figshare.3115156.v2
Retrieved: 22 13, May 11, 2017 (GMT)

Kurtzer GM, Sochat V, Bauer MW (2017): Singularity: Scientific containers for mobility of compute. 
PLoS ONE 12(5): e0177459. https://doi.org/10.1371/journal.pone.0177459
