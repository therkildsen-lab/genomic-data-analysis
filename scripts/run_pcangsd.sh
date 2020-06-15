#!/bin/bash
## This script is used to run PCA using pcangsd. It can be used to run individual-based PCA, estimate selection, inbreeding coefficient, kinship, admixture, and others. The input is a beagle formatted genotype likelihood file.
## See https://github.com/Rosemeis/pcangsd for details

BASEDIR=$1 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
BEAGLE=$2 # Path to the beagle formatted genotype likelihood file
MINMAF=$3 # Minimum allele frequency filter
ANALYSIS=$4 # Type of analysis with pcangsd. It can be one of the following: pca, selection, inbreedSites, kinship, admix
MINE=$5 # Minimum number of eigenvectors to use in the modelling of individual allele frequencies (relevant for admix)
MAXE=$6 # Maximum number of eigenvectors to use in the modelling of individual allele frequencies (relevant for admix)

PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'` 

if [ $ANALYSIS = pca ]; then
	python2 /workdir/programs/pcangsd/pcangsd.py -beagle $BEAGLE -minMaf $MINMAF -threads 16 -o $BASEDIR'angsd/pcangsd_'$PREFIX

elif [ $ANALYSIS = selection ]; then 
	python2 /workdir/programs/pcangsd/pcangsd.py -beagle $BEAGLE -selection -minMaf $MINMAF -threads 16 -o $BASEDIR'angsd/pcangsd_'$PREFIX -sites_save

elif [ $ANALYSIS = inbreedSites ]; then 
	python2 /workdir/programs/pcangsd/pcangsd.py -beagle $BEAGLE -inbreedSites -minMaf $MINMAF -threads 16 -o $BASEDIR'angsd/pcangsd_'$PREFIX -sites_save

elif [ $ANALYSIS = kinship ]; then 
	python2 /workdir/programs/pcangsd/pcangsd.py -beagle $BEAGLE -kinship -minMaf $MINMAF -threads 16 -o $BASEDIR'angsd/pcangsd_'$PREFIX

elif [ $ANALYSIS = admix ]; then 
	for ((E = $MINE; E <= $MAXE; E++)); do
		echo $E
		python2 /workdir/programs/pcangsd/pcangsd.py -beagle $BEAGLE -admix -e $E -minMaf $MINMAF -threads 16 -o $BASEDIR'angsd/pcangsd_'$PREFIX'_e'$E
	done

fi