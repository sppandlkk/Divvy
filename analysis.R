library(shiny)
library(ggplot2)
library(ggmap)
library(gplots)
library(TSP)

# read in the data
trips <- read.csv("./data/Divvy_Trips_2013_t.csv")
stations <- read.csv("./data/Divvy_Stations_2013.csv")

#### load function
source("./clean_data.r")
data_clean <- clean_data(trips)

#### first restrict to member
trips_subs <- data_clean[data_clean$usertype=="Subscriber",]
trips_cust <- data_clean[data_clean$usertype=="Customer",]

####
trips_subs <- clean_subs_data(trips_subs)


#####
p <- ggplot(data_clean, aes(x=from_month,fill=weekdays)) + geom_histogram(binwidth=1) + facet_grid(.~usertype) + xlim(0,24)

###  TSP
start_id <- 59
chosen_station_id <- c(90,25,286,341)
n_station <- length(chosen_station_id)
ss <- stations[stations$id %in% c(start_id,chosen_station_id),c("latitude", "longitude")]

best_route <- as.integer((solve_TSP(ETSP(ss))))
start_index <- which(best_route==1)
best_sol <- rep(best_route,2)[start_index:(start_index+n_station)]
final_route <-do.call(rbind,lapply((c(start_id,chosen_station_id)[best_sol]),function(x) stations[stations$id==x,]))
final_route <- data.frame(rbind(final_route,final_route[1,]))
### compute information
compute_avg_time <- do.call(rbind,
lapply(1:(n_station+1),function(i){
	data_temp <- data_clean[(data_clean$from_station_id ==(final_route[i,"id"]))&(data_clean$to_station_id ==(final_route[i+1,"id"])),]
	data.frame(from_id=final_route[i,"id"],from_station=stations[stations	$id==final_route[i,"id"],"name"],
	  to_id=final_route[i+1,"id"],to_station=stations[stations$id==final_route[i+1,"id"],"name"],
	  number_of_route=dim(data_temp)[1],avg_time=mean(data_temp$tripduration))
}))
compute_avg_time




