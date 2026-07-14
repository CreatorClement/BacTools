#' Query All Repositories (CRAN, Bioconductor, and GitHub)
#'
#' Search all three repositories and combine results into a unified catalog
#'
#' @param tags Character vector of search tags used across CRAN, Bioconductor, and GitHub (default: default_bacterial_tags)
#' @param additional_tags Additional tags to append to the search (default: NULL)
#' @param use_defaults Logical, whether to use default tags (default: TRUE)
#' @param include_cran Logical, include CRAN packages (default: TRUE)
#' @param include_bioc Logical, include Bioconductor packages (default: TRUE)
#' @param include_github Logical, include GitHub repositories (default: TRUE)
#' @param github_token GitHub Personal Access Token (default: NULL, uses GITHUB_PAT env var)
#' @param github_per_page Results per page for GitHub (default: 30)
#' @param github_pages Pages to retrieve per tag (default: 2)
#' @param add_citations Logical, retrieve citation counts for CRAN/Bioc packages (default: FALSE)
#' @param return_df Logical, return as data frame instead of list (default: TRUE)
#' @return Data frame or list of package/repository information from all sources
#' @importFrom dplyr bind_rows distinct mutate relocate last_col
#' @export
#' @examples
#' \dontrun{
#' # Query all repositories with defaults
#' all_tools <- search_bactools()
#'
#' # Add custom terms to all searches
#' all_tools <- search_bactools(
#'   additional_tags = c("sequencing", "assembly", "phylogenetics", "metagenomics")
#' )
#'
#' # Query only GitHub with custom tags
#' github_only <- search_bactools(
#'   tags = c("viral-genomics", "phage"),
#'   use_defaults = FALSE,
#'   include_cran = FALSE,
#'   include_bioc = FALSE,
#'   github_token = "ghp_xxxx"
#' )
#'
#' # Full catalog with citation counts
#' full_catalog <- search_bactools(
#'   add_citations = TRUE,
#'   github_token = Sys.getenv("GITHUB_PAT")
#' )
#' }
search_bactools <- function(tags = NULL,
                                   additional_tags = NULL,
                                   use_defaults = TRUE,
                                   include_cran = TRUE,
                                   include_bioc = TRUE,
                                   include_github = TRUE,
                                   github_token = NULL,
                                   github_per_page = 30,
                                   github_pages = 2,
                                   add_citations = FALSE,
                                   return_df = TRUE) {

  all_tools <- list()

  # Query CRAN
  if (include_cran) {
    message(strrep("=", 60))
    message("Querying CRAN...")
    message(strrep("=", 60))
    cran_tools <- query_cran_by_tags(
      tags = tags,
      additional_tags = additional_tags,
      use_defaults = use_defaults
    )
    all_tools$cran <- cran_tools
  }

  # Query Bioconductor
  if (include_bioc) {
    message(paste0("\n", strrep("=", 60)))
    message("Querying Bioconductor...")
    message(strrep("=", 60))
    bioc_tools <- query_bioc_by_tags(
      tags = tags,
      additional_tags = additional_tags,
      use_defaults = use_defaults
    )
    all_tools$bioc <- bioc_tools
  }

  # Query GitHub
  if (include_github) {
    message(paste0("\n", strrep("=", 60)))
    message("Querying GitHub...")
    message(strrep("=", 60))
    github_tools <- query_github_by_tags(
      tags = tags,
      additional_tags = additional_tags,
      use_defaults = use_defaults,
      github_token = github_token,
      per_page = github_per_page,
      pages = github_pages
    )
    all_tools$github <- github_tools
  }

  if (!return_df) {
    return(all_tools)
  }

  # Convert to data frames and combine
  message(paste0("\n", strrep("=", 60)))
  message("Combining results...")
  message(strrep("=", 60))

  combined <- dplyr::bind_rows(
    if (include_cran) tool_list_to_df(all_tools$cran) else NULL,
    if (include_bioc) tool_list_to_df(all_tools$bioc) else NULL,
    if (include_github) all_tools$github else NULL
  )

  # Add citation counts if requested
  if (add_citations && nrow(combined) > 0) {
    message("Retrieving citation counts (this may take a while)...")
    combined <- dplyr::mutate(combined,
      citation_count = ifelse(
        source %in% c("CRAN", "Bioconductor"),
        sapply(doi, get_citation_count_cached),
        NA_integer_
      )
    )
  }

  # Remove duplicates and add catalog date
  combined <- dplyr::mutate(
    dplyr::distinct(combined, name, source, .keep_all = TRUE),
    catalog_date = Sys.time()
  )

  # Move owner to the last column
  combined <- dplyr::relocate(combined, owner, .after = dplyr::last_col())

  message(paste0("\n", strrep("=", 60)))
  message(sprintf("SUMMARY: Found %d CRAN, %d Bioconductor, %d GitHub tools (Total: %d unique)",
                  sum(combined$source == "CRAN", na.rm = TRUE),
                  sum(combined$source == "Bioconductor", na.rm = TRUE),
                  sum(combined$source == "GitHub", na.rm = TRUE),
                  nrow(combined)))
  message(strrep("=", 60))

  return(combined)
}
