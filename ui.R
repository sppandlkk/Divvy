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
    sliderInput("limit_for_duration", 'Limit (for Duration Histogram)', min=3000, max=20000, value=5000, step= 1000),
    
    checkboxInput('by_age', 'By Age (for Histogram)'),
    checkboxInput('by_gender', 'By Gender (for Histogram)'),

    
   selectInput('trip_start_name', 'Trip Start Station', c(unique(dataset$from_station_name))),
	checkboxGroupInput("landmark_selected",label = h3("Select Landmark (at least 2)"), choices = 
	list("Water Tower/John Hancock" = 1,
	"Navy Pier" = 2, 
	"Millennium Park" = 3,
	"Museum Campus" = 4,
	"Sears Tower" = 5,
	"Adler Planetarium" = 6),        selected = c(1,3)),



#    selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
#    selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))

    sliderInput('alpha', 'alpha (for graph 2)', min=1, max=10, value=3, step= 0.5),


    sliderInput('size_to', 'size (for graph 3)', min=1, max=20, value=5 , step= 2)
  ),

    mainPanel(
    	tabsetPanel(
		tabPanel("Histogram",	
    			h3("Divvy Usage Duration Distribution"),	
    			p("Tourists traveled a lot from 10 am to 8 pm. They traveled more in the weekend than in the weekdays."),				

    			p("Most of the commuters used Divvy duration the weekday and rush hours."),				
    			plotOutput("hist_for_weekdays"),
			p("As expected, most of the duration is less than 30 minutes or 1800 seconds (free of charge)"),

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
			p("Octuber has the most frequent Divvy usuage, followed by September and November"),
			p("Surprisingly, July has very few data (because we only look for subscribes"),
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
			p("The most popular timeframes are the commute time: 8am and 5pm (and one hour before and after"),
    			plotOutput("hist_for_from_hour")
    		)
		,
		tabPanel("Stations Pairwise Analyses",
			br(),
			br(),
			textOutput("text_start"),
			tableOutput("landmark_table"),
			h3("Cross-walk Table"),
			tableOutput("landmark_crosswalk"),
			textOutput("text_to"),
			plotOutput("plot_start")
		)
		,
		tabPanel("Location Analyses",
			h3("Distribution of the start station"),
			textOutput("given_end"),
			p("This map shows the distribution of the start station"),
			p("The size of dots represents the total counts for each end station"),
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
			p("The size of dots represents the total counts for each end station"),
			plotOutput("ggmap_by_end")
			
		)
		,
		tabPanel("Month v.s. Time Analyses",
			h3("Heatmap for Month and Time"),
			textOutput("text_start1"),
			textOutput("text_to1"),
			p("Most trips are contributed by the commuters in the summer"),
			plotOutput("heatmap")
		)
 	)
  )
)
