##### CCP investigation #####
# 0.Load packages
packgs <- c("phyloseq", "ConsensusClusterPlus", "NbClust")
lapply(packgs, require, character.only = TRUE)

# 1.Declare several variables to perform analysis on several configurations
rank <-  "Species" # Genus or "Species"
nfeat <- "22" # 
trans <- "clr" # "log2", "clr" or "alr"
cl <- "km" # "km", "pam" or "hc"

# 2. Declare several functions for preprocess data
# 2.1.Select Target
select_target <- function(pseq, tget) {
  require(dplyr)
  require(phyloseq)
  df <- sample_data(pseq)
  colnames(df)[colnames(df) == tget] <- "target"
  sample_data(pseq) <- df
  return(pseq)
}
# 2.2.Normalization
if (trans == "log2") {
  norm_dataset <- function(pseq) {
    # Change columns by rows too, interested in maintain fts in columns
    require(phyloseq)
    otu <- data.frame(otu_table(pseq))
    # Normalize that variables
    otu <- apply(X = otu, FUN = function(x) log2(x + 1), MARGIN = 2)
    otu_table(pseq) <- otu_table(otu, taxa_are_rows = FALSE)
    print(paste("log2", "normalization selected"))
    return(pseq)
  }
  
}else if (trans == "clr") {
  norm_dataset <- function(pseq){
    require(microbiome)
    # Note that small pseudocount is added if data contains zeroes
    pseq_clr <-  microbiome::transform(pseq, transform =  'clr', shift=1)
    print(paste("clr", "normalization selected"))
    return(pseq_clr)
  }
}else if (trans == "alr") {
  norm_dataset = function(pseq){
    require(microbiome)
    pseq_alr =  microbiome::transform(pseq, transform =  'alr', shift=1,
                                      reference=1)
    print(paste("alr", "normalization selected"))
    return(pseq_alr)
  }
}else{
  print("Introduce valid normalization (log2, clr or alr)")
}

# 3.Load data
Ravel <- readRDS(paste0("00_preprocess_cohorts/data/", rank, "Intersect/Ravel_",
                        rank, "_pseq_", nfeat, ".rds"))
Ravel <- select_target(pseq = Ravel, tget = "Nugent_score_category")
Ravel <- norm_dataset(pseq = Ravel)
ravel_mat <- as.data.frame(otu_table(Ravel)@.Data)

NbClust(data = ravel_mat, method = "kmeans", diss=NULL, distance = "euclidean",
        index = "silhouette", min.nc = 2, max.nc = 25
          )

set.seed(1111)
res_25 <- NbClust(data = ravel_mat, diss = NULL, distance = "euclidean", min.nc = 3, max.nc = 25, 
                  method = "kmeans", index = "alllong")
res_20 <- NbClust(data = ravel_mat, diss = NULL, distance = "euclidean", min.nc = 3, max.nc = 20, 
                  method = "kmeans", index = "alllong")
res_15 <- NbClust(data = ravel_mat, diss = NULL, distance = "euclidean", min.nc = 3, max.nc = 15, 
                  method = "kmeans", index = "alllong")
res_10 <- NbClust(data = ravel_mat, diss = NULL, distance = "euclidean", min.nc = 3, max.nc = 10, 
                  method = "kmeans", index = "alllong")
res_5 <- NbClust(data = ravel_mat, diss = NULL, distance = "euclidean", min.nc = 3, max.nc = 5, 
                 method = "kmeans", index = "alllong")