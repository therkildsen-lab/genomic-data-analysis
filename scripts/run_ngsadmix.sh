#!/bin/bash
## This script is used to run ngsAdmix. See http://www.popgen.dk/software/index.php/NgsAdmix for details. 

BASEDIR=$1 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
BEAGLE=$2 # Path to the beagle formatted genotype likelihood file
MINMAF=$3 # Minimum allele frequency filter
MINK=$4 # Minimum number of K
MAXK=$5 # Maximum number of K

PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'` 

for ((K = $MINK; K <= $MAXK; K++)); do
	#run ngsAdmix
	echo $K
	#/workdir/Programs/NGSadmix -likes $BEAGLE -K $K -P 16 -o $BASEDIR'angsd/ngsadmix_'$PREFIX'_k'$K -minMaf $MINMAF
done
