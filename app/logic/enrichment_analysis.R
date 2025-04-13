box::use(
  clusterProfiler[read.gaf,buildGOmap,enricher],
  enrichplot[pairwise_termsim],
  dplyr[filter, pull, select, mutate, inner_join],
  utils[head],
  AnnotationDbi[Term],
)

#' @export
read_go_annot <- function(data, species, assembly) {

  sel_file = data |>
    filter(
      Species == species, Assembly == assembly
     ) |>
    pull(file)

  print(sel_file)

  if(length(sel_file)==0){
    return(NULL)
  }

  infile = file.path("app","static","data","gaf",sel_file)
  raw_go_annots = read.gaf(infile) |>
    mutate(
      Species=species,
      Assembly=assembly
    )

  # print(head(raw_go_annots))

  goterms <- Term(raw_go_annots$GO)

  term2name <- data.frame("GO"=names(goterms),"term"=goterms ) |>
    filter(!is.na(GO)|!is.na(term)) |>
    unique()

  raw_go_annots_out = inner_join(raw_go_annots,term2name)

  # print(head(raw_go_annots_out))

  return(raw_go_annots_out)
}

#' @export
filter_go_annot <- function(raw_go_annots, ontology) {
  filt_go_annots = raw_go_annots |>
    filter(
      ONTOLOGY == ontology
    )
  return(filt_go_annots)
}

#' @export
get_enriched_terms <- function(
    filt_go_annots,de_gene_ids,background_gene_ids,ontology
  ){

  cp_go_data = filt_go_annots |>
    select(
      GO, GENE, ONTOLOGY
    ) |>
    buildGOmap()

  goterms <- Term(cp_go_data$GO)

  term2name <- data.frame("GOID"=names(goterms),"term"=goterms ) |>
    filter(!is.na(GOID) | !is.na(term)) |>
    unique()

  enrich_go = enricher(
    gene = de_gene_ids,
    universe = background_gene_ids,
    TERM2GENE = cp_go_data,
    TERM2NAME = term2name,
    pvalueCutoff = 1,
    qvalueCutoff = 1,
    minGSSize = 10,
    maxGSSize = 500
  )

  enrich_go@ontology = ontology
  enrich_go = pairwise_termsim(enrich_go)

  return(enrich_go)

}
