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

    sliderInput("binwidth_for_duration", 'Binwidth (for Duration Histogram)', min=10, max=200, value=50, step= 10),

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
    			plotOutput("hist_for_duration"),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
    			h3("Divvy Usage Month Distribution"),
    			plotOutput("hist_for_month"),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
    			h3("Divvy Usage Time Distribution"),
    			plotOutput("hist_for_from_hour")
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
		tabPanel("Location Analyses",
			h3("Distribution of the start station"),
			textOutput("given_end"),
			p("This map shows the distribution of the start station"),
			p("The size of dots represent the total counts for each end station"),
			plotOutput("ggmap_by_start"),

			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			br(),
			h3("Distribution of the end station"),
			textOutput("given_start"),
			p("This map shows the distribution of the end station"),
			p("The size of dots represent the total counts for each end station"),
			plotOutput("ggmap_by_end")
			
		)
		,
		tabPanel("Month v.s. Time Analyses",
			h3("Heatmap for Month and Time"),
			textOutput("text_start1"),
			textOutput("text_to1"),
			plotOutput("heatmap")
		)
 	)
  )
)
