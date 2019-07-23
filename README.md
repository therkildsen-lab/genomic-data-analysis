# genomic-data-analysis
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
nohup ./angsd_global_snp_calling.sh ../bamlist.txt ../reference_genome.fasta ../pathtooutput output_basename MinDepth MaxDepth MinInd minQ > ../output_logfile.nohup &


## Genotype likelihood estimation

Use the [get_beagle.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_beagle.sh) script to get genotype likelihoods for distinct sites (in sites file from SNP calling script) in beagle format.

Run the script using the following command with nohup from the script directory:
nohup ./get_beagle.sh > ../output_logfile.nohup &

## Minor allele frequency estimation

[get_maf_per_pop.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/get_maf_per_pop.sh)

Note on `doMajorMinor`

## Individual-level PCA and PCoA

1. PCAngsd

[run_pcangsd.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/run_pcangsd.sh)

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
