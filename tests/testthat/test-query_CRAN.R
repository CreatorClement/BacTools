test_that("build_tag_vector handles default tags", {
  # Mock the default_bacterial_tags (you'll need to source or define this)
  # For testing purposes, we'll create a local version
  local_default_tags <- c("bacteria", "microbe", "genomics")
  
  # Test with use_defaults = TRUE and no tags specified
  with_mocked_bindings(
    default_bacterial_tags = local_default_tags,
    {
      result <- build_tag_vector(tags = NULL, additional_tags = NULL, use_defaults = TRUE)
      expect_equal(result, local_default_tags)
    },
    .package = "BacTools"
  )
})

test_that("build_tag_vector handles custom tags", {
  local_default_tags <- c("bacteria", "microbe")
  
  # Test with custom tags and use_defaults = FALSE
  custom_tags <- c("virus", "fungus")
  result <- build_tag_vector(tags = custom_tags, additional_tags = NULL, use_defaults = FALSE)
  expect_equal(result, custom_tags)
  
  # Test with custom tags overriding defaults when use_defaults = TRUE
  with_mocked_bindings(
    default_bacterial_tags = local_default_tags,
    {
      result <- build_tag_vector(tags = custom_tags, additional_tags = NULL, use_defaults = TRUE)
      expect_equal(result, custom_tags)
    },
    .package = "BacTools"
  )
})

test_that("build_tag_vector handles additional_tags", {
  local_default_tags <- c("bacteria", "microbe")
  
  with_mocked_bindings(
    default_bacterial_tags = local_default_tags,
    {
      # Test adding additional tags to defaults
      additional <- c("sequencing", "assembly")
      result <- build_tag_vector(tags = NULL, additional_tags = additional, use_defaults = TRUE)
      expect_equal(result, c(local_default_tags, additional))
      
      # Test adding additional tags to custom tags
      custom_tags <- c("virus")
      result <- build_tag_vector(tags = custom_tags, additional_tags = additional, use_defaults = TRUE)
      expect_equal(result, c(custom_tags, additional))
    },
    .package = "BacTools"
  )
})

test_that("build_tag_vector removes duplicates", {
  local_default_tags <- c("bacteria", "microbe")
  
  with_mocked_bindings(
    default_bacterial_tags = local_default_tags,
    {
      # Test with duplicate tags in additional_tags
      additional <- c("bacteria", "sequencing")
      result <- build_tag_vector(tags = NULL, additional_tags = additional, use_defaults = TRUE)
      expect_equal(result, c("bacteria", "microbe", "sequencing"))
      expect_equal(length(result), 3) # Should have 3 unique tags
    },
    .package = "BacTools"
  )
})

test_that("build_tag_vector errors with no tags", {
  # Test error when no tags are provided
  expect_error(
    build_tag_vector(tags = NULL, additional_tags = NULL, use_defaults = FALSE),
    "No tags provided"
  )
})

test_that("query_cran_by_tags returns expected structure", {
  skip_if_offline()
  skip_on_cran()
  
  # This is an integration test - it requires internet connection
  # Test with a very specific tag that should return few results
  result <- query_cran_by_tags(tags = c("phylogenetic"), use_defaults = FALSE)
  
  expect_type(result, "list")
  
  if (length(result) > 0) {
    # Check structure of first result
    first_tool <- result[[1]]
    
    expect_true("name" %in% names(first_tool))
    expect_true("summary" %in% names(first_tool))
    expect_true("source" %in% names(first_tool))
    expect_true("language" %in% names(first_tool))
    expect_equal(first_tool$source, "CRAN")
    expect_equal(first_tool$language, "R")
  }
})

test_that("query_cran_by_tags handles no results gracefully", {
  skip_if_offline()
  skip_on_cran()
  
  # Use a tag that should return no results
  result <- query_cran_by_tags(
    tags = c("xyznonexistenttag123456789"), 
    use_defaults = FALSE
  )
  
  expect_type(result, "list")
  expect_equal(length(result), 0)
})
