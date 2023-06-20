## tSPM vs tSPM+ benchmark
####author Jonas Hügel --jhuegel@mgh.harvard.edu
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
  install.packages("clai_share/shared_workspace/libs/src/tSPMPlus_0.03.004.tar.gz", repos = NULL)
}
if(!require("tictoc")) install.packages("tictoc")

## load and prep the data
tic("Overall")
tic("loading data")
count="first"
pattern = "tSPM"
phenx <- "AD"
load("workspace/AD/data/benchmark_dbmart.first.sim.RData")
load("workspace/AD/data/seq_dat.RData")
toc()

uniqpats <- c(unique(dbmart.first.sim$patient_num))

##now sequence by time this process constructs 2-deep sequences by all observations that happened after 1st observation.
dbseq <- list()
pat.dat.sequence <- list()
seq2deep.agg <- list()

#setup parallel backend to use many processors
cores<-detectCores()
cl <- parallel::makeCluster(cores) #not to overload your computer
doParallel::registerDoParallel(cl)

# define parameters
sparsity = 0.05
tic("tSPM and sequencing")
tic("orignal tSPM")
###traditional implementation
if(pattern == "sequent"){
  for (y in 1:length(uniqpats)) {
    tryCatch({
      print(sprintf(paste0("sequencing data for patient ",y, " of ", length(uniqpats))))
      pat.dat <- subset(dbmart.first.sim,dbmart.first.sim$patient_num == uniqpats[y])
      pat.dat$start_date <- as.POSIXct(pat.dat$start_date, "%Y-%m-%d")
      pat.dat.date <- as.data.table(unique(pat.dat$start_date))
      pat.dat.date[with(pat.dat.date ,order(x)),sequence := .I]
      colnames(pat.dat.date)[1] <- "start_date"
      pat.dat.date$start_date <- as.POSIXct(pat.dat.date$start_date, "%Y-%m-%d")
      pat.dat<- merge(pat.dat,pat.dat.date,by="start_date")
      rm(pat.dat.date)
      max.pat.obs <- max(pat.dat$sequence)
      dbseq[[y]] <- 
        foreach(g = 1: (max.pat.obs-1), 
                .combine = "rbind") %dopar% {
                  seq.0 <- subset(pat.dat,pat.dat$sequence == g)
                  seq.1 <- subset(pat.dat,pat.dat$sequence == g+1)
                  seq.1$sequence.real=seq.1$sequence
                  seq.1$sequence=g
                  pat.dat.sequence <- merge(seq.0,seq.1,by="sequence",allow.cartesian=TRUE)
                  rm(seq.0,seq.1)
                  pat.dat.sequence
                }
      pat.dat.sequence = list()
      rm(pat.dat,max.pat.obs)
      if(endsWith(as.character(y),"500")){gc()}
      
    }, 
    error = function(fr) {cat("ERROR :",conditionMessage(fr), "\n")})
  } 
} else if(pattern != "sequent"){
  for (y in 1:length(uniqpats)) {
    tryCatch({
      print(sprintf(paste0("sequencing data for patient ",y, " of ", length(uniqpats))))
      pat.dat <- subset(dbmart.first.sim,dbmart.first.sim$patient_num == uniqpats[y])
      pat.dat$start_date <- as.POSIXct(pat.dat$start_date, "%Y-%m-%d")
      pat.dat.date <- as.data.table(unique(pat.dat$start_date))
      pat.dat.date[with(pat.dat.date ,order(x)),sequence := .I]
      colnames(pat.dat.date)[1] <- "start_date"
      pat.dat.date$start_date <- as.POSIXct(pat.dat.date$start_date, "%Y-%m-%d")
      pat.dat<- merge(pat.dat,pat.dat.date,by="start_date")
      rm(pat.dat.date)
      max.pat.obs <- max(pat.dat$sequence)
      dbseq[[y]] <- data.frame(foreach(g = 1: (max.pat.obs-1), 
                                       .combine = "rbind") %dopar% {
                                         seq.0 <- subset(pat.dat,pat.dat$sequence == g)
                                         seq.1 <- subset(pat.dat,pat.dat$sequence > g)
                                         seq.1$sequence.real=seq.1$sequence
                                         seq.1$sequence=g
                                         pat.dat.sequence <- merge(seq.0,seq.1,by="sequence",allow.cartesian=TRUE)
                                         rm(seq.0,seq.1)
                                         pat.dat.sequence
                                       },stringsAsFactors=FALSE)
      rm(pat.dat,max.pat.obs)
      pat.dat.sequence = list()
      if(endsWith(as.character(y),"500")){gc()}
      
    }, 
    error = function(fr) {cat("ERROR :",conditionMessage(fr), "\n")})
  }
}
toc()
toc()
toc()