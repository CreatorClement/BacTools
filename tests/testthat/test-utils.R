test_that("make_tag_pattern creates correct regex pattern", {
  # Test basic functionality
  tags <- c("bacteria", "microbe")
  result <- make_tag_pattern(tags)
  expect_equal(result, "bacteria|microbe")
  
  # Test with single tag
  single_tag <- "genomics"
  result_single <- make_tag_pattern(single_tag)
  expect_equal(result_single, "genomics")
  
  # Test with multiple tags
  many_tags <- c("tag1", "tag2", "tag3", "tag4")
  result_many <- make_tag_pattern(many_tags)
  expect_equal(result_many, "tag1|tag2|tag3|tag4")
})

test_that("classify_tool correctly categorizes tools", {
  # Test visualization tools
  expect_equal(classify_tool("iTOL viewer"), "Visualization Tools")
  expect_equal(classify_tool("Cytoscape plugin"), "Visualization Tools")
  expect_equal(classify_tool("Visual analysis"), "Visualization Tools")
  
  # Test sequence analysis
  expect_equal(classify_tool("FastQC quality control"), "Sequence Analysis")
  expect_equal(classify_tool("BWA aligner"), "Sequence Analysis")
  expect_equal(classify_tool("BLAST search"), "Sequence Analysis")
  expect_equal(classify_tool("Bowtie2"), "Sequence Analysis")
  
  # Test phylogenetic tools
  expect_equal(classify_tool("RAxML phylogenetic tree"), "Phylogenetic and evolutionary analysis")
  expect_equal(classify_tool("BEAST evolution"), "Phylogenetic and evolutionary analysis")
  
  # Test comparative genomics
  expect_equal(classify_tool("Mauve alignment"), "Comparative genomics")
  expect_equal(classify_tool("MUMmer comparison"), "Comparative genomics")
  
  # Test metagenomics
  expect_equal(classify_tool("QIIME2 pipeline"), "Metagenomics and community analysis")
  expect_equal(classify_tool("MetaPhlAn profiling"), "Metagenomics and community analysis")
  expect_equal(classify_tool("Microbiome analysis"), "Metagenomics and community analysis")
  
  # Test default category
  expect_equal(classify_tool("Random tool"), "Specialized analysis")
  expect_equal(classify_tool("Unknown package"), "Specialized analysis")
})

test_that("classify_tool handles edge cases", {
  # Test case insensitivity
  expect_equal(classify_tool("FASTQC"), "Sequence Analysis")
  expect_equal(classify_tool("fastqc"), "Sequence Analysis")
  expect_equal(classify_tool("FastQC"), "Sequence Analysis")
  
  # Test empty string
  expect_equal(classify_tool(""), "Specialized analysis")
  
  # Test partial matches
  expect_equal(classify_tool("phylogenetic tree builder"), "Phylogenetic and evolutionary analysis")
})

test_that("tool_list_to_df converts list to data frame", {
  # Create sample tool list
  tool_list <- list(
    list(
      name = "tool1",
      author = "Author 1",
      summary = "Summary 1",
      source = "CRAN"
    ),
    list(
      name = "tool2",
      author = "Author 2",
      summary = "Summary 2",
      source = "GitHub"
    )
  )
  
  # Test conversion
  result <- tool_list_to_df(tool_list)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true("name" %in% names(result))
  expect_true("author" %in% names(result))
  expect_equal(result$name, c("tool1", "tool2"))
})

test_that("tool_list_to_df handles NULL values", {
  # Create tool list with NULL values
  tool_list <- list(
    list(
      name = "tool1",
      author = NULL,
      summary = "Summary 1",
      source = "CRAN"
    )
  )
  
  result <- tool_list_to_df(tool_list)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  # NULL should be converted to empty string
  expect_equal(result$author, "")
})
