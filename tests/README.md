# BacTools Tests

This directory contains unit tests for the BacTools package using the `testthat` framework.

## Running Tests

### Run all tests
```r
# From R console
devtools::test()

# Or using testthat directly
testthat::test_dir("tests/testthat")
```

### Run specific test file
```r
testthat::test_file("tests/testthat/test-query_CRAN.R")
```

### Run tests during package check
```bash
R CMD check .
```

## Test Structure

- `testthat.R` - Main test runner, automatically executed by `R CMD check`
- `testthat/` - Directory containing all test files
  - `setup.R` - Helper functions and fixtures available to all tests
  - `test-*.R` - Individual test files for each R source file

## Test Files

- `test-default_tags.R` - Tests for default tag functions
- `test-make_tag_pattern.R` - Tests for tag pattern creation
- `test-query_CRAN.R` - Tests for CRAN package queries
- `test-query_Bioconductor.R` - Tests for Bioconductor package queries
- `test-query_Github.R` - Tests for GitHub repository queries
- `test-query_all.R` - Tests for combined query functions
- `test-export_catalog.R` - Tests for catalog export functionality
- `test-get_citation_count_cached.R` - Tests for citation counting
- `test-utils.R` - Tests for utility functions

## Writing Tests

Follow the testthat pattern:
```r
test_that("descriptive test name", {
  # Arrange
  input <- "test_value"
  
  # Act
  result <- your_function(input)
  
  # Assert
  expect_equal(result, expected_value)
})
```

## Test Helpers

The `setup.R` file provides helper functions:
- `skip_if_offline()` - Skip tests requiring internet
- `create_sample_results()` - Generate sample query results
- `create_temp_test_dir()` - Create temporary test directories
- `cleanup_temp()` - Clean up temporary files

## Test Coverage

To check test coverage:
```r
covr::package_coverage()
covr::report()
```

## Notes

- Tests that require internet connection use `skip_if_offline()`
- Tests that query external APIs use `skip_on_cran()`
- Temporary files are created in `tempdir()` and cleaned up after tests
