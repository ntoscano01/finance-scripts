# finance-scripts
These scripts are written to assist wtih financial research.  I do not recommend to use these scripts for to make trading decisions.

# Stock_Analysis_Data_REL
This script fetches ticker data and arranges data to a data frame.  It then performs a series of tasks:
1. Calculate descriptive statistics
2. Create histogram of volume frequency
3. Create line chart of stock price
4. Create control chart
5. Save the data as three separate csv files to disc

The following packages are required to run the script:
quantmod
zoo
ggplot2
scales
pastecs
dplyr
