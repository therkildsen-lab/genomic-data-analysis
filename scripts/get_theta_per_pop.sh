#!/bin/bash
## This script is used to get the site frequency spectrum and theta estimations from angsd for each population / group

BASEDIR=$1 #  Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
SAMPLETABLE=$2 # Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. The 6th column should be data type, which is either pe or se. An example of such a sample table is: /workdir/cod/greenland-cod/sample_lists/sample_table.tsv
POPCOLUMN=$3 # The column index of the variable that you want to group by in the sample table above. In the Greenland project, it's the fifth column,  and thus 5
BAMLISTPREFIX=$4 # Prefix of the bam lists. An example from the Greenland cod project is bam_list_realigned_
REFERENCE=$5 # Path to reference genome
MINDP=$6 # Minimum depth filter
MAXDP=$7 # Maximum depth filter
MININD=$8 # Minimum individual filter
MINQ=$9 # Minimum quality filter
MINMAPQ=${10} # Minimum mapping quality filter
WINDOW_SIZE=${11} # Window size when estimating theta in sliding windows
STEP_SIZE=${12} # Step size when estimating theta in sliding windows

OUTBASE=$BAMLISTPREFIX'popmindp'$MINDP'_popmaxdp'$MAXDP'_popminind'$MININD'_minq'$MINQ'_minmapq'$MINMAPQ
OUTDIR=$BASEDIR'angsd/popminind'$MININD'/'

if [ ! -d "$OUTDIR" ]; then
    mkdir $OUTDIR
fi

for POP in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
    echo $POP
    ## Get saf file
    /workdir/programs/angsd0.931/angsd/angsd \
    -b $BASEDIR'sample_lists/bam_list_per_pop/'$BAMLISTPREFIX$POP'.txt' \
    -anc $REFERENCE \
    -out $OUTDIR$POP'_'$OUTBASE \
    -doSaf 1 \
    -doCounts 1 \
    -GL 1 \
    -P 8 \
    -setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD -minQ $MINQ -minMapQ $MINMAPQ
    
    ## Get SFS from saf
    /workdir/programs/angsd0.931/angsd/misc/realSFS \
    $OUTDIR$POP'_'$OUTBASE'.saf.idx' \
    -P 8 \
    > $OUTDIR$POP'_'$OUTBASE'.sfs'
    
    ## Estimate theta
    /workdir/programs/angsd0.931/angsd/angsd \
    -b $BASEDIR'sample_lists/bam_list_per_pop/'$BAMLISTPREFIX$POP'.txt' \
    -out $OUTDIR$POP'_'$OUTBASE \
    -doThetas 1 \
    -doSaf 1 \
    -pest $OUTDIR$POP'_'$OUTBASE'.sfs' \
    -anc $REFERENCE \
    -GL 1 \
    -P 8 \
    -doCounts 1 \
    -setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD -minQ $MINQ -minMapQ $MINMAPQ
    
    ## Print per-SNP theta
    /workdir/programs/angsd0.931/angsd/misc/thetaStat print \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' | \
    gzip \
    > $OUTDIR$POP'_'$OUTBASE'.thetas.tsv.gz'
    
    ## Calculate fixed window theta
    /workdir/programs/angsd0.931/angsd/misc/thetaStat do_stat \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' \
    -win $WINDOW_SIZE -step $STEP_SIZE \
    -outnames $OUTDIR$POP'_'$OUTBASE'.'$WINDOW_SIZE'window_'$STEP_SIZE'step_thetas.gz'
    
    ## Calculate per-chromosome average theta
    /workdir/programs/angsd0.931/angsd/misc/thetaStat do_stat \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' \
    -outnames $OUTDIR$POP'_'$OUTBASE'.average_thetas.gz'
done