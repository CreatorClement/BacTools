#' Export Tool Catalog to CSV
#'
#' Save a catalog of bioinformatics tools to CSV file
#'
#' @param catalog Data frame of tools (output from search_bactools)
#' @param filename Output CSV filename (default: "biotools_catalog.csv")
#' @param include_timestamp Add timestamp to filename (default: TRUE)
#' @return Invisible path to saved file
#' @importFrom readr write_csv
#' @export
#' @examples
#' \dontrun{
#' all_tools <- search_bactools()
#' export_catalog(all_tools)
#' export_catalog(all_tools, "my_custom_catalog.csv", include_timestamp = FALSE)
#' }
export_catalog <- function(catalog, 
                           filename = "biotools_catalog.csv",
                           include_timestamp = TRUE) {
  
  if (include_timestamp) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- sub("\\.csv$", "", filename)
    filename <- paste0(filename, "_", timestamp, ".csv")
  }
  
  readr::write_csv(catalog, filename)
  message(sprintf("✅ Exported catalog to %s (%d tools)", filename, nrow(catalog)))
  
  invisible(filename)
}