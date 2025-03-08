box::use(
  bslib[sidebar],
  shiny[
    fileInput, moduleServer, NS, selectizeInput, textAreaInput,
  ],
)

shiny::enableBookmarking()

#' @export
ui <- function(id, data) {
  ns <- NS(id)
  sidebar <- sidebar(
    title = "Inputs",
    selectizeInput(
      inputId = ns("species"),
      label = "Select Species",
      choices = data$Species |>
        unique()
    ),
    selectizeInput(
      inputId = ns("assembly"),
      label = "Select Assembly",
      choices = data$Assembly |>
        unique()
    ),
    textAreaInput(
      inputId = ns("Gene IDs"),
      label = "Paste DE Gene List"
    ),
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
