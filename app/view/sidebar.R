box::use(
  bslib[sidebar],
  shiny[
    fileInput, moduleServer, NS, selectizeInput,
  ],
)

shiny::enableBookmarking()

#' @export
ui <- function(id, data) {
  ns <- NS(id)

  sidebar <- sidebar(
    title = "Inputs",
    fileInput(
      inputId = ns("file-upload"),
      label = "Upload Gene List",
      multiple = TRUE
    ),
    selectizeInput(
      inputId = ns("var"),
      label = "Select Species",
      choices = data$Species |>
        unique()
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
  })
}
