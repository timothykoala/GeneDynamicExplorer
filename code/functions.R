### Additional functions ###

geneSearch <- function(searchList, snyList, rnaSeqData){
  # The goal of this function is to take in a list of genes
  # of interest and search a gene synonym database for
  # a match with a cannonical name as well as the searched name.
  
  df = snyList %>% filter(tolower(GN_Syn) %in% tolower(searchList)) %>%
    mutate(match = GeneName == GN_Syn, plotName = ifelse(match, GeneName, 
                                                           paste0(GN_Syn,' (',GeneName,')')))
  
  df = df %>% inner_join(rnaSeqData, ., by = 'GeneName') %>%
    select(plotName, WTb_0_3:KO2_48_3) %>% dplyr::rename(GeneName = plotName) %>% gather("Sample", "TPM", 2:ncol(.)) %>% 
    separate(Sample, into = c("Genotype", "Hour", "Replicate"), sep = "\\_") %>%
    mutate(Genotype = paste0('', Genotype), Hour = as.numeric(Hour))
  
  return(df)
}