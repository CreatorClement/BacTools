# Advanced Testing Examples for BacTools
# This file demonstrates more sophisticated testing techniques

# Example 1: Testing with mock data (avoiding actual API calls)
test_that("query_cran_by_tags handles response correctly", {
  # Skip this in normal test runs, it's just an example
  skip("Example only - demonstrates mocking pattern")
  
  # Mock the API response
  mock_response <- list(
    results = data.frame(
      Package = c("pkg1", "pkg2"),
      Title = c("Title 1", "Title 2"),
      Description = c("Desc 1", "Desc 2"),
      stringsAsFactors = FALSE
    )
  )
  
  # If using mockery or similar package:
  # mockery::stub(query_cran_by_tags, 'api_call', mock_response)
  # result <- query_cran_by_tags(tags = "test")
  # expect_equal(length(result), 2)
})

# Example 2: Testing error handling
test_that("functions handle network errors gracefully", {
  skip("Example only - demonstrates error handling pattern")
  
  # Test what happens when network fails
  # This would require mocking the network call to fail
  # expect_error(query_cran_by_tags(tags = "test"), regexp = "network error")
})

# Example 3: Testing with fixtures (sample data)
test_that("export_catalog formats data correctly", {
  # Create a fixture - sample data that mimics real query results
  # export_catalog expects a DATA FRAME, not a list
  fixture_data <- data.frame(
    name = c("microbiome", "phyloseq", "DESeq2", "edgeR"),
    source = c("CRAN", "CRAN", "Bioconductor", "Bioconductor"),
    summary = c("Microbiome Analysis", "Phylogenetic Analysis", 
                "Differential Expression", "Empirical Differential"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  # Test the function with fixture data
  result <- export_catalog(fixture_data, filename = temp_file, include_timestamp = FALSE)
  
  expect_true(file.exists(temp_file))
  
  # Read back and verify
  exported <- read.csv(temp_file)
  expect_equal(nrow(exported), 4)  # 2 from CRAN + 2 from Bioconductor
  
  # Clean up
  unlink(temp_file)
})

# Example 4: Parameterized tests
test_that("query functions handle various tag formats", {
  skip_if_offline()
  skip_on_cran()
  
  # Test different tag inputs - using the actual function name
  tag_variants <- list(
    c("bacteria"),
    c("bacteria", "microbiome"),
    c("genomic"),
    c("sequence")
  )
  
  for (tags in tag_variants) {
    result <- query_cran_by_tags(tags = tags, use_defaults = FALSE)
    expect_type(result, "list")
    # All should return valid lists, even if empty
  }
})

# Example 5: Testing caching behavior
test_that("citation cache improves performance", {
  skip_if_offline()
  skip_on_cran()
  
  # Use the correct parameter name: 'doi' not 'package'
  doi <- "10.32614/CRAN.package.ggplot2"
  
  # First call - not cached
  time1 <- system.time({
    result1 <- get_citation_count_cached(doi = doi)
  })
  
  # Second call - should be cached
  time2 <- system.time({
    result2 <- get_citation_count_cached(doi = doi)
  })
  
  # Results should be identical
  expect_equal(result1, result2)
  
  # Second call should be faster (at least 50% faster)
  # Only test if both calls succeeded
  if (!is.na(result1)) {
    expect_true(time2["elapsed"] < time1["elapsed"] * 0.5)
  }
})

# Example 6: Testing with temporary directories
test_that("export handles custom output directories", {
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "output.csv")
  
  # Must be a data frame, not a list
  sample_data <- data.frame(
    name = "test",
    source = "CRAN",
    summary = "Test Package",
    stringsAsFactors = FALSE
  )
  
  result <- export_catalog(sample_data, filename = temp_file, include_timestamp = FALSE)
  
  expect_true(file.exists(temp_file))
  expect_true(dir.exists(temp_dir))
  
  # Clean up
  unlink(temp_file)
})

# Example 7: Testing multiple assertions
test_that("search_bactools returns complete results structure", {
  skip_if_offline()
  skip_on_cran()
  
  # Use the correct function name
  result <- search_bactools(
    tags = "bacteria", 
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  # Should return a data frame when return_df = TRUE
  expect_s3_class(result, "data.frame")
  
  # Check for expected columns
  if (nrow(result) > 0) {
    expect_true("name" %in% names(result))
    expect_true("source" %in% names(result))
  }
})
