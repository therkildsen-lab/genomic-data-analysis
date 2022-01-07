#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --job-name=get_heterozygosity

# Keep a record of the Job ID
echo $SLURM_JOB_ID

# Create and move to working directory for job
WORKDIR=/workdir/$USER/$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID/
mkdir -p $WORKDIR
cd $WORKDIR

# Make subdirectories with the working directory
mkdir bam
mkdir reference
mkdir -p angsd/heterozygosity
mkdir sample_lists

# If the server is cbsunt246, workdir/ should be mounted. If the server is cbsubscb16, storage/ should be mounted.
/programs/bin/labutils/mount_server $SERVER

# Copy the reference sequence and its index file to the computing node
cp $REFERENCE $WORKDIR'reference/'
sleep 60
cp $REFERENCE'.fai' $WORKDIR'reference/'

## Copy one bam file per array job to the computing node, and write a bam list with path to local bam copies
BAMLIST_LOCAL=$WORKDIR'/sample_lists/bam_list.txt'
LINE=`cat $BAMLIST | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
BAM_REMOTE=$BASEDIR'/bam/'${LINE##*/}
BAM_LOCAL=$WORKDIR'/bam/'${LINE##*/}
cp $BAM_REMOTE $BAM_LOCAL
cp ${BAM_REMOTE%.*}.bai ${BAM_LOCAL%.*}.bai
echo $BAM_LOCAL > $BAMLIST_LOCAL

# Call the get_heterozygosity.sh script
bash $SCRIPT \
  $WORKDIR \
  $BAMLIST_LOCAL \
  $WORKDIR'reference/'${REFERENCE##*/} \
  $MINDP \
  $MAXDP \
  $MINQ \
  $MINMAPQ \
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
