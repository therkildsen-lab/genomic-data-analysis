#!/usr/bin/env Rscript
## This script is the second dependency of /workdir/genomic-data-analysis/scripts
## It performs eigen decomposition on a covarianc matrix outputted by pcangsd

args = commandArgs(trailingOnly=TRUE)

cov_matrix <- args[1]
pc <- args[2]
snp <- args[3]
beagle <- args[4]
lg <- args[5]
out_dir <- args[6]

# cov_matrix <- "bam_list_realigned_mindp161_maxdp768_minind97_minq20_LG01.beagle.x00.gz.cov.npy"
# pc <- 2
# snp <- 10000
# beagle <- "bam_list_realigned_mindp161_maxdp768_minind97_minq20_LG01.beagle.x00.gz"
# lg <- "LG01"
# out_dir <- "/local/workdir/cod/greenland-cod/angsd/local_pca/"

## Load required libraries
library(data.table)
library(lostruct)
suppressWarnings(suppressMessages(library(tidyverse)))
library(RcppCNPy)

## Read covariance matrix and perform eigen decomposition
c <- npyLoad(cov_matrix) %>%
	as.matrix()
e <- eigen(c)
e_values <- e$values
e_vectors <- as.data.frame(e$vectors)

## Format the output as required by local_pca 
pca_summary <- c(sum(c^2), e_values[1:pc], unlist(e_vectors[1:pc], use.names=FALSE)) %>%
	matrix(nrow = 1) %>%
	as.data.frame()
write_tsv(pca_summary, paste0(out_dir, "pca_summary_", snp, "snp_", lg, "_", pc, "pc.tsv"), append=T, col_names=F)

## Save the start and end position of each window
suppressWarnings(suppressMessages(b <- read_tsv(beagle)))
snp_position <- c(b[[1,1]], b[[dim(b)[1],1]]) %>%
	matrix(nrow = 1) %>%
	as.data.frame()
write_tsv(snp_position, paste0(out_dir, "snp_position_", snp, "snp_", lg, "_", pc, "pc.tsv"), append=T, col_names=F)
