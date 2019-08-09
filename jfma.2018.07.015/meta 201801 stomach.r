# Talc Exposure and Risk of Stomach Cancer: Systemic review and Meta-Analysis of Occupational Cohort Studies
# set-up:
rm(list=ls(all=TRUE))
ls()
# Load required packages: meta, metafor
if(require(meta)==FALSE){install.packages("meta");require(meta)} 
if(require(metafor)==FALSE){install.packages("metafor");require(metafor)} 
if(require(gsheet)==FALSE){install.packages("gsheet");require(gsheet)}  # for reading online spreadsheet
# continuous data: 
meta04stomach <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1BYMCu3gKjjY5fYXPfIlxdufU8K0JSXWB1-EIVym_1j8/edit#gid=109663468')  
summary(meta04stomach)
meta04stomach$logsmr = log(meta04stomach$obs / meta04stomach$exp)
meta04stomach$selogsmr = 1 / sqrt(meta04stomach$obs)
meta04stomach.gen = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, comb.fixed = F)
meta04stomach.gen
forest(meta04stomach.gen, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
funnel(meta04stomach.gen)
# Egger's test for publication bias
metabias(meta04stomach.gen, method.bias = "linreg", plotit = T)


# Sensitivity analysis: asbestos contamination 
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, byvar = contamination, comb.fixed = F)
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# contamination = 0
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, contamination==0), comb.fixed = F)
# contamination = 1
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, contamination==1), comb.fixed = F)


# Sensitivity analysis: talc-producing vs. user industries 
meta04stomach$talcmine # 1 = talc-producing, 0 = user industries 
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, byvar = talcmine, comb.fixed = F)
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# user industries
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, talcmine==0), comb.fixed = F)
# talc-producing industry
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, talcmine==1), comb.fixed = F)


# Sensitivity analysis: geography 
meta04stomach$Location # ""=multi-national
exclude_multination = meta04stomach$Location != "" # to excluded McLean et al.
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach[exclude_multination, ], byvar = Location, comb.fixed = F) # excluded McLean et al.
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# Asia (China + Russia)
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach[exclude_multination, ], Location=="Asia"), comb.fixed = F)
# Russian vs. Chinese studies
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach[exclude_multination, ], Location=="Asia"), byvar = language, comb.fixed = F)
# Europe
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach[exclude_multination, ], Location=="Europe"), comb.fixed = F)
# North America
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach[exclude_multination, ], Location=="North America"), comb.fixed = F)


# Sensitivity analysis: duration of follow-up 
meta04stomach$duration = cut(meta04stomach$duration_followed, c(0, 20, 40, 100), right = F, labels = c("<20 years", "20-40 years", ">=40 years"))
summary(meta04stomach$duration)
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, byvar = duration, comb.fixed = F)
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# <20 years
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, duration_followed < 20), comb.fixed = F)
# 20-40 years
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, duration_followed >= 20 & duration_followed < 40), comb.fixed = F)
# >=40 years
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, duration_followed >= 40), comb.fixed = F)


# Sensitivity analysis: language 
summary(meta04stomach$language)
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, byvar = language, comb.fixed = F)
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# English
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, language == "English"), comb.fixed = F)
# Chinese
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, language == "Chinese"), comb.fixed = F)


# Sensitivity analysis: study quality (NOS score)
meta04stomach$quality = cut(meta04stomach$NOS_score, c(6, 8, 10), right = F, labels = c("medium", "high"))
summary(meta04stomach$quality)
meta04stomach.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach, byvar = quality, comb.fixed = F)
meta04stomach.byvar
forest(meta04stomach.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# medium
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, quality == "medium"), comb.fixed = F)
# high
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach, quality == "high"), comb.fixed = F)


# was there any difference in the study quality by geographic location
table(meta04stomach[exclude_multination, ]$NOS_score, meta04stomach[exclude_multination, ]$Location)
aggregate(meta04stomach[exclude_multination, ]$NOS_score, by=list(meta04stomach[exclude_multination, ]$Location), FUN=median)
aggregate(meta04stomach[exclude_multination, ]$NOS_score, by=list(meta04stomach[exclude_multination, ]$Location), FUN=IQR)
kruskal.test(meta04stomach[exclude_multination, ]$NOS_score ~ meta04stomach[exclude_multination, ]$geography_code)


# Influence of excluding each individual cohort (leave-one-out method)
meta04stomach.gen.inf = metainf(meta04stomach.gen, pooled = "random")
meta04stomach.gen.inf
forest(meta04stomach.gen.inf, overall = F, smlab = "Meta-SMR", leftlabs = c(""), rightlabs = c("Meta-SMR", "95%-CI"))


# Sensitivity analysis: gender
meta04stomach_gender <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1BYMCu3gKjjY5fYXPfIlxdufU8K0JSXWB1-EIVym_1j8/edit#gid=2017095868')  
summary(meta04stomach_gender)
meta04stomach_gender$logsmr = log(meta04stomach_gender$obs / meta04stomach_gender$exp)
meta04stomach_gender$selogsmr = 1 / sqrt(meta04stomach_gender$obs)
meta04stomach_gender$Gender # mixed --> to be excluded
exclude_mixedgender = meta04stomach_gender$Gender != "mixed" # to excluded McLean et al.
meta04stomach_gender.byvar = metagen(logsmr, selogsmr, study, sm="HR",data=meta04stomach_gender[exclude_mixedgender, ], byvar = Gender, comb.fixed = F)
meta04stomach_gender.byvar
forest(meta04stomach_gender.byvar, smlab = "SMR", leftlabs = c("Study", "logSMR", "SE"), rightlabs = c("SMR", "95%-CI", "Weights"))
# female
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach_gender[exclude_mixedgender, ], Gender=="female"), comb.fixed = F)
# male
metagen(logsmr, selogsmr, study, sm="HR",data=subset(meta04stomach_gender[exclude_mixedgender, ], Gender=="male"), comb.fixed = F)

