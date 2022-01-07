#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --job-name=get_theta_per_pop
#SBATCH --output=get_theta_per_pop.log

# Keep a record of the Job ID
echo $SLURM_JOB_ID

# Create and move to working directory for job
WORKDIR=/workdir/$USER/$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID/
mkdir -p $WORKDIR
cd $WORKDIR

# Make subdirectories with the working directory
mkdir bam
mkdir -p sample_lists/bam_list_per_pop/
mkdir reference
mkdir angsd

# If the server is cbsunt246, workdir/ should be mounted. If the server is cbsubscb16, storage/ should be mounted.
/programs/bin/labutils/mount_server $SERVER

# Copy the reference sequence and its index file to the computing node
cp $REFERENCE $WORKDIR'reference/'
sleep 60
cp $REFERENCE'.fai' $WORKDIR'reference/'

## Construct a sample table with one population per array
SAMPLETABLE_LOCAL=$WORKDIR/sample_lists/sample_table.tmp
POP=`tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
head -n 1 $SAMPLETABLE > $SAMPLETABLE_LOCAL
awk  -F'\t' -v col="$POPCOLUMN" -v pop="$POP" 'BEGIN{OFS=FS} $col==pop' $SAMPLETABLE >> $SAMPLETABLE_LOCAL

## Copy all bam files to the computing node, and write a bam list with path to local bam copies
BAMLIST_REMOTE=$BASEDIR'/sample_lists/bam_list_per_pop/'$BAMLISTPREFIX$POP'.txt'
BAMLIST_LOCAL=$WORKDIR'/sample_lists/bam_list_per_pop/'$BAMLISTPREFIX$POP'.txt'
for LINE in `cat $BAMLIST_REMOTE`; do
  BAM_REMOTE=$BASEDIR'/bam/'${LINE##*/}
  BAM_LOCAL=$WORKDIR'/bam/'${LINE##*/}
  cp $BAM_REMOTE $BAM_LOCAL
  cp ${BAM_REMOTE%.*}.bai ${BAM_LOCAL%.*}.bai
  echo $BAM_LOCAL >> $BAMLIST_LOCAL
done

# Call the get_maf_per_pop.sh script
bash $SCRIPT \
  $WORKDIR \
  $SAMPLETABLE_LOCAL \
  $POPCOLUMN \
  $BAMLISTPREFIX \
  $WORKDIR'reference/'${REFERENCE##*/} \
  $MINDP \
  $MAXDP \
  $MININD \
  $MINQ \
  $MINMAPQ \
  $WINDOW_SIZE \
  $STEP_SIZE \
  $ANGSD \
  $ANGSD_MISC \
  $THREADS \
  "$EXTRA_ARG_SAF" \
  "$EXTRA_ARG_SFS" \
  $EXTRA_OUTNAME

# Copy all output files back to the base directory on the mounted server
cp -r $WORKDIR/angsd/* $BASEDIR/angsd/

# Remove this working directory and other subfolders
rm -rf $WORKDIR
