library(shiny)
library(ggplot2)
library(ggmap)
library(gplots)

# read in the data
trips <- read.csv("./data/Divvy_Trips_2013.csv")
stations <- read.csv("./data/Divvy_Stations_2013.csv")

#### first restrict to member
trips_subs <- trips[trips$usertype=="Subscriber",]
trips_subs <- trips[!is.na(trips$birthday),]
#### cut off extreme point
trips_subs <- trips_subs[trips_subs$tripduration <= 2500,]

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

#### cut off old people
trips_subs <- trips_subs[trips_subs$age <= 90,]


#### create month
#trips_subs$start_month <- format(as.Date(substr(trips_subs$starttime,1,7),"%m/%d/%y"),"%m")
trips_subs$from_month <- as.numeric(substr(trips_subs$starttime,6,7))
trips_subs$from_hour  <- as.numeric(substr(trips_subs$starttime,12,13))
trips_subs$to_hour    <- as.numeric(substr(trips_subs$stoptime,12,13))

function(input, output) {
		
  dataset <- reactive({
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
#### for creating the plot
  output$hist_for_duration <- renderPlot({
    p <- qplot(tripduration,data=dataset(),  geom="histogram", binwidth=input$binwidth_for_duration)

	facet_col <- "."	
	facet_row <- "."

    if (input$by_age)	facet_col <- "age_cat"
    if (input$by_gender)	facet_row <- "gender"
    
  
    facets <- paste(facet_row, '~', facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)


    print(p)

  }, height=600)

  output$hist_for_month <- renderPlot({
    p <- qplot(from_month,data=dataset(),  geom="histogram", binwidth=1)

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
    p <- qplot(from_hour,data=dataset(),  geom="histogram", binwidth=1)

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
	p_start <- qplot(age,tripduration, data=dataset(),color=gender,alpha=I(1/input$alpha))
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
		data_heat <- dataset()
		#print(heatmap.2(table(data_heat[,c("from_month","from_hour")]),Rowv=FALSE,Cowv=FALSE))
		heatmap.2(table(data_heat[,c("from_month","from_hour")]),Rowv=FALSE,Colv=FALSE,dendrogram="none",trace="none",scale="none")

	},height=450)


}
