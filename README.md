# Population genomic analysis of low-coverage whole genome data
Pipelines for analyzing genomic data based on genotype likelihoods or population allele frequency data derived from genotype likelihoods.

## SNP calling
Run the [angsd_global_snp_calling.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/angsd_global_snp_calling.sh) script to detect variant sites in a population or group of populations using angsd with a p-value ≤ 1e-6 (hard coded). A range of files and parameters have to be provided in the following order:
+ Path to a list of bamfiles with one file per line (`BAMLIST`), e.g. `path/bamlist.txt`
+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to the indexed reference genome (`REFERENCE`), e.g. `path/reference_genome.fasta`
+ Minimum combined sequencing depth (`MINDP`), e.g. 0.33 x number of individuals
+ Maximum combined sequencing depth across all individual (`MAXDP`), e.g = mean depth + 4 s.d.
+ Minimum number of individuals (`MININD`) a read has to be present in, e.g. 50% of individuals
+ The minimum base quality score (`MINQ`), e.g minQ = 20 
+ Minimum minor allele frequency (`MINMAF`), e.g. 1%

Run the script using the following command with nohup from the script directory:

``` bash
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

## Genotype likelihood estimation

Use the [get_beagle.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_beagle.sh) script to get genotype likelihoods for distinct sites (e.g. sites file from SNP calling script) in beagle format. A range of files and parameters have to be provided in the following order:
+ A list of bamfiles with one file per line (`BAMLIST`), e.g. `path/bamlist.txt`
+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Indexed reference genome (`REFERENCE`), e.g. `path/reference_genome.fasta`
+ Path to the SNP list (`SNPLIST`), e.g. `path/global_snp_list.txt`

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./get_beagle.sh \
BAMLIST \
BASEDIR \
REFERENCE \
SNPLIST \
> path/output_logfile.nohup &
```
## Minor allele frequency estimation

Use the [get_maf_per_pop.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_maf_per_pop.sh) script to get minor allele frequency (MAF) estimates for distinct sites (e.g. sites file from SNP calling script) for individual groups of individuals, i.e. populations. This script loops over populations as provided in the sample table. The following additional (not explained above) parameters and files have to be provided:
+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to a tab deliminated sample table (`SAMPLETABLE`) where the 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique, which then forms the 1st column in the format of sampleID_seqID_laneID. The 6th column should be data type, which is either pe or se. This is the same as the merged sample table used in [data-processing](https://github.com/therkildsen-lab/greenland-cod/blob/master/markdowns/data_processing.md). e.g. `path/sample_table.tsv`
+ Index of the column with population information in the sample table (`POPCOLUMN`), e.g. `5`
+ Prefix in file name of the bamfile list (`BAMLISTPREFIX`), e.g. `bam_list_realigned_`
+ Path to the indexed reference genome (`REFERENCE`), e.g. `path/reference_genome.fasta`
+ Path to the SNP list (`SNPLIST`), e.g. `path/global_snp_list.txt`
+ Minimum combined sequencing depth in a population (`MINDP`)
+ Maximum combined sequencing depth across all individual in a population (`MAXDP`)
+ Minimum number of individuals a read has to be present in a population (`MININD`)
+ The minimum base quality score (`MINQ`), e.g `20`

Run the script using the following command with nohup from the script directory:

```bash
nohup ./get_maf_per_pop.sh \
BASEDIR \
SAMPLETABLE \
POPCOLUMN \
BAMLISTPREFIX \
REFERENCE \
SNPLIST \
MINDP \
MAXDP \
MININD \
MINQ \
> path/output_logfile.nohup &
```
Note: Important is that one uses `-doMajorMinor 3` when providing a sites file to use the provided major and minor allele as the basis for estimating minor allele frequencies. 

## Individual-level PCA and PCoA

Scripts to perform and plot principal components analyses.

1. PCAngsd

Use the [run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh) script to run PCAngsd based on provided genotype likelihoods in beagle format (get with angsd). This will create a covariance matrix that can be used for principal components analyses in R using the R script described below. 

The following files and parameters have to be provided to run PCAngsd:
+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to beagle formatted genotype likelihood file (`BEAGLE`), e.g. `path/genotype_likelihood.beagle.gz`
+ Minor allele frequency filter, e.g. `0.05`
+ Type of analysis to run: for pca use `pca` (other options: selection, inbreedSites, kinship, admix)

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./run_pcangsd.sh \
BASEDIR \
BEAGLE \
MINMAF \
pca \
1 \
1 > path/output_logfile.nohup &
```

The covariance matrix can be used as input for the [individual_pca_functions.R](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/individual_pca_functions.R) R script to create and plot a PCA. The input parameters for the `PCA()` function are described in the R script. This script can then also be used to perform a discriminant analysis of principal components (DAPC) on the PC scores using the `DAPC()` function.

2. PCoA

The [individual_pca_functions.R](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/individual_pca_functions.R) R script can also be used to perform a prinicpal coordinate analysis (PCoA) based on a genetic distance matrix, which can be generated in the SNP calling step with a `.ibsMat` suffix. This distance matrix can also be obtained e.g. with [ngsDist](https://github.com/fgvieira/ngsDist). PCoA can then be performed using the `PCoA()` function as described in the R script. 

## Fst

1. per SNP and genome-wide average

[get_fst.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_fst.sh)

2. windowed

## dxy

1. ngsTools

2. David Marques's script

## Nucleotide diversity

## Tajima's D

## Linkage disequilibrium

1. ngsLD

[run_ngsLD.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_ngsLD.sh)

## Relatedness

## Admixture

1. ngsAdmix

[run_ngsadmix.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_ngsadmix.sh)

2. PCAngsd

[run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh)

## Selection scan

1. PCAngsd

[run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh)

2. outflank

## conStruct

## EEMES

## localPCA

## Notes

Add potential issues, our recommended practices, link to scripts and insructions
