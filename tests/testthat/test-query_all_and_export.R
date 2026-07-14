# Tests for query_all.R and export_catalog.R

test_that("search_bactools combines results correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test with limited queries to speed up testing
  result <- search_bactools(
    tags = c("sequence"),
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  expect_s3_class(result, "data.frame")
  expect_true("name" %in% names(result))
  expect_true("source" %in% names(result))
  expect_true("catalog_date" %in% names(result))
})

test_that("search_bactools respects include flags", {
  skip_if_offline()
  skip_on_cran()
  
  # Test with only CRAN
  result <- search_bactools(
    tags = c("sequence"),
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  if (nrow(result) > 0) {
    expect_true(all(result$source == "CRAN"))
  }
})

test_that("search_bactools returns list when return_df = FALSE", {
  skip_if_offline()
  skip_on_cran()
  
  result <- search_bactools(
    tags = c("sequence"),
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = FALSE
  )
  
  expect_type(result, "list")
  expect_true("cran" %in% names(result))
})

test_that("search_bactools handles empty results", {
  skip_if_offline()
  skip_on_cran()
  
  # Use nonsensical tags that won't match anything
  result <- search_bactools(
    tags = c("xyznonexistent12345"),
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  expect_s3_class(result, "data.frame")
})

test_that("search_bactools removes duplicates", {
  skip_if_offline()
  skip_on_cran()
  
  result <- search_bactools(
    tags = c("sequence"),
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  if (nrow(result) > 0) {
    # Check for duplicate name + source combinations
    duplicates <- duplicated(result[, c("name", "source")])
    expect_false(any(duplicates))
  }
})

# Tests for export_catalog

test_that("export_catalog creates CSV file", {
  # Create sample catalog as DATA FRAME
  catalog <- data.frame(
    name = c("tool1", "tool2"),
    source = c("CRAN", "GitHub"),
    summary = c("Summary 1", "Summary 2"),
    stringsAsFactors = FALSE
  )
  
  # Export to temp file
  temp_file <- tempfile(fileext = ".csv")
  result <- export_catalog(catalog, filename = temp_file, include_timestamp = FALSE)
  
  # Check file was created
  expect_true(file.exists(temp_file))
  
  # Check returned path
  expect_equal(result, temp_file)
  
  # Check contents
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 2)
  expect_equal(imported$name, c("tool1", "tool2"))
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog adds timestamp when requested", {
  catalog <- data.frame(
    name = c("tool1"),
    source = c("CRAN"),
    stringsAsFactors = FALSE
  )
  
  temp_dir <- tempdir()
  base_name <- "test_catalog.csv"
  
  result <- export_catalog(catalog, 
                          filename = file.path(temp_dir, base_name), 
                          include_timestamp = TRUE)
  
  # Check that filename contains timestamp pattern
  expect_match(result, "_\\d{8}_\\d{6}\\.csv$")
  
  # Check file exists
  expect_true(file.exists(result))
  
  # Clean up
  unlink(result)
})

test_that("export_catalog does not add timestamp when not requested", {
  catalog <- data.frame(
    name = c("tool1"),
    source = c("CRAN"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  result <- export_catalog(catalog, filename = temp_file, include_timestamp = FALSE)
  
  # Check filename is exactly what was specified
  expect_equal(result, temp_file)
  
  # Check file exists
  expect_true(file.exists(result))
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog handles empty catalog", {
  catalog <- data.frame(
    name = character(0),
    source = character(0),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  result <- export_catalog(catalog, filename = temp_file, include_timestamp = FALSE)
  
  # Check file was created even with empty data
  expect_true(file.exists(result))
  
  # Check it has 0 rows
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 0)
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog preserves column names and types", {
  catalog <- data.frame(
    name = c("pkg1", "pkg2"),
    source = c("CRAN", "Bioconductor"),
    summary = c("A package", "Another package"),
    stars = c(100, 200),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  export_catalog(catalog, filename = temp_file, include_timestamp = FALSE)
  
  # Read back
  imported <- read.csv(temp_file)
  
  # Check structure preserved
  expect_equal(names(imported), names(catalog))
  expect_equal(imported$name, catalog$name)
  expect_equal(imported$stars, catalog$stars)
  
  # Clean up
  unlink(temp_file)
})

test_that("integration test: query and export workflow", {
  skip_if_offline()
  skip_on_cran()
  
  # Query small dataset
  results <- search_bactools(
    tags = "phylogenetic",
    use_defaults = FALSE,
    include_cran = TRUE,
    include_bioc = FALSE,
    include_github = FALSE,
    return_df = TRUE
  )
  
  if (nrow(results) > 0) {
    # Export results
    temp_file <- tempfile(fileext = ".csv")
    export_path <- export_catalog(results, filename = temp_file, include_timestamp = FALSE)
    
    # Verify export
    expect_true(file.exists(export_path))
    
    # Read back and verify
    imported <- read.csv(export_path)
    expect_equal(nrow(imported), nrow(results))
    expect_true(all(names(results) %in% names(imported)))
    
    # Clean up
    unlink(export_path)
  }
})
