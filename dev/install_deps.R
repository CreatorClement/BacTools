#!/usr/bin/env Rscript
# Install required packages
packages <- c('devtools', 'dplyr', 'purrr', 'httr', 'jsonlite', 'base64enc', 'readr', 'tibble', 'rcrossref', 'testthat')
install.packages(packages, dependencies=TRUE, quiet=TRUE)

# Install BiocPkgTools from Bioconductor
if (!require('BiocManager', quietly=TRUE)) {
  install.packages('BiocManager', quiet=TRUE)
}
if (!require('BiocPkgTools', quietly=TRUE)) {
  BiocManager::install('BiocPkgTools', quiet=TRUE)
}

cat("All packages installed successfully!\n")
