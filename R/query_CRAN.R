#' Query CRAN Packages by Tags
#'
#' Search CRAN repository for packages matching specified tags
#'
#' @param tags Character vector of search tags (default: default_bacterial_tags).
#'   Set to NULL to use only additional_tags, or provide custom tags to replace defaults.
#' @param additional_tags Character vector of additional tags to append to the default tags (default: NULL)
#' @param use_defaults Logical, whether to include default_bacterial_tags (default: TRUE)
#' @return List of package information
#' @importFrom tools CRAN_package_db
#' @export
#' @examples
#' \dontrun{
#' # Use default bacterial tags only
#' cran_tools <- query_cran_by_tags()
#' 
#' # Add custom tags to defaults
#' cran_tools <- query_cran_by_tags(additional_tags = c("sequencing", "assembly"))
#' 
#' # Use only custom tags (no defaults)
#' cran_tools <- query_cran_by_tags(tags = c("genomics", "sequencing"), use_defaults = FALSE)
#' }
query_cran_by_tags <- function(tags = NULL, 
                               additional_tags = NULL,
                               use_defaults = TRUE) {
  final_tags <- build_tag_vector(tags, additional_tags, use_defaults)
  
  message(sprintf("Searching CRAN with %d tags: %s", 
                  length(final_tags), 
                  paste(final_tags, collapse = ", ")))
  
  tag_pattern <- make_tag_pattern(final_tags)
  cran_db <- tools::CRAN_package_db()
  
  title_match <- grepl(tag_pattern, cran_db$Title, ignore.case = TRUE)
  desc_match <- grepl(tag_pattern, cran_db$Description, ignore.case = TRUE)
  select_pkgs <- cran_db[title_match | desc_match, ]
  
  if (nrow(select_pkgs) == 0) {
    message("No CRAN packages found matching the specified tags")
    return(list())
  }
  
  message(sprintf("Found %d CRAN packages", nrow(select_pkgs)))
  
  tools <- lapply(seq_len(nrow(select_pkgs)), function(i) {
    info <- select_pkgs[i, ]
    pkg_name <- info$Package
    doi_str <- paste0("10.32614/CRAN.package.", pkg_name)
    
    list(
      name = pkg_name,
      owner = NA_character_,
      author = info$Author %||% NA_character_,
      summary = info$Title %||% NA_character_,
      doi = doi_str,
      apa_citation = sprintf(
        "%s. (%s). %s. R package version %s. https://doi.org/%s",
        pkg_name,
        substr(info$Published %||% "", 1, 4),
        info$Title %||% "",
        info$Version %||% "",
        doi_str
      ),
      language = "R",
      release_date = info$Published %||% NA_character_,
      docs = paste0("https://cran.r-project.org/web/packages/", pkg_name, "/index.html"),
      tutorials = paste0("https://cran.r-project.org/web/packages/", pkg_name, "/vignettes"),
      license = info$License %||% NA_character_,
      source = "CRAN",
      category = classify_tool(info$Title %||% pkg_name)
    )
  })
  
  return(tools)
}

#' Build Final Tag Vector
#'
#' Internal helper to construct tag vector from various inputs
#'
#' @keywords internal
build_tag_vector <- function(tags, additional_tags, use_defaults) {
  if (use_defaults) {
    final_tags <- if (is.null(tags)) {
      default_bacterial_tags
    } else {
      tags
    }
  } else {
    final_tags <- tags
  }
  
  if (!is.null(additional_tags)) {
    final_tags <- c(final_tags, additional_tags)
  }
  
  final_tags <- unique(final_tags)
  
  if (length(final_tags) == 0) {
    stop("No tags provided. Please specify tags, additional_tags, or set use_defaults = TRUE")
  }
  
  return(final_tags)
}