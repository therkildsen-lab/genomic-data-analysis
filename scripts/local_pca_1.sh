#!/bin/bash
## This script is the first dependency of /workdir/genomic-data-analysis/scripts 
## It will loop through all windowed beagle files in each LG
## For each beagle file, it runs pcangsd first, and then runs an R script (/workdir/genomic-data-analysis/scripts/local_pca_2.R) to process the covariance matrix.  

BEAGLEDIR=$1
PREFIX=$2
LG=$3
PC=$4
SNP=$5
$PYTHON=$6
PCANGSD=$7
LOCAL_PCA_2=$8

## Set maximum number of threads to 1
export OMP_NUM_THREADS=1

## Loop through each windowed beagle file in the same linkage group (or chromosome)
for INPUT in `ls $BEAGLEDIR"local_pca/"$PREFIX"_"$LG".beagle.x"*".gz"`; do
	## Run pcangsd
	python $PCANGSD -beagle $INPUT -o $INPUT -threads 1
	## Process pcangsd output
	Rscript --vanilla $LOCAL_PCA_2 $INPUT".cov" $PC $SNP $INPUT $LG $BEAGLEDIR"local_pca/"
done