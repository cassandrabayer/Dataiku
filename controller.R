# refreshenvironment

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

#Dates
library(zoo)
library(lubridate)

census_train <- read.csv(file = "census_income_learn.csv", stringsAsFactors = F)


