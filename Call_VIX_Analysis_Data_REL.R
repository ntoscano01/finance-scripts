output_dir <- file.path("your_file_path")

if (!dir.exists(output_dir)){
  dir.create(output_dir)
} else {
  print("Dir already exists!")
}

getwd()
work <- setwd("your_file_path")

packages = c("quantmod", "zoo")
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

search()

options(scipen = 999)

library(quantmod)
library(zoo)

start <- as.Date("2012-01-01")
end <- Sys.Date()

tickers <- c("^VIX","^GSPC","^IXIC","^DJI","^RUT","^TNX")
#Tickers: 
#^VIX = CBOE Volatility Index https://finance.yahoo.com/quote/%5EVIX?p=^VIX
#^GSPC = S&P 500 https://finance.yahoo.com/quote/%5EGSPC?p=^GSPC
#^IXIC = NASDAQ Composite https://finance.yahoo.com/quote/%5EIXIC?p=^IXIC
#^DJI = Dow Jones Industrial Average https://finance.yahoo.com/quote/%5EDJI?p=^DJI
#^RUT = Russell 2000 https://finance.yahoo.com/quote/%5ERUT?p=^RUT
#^TNX = CBOE Interest Rate 10 Year T No https://finance.yahoo.com/quote/%5ETNX?p=^TNX

asset.price <- NULL
for(ticker in tickers)
  asset.price <- na.omit(cbind(asset.price,getSymbols(ticker, from = start, to = end,auto.assign = F)))
head(asset.price,3) 
tail(asset.price,3)

write.zoo(asset.price, "vix_anal_data.csv",index.name="Date",sep=",")