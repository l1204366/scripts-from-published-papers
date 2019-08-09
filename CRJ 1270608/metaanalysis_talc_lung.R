# Meta-analysis of talc and lung cancer

# set-up:
rm(list=ls(all=TRUE))
ls()

# put "metaanalysis_raw_data.csv" into a working directory
setwd("B:/talc/meta review")

# Load required packages: metafor
if(require(metafor)==FALSE){install.packages("metafor");require(metafor)} 

# Load data: 
  meta04lung <- read.csv("metaanalysis_raw_data.csv", header=T) #read csv  
  summary(meta04lung)
  meta04lung = meta04lung[1:9][complete.cases(meta04lung[1:9]),]
  meta04lung$logsmr = log(meta04lung$obs / meta04lung$exp)
  meta04lung$selogsmr = 1 / sqrt(meta04lung$obs)
  meta04lung.gen = metagen(logsmr, selogsmr, study, sm="HR",data=meta04lung)
  meta04lung.gen
  forest(meta04lung.gen)
  funnel(meta04lung.gen)
  # Egger's test for publication bias
  metabias(meta04lung.gen, method.bias = "linreg", plotit = T)
  
  # Sensitivity analysis: asbestos contamination 
  meta04lung.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04lung, byvar = contamination)
  meta04lung.byvar
  forest(meta04lung.byvar)
  # contamination = 0
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung, contamination==0))
  # contamination = 1
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung, contamination==1))
  
  # Sensitivity analysis: talc-producing vs. user industries 
  meta04lung$talcmine = c(0,1,1,1,0,0,0,0,1,0,0,1,1,1)
  meta04lung.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04lung, byvar = talcmine)
  meta04lung.byvar
  forest(meta04lung.byvar)
  # user industries
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung, talcmine==0))
  # talc-producing industry
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung, talcmine==1))
  
  # Sensitivity analysis: geography 
  meta04lung$geography01 = as.numeric(meta04lung$geography)
  meta04lung.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04lung[-6,], byvar = geography01)
  meta04lung.byvar
  forest(meta04lung.byvar)
  # China + Russia
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung[-6,], geography01==1))
  # Europe
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung[-6,], geography01==2))
  # North America
  metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04lung[-6,], geography01==4))
  
  # Sensitivity analysis: remove Stern et al.
  meta04lung.gen = metagen(logsmr, selogsmr, study, sm="HR",data=meta04lung[-8,])
  meta04lung.gen
  forest(meta04lung.gen)
  funnel(meta04lung.gen)
  
