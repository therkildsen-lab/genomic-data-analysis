
get_concensus_per_base <- function(count_per_ind_per_base, min_depth, min_maf){
  ## This function is used to get concensus allele for each base; it is imbedded in the convert_count_to_concensus() function
  if (sum(count_per_ind_per_base) < min_depth ){
        return("N")
      } else if (max(count_per_ind_per_base)/sum(count_per_ind_per_base) < min_maf) {
        return("N")
      } else {
        major_allele <- which(count_per_ind_per_base==max(count_per_ind_per_base))
        if (major_allele==1){
          return("A")
        } else if (major_allele==2){
          return("C")
        } else if (major_allele==3){
          return("G")
        } else if (major_allele==4){
          return("T")
        }
      }
}

convert_count_to_concensus <- function(x, min_depth, min_maf){
  ## This function is used to convert allele count data outputted by angsd -dumpCounts 4 into a data frame containing the consensus sequence
  # x should be a path leading to the .counts.gz file
  # min_depth is the minimum depth required at each base for each individual. Below this depth, the function produced "N"
  # min_maf is the minimum MAJOR allele frequency at each base for each individual. Below this frequency, the function produced "N"
  count <- read_tsv(x)
  n_site <- dim(count)[1]
  n_ind <- floor(dim(count)[2]/4)
  concensus <- matrix(nrow=n_ind, ncol=n_site)
  for (ind in 1:n_ind){
      count_ind <- count[,(ind*4-3):(ind*4)]
      concensus_ind <- apply(count_ind, 1, function(x){get_concensus_per_base(x, min_depth, min_maf)})
      concensus[ind,] <- concensus_ind
  }
  return(concensus)
}

concensus_to_fasta <- function(concensus, ind_label, out_path){
  ## This function is used to convert the output from convert_count_to_concensus() into a fasta file
  # concensus should be a data frame outputted by convert_count_to_concensus()
  # ind_label should be a vector with the same length as the number of rows in concensus, containing the individual labels for each sequence
  # out_path should be the output path of the fasta file
  for (i in seq_along(ind_label)){
    if (i==1) {
      write_lines(paste0(">", ind_label[i]), out_path, append = F)
    } else {
      write_lines(paste0(">", ind_label[i]), out_path, append = T)
    }
    write_lines(paste0(concensus[i,], collapse = ""), out_path, append = T)
  }
}