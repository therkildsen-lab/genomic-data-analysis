#!/bin/bash
## This script is used to get minor allele frequency estimation from angsd for each population / group

BASEDIR=$1 #  Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod/
SAMPLETABLE=$2 # Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. The 6th column should be data type, which is either pe or se. An example of such a sample table is: /workdir/cod/greenland-cod/sample_lists/sample_table.tsv
POPCOLUMN=$3 # The column index of the variable that you want to group by in the sample table above. In the Greenland project, it's the fifth column,  and thus 5
OUTNAME=$4 # Prefix of the output bam lists. An example from the Greenland cod project is bam_list_realigned
REFERENCE=$5 # Path to reference genome
SNPLIST=$6 # Path to the SNP list
MINDP=$7 # Minimum depth filter
MAXDP=$8 # Maximum depth filter
MININD=$9 # Minimum individual filter

OUTBASE=`echo $SNPLIST | sed 's/\..*//' | sed -e 's#.*snp_list_\(\)#\1#'` 
OUTDIR=$BASEDIR'angsd/pop_minind'$MININD'/'
if [ ! -d "$OUTDIR" ]; then
mkdir $OUTDIR
fi

for POP in `tail -n +2 $SAMPLETABLE | cut -f $POPCOLUMN | sort | uniq`; do 
echo $POP
/workdir/Programs/angsd/angsd -b $BASEDIR'sample_lists/bam_list_per_pop/'$OUTNAME$POP'.txt' -anc $REFERENCE -out $OUTDIR$OUTBASE'_'$POP -dosaf 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doPost 1 -doVcf 1 -doCounts 1 -doDepth 1 -dumpCounts 1 -P 2 -setMinDepth $MINDP -setMaxDepth $MAXDP -minInd $MININD -sites $SNPLIST >& $BASEDIR'nohups/'$OUTBASE'_'$POP'_maf.log'
done