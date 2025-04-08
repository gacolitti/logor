# logor

An R package to fetch company and cryptocurrency brand logos.

## Installation

You can install the development version of logor from GitHub with:

```r
# install.packages("remotes")
remotes::install_github("gacolitti/logor")
```

## Usage

```r
library(logor)

# Get a company logo URL
company_logo <- get_company_logo("AAPL")

# Get a cryptocurrency logo URL
crypto_logo <- get_crypto_logo("BTC")
```

## Features

- Fetch company logos using company website information
- Fetch cryptocurrency logos from CryptoCompare
- Simple and easy-to-use interface

## License

MIT
