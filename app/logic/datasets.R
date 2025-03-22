box::use(
  readxl[read_excel]
)

get_datasets <- function() {
  datasets = read_excel("app/static/data/datasets.xlsx")
  return(datasets)
}

get_examples <- function(){
  out = list()
  out[["de_genes"]] = readLines("app/static/data/B73_v4.test.txt")
  out[["background_genes"]] = readLines("app/static/data/B73_v4_universe.txt")
  return(out)
}
