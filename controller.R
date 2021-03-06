
# Dataiku Controller ------------------------------------------------------

# Set working directory ---------------------------------------------------
setwd("/Users/cassandrabayer/Desktop/Dataiku")

# Load Packages -----------------------------------------------------------
# load basic packages
library(data.table)
library(tidyr)
library(tidyverse)
library(stringr)

# visualization packages
library(ggplot2)
library(plotly)
library(Hmisc)
library(RColorBrewer)
library(rpart.plot)
library(reshape2)
library(shiny)


# basic stats and prediction
library(corrplot)
library(stats)
library(forecast)
library(Amelia)
library(mlbench)
library(rpart)
library(tree)
library(e1071)

# Model Selection
library(MASS)
library(glmnet)
library(car)
library(caret)

# Validation
library(pscl)
library(pROC)
library(ROCR)

# Dates
library(zoo)
library(lubridate)


# Custom Functions --------------------------------------------------------------------------------------
# anyMissing <- function(col) {
#   numMissing <- dt[is.na(col) | col == "NA", .N]
#   return(numMissing)
# }



censusCleaner <- function(dt){
  ## I know I'm losing data but 1 row out of 200k will be of negligble significance in this case
  dt <- data.table(dt)
  
  setnames(dt, dput(names(dt)),
           c("age", "classOfWorker", "industryRecode", "occRecode", "edu", "wageHr", "eduInLastWk", 
             "maritalStat", "majorIndustry", "majorOccCode", "race", "hispanic", "sex", "laborUnion", 
             "unemploymentReason", "employmentStatus", "capGains", "capLoss", "stocks", "taxStatus", "region", 
             "state", "hhStat", "hhSum", "instanceWt", "migrationMSA", "migrationReg", "migrationWithInReg", 
             "house1PlusYr", "prevResInSunbelt", "pplWorkForEmp", "fam18under", "foreignDad", "foreignMom",
             "foreign", "citizenship", "bizOrSelfEmp", "vetAdmin", "vetBens", "wksWorkedPastYr", "year", "over50k"))
  
  ## Clean up the missing data and handle for white space
  dt <- dt[, lapply(.SD, function(x) str_replace(x, "Not in universe", NA_character_))]
  dt <- dt[, lapply(.SD, function(x) str_replace(x, "[?]",NA_character_))]
  dt <- dt[, lapply(.SD, function(x) trimws(x))]
  
  ## Count missing and store
  missing <- colSums(is.na(dt))
  
  ## Take a snapshot of the data
  dtSnapshot <- dt
  
  ### Binary for the dependent var
  dt[grepl(x = over50k, pattern = "-"), over50k := "0"]
  dt[over50k != "0", over50k := "1"]
  
  ## Binaries for sex
  dt[, female := 0]
  dt[, male := 0]
  dt[sex == "Female", female := 1]
  dt[sex == "Male", male := 1]
  
  ### Binary for race/citizenship
  dt[foreignDad == " United-States" | foreignMom == "United-States" | foreign == "United-States",
     `:=`(foreignDad = "0",
          foreignMom = "0",
          foreign = "0")]
  
  dt[foreignDad != "0" | foreignMom != "0" | foreign != "0",
     `:=`(foreignDad = "1",
          foreignMom = "1",
          foreign = "1")]
  
  dt[grepl(x = citizenship, pattern = "naturalization"), citizenship := "Naturalized"]
  dt[grepl(x = citizenship, pattern = "Native"), citizenship := "Native"]
  dt[grepl(x = citizenship, pattern = "Foreign"), citizenship := "Foreign"]
  
  dt[hispanic %in% c("NA", "Do not know"), hispanic := "0"]
  dt[hispanic != "0", hispanic := "1"]
  
  dt[, black := 0]
  dt[race == "Black", black := 1]
  
  dt[, white := 0]
  dt[race == "White", white := 1]
  dt[, race := NULL]
  
  ### Binaries for employment status
  dt[, unemployed := 0]
  dt[classOfWorker %in% c("Without pay", "Never Worked"), unemployed := 1]
  
  dt[, blueCollar := 0]
  dt[majorIndustry %in% c("Construction", "Business and repair services", 
                          "Manufacturing-nondurable goods", "Mining", 
                          "Transportation", "Wholesale trade", 
                          "Private household services", "Utilities and sanitary services",
                          "Agriculture", "Armed Forces"), 
     blueCollar := 1]
  
  dt[, whiteCollar := 0]
  dt[blueCollar == 0, whiteCollar := 1]
  
  ## Binaries for education
  dt[, belowCollege := 0]
  dt[, college := 0]
  dt[, aboveCollege := 0]
  dt[, aboveMasters := 0]
  
  dt[!edu %in% c("Doctorate degree(PhD EdD)", "Prof school degree (MD DDS DVM LLB JD)", 
                 "Associates degree-occup /vocational", "Masters degree(MA MS MEng MEd MSW MBA)",
                 "Bachelors degree(BA AB BS)"), belowCollege := 1]
  
  dt[edu %in% c("Associates degree-occup /vocational", "Bachelors degree(BA AB BS)"), college := 1]
  
  dt[edu %in% c("Doctorate degree(PhD EdD)", "Prof school degree (MD DDS DVM LLB JD)", 
                "Masters degree(MA MS MEng MEd MSW MBA)"), aboveCollege := 1]
  
  dt[edu == "Doctorate degree(PhD EdD)", aboveMasters := 1]
  
  ## binaries for family status a
  dt[, divorced := 0]
  dt[, married := 0]
  dt[, single := 1]
  
  dt[maritalStat == "Divorced", divorced := 1]
  dt[grepl(x = maritalStat, pattern = "Married"), married := 1]
  dt[married == 1, single := 0]
  
  dt[, householder := 0]
  dt[hhStat == "Householder", householder := 1]
  
  dt[, bothParents := 0]
  dt[fam18under == "Both parents present", bothParents := 1]
  
  dt[, children := 0]
  dt[!is.na(fam18under), children := 1]
  
  ## Update any data types
  dt[, `:=`(age = as.integer(age),
            wageHr = as.integer(wageHr), 
            wksWorkedPastYr = as.integer(wksWorkedPastYr),
            foreignDad = as.integer(foreignDad),
            foreignMom = as.integer(foreignMom),
            foreign = as.integer(foreign),
            over50k = as.integer(over50k),
            hispanic = as.integer(hispanic))]
  
  ## Add calculated variables and interaction variables of interest
  dt[year == "94", normalizedWageHr := (1.03 * wageHr)]
  dt[year == 85, normalizedWageHr := wageHr]
  
  dt[, ageSq := age^2]
  
  dt[, whiteDivorcedF := 0]
  dt[, blackDivorcedF := 0]
  dt[, hispanicDivorcedF := 0]
  dt[, whiteDivorcedM := 0]
  dt[, blackDivorcedM := 0]
  dt[, hispanicDivorcedM := 0]
  
  dt[white == 1 & divorced == 1 & female == 1, whiteDivorcedF := 1]
  dt[black == 1 & divorced == 1 & female == 1, blackDivorcedF := 1]
  dt[hispanic == 1 & hispanic == 1 & female == 1, hispanicDivorcedF := 1]
  
  dt[white == 1 & divorced == 1 & male == 1, whiteDivorcedM := 1]
  dt[black == 1 & divorced == 1 & male == 1, blackDivorcedM := 1]
  dt[hispanic == 1 & divorced == 1 & male == 1, hispanicDivorcedM := 1]
  
  ## Count missing values
  #missing <- lapply(dt, function (x) colSums())
  
  ## any final cleaning
  dt <- dt[, lapply(.SD, function(x) as.integer(x))]
  
  ## Exclude duplicative or irrelevant columns (or those with mostly missing data)
  dt <- dt[, .(age, ageSq, male, female, normalizedWageHr, foreignDad, foreignMom, foreign, wksWorkedPastYr, black, 
               white, hispanic, unemployed,blueCollar, whiteCollar, belowCollege, college, aboveCollege, 
               aboveMasters, divorced, married, single, householder, bothParents, children, whiteDivorcedF, 
               blackDivorcedF, hispanicDivorcedF, whiteDivorcedM, blackDivorcedM, hispanicDivorcedM, over50k)]
  
  dt <- list(missingNum = missing,
             missingPct = missing/nrow(dt),
             dtClean = dt,
             dtMessy = dtSnapshot)
  return(dt)
}

# Load Data ---------------------------------------------------------------
census_train <- read.csv(file = "census_income_learn.csv", stringsAsFactors = F, header = T)
census_test <- read.csv(file = "census_income_test.csv", stringsAsFactors = F, header = T)

# Light Pre Processing ----------------------------------------------------
census_train <- censusCleaner(census_train)
census_test <- censusCleaner(census_test)
