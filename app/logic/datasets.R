box::use(
  readxl[read_excel]
)

# In-memory cache for datasets and examples
cache <- new.env(parent = emptyenv())
cache$datasets <- NULL
cache$examples <- NULL

#' @export
get_datasets <- function() {
  if (is.null(cache$datasets)) {
    rds_file <- "app/static/data/datasets.rds"
    xlsx_file <- "app/static/data/datasets.xlsx"
    if (file.exists(rds_file)) {
      cache$datasets <- readRDS(rds_file)
    } else {
      cache$datasets <- read_excel(xlsx_file)
      tryCatch({
        saveRDS(cache$datasets, rds_file)
      }, error = function(e) {
        warning("Failed to save datasets cache: ", e$message)
      })
    }
  }
  return(cache$datasets)
}

#' @export
get_examples <- function(){
  if (is.null(cache$examples)) {
    out = list()
    out[["de_genes"]] = readLines("app/static/data/B73_v4.test.txt")
    out[["background_genes"]] = readLines("app/static/data/B73_v4_universe.txt")
    cache$examples <- out
  }
  return(cache$examples)
}

