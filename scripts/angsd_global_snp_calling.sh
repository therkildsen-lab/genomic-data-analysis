#!/bin/bash
## This script is used to call SNPs using angsd

BAMLIST=$1 # Path to textfile listing bamfiles to include in global SNP calling with absolute paths
BASEDIR=$2 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
REFERENCE=$3 # Path to reference genome
MINDP=$4 # Minimum depth filter
MAXDP=$5 # Maximum depth filter
MININD=$6 # Minimum individual filter
MINQ=$7 # Minimum quality filter
MINMAF=$8 # Minimum minor allele frequency filter
MINMAPQ=${9:-20} # Minimum mapping quality (alignment score) filter, default value is 20
ANGSD=${10:-/workdir/programs/angsd0.931/angsd/angsd} # Path to ANGSD, default value is /workdir/programs/angsd0.931/angsd/angsd
THREADS=${11:-8} # Number of parallel threads to use, default value is 8.
EXTRA_ARG=${12:-'-remove_bads 1 -only_proper_pairs 1 -C 50'} # Extra arguments when running ANGSD, default value is '-remove_bads 1 -only_proper_pairs 1 -C 50'

## Extract the name of the bam list (excluding path and suffix)
BAMLISTNAME=`echo $BAMLIST | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'`

## Build base name of output files
OUTBASE=$BAMLISTNAME'_mindp'$MINDP'_maxdp'$MAXDP'_minind'$MININD'_minq'$MINQ

## Call SNPs
$ANGSD -b $BAMLIST -ref $REFERENCE -out $BASEDIR'angsd/'$OUTBASE \
-GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 1 -doCounts 1 -doDepth 1 -dumpCounts 1 -doIBS 1 -makematrix 1 -doCov 1 \
-setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD \
-minQ $MINQ -minMapQ $MINMAPQ \
-SNP_pval 1e-6 -minMaf $MINMAF \
-P $THREADS \
$EXTRA_ARG \
>& $BASEDIR'nohups/'$OUTBASE'.log'

## Create a SNP list to use in downstream analyses
gunzip -c $BASEDIR'angsd/'$OUTBASE'.mafs.gz' | cut -f 1,2,3,4 | tail -n +2 > $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt'
$ANGSD sites index $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt'

## Also make it in regions format for downstream analyses
cut -f 1,2 $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt' | sed 's/\t/:/g' > $BASEDIR'angsd/global_snp_list_'$OUTBASE'.regions'

## Lastly, extract a list of chromosomes/LGs/scaffolds for downstream analysis
cut -f1 $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt' | sort | uniq > $BASEDIR'angsd/global_snp_list_'$OUTBASE'.chrs'
