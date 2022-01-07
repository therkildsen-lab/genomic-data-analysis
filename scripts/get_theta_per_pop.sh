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
ANGSD=${13:-/workdir/programs/angsd0.931/angsd/angsd} # Path to ANGSD, default value is /workdir/programs/angsd0.931/angsd/angsd
ANGSD_MISC=${14:-/workdir/programs/angsd0.931/angsd/misc} # Path to the misc folder in ANGSD, default value is /workdir/programs/angsd0.931/angsd/misc
THREADS=${15:-8} # Number of parallel threads to use, default value is 8.
EXTRA_ARG_SAF=${16:-'-remove_bads 1 -only_proper_pairs 1 -C 50'} # Extra arguments when running saf estimation, default value is '-remove_bads 1 -only_proper_pairs 1 -C 50'
EXTRA_ARG_SFS=${17:-''} # Extra arguments when running sfs estimation, default value is ''
EXTRA_OUTNAME=${18:-''} # Extra suffix in output name, default value is ''

OUTBASE=$BAMLISTPREFIX'popmindp'$MINDP'_popmaxdp'$MAXDP'_popminind'$MININD'_minq'$MINQ'_minmapq'$MINMAPQ$EXTRA_OUTNAME
OUTDIR=$BASEDIR'angsd/popminind'$MININD'/'
REALSFS=${ANGSD_MISC}/realSFS
THETASTAT=${ANGSD_MISC}/thetaStat

if [ ! -d "$OUTDIR" ]; then
    mkdir $OUTDIR
fi

for POP in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
    echo $POP
    ## Get saf file
    $ANGSD \
    -b $BASEDIR'sample_lists/bam_list_per_pop/'$BAMLISTPREFIX$POP'.txt' \
    -anc $REFERENCE \
    -ref $REFERENCE \
    -out $OUTDIR$POP'_'$OUTBASE \
    -doSaf 1 \
    -doCounts 1 \
    -GL 1 \
    -P $THREADS \
    -setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD -minQ $MINQ -minMapQ $MINMAPQ \
    $EXTRA_ARG_SAF
    
    ## Get SFS from saf
    $REALSFS \
    $OUTDIR$POP'_'$OUTBASE'.saf.idx' \
    -P $THREADS \
    $EXTRA_ARG_SFS \
    > $OUTDIR$POP'_'$OUTBASE'.sfs'
    
    ## Estimate theta
    $REALSFS saf2theta \
    $OUTDIR$POP'_'$OUTBASE'.saf.idx' \
    -outname $OUTDIR$POP'_'$OUTBASE \
    -sfs $OUTDIR$POP'_'$OUTBASE'.sfs' \
    -anc $REFERENCE \
    -P $THREADS 
    
    ## Print per-SNP theta
    $THETASTAT print \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' | \
    gzip \
    > $OUTDIR$POP'_'$OUTBASE'.thetas.tsv.gz'
    
    ## Calculate fixed window theta
    $THETASTAT do_stat \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' \
    -win $WINDOW_SIZE -step $STEP_SIZE \
    -outnames $OUTDIR$POP'_'$OUTBASE'.'$WINDOW_SIZE'window_'$STEP_SIZE'step_thetas'
    
    ## Calculate per-chromosome average theta
    $THETASTAT do_stat \
    $OUTDIR$POP'_'$OUTBASE'.thetas.idx' \
    -outnames $OUTDIR$POP'_'$OUTBASE'.average_thetas'
done