# This file runs before all tests
# Use it to set up test fixtures, helper functions, or test data

# Helper function to check if we're offline
skip_if_offline <- function() {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
}

# Helper function to create sample query results for testing
create_sample_results <- function(n = 5) {
  data.frame(
    package = paste0("pkg", 1:n),
    title = paste0("Package ", 1:n),
    description = paste0("Description for package ", 1:n),
    stringsAsFactors = FALSE
  )
}

# Helper function to create temporary test directories
create_temp_test_dir <- function() {
  temp_dir <- tempfile()
  dir.create(temp_dir, recursive = TRUE)
  temp_dir
}

# Clean up function for temporary files/directories
cleanup_temp <- function(path) {
  if (file.exists(path)) {
    if (dir.exists(path)) {
      unlink(path, recursive = TRUE)
    } else {
      unlink(path)
    }
  }
}
