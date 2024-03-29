#!/bin/bash
## This script is used to run local_pca based on genotype likelihood data. See https://github.com/petrelharp/local_pca for details. 
## This script will use a separate thread for each LG. So you will need to first run /workdir/genomic-data-analysis/scripts/subset_beagle_by_lg.sh

BEAGLE=$1 # This should be the path to a beagle.gz file that you have used for subset_beagle_by_lg.sh. An example is /workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz
LGLIST=$2 # This should be the path to a list of LGs or chromosomes that you want to subset by. An example is /workdir/cod/greenland-cod/sample_lists/lg_list.txt
SNP=$3 ## Number of SNPs to include in each window
PC=$4 ## Number of PCs to keep for each window
N_CORE_MAX=${5:-30} # Maximum number of threads to use simulatenously
LOCAL_PCA_1=${6:-/workdir/genomic-data-analysis/scripts/local_pca_1.sh}
LOCAL_PCA_2=${7:-/workdir/genomic-data-analysis/scripts/local_pca_2.R}
PYTHON=${8:-python}
PCANGSD=${9:-/workdir/programs/pcangsd-1.03/pcangsd/pcangsd.py}

## Extract prefix and directory from the beagle path
PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'`
BEAGLEDIR=`echo $BEAGLE | sed 's:/[^/]*$::' | awk '$1=$1"/"'`

## Split beagle files into smaller windows, each containing a header and the desired number of SNPs
COUNT=0
for LG in `cat $LGLIST`; do
	echo "Splitting "$LG
	zcat $BEAGLEDIR$PREFIX"_"$LG".beagle.gz" | tail -n +2 | split -d --lines $SNP - --filter='bash -c "{ zcat ${FILE%.*} | head -n1; cat; } > $FILE"' $BEAGLEDIR$PREFIX"_"$LG".beagle.x" &
	COUNT=$(( COUNT + 1 ))
  if [ $COUNT == $N_CORE_MAX ]; then
	  wait
	  COUNT=0
	fi
done

wait

## Gzip these beagle files
COUNT=0
for LG in `cat $LGLIST`; do
	echo "Zipping "$LG
	gzip $BEAGLEDIR$PREFIX"_"$LG".beagle.x"* &
	COUNT=$(( COUNT + 1 ))
  if [ $COUNT == $N_CORE_MAX ]; then
	  wait
	  COUNT=0
	fi
done

wait

## Move the beagle files to local_pca directory
COUNT=0
for LG in `cat $LGLIST`; do
	echo "Moving "$LG
	mv $BEAGLEDIR$PREFIX"_"$LG".beagle.x"* 	$BEAGLEDIR"local_pca/" &
	COUNT=$(( COUNT + 1 ))
  if [ $COUNT == $N_CORE_MAX ]; then
	  wait
	  COUNT=0
	fi
done

wait

## Run pcangsd and and prepare the local_pca input. The dependencies are /workdir/genomic-data-analysis/scripts/local_pca_1.sh and /workdir/genomic-data-analysis/scripts/local_pca_2.R
COUNT=0
for LG in `cat $LGLIST`; do
	if [ -f $BEAGLEDIR"local_pca/snp_position_"$SNP"snp_"$LG".tsv" ]; then
		rm $BEAGLEDIR"local_pca/snp_position_"$SNP"snp_"$LG".tsv"
	fi
	if [ -f $BEAGLEDIR"local_pca/pca_summary_"$SNP"snp_"$LG".tsv" ]; then
		rm $BEAGLEDIR"local_pca/pca_summary_"$SNP"snp_"$LG".tsv"
	fi
	bash $LOCAL_PCA_1 $BEAGLEDIR $PREFIX $LG $PC $SNP $PYTHON $PCANGSD $LOCAL_PCA_2 &
	COUNT=$(( COUNT + 1 ))
  if [ $COUNT == $N_CORE_MAX ]; then
	  wait
	  COUNT=0
	fi
done