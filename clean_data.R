#temp <- tempfile()
#download.file("http://s3.amazonaws.com/divvy-data/datachallenge/datachallenge.zip",temp)
#trips <- read.csv(unz(temp, "Data Challenge 2013_2014/Divvy_Stations_Trips_2013/Divvy_Trips_2013.csv"))
#unlink(temp)


#stations <- read.csv("data/Divvy_Stations_2013.csv")
#trips <- read.csv("data/Divvy_Trips_2013.csv")


#### first restrict to member
trips_subs <- trips[trips$usertype=="Subscriber",]
trips_subs <- trips[!is.na(trips$birthday),]
#### cut off extreme point
trips_subs <- trips_subs[trips_subs$tripduration <= 1440,]

####
trips_subs$from_station_name <- as.character(trips_subs$from_station_name)
trips_subs$to_station_name <- as.character(trips_subs$to_station_name)

### create age variable
trips_subs$age <- 2015 - trips_subs$birthday
trips_subs$age_cat <- "0-30"
trips_subs$age_cat[trips_subs$age >= 31] <- "31-35"
trips_subs$age_cat[trips_subs$age >= 36] <- "36-40"
trips_subs$age_cat[trips_subs$age >= 41] <- "41-34"
trips_subs$age_cat[trips_subs$age >= 51] <- "51+"
#table(trips_subs$age_cat)
