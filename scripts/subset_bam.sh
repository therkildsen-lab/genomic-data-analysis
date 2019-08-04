#!/bin/bash
## This script is used to subset bam files based on an identifier (e.g. mitochondrial genome)

BAMLIST=$1 # Path to textfile listing bamfiles to subset (e.g. /workdir/cod/greenland-cod/sample_lists/bam_list_realigned.tsv)
IDENTIFIER=$2 # A feature in bam files to subset for (e.g. MT_genome)
SUFFIX=$3 # suffix of output (e.g. mtgenome)

for LINE in `cat $BAMLIST`; do
	NAME=`echo "${LINE%.*}"`
	echo $NAME
	samtools view -h $NAME'.bam' | head -n 1 > $NAME'_'$SUFFIX'.sam'
	samtools view -h $NAME'.bam' | grep $IDENTIFIER > $NAME'_'$SUFFIX'.sam'
	samtools view -b $NAME'_'$SUFFIX'.sam' > $NAME'_'$SUFFIX'.bam'
	rm $NAME'_'$SUFFIX'.sam'
	samtools sort $NAME'_'$SUFFIX'.bam' > $NAME'_'$SUFFIX'_sorted.bam'
	samtools index $NAME'_'$SUFFIX'_sorted.bam'
done