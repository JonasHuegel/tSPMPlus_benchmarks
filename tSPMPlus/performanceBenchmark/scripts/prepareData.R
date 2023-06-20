## tSPM vs tSPM+ benchmark
####author Jonas Hügel --jhuegel@mgh.harvard.edu
###author: Hossein Estiri -- hestiri@mgh.harvard.edu

####  Install and load the required packages
if(!require(pacman)) install.packages("pacman")

pacman::p_load(data.table, devtools, backports, Hmisc, tidyr,dplyr,ggplot2,plyr,scales,
               httr, DT, lubridate, tidyverse,reshape2,foreach,doParallel,epitools,rbenchmark)
##first, load the packages and sure they are installed for the benchmark!
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
  install.packages("~/clai_share/shared_workspace/libs/src/tSPMPlus_0.03.004.tar.gz", repos = NULL)
}
if(!require("tictoc")) install.packages("tictoc")
tic("Overall")
tic("Load data")
## load and prep the data
basePath = "../data/syntethicData/100k_synthea_covid19_csv/"

med <- fread(paste0(basePath, "medications.csv"))
med <- med %>% select(START,PATIENT,CODE,DESCRIPTION)
colnames(med) <- c("start_date", "patient_num", "phenx", "description")
med$phenx <- as.character(med$phenx)

proc <-fread(paste0(basePath, "procedures.csv"))
proc <- proc %>%  select(DATE,PATIENT,CODE,DESCRIPTION)
colnames(proc) <- c("start_date", "patient_num", "phenx", "description")
proc$phenx <- as.character(proc$phenx)

devices <- fread(paste0(basePath, "devices.csv"))
devices <- devices %>% select(START,PATIENT,CODE,DESCRIPTION)
colnames(devices) <- c("start_date", "patient_num" , "phenx", "description")
devices$phenx <- as.character(devices$phenx)

allergies <- fread(paste0(basePath, "allergies.csv"))
allergies <- allergies %>%  select(START,PATIENT,CODE,DESCRIPTION)
colnames(allergies) <- c("start_date", "patient_num", "phenx", "description")
allergies$phenx <- as.character(allergies$phenx)

immunizations <-  fread(paste0(basePath, "immunizations.csv"))
immunizations <- immunizations %>% select(DATE,PATIENT,CODE,DESCRIPTION)
colnames(immunizations) <- c("start_date", "patient_num", "phenx", "description")
immunizations$phenx <- as.character(immunizations$phenx)

observations <- fread(paste0(basePath, "observations.csv"))
observations <- observations %>% select(DATE,PATIENT,CODE,DESCRIPTION)
colnames(observations) <- c("start_date", "patient_num", "phenx", "description")
observations$phenx <- as.character(observations$phenx)


conditions <- fread(paste0(basePath, "conditions.csv"))
conditions <- conditions %>% select(START,PATIENT,CODE,DESCRIPTION)
colnames(conditions) <- c("start_date", "patient_num", "phenx", "description")
# move startdate from covid 2 years in the past, to find more canidates later
conditions <- conditions %>% mutate(start_date = start_date - ifelse( description == "COVID-19", 365*2, 0))
conditions$phenx <- as.character(conditions$phenx)

dbmart <- data.frame(start_date=character(),
                     patient_num=character(),
                     phenx=character(),
                     description=character())
dbmart <- rbind(dbmart, observations)
dbmart <- rbind(dbmart, med)
dbmart <- rbind(dbmart, proc)
dbmart <- rbind(dbmart, devices)
dbmart <- rbind(dbmart,allergies)
dbmart <- rbind(dbmart, immunizations)
dbmart <- rbind(dbmart, conditions)

dbmart$phenx = as.vector(dbmart$phenx)
toc()
tic("transform to numeric")
db  <- tSPMPlus::transformDbMartToNumeric(dbmart)
setDT(db)
toc()

save(db,file = "../data/syntethicData/performanceBenchmark.RData")
toc()