
box::use(
  bslib[
    bs_add_rules, bs_theme, nav_panel, navbar_options, page_navbar
  ],
  rhino[rhinos],
  sass[sass_file],
  shiny[
    moduleServer, NS
  ],
)

box::use(
  app/logic/datasets[get_datasets],
  app/view/chart,
  app/view/sidebar,
  app/view/table,
)


#' @export
ui <- function(id) {
  ns <- NS(id)

  theme <- bs_theme(bootswatch = "default") |>
    bs_add_rules(sass_file("app/styles/main.scss"))
  datasets = get_datasets()
  page_navbar(
    title = "GOMAP-Enrich",
    theme = theme,
    sidebar = sidebar$ui(ns("sidebar"), data = datasets),
    navbar_options = navbar_options(
      bg = "#0062cc",
      underline = TRUE
    ),
    nav_panel(
      title = "Table",
      table$ui(ns("table")),
    ),
    nav_panel(
      title = "Chart",
      chart$ui(ns("chart"))
    )
  )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- rhinos
    table$server("table", data = data)
    chart$server("chart", data = data)
  })
}
