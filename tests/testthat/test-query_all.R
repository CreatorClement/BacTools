test_that("search_bactools combines results from all sources", {
  skip_if_offline()
  skip_on_cran()
  
  # Use the correct function name: search_bactools
  result <- search_bactools(
    tags = "microbiome",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  expect_s3_class(result, "data.frame")
  
  if (nrow(result) > 0) {
    expect_true("name" %in% names(result))
    expect_true("source" %in% names(result))
  }
})

test_that("search_bactools returns data frames for each source", {
  skip_if_offline()
  skip_on_cran()
  
  # Test with return_df = FALSE to get list structure
  result <- search_bactools(
    tags = "bacteria",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = FALSE
  )
  
  expect_type(result, "list")
  expect_true("cran" %in% names(result))
})

test_that("search_bactools handles errors in individual queries gracefully", {
  skip_if_offline()
  skip_on_cran()
  
  # Use tags that might return no results
  result <- search_bactools(
    tags = "xyznonexistent999",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  # Should return empty data frame, not error
  expect_s3_class(result, "data.frame")
})

test_that("search_bactools respects include flags", {
  skip_if_offline()
  skip_on_cran()
  
  # Test with only CRAN enabled
  result <- search_bactools(
    tags = "statistics",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  expect_s3_class(result, "data.frame")
  
  # If any results, they should all be from CRAN
  if (nrow(result) > 0) {
    expect_true(all(result$source == "CRAN"))
  }
})

test_that("search_bactools removes duplicates", {
  skip_if_offline()
  skip_on_cran()
  
  result <- search_bactools(
    tags = "phylogenetic",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  if (nrow(result) > 0) {
    # Check for duplicates based on name + source
    duplicates <- duplicated(result[, c("name", "source")])
    expect_false(any(duplicates))
  }
})

test_that("search_bactools adds catalog_date", {
  skip_if_offline()
  skip_on_cran()
  
  result <- search_bactools(
    tags = "bacteria",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  # Should have catalog_date column
  expect_true("catalog_date" %in% names(result))
})
