#' Getting data for prediction
#' 
#' @description
#' * Reading forecasting data from [data.csv] and temperature data from [temperature.csv]
#' * Transforming and preparing data for model use
#' * Returning train and test sets
#' 
#' @params
#' @param dateFrom - data range in whole data set starts from this date
#' @param dateTo - data range in whole data set ends on this date
#' @param dataSplitRatio - splits data set into train (<= ratio) and test (> ratio)
#' 
#' @output
#' Returns train and test dataframes for forecasting models


library(dplyr)

GetData <- function(dateFrom = '2014-10-01',
                    dateTo = '2016-05-31',
                    dataSplitRatio = 0.8) {
  
  # dateFrom <- '2014-10-01'
  # dateTo <- '2016-05-31'
  # dataSplitRatio <- 0.8
  
  
  ## Read and join data -----------------------------
  
  ## __ Read gas data -----------------------------
  dataPath <- "./"
  dataName <- "data.csv"
  gasData <- read.csv(
    paste0(dataPath, dataName),
    sep = ",",
    dec = ".",
    header = T,
    encoding = 'WIN-1250'
  )
  gasData <- gasData[, c('date','coef','coef_correction')]
  gasData$date <- as.Date(gasData$date)
  
  
  ## __ Read temperature data -----------------------------
  temperaturePath <- "./"
  temperatureName <- "temperature.csv"
  temperature <- read.csv(
    paste0(temperaturePath, temperatureName),
    sep = ",",
    dec = ".",
    header = T,
    encoding = 'WIN-1250'
  )
  temperature$forecast_date <- as.Date(temperature$forecast_date)
  
  
  ## __ Join data -----------------------------
  dataJoned <- left_join(gasData, temperature, by = c('date' = 'forecast_date'))
  dataJoned$coef <- ifelse(dataJoned$coef >= 0, dataJoned$coef, dataJoned$coef_correction)
  dataJoned <- dataJoned[, c('date','coef','avg_temp','min_temp','max_temp')]
  

  ## Handle NAs -----------------------------
  summary(dataJoned)
  whichNA <- which(is.na(dataJoned$avg_temp))
  whichNAColnames <- c('avg_temp', 'min_temp', 'max_temp')
  # No coef_correction in whichNAColnames because it's normal that it gets NA
  obsToMean <- 3
  for (i in whichNA) {
    obsToMeanMin <- ifelse(i - obsToMean < 1, 1, obsToMean)
    obsToMeanMax <- ifelse(i + obsToMean > nrow(dataJoned), nrow(dataJoned), obsToMean)
    dataToApply <- dataJoned[(i - obsToMeanMin):(i + obsToMeanMax), whichNAColnames]
    replaceValues <- apply(dataToApply, 2, function(x) mean(x, round(na.rm = T), 2))
    dataJoned[i, whichNAColnames] <- replaceValues
  }
  
  
  ## Make new variables -----------------------------
  
  ## __ coef delays -----------------------------
  MakeDelays <- function(delayDays) {
    delay <- c(rep(NA, delayDays), dataJoned$coef[1:(nrow(dataJoned) - delayDays)])
    return(delay)
  }
  dataJoned$coef1 <- MakeDelays(delayDays = 1)
  dataJoned$coef2 <- MakeDelays(delayDays = 2)
  dataJoned$coef7 <- MakeDelays(delayDays = 7)
  dataJoned$coef14 <- MakeDelays(delayDays = 14)
  
  ## __ temperature increments -----------------------------
  #
  
  
  
  ## Change data range -----------------------------
  selectedRows <- dplyr::between(dataJoned$date, as.Date(dateFrom), as.Date(dateTo))
  dataJoned <- dataJoned[selectedRows, ]
  ## Chech for NAs once again
  summary(dataJoned)
  
  
  ## Split to train and test -----------------------------
  dataSplitRow <- floor(dataSplitRatio*nrow(dataJoned))
  train <- dataJoned[1:dataSplitRow, ]
  test <- dataJoned[(dataSplitRow+1):nrow(dataJoned), ]
  
  
}
