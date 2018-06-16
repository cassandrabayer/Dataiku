
shinyServer(function(input, output) {
  
  lm1 <- reactive({lm(reformulate(input$IndVar, input$DepVar), data = census_train$dtClean, 
                      family = binomial(link = "logit"))})
  
  output$DepPrint <- renderPrint({input$DepVar})
  output$IndPrint <- renderPrint({input$IndVar})
  output$RegSum <- renderPrint({summary(lm1())})
  
})
