library(shiny)
library(ggplot2)
library(jsonlite)
library(dplyr)
library(zoo)

function(input, output,session) {
  rv <- reactiveValues(data = data_df,head={fromJSON("http://geo.irceline.be/sos/api/v1/timeseries/10701")$label})
  observeEvent(input$load,{
      data_df <- tryCatch({ as.data.frame(fromJSON(paste0(input$apiurl,"/getData")))}
      ,error=function(e){
        NA
      })
      if(is.na.data.frame(data_df))
      {
        updateTextInput(session,"apiurl",value="http://geo.irceline.be/sos/api/v1/timeseries/10701")
        data_df <- as.data.frame(fromJSON("http://geo.irceline.be/sos/api/v1/timeseries/10701/getData"))
        showModal(modalDialog("Invalid API link choosen redirecting to http://geo.irceline.be/sos/api/v1/timeseries/10701"))
        rv$head <- fromJSON("http://geo.irceline.be/sos/api/v1/timeseries/10701")$label
      }
      else
        rv$head <- fromJSON(input$apiurl)$label
    data_df$values.timestamp <- as.POSIXct(as.numeric(data_df$values.timestamp)/1000,origin="1970-01-01")
    data_df <- na.locf(zoo(data_df$values.value,data_df$values.timestamp))
    rv$data = data_df
  })
  observeEvent(input$upload,{
    data_df <- tryCatch({read.csv(input$file1$datapath,stringsAsFactors = F)}
                        ,error=function(e){
                          NA
                        })
    if(is.na.data.frame(data_df))
    {
      updateTextInput(session,"apiurl",value="http://geo.irceline.be/sos/api/v1/timeseries/10701")
      data_df <- as.data.frame(fromJSON("http://geo.irceline.be/sos/api/v1/timeseries/10701/getData"))
      showModal(modalDialog("Invalid API link choosen redirecting to http://geo.irceline.be/sos/api/v1/timeseries/10701"))
    }
    else{
    data_df$values.timestamp <- tryCatch({as.POSIXct(data_df$values.timestamp)}
                                         ,error=function(e){
                                           data_df$values.timestamp <- as.POSIXct(as.numeric(data_df$values.timestamp)/1000,origin="1970-01-01")
                                         })
    updateTextInput(session,"apiurl",value="")
    }
    data_df <- na.locf(zoo(data_df$values.value,data_df$values.timestamp))
    rv$data = data_df
    rv$head <- input$file1$name
  })
  output$basicplot <- renderPlot({
  ggplot() +
      geom_path(aes(x=index(rv$data),y=coredata(rv$data)),colour="red1",size=1.1) +theme_bw()+
      theme(panel.border = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
      theme(panel.grid.major.x=element_blank(),panel.grid.major.y = element_line( size=.1, color="grey" ))  +
      xlab("\nTime")+ylab("Value\n")+
      theme(axis.text=element_text(size=13),axis.title=element_text(size=16))
  })
  output$basictable <- renderTable({
    data_table <- as.data.frame(cbind(as.character(index(rv$data)),coredata(rv$data)))
    colnames(data_table) <- c("Time","Value")
    data_table
  },align="c",bordered = T,striped = T,hover = T,spacing = 'l',rownames = T)
  output$acfplot <- renderPlot({acf(rv$data,main="",ylab="Cross-Correlation")})
  output$pacfplot <- renderPlot({pacf(rv$data,main="",ylab="Cross-Correlation")})
  output$plotname <- renderText({rv$head})
  output$tablename<- renderText({rv$head})
  output$ACF <- renderText({"Auto Correlation Function"})
  output$PACF<- renderText({"Partial Auto Correlation Function"})
  output$SMA <- renderText({"Moving Average"})
  output$forecast <- renderText({"Forecasting with HoltWinters"})
  output$arima <- renderText({"Forecasting with ARIMA model"})
    output$summary <- renderPrint({
      if(input$Tabs %in% c("ACF","PACF"))
        {
          a <- Box.test(rv$data)
          a$data.name=rv$head
          a
        }
      else
        summary(coredata(rv$data))
      })
  output$sma <- renderPlot({
    sma <- rollmean(rv$data,input$smak)
    ggplot() +
      geom_path(aes(x=index(sma),y=coredata(sma)),colour="red1",size=1.1) +theme_bw()+
      theme(panel.border = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
      theme(panel.grid.major.x=element_blank(),panel.grid.major.y = element_line( size=.1, color="grey" ))  +
      xlab("\nTime")+ylab("Value\n")+
      theme(axis.text=element_text(size=13),axis.title=element_text(size=16))
  })
  output$forecastplot <- renderPlot({
    q <- HoltWinters(rv$data,gamma=F)
    plot(forecast(q,h=input$smak),col="red1",lw=3,main="")
  })
  output$arimaplot <- renderPlot({
    q <- auto.arima(rv$data)
    plot(forecast(q,h=input$smak),col="red1",lw=3,main="")
  })
  output$arimacoef <- renderPrint({auto.arima(rv$data)})
}
