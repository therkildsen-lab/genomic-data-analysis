#!/bin/bash
## This script is used to get theta estimates from bam files using atlas

BAMLIST=$1 # Path to textfile listing bamfiles to estimate theta from (e.g. /workdir/cod/greenland-cod/sample_lists/bam_list_realigned.tsv)

for LINE in `cat $BAMLIST`; do
	NAME=`echo "${LINE%.*}"`
	echo $NAME
	atlas \
	task=estimateTheta \
	bam=$NAME'.bam' \
	minDepth=2
done