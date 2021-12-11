#!/bin/bash
INPUT_PATH=$1 # Path to directory containing input files (genotype likelihood file and SNP position file)
GENO=$2 # Name of the input genotype likelihood file (in beagle format without header, should only contain GL values, has to be gzipped)
POS=$3 # Tab deliminated list of SNPs with positions (first column is chromosome name, second column is position, has to be gzipped)
MAXDIST=$4 # Max distance for analyses in kB, e.g. 100
THREADS=${5-8} # Number of threads to use, default value is 8, but the program can use a lot more if they are made available
NGSLD=${6:-'/programs/ngsLD-1.1.1/ngsLD'} # Path to ngsLD, default value is '/programs/ngsLD-1.1.1/ngsLD'
EXTRA_ARG=${7:-''} # Extra arguments when running ngsLD, default value is ''

## Define N_IND, N_SITES, and OUT
N_COL=`zcat $INPUT_PATH$GENO | awk -F'\t' '{print NF; exit}'`
((N_IND=N_COL/3))
N_SITE=`zcat $INPUT_PATH$POS | wc -l`
OUT=${GENO%%.*}.ld

## Run ngsLD
$NGSLD \
--geno $INPUT_PATH$GENO \
--pos $INPUT_PATH$POS \
--n_ind $N_IND \
--n_sites $N_SITE \
--out $INPUT_PATH$OUT \
--probs \
--max_kb_dist $MAXDIST \
--n_threads $THREADS \
$EXTRA_ARG

