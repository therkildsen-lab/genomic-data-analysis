#!/bin/bash
## This script is used to get beagle formatted genotype likelihood file

BAMLIST=$1 # Path to textfile listing bamfiles to include in global SNP calling with absolute paths
BASEDIR=$2 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
REFERENCE=$3 # Path to reference genome
SNPLIST=$4 # Path to the SNP list

## Build base name of output files
OUTBASE=`echo $SNPLIST | sed 's/\..*//' | sed -e 's#.*snp_list_\(\)#\1#'` 
CHRLIST=`echo $SNPLIST | sed 's/\..*//'`.chrs

## Get beagle formatted genotype likelihood
/workdir/Programs/angsd/angsd \
-b $BAMLIST \
-anc $REFERENCE \
-out $BASEDIR'angsd/'$OUTBASE \
-GL 1 \
-doGlf 2 \
-doMaf 1 \
-doMajorMinor 3 \
-P 32 \
-sites $SNPLIST \
-rf $CHRLIST \
>& $BASEDIR'nohups/'$OUTBASE'_get_beagle.log' 