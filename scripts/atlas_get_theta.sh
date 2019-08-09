#!/bin/bash
## This script is used to get theta estimates from bam files using atlas

BAMLIST=$1 # Path to textfile listing bamfiles to estimate theta from (e.g. /workdir/cod/greenland-cod/sample_lists/bam_list_realigned.tsv)

for LINE in `cat $BAMLIST`; do
	NAME=`echo "${LINE%.*}"`
	echo $NAME
	if [ ! -f $NAME'.bam.bai' ]; then
		samtools index $NAME'.bam'
	fi
	if [ ! -f $NAME'_theta_estimates.txt.gz' ]; then
			atlas \
			task=estimateTheta \
			bam=$NAME'.bam' \
			minDepth=2
	fi
done