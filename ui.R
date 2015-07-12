library(shiny)
library(ggplot2)

dataset <- read.csv("./data/head.csv")
dataset$from_station_name <- as.character(dataset$from_station_name)
dataset$to_station_name <- as.character(dataset$to_station_name)


fluidPage(

  titlePanel("2013 Divvy Data Analyses"),

  sidebarPanel(

    selectInput('from_station_name', 'Start Station', c("ALL",unique(dataset$from_station_name))),
    selectInput('to_station_name', 'End Station', c("ALL",unique(dataset$to_station_name))),

    sliderInput("binwidth", 'Binwidth (for Histogram)', min=10, max=200, value=50, step= 10),

    checkboxInput('by_age', 'By Age (for Histogram)'),
    checkboxInput('by_gender', 'By Gender (for Histogram)'),

#    selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
#    selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))

    sliderInput('alpha', 'alpha (for graph 2)', min=1, max=10, value=3, step= 0.5),


    sliderInput('size_to', 'size (for graph 3)', min=1, max=20, value=10, step= 2)
  ),

    mainPanel(
    	tabsetPanel(
		tabPanel("Histogram",	
    			h3("Divvy Usage Duration Distribution"),
    			plotOutput("plot")
    		)
		,
		tabPanel("Stations Pairwise Analyses",
			br(),
			br(),
			textOutput("text_start"),
			textOutput("text_to"),
			plotOutput("plot_start")
		)
		,
		tabPanel("End Stations Analyses",
			textOutput("given_start"),
			p("This Map Shows The Distribution of the End Station"),
			plotOutput("ggmap_by_start")
		)
 	)
  )
)
