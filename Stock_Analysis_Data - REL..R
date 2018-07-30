output_dir <- file.path("Your_File_Path")

if (!dir.exists(output_dir)){
  dir.create(output_dir)
} else {
  print("Dir already exists!")
}

getwd()
work <- setwd("Your_File_Path")

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

start <- as.Date("2017-01-01")
end <- Sys.Date()

tickers <- c("NTDOY")

asset.price <- NULL
for(ticker in tickers)
  asset.price <- na.omit(cbind(asset.price,getSymbols(ticker, from = start, to = end,auto.assign = F)))
head(asset.price,3) 
tail(asset.price,3)

df.asset.price<- data.frame(date=index(asset.price), coredata(asset.price))
names(df.asset.price) <- c("Open","High","Low","Close","Volume","Adjusted")
names(df.asset.price) <- c("Date","Open","High","Low","Close","Volume","Adjusted")

df.asset.price[c("Shares.Out", "Shares.Remain")]<-NA
df.asset.price$Shares.Out <- 120130000
df.asset.price$Shares.Remain <- df.asset.price$Shares.Out - df.asset.price$Volume

head(df.asset.price,3)

library(ggplot2)
require(gghighlight)
ggplot(title="NTDOY",data=df.asset.price, aes(x= Date, y=Adjusted, group=1)) +
  geom_line()

ss <- subset(df.asset.price, Date > as.Date("2018-01-01"))

write.zoo(asset.price, "NTDOY_anal_data.csv",index.name="Date",sep=",")

write.zoo(df.asset.price, "NTDOY_anal_data_all.csv",index.name="Date",sep=",")
