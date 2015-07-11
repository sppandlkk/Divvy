library(shiny)
library(ggplot2)
# read in the data
source("./load_data.r")
dataset <- trips_subs

fluidPage(

  titlePanel("Divvy Explorer"),

  sidebarPanel(

    sliderInput('binwidth', 'Binwidth', min=1, max=floor(dataset$tripduration/5),
                value=min(10, nrow(dataset)), step= 10, round=0),

    selectInput('from_station_id', 'From Station ID', c("ALL",sort(unique(dataset$from_station_id)))),
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
