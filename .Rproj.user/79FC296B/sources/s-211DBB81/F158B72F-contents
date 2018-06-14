
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


# Load Data ---------------------------------------------------------------
census_train <- read.csv(file = "census_income_learn.csv", stringsAsFactors = F, header = T)
census_test <- read.csv(file = "census_income_test.csv", stringsAsFactors = F, header = T)
census_train <- data.table(census_train)
census_test <- data.table(census_test)

## I know I'm losing data but 1 row out of 200k will be of negligble significance in this case
setnames(census_train, dput(names(census_train)),
         c("age", "classOfWorker", "industry", "adjGrossIncome", "edu", "wageHr", "eduInLastWk", "maritalStat", "majorIndustry",
           "occupation code", "race", "hispanic", "sex", "laborUnion", "unemploymentReason", "employmentStatus", "capGains", "capLoss",
           "stocks", "fedIncTaxLiable", "taxStatus", "region", "state", "hhStat", "instanceWt", "migrationMSA", "migrationReg",
           "migrationWithInReg", "house1PlusYr", "prevResInSunbelt", "pplWorkForEmp", "fam18under", "foreignDad",
           "foreignMom", "foreign", "citizenship", "bizOrSelfEmp", "vetAdmin", "vetBens", "weeksWorkedPastYr", "year", "over50k"))

setnames(census_test, dput(names(census_train)),
         c("age", "classOfWorker", "industry", "adjGrossIncome", "edu", "wageHr", "eduInLastWk", "maritalStat", "majorIndustry",
           "occupation code", "race", "hispanic", "sex", "laborUnion", "unemploymentReason", "employmentStatus", "capGains", "capLoss",
           "stocks", "fedIncTaxLiable", "taxStatus", "region", "state", "hhStat", "instanceWt", "migrationMSA", "migrationReg",
           "migrationWithInReg", "house1PlusYr", "prevResInSunbelt", "pplWorkForEmp", "fam18under", "foreignDad",
           "foreignMom", "foreign", "citizenship", "bizOrSelfEmp", "vetAdmin", "vetBens", "weeksWorkedPastYr", "year", "over50k"))


# Light Processing --------------------------------------------------------
## Clean up the missing data
census_train <- census_train[, lapply(.SD, function(x) str_replace(x, "Not in universe", "NA"))]
census_test <- census_test[, lapply(.SD, function(x) str_replace(x, "Not in universe", "NA"))]

census_train <- census_train[, lapply(.SD, function(x) str_replace(x, "[?]", "NA"))]
census_test <- census_test[, lapply(.SD, function(x) str_replace(x, "[?]", "NA"))]

## Clean up the binaries 
census_train[grepl(x = over50k, pattern = "-"), over50k := "0"]
census_train[grepl(x = over50k, pattern = "+"), over50k := "1"]

census_test[grepl(x = over50k, pattern = "-"), over50k := "0"]
census_test[grepl(x = over50k, pattern = "+"), over50k := "1"]

census_train[foreignDad == " United-States" | foreignMom == " United-States" | foreign == " United-States",
             `:=`(foreignDad = "0",
                  foreignMom = "0",
                  foreign = "0")]

census_train[foreignDad != "0" | foreignMom != "0" | foreign != "0",
             `:=`(foreignDad = "1",
                  foreignMom = "1",
                  foreign = "1")]


census_test[foreignDad == " United-States" | foreignMom == " United-States" | foreign == " United-States",
             `:=`(foreignDad = "0",
                  foreignMom = "0",
                  foreign = "0")]

census_test[foreignDad != "0" | foreignMom != "0" | foreign != "0",
             `:=`(foreignDad = "1",
                  foreignMom = "1",
                  foreign = "1")]

## Update any data types


