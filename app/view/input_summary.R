box::use(
  bsicons[bs_icon],
  bslib[
    card, card_header, card_footer, layout_columns, page_fillable, value_box,
    showcase_bottom
  ],
  dplyr[pull, filter, mutate, case_when, rename],
  reactable,
  scales[comma],
  shiny[actionButton, div, icon, h2, h3, h4, moduleServer, NS, observe, renderText,
        req, textOutput, Progress,tags,includeHTML],
  utils[head],
  shinybusy[add_busy_bar],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  page_fillable(
    tags$head(
      includeHTML("app/static/google-analytics.html"),
    ),
    layout_columns(
      height = "150px",
      fill = FALSE,
      # col_widths=c(4,4,2,2),
      value_box(
        title="Annotated Genes",
        value = textOutput(ns("vbox_num_total_genes")),
        theme = "green"
      ),
      value_box(
        title="Total Annotations ",
        value = textOutput(ns("vbox_num_total_annots")),
        theme = "green",
      ),
      value_box(
        title="Differential Expressed Genes",
        value = textOutput(ns("vbox_num_de_genes")),
        theme = "red",
      ),
      value_box(
        title="Background Genes",
        value = textOutput(ns("vbox_num_background_genes")),
        theme = "red"
      ),
    ),
    card(
      card_header(
        layout_columns(
          h4("GO Annotations"),
          actionButton(
            inputId = "asd",
            label = "",
            onclick = "Reactable.downloadDataCSV('go-annot-table')",
            icon = icon("download")
          ),
          fill = F,
          col_widths = c(11,1)
        )
      ),
      reactable$reactableOutput(ns("dataset_tbl"))
    )
  )
}

#' @export
server <- function(
    id, data, de_gene_ids, background_gene_ids,
    filt_go_annots = NULL, raw_go_annots = NULL
    ) {
  moduleServer(id, function(input, output, session) {

    output$vbox_num_de_genes = renderText({
      req(de_gene_ids())

      de_gene_ids() |>
        length()
    })

    output$vbox_num_background_genes = renderText({
      req(background_gene_ids())

      background_gene_ids() |>
        length()
    })

    output$vbox_num_total_genes = renderText({
      req(filt_go_annots())
      ont_genes = filt_go_annots() |>
        pull(GENE) |>
        unique() |>
        length() |>
        comma()
      all_genes = raw_go_annots() |>
        pull(GENE) |>
        unique() |>
        length() |>
        comma()

      paste0(ont_genes,"/",all_genes)

    })

    output$vbox_num_total_annots = renderText({
      req(filt_go_annots())

      ont_annots = filt_go_annots() |>
        nrow() |>
        comma()
      all_annots = raw_go_annots() |>
        nrow() |>
        comma()
      paste0(ont_annots,"/",all_annots)
    })

    output$dataset_tbl <- reactable$renderReactable({
      req(filt_go_annots())
      req(de_gene_ids())
      req(background_gene_ids())

      # print(dim(filt_go_annots()))

      out = filt_go_annots() |>
        filter(
          GENE %in% c(de_gene_ids(),background_gene_ids())
        ) |>
        mutate(
          `Gene Type` = case_when(
            GENE %in% background_gene_ids() ~ "Background",
            GENE %in% de_gene_ids() ~ "DEG"
          ),
        ) |>
        rename(
          "Name"="term"
        )
      # print(head(out))
      reactable$reactable(
        out,
        searchable = T,
        filterable = T,
        compact = T,
        wrap = F,
        elementId ="go-annot-table",

      )
    })

  })
}
