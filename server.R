library(shiny)
library(ggplot2)
library(ggmap)
library(gplots)

# read in the data
trips <- read.csv("./data/Divvy_Trips_2013_t.csv")
stations <- read.csv("./data/Divvy_Stations_2013.csv")
landmark <- read.csv("./data/landmark.csv")

#### load function
source("./clean_data.r")
data_clean <- clean_data(trips)

#### first restrict to member
trips_subs <- data_clean[data_clean$usertype=="Subscriber",]
trips_cust <- data_clean[data_clean$usertype=="Customer",]

####
trips_subs <- clean_subs_data(trips_subs)



function(input, output) {
		
  dataset_all <- reactive({
	dd <- data_clean
  	if(input$from_station_name != "ALL"){
    		dd <- dd[dd$from_station_name %in% input$from_station_name,]
    	}
   	if(input$to_station_name != "ALL"){
     		dd <- dd[dd$to_station_name %in% input$to_station_name,]
     	}
	return(dd)
  })
  
    dataset_subs <- reactive({
	dd <- trips_subs
  	if(input$from_station_name != "ALL"){
    		dd <- dd[dd$from_station_name %in% input$from_station_name,]
    	}
   	if(input$to_station_name != "ALL"){
     		dd <- dd[dd$to_station_name %in% input$to_station_name,]
     	}
	return(dd)
  })

  dataset_by_start <- reactive({
	dd <- trips_subs
  	if(input$from_station_name != "ALL"){
    		dd <- dd[dd$from_station_name %in% input$from_station_name,]
    	}
	tt <- table(dd$to_station_id)
	merge(data.frame(id=names(tt),cnt=c(tt)),stations[,c("longitude","latitude","id")],by="id")
  })

  dataset_by_to <- reactive({
	dd <- trips_subs
   	if(input$to_station_name != "ALL"){
     		dd <- dd[dd$to_station_name %in% input$to_station_name,]
     	}
	tt1 <- table(dd$from_station_id)
	merge(data.frame(id=names(tt1),cnt=c(tt1)),stations[,c("longitude","latitude","id")],by="id")
  })


#### first panel
####
	output$hist_for_weekdays <- renderPlot({
		p <- ggplot(dataset_all(), aes(x=from_hour,fill=weekdays)) + geom_histogram(binwidth=1) + facet_grid(.~usertype) + xlim(0,24)
		print(p)
  }, height=300)
  
	output$hist_for_month <- renderPlot({
		p <- ggplot(dataset_all(), aes(x=from_month,fill=weekdays)) + geom_histogram(binwidth=1) + facet_grid(.~usertype) + xlim(0,24)
		print(p)
  }, height=300)



#### for creating the plot
  output$hist_for_duration <- renderPlot({
		p <- ggplot(dataset_all(), aes(x=tripduration,fill=weekdays)) + geom_histogram(binwidth=input$binwidth_for_duration) + facet_grid(.~usertype) + xlim(0,input$limit_for_duration)
		print(p)
  }, height=300)

  output$hist_for_month <- renderPlot({
    p <- qplot(from_month,data=dataset_all(),  geom="histogram", binwidth=1)

	facet_col <- "."	
	facet_row <- "."

    if (input$by_age)	facet_col <- "age_cat"
    if (input$by_gender)	facet_row <- "gender"
    
  
    facets <- paste(facet_row, '~', facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)


    print(p)

  }, height=600)
  
  output$hist_for_from_hour <- renderPlot({
    p <- qplot(from_hour,data=dataset_all(),  geom="histogram", binwidth=1)

	facet_col <- "."	
	facet_row <- "."

    if (input$by_age)	facet_col <- "age_cat"
    if (input$by_gender)	facet_row <- "gender"
    
  
    facets <- paste(facet_row, '~', facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)


    print(p)

  }, height=600)

#### second panel
####  landmark 
	output$landmark_table <- renderTable({
		start_id <- stations[stations$name==input$trip_start_name,"id"]
		chosen_station_id <- landmark[input$landmark_selected,"id"]
		n_station <- length(chosen_station_id)
		ss <- stations[stations$id %in% c(start_id,chosen_station_id),c("id","latitude", "longitude")]

		best_route <- as.integer((solve_TSP(ETSP(ss[,2:3]))))
		start_index <- which(best_route==1)
		best_sol <- rep(best_route,2)[start_index:(start_index+n_station)]
		
		final_route <-do.call(rbind,lapply((c(start_id,chosen_station_id)[best_sol]),function(x) 					stations[stations$id==x,]))
		final_route <- data.frame(rbind(final_route,final_route[1,]))
### compute information
### first create_new landmark
		landmark$landmark <- as.character(landmark$landmark)
		landmark_new <- rbind(landmark[,c("landmark","id")],c("Trip Start Station",start_id))
		compute_avg_time <- do.call(rbind,
		lapply(1:(n_station+1),function(i){
			data_temp <- data_clean[(data_clean$from_station_id ==(final_route[i,"id"]))&(data_clean$to_station_id ==(final_route[i+1,"id"])),]
			data.frame(
			from=landmark_new[landmark_new$id==(final_route[i,"id"]),"landmark"],
	  		to=landmark_new[landmark_new$id==(final_route[i+1,"id"]),"landmark"],

#		  	to_station=stations[stations$id==final_route[i+1,"id"],"name"],
#			from_station=stations[stations	$id==final_route[i,"id"],"name"],			
	  		number_of_route=dim(data_temp)[1],avg_time_in_sec=mean(data_temp$tripduration))
		}))
		compute_avg_time

	})
	
	output$landmark_crosswalk <- renderTable({
		start_id <- stations[stations$name==input$trip_start_name,"id"]
		chosen_station_id <- landmark[input$landmark_selected,"id"]

		dd <- rbind(
		cbind(landmark="Trip Start Station",stations[stations$name==input$trip_start_name,c("name","latitude","longitude","dpcapacity")])
		,
		landmark[landmark$id %in% chosen_station_id,c("landmark","name","latitude","longitude","dpcapacity")]
		)		
		names(dd)[2] <- "Divvy Station Name"		
		row.names(dd) <- NULL
		dd
		
	})


#### start station analysis
  output$text_start <- renderText({
	 paste("You have selected start station :", input$from_station_name)
  })
  output$text_to    <- renderText({
	 paste("You have selected end station :", input$to_station_name)
  })
  output$text_start1 <- renderText({
	 paste("You have selected start station :", input$from_station_name)
  })
  output$text_to1    <- renderText({
	 paste("You have selected end station :", input$to_station_name)
  })

#### plot 
  output$plot_start <- renderPlot({
	p_start <- qplot(age,tripduration, data=dataset_all(),color=gender,alpha=I(1/input$alpha))
	print(p_start)
  })

#### thrid panel
#### text first
  output$given_start <- renderText({
	 paste("Given the start station :", input$from_station_name)
  })
  output$given_end <- renderText({
	 paste("Given the end station :", input$to_station_name)
  })
#### ggmap
	output$ggmap_by_start <- renderPlot({
		data_temp <- dataset_by_start()
		lon_default <- -87.65
		lat_default <-  41.88
		if(input$from_station_name != "ALL"){
			lon_default <- stations$longitude[stations$name == input$from_station_name]
			lat_default <- stations$latitude[stations$name == input$from_station_name]
		}
		gg <- get_map(location = c(lon=lon_default,lat=lat_default), zoom = 12)
		gg <- ggmap(gg,extent="panel")
		gg <- gg + geom_point(aes(x = longitude, y = latitude, size = cnt), data = data_temp)
		### adding the starting
		gg <- gg + geom_point(aes(x = longitude, y = latitude), size = input$size_to, pch=17 , color= "red", data = stations[stations$name==input$from_station_name,])
		print(gg)
	},height=600)
####  ggmpa by end
	output$ggmap_by_end <- renderPlot({
		data_temp1 <- dataset_by_to()
		lon_default <- -87.65
		lat_default <-  41.88
		if(input$to_station_name != "ALL"){
			lon_default <- stations$longitude[stations$name == input$to_station_name]
			lat_default <- stations$latitude[stations$name == input$to_station_name]
		}
		gg <- get_map(location = c(lon=lon_default,lat=lat_default), zoom = 12)
		gg <- ggmap(gg,extent="panel")
		gg <- gg + geom_point(aes(x = longitude, y = latitude, size = cnt), data = data_temp1)
		### adding the starting
		gg <- gg + geom_point(aes(x = longitude, y = latitude), size = input$size_to, pch=17 , color= "red", data = stations[stations$name==input$to_station_name,])
		print(gg)
	},height=600)


#### fourth time analysis
	output$heatmap <- renderPlot({
		data_heat <- dataset_all()
		#print(heatmap.2(table(data_heat[,c("from_month","from_hour")]),Rowv=FALSE,Cowv=FALSE))
		heatmap.2(table(data_heat[,c("from_month","from_hour")]),Rowv=FALSE,Colv=FALSE,dendrogram="none",trace="none",scale="none")

	},height=450)


}
