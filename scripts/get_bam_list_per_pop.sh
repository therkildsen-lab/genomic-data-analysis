#!/bin/bash
## This script is used to create a bam list for each population / group

BASEDIR=$1 #  Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
SAMPLETABLE=$2 # Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. The 6th column should be data type, which is either pe or se. An example of such a sample table is: /workdir/cod/greenland-cod/sample_lists/sample_table.tsv
POPCOLUMN=$3 # The column index of the variable that you want to group by in the sample table above. In the Greenland project, it's the fifth column,  and thus 5
BAMFILESUFFIX=$4 # Suffix of the bam files that you want to include in these lists. An example from the Greenland cod project is _bt2_gadMor2_minq20_sorted_dedup_overlapclipped_realigned.bam
OUTNAME=$5 # Prefix of the output bam lists. An example from the Greenland cod project is bam_list_realigned_

for POP in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
echo $POP
grep -w $POP $SAMPLETABLE | cut -f1 | awk -v a="$BASEDIR" -v b="$BAMFILESUFFIX" '$1=a"bam/"$1b' > $BASEDIR'sample_lists/bam_list_per_pop/'$OUTNAME$POP'.txt'
done
