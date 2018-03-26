library(shiny)

fluidPage(
  titlePanel("Analysis Of Time Series from Helgoland"),
    splitLayout(cellWidths = c("70%", "30%"),
      tabsetPanel(id="Tabs",selected = "Plot",
        tabPanel("Plot",
      wellPanel(
       textOutput("plotname"),
       tags$style(type="text/css", "#plotname { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
       plotOutput("basicplot",width = "95%"),
       tags$style(type="text/css", "#basictable {height: 394.5px;}")
       )),
        tabPanel("Table",
        fluidRow(
          column(12,align="center",
         wellPanel(
           textOutput("tablename"),
           tags$style(type="text/css", "#tablename { height: 35px; width: 100%; text-align:center; font-size: 20px;}"),
           tableOutput("basictable"),
           tags$style(type="text/css", "#basictable {align:centre;overflow-y:scroll;height: 394.5px;}")
         )))
      ),
      tabPanel("ACF",
      wellPanel(
      textOutput("ACF"),
      tags$style(type="text/css", "#ACF { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
      plotOutput("acfplot")       
      )),
      tabPanel("PACF",
      wellPanel(
      textOutput("PACF"),
      tags$style(type="text/css", "#PACF { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
      plotOutput("pacfplot")       
      )),
      tabPanel("Moving Average",
      wellPanel(
      textOutput("SMA"),
      tags$style(type="text/css", "#SMA { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
      plotOutput("sma"),
      tags$style(type="text/css", "#sma {height: 400px;}")
      )),
      tabPanel("Forecast",
      wellPanel(
      textOutput("forecast"),
      tags$style(type="text/css", "#forecast { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
      plotOutput("forecastplot"),
      tags$style(type="text/css", "#forecastplot {height: 400px;}")
      )
      ),
      tabPanel("ARIMA Model",
      wellPanel(
      textOutput("arima"),
      tags$style(type="text/css", "#arima { height: 30px; width: 100%; text-align:center; font-size: 20px;}"),
      plotOutput("arimaplot"),
      tags$style(type="text/css", "#arimaplot {height: 400px;}"),
      verbatimTextOutput("arimacoef")
      ))),
      wellPanel(
       textInput("apiurl","SOS URL","http://geo.irceline.be/sos/api/v1/timeseries/10701"),
       actionButton("load","Load Data"),
       tags$hr(),
       fileInput("file1", "Choose CSV File",accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
       actionButton("upload","Upload  CSV File"),
       br(),br(),
       tags$hr(),
       br(),
       conditionalPanel(condition="input.Tabs !='Moving Average' && input.Tabs !='Forecast' && input.Tabs!='ARIMA Model'",
       tags$strong("Summary"),
       br(),br(),
       verbatimTextOutput("summary")
      ),
      conditionalPanel(condition="input.Tabs =='Moving Average' || input.Tabs =='Forecast' || input.Tabs =='ARIMA Model'",
        sliderInput("smak","Choose Value",min=1,max=25,value=1),
        br()
      ))
    )
  )
