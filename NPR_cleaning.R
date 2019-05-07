library(dplyr)
library(ggplot2)
library(lubridate)

csvlist = c("NPR.1A.csv", "NPR.CodeSwitch.csv", "NPR.Embedded.csv", 
           "NPR.NewsNow.csv", "NPR.UpFirst.csv", 
           "NPR.HereAndNow.csv", "NPR.FreshAir.csv", "NPR.LatinoUSA.csv")

politics = read.csv("NPR.Politics.csv", stringsAsFactors = FALSE)
politics$Show = "Politics"

for (csv in csvlist) {
  temp = read.csv(csv, stringsAsFactors = FALSE)
  tempstr = gsub("NPR.", "", csv) 
  tempstr = gsub(".csv", "", tempstr)
  temp$Show = tempstr
  politics = rbind(politics, temp)
}

politics$Date = as.Date(parse_date_time(politics$Date, orders = c('mdy', 'dmY', 'Ymd')))

write.csv(politics, file = "NPR.Total.csv")

total = read.csv("NPR.Total.csv", stringsAsFactors = FALSE)
sample = read.csv("NPR.sample.csv", stringsAsFactors = FALSE)

###Polarity Boxplots
sample %>% group_by(Rating) %>% 
  ggplot(., aes(x = Rating, y = Polarity)) +
  geom_boxplot() +
  facet_wrap(~ Show) +
  ggtitle("Podcast Review Polarity by Rating")

sample$Rating = as.character(sample$Rating)

###Avg rating across news podcasts
total %>% summarise(Avgrating = mean(Rating))

###Avg rating per year
total %>% mutate(Rev_Year = year(Date)) %>% 
  group_by(Rev_Year) %>% 
  summarise(Avgrating = mean(Rating)) %>% 
  ggplot(., aes(x = Rev_Year, y = Avgrating)) +
  geom_line() + 
  facet_wrap(Show) +
  ggtitle("Average Podcast Review Rating per Year") +
  xlab("Year") + ylab("Average Rating")

###Chi-Square year v. rating
year_num = total %>% 
  mutate(Rev_Year = year(Date)) %>% 
  group_by(Rev_Year, Rating) %>% 
  summarise(review_num = n())
year_num
chisq.test(year_num$Rev_Year, year_num$Rating)

###Time series of number of reviews 
sample %>% mutate(Rev_year = year(Date)) %>% 
  group_by(Rev_year) %>% 
  summarise(total = n()) %>% 
  ggplot(., aes(x = Rev_year, y = total)) +
  geom_line() +
  ggtitle("Total Reviews Left per Year") +
  xlab("Year") + ylab("Reviews Left")


###What are the ratings by show?
sample %>% 
  mutate(Rev_year = year(Date)) %>% 
  group_by(Show, Rev_year) %>% 
  summarise(review_num = n()) %>% 
  ggplot(., aes(x = Rev_year, y = review_num)) +
  geom_line() + facet_wrap(~ Show) +
  ggtitle("Reviews Over Time by Show") +
  xlab("Year") + ylab("Reviews Left")


###What's up with October 12, 2016?
twentysix = total %>% 
  group_by(Date) %>% 
  summarise(most = n()) %>% 
  ggplot(., aes(x=Date, y = most)) +
  geom_histogram(stat = "identity", bins = 100)
  
october12 = total %>% filter(Date == "2016-10-12")

  ggplot(., aes(x=Date)) +
  geom_histogram(stat = "count")
