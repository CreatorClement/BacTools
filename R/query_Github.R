#' Query GitHub Repositories by Tags
#'
#' Search GitHub for repositories matching specified tags with DOI and citation retrieval
#'
#' @param tags Character vector of GitHub topics to search (default: default_bacterial_tags)
#' @param additional_tags Character vector of additional tags to search (default: NULL)
#' @param use_defaults Logical, whether to use default_bacterial_tags (default: TRUE)
#' @param github_token GitHub Personal Access Token. If NULL, will check GITHUB_PAT environment variable
#' @param per_page Number of results per page (default: 30, max: 100)
#' @param pages Number of pages to retrieve per tag (default: 2)
#' @param cache_file Path to cache file for DOI and citation data (default: "github_doi_cache.rds")
#' @return Data frame of GitHub repository information
#' @importFrom httr GET add_headers status_code content
#' @importFrom jsonlite fromJSON
#' @importFrom base64enc base64decode
#' @importFrom rcrossref cr_cn
#' @importFrom purrr map_chr
#' @importFrom dplyr distinct mutate
#' @importFrom tibble tibble
#' @export
#' @examples
#' \dontrun{
#' # Use default tags with environment variable token
#' github_tools <- query_github_by_tags()
#'
#' # Provide token explicitly
#' github_tools <- query_github_by_tags(github_token = "ghp_xxxxxxxxxxxx")
#'
#' # Add custom tags
#' github_tools <- query_github_by_tags(
#'   additional_tags = c("phylogenetics", "metagenomics")
#' )
#'
#' # Use only custom tags
#' github_tools <- query_github_by_tags(
#'   tags = c("viral-genomics", "phage"),
#'   use_defaults = FALSE
#' )
#' }
query_github_by_tags <- function(tags = NULL,
                                   additional_tags = NULL,
                                   use_defaults = TRUE,
                                   github_token = NULL,
                                   per_page = 30,
                                   pages = 2,
                                   cache_file = "github_doi_cache.rds") {

  # Handle GitHub token
  if (is.null(github_token)) {
    github_token <- Sys.getenv("GITHUB_PAT")
  }
  if (github_token == "") {
    stop("GitHub token required. Set GITHUB_PAT environment variable or pass github_token argument.",
         call. = FALSE)
  }

  # Build tag vector (shared helper defined in query_CRAN.R)
  final_tags <- build_tag_vector(tags, additional_tags, use_defaults)

  message(sprintf("Searching GitHub with %d tags: %s",
                  length(final_tags),
                  paste(final_tags, collapse = ", ")))

  # Load cache into a shared environment so closures can read/write it
  cache_env <- new.env(parent = emptyenv())
  cache_env$doi_cache <- load_github_cache(cache_file)

  # Set up headers
  headers <- httr::add_headers(Authorization = paste("token", github_token))

  # Search repositories (all loops use cache_env$doi_cache directly)
  all_rows <- list()
  for (tag in final_tags) {
    message(sprintf("  Searching tag: %s", tag))
    for (page in seq_len(pages)) {
      url <- sprintf(
        "https://api.github.com/search/repositories?q=topic:%s&sort=stars&order=desc&per_page=%d&page=%d",
        tag, per_page, page
      )

      resp <- httr::GET(url, headers)

      if (httr::status_code(resp) != 200) {
        warning(sprintf("GitHub API request failed for tag '%s', page %d", tag, page))
        next
      }

      dat <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), flatten = TRUE)

      if (length(dat$items) == 0) next

      # Extract license names safely
      license_names <- extract_licenses(dat$items)

      # Create base data frame
      result_df <- data.frame(
        github_tag   = tag,
        name         = dat$items$name,
        owner        = dat$items$owner.login,
        author       = dat$items$owner.login,
        summary      = dat$items$description,
        doi          = NA_character_,
        apa_citation = NA_character_,
        language     = dat$items$language,
        release_date = dat$items$created_at,
        docs         = dat$items$html_url,
        tutorials    = NA_character_,
        license      = license_names,
        github_stars = dat$items$stargazers_count,
        source       = "GitHub",
        stringsAsFactors = FALSE
      )

      # Add DOI and citations
      for (i in seq_len(nrow(result_df))) {
        d <- get_doi_from_citation_file(result_df$owner[i], result_df$name[i],
                                        headers, cache_env)
        a <- get_apa_from_doi(d, cache_env)
        result_df$doi[i]          <- d
        result_df$apa_citation[i] <- a
      }

      all_rows[[length(all_rows) + 1]] <- result_df
      Sys.sleep(0.5)  # Rate limiting between pages
    }
  }

  results <- do.call(rbind, all_rows)

  # Save cache
  saveRDS(cache_env$doi_cache, cache_file)

  # Add category and remove duplicates
  results <- dplyr::distinct(
    dplyr::mutate(results, category = sapply(summary, classify_tool)),
    docs, .keep_all = TRUE
  )

  message(sprintf("Found %d unique GitHub repositories", nrow(results)))

  return(results)
}

#' Load GitHub DOI/Citation Cache
#'
#' @keywords internal
load_github_cache <- function(cache_file) {
  if (file.exists(cache_file)) {
    readRDS(cache_file)
  } else {
    list(doi = list(), apa = list())
  }
}

#' Extract License Information from GitHub API Response
#'
#' @keywords internal
extract_licenses <- function(items) {
  if ("license" %in% names(items)) {
    purrr::map_chr(items$license, ~ {
      if (!is.null(.x) && "name" %in% names(.x)) .x$name else NA_character_
    })
  } else {
    rep(NA_character_, nrow(items))
  }
}

#' Get DOI from CITATION.cff File
#'
#' @keywords internal
get_doi_from_citation_file <- function(owner, repo, headers, cache_env) {
  key <- paste0(owner, "/", repo)

  # Check cache
  if (!is.null(cache_env$doi_cache$doi[[key]])) {
    return(cache_env$doi_cache$doi[[key]])
  }

  Sys.sleep(1)  # Rate limiting

  url <- sprintf("https://api.github.com/repos/%s/%s/contents/CITATION.cff", owner, repo)
  resp <- httr::GET(url, headers)

  if (httr::status_code(resp) != 200) {
    cache_env$doi_cache$doi[[key]] <- NA_character_
    return(NA_character_)
  }

  tryCatch({
    content_json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
    content_txt <- rawToChar(base64enc::base64decode(content_json$content))

    # Extract DOI
    # perl = TRUE ensures \s correctly matches newlines, so the match stops
    # at the end of the doi: line instead of bleeding into subsequent YAML
    # fields (e.g. preferred-citation:, type:, author) in CITATION.cff
    match <- regmatches(content_txt, regexpr("doi:\\s*([^\\s]+)", content_txt, perl = TRUE))
    doi_val <- if (length(match) > 0) sub("doi:\\s*", "", match, perl = TRUE) else NA_character_

    cache_env$doi_cache$doi[[key]] <- doi_val
    return(doi_val)
  }, error = function(e) {
    cache_env$doi_cache$doi[[key]] <- NA_character_
    return(NA_character_)
  })
}

#' Get APA Citation from DOI
#'
#' @keywords internal
get_apa_from_doi <- function(doi, cache_env) {
  if (is.na(doi) || doi == "") return(NA_character_)

  # Check cache
  if (!is.null(cache_env$doi_cache$apa[[doi]])) {
    return(cache_env$doi_cache$apa[[doi]])
  }

  Sys.sleep(1)  # Rate limiting

  apa_val <- tryCatch({
    res <- rcrossref::cr_cn(dois = doi, format = "text", style = "apa")
    if (length(res) && !is.na(res[1])) res[1] else NA_character_
  }, error = function(e) {
    NA_character_
  })

  cache_env$doi_cache$apa[[doi]] <- apa_val
  return(apa_val)
}
