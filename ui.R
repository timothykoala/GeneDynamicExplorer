library(shiny)
library(readr)
source('code/functions.R')

shinyUI(
  navbarPage('GeneDynamicExplorer',
             tabPanel('RPE1 TGFbeta Time Course Plots',
                      sidebarPanel(
                        #img(src = 'logo.png', style = "float: left; width: 75px; margin-right: 10px; margin-top: 5px"),
                        titlePanel(strong("RNA-seq Time Course Plots")),
                        h6(em("T. Chan @ Marc Timmers lab")),
                        selectInput("plot_type", "Plot Type:", c("Mean","Loess")),
                        sliderInput('pointSize', 'Point Size', min = 0, max = 5, value = 2.5, step = 0.1),
                        textOutput("result"),
                        
                        checkboxGroupInput("Genotype", "Cells to plot",
                                           c("WTb" = "WTb","WT1" = "WT1","KO1" = "KO1","KO2" = "KO2"),
                                           selected = c("WTb","WT1","KO1","KO2"),
                                           inline = TRUE),
                        
                        checkboxGroupInput("time", "Time Points to Plot (Hour):",
                                           c("0" = 0,"2" = 2, "10" = 10, 
                                             "18" = 18, "30" = 30, "48" = 48),
                                           selected = c(0,2,10,18,30,48),
                                           inline = TRUE),
                        
                        textInput("genes", "Genes (separate by space):", value = "KMT2D"),
                        
                        actionButton('plot','Plot'),
                        
                        
                        h3(strong("Download")),
                        
                        # Download Plot Settings
                        h5("PDF Dimensions"),
                        splitLayout(
                          textInput("width", "Width (in)", value = 10),
                          textInput("height", "Height (in)", value = 5)
                        ),
                        
                        downloadButton("downloadPlot", "Export plot as PDF"),
                        
                        # Download Data Settings
                        downloadButton("downloadData", "Export table as CSV")
                        
                        
                      ),
                      
                      mainPanel(
                        tabsetPanel(
                          tabPanel("Plots", 
                                   plotOutput("plot")
                          ),
                          tabPanel("Data Table", 
                                   tableOutput("table")
                          )
                        )
                      )
             )
             )
  )