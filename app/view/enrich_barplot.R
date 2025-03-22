box::use(
  bslib[card, card_header],
  datasets[cars],
  graphics[barplot],
  reactable,
  shiny[h3, moduleServer, NS, req],
  ggplot2[ggplot, geom_histogram,aes],
  plotly,
  enrichplot
)

box::use(
  app/logic/enrichment_analysis[get_enriched_terms],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card(
    card_header(h3("Enrichment Bar Plot")),
    plotly$plotlyOutput(ns("enr_barplot"))
  )
}

#' @export
server <- function(id, enriched_go) {
  moduleServer(id, function(input, output, session) {
    output$enr_barplot <- plotly$renderPlotly({
      req(enriched_go())
      barplot(enriched_go())
    })
  })
}
