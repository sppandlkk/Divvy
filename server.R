library(shiny)
library(ggplot2)
library(ggmap)

# read in the data
trips <- read.csv("./data/Divvy_Trips_2013_t.csv")
stations <- read.csv("./data/Divvy_Stations_2013.csv")

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

#### cut off old people
trips_subs <- trips_subs[trips_subs$age <= 90,]

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
	tt <- table(dd$from_station_id)
	merge(data.frame(id=names(tt),cnt=c(tt)),stations[,c("longitude","latitude","id")],by="id")
  })


#### first panel
#### for creating the plot
  output$plot <- renderPlot({
    p <- qplot(tripduration,data=dataset(),  geom="histogram", binwidth=input$binwidth)

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
#### ggmap
	output$ggmap_by_start <- renderPlot({
		gg <- get_map(location = c(lon=-87.65,lat=41.88), zoom = 12)
		gg <- ggmap(gg,extent="panel")
		gg <- gg + geom_point(aes(x = longitude, y = latitude, size = sqrt(cnt)), data = dataset_by_start())
		### adding the starting
		gg <- gg + geom_point(aes(x = longitude, y = latitude), size = input$size_to, color= "red", data = stations[stations$name==input$from_station_name,])
		print(gg)
	},height=600)





}
