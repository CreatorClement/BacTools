test_that("load_github_cache creates new cache if file doesn't exist", {
  # Use a non-existent file path
  temp_cache <- tempfile()

  result <- load_github_cache(temp_cache)

  expect_type(result, "list")
  expect_true("doi" %in% names(result))
  expect_true("apa" %in% names(result))
  expect_type(result$doi, "list")
  expect_type(result$apa, "list")
})

test_that("load_github_cache loads existing cache", {
  # Create a temporary cache file
  temp_cache <- tempfile()
  cache_data <- list(
    doi = list("owner/repo" = "10.1234/test"),
    apa = list("10.1234/test" = "Test citation")
  )
  saveRDS(cache_data, temp_cache)

  result <- load_github_cache(temp_cache)

  expect_equal(result$doi[["owner/repo"]], "10.1234/test")
  expect_equal(result$apa[["10.1234/test"]], "Test citation")

  # Clean up
  unlink(temp_cache)
})

test_that("extract_licenses handles missing license field", {
  # Test with items that have no license field
  items <- data.frame(
    name = c("repo1", "repo2"),
    stars = c(100, 200)
  )

  result <- extract_licenses(items)

  expect_type(result, "character")
  expect_equal(length(result), 2)
  expect_true(all(is.na(result)))
})

test_that("extract_licenses extracts license names", {
  # Test with items that have license information
  items <- list(
    license = list(
      list(name = "MIT License"),
      list(name = "GPL-3.0"),
      NULL
    )
  )

  result <- extract_licenses(items)

  expect_type(result, "character")
  expect_equal(length(result), 3)
  expect_equal(result[1], "MIT License")
  expect_equal(result[2], "GPL-3.0")
  expect_true(is.na(result[3]))
})

test_that("query_github_by_tags errors without token", {
  # Clear any existing GITHUB_PAT
  withr::local_envvar(GITHUB_PAT = "")

  expect_error(
    query_github_by_tags(tags = "test", use_defaults = FALSE, github_token = NULL),
    "GitHub token required"
  )
})

# Integration tests (skipped unless online and token available)
test_that("query_github_by_tags returns expected structure", {
  skip_if_offline()
  skip_on_cran()
  skip_if(Sys.getenv("GITHUB_PAT") == "", "GITHUB_PAT not set")

  # Test with a very specific tag and limited results
  result <- query_github_by_tags(
    tags = "bacterial-genomics",
    use_defaults = FALSE,
    per_page = 5,
    pages = 1,
    cache_file = tempfile()
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    # Check expected columns
    expect_true("name" %in% names(result))
    expect_true("owner" %in% names(result))
    expect_true("summary" %in% names(result))
    expect_true("source" %in% names(result))
    expect_true("github_stars" %in% names(result))
    expect_true("category" %in% names(result))

    # Check all rows have GitHub as source
    expect_true(all(result$source == "GitHub"))
  }
})
