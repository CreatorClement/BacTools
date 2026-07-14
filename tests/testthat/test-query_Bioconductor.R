test_that("query_bioc_by_tags returns expected structure", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("BiocPkgTools")
  
  # This is an integration test - it requires internet connection
  # Test with a specific tag that should return results
  result <- query_bioc_by_tags(tags = c("phylogenetic"), use_defaults = FALSE)
  
  expect_type(result, "list")
  
  if (length(result) > 0) {
    # Check structure of first result
    first_tool <- result[[1]]
    
    expect_true("name" %in% names(first_tool))
    expect_true("summary" %in% names(first_tool))
    expect_true("source" %in% names(first_tool))
    expect_true("language" %in% names(first_tool))
    expect_true("doi" %in% names(first_tool))
    expect_equal(first_tool$source, "Bioconductor")
    expect_equal(first_tool$language, "R")
    
    # Check DOI format
    expect_match(first_tool$doi, "^10\\.18129/B9\\.bioc\\.")
  }
})

test_that("query_bioc_by_tags handles no results gracefully", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("BiocPkgTools")
  
  # Use a tag that should return no results
  result <- query_bioc_by_tags(
    tags = c("xyznonexistenttag123456789"), 
    use_defaults = FALSE
  )
  
  expect_type(result, "list")
  expect_equal(length(result), 0)
})

test_that("query_bioc_by_tags uses build_tag_vector correctly", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("BiocPkgTools")
  
  # Test that it accepts additional tags
  result <- query_bioc_by_tags(
    tags = c("sequence"),
    additional_tags = c("alignment"),
    use_defaults = FALSE
  )
  
  expect_type(result, "list")
})

test_that("query_bioc_by_tags creates proper citations", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("BiocPkgTools")
  
  result <- query_bioc_by_tags(tags = c("phylogenetic"), use_defaults = FALSE)
  
  if (length(result) > 0) {
    first_tool <- result[[1]]
    
    # Check citation structure
    expect_type(first_tool$apa_citation, "character")
    expect_true(nchar(first_tool$apa_citation) > 0)

    # Citation should contain the DOI
    expect_true(grepl(first_tool$doi, first_tool$apa_citation, fixed = TRUE))

    # Citation should contain package name
    expect_true(grepl(first_tool$name, first_tool$apa_citation, fixed = TRUE))
  }
})
