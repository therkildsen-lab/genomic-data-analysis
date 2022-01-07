#!/bin/bash
## This script is used to get the site frequency spectrum and theta estimations from angsd for each population / group

BASEDIR=$1 #  Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
BAMLIST=$2 # Name of the bam lists. An example from the Greenland cod project is bam_list_realigned_mincov_filtered.txt
REFERENCE=$3 # Path to reference genome
MINDP=$4 # Minimum depth filter
MAXDP=$5 # Maximum depth filter
MINQ=$6 # Minimum quality filter
MINMAPQ=$7 # Minimum mapping quality filter
ANGSD=${8:-/workdir/programs/angsd0.931/angsd/angsd} # Path to ANGSD, default value is /workdir/programs/angsd0.931/angsd/angsd
ANGSD_MISC=${9:-/workdir/programs/angsd0.931/angsd/misc} # Path to the misc folder in ANGSD, default value is /workdir/programs/angsd0.931/angsd/misc
THREADS=${10:-8} # Number of parallel threads to use, default value is 8.
EXTRA_ARG_SAF=${11:-'-remove_bads 1 -only_proper_pairs 1 -C 50'} # Extra arguments when running saf estimation, default value is '-remove_bads 1 -only_proper_pairs 1 -C 50'
EXTRA_ARG_SFS=${12:-''} # Extra arguments when running sfs estimation, default value is ''
EXTRA_OUTNAME=${13:-''} # Extra suffix in output name, default value is ''

OUTDIR=$BASEDIR'angsd/heterozygosity/'
REALSFS=${ANGSD_MISC}/realSFS
THETASTAT=${ANGSD_MISC}/thetaStat

if [ ! -d "$OUTDIR" ]; then
	mkdir $OUTDIR
fi

for LINE in `cat $BAMLIST`; do

  NAME_TEMP=`echo "${LINE%.*}"`
  NAME=`echo "${NAME_TEMP##*/}"`
  echo $NAME
  OUTBASE=$NAME'_mindp'$MINDP'_maxdp'$MAXDP'_minq'$MINQ'_minmapq'$MINMAPQ$EXTRA_OUTNAME

	## Get saf file
	$ANGSD \
  -i $LINE \
  -anc $REFERENCE \
  -ref $REFERENCE \
  -out $OUTDIR$OUTBASE \
  -doSaf 1 \
  -GL 1 \
  -P $THREADS \
  -doCounts 1 \
  -setMinDepth $MINDP \
  -setMaxDepth $MAXDP \
  -minQ $MINQ \
  -minmapq $MINMAPQ \
  $EXTRA_ARG_SAF
    
  ## Get SFS from saf
  $REALSFS \
  $OUTDIR$OUTBASE'.saf.idx' \
  -P $THREADS \
  $EXTRA_ARG_SFS \
  > $OUTDIR$OUTBASE'.ml'
    
  ## Generate per site thetas
  $REALSFS saf2theta \
  $OUTDIR$OUTBASE'.saf.idx' \
  -outname $OUTDIR$OUTBASE \
  -sfs $OUTDIR$OUTBASE'.ml' \
  -anc $REFERENCE \
  -P $THREADS 

  ## Print per site thetas
  $THETASTAT print \
  $OUTDIR$OUTBASE'.thetas.idx' | \
  gzip \
  > $OUTDIR$OUTBASE'.thetas.tsv.gz'

  ## Print average thetas
  $THETASTAT do_stat \
  $OUTDIR$OUTBASE'.thetas.idx' \
  -outnames $OUTDIR$OUTBASE'.average_thetas'

done