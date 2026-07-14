# main.R

# Source the search_handling.R module
source("scripts/make_tag_pattern.R")

# Example usage:
tags <- c("bacteria", "microbiome", "antibiotic")
pattern <- make_tag_pattern(tags)
print(pattern)
# Output: "bacteria|microbiome|antibiotic"