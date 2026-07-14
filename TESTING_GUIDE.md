# BacTools Testing Guide

Complete guide for setting up and using testthat with the BacTools package.

## Quick Start

1. **Install required packages:**
   ```r
   source("setup_tests.R")
   ```

2. **Run all tests:**
   ```r
   devtools::test()
   ```

3. **Run a specific test file:**
   ```r
   testthat::test_file("tests/testthat/test-query_CRAN.R")
   ```

## Directory Structure

```
BacTools/
├── tests/
│   ├── testthat.R              # Main test runner
│   ├── README.md               # Tests documentation
│   └── testthat/
│       ├── setup.R             # Test helpers and fixtures
│       ├── test-default_tags.R
│       ├── test-export_catalog.R
│       ├── test-get_citation_count_cached.R
│       ├── test-make_tag_pattern.R
│       ├── test-query_all.R
│       ├── test-query_Bioconductor.R
│       ├── test-query_CRAN.R
│       ├── test-query_Github.R
│       └── test-utils.R
└── setup_tests.R               # Setup script
```

## Test File Naming Convention

- Test files must start with `test-`
- Name should match the R source file being tested
- Example: `R/query_CRAN.R` → `tests/testthat/test-query_CRAN.R`

## Writing Tests

### Basic Test Structure

```r
test_that("function does what it should", {
  # Arrange: Set up test data
  input <- "test_data"
  
  # Act: Call the function
  result <- your_function(input)
  
  # Assert: Check the result
  expect_equal(result, expected_output)
})
```

### Common Expectations

```r
# Equality
expect_equal(object, expected)
expect_identical(object, expected)

# Type checking
expect_type(object, "character")
expect_s3_class(object, "data.frame")

# Logical conditions
expect_true(condition)
expect_false(condition)

# Errors and warnings
expect_error(bad_function())
expect_warning(warning_function())
expect_message(message_function())

# No errors
expect_error(good_function(), NA)
```

### Skipping Tests

```r
# Skip on CRAN
test_that("API test", {
  skip_on_cran()
  # ... test code ...
})

# Skip if offline
test_that("network test", {
  skip_if_offline()
  # ... test code ...
})

# Custom skip
test_that("special test", {
  skip("Not yet implemented")
  # ... test code ...
})
```

## Testing API Functions

For functions that query external APIs (CRAN, Bioconductor, GitHub):

```r
test_that("query_CRAN works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  result <- query_CRAN(tags = "microbiome", max_results = 5)
  
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 0)
  
  if (nrow(result) > 0) {
    expect_true("package" %in% names(result))
  }
})
```

## Testing File I/O

```r
test_that("export_catalog creates file", {
  # Use temporary file
  temp_file <- tempfile(fileext = ".csv")
  
  # Test function
  export_catalog(data, output_file = temp_file)
  
  # Check result
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
})
```

## Test Coverage

### Check coverage
```r
# Install covr
install.packages("covr")

# Run coverage
library(covr)
coverage <- package_coverage()
coverage

# Generate HTML report
report(coverage)
```

### Aim for high coverage
- Target: >80% code coverage
- Critical functions should have 100% coverage
- Document any intentionally untested code

## Running Tests

### During development
```r
# Test everything
devtools::test()

# Test with coverage
devtools::test_coverage()

# Test specific file
testthat::test_file("tests/testthat/test-query_CRAN.R")
```

### Before committing
```r
# Run full package check
devtools::check()

# Or from command line
R CMD check .
```

### Continuous Integration

Add to `.github/workflows/R-CMD-check.yaml`:
```yaml
name: R-CMD-check
on: [push, pull_request]
jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: r-lib/actions/setup-r@v2
      - name: Install dependencies
        run: |
          install.packages(c("devtools", "testthat"))
          devtools::install_deps(dependencies = TRUE)
        shell: Rscript {0}
      - name: Check
        run: devtools::check()
        shell: Rscript {0}
```

## Customizing Tests

### 1. Update test expectations

Review each test file and adjust expectations based on your actual function behavior:

```r
# In test-default_tags.R
test_that("default_tags contains expected terms", {
  tags <- default_tags()
  
  # Update these to match your actual default tags
  expect_true("bacteria" %in% tags)
  expect_true("microbiome" %in% tags)
})
```

### 2. Add function-specific tests

For `utils.R`, add tests for your specific utility functions:

```r
# Example if you have a validate_tags() function
test_that("validate_tags checks input correctly", {
  expect_true(validate_tags(c("bacteria", "microbiome")))
  expect_error(validate_tags(NULL))
  expect_error(validate_tags(123))
})
```

### 3. Add integration tests

Test how functions work together:

```r
test_that("full workflow works", {
  skip_if_offline()
  skip_on_cran()
  
  # Get tags
  tags <- default_tags()
  
  # Create pattern
  pattern <- make_tag_pattern(tags)
  
  # Query all sources
  results <- query_all(tags = tags, max_results = 5)
  
  # Export results
  temp_file <- tempfile(fileext = ".csv")
  export_catalog(results, output_file = temp_file)
  
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})
```

## Best Practices

1. **Test one thing per test**: Each test should verify a single behavior
2. **Use descriptive names**: Test names should clearly state what's being tested
3. **Keep tests independent**: Tests shouldn't depend on each other
4. **Clean up resources**: Always remove temporary files and restore state
5. **Use setup.R for common code**: Put shared helpers in setup.R
6. **Skip appropriately**: Use skip_on_cran() for slow/network tests
7. **Test edge cases**: Empty inputs, NULL, invalid types, etc.
8. **Test error handling**: Verify functions fail gracefully

## Debugging Tests

### Run test with browser
```r
test_that("my test", {
  browser()  # Debugger will stop here
  result <- my_function()
  expect_equal(result, expected)
})
```

### Verbose output
```r
devtools::test(reporter = "progress")
```

### Test specific function interactively
```r
# Load package
devtools::load_all()

# Run function manually
result <- query_CRAN(tags = "test", max_results = 5)
str(result)
```

## Troubleshooting

### Tests fail in R CMD check but pass in devtools::test()
- Check for dependencies in DESCRIPTION
- Ensure all required packages are loaded in tests
- Check for path issues (use system.file() for package files)

### Tests are slow
- Use skip_on_cran() for slow tests
- Mock API calls for faster testing
- Use smaller max_results values in tests

### Coverage is low
- Add tests for untested functions
- Check for untested branches (if/else statements)
- Test error conditions

## Additional Resources

- testthat documentation: https://testthat.r-lib.org/
- R Packages book (Testing chapter): https://r-pkgs.org/testing-basics.html
- Writing R Extensions: https://cran.r-project.org/doc/manuals/R-exts.html
