
clean_data <- function(data_in){
	data_in$from_station_name <- as.character(data_in$from_station_name)
	data_in$to_station_name <- as.character(data_in$to_station_name)

	#### create age
	data_in$age <- 2015 - data_in$birthday
	data_in$age_cat <- "0-30"
	data_in$age_cat[is.na(data_in$age)] <- NA
	data_in$age_cat[data_in$age >= 31] <- "31-35"
	data_in$age_cat[data_in$age >= 36] <- "36-40"
	data_in$age_cat[data_in$age >= 41] <- "41-34"
	data_in$age_cat[data_in$age >= 51] <- "51+"

	data_in$from_month <- as.numeric(substr(data_in$starttime,6,7))
	data_in$from_hour  <- as.numeric(substr(data_in$starttime,12,13))
	data_in$to_hour    <- as.numeric(substr(data_in$stoptime,12,13))

	data_in$from_time <- substr(data_in$starttime,12,16)
	data_in$to_time   <- substr(data_in$stoptime,12,16)


	data_in$start_date <- as.Date(substr(data_in$starttime,1,10),"%Y-%m-%d")
	data_in$weekdays <- "weenday"
	data_in$weekdays[weekdays(data_in$start_date) %in% c("Saturday","Sunday")] <- "weekend"

	
	return(data_in)
}


clean_subs_data <- function(data_in){
	data_in <- data_in[!is.na(data_in$birthday),]
	#### cut off extreme point
	data_in <- data_in[data_in$tripduration <= 3500,]
	
	#### cut off old people
	data_in <- data_in[data_in$age <= 100,]
	
	
}







