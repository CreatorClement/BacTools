test_that("make_tag_pattern returns correct pattern format", {
  # Test basic functionality
  tags <- c("bacteria", "microbiome")
  pattern <- make_tag_pattern(tags)
  
  expect_type(pattern, "character")
  expect_true(grepl("bacteria", pattern))
  expect_true(grepl("microbiome", pattern))
})

test_that("make_tag_pattern handles single tag", {
  pattern <- make_tag_pattern("bacteria")
  
  expect_type(pattern, "character")
  expect_true(nchar(pattern) > 0)
})

test_that("make_tag_pattern handles empty input", {
  expect_error(make_tag_pattern(character(0)), NA)
  # Or expect_error() if it should fail on empty input
})

test_that("make_tag_pattern handles special characters", {
  tags <- c("16S-rRNA", "gene+expression")
  pattern <- make_tag_pattern(tags)
  
  expect_type(pattern, "character")
})
