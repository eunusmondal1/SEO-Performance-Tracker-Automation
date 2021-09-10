setwd("~/")
library.path <-.libPaths()[1]
library("googleAnalyticsR")
library("searchConsoleR")
library("googlesheets4")
require("dplyr")
library("lubridate")
ga_auth(email = "abc@gmail.com") #paste your google analytics email address
scr_auth(email = "abc@gmail.com") #paste your google search console email address 
gs4_auth(email = "abc@gmail.com") #paste your google sheet email address 

GAA1 <- google_analytics(123456789, # paste google analytics id that can be found in google analytics View
                         date_range = c("60daysAgo", "31daysAgo", "30daysAgo", "yesterday"),
                         metrics = c("Pageviews","sessions","AvgSessionDuration","bouncerate"),
                         dimensions = c("medium"),
                         max = -1) 
GAA2<- data.frame(GAA1)
GAA3 <- GAA2[GAA2$medium == "organic", ] 
GAA4 <- mutate(GAA3,
               Page_Per_Session.d1 = Pageviews.d1 / sessions.d1,
               Page_Per_Session.d2 = Pageviews.d2 / sessions.d2)
GAA5 <- mutate(GAA4,
               Page_Views = Pageviews.d2- Pageviews.d1,
               Sessions = sessions.d2 - sessions.d1,
               Avg_Session_Duration = AvgSessionDuration.d2 - AvgSessionDuration.d1,
               Bounce_Rate = bouncerate.d2 - bouncerate.d1,
               Page_Per_Session = Page_Per_Session.d2 - Page_Per_Session.d1)
GAA5["Date"]<-today()
GAA6 <- GAA5 [ , c("Date","Page_Views","Sessions", "Avg_Session_Duration", "Bounce_Rate","Page_Per_Session")]
#working on google console
GCA1 <- search_analytics("https://abc.com/",  # paste your google console website link
                         startDate = Sys.Date() - 62,
                         endDate = Sys.Date() - 33,
                         searchType = c("web"),
                         rowLimit = 10,
                         walk_data = "byBatch")
GCA2 <- search_analytics("https://abc.com/", # paste your google console website link
                         startDate = Sys.Date() - 32,
                         endDate = Sys.Date() - 3,
                         searchType = c("web"),
                         rowLimit = 10,
                         walk_data = "byBatch")



GCA3<-GCA2-GCA1

GCA3$Account <- c("Account Name") # Put your Account Name that you want to know the performance 

GCA3["Date"]<-today()

GCA4 <- GCA3 [ , c("Account","Date","clicks", "impressions", "ctr")]
GAGCA <- merge (GCA4, GAA6, by = "Date")

ss <- gs4_get("google sheet url") #Paste google sheet url             

#Below 8 lines for Writing data from the first time in a google sheet
range_write(
  ss,
  GCA4,
  sheet = 1,
  range = NULL,
  col_names = TRUE,
  reformat = TRUE
)
##For writing data on existing sheet
sheet_append(
  ss,
  GCA4
)
