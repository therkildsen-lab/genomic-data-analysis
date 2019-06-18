#!/bin/bash
## This script is used to run local_pca based on genotype likelihood data. See https://github.com/petrelharp/local_pca for details. 

BEAGLE=$1 # This should be a beagle.gz file that you have used for subset_beagle_by_lg.sh. An example is /workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz
LGLIST=$2 # This should be a list of LGs or chromosomes that you want to subset by. An example is /workdir/cod/greenland-cod/sample_lists/lg_list.txt
SNP=$3
PC=$4

# BEAGLE=/workdir/cod/greenland-cod/angsd/bam_list_realigned_mindp161_maxdp768_minind97_minq20.beagle.gz
# LGLIST=/workdir/cod/greenland-cod/sample_lists/lg_list.txt
# SNP=10000
# PC=2
# LG=LG01
# INPUT=/workdir/cod/greenland-cod/angsd/local_pca/bam_list_realigned_mindp161_maxdp768_minind97_minq20_LG01.beagle.x00.gz

PREFIX=`echo $BEAGLE | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'`
BEAGLEDIR=`echo $BEAGLE | sed 's:/[^/]*$::' | awk '$1=$1"/"'`

for LG in `cat $LGLIST`; do
	echo "Splitting "$LG
	zcat $BEAGLEDIR$PREFIX"_"$LG".beagle.gz" | tail -n +2 | split -d --lines $SNP - --filter='bash -c "{ zcat ${FILE%.*} | head -n1; cat; } > $FILE"' $BEAGLEDIR$PREFIX"_"$LG".beagle."$SNP"snp.x" &
done

wait

for LG in `cat $LGLIST`; do
	echo "Zipping "$LG
	gzip $BEAGLEDIR$PREFIX"_"$LG".beagle."$SNP"snp.x"* &
done

wait

for LG in `cat $LGLIST`; do
	echo "Moving "$LG
	mv $BEAGLEDIR$PREFIX"_"$LG".beagle."$SNP"snp.x"* $BEAGLEDIR"local_pca/" &
done

wait

for LG in `cat $LGLIST`; do
	if [ -f $BEAGLEDIR"local_pca/snp_position_"$SNP"snp_"$LG".tsv" ]; then
		rm $BEAGLEDIR"local_pca/snp_position_"$SNP"snp_"$LG".tsv"
	fi
	if [ -f $BEAGLEDIR"local_pca/pca_summary_"$SNP"snp_"$LG".tsv" ]; then
		rm $BEAGLEDIR"local_pca/pca_summary_"$SNP"snp_"$LG".tsv"
	fi
	bash /workdir/genomic-data-analysis/scripts/local_pca_1.sh $BEAGLEDIR $PREFIX $LG $PC $SNP &
done