#!/bin/bash
## This script is used to run ngsAdmix. See http://www.popgen.dk/software/index.php/NgsAdmix for details. 

BASEDIR=$1 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
BEAGLE=$2 # Path to the beagle formatted genotype likelihood file
MINMAF=$3 # Minimum allele frequency filter
K=$4 # Number of K. Should be formatted as an array. e.g. (1 2 3 4 5 6 7 8 9)

PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'` 

for I in "${K[@]}"; do
	#run ngsAdmix
	/workdir/Programs/NGSadmix -likes $BEAGLE -K $I -P 16 -o $BASEDIR'angsd/ngsadmix_'$PREFIX'_k'$K -minMaf $MINMAF
done
