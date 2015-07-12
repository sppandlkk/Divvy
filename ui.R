library(shiny)
library(ggplot2)
# read in the data
#source("./load_data.r")
dataset <- read.csv("./data/head.csv")

fluidPage(

  titlePanel("Divvy Explorer"),

  sidebarPanel(

    sliderInput('binwidth', 'Binwidth', min=10, max=500,
                value=50, step= 10),

    selectInput('from_station_name', 'From Station', c("ALL",unique(dataset$from_station_name))),
#    selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
#    selectInput('color', 'Color', c('None', names(dataset))),

    checkboxInput('by_age', 'By Age'),
    checkboxInput('by_gender', 'By Gender')

#    selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
#    selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
  ),

  mainPanel(
    plotOutput('plot')
  )
)
