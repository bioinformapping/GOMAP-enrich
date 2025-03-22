box::use(
  bslib[card, card_header, layout_columns],
  reactable,
  shiny[actionButton, icon, h3, moduleServer, NS, req],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card(
    card_header(
      layout_columns(
        h3("Enriched Terms"),
        actionButton(
          inputId = "asd",
          label = "",
          onclick = "Reactable.downloadDataCSV('enrich-table')",
          icon = icon("download")
        ),
        fill = F,
        col_widths = c(11,1)
      ),

    ),
    reactable$reactableOutput(ns("enrich_table"))
  )
}

#' @export
server <- function(id, enriched_go) {
  moduleServer(id, function(input, output, session) {
    output$enrich_table <- reactable$renderReactable({
      req(enriched_go())
      reactable$reactable(
        as.data.frame(enriched_go()),
        searchable = T,
        wrap=F,
        pagination = F,
        elementId = "enrich-table",
        resizable = T

      )
    })
  })
}
