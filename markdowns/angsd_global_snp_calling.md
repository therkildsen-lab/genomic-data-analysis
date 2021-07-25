---
title: "SNP calling with ANGSD"
output: 
  html_document:  
    keep_md: TRUE
---



<br> 

## Script

Run the [angsd_global_snp_calling.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/angsd_global_snp_calling.sh) script to detect variant sites in a population or group of populations using angsd with a p-value ≤ 1e-6 (hard coded). A range of files and parameters have to be provided in the following order:

+ Path to a list of bamfiles with one file per line (`BAMLIST`), e.g. `path/bamlist.txt`
+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to the indexed reference genome (`REFERENCE`), e.g. `path/reference_genome.fasta`
+ Minimum combined sequencing depth (`MINDP`), e.g. 0.33 x number of individuals
+ Maximum combined sequencing depth across all individual (`MAXDP`), e.g = mean depth + 4 s.d.
+ Minimum number of individuals (`MININD`) a read has to be present in, e.g. 50% of individuals
+ The minimum base quality score (`MINQ`), e.g. `20`
+ Minimum minor allele frequency (`MINMAF`), e.g. `0.05`

Run the script using the following command with nohup from the script directory:


```bash
nohup ./angsd_global_snp_calling.sh \
BAMLIST \
BASEDIR \
REFERENCE \
MINDP \
MAXDP \
MININD \
MINQ \
MINMAF \
> path/output_logfile.nohup &
```

<br> 

## Output

The output of this SNP calling step are stored in the `angsd` directory within the project directory, and they include the followings:

+ A `txt` file containing a list of SNPs identified in the data and its associated index files.
    + These can be used later to restrict certain analyses on this set of SNPs.
+ A `pos.gz` file containing the position of total sequencing depth at these SNPs.
+ A `mafs.gz` file containing the estimated allele frequencies at these SNPs.
+ A `beagle.gz` file containing the genotype likelihoods of each individual at these SNPs in beagle format.
    + This can be used later as input for other downstream analysis tools, such as ngsLD, PCAngsd, and etc. 
+ A `depthGlobal` and a`depthSample` file that contain the sequencing depth distribution for each SNP, for all samples combined and for each sample separately. 
+ A `ibsMat` file that contains a distance matrix for all samples generated using the random read sampling method.
+ A `covMat` file that contains a covariance matrix for all samples generated using the random read sampling method.

<br> 

## Notes

+ We recommend that relaxed filters could be used in this initial SNP calling step, since the SNP list can be further subsetted downstream.
