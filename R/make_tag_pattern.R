# make_tag_pattern.R

#' make_tag_pattern
#' The pattern produced by the function makes it easy to be used in functions like 
#' grep(), str_detect(), or other string matching operations in R to find any 
#' occurrences of these keywords.
#'
#' @param tags A character vector of tags (e.g., c("bacteria", "microbiome"))
#' @return A regex string that matches any of the tags.
#' @examples
#' Input: ("bacteria", "microbiome", "antibiotic") or c("bacteria", "microbiome", "antibiotic")
#' pattern <- make_tag_pattern("bacteria", "microbiome", "microbiomes")
make_tag_pattern <- function(...) {
  tags <- unlist(list(...))      # Grabs tags whether via vector or sequence
  paste(tags, collapse = "|")    # Collapses them into a single regex string
}
#' Output: "bacteria|microbiome|antibiotic"