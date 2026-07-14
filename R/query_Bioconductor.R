#' Query Bioconductor Packages by Tags
#'
#' Search Bioconductor repository for packages matching specified tags
#'
#' @param tags Character vector of search tags (default: default_bacterial_tags)
#' @param additional_tags Character vector of additional tags to append to the default tags (default: NULL)
#' @param use_defaults Logical, whether to include default_bacterial_tags (default: TRUE)
#' @return List of package information
#' @importFrom BiocPkgTools biocPkgList
#' @export
#' @examples
#' \dontrun{
#' bioc_tools <- query_bioc_by_tags()
#' bioc_tools <- query_bioc_by_tags(additional_tags = c("sequencing", "assembly"))
#' }
query_bioc_by_tags <- function(tags = NULL, 
                               additional_tags = NULL,
                               use_defaults = TRUE) {
  final_tags <- build_tag_vector(tags, additional_tags, use_defaults)
  
  message(sprintf("Searching Bioconductor with %d tags: %s", 
                  length(final_tags), 
                  paste(final_tags, collapse = ", ")))
  
  tag_pattern <- make_tag_pattern(final_tags)
  all_bioc <- BiocPkgTools::biocPkgList()
  
  title_match <- grepl(tag_pattern, all_bioc$Title, ignore.case = TRUE)
  desc_match <- grepl(tag_pattern, all_bioc$Description, ignore.case = TRUE)
  select_bioc <- all_bioc[title_match | desc_match, ]
  
  if (nrow(select_bioc) == 0) {
    message("No Bioconductor packages found matching the specified tags")
    return(list())
  }
  
  message(sprintf("Found %d Bioconductor packages", nrow(select_bioc)))
  
  tools <- lapply(seq_len(nrow(select_bioc)), function(i) {
    entry <- select_bioc[i, ]
    pkg_name <- entry$Package
    doi_str <- paste0("10.18129/B9.bioc.", pkg_name)
    
    list(
      name = pkg_name,
      owner = NA_character_,
      author = entry$Author %||% NA_character_,
      summary = entry$Title %||% NA_character_,
      doi = doi_str,
      apa_citation = sprintf(
        "%s. (%s). %s. R package version %s. https://doi.org/%s",
        pkg_name,
        substr(entry$`Date/Publication` %||% "", 1, 4),
        entry$Title %||% "",
        entry$Version %||% "",
        doi_str
      ),
      language = "R",
      release_date = entry$`Date/Publication` %||% NA_character_,
      docs = paste0("https://bioconductor.org/packages/release/bioc/html/", pkg_name, ".html"),
      tutorials = paste0("https://bioconductor.org/packages/release/bioc/vignettes/", 
                         pkg_name, "/inst/doc/"),
      license = entry$License %||% NA_character_,
      source = "Bioconductor",
      category = classify_tool(entry$Title %||% pkg_name)
    )
  })
  
  return(tools)
}