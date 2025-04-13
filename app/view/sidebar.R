box::use(
  bslib[sidebar],
  shiny[
    actionButton, icon, fileInput, moduleServer, NS, reactive, req,
    selectInput, textAreaInput, updateSelectInput, updateTextAreaInput,
    observeEvent, observe, Progress, submitButton, eventReactive
  ],
  dplyr [ filter, pull],
  shinybusy[add_busy_bar],
)

box::use(
  app/logic/enrichment_analysis[read_go_annot, filter_go_annot, get_enriched_terms],
  app/logic/datasets[get_examples],
)

#' @export
ui <- function(id, data) {
  ns <- NS(id)
  sidebar <- sidebar(
    title = "Inputs",
    add_busy_bar(color = "red"),
    selectInput(
      inputId = ns("species"),
      label = "Select Species",
      choices = data$Species |>
        unique(),
      selected = NULL,
      multiple = F
    ),
    selectInput(
      inputId = ns("assembly"),
      label = "Select Assembly",
      choices = NULL,
      selected = NULL,
      multiple = F
    ),
    selectInput(
      inputId = ns("ontology"),
      label = "Select Ontology",
      choices = list(
        `Molecular Function` = "MF",
        `Biological Process` = "BP",
        `Cellular Component` = "CC"
      ),
      selected = NULL,
      multiple = F
    ),
    textAreaInput(
      inputId = ns("input_de_gene_ids"),
      label = "Paste DE Gene List"
    ),
    textAreaInput(
      inputId = ns("input_background_gene_ids"),
      label = "Paste Background Gene List"
    ),
    actionButton(
      inputId = ns("example_de_genes"),
      label = "Example Data",
      icon = icon("seedling")
    ),
    actionButton(
      inputId = ns("submit_btn"),
      label = "Analyze Data",
      icon = icon("magnifying-glass-chart")
    )
  )
}

#' @export
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    observeEvent(
      input$species,{

        updateTextAreaInput(
          inputId = "input_de_gene_ids",
          value = ""
        )

        updateTextAreaInput(
          inputId = "input_background_gene_ids",
          value = ""
        )

        assembly_choices = data |>
          filter(
            Species == input$species
          ) |>
          pull(Assembly)
        updateSelectInput(
          inputId = "assembly",
          choices = assembly_choices
        )
      }
    )

    de_gene_ids = reactive({
      req(input$input_de_gene_ids)
      de_gene_ids = strsplit(input$input_de_gene_ids,split = c(",|\t| |\n")) |>
        unlist() |> unique()
      return(de_gene_ids)
    })

    background_gene_ids = reactive({
      req(input$input_background_gene_ids)
      background_gene_ids = strsplit(input$input_background_gene_ids,split = c(",|\t| |\n")) |>
        unlist() |>
        unique()
      return(background_gene_ids)
    })

    raw_go_annots = reactive({
      req(input$species)
      req(input$assembly)

      print("Raw GO is still happening")

      raw_go_annots = read_go_annot(
        data, input$species, input$assembly
      )
      return(raw_go_annots)
    })

    filt_go_annots = reactive({
      req(raw_go_annots())
      req(input$ontology)

      print("filt_go_annots is still happening")

      filt_go_annots = filter_go_annot(
        raw_go_annots(), input$ontology
      )
      return(filt_go_annots)
    })

    enriched_go = eventReactive(input$submit_btn,{
      req(background_gene_ids())
      req(de_gene_ids())
      req(filt_go_annots())
      req(input$ontology)

      enriched_go = get_enriched_terms(
        filt_go_annots = filt_go_annots(),
        de_gene_ids = de_gene_ids(),
        background_gene_ids = background_gene_ids(),
        ontology = input$ontology
      )
      return(enriched_go)
    })



    observeEvent(input$example_de_genes,{
      example_data = get_examples()
      updateSelectInput(
        inputId = "species",
        selected = "Zea mays"
      )
      updateSelectInput(
        inputId = "assembly",
        selected = "B73_v4"
      )
      updateTextAreaInput(
        inputId = "input_de_gene_ids",
        value = example_data[["de_genes"]]
      )
      updateTextAreaInput(
        inputId = "input_background_gene_ids",
        value = example_data[["background_genes"]]
      )
    })

    # observe(enriched_go)


    return(
      list(
        de_gene_ids = de_gene_ids,
        background_gene_ids = background_gene_ids,
        raw_go_annots = raw_go_annots,
        filt_go_annots = filt_go_annots,
        enriched_go = enriched_go
      )
    )

  })
}
