#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --job-name=get_fst
#SBATCH --output=get_fst.log

# Keep a record of the Job ID
echo $SLURM_JOB_ID

# Create and move to working directory for job
WORKDIR=/workdir/$USER/$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID/
mkdir -p $WORKDIR
cd $WORKDIR

# If the server is cbsunt246, workdir/ should be mounted. If the server is cbsubscb16, storage/ should be mounted.
/programs/bin/labutils/mount_server $SERVER

# Get the population indices for this array job
NPOP=`tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq | wc -l`
POP1_INDEX=$(((SLURM_ARRAY_TASK_ID-1)/NPOP + 1))
POP2_INDEX=$(((SLURM_ARRAY_TASK_ID-1)%NPOP + 1))

# Only run this job if the index for population 1 is lower than that of population 2
if [ $POP1_INDEX -lt $POP2_INDEX ]; then
  
  # Construct a sample table with one population pair (two populations) per array
  SAMPLETABLE_LOCAL=$WORKDIR/sample_table.tmp
  POP1=`tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq | head -n $POP1_INDEX | tail -n 1`
  POP2=`tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq | head -n $POP2_INDEX | tail -n 1`
  head -n 1 $SAMPLETABLE > $SAMPLETABLE_LOCAL
  awk  -F'\t' -v col="$POPCOLUMN" -v pop="$POP1" 'BEGIN{OFS=FS} $col==pop' $SAMPLETABLE >> $SAMPLETABLE_LOCAL
  awk  -F'\t' -v col="$POPCOLUMN" -v pop="$POP2" 'BEGIN{OFS=FS} $col==pop' $SAMPLETABLE >> $SAMPLETABLE_LOCAL
  
  # Copy saf files to the computing node
  cp ${SAFDIR}${POP1}${BASENAME}.saf* $WORKDIR
  cp ${SAFDIR}${POP2}${BASENAME}.saf* $WORKDIR
  
  # Call the get_fst.sh script
  bash $SCRIPT \
    $WORKDIR \
    $SAMPLETABLE_LOCAL \
    $POPCOLUMN \
    $BASENAME \
    $REALSFS \
    $THREADS \
    "$EXTRA_ARG"
  
  # Copy all output files back to the base directory on the mounted server
  rm ${WORKDIR}*.saf*
  cp $WORKDIR/* $SAFDIR
fi

# Remove this working directory and other subfolders
rm -rf $WORKDIR
