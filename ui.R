library(shiny)
library(ggplot2)

dataset <- read.csv("./data/head.csv")
dataset$from_station_name <- as.character(dataset$from_station_name)
fluidPage(

  titlePanel("Divvy Usage Duration Distribution"),

  sidebarPanel(

    sliderInput('binwidth', 'Binwidth', min=10, max=200,
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
