#!/bin/bash
## This script is used to get pairwise Fst estimates from angsd for each population / group pair

SAFDIR=$1 #  Path to per population saf.gz files. An example for the Greenland cod data is: /workdir/cod/greenland-cod/angsd/popminind2/
SAMPLETABLE=$2 # Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. The 6th column should be data type, which is either pe or se. An example of such a sample table is: /workdir/cod/greenland-cod/sample_lists/sample_table.tsv
POPCOLUMN=$3 # The column index of the variable that you want to group by in the sample table above. In the Greenland project, it's the fifth column, and thus 5
BASENAME=$4 # Base name of the saf files excluding ".saf.gz". It will be used as the base name of all output files. An example from the Greenland cod project is _bam_list_realigned_mindp161_maxdp768_minind97_minq20_popminind2

cd $SAFDIR

I=1
for POP1 in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
	J=1
	for POP2 in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
		if [ $I -lt $J ]; then
			echo $POP1'_'$POP2
			if [ ! -f $POP1$BASENAME'.saf.idx' ] || [ ! -f $POP2$BASENAME'.saf.idx' ]; then
				echo 'One or both of the saf.idx files do not exist. Will proceed to the next population pair.'
			else
				# Check if Fst output already exists
				if [ ! -f $POP1'_'$POP2$BASENAME'.fst' ]; then
					# Generate the 2dSFS to be used as a prior for Fst estimation (and individual plots)				
					/workdir/programs/angsd0.928/angsd/misc/realSFS $POP1$BASENAME'.saf.idx' $POP2$BASENAME'.saf.idx' > $POP1'_'$POP2$BASENAME'.2dSFS'
					# Estimating Fst in angsd
					/workdir/programs/angsd0.928/angsd/misc/realSFS fst index  $POP1$BASENAME'.saf.idx' $POP2$BASENAME'.saf.idx' -sfs $POP1'_'$POP2$BASENAME'.2dSFS' -fstout $POP1'_'$POP2$BASENAME'.alpha_beta'
					/workdir/programs/angsd0.928/angsd/misc/realSFS fst print $POP1'_'$POP2$BASENAME'.alpha_beta.fst.idx' > $POP1'_'$POP2$BASENAME'.alpha_beta.txt'
					awk '{ print $0 "\t" $3 / $4 }' $POP1'_'$POP2$BASENAME'.alpha_beta.txt' > $POP1'_'$POP2$BASENAME'.fst'
				fi
				# Check if average Fst output already exists
				if [ ! -f $POP1'_'$POP2$BASENAME'.average_fst.txt' ]; then
					# Estimating average Fst in angsd
					/workdir/programs/angsd0.928/angsd/misc/realSFS fst stats $POP1'_'$POP2$BASENAME'.alpha_beta.fst.idx' > $POP1'_'$POP2$BASENAME'.average_fst.txt' 
				fi
			fi
		fi
		J=$((J+1))
	done
	I=$((I+1))
done