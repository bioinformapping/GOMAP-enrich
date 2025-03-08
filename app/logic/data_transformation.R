# app/logic/data_transformation.R

box::use(
  dplyr[arrange],
  tidyr[pivot_wider],
)

#' @export
transform_data <- function(data) {
  pivot_wider(
    data = data,
    names_from = Species,
    values_from = Population
  ) |>
    arrange(Year)
}
