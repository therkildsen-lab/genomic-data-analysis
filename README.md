# Population genomic analysis of low-coverage whole genome data
Pipelines for analyzing genomic data based on genotype likelihoods or population allele frequency data derived from genotype likelihoods.

## SNP calling
Run the [angsd_global_snp_calling.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/angsd_global_snp_calling.sh) script to detect variant sites in a population or group of populations using angsd with a p-value ≤ 1e-6 and a minor allele frequency of 5% (hard coded). A range of files and parameters have to be provided:
+ A list of bamfiles with one file per line, e.g. bamlist.txt
+ Indexed reference genome
+ The minimum base quality score (minQ), e.g minQ = 20 
+ Minimum combined sequencing depth (MinDepth), e.g. 0.33 x number of individuals
+ Maximum combined sequencing depth across all individual (MaxDepth), e.g = mean depth + 4 s.d.
+ Minimum number of individuals (MinInd) a read has to be present in, e.g. 50% of individuals

Run the script using the following command with nohup from the script directory:

nohup ./angsd_global_snp_calling.sh path/bamlist.txt path/reference_genome.fasta path/pathtooutput output_basename MinDepth MaxDepth MinInd minQ > path/output_logfile.nohup &


## Genotype likelihood estimation

Use the [get_beagle.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_beagle.sh) script to get genotype likelihoods for distinct sites (e.g. sites file from SNP calling script) in beagle format.

Run the script using the following command with nohup from the script directory:

nohup ./get_beagle.sh path/bamlist.txt /pathtobasedirectory path/reference_genome.fasta path/sites.txt > path/output_logfile.nohup &

## Minor allele frequency estimation

Use the [get_maf_per_pop.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_maf_per_pop.sh) script to get minor allele frequency (MAF) estimates for distinct sites (e.g. sites file from SNP calling script) for individual groups of individuals, i.e. populations. This script loops over populations as provided in the sample table. The following additional (not explained above) parameters and files have to be provided:
+ sample table: Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. The 6th column should be data type, which is either pe or se. Same as for genomic-data-processing
+ Index of the column with population information in the sample table (e.g. 5)
+ Prefix of the bamfile list containing

Run the script using the following command with nohup from the script directory:

nohup ./get_beagle.sh path/bamlist.txt path/pathtobasedirectory path/reference_genome.fasta path/sites.txt > path/output_logfile.nohup &

Note: Important is that one uses `-doMajorMinor 3` when providing a sites file to use the provided major and minor allele as the basis for estimating minor allele frequencies. 

## Individual-level PCA and PCoA

Scripts to perform and plot principal components analyses.

1. PCAngsd

Use the [run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh) script to run PCAngsd based on provided genotype likelihoods in beagle format (get with angsd). 
The following files and parameters have to be provided:
+ A list of bamfiles with one file per line, e.g. bamlist.txt

Run the script using the following command with nohup from the script directory:

nohup ./run_pcangsd.sh  > path/output_logfile.nohup &

2. angsd

Both methods can be plotted using [individual_pca_functions.R](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/individual_pca_functions.R)

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
