library(shiny)
library(ggplot2)
# read in the data
#source("./load_data.r")

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

  }, height=700)

}
