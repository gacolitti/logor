#' Get cryptocurrency logo URL from coin info
#' @noRd
get_logo_url <- function(coin_data, symbol) {
  if (is.null(coin_data) || is.null(coin_data$CoinInfo$ImageUrl)) {
    warning("No image URL found for symbol: ", symbol)
    return(NULL)
  }
  paste0("https://www.cryptocompare.com", coin_data$CoinInfo$ImageUrl)
}

#' Find coin data for a symbol
#' @noRd
find_coin_data <- function(coins_data, symbol) {
  # Safely check if symbol exists in coins_data
  tryCatch(
    {
      # Create a logical vector indicating which coin matches the symbol
      matches <- vapply(coins_data, function(coin) {
        # Check if the coin has the expected structure
        if (is.null(coin) || !is.list(coin) || is.null(coin$CoinInfo) || is.null(coin$CoinInfo$Name)) {
          return(FALSE)
        }
        toupper(coin$CoinInfo$Name) == symbol
      }, logical(1))

      # Find matching index
      coin_index <- which(matches)

      if (length(coin_index) == 0) {
        warning("Symbol not found in CryptoCompare API: ", symbol, call. = FALSE)
        return(NULL)
      }
      coins_data[[coin_index[1]]]
    },
    error = function(e) {
      warning("Error finding cryptocurrency symbol: ", symbol, " (Error: ", e$message, ")", call. = FALSE)
      return(NULL)
    }
  )
}

#' Fetch cryptocurrency logos from CryptoCompare API
#'
#' @param symbols Character vector of cryptocurrency symbols (e.g., "BTC", "ETH")
#' @param output Character string specifying the output type. One of "png" (default),
#'        "url", "request", "response", or "raw".
#' @param path Character string specifying the path where to save the PNG file(s).
#'        Required when output = "png". For multiple symbols, "_SYMBOL.png" will be
#'        appended to the path.
#' @return Named list where each element depends on the output type:
#'         - "url": URL string
#'         - "request": httr2 request object
#'         - "response": httr2 response object
#'         - "raw": raw vector
#'         - "png": TRUE if successful
#' @export
#' @examples
#' \dontrun{
#' # Get URLs
#' get_crypto_logos(c("BTC", "ETH"), output = "url")
#'
#' # Download PNGs
#' get_crypto_logos(c("BTC", "ETH"), output = "png", path = "logos/crypto")
#' }
get_crypto_logos <- function(symbols, output = c("png", "url", "request", "response", "raw"), file_paths = NULL) {
  output <- match.arg(output)
  if (length(symbols) == 0) {
    stop("No symbols provided")
  }
  symbols <- toupper(symbols) # Convert to uppercase for consistency

  if (!is.null(file_paths) && length(symbols) != length(file_paths)) {
    stop("Number of symbols must match number of file paths")
  }

  # Handle file paths for png output
  if (output == "png") {
    file_paths <- handle_png_paths(symbols, file_paths)
  }

  # Get crypto info from CryptoCompare API
  req <- httr2::request("https://min-api.cryptocompare.com/data/coin/generalinfo") |>
    httr2::req_url_query("fsyms" = symbols, "tsym" = "USD", .multi = "comma")

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp)

  # Extract coins data or return empty result if no data
  if (is.null(data$Data)) {
    warning("No data returned from CryptoCompare API")
    return(setNames(vector("list", length(symbols)), symbols))
  }

  # Create result list with symbol names
  result <- setNames(vector("list", length(symbols)), symbols)

  # Process each symbol
  for (symbol in symbols) {
    # Find coin data and get logo URL
    coin_data <- find_coin_data(data$Data, symbol)
    if (!is.null(coin_data)) {
      logo_url <- get_logo_url(coin_data, symbol)
      if (!is.null(logo_url)) {
        result[[symbol]] <- process_output(logo_url, symbol, output, file_paths)
      }
    }
  }

  result
}
