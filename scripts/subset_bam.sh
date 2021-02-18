#!/bin/bash
## This script is used to subset bam files based on an identifier (e.g. mitochondrial genome)

BAMLIST=$1 # Path to textfile listing bamfiles to subset (e.g. /workdir/cod/greenland-cod/sample_lists/bam_list_realigned.tsv)
IDENTIFIER=$2 # A feature in bam files to subset for (e.g. MT_genome)
SUFFIX=$3 # suffix of output (e.g. mtgenome)
JOBS=${4:-1} # Number of jobs to run in parallel (default 1)

JOB_INDEX=0

## subset, sort, and convert to bam format
for LINE in `cat $BAMLIST`; do
	NAME=`echo "${LINE%.*}"`
	samtools view -h $NAME'.bam' | grep $IDENTIFIER | samtools sort | samtools view -b > $NAME'_'$SUFFIX'_sorted.bam' &
	JOB_INDEX=$(( JOB_INDEX + 1 ))
	if [ $JOB_INDEX == $JOBS ]; then
		wait
		JOB_INDEX=0
	fi
done

wait 
JOB_INDEX=0

## index bam files
for LINE in `cat $BAMLIST`; do
	NAME=`echo "${LINE%.*}"`
	samtools index $NAME'_'$SUFFIX'_sorted.bam' &
	JOB_INDEX=$(( JOB_INDEX + 1 ))
	if [ $JOB_INDEX == $JOBS ]; then
		wait
		JOB_INDEX=0
	fi
done
