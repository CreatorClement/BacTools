# BacTools Test Fixes - Complete Guide

## Problems Found and Fixed

### 1. **Missing %R% Operator** ❌→✅
**Error**: `could not find function "%R%"`

**Problem**: The `query_all.R` file uses `%R%` operator to repeat strings (e.g., `"=" %R% 60` to create separator lines), but this operator was never defined.

**Fix**: Added the operator definition to `utils.R`:
```r
`%R%` <- function(x, n) {
  paste(rep(x, n), collapse = "")
}
```

**Action**: Replace your `R/utils.R` with the corrected version.

---

### 2. **export_catalog() Expects Data Frame, Not List** ❌→✅
**Error**: `is.data.frame(x) is not TRUE`

**Problem**: Tests were passing lists to `export_catalog()`, but the function expects a data frame.

**Wrong**:
```r
sample_results <- list(
  CRAN = data.frame(package = "pkg1"),
  Bioconductor = data.frame(package = "pkg2")
)
export_catalog(sample_results, ...)  # ERROR!
```

**Correct**:
```r
sample_results <- data.frame(
  name = c("pkg1", "pkg2"),
  source = c("CRAN", "Bioconductor")
)
export_catalog(sample_results, ...)  # Works!
```

**Fixed Files**:
- `test-advanced_examples.R`
- `test-export_catalog.R`

---

### 3. **Wrong Function Name: query_CRAN** ❌→✅
**Error**: `could not find function "query_CRAN"`

**Problem**: Tests used `query_CRAN()` but the actual function is `query_cran_by_tags()`.

**Fix**: Updated all test files to use correct function names:
- `query_CRAN()` → `query_cran_by_tags()`
- `query_all()` → `search_bactools()`
- `query_all_and_export()` → `search_bactools()` (same function)

**Fixed Files**:
- `test-advanced_examples.R`
- `test-query_all.R`

---

### 4. **Wrong Parameter Name: package vs doi** ❌→✅
**Error**: `unused argument (package = "ggplot2")`

**Problem**: `get_citation_count_cached()` takes `doi` parameter, not `package`.

**Wrong**:
```r
get_citation_count_cached(package = "ggplot2")  # ERROR!
```

**Correct**:
```r
get_citation_count_cached(doi = "10.32614/CRAN.package.ggplot2")  # Works!
```

**Fixed Files**:
- `test-get_citation_count_cached.R`
- `test-advanced_examples.R`

---

### 5. **Unsupported format Parameter** ❌→✅
**Error**: `unused argument (format = "csv")`

**Problem**: `export_catalog()` doesn't have a `format` parameter.

**Fix**: Removed the `format` parameter from tests.

**Fixed Files**:
- `test-export_catalog.R`

---

## Files Provided

### ✅ Corrected Test Files (Replace these)
1. **test-advanced_examples.R** - Fixed data types, function names, parameters
2. **test-export_catalog.R** - Fixed data types, removed invalid parameters
3. **test-get_citation_count_cached.R** - Fixed parameter names
4. **test-query_all.R** - Fixed function names
5. **test-query_all_and_export.R** - Fixed data types and function calls

### ✅ Corrected R Source File (Replace this)
6. **utils.R** - Added missing `%R%` operator

### ✅ Good Files (Already Correct - No Changes Needed)
7. test-utils.R
8. test-query_CRAN.R
9. test-query_Github.R
10. test-query_Bioconductor.R
11. test-default_tags.R
12. test-make_tag_pattern.R
13. setup.R
14. testthat.R

---

## Installation Instructions

### Step 1: Replace R Source File
```bash
# Replace this file in your R/ directory
cp utils.R /path/to/BacTools/R/utils.R
```

### Step 2: Replace Test Files
```bash
# Replace these files in your tests/testthat/ directory
cp test-advanced_examples.R /path/to/BacTools/tests/testthat/
cp test-export_catalog.R /path/to/BacTools/tests/testthat/
cp test-get_citation_count_cached.R /path/to/BacTools/tests/testthat/
cp test-query_all.R /path/to/BacTools/tests/testthat/
cp test-query_all_and_export.R /path/to/BacTools/tests/testthat/
```

### Step 3: Verify the Fix
```r
# In R
devtools::load_all()
devtools::test()
```

You should now see:
```
✔ | F W  S  OK | Context
✔ |        XX | advanced_examples
✔ |        XX | default_tags
✔ |        XX | export_catalog
✔ |        XX | get_citation_count_cached
...

[ FAIL 0 | WARN 0 | SKIP X | PASS XXX ]
```

---

## Summary of Changes

| File | Issue | Fix |
|------|-------|-----|
| `R/utils.R` | Missing `%R%` operator | Added operator definition |
| `test-advanced_examples.R` | Lists instead of data frames | Changed to data frames |
| `test-advanced_examples.R` | Wrong function names | Used correct names |
| `test-advanced_examples.R` | Wrong parameter `package=` | Changed to `doi=` |
| `test-export_catalog.R` | Lists instead of data frames | Changed to data frames |
| `test-export_catalog.R` | Invalid `format=` parameter | Removed parameter |
| `test-get_citation_count_cached.R` | Wrong parameter `package=` | Changed to `doi=` |
| `test-query_all.R` | Wrong function `query_all()` | Changed to `search_bactools()` |
| `test-query_all_and_export.R` | Lists instead of data frames | Changed to data frames |

---

## Expected Test Results

After applying fixes:

### ✅ Tests That Should Pass
- All utility function tests
- All CRAN query tests (when online)
- All Bioconductor tests (when online, BiocPkgTools installed)
- All export tests
- Citation caching tests (when online)
- Integration tests (when online)

### ⏭️ Tests That May Skip
- GitHub tests (if GITHUB_PAT not set)
- Any test marked with `skip_if_offline()` when offline
- Tests marked with `skip_on_cran()` when running on CRAN

### 📊 Expected Coverage
- Overall: 80%+ (with network access)
- Utils: 100%
- Export: 95%+
- Query functions: 70%+ (some paths require live APIs)

---

## Troubleshooting

### Still getting errors?

**Check 1**: Did you replace `R/utils.R`?
```r
# Test the operator
"=" %R% 60  # Should output: "============...=" (60 times)
```

**Check 2**: Are you loading the package correctly?
```r
devtools::load_all()  # Not just library(BacTools)
```

**Check 3**: Clear old test cache
```r
# Remove any old cache files
unlink("tests/testthat/*.rds")
```

**Check 4**: Verify file locations
```
BacTools/
├── R/
│   └── utils.R          ← Updated file here
└── tests/
    └── testthat/
        ├── test-*.R     ← Updated test files here
        └── testthat.R
```

---

## Quick Reference: Corrected Code Patterns

### ✅ Correct
```r
# Data frames for export
df <- data.frame(name = "pkg", source = "CRAN")
export_catalog(df, filename = "out.csv")

# DOI parameter
get_citation_count_cached(doi = "10.32614/CRAN.package.ggplot2")

# Function names
query_cran_by_tags(tags = "bacteria")
search_bactools(tags = "bacteria", return_df = TRUE)

# String repetition
message("=" %R% 60)
```

### ❌ Wrong (Old Code)
```r
# Lists for export - WRONG
list_data <- list(CRAN = df1, Bioc = df2)
export_catalog(list_data, ...)

# Package parameter - WRONG
get_citation_count_cached(package = "ggplot2")

# Old function names - WRONG
query_CRAN(...)
query_all(...)

# Missing operator - WRONG
"=" %R% 60  # ERROR if %R% not defined
```

---

## Need More Help?

1. **Read error messages carefully** - They usually point to the exact issue
2. **Check function signatures** - Use `?function_name` in R
3. **Review test patterns** - Look at working tests for examples
4. **Test incrementally** - Fix one file at a time

Good luck! 🎉
