box::use(
  bslib[card, card_header],
  reactable,
  shiny[h3, moduleServer, NS],
)

box::use(
  app/logic/data_transformation[transform_data],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  card(
    card_header(h3("Table")),
    reactable$reactableOutput(ns("table"))
  )
}

#' @export
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$table <- reactable$renderReactable(
      data |>
        transform_data() |>
        reactable$reactable()
    )
  })
}
