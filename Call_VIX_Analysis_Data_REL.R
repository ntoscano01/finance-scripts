output_dir <- file.path("Your_File_Path")

if (!dir.exists(output_dir)){
  dir.create(output_dir)
} else {
  print("Dir already exists!")
}

getwd()
work <- setwd("Your_File_Path")

packages = c("quantmod", "zoo", "ggplot2", "corrplot")
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

tickers <- c("^VIX","^GSPC","^IXIC")
#Tickers: 
#^VIX = CBOE Volatility Index https://finance.yahoo.com/quote/%5EVIX?p=^VIX
#^GSPC = S&P 500 https://finance.yahoo.com/quote/%5EGSPC?p=^GSPC
#^IXIC = NASDAQ Composite https://finance.yahoo.com/quote/%5EIXIC?p=^IXIC

asset.price <- NULL
for(ticker in tickers)
  asset.price <- na.omit(cbind(asset.price,getSymbols(ticker, from = start, to = end,auto.assign = F)))
head(asset.price,3) 
tail(asset.price,3)

df.asset.price<- data.frame(date=index(asset.price), coredata(asset.price))
names(df.asset.price) <- c("Date","VIX.Open","VIX.High","VIX.Low","VIX.Close","VIX.Volume","VIX.Adjusted",
                    "GSPC.Open","GSPC.High","GSPC.Low","GSPC.Close","GSPC.Volume","GSPC.Adjusted",
                    "IXIC.Open","IXIC.High","IXIC.Low","IXIC.Close","IXIC.Volume","IXIC.Adjusted")

head(df.asset.price,3)

library(corrplot)

cor.asset.price<-df.asset.price[, c(7,13,19)]
cat(("Correlation to major indexes"),'\n')
res <- cor(cor.asset.price)
round(res, 4)

library(ggplot2)

ggplot(title="VIX",data=df.asset.price, aes(x= Date, y=VIX.Adjusted, group=1)) +
  geom_line()

ss <- subset(df.asset.price, Date > as.Date("2018-01-01"))

ggplot(title="VIX",data=ss, aes(x= Date, y=VIX.Adjusted, group=1)) +
  geom_line()

ggplot(title="S&P 500",data=ss, aes(x= Date, y=GSPC.Adjusted, group=1)) +
  geom_line()

ggplot(title="NASDAG Composite",data=ss, aes(x= Date, y=IXIC.Adjusted, group=1)) +
  geom_line()

print("VIX values greater than 30 are generally associated with a large amount of volatility as a result of investor fear or uncertainty, while values below 20 generally correspond to less stressful, even complacent, times in the markets.")

x <- tail(asset.price$VIX.Adjusted,1) 
if(x >=30){
  print("Indicator of high volatility")
} else if (x <= 20) {
  print("Indicator of low volatility")
} else
    print("Average market")
print(tail(asset.price$VIX.Adjusted,1))

write.zoo(asset.price, "vix_anal_data.csv",index.name="Date",sep=",")

write.zoo(df.asset.price, "vix_anal_data_all.csv",index.name="Index",sep=",")