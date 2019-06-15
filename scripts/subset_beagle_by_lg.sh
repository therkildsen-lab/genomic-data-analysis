#!/bin/bash
## This script is used to subset a genome-wide beagle file into smaller files by linkage groups or chromosomes. 

BEAGLE=$1 # This should be a beagle.gz file. An example is /workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz
LG=$2 # This should be a list of LGs or chromosomes that you want to subset by. An example is /workdir/cod/greenland-cod/sample_lists/lg_list.txt

PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'`
BEAGLEDIR=`echo $BEAGLE | sed 's:/[^/]*$::' | awk '$1=$1"/"'`

for LG in `cat $LG`; do
	if [ ! -s $BEAGLEDIR$PREFIX"_"$LG".beagle.gz" ]; then
		echo "Subsetting "$LG
		zcat $BEAGLE | head -n 1 > $BEAGLEDIR$PREFIX"_"$LG".beagle"
		zcat $BEAGLE | grep $LG"_" >> $BEAGLEDIR$PREFIX"_"$LG".beagle" &
	else
		echo $LG" was already subsetted"
	fi
done

wait 

for LG in `cat $LG`; do
	if [ ! -s $BEAGLEDIR$PREFIX"_"$LG".beagle.gz" ]; then
		echo "Gzipping "$LG
		gzip $BEAGLEDIR$PREFIX"_"$LG".beagle" &
	fi
done