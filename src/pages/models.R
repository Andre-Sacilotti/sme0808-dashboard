library(shiny)
library(bslib)


css <- "

.top_choices{
    display: flex;
  flex-flow: row wrap;
  max-width: inherit;
  padding-left: 40px;
    padding-bottom: 10px;
    padding-top: 40px;
}

.data_params {
    padding-left: 40px;
}

.model_button {
    padding-right: 40px;
}

.model_selection{
    display: flex;
  flex-flow: row wrap;
  max-width: inherit;

}

.model_confirms{
    display: flex;
  flex-flow: row wrap;
  max-width: inherit;
  padding-left: 40px;
    padding-bottom: 40px;
    padding-top: 40px;
}

.text_models {
    padding-left: 40px;
    padding-bottom: 10px;
    padding-top: 40px;
    font-size: 22px;
    font-family: 'Montserrat';
    font-weight: 600;
}

.res_text {
    padding-top: 10px;
    padding-bottom: 10px;
}

.residual_box {
    color:#555;
    border-radius:10px;
    font-family: 'Montserrat';
    padding-left: 40px;
    paddding-bottom: 20px;
    margin-bottom: 10px;
    margin:10px;

    # background-color: #f44336; /* Red */
    color: white;
    margin-bottom: 15px;
    font-size: 16px;

    max-width: 760px;
    width: 760px;
    

}

.box-models {
    align: center;
    padding-top: 30px;
    padding-bottom: 40px;
}

.box_table {
     padding-left: 40px;
    paddding-bottom: 20px;
    padding-top: 70px;
    align: center;
    padding-bottom: 40px;
}

#forecast_metrics_ {
    display: flex;
    justify-content: center;
    text-align:center;
    margin: 0 auto
}

#forecast {
    display: flex;
    justify-content: center;
    text-align:center;
    margin: 0 auto
}

#table_metrics {
    display: flex;
    justify-content: center;
    text-align:center;
    margin: 0 auto
}

#residuals  {
    display: flex;
    justify-content: center;
    text-align:center;
    margin: 0 auto
}

.model_params2 {
    padding-left: 30px;
}


"

hypothesis_div <- div(
     class="box-models",
)

residuals_div <- div(
    class="box-models",
    div(
        class='residuals',
        shinycssloaders::withSpinner(plotlyOutput('residuals')),
        div(
            class="residual_box",
            id="residual_box",
            div(class="res_text", textOutput('residual_text'))
            
        )
        
        
    )
)

prediction_div <- div(
    class="box-models",
    div(
        class='forecast',
       
        shinycssloaders::withSpinner(plotOutput('forecast', width="80%")),
         div(
            class="box_table",
            shinycssloaders::withSpinner(plotlyOutput('forecast_metrics_', width="70%"))
            # tableOutput('forecast_metrics_')
        ),
        
        
    )
)



adjust_metric_div <- div(
    class="box-models",
    tableOutput('table_metrics')
)

models_page <- div(
     tags$head(
        tags$style(HTML(css)),
        tags$link()
    ),

    div(
        class="text_models",
        "Ajuste de Modelos e Predição"
    ),

    div(
        class="top_choices",
        div(
        class="model_selection",
        radioButtons("model_choice", "Escolha de Modelo",
                c(
                    "Auto ARIMA (Seleção Automatica)" ,
                    "SARIMA" ,
                    "ARIMA" ,
                    "AR",
                    "MA"
                ),
                selected="Auto ARIMA (Seleção Automatica)"
        ),
        div(
            class="model_params",
            conditionalPanel(
            "input.model_choice=='ARIMA' || input.model_choice=='AR' || input.model_choice=='ARMA' || input.model_choice=='SARIMA'",
            numericInput("ARIMA_p",
                "Parametro P (AR)", 2, min = 0, max = 100
            ),
        ),
         conditionalPanel(
            "input.model_choice=='ARIMA' || input.model_choice=='SARIMA'",
            numericInput("ARIMA_i",
                "Parametro D", 0, min = 0, max = 100
            ),
         ),
          conditionalPanel(
            "input.model_choice=='ARIMA' || input.model_choice=='MA' || input.model_choice=='ARMA' || input.model_choice=='SARIMA'",
            numericInput("ARIMA_q",
                "Parametro Q (MA)", 2, min = 0, max = 100
            )
        )
        ),
        div(
            class="model_params2",
            conditionalPanel(
            "input.model_choice=='SARIMA'",
            numericInput("ARIMA_Sp",
                "Parametro Sazonal P", 1, min = 0, max = 100
            ),
        ),
         conditionalPanel(
            "input.model_choice=='SARIMA'",
            numericInput("ARIMA_Si",
                "Parametro Sazonal D", 0, min = 0, max = 100
            ),
         ),
          conditionalPanel(
            "input.model_choice=='SARIMA' ",
            numericInput("ARIMA_Sq",
                "Parametro Sazonal Q", 0, min = 0, max = 100
            )
        )
        ),
        
        
        ),
        div(
            class="data_params",
            numericInput("test_steps_slider", "Tamanho do Horizonte da Base de Teste", min = 1, max = 300, value = 7), #só troquei pra fazer sentido na predição diária tbm; se algm tiver solução melhor, faça
            conditionalPanel(
            "input.model_choice=='SARIMA' || input.model_choice=='Auto ARIMA (Seleção Automatica)' ",
            numericInput("sazofreq",
                "Frequencia da Sazonalidade", 7, min = 1, max = 100
            )
        )
        )
    ),

    div(
        # sliderInput("prediction_steps_slider", "Passos de Previsão Futura", min = 1, max = 4, value = 2),
        class = "model_confirms",
        div(
            class = "model_button",
            actionButton("model_selection", "Confirmar Modelo!"),
        ),
        div(
            class = "model_button",
            actionButton("model_reset", "Resetar Modelo!"),
        )
        


    ),
    shinyjs::hidden(div(
        id="tab_models",
        tabsetPanel(
            type="tabs",
            tabPanel("Métricas de Ajuste", adjust_metric_div),
            tabPanel("Previsão", prediction_div),
            tabPanel("Analise de Residuos", residuals_div),
        )

    ))

)

