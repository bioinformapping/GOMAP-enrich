
box::use(
  shiny[
    div, moduleServer, NS, renderUI, tags, uiOutput, fluidRow, h1
  ],
  semantic.dashboard[dashboard_page, dashboard_header, dashboard_body],
  bslib[
    page_navbar, layout_columns, bs_theme, bs_add_rules, toggle_dark_mode,
    nav_spacer, nav_panel, navbar_options
  ],
  rhino[rhinos],
  sass[sass_file],
)

box::use(
  app/view/chart,
  app/view/table,
  app/view/sidebar,
)


#' @export
ui <- function(id) {
  ns <- NS(id)

  theme <- bs_theme(bootswatch = "default") |>
    bs_add_rules(sass_file("app/styles/main.scss"))

  page_navbar(
    title = "GOMAP-Enrich",
    theme = theme,
    sidebar = sidebar$ui(ns("sidebar"),data=rhinos),
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
    # datatable$server("datatable")
    table$server("table", data=data)
    chart$server("chart", data=data)
  })
}
