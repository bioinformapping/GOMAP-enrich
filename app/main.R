
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
  app/view/input_summary,
  app/view/sidebar,
  app/view/table,
  app/view/enrich_barplot,
  app/view/enrich_dotplot,
)

shiny::enableBookmarking()

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
      title = "Input Summary",
      input_summary$ui(ns("datasets")),
    ),
    nav_panel(
      title = "Bar Plot",
      enrich_barplot$ui(ns("enr-barplot")),
    ),
    nav_panel(
      title = "Dot Plot",
      enrich_dotplot$ui(ns("enr-dotplot")),
    ),
    nav_panel(
      title = "Output Table",
      table$ui(ns("enrich_table")),
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
    datasets = get_datasets()
    sidebar_data = sidebar$server("sidebar",data = datasets)
    input_summary$server(
      id = "datasets", data = datasets,
      de_gene_ids = sidebar_data$de_gene_ids,
      background_gene_ids = sidebar_data$background_gene_ids,
      raw_go_annots = sidebar_data$raw_go_annots,
      filt_go_annots = sidebar_data$filt_go_annots
    )
    chart$server("chart", data = data)
    enrich_barplot$server(
      "enr-barplot", enriched_go=sidebar_data$enriched_go
    )
    enrich_dotplot$server(
      "enr-dotplot", enriched_go=sidebar_data$enriched_go
    )
    table$server(
      "enrich_table", enriched_go=sidebar_data$enriched_go
    )
  })
}
