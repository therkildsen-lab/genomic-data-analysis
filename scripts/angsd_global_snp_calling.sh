#!/bin/bash
## This script is used to call SNPs using angsd

BAMLIST=$1 # Path to textfile listing bamfiles to include in global SNP calling with absolute paths
BASEDIR=$2 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
REFERENCE=$3 # Path to reference genome
MINDP=$4 # Minimum depth filter
MAXDP=$5 # Maximum depth filter
MININD=$6 # Minimum individual filter
MINQ=$7 # Minimum quality filter
MINMAF=$8 #Minimum minor allele frequency filter

## Extract the name of the bam list (excluding path and suffix)
BAMLISTNAME=`echo $BAMLIST | sed 's/\..*//' | sed -e 's#.*/\(\)#\1#'` 

## Build base name of output files
OUTBASE=$BAMLISTNAME'_mindp'$MINDP'_maxdp'$MAXDP'_minind'$MININD'_minq'$MINQ

## Call SNPs
/workdir/Programs/angsd/angsd -b $BAMLIST -anc $REFERENCE -out $BASEDIR'angsd/'$OUTBASE -dosaf 1 -GL 1 -doGlf 3 -doMaf 1 -doMajorMinor 1 -doPost 1 -doVcf 1 -doCounts 1 -doDepth 1 -dumpCounts 1 -doIBS 1 -makematrix 1 -doCov 1 -P 32 -SNP_pval 1e-6 -setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD -minQ $MINQ -minMaf $MINMAF >& $OUTDIR$OUTBASE'.log' # when I added -dogeno 8 and changed doGlf 3 to 2, the nInd output stops working

## Create a SNP list to use in downstream analyses 
gunzip -c $BASEDIR'angsd/'$OUTBASE'.mafs.gz' | cut -f 1,2,3,4 | tail -n +2 > $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt'
/workdir/Programs/angsd/angsd sites index $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt'

## Also make it in regions format for downstream analyses
cut -f 1,2 $BASEDIR'angsd/global_snp_list_'$OUTBASE'.txt' | sed 's/\t/:/g' > $BASEDIR'angsd/global_snp_list_'$OUTBASE'.regions'