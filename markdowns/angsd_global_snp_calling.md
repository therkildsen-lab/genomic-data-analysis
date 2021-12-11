SNP calling with ANGSD
================

  - [Introduction](#introduction)
  - [Depth filters](#depth-filters)
  - [Standalone server](#standalone-server)
  - [Computer cluster](#computer-cluster)
  - [Output](#output)
  - [Notes](#notes)
  - [Example workflow](#example-workflow)

<br>

## Introduction

SNP calling is the process where single nucleotide polymorphisms are
identified from sequence alignment data. It is a required step for
population genomic analyses that only take variant sites into account,
but should not be used when invariant sites are part of the analysis
(e.g. genetic diversity estimation).

We use `ANGSD` to perform SNP calling on a list of bam formatted
sequence alignment files. Samples with very low sequencing depth
compared to others, as well as problematic samples (e.g. those affected
by cross-contamination) should be excluded before your final SNP calling
step. A series of depth and quality filters need to be inputted so that
sites with problematic mapping or poor information content can be
excluded.

<br>

## Depth filters

To set up depth filters, we recommend you to first examine the
per-position depth distribution summed across all samples that you will
run SNP calling with. Such distribution can be obtained by running ANGSD
with the `-doDepth 1` option before the actual SNP calling. Make sure
that the same quality filters that you plan to use for the SNP calling
step are also used here (e.g. our default settings are `-minMapQ 20
-minQ 20 -remove_bads 1 -only_proper_pairs 1 -C 50`).

In addition to `-doDepth 1`, we also choose to run minor allele
frequency estimation with `-GL 1 -doMajorMinor 1 -doMaf 1` in this step
so that a list of sites with major and minor alleles can be generated,
which can further be subsetted for diversity estimation (since invariant
sites will also be outputted). This may not be applicable for every
situation though.

Because this step may be different for different projects, we will not
provide a hard-coded script but will just include an example script
below. To use this script, you will need to define the following
variables in your Unix environment.

  - `ANGSD`: Path to the ANGSD program
    (e.g. `/workdir/programs/angsd0.935/angsd/angsd`)
  - `BAMLIST`: Path to text file listing bam files to include in global
    SNP calling with absolute paths
    (e.g. `/workdir/cod/greenland-cod/sample_lists/bam_list_realigned_mincov_contamination_filtered.txt`)
  - `REFERENCE`: Path to the indexed reference genome
    (e.g. `/workdir/cod/reference_seqs/gadMor3.fasta`)
  - `OUT`: Path and prefix of output files
    (e.g. `/workdir/cod/greenland-cod/angsd/bam_list_realigned_mincov_contamination_filtered_minq20_minmapq20`)

For example, you will run the following lines to define these variables.

``` bash
ANGSD=/workdir/programs/angsd0.935/angsd/angsd
BAMLIST=/workdir/cod/greenland-cod/sample_lists/bam_list_realigned_mincov_contamination_filtered.txt
REFERENCE=/workdir/cod/reference_seqs/gadMor3.fasta
OUT=/workdir/cod/greenland-cod/angsd/bam_list_realigned_mincov_contamination_filtered_minq20_minmapq20
```

Then, you will run the following script to count the depth.

``` bash
nohup $ANGSD \
-bam $BAMLIST \
-ref $REFERENCE \
-out $OUT \
-doDepth 1 -maxDepth 10000 \
-GL 1 -doMajorMinor 1 -doMaf 1 -doCounts 1  -dumpCounts 1 \
-P 8 \
-minMapQ 20 -minQ 20 -remove_bads 1 -only_proper_pairs 1 -C 50 &
```

Among other things, this script will generate a file with the
`.depthGlobal` suffix, which is essentially a histogram of depth counts
for all sites summed across all samples. You can read this file in your
favorite programming language and visualize the distribution.

The goal of depth filters in SNP calling is to keep the main peak of the
depth distribution and to exclude sites with depths that are too low or
too high. There is not a standard way to determine the right cutoffs,
and shape of the distribution highly depends on whether the reference
genome is well-behaving. In our case, we often see a bimodal
distribution with a lot of sites receiving none or very low sequencing
depth, and then there is a main peak. In addition, there tends to be a
long tail with a few sites receiving very high depth. With this
distribution, it does not make sense to use the empirical standard
deviation to determine depth cutoff (it is too high), so we chose to fit
a normal distribution to our main peak, and use the standard deviation
of the fitted distribution to establish depth cutoffs instead.

In addition to the depth filters, you will also need to specify a
minimum individual filter in the SNP calling step, this is to prevent a
few individuals contributing to most of the sequencing depth at some
sites. With the right depth filters, we think that the minimum
individual filter can be rather relaxed.

[Here](https://github.com/therkildsen-lab/greenland-cod/blob/master/markdowns/data_analysis_filtered.md#establish-snp-calling-filters)
is an example of how these filters were chosen in our Greenland cod
project.

Once these filters are determined, you can proceed to the actual SNP
calling step.

<br>

## Standalone server

Run the
[angsd\_global\_snp\_calling.sh](https://github.com/therkildsen-lab/genomic-data-analysis/blob/master/scripts/angsd_global_snp_calling.sh)
script with `nohup bash` and pass the following input variables as
positional parameters **in the given order**:

1.  `BAMLIST`: Path to textfile listing bam files to include in global
    SNP calling with absolute paths
    (e.g. `/workdir/cod/greenland-cod/sample_lists/bam_list_realigned_mincov_contamination_filtered.txt`)
2.  `BASEDIR`: Path to the base directory where output files will be
    written to a subdirectory named `angsd/`
    (e.g. `/workdir/cod/greenland-cod/`)
3.  `REFERENCE`: Path to the indexed reference genome
    (e.g. `/workdir/cod/reference_seqs/gadMor3.fasta`)
4.  `MINDP`: Minimum combined sequencing depth across all individual
    (e.g = mean depth - 2 s.d)
5.  `MAXDP`: Maximum combined sequencing depth across all individual
    (e.g = mean depth - 2 s.d)
6.  `MININD`: Minimum number of individuals a read has to be present in
    (e.g. 50% of individuals)
7.  `MINQ`: The minimum base quality score (e.g. `20`)
8.  `MINMAF`: Minimum minor allele frequency (e.g. `0.05`)
9.  `MINMAPQ`: Minimum mapping quality filter (default value is `20`)
10. `ANGSD`: Path to ANGSD (default value is
    `/workdir/programs/angsd0.931/angsd/angsd`)
11. `THREADS`: Number of parallel threads to use (default value is `8`)
12. `EXTRA_ARG`: Extra arguments provided to ANGSD (default value is
    `'-remove_bads 1 -only_proper_pairs 1 -C 50'`)

Note that if you would like to, for example, specify the path to ANGSD
yourself, you will need to specify all variables before it, even if some
of them have a default value (e.g. `MINMAPQ`)

Below is an example taken from the Greenland cod project:

``` bash
nohup bash /workdir/genomic-data-analysis/scripts/angsd_global_snp_calling.sh \
/workdir/cod/greenland-cod/sample_lists/bam_list_realigned_mincov_contamination_filtered.txt \
/workdir/cod/greenland-cod/ \
/workdir/cod/reference_seqs/gadMor3.fasta \
368 928 167 20 0.01 20 \
/workdir/programs/angsd0.935/angsd/angsd \
8 \
'-remove_bads 1 -only_proper_pairs 1 -C 50' \
> /workdir/cod/greenland-cod/nohups/global_snp_calling_bam_list_realigned_mincov_contamination_filtered_mindp368_maxdp928_minind167_minq20.nohup &
```

<br>

## Computer cluster

The SNP calling step is not straightforward to parallelize (but see a
discussion about this in the note section), so we will not add
additional parallelization features. Also, copying all bam files from
the storage location to a different computing node can be time
consuming, so if possible, we recommend you to submit the job specifying
that the job should be run in the computing node where the data is
stored (e.g. with `--nodelist` in slurm).

Therefore, running SNP calling on the cluster becomes a simple matter of
submitting the `angsd_global_snp_calling.sh` script to your job
scheduler, with the same variables as described above in the "standalone
server section. You will also need to add some additional parameters for
your job scheduler (e.g. for a slurm system, you may need `--nodelist`,
`--partition`, `--nodes`, `--ntasks`, `--mem`, and `--output`).

Below is an example taken from the Gulf of St. Lawrence cod project:

``` bash
sbatch \
  --nodelist=cbsubscb16 \
  --partition=long7 \
  --nodes=1 \
  --ntasks=8 \
  --mem=20G \
  --output=/local/storage/cod/gosl-cod/nohups/global_snp_calling_bam_list_realigned_mincov_contamination_filtered_mindp184_maxdp404_minind77_minq20.log \
  /fs/cbsunt246/workdir/genomic-data-analysis/scripts/angsd_global_snp_calling.sh \
  /local/storage/cod/gosl-cod/sample_lists/bam_list_realigned_mincov_contamination_filtered.txt \
  /local/storage/cod/gosl-cod/ \
  /local/storage/cod/reference_seqs/gadMor3.fasta \
  184 404 77 20 0.01 20 \
  /fs/cbsunt246/workdir/programs/angsd0.935/angsd/angsd \
  8
```

If your data is not stored on one of the computing nodes, you just need
to add a few lines to copy the bam files from the storage location to
the computing node before running `angsd_global_snp_calling.sh`. After
the computation is done, remember that you will need to transfer the
output back to the storage location as well.

<br>

## Output

The output of this SNP calling step are stored in the `angsd` directory
within the project directory, and they include the followings:

  - A `txt` file containing a list of SNPs identified in the data and
    its associated index files.
      - These can be used later to restrict certain analyses on this set
        of SNPs.
  - A `pos.gz` file containing the position of total sequencing depth at
    these SNPs.
  - A `mafs.gz` file containing the estimated allele frequencies at
    these SNPs.
  - A `beagle.gz` file containing the genotype likelihoods of each
    individual at these SNPs in beagle format.
      - This can be used later as input for other downstream analysis
        tools, such as ngsLD, PCAngsd, and etc.
  - A `depthGlobal` and a`depthSample` file that contain the sequencing
    depth distribution for each SNP, for all samples combined and for
    each sample separately.
  - A `ibsMat` file that contains a distance matrix for all samples
    generated using the random read sampling method.
  - A `covMat` file that contains a covariance matrix for all samples
    generated using the random read sampling method.

<br>

## Notes

  - The following options are hard-coded in the
    `angsd_global_snp_calling.sh` script. To make changes, you can
    either fork this repo or make a copy of the original script.
    
      - The samtools genotype likelihood model is used in default
        (`-GL 1`)
      - The beagle formatted genotype likelihoods are outputted in
        default (`-doGlf 2`)
      - The SNP significance thredshold is set to be `1e-6`
        (`-SNP_pval 1e-6`)
      - The random read sampling method is used to construct the
        distance and covariance matrices (`-doIBS 1`)

  - In our experience, ANGSD cannot use more than 8 computing cores for
    SNP calling. If you have extremely large genome size and/or sample
    size, you may want to consider breaking the process by chromosomes
    (e.g. using the `-rf` option in ANGSD) and submit a separate job for
    each. We choose to not do it here because it involves stitching
    together several very large output files, but it can be worth it in
    some circumstances.

  - It is also an valid option to use GATK for SNP calling, and the
    resulting vcf file containing genotype likelihoods can be inputted
    into ANGSD and other programs for downstream analyses.

<br>

## Example workflow

  - [SNP calling with the Greenland cod
    project](https://github.com/therkildsen-lab/greenland-cod/blob/master/markdowns/data_analysis_filtered.md)

<br>
