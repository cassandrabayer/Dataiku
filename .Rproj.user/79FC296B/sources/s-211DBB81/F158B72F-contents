
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

# basic stats and prediction
library(stats)
library(forecast)

# Model Selection
library(MASS)
library(glmnet)
library(car)
library(caret)

# Dates
library(zoo)
library(lubridate)


# Custom functions
censusCleaner <- function(dt){
  ## I know I'm losing data but 1 row out of 200k will be of negligble significance in this case
  dt <- data.table(dt)
  
  setnames(dt, dput(names(dt)),
           c("age", "classOfWorker", "industryRecode", "occRecode", "edu", "wageHr", "eduInLastWk", "maritalStat", "majorIndustry",
            "majorOccCode", "race", "hispanic", "sex", "laborUnion", "unemploymentReason", "employmentStatus", 
             "capGains", "capLoss", "stocks", "taxStatus", "region", "state", "hhStat", "hhSum", "instanceWt", "migrationMSA", "migrationReg",
             "migrationWithInReg", "house1PlusYr", "prevResInSunbelt", "pplWorkForEmp", "fam18under", "foreignDad",
             "foreignMom", "foreign", "citizenship", "bizOrSelfEmp", "vetAdmin", "vetBens", "wksWorkedPastYr", "year", "over50k"))
  
  ## Clean up the missing data
  dt <- dt[, lapply(.SD, function(x) str_replace(x, "Not in universe", "NA"))]
  dt <- dt[, lapply(.SD, function(x) str_replace(x, "[?]", "NA"))]
  
  ## Clean up the binaries 
  
  ### Binary for the dependent var
  dt[grepl(x = over50k, pattern = "-"), over50k := "0"]
  dt[grepl(x = over50k, pattern = "+"), over50k := "1"]
  
  ### Binary for race/citizenship
  dt[foreignDad == " United-States" | foreignMom == " United-States" | foreign == " United-States",
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
  
  ### Binary for employment status
  dt[, unemployed := 0]
  dt[classOfWorker %in% c("Without pay", "Never Worked"), unemployed := 1]
  
  ## Update any data types
  dt[, `:=`(age = as.integer(age),
            wageHr = as.integer(wageHr), 
            wksWorkedPastYr = as.integer(wksWorkedPastYr),
            foreignDad = as.integer(foreignDad),
            foreignMom = as.integer(foreignMom),
            foreign = as.integer(foreigin),
            over50k = as.integer(over50k),
            hispanic = as.integer(hispanic))]

  ## Exclude any column that has overwhelming missing data
  
  ## Exclude duplicative or irrelevant columns
  
  
  return(dt)
}

# Load Data ---------------------------------------------------------------
census_train <- read.csv(file = "census_income_learn.csv", stringsAsFactors = F, header = T)
census_test <- read.csv(file = "census_income_test.csv", stringsAsFactors = F, header = T)

# Light Pre Processing ----------------------------------------------------
census_train <- censusCleaner(census_train)
census_test <- censusCleaner(census_test)
