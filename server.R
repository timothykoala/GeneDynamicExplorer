library(shiny)
library(tidyverse)
library(readxl)
library(httr)
library(viridis)
library(scales)
library(gtools)
source('code/functions.R')

# Read in data
normalized_data_genelevel_tpm = read_csv("data/normalized_data_RPE1.csv")
geneSyns = read_csv('data/GeneNameshuman.csv')

shinyServer(function(input, output, session) {
  
  # Reads genes and formats them when plot buttion is pushed
  geneNames <- reactive({
    input$plot
    isolate(input$genes %>% strsplit(' ') %>% unlist() %>% tolower())
  })
  
  # Formats the data for plotting
  datasetInput <- reactive({
    geneSearch(geneNames(), geneSyns, normalized_data_genelevel_tpm) %>% 
      filter(Genotype %in% input$Genotype, Hour %in% input$time)
  })
  
  # Formats the data for table output
  tableFormat <- reactive({
    
    tab = datasetInput() %>% unite("Hour_Replicate", c("Hour", "Replicate")) %>% 
      spread("Hour_Replicate","TPM") %>% unite("Condition", c("GeneName","Genotype"))
    
    mat = t(tab[2:ncol(tab)])
    mat = cbind(colnames(tab[,2:ncol(tab)]),mat)
    colnames(mat) = c("Sample",as.character(tab$Condition))
    as.data.frame(mat) %>% separate(Sample, into = c("Hour","Replicate"), sep = "\\_")
  })
  
  # Updates dropdown menu with searched genes
  observe({
    updateSelectInput(session = session, inputId = "uniprot", choices = geneNames())
  })
  
  # Write Uniprot HTML File
  oijfewoji <- reactive({
    selected = filter(geneSyns, tolower(GN_Syn) == tolower(input$uniprot))
    selected = selected[1,1] %>% as.character()
    
    paste0('https://www.uniprot.org/uniprot/',selected)
  })
  
  output$Uniprot <- renderText({
    #request <- GET(url = url())
    #writeLines(content(request, as="text"), file('uniprot.html'))
    #content(request, as = "text")
    as.character(url())
  })
  
  
  # Defines the different plots
  datasetPlot <- reactive({
    if(input$plot_type == 'Loess'){
      ggplot(datasetInput(), aes(Hour, TPM, colour = Genotype)) + geom_point(size = input$pointSize) + geom_smooth(method = loess) +
        facet_wrap(~GeneName, scales = "free") + scale_x_continuous(breaks = as.numeric(input$time)) + 
        theme_classic() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        scale_color_manual(values=c("#ED1C24","#C61017","#213F99","#335bd3")) + ylab('Mean NRC')
    }
    
    else{
      data = datasetInput() %>% group_by(GeneName,Genotype,Hour) %>% summarise(mean = mean(TPM, na.rm = T), stdev = sd(TPM, na.rm = T))
      ggplot(data, aes(Hour, mean, colour = Genotype)) + geom_point(size = input$pointSize) + geom_path(size = 1) + 
        geom_errorbar(aes(ymin = mean - stdev, ymax = mean + stdev), width = 0.25, size = 1) +
        facet_wrap(~GeneName, scales = "free") + scale_x_continuous(breaks = as.numeric(input$time)) + 
        theme_classic() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        scale_color_manual(values=c("#ED1C24","#C61017","#213F99","#335bd3")) + ylab('Mean NRC')
    }
  })
  
  plotDims <- reactive({
    c(as.numeric(input$width), as.numeric(input$height))
  })
  
  # Plot Data  
  output$plot <- renderPlot({
    
    datasetPlot()
    
  })
  
  # Download PDF of plotted dataset ----
  output$downloadPlot <-downloadHandler(
    filename = function() {
      "Plot.pdf"
    },
    content = function(file){
      #x = plotDims()
      renderPlot({
        datasetPlot()
      })
      ggsave(file, width = plotDims()[1], height = plotDims()[2], units = c('in'), useDingbats=FALSE)
    }
  )
  
  # Table of selected dataset ----
  output$table <- renderTable({
    tableFormat()
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$genes, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(tableFormat(), file, row.names = FALSE)
    }
  )
})
