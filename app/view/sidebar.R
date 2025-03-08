box::use(
  shiny[
    h3, moduleServer, NS, tagList, selectizeInput, numericInput,fileInput
  ],
  semantic.dashboard[
    dashboard_sidebar, sidebar_menu, menu_item
  ],
  bslib[sidebar],
  dplyr[select_if],
  shiny.semantic[file_input],
  palmerpenguins[penguins]
)

shiny::enableBookmarking()

#' @export
ui <- function(id,data) {
  ns <- NS(id)

  sidebar = sidebar(
    title = "Inputs",
    fileInput(
      inputId = "file-upload",
      label = "Upload Gene List",
      multiple = T
    ),
    selectizeInput(
      inputId = "var",
      label = "Select Species",
      choices = data$Species |>
        unique()
    )
  )
  # dashboard_sidebar(
  #   sidebar_menu(
  #     menu_item(tabName = "map", text = "Map"),
  #     menu_item(tabName = "ghg", text = "GHG Emission Coverage"),
  #     menu_item(tabName = "price", text = "Price"),
  #     menu_item(tabName = "revenue", text = "Revenue")
  #   ),
  #   side="left",visible = T,closable = F,pushable = T,
  #   size = "wide"
  # )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
  })
}
