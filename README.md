![logo](https://github.com/YeoLab/eclip/blob/master/eCLIP-flowchart.png)

# eCLIP

eCLIP is a pipeline designed to identify genomic locations of RNA-bound proteins.
 
# Installation:

[Install singularity](http://singularity.lbl.gov/install-linux)

[Download executable into an empty directory](link_to_singularity)

That's it!

# Running the Pipeline:

Mark downloaded program as executable:
```
chmod +x eCLIP-0.1.4
```

Display  a brief overview of options and expected parameters:
```
./eCLIP-0.1.4
```

To get started, you'll need to download a [rather large file](LINKTOZIPPEDFILE)  
This file contains everything that's needed to run a small example 

<b>(make sure to place this in a location with plenty of space!)</b>:
- (IP sample) Read 1 FASTQ.gz
- (IP sample) Read 2 FASTQ.gz
- (size-matched input sample) Read 1 FASTQ.gz
- (size-matched input sample) Read 2 FASTQ.gz
- (chromosome 19 only) STAR index tar.gz file
- (repbase) STAR index tar.gz file
- (barcodes) FASTA file containing barcodes for demultiplexing reads

Execute the analysis using the provided example YAML file pointing to the appropriate bundled example files
```
./eCLIP-0.1.4 eclip_example.yaml
```

### Running the data with required arguments:

Running time for the examples should be ~15 minutes.
Running on a complete dataset takes about a day for human ENCODE data 
(24 hours), so sit back and relax by reading the rest of this README.

These are the minimum required arguments needed to run the pipeline 
(you can view the same information inside the eclip_example.yml file):


The is a FASTA formatted file containing the barcodes we will use to 
demultiplex our FASTQ's ([Example](BARCODESFASTA)) :
```YAML
barcodesfasta:
  class: File
  path: 
```

The following YAML block describes the location paths of the forward (fwd), 
reverse (rev) reads, and the barcodes required to demultiplex these reads for
each sample. 

<b>Barcode names must match those described in the above barcodes.fasta file!</b>

We're showing two samples for brevity, but the pipeline should be able to 
process any number of replicates (and their inputs) in described in this space.
Each sample will be defined as indicated below each ``` - name:``` field.

```YAML
clipalize_items:

  - name: replicate1.CLIP
    fwd:
      class: File
      path: r1_starting_fastq.fastq.gz
    rev:
      class: File
      path: r2_starting_fastq.fastq.gz
    barcodeids: [A01, B06]

  - name: replicate1.INPUT
    fwd:
      class: File
      path: r1_input_starting_fastq.fastq.gz
    rev:
      class: File
      path: r2_input_starting_fastq.fastq.gz
    barcodeids: [NIL, NIL]
```

This YAML block describes which samples will be used as a background relative
to the sample of interest. Basically, it'll take the ```- ip``` (ip) and 
normalize against a background ```- in``` (size-matched input) sample.
In our small example, we're only processing one replicate, but multiple 
samples can also be specified using the same YAML structure as below:

```YAML
normalize_items:

  - ip: replicate1.CLIP
    in: replicate1.INPUT
    
  - ip: replicate2.CLIP
    in: replicate2.INPUT
```

This parameter specifies the length of the randomer/UMI contained 
in the read. It's used for identifying unique reads within a dataset.

<b>NOTE:</b>due to technical limitations, this parameter needs to be evaluated as
a string (ie. randomer_length of 10 will need to be specified as "10")
```YAML
randomer_length: "10"
```

This parameter specifies the genome reference that the pipeline will use
throughout each step (choose among: hg19 hg19chr19 GRCh38 mm10 mm9 ce10):
```YAML
species: hg19chr19
```

Modify this parameter if you would like to add a common prefix name to this
experiment. Outputs will always start with this prefix 
(ie. SOME_EXPT.replicate1.bam),
but otherwise will have no effect on the peak calling.
```YAML
dataset: SOME_EXPT
```

These parameters modify the log2 fold change (l2fc) and log10 p-value (pval)
cutoff thresholds to report which peaks are significantly enriched in the IP 
over its size-matched input.

<b>NOTE:</b>due to technical limitations, this parameter needs to be evaluated as
a string (ie. l2fc of 3 will need to be specified as "3")

```YAML
l2fc: "3"
pval: "3"
```

I have no idea what this does but it needs to be here...
```
overlapize_items:

  []
```

# Outputs:

During processing, the pipeline will echo (output) a bunch of stuff for 
debugging purposes. If the pipeline runs successfully, you'll get a nice 
message:
```commandline
*********************************************************************
********** SUCCESS: eclip_example PROCESSED WITH eclip-0.1.4 **********
*********************************************************************
```

The result of any pipeline job will produce a folder under the same 
name as the starting YAML job document. If our file was called eclip_example.yaml,
you'll see an ```eclip_example/``` directory created in the same working directory.

There are LOTS of intermediate files inside (described below), but the ones 
you'd want to start with are the bed files describing normalized peak signals 
corresponding RBP binding sites:
```
eclip_example/finals.LKS/SOME_EXPT.replicate1.CLIP.---.r-.fqTrTrU-SoMaSoCoSoMeV2ClNo.bed
```

##### Format (tabs) of the BED file:
1. chromosome
2. peak start (0-based) 
3. peak end
4. -log10 p-value
5. log2 fold change (IP/INPUT)
6. strand

# Other things to look for:

If there were any problems, don't worry! We try to be as 
transparent as possible to make it easy to debug. To do this, we create a 
working directory (under the same name as the yaml document), containing:
 
- ```ECLIP-JOB-COPY.eclip_example.txt``` : a copy of the YAML file used to run the job
- ```ECLIP-JOB-LOG.txt```: a log file of all commands
- ```ECLIP-VERSION.0.1.4``` : the pipeline version

Also within this directory are subdirectories that contain both temporary and final result files: 

```
errors/fails.txt (log file of any commands which result in errors
errors/timedouts_full.txt ()
errors/timedouts_genes.txt (list of genes which exceed the maximum limit that CLIPper allows for read counting)
errors/timedouts_samples.txt ()

tmp/cwltool_interm (directory containing cached outputs for intermediates - used to re-run up any incomplete/failed analyses) 
tmp/outdir (contains all finished intermediate files)
tmp/toillogs ()
tmp/workdir ()

results/finals.LKS ()
results/intermediates.LKS ()
results/metricsfiles.LKS ()
results/textfiles.LKS ()

```

# References:

Van Nostrand, E.L., Pratt, G.A., Shishkin, A.A., Gelboin-Burkhart, C., Fang, M.Y., Sundararaman, B., Blue, S.M., Nguyen, T.B., Surka, C., Elkins, K. and Stanton, R. "Robust transcriptome-wide discovery of RNA-binding protein binding sites with enhanced CLIP (eCLIP)." Nature methods 13.6 (2016): 508-514.

Amstutz, Peter; Crusoe, Michael R.; Tijanić, Nebojša; Chapman, Brad; Chilton, John; Heuer, Michael; Kartashov, Andrey; Leehr, Dan; Ménager, Hervé; Nedeljkovich, Maya; Scales, Matt; Soiland-Reyes, Stian; Stojanovic, Luka (2016): Common Workflow Language, v1.0. 
figshare. https://doi.org/10.6084/m9.figshare.3115156.v2
Retrieved: 22 13, May 11, 2017 (GMT)

Kurtzer GM, Sochat V, Bauer MW (2017): Singularity: Scientific containers for mobility of compute. 
PLoS ONE 12(5): e0177459. https://doi.org/10.1371/journal.pone.0177459
