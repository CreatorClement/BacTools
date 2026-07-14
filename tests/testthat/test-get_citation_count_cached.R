test_that("get_citation_count_cached returns numeric value", {
  skip_if_offline()
  skip_on_cran()
  
  # Use DOI parameter, not package parameter
  doi <- "10.32614/CRAN.package.ggplot2"
  
  result <- get_citation_count_cached(doi = doi)
  
  # Should return integer or NA
  expect_true(is.integer(result) || is.na(result))
  
  # Clean up cache file
  if (file.exists("cran_bioc_citation_cache.rds")) {
    unlink("cran_bioc_citation_cache.rds")
  }
})

test_that("get_citation_count_cached uses cache", {
  skip_if_offline()
  skip_on_cran()
  
  doi <- "10.32614/CRAN.package.dplyr"
  cache_file <- tempfile(fileext = ".rds")
  
  # First call - creates cache
  result1 <- get_citation_count_cached(doi = doi, cache_file = cache_file)
  expect_true(file.exists(cache_file))
  
  # Second call - uses cache
  result2 <- get_citation_count_cached(doi = doi, cache_file = cache_file)
  
  # Results should be identical
  expect_equal(result1, result2)
  
  # Clean up
  unlink(cache_file)
})

test_that("get_citation_count_cached handles nonexistent packages", {
  skip_if_offline()
  skip_on_cran()
  
  # Use a DOI that doesn't exist
  doi <- "10.32614/CRAN.package.nonexistentpackage12345"
  cache_file <- tempfile(fileext = ".rds")
  
  # Should return NA for non-existent package, not error
  result <- expect_warning(
    get_citation_count_cached(doi = doi, cache_file = cache_file)
  )
  
  expect_true(is.na(result))
  
  # Clean up
  unlink(cache_file)
})

test_that("get_citation_count_cached handles invalid DOIs", {
  cache_file <- tempfile(fileext = ".rds")
  
  # Test various invalid inputs
  expect_equal(get_citation_count_cached(doi = NA, cache_file = cache_file), NA_integer_)
  expect_equal(get_citation_count_cached(doi = "", cache_file = cache_file), NA_integer_)
  expect_equal(get_citation_count_cached(doi = NULL, cache_file = cache_file), NA_integer_)
  
  # Clean up
  if (file.exists(cache_file)) unlink(cache_file)
})

test_that("get_citation_count_cached creates and uses cache file", {
  cache_file <- tempfile(fileext = ".rds")
  
  # Cache file shouldn't exist yet
  expect_false(file.exists(cache_file))
  
  # Call with valid DOI
  doi <- "10.32614/CRAN.package.ggplot2"
  result <- get_citation_count_cached(doi = doi, cache_file = cache_file)
  
  # Cache file should now exist
  expect_true(file.exists(cache_file))
  
  # Read cache and verify structure
  cache <- readRDS(cache_file)
  expect_type(cache, "list")
  expect_true(doi %in% names(cache))
  
  # Clean up
  unlink(cache_file)
})
