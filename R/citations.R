#' Get Citation Count with Caching
#'
#' Retrieves citation count for a DOI with local caching to reduce API calls
#'
#' @param doi Character string of the DOI
#' @param cache_file Path to cache file (default: "cran_bioc_citation_cache.rds")
#' @return Integer citation count or NA if unavailable
#' @importFrom rcrossref cr_citation_count
#' @export
#' @examples
#' \dontrun{
#' get_citation_count_cached("10.32614/CRAN.package.dplyr")
#' }
get_citation_count_cached <- function(doi, 
                                      cache_file = "cran_bioc_citation_cache.rds") {
  # Early return for invalid DOI
  if (is.na(doi) || doi == "" || is.null(doi)) {
    return(NA_integer_)
  }
  
  # Load or initialize cache
  cit_cache <- if (file.exists(cache_file)) {
    readRDS(cache_file)
  } else {
    list()
  }
  
  # Return cached value if available
  if (!is.null(cit_cache[[doi]])) {
    return(cit_cache[[doi]])
  }
  
  # Query API with error handling
  Sys.sleep(1)  # Rate limiting
  res <- tryCatch({
    count <- rcrossref::cr_citation_count(doi)$count
    if (is.null(count) || (length(count) == 1 && is.na(count))) {
      warning(sprintf("Failed to retrieve citation count for DOI %s: no data returned", doi))
      NA_integer_
    } else {
      as.integer(count)
    }
  },
  error = function(e) {
    warning(sprintf("Failed to retrieve citation count for DOI %s: %s", doi, e$message))
    NA_integer_
  })

  # Update cache
  cit_cache[[doi]] <- res
  saveRDS(cit_cache, cache_file)

  return(res)
}

#' Batch Get Citation Counts
#'
#' Efficiently retrieve citation counts for multiple DOIs
#'
#' @param dois Character vector of DOIs
#' @param cache_file Path to cache file
#' @param progress Logical, show progress bar (default: TRUE)
#' @return Integer vector of citation counts
#' @export
batch_get_citations <- function(dois, 
                                cache_file = "cran_bioc_citation_cache.rds",
                                progress = TRUE) {
  vapply(dois, get_citation_count_cached, 
         FUN.VALUE = integer(1),
         cache_file = cache_file,
         USE.NAMES = FALSE)
}