#!/bin/bash
INDIR=$1 # Path to directory of inputfiles
OUTDIR=$2 # Path to directory for outfiles
INPUT=$3 #Basename for inputfile
SNPLIST=$4 #List of SNPs with positions
NIND=$5 #N ind per pop
NSITES=$6 #N sites per pop
POP=$7 #PopID for output
PROPSITES=$8 #Subset (proportion) of sites used for analyses e.g. 0.05
MAXDIST=$9 # Max distance for analyses in kB INT e.g. 100

/workdir/arne/programs/ngsLD/ngsLD --geno $INDIR$INPUT'.glf' --pos $INDIR$SNPLIST --n_ind $NIND --n_sites $NSITES --out $OUTDIR$POP'_ngsLD_output' --probs --log_scale --rnd_sample $PROPSITES --max_kb_dist $MAXDIST --n_threads 8

# nohup bash run_ngsLD.sh /workdir/arne/results/snp_datasets/ /workdir/arne/results/LD_analyses/ GLF_filtsnps_mme_jiga Mme_global_filtSNP_list.txt 48 4696247 JIGA 0.05 100 > /workdir/arne/output_logfiles/JIGA_ngsLD_estimates_nohup.log &
