## tSPM vs tSPM+ benchmark
### 
###author Jonas Hügel --jhuegel@mgh.harvard.edu
###author: Hossein Estiri -- hestiri@mgh.harvard.edu
###sequencing the data

####  Install and load the required packages
if(!require(pacman)) install.packages("pacman")

pacman::p_load(data.table, devtools, backports, Hmisc, tidyr,dplyr,ggplot2,plyr,scales,
               httr, DT, lubridate, tidyverse,reshape2,foreach,doParallel,epitools,rbenchmark)
##first, load the packages
options(scipen = 999)
if (!require("scales")) install.packages('scales', repos = "http://cran.rstudio.com/")
if (!require("reshape2")) install.packages('reshape2', repos = "http://cran.rstudio.com/")
if (!require("foreach")) install.packages('foreach', repos = "http://cran.rstudio.com/")
if (!require("doParallel")) install.packages('doParallel', repos = "http://cran.rstudio.com/")
if (!require("profmem")) install.packages('profmem', repos = "http://cran.rstudio.com/")
if (!require("microbenchmark")) install.packages('microbenchmark', repos = "http://cran.rstudio.com/")
## load tSPM+(check version and path)
if (!require("tSPMPlus")){
  if(!require("Rcpp")) install.packages("Rcpp")
  if(!require("RcppParallel")) install.packages("RcppParallel")
  install.packages("clai_share/shared_workspace/libs/src/tSPMPlus_0.03.005.tar.gz", repos = NULL)
}
if(!require("tictoc")) install.packages("tictoc")

## load and prep the data
tic("Overall")
tic("loading data")
count="first"
pattern = "tSPM"
phenx <- "AD"
load("../data/syntethicData/performanceBenchmark.RData")
toc()

uniqpats <- c(unique(dbmart.first.sim$patient_num))
sparsity = 0.05

#setup parallel backend to use many processors
cores<-detectCores()

##tSPMPlus
tic("tSPMPLus including transformation")
tic("numeric transformation")
dbmart_num <- tSPMPlus::transformDbMartToNumeric(dbmart.first.sim)
print(object.size(dbmart_num))
print(object.size(dbmart.first.sim))
toc()
tic("tSPMPlus & sequencing")
x <- tSPMPlus::extractNonSparseSequences(df_dbMart =  dbmart_num$dbMart,
                                          numOfThreads = cores,
                                          sparsityValue =  sparsity,
                                          storeSeqDuringCreation = FALSE)
toc()
rm(x)
gc()
toc()
toc()
