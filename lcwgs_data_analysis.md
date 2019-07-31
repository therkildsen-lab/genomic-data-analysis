# Population genomic analysis of low-coverage whole genome data

Pipelines for analyzing genomic data based on genotype likelihoods or population allele frequency data derived from genotype likelihoods.

- [SNP calling](#snp)
- [Genotype likelihood estimation](#gl)
- [Minor allele frequency estimation](#maf)
- [Fst](#fst)
- [dxy](#dxy)
- [Nucleotide diversity](#diversity)
- [Tajima's D](#tajima)
- [Linkage disequilibrium](#ld)
- [Relatedness](#relatedness)
- [Individual-level PCA and PCoA](#pca)
- [Admixture](#admix)
- [Selection scan](#selection)
- [conStruct](#construct)
- [EEMES](#eemes)
- [localPCA](#localpca)
- [Notes](#notes)

<a name="snp"/>

## SNP calling

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

<a name="gl"/>

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

<a name="maf"/>

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

``` bash
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

<a name="fst"/>

## Fst

1. per SNP and genome-wide average

Use the [get_fst.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_fst.sh) script to estimate per SNP Fst and its genome average. A range of files and parameters have to be provided in the following order:

+ Path to a directory where per population `saf.gz` files are located (`SAFDIR`), e.g. `/workdir/cod/greenland-cod/angsd/popminind2/`
+ Path to a tab deliminated sample table (`SAMPLETABLE`) where the 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique, which then forms the 1st column in the format of sampleID_seqID_laneID. The 6th column should be data type, which is either pe or se. This is the same as the merged sample table used in [data-processing](https://github.com/therkildsen-lab/greenland-cod/blob/master/markdowns/data_processing.md). e.g. `path/sample_table.tsv`
+ Index of the column with population information in the sample table (`POPCOLUMN`), e.g. `5`
+ Base name of the saf files excluding ".saf.gz" (`BASENAME`). This will be used as the base name of all output files, e.g. `_bam_list_realigned_mindp161_maxdp768_minind97_minq20_popminind2`

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./get_fst.sh \
SAFDIR \
SAMPLETABLE \
POPCOLUMN \
BASENAME \
> path/output_logfile.nohup &
```

2. windowed

<a name="dxy"/>

## dxy

1. ngsTools

2. David Marques's script

<a name="diversity"/>

## Nucleotide diversity

<a name="tajima"/>

## Tajima's D

<a name="ld"/>

## Linkage disequilibrium

1. ngsLD

[run_ngsLD.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_ngsLD.sh)

<a name="relatedness"/>

## Relatedness

<a name="pca"/>

## Individual-level PCA and PCoA

Scripts to perform and plot principal components analyses (based on a covariance matrix) and principal coordinate analyses (based on a distance matrix).

1. PCAngsd

Use the [run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh) script to run PCAngsd based on provided genotype likelihoods in beagle format (get with angsd). This will create a covariance matrix that can be used for principal components analyses in R using the R script described below. The following files and parameters have to be provided to run PCAngsd:

+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to beagle formatted genotype likelihood file (`BEAGLE`), e.g. `path/genotype_likelihood.beagle.gz`
+ Minor allele frequency filter (`MINMAF`), e.g. `0.05`
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


<a name="admix"/>

## Admixture

1. ngsAdmix

Use the [run_ngsadmix.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_ngsadmix.sh) script to run an admixture analysis using ngsAdmix. A range of files and parameters have to be provided in the following order:

+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to beagle formatted genotype likelihood file (`BEAGLE`), e.g. `path/genotype_likelihood.beagle.gz`
+ Minimum minor allele frequency (`MINMAF`), e.g. `0.05`
+ Minimum number of K (`MINK`), e.g. `1`
+ Maximum number of K (`MAXK`), e.g. `10`

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./run_ngsadmix.sh \
BASEDIR \
BEAGLE \
MINMAF \
MINK \
MAXK \
> path/output_logfile.nohup &
```

2. PCAngsd

Use the [run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh) to run an admixture analysis with PCAngsd. A range of files and parameters have to be provided in the following order:

+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to beagle formatted genotype likelihood file (`BEAGLE`), e.g. `path/genotype_likelihood.beagle.gz`
+ Minor allele frequency filter (`MINMAF`), e.g. `0.05`
+ Type of analysis to run: for admixture use `admix` (other options: pca, selection, inbreedSites, kinship)
+ Minimum number of eigenvectors to use in the modelling of individual allele frequencies (`MINE`), e.g. `1`
+ Maximum number of eigenvectors to use in the modelling of individual allele frequencies (`MAXE`), e.g. `10`

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./run_pcangsd.sh \
BASEDIR \
BEAGLE \
MINMAF \
admix \
MINE \
MAXE > path/output_logfile.nohup &
```

<a name="selection"/>

## Selection scan

1. PCAngsd

Use the [run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh) script to run a selection scan using PCAngsd based on provided genotype likelihoods in beagle format (get with angsd). The following files and parameters have to be provided to run PCAngsd:

+ The project's base directory (`BASEDIR`), e.g. `path/base_directory/`
+ Path to beagle formatted genotype likelihood file (`BEAGLE`), e.g. `path/genotype_likelihood.beagle.gz`
+ Minor allele frequency filter (`MINMAF`), e.g. `0.05`
+ Type of analysis to run: for pca use `selection` (other options: pca, inbreedSites, kinship, admix)

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./run_pcangsd.sh \
BASEDIR \
BEAGLE \
MINMAF \
selection \
1 \
1 > path/output_logfile.nohup &
```

This script will performs a genome selection scan along all significant PCs. If you want to define the number of PCs on your own, you can also write your own script following [this example](https://github.com/therkildsen-lab/greenland-cod/blob/master/markdowns/exploratory_data_analysis.md#run-pcangsd-with-the-selection-option).

2. outflank

<a name="construct"/>

## conStruct

<a name="eemes"/>

## EEMES

<a name="localpca"/>

## localPCA

First, use the [subset_beagle_by_lg.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/subset_beagle_by_lg.sh) script to subset the beagle files by LGs or chromosomes. A range of files and parameters have to be provided in the following order:
+ Path to a genome-wide beagle file (`BEAGLE`), e.g. `/workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz`
+ Path to a list of LGs or chromosomes that you want to subset by (`LGLIST`), e.g. `/workdir/cod/greenland-cod/sample_lists/lg_list.txt`

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./subset_beagle_by_lg.sh \
BEAGLE \
LGLIST \
> path/output_logfile.nohup &
```
Then, use the [run_local_pca.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_local_pca.sh) script to run a localPCA analysis. A range of files and parameters have to be provided in the following order:
+ Path to a beagle.gz file that you have used for the subsetting step (`BEAGLE`), e.g. `/workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz`
+ Path to a list of LGs or chromosomes that you have used for the subsetting step (`LGLIST`), e.g. `/workdir/cod/greenland-cod/sample_lists/lg_list.txt`
+ Number of SNPs to include in each window (`SNP`), e.g. 10000
+ Number of PCs to keep for each window (`PC`), e.g. 2

Run the script using the following command with nohup from the script directory:

``` bash
nohup ./run_local_pca.sh \
BEAGLE \
LGLIST \
SNP \
PC \
> path/output_logfile.nohup &
```

<a name="notes"/>

## Notes

Add potential issues, our recommended practices, link to scripts and insructions
