
<!-- README.md is generated from README.Rmd. Please edit that file -->

# logor <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/logor)](https://CRAN.R-project.org/package=logor)
[![R-CMD-check](https://github.com/gacolitti/logor/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gacolitti/logor/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/gacolitti/logor/graph/badge.svg)](https://app.codecov.io/gh/gacolitti/logor)
<!-- badges: end -->

The goal of logor is to provide a simple interface for fetching company
and cryptocurrency brand images/logos. It leverages multiple APIs
including CoinDesk and CryptoCompare for cryptocurrency data, and
extracts company logos directly from their websites.

## Installation

You can install the development version of logor from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("gacolitti/logor")
```

## Usage

### Company Logos

``` r
library(logor)

img_path <- "man/figures/MSFT.png"

# Fetch and save a public company logo 
logor::get_company_logos("MSFT", file_paths = img_path)
#> Using existing authentication file.
#> $MSFT
#> [1] "man/figures/MSFT.png"

knitr::include_graphics(img_path)
```

<img src="man/figures/MSFT.png" width="100px" />

### Website Logos

``` r
img_path <- "man/figures/twitter.png"

# Fetch and save a website logo by URL
logor::get_website_logos("https://www.twitter.com", file_paths = img_path)
#> $twitter.com
#> [1] "man/figures/twitter.png"

knitr::include_graphics(img_path)
```

<img src="man/figures/twitter.png" width="100px" />

### Cryptocurrency Logos

``` r
img_path <- "man/figures/BTC.png"

# Fetch and save a cryptocurrency logo by symbol
logor::get_crypto_logos("BTC", file_paths = img_path)
#> $BTC
#> [1] "man/figures/BTC.png"

knitr::include_graphics(img_path)
```

<img src="man/figures/BTC.png" width="100px" />
