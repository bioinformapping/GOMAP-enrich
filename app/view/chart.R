# app/view/chart.R

box::use(
  echarts4r,
  shiny[h3, moduleServer, NS, tagList],
  rhino[rhinos],
  bslib[card, card_header],
)

box::use(
  app/logic/chart_utils[label_formatter],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card(
    card_header(h3("Chart")),
    echarts4r$echarts4rOutput(ns("chart"))
  )
}

#' @export
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$chart <- echarts4r$renderEcharts4r(
      data |>
        echarts4r$group_by(Species) |>
        echarts4r$e_chart(x = Year) |>
        echarts4r$e_line(Population) |>
        echarts4r$e_x_axis(
          Year,
          axisLabel = list(
            formatter = label_formatter
          )
        ) |>
        echarts4r$e_tooltip()
    )
  })
}

