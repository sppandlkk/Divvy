library(shiny)
library(ggplot2)
# read in the data
trips <- read.csv("./data/Divvy_Trips_2013_t.csv")


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




}
