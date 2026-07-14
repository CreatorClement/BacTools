test_that("export_catalog creates output file", {
  temp_file <- tempfile(fileext = ".csv")
  
  # Create sample data - must be a DATA FRAME, not a list
  sample_results <- data.frame(
    name = c("pkg1", "pkg2"),
    source = c("CRAN", "Bioconductor"),
    summary = c("desc1", "desc2"),
    stringsAsFactors = FALSE
  )
  
  result <- export_catalog(sample_results, filename = temp_file, include_timestamp = FALSE)
  
  expect_true(file.exists(temp_file))
  expect_equal(result, temp_file)
  
  # Verify contents
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 2)
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog adds timestamp when requested", {
  # Must be a data frame
  sample_results <- data.frame(
    name = "pkg1",
    source = "CRAN",
    summary = "desc1",
    stringsAsFactors = FALSE
  )
  
  temp_dir <- tempdir()
  base_file <- file.path(temp_dir, "test_export.csv")
  
  result <- export_catalog(sample_results, filename = base_file, include_timestamp = TRUE)
  
  # Should have timestamp added
  expect_true(file.exists(result))
  expect_match(result, "_\\d{8}_\\d{6}\\.csv$")
  expect_true(result != base_file)  # Should be different from input
  
  # Clean up
  unlink(result)
})

test_that("export_catalog handles empty results", {
  temp_file <- tempfile(fileext = ".csv")
  
  # Empty data frame (not empty list)
  empty_results <- data.frame(
    name = character(0),
    source = character(0),
    summary = character(0),
    stringsAsFactors = FALSE
  )
  
  # Should not error with empty data frame
  expect_no_error({
    result <- export_catalog(empty_results, filename = temp_file, include_timestamp = FALSE)
  })
  
  expect_true(file.exists(temp_file))
  
  # Verify it's empty
  imported <- read.csv(temp_file)
  expect_equal(nrow(imported), 0)
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog returns correct filename", {
  sample_results <- data.frame(
    name = "pkg1",
    source = "CRAN",
    summary = "Test package",
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  # Without timestamp, should return exact filename
  result <- export_catalog(sample_results, filename = temp_file, include_timestamp = FALSE)
  expect_equal(result, temp_file)
  
  # Clean up
  unlink(temp_file)
})

test_that("export_catalog preserves data integrity", {
  # Create test data with various column types
  test_data <- data.frame(
    name = c("pkg1", "pkg2"),
    source = c("CRAN", "GitHub"),
    summary = c("Package 1", "Package 2"),
    stars = c(100, 200),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  export_catalog(test_data, filename = temp_file, include_timestamp = FALSE)
  
  # Read back and compare
  imported <- read.csv(temp_file)
  
  expect_equal(nrow(imported), nrow(test_data))
  expect_equal(imported$name, test_data$name)
  expect_equal(imported$source, test_data$source)
  expect_equal(imported$stars, test_data$stars)
  
  # Clean up
  unlink(temp_file)
})
