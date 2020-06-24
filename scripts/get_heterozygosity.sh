#!/bin/bash
## This script is used to get the site frequency spectrum and theta estimations from angsd for each population / group

BASEDIR=$1 #  Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
BAMLIST=$2 # Name of the bam lists. An example from the Greenland cod project is bam_list_realigned_mincov_filtered.txt
REFERENCE=$3 # Path to reference genome
MINDP=$4 # Minimum depth filter
MAXDP=$5 # Maximum depth filter
MINQ=$6 # Minimum quality filter
MINMAPQ=$7 # Minimum mapping quality filter

OUTDIR=$BASEDIR'angsd/heterozygosity/'

if [ ! -d "$OUTDIR" ]; then
	mkdir $OUTDIR
fi

for LINE in `cat $BAMLIST`; do

    NAME_TEMP=`echo "${LINE%.*}"`
    NAME=`echo "${NAME_TEMP##*/}"`
	echo $NAME
    OUTBASE=$NAME'_mindp'$MINDP'_maxdp'$MAXDP'_minq'$MINQ'_minmapq'$MINMAPQ

	## Get saf file
	/workdir/programs/angsd0.931/angsd/angsd \
    -i $LINE \
    -anc $REFERENCE \
    -out $OUTDIR$OUTBASE \
    -doSaf 1 \
    -GL 1 \
    -P 8 \
    -doCounts 1 \
    -setMinDepth $MINDP \
    -setMaxDepth $MAXDP \
    -minQ $MINQ \
    -minmapq $MINMAPQ 
    
    ## Get SFS from saf
    /workdir/programs/angsd0.931/angsd/misc/realSFS \
    $OUTDIR$OUTBASE'.saf.idx' \
    -P 8 \
    > $OUTDIR$OUTBASE'.ml'
    
    ## Generate per site thetas
    /workdir/programs/angsd0.931/angsd/angsd \
    -i $LINE \
    -out $OUTDIR$OUTBASE \
    -doThetas 1 \
    -doSaf 1 \
    -pest $OUTDIR$OUTBASE'.ml' \
    -anc $REFERENCE \
    -GL 1 \
    -P 8 \
    -doCounts 1 \
    -setMinDepth $MINDP \
    -setMaxDepth $MAXDP \
    -minQ $MINQ \
    -minmapq $MINMAPQ 

done