test_that("default_bacterial_tags returns a character vector", {
  tags <- default_bacterial_tags

  expect_type(tags, "character")
  expect_true(length(tags) > 0)
})

test_that("default_bacterial_tags contains expected biology terms", {
  tags <- default_bacterial_tags

  # Based on the actual default_tags.R file
  expect_true("bacteria" %in% tags)
  expect_true("microbiome" %in% tags)
  expect_true("antibiotic-resistance" %in% tags)
  expect_equal(length(tags), 10)
})

test_that("default_bacterial_tags returns unique values", {
  tags <- default_bacterial_tags

  expect_equal(length(tags), length(unique(tags)))
})
