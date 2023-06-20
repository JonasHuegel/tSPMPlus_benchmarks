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
tic("Overall")
tic("Load data")
## load and prep the data
count="first"
pattern = "tSPM"
phenx <- "AD"
load("workspace/AD/data/dbwide_AD.RData")

rm(dbmart.wide)
# ###prepare the raw and sequenced data bases for validation
dbmart <- dplyr::select(dbmart,patient_num,phenx=concept_cd,start_date)

# #sequence the data
# # aggregating by patient and data and observation

dbmart$start_date <- as.POSIXct(dbmart$start_date, "%Y-%m-%d")
# 
uniqpats <- c(unique(dbmart$patient_num))
# 
# ##
setDT(dbmart)
toc()
tic("first occurence")
if (count == "first"){
  ##sequencing but only using the first occurence for each observations
  first.obs <- list()
  for (p in 1:length(uniqpats)) {
    tryCatch({
      pat.dat <- subset(dbmart,dbmart$patient_num == uniqpats[p])
      #store the first observation for each record
      first.obser.date <- ddply(pat.dat,~phenx,summarise,start_date=min(start_date))
      first.obser.date$start_date <- as.POSIXct(first.obser.date$start_date, "%Y-%m-%d")
      pat.dat$start_date <- as.POSIXct(pat.dat$start_date, "%Y-%m-%d")
      pat.dat$unique.key <- paste0(pat.dat$phenx,as.character(pat.dat$start_date,"%Y-%m-%d"))
      first.obser.date$unique.key <- paste0(first.obser.date$phenx,as.character(first.obser.date$start_date,"%Y-%m-%d"))
      #only grab data from the first observations
      pat.dat <- subset(pat.dat, pat.dat$unique.key %in% first.obser.date$unique.key)
      #remove duplicates
      pat.dat <- pat.dat[!duplicated(pat.dat$unique.key), ]
      pat.dat$unique.key <- NULL
      first.obs[[p]] <- pat.dat
      rm(pat.dat,first.obser.date)
    },
    error = function(fr) {cat("ERROR :",conditionMessage(fr), "\n")})
  }
  dbmart.first <- do.call(rbind, lapply(first.obs, data.frame, stringsAsFactors=FALSE))
  rm(first.obs);gc()
  
  #simplify the data
  dbmart.first.sim <- dplyr::select(dbmart.first,patient_num,start_date,phenx)
  rm(dbmart.first)
} else if (count != "first"){
  dbmart.first.sim <- dplyr::select(dbmart.beforehf,patient_num,start_date,phenx)
}
dbmart.first.sim$patient_num <- as.integer(dbmart.first.sim$patient_num)
dbmart.first.sim <- dbmart.first.sim[order(patient_num),]
toc()
toc()
save(dbmart.first.sim,file = "workspace/AD/data/benchmark_dbmart.first.sim.RData")