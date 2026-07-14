#!/usr/bin/env Rscript
# Script to set up testthat testing infrastructure for BacTools

cat("Setting up testthat for BacTools package...\n\n")

# Install testthat if not already installed
if (!requireNamespace("testthat", quietly = TRUE)) {
  cat("Installing testthat package...\n")
  install.packages("testthat")
}

# Install devtools if not already installed (useful for running tests)
if (!requireNamespace("devtools", quietly = TRUE)) {
  cat("Installing devtools package...\n")
  install.packages("devtools")
}

# Install covr for test coverage (optional)
if (!requireNamespace("covr", quietly = TRUE)) {
  cat("Installing covr package for test coverage...\n")
  install.packages("covr")
}

# Update DESCRIPTION file to include testthat in Suggests
cat("\nUpdating DESCRIPTION file...\n")
desc_file <- "DESCRIPTION"

if (file.exists(desc_file)) {
  desc_lines <- readLines(desc_file)
  
  # Check if Suggests field exists
  suggests_line <- grep("^Suggests:", desc_lines)
  
  if (length(suggests_line) == 0) {
    # Add Suggests field
    desc_lines <- c(desc_lines, "Suggests:", "    testthat (>= 3.0.0)")
  } else {
    # Check if testthat is already listed
    if (!any(grepl("testthat", desc_lines))) {
      # Add testthat to existing Suggests
      desc_lines[suggests_line] <- paste0(desc_lines[suggests_line], 
                                          ifelse(grepl(",$", desc_lines[suggests_line]), "", ","))
      desc_lines <- append(desc_lines, "    testthat (>= 3.0.0)", after = suggests_line)
    }
  }
  
  writeLines(desc_lines, desc_file)
  cat("DESCRIPTION file updated.\n")
} else {
  cat("Warning: DESCRIPTION file not found. Please add manually:\n")
  cat("Suggests:\n    testthat (>= 3.0.0)\n")
}

cat("\n✓ testthat setup complete!\n\n")
cat("Next steps:\n")
cat("1. Review and customize the test files in tests/testthat/\n")
cat("2. Run tests with: devtools::test()\n")
cat("3. Check test coverage with: covr::package_coverage()\n")
cat("4. Run R CMD check with tests: R CMD check .\n")
