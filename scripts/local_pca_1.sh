BEAGLEDIR=$1
PREFIX=$2
LG=$3
SNP=$4

for INPUT in `ls $BEAGLEDIR"local_pca/"$PREFIX"_"$LG".beagle.x"*`; do
	python /workdir/programs/pcangsd/pcangsd.py -beagle $INPUT -o $INPUT
	Rscript --vanilla /workdir/genomic-data-analysis/scripts/local_pca_2.R $INPUT".cov.npy" $PC $SNP $INPUT $LG $BEAGLEDIR"local_pca/"
	# rm $BEAGLEDIR"local_pca/"$LG".cov.npy"
	# rm $INPUT
done