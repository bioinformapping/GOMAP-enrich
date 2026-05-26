box::use(
  clusterProfiler[read.gaf,buildGOmap,enricher],
  enrichplot[pairwise_termsim],
  dplyr[filter, pull, select, mutate, inner_join],
  utils[head],
  AnnotationDbi[Term],
)

# Global cache for loaded GO annotations to prevent redundant file reads/parsing
go_cache <- new.env(parent = emptyenv())

#' @export
read_go_annot <- function(data, species, assembly) {
  cache_key <- paste(species, assembly, sep = "___")
  if (exists(cache_key, envir = go_cache)) {
    return(get(cache_key, envir = go_cache))
  }

  sel_file = data |>
    filter(
      Species == species, Assembly == assembly
     ) |>
    pull(file)

  if (length(sel_file) == 0 || is.na(sel_file) || sel_file == "") {
    warning("No GAF file found matching species '", species, "' and assembly '", assembly, "'")
    return(NULL)
  }

  infile = file.path("app","static","data","gaf",sel_file)
  
  # Ensure the GAF file actually exists
  if (!file.exists(infile)) {
    warning("GAF file does not exist at path: ", infile)
    return(NULL)
  }

  rds_file = paste0(infile, ".rds")
  
  if (file.exists(rds_file)) {
    raw_go_annots_out = readRDS(rds_file)
  } else {
    raw_go_annots = read.gaf(infile) |>
      mutate(
        Species=species,
        Assembly=assembly
      )
  
    # CRITICAL OPTIMIZATION: Query database only for UNIQUE GO terms to avoid massive redundancy.
    # This reduces lookup times from seconds/minutes to milliseconds.
    goterms <- Term(unique(raw_go_annots$GO))
  
    term2name <- data.frame("GO"=names(goterms),"term"=goterms ) |>
      filter(!is.na(GO)|!is.na(term)) |>
      unique()
  
    raw_go_annots_out = inner_join(raw_go_annots,term2name)
    
    tryCatch({
      saveRDS(raw_go_annots_out, rds_file)
    }, error = function(e) {
      warning("Failed to save RDS cache: ", e$message)
    })
  }

  assign(cache_key, raw_go_annots_out, envir = go_cache)
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

  # CRITICAL OPTIMIZATION: Query database only for UNIQUE GO terms to avoid database lookup overhead.
  goterms <- Term(unique(cp_go_data$GO))

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
