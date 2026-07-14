# Test Helper Functions
# This file contains helper functions and utilities used across multiple test files

#' Check if we're offline
#'
#' @return TRUE if offline, FALSE otherwise
skip_if_offline <- function() {
  if (!requireNamespace("curl", quietly = TRUE)) {
    testthat::skip("curl not available")
  }
  
  has_internet <- tryCatch(
    {
      con <- url("https://www.google.com")
      close(con)
      TRUE
    },
    error = function(e) FALSE,
    warning = function(w) FALSE
  )
  
  if (!has_internet) {
    testthat::skip("No internet connection")
  }
}

#' Create a mock tool list for testing
#'
#' @param n Number of tools to create
#' @param source Source repository (CRAN, Bioconductor, GitHub)
#' @return List of mock tool data
create_mock_tools <- function(n = 3, source = "CRAN") {
  lapply(seq_len(n), function(i) {
    list(
      name = paste0("tool", i),
      owner = ifelse(source == "GitHub", paste0("owner", i), NA_character_),
      author = paste0("Author ", i),
      summary = paste0("Summary for tool ", i),
      doi = paste0("10.1234/doi.", i),
      apa_citation = paste0("Citation for tool ", i),
      language = "R",
      release_date = Sys.Date() - i,
      docs = paste0("https://example.com/tool", i),
      tutorials = NA_character_,
      license = "MIT",
      github_stars = ifelse(source == "GitHub", 100 * i, NA_integer_),
      source = source,
      category = "Specialized analysis"
    )
  })
}

#' Create a mock catalog data frame
#'
#' @param n_cran Number of CRAN packages
#' @param n_bioc Number of Bioconductor packages  
#' @param n_github Number of GitHub repos
#' @return Data frame of mock catalog
create_mock_catalog <- function(n_cran = 2, n_bioc = 2, n_github = 2) {
  all_tools <- list()
  
  if (n_cran > 0) {
    all_tools$cran <- create_mock_tools(n_cran, "CRAN")
  }
  
  if (n_bioc > 0) {
    all_tools$bioc <- create_mock_tools(n_bioc, "Bioconductor")
  }
  
  if (n_github > 0) {
    all_tools$github <- create_mock_tools(n_github, "GitHub")
  }
  
  # Convert to data frame
  dplyr::bind_rows(
    if (n_cran > 0) tool_list_to_df(all_tools$cran) else NULL,
    if (n_bioc > 0) tool_list_to_df(all_tools$bioc) else NULL,
    if (n_github > 0) tool_list_to_df(all_tools$github) else NULL
  )
}

#' Default test tags for mocking
#' @keywords internal
default_test_tags <- function() {
  c("bacteria", "microbe", "genomics", "sequencing")
}
