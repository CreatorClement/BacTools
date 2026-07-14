#' Repeat String Operator
#'
#' @param x String to repeat
#' @param n Number of times to repeat
#' @return Repeated string
#' @keywords internal
`%R%` <- function(x, n) {
  paste(rep(x, n), collapse = "")
}

#' Create Tag Pattern for Regex Matching
#'
#' @param tags Character vector of tags
#' @return A regex pattern string with tags separated by |
#' @keywords internal
make_tag_pattern <- function(tags) {
  paste(tags, collapse = "|")
}

#' Classify Tool by Name
#'
#' Categorizes a bioinformatics tool based on its name
#'
#' @param name Character string of the tool name
#' @return Character string of the tool category
#' @export
#' @examples
#' classify_tool("FastQC")
#' classify_tool("QIIME2")
classify_tool <- function(name) {
  name_lower <- tolower(name)
  
  # More efficient using switch-like logic with vectorized operations
  categories <- list(
    "Visualization Tools" = c("itol", "cytoscape", "visual"),
    "Sequence Analysis" = c("fastqc", "bwa", "blast", "bowtie", "sequence"),
    "Phylogenetic and evolutionary analysis" = c("raxml", "beast", "phylo", "treemacs", "evolution"),
    "Comparative genomics" = c("mauve", "mummer", "progressive"),
    "Metagenomics and community analysis" = c("qiime", "metaphlan", "metagenomic", "microbiome")
  )
  
  for (category in names(categories)) {
    pattern <- paste(categories[[category]], collapse = "|")
    if (grepl(pattern, name_lower)) {
      return(category)
    }
  }
  
  return("Specialized analysis")
}

#' Convert Tool List to Data Frame
#'
#' @param tool_list List of tools with nested structure
#' @return A data frame with tool information
#' @importFrom dplyr bind_rows
#' @keywords internal
tool_list_to_df <- function(tool_list) {
  cleaned <- lapply(tool_list, function(x) {
    x[sapply(x, is.null)] <- ""
    as.data.frame(x, stringsAsFactors = FALSE)
  })
  dplyr::bind_rows(cleaned)
}
