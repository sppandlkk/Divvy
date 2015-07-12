library(shiny)
library(ggplot2)
# read in the data
trips <- read.csv("./data/Divvy_Trips_2013.csv")


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


function(input, output) {
		
  dataset <- reactive({
  	if(input$from_station_name != "ALL"){
    		return(trips_subs[trips_subs$from_station_name %in% input$from_station_name,])
    	}else{
    		return(trips_subs)
    	}

  })

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

}
