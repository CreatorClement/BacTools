# testthat Quick Reference for BacTools

## Setup

```r
# Run once to set up testthat
source("setup_tests.R")

# Or manually
install.packages("testthat")
usethis::use_testthat()
```

## Running Tests

```r
# All tests
devtools::test()

# Specific file
testthat::test_file("tests/testthat/test-query_CRAN.R")

# With coverage
devtools::test_coverage()

# Full package check
devtools::check()
```

## Test Structure

```r
test_that("descriptive name", {
  # Your test code here
  expect_equal(actual, expected)
})
```

## Common Expectations

| Function | Purpose |
|----------|---------|
| `expect_equal(x, y)` | Values are equal (within tolerance) |
| `expect_identical(x, y)` | Values are exactly identical |
| `expect_true(x)` | Value is TRUE |
| `expect_false(x)` | Value is FALSE |
| `expect_null(x)` | Value is NULL |
| `expect_type(x, "type")` | Check R type (character, double, list, etc.) |
| `expect_s3_class(x, "class")` | Check S3 class (data.frame, etc.) |
| `expect_error(expr)` | Expression throws an error |
| `expect_warning(expr)` | Expression produces a warning |
| `expect_message(expr)` | Expression produces a message |
| `expect_error(expr, NA)` | Expression does NOT throw an error |
| `expect_length(x, n)` | Object has length n |
| `expect_named(x, names)` | Object has specific names |

## Skip Functions

```r
skip("Reason for skipping")
skip_if_offline()
skip_on_cran()
skip_if_not_installed("package")
skip_on_os("windows")
skip_if(condition, "message")
```

## File Operations in Tests

```r
# Create temporary file
temp_file <- tempfile(fileext = ".csv")

# Use it
write.csv(data, temp_file)

# Clean up
unlink(temp_file)

# Or use withr for automatic cleanup
withr::with_tempfile("temp_file", {
  write.csv(data, temp_file)
  # temp_file automatically deleted after
})
```

## Testing API Functions

```r
test_that("API function works", {
  skip_if_offline()    # Skip if no internet
  skip_on_cran()       # Skip on CRAN checks
  
  result <- query_function()
  
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 0)
})
```

## Debugging Tests

```r
# Add browser() to pause
test_that("my test", {
  browser()  # Debugger stops here
  result <- my_function()
  expect_equal(result, expected)
})

# Run with verbose output
devtools::test(reporter = "progress")

# Load package and test interactively
devtools::load_all()
my_function()  # Test manually
```

## Test Coverage

```r
# Check coverage
library(covr)
coverage <- package_coverage()
coverage

# Generate report
report(coverage)

# Coverage for specific file
file_coverage("R/query_CRAN.R", "tests/testthat/test-query_CRAN.R")
```

## Best Practices

✅ **DO:**
- Test one thing per test
- Use descriptive test names
- Clean up temporary files
- Test edge cases (NULL, empty, invalid)
- Skip slow tests on CRAN
- Test error conditions

❌ **DON'T:**
- Make tests depend on each other
- Test implementation details
- Leave temporary files
- Make assumptions about external state
- Forget to handle errors
- Hard-code file paths

## Common Patterns

### Testing data frames
```r
test_that("returns correct data structure", {
  result <- my_function()
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 5)
  expect_true("column_name" %in% names(result))
})
```

### Testing with fixtures
```r
test_that("processes fixture correctly", {
  fixture <- data.frame(x = 1:3, y = 4:6)
  result <- process_data(fixture)
  
  expect_equal(nrow(result), 3)
})
```

### Testing errors
```r
test_that("fails on invalid input", {
  expect_error(my_function(NULL))
  expect_error(my_function(-1), "must be positive")
})
```

### Testing file output
```r
test_that("creates output file", {
  temp <- tempfile(fileext = ".csv")
  
  export_function(data, temp)
  
  expect_true(file.exists(temp))
  
  # Verify content
  imported <- read.csv(temp)
  expect_equal(nrow(imported), expected_rows)
  
  unlink(temp)
})
```

## File Structure

```
package/
├── tests/
│   ├── testthat.R           # Test runner
│   └── testthat/
│       ├── setup.R          # Test helpers
│       ├── test-file1.R     # Tests for R/file1.R
│       └── test-file2.R     # Tests for R/file2.R
```

## DESCRIPTION File

Add to your DESCRIPTION:
```
Suggests:
    testthat (>= 3.0.0),
    covr
```

## Quick Commands Summary

```bash
# Command line
R CMD check .                 # Full package check
R -e 'devtools::test()'      # Run tests

# In R console
devtools::test()              # Run all tests
devtools::test_coverage()     # Check coverage
devtools::check()             # Full check
testthat::test_file("tests/testthat/test-file.R")  # Single file
```
