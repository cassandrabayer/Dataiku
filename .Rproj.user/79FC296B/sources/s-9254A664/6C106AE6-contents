

shinyUI(fluidPage(
  headerPanel("Regression Testing"), 
  sidebarPanel(
    p("Select the inputs for the Independent Variable"),
    selectInput(inputId = "IndVar", label = "Independent Variables", 
                multiple = F, 
                choices = names(census_train[, 1:31])),
    p("Select the inputs for the Dependent Variable"),
    selectInput(inputId = "DepVar", label = "Dependent Variables", multiple = FALSE, choices = list( "over50k"))
  ),
  mainPanel(
    verbatimTextOutput(outputId = "RegSum"),
    verbatimTextOutput(outputId = "IndPrint"),
    verbatimTextOutput(outputId = "DepPrint")
    #plotOutput("hist")
  )
))

