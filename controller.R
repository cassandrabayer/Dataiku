
# Dataiku Controller ------------------------------------------------------

# Set working directory ---------------------------------------------------
setwd("/Users/cassandrabayer/Desktop/Dataiku")

# Load Packages -----------------------------------------------------------
# load basic packages
library(data.table)
library(tidyr)
library(tidyverse)

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
census_train <- read.csv(file = "census_income_learn.csv", stringsAsFactors = F,header = T)
census_train <- data.table(census_train)

## I know I'm losing data but 1 row out of 200k will be of negligble significance in this case
setnames(census_train, dput(names(census_train)),
                         c("age", "classOfWorker", "industry", "adjGrossIncome", "edu", "wageHr", "eduInLastWk", "maritalStat", "majorIndustry",
                           "occupation code", "mac", "hispanic", "sex", "laborUnion", "unemploymentReason", "employmentStatus", "capGains", "capLoss",
                           "stocks", "fedIncTaxLiable", "taxStatus", "region", "state", "hhStat", "instanceWt", "migrationMSA", "migrationReg",
                           "migrationWithInReg", "house1PlusYr", "prevResInSunbelt", "pplWorkForEmp", "fam18under", "totalEarn", "fatherOrigin",
                           "motherOrigin", "selfOrigin", "citizenship", "totalInc", "bizOrSelfEmp", "taxableInc", "vetAdmin", "weeksWorkedPastYr"))

census_test <- read.csv()

