box::use(
  bslib[card, card_header, page_fillable, layout_columns],
  datasets[cars],
  graphics[barplot],
  reactable[reactableOutput,reactable, renderReactable],
  shiny[h3, moduleServer, NS, req, fluidRow, reactive, observe],
  ggplot2[ggplot, geom_histogram,aes],
  dplyr[arrange,filter,rename,mutate],
  plotly[plotlyOutput, plot_ly, renderPlotly,layout, highlight],
  enrichplot,
  crosstalk[SharedData],
  tidyr[separate_rows],
  utils[head],
  tibble[remove_rownames],
  DT[renderDataTable,datatable,dataTableOutput]
)

box::use(
  app/logic/enrichment_analysis[get_enriched_terms],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  page_fillable(
    # layout_columns(
      card(
        plotlyOutput(ns("enr_barplot")),
        full_screen = T,
        max_height = "50%"
      ),
    #   card(
    #     plotlyOutput(ns("enr_dot_plot")),
    #     full_screen = T,
    #   ),
    #   max_height = "50%"
    # ),
    card(
      reactableOutput(ns("enr_barplot_tbl")),
      full_screen = T,
      fill = T,
      max_height = "50%"
    )
  )
  # card(
    # card_header(h3("Enrichment Bar Plot")),
  # )
}

#' @export
server <- function(id, enriched_go) {
  moduleServer(id, function(input, output, session) {

    shared_enriched_go = SharedData$new(reactive({
      req(enriched_go())
      enriched_go() |>
        as.data.frame() |>
        filter(p.adjust<0.05)
    }),key=~ID)

    # observe(shared_enriched_go)

    output$enr_barplot <- renderPlotly({
        plot_ly(
          data=shared_enriched_go,
          x = ~RichFactor,
          y = ~Description,
          color = ~p.adjust,
          type = "bar"
        ) |>
        layout(barmode = "overlay") |>
        highlight(
          on = "plotly_click", off = "plotly_doubleclick"
        )
    })

    # output$enr_dot_plot <- renderPlotly({
    #
    #     plot_ly(
    #       data=shared_enriched_go,
    #       x = ~Count,
    #       y = ~Description,
    #       color = ~p.adjust,
    #       type = "bar"
    #     ) |>
    #     layout(barmode = "overlay") |>
    #     highlight(
    #       on = "plotly_click", off = "plotly_doubleclick"
    #     )
    # })

    output$enr_barplot_tbl <- renderReactable({
      req(shared_enriched_go)

      reactable(
        shared_enriched_go,
        selection = "multiple",
        onClick = "select",
        rowStyle = list(cursor = "pointer"),
        wrap=F
      )
    })


  })
}
