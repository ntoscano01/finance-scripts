#INPUT DIRECTIONS
##Line 47: Enter ticker symbol
##Line 72: Enter Shares Outstanding - You can find this data on NASDAQ, Yahoo, or the company website
##Line 148 and Line 151 Adjust Histograms if data does not fit plot in charts
##Standard Deviation for control chart is set 1 by default.  To change SD adjust line 128 and line 129

output_dir <- file.path("Your_File_Path")

if (!dir.exists(output_dir)){
  dir.create(output_dir)
} else {
  print("Dir already exists!")
}

getwd()
work <- setwd("Your_File_Path")

packages = c("quantmod", "zoo", "ggplot2", "scales", "pastecs", "dplyr")
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

search()

options(scipen = 999)

file_test <- "Your_File_Path"

library(quantmod)
library(zoo)
library(ggplot2)
library(scales)
library(pastecs)
library(dplyr)

#Fetch data
if (file.exists(file_test)){
  print("File already exists!")
} else {
  
start <- as.Date("2015-01-01")
start_ss <- as.Date("2018-01-01")
end <- Sys.Date()
currentdate <- Sys.Date() 

ticker <- c("DUST")

asset.price <- NULL
for(ticker in ticker)
  asset.price <- na.omit(cbind(asset.price,getSymbols(ticker, from = start, to = end,auto.assign = F)))
head(asset.price,3)
tail(asset.price,3)

#sum(is.na(df))

print(noquote("Writing data to excel."))

csvfilename <- paste("Your_File_Path",sep="")
write.csv(asset.price,file=csvfilename) 

print(noquote("Excel files created and saved to folder."))

#Create data frame and assemble table
df.asset.price<- data.frame(date=index(asset.price), coredata(asset.price))
names(df.asset.price) <- c("Open","High","Low","Close","Volume","Adjusted")
names(df.asset.price) <- c("Date","Open","High","Low","Close","Volume","Adjusted")

#Format datadf.asset.price[c("Shares.Out", "Shares.Remain", "Percent.Shares")]<-NA
df.asset.price$Shares.Out <- 4119000
df.asset.price$Name <- ticker
head(df.asset.price,3)

ss <- subset(df.asset.price, Date > start_ss)

print(noquote("Writing data to excel."))

csvfilename <- paste("Your_File_Path",ticker,"_","anal_data_all",".csv", sep="")
write.csv(df.asset.price,file=csvfilename) 

csvfilename <- paste("Your_File_Path",ticker,"_","anal_data_subset",".csv", sep="")
write.csv(ss,file=csvfilename) 

print(noquote("Excel files create and saved to folder."))

}

#Confirm Output
list.files()

#Import required dataset: All
dataset <- read.csv("Your_File_Path/DUST_anal_data_all.csv")
head(dataset,3) 
tail(dataset,3)
str(dataset)

#Import required dataset: Subset
dataset_ss <- read.csv("Your_File_Path/DUST_anal_data_subset.csv")
head(dataset_ss,3) 
tail(dataset_ss,3)
str(dataset_ss)

#Create price charts
ggplot(title="ticker All Data",data=dataset, aes(x= Date, y= Adjusted, group = 1)) + geom_line()

ggplot(title="ticker Subset Data",data=dataset_ss, aes(x= Date, y= Adjusted, group = 1)) + geom_line()

#Calculate Descriptive stats and assemble table
print(noquote("Descriptive Statistics for sample:")) # nbr.val, nbr.null, nbr.na, min max, range, sum,median, mean, SE.mean, CI.mean, var, std.dev, coef.var
noquote(format(round(stat.desc(dataset$Adjusted), 2), big.mark = ","))
noquote(format(round(stat.desc(dataset$Volume), 2), big.mark = ","))

print(noquote("Descriptive Statistics for subseet:"))

noquote(format(round(stat.desc(dataset_ss$Adjusted, basic = F), 2), big.mark = ","))
noquote(format(round(stat.desc(dataset_ss$Volume, basic = F), 2), big.mark = ","))

dataset <- mutate(dataset, Adjusted.Mean = mean(dataset$Adjusted))
dataset <- mutate(dataset, High.Hi = max(dataset$High))
dataset <- mutate(dataset, Low.Lo = min(dataset$Low))
dataset <- mutate(dataset, UCL = dataset$Adjusted.Mean+(1*sd(dataset$Adjusted)))
dataset <- mutate(dataset, LCL = dataset$Adjusted.Mean-(1*sd(dataset$Adjusted)))
dataset$ID <- seq.int(nrow(dataset))

dataset<-dataset[c("ID","Date","Open","High","Low","Close","Volume","Adjusted","RSI","Adjusted.Mean","High.Hi","Low.Lo","UCL","LCL")]

cat(("Measures of central tendancies for Adjusted Price:"),'\n')
summary((dataset$Adjusted),'\n')
cat("Standard deviation:",sd(dataset$Adjusted),'\n')

options(digits = 4)

cat("High:",signif(max(dataset$High),4),'\n')
cat("Lo:",signif(min(dataset$Low),4),'\n')

cat("Mode Adjusted Prices:", names(table(dataset$Adjusted))[table(dataset$Adjusted)==max(table(dataset$Adjusted))],'\n')
cat("Mode Highs:", names(table(dataset$High))[table(dataset$High)==max(table(dataset$High))],'\n')
cat("Mode Lows:", names(table(dataset$Low))[table(dataset$Low)==max(table(dataset$Low))],'\n')

cat(("The following histograms describe the frequency and range of the adjusted closing prices and the volume."),'\n')

histinfo1<-hist(dataset$Adjusted, breaks=20,xlim=c(20,60), xlab="Adjusted Prices", main="Frequency and Range of Adjusted Closing Prices", col="lightblue", prob=T)
lines(density(dataset$Adjusted))

histinfo2<-hist(dataset$Volume, breaks=160, xlim=c(0,1000000), xlab="Volume", main="Frequency of Volume", col="lightblue", prob=T)
lines(density(dataset$Volume))

sort(table(signif(dataset$Adjusted,4)))
sort(table(signif(dataset$High,4)))
sort(table(signif(dataset$Low,4)))

#Create control chart
cat(("The ticker control chart for full period of data pull"),'\n')
cat(("The ticker control chart displays the price movement between the upper control level and the lovwer control level.  The mean price for the time period is shown.  The UCL and LCL are set to 1 standard deviation.  Control limits can be adjusted in the code."),'\n')

ggplot(dataset, aes(x = dataset$ID))+geom_line(aes(y = dataset$Adjusted),colour ="blue") + geom_line(aes(y = dataset$Adjusted.Mean), colour = "black")+ geom_line(aes(y = dataset$UCL), colour = "orange")+ geom_line(aes(y = dataset$LCL), colour = "orange")+ geom_line(aes(y = dataset$High.Hi), colour = "green")+ geom_line(aes(y = dataset$Low.Lo), colour = "red") + ggtitle("Ticker Control Chart") + xlab("Adjusted Price") + ylab("Observations")+
  scale_x_continuous(name="Adjusted Prices", labels = ) + 
  scale_y_continuous(name="Observations", labels = scales::comma)

ggplot(data=dataset, aes(x=dataset$Date, y=dataset$Volume)) + geom_bar(stat="identity")


print(noquote("Analysis complete."))
