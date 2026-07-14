# This file is part of the standard testthat testing infrastructure
# It automatically runs all tests in tests/testthat/ when R CMD check is run

library(testthat)
library(BacTools)

test_check("BacTools")
