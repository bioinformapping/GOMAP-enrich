box::use(
  readxl[read_excel]
)

get_datasets <- function() {
  datasets = read_excel("app/static/datasets.xlsx")
}
