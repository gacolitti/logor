#' Fetch company logos from company websites
#'
#' @param symbols Character vector of company stock symbols
#' @param output Character string specifying the output type. One of "url" (default),
#'        "request", "response", "raw", or "png".
#' @param file_paths Character string specifying the path(s) where to save the PNG file(s).
#'        When output = "png" and file_paths is NULL (default), files are saved in the
#'        working directory as "logo_SYMBOL.png". For custom paths with multiple symbols,
#'        "_SYMBOL.png" will be appended to each path.
#' @return Named list where each element depends on the output type:
#'         - "url": URL string
#'         - "request": httr2 request object
#'         - "response": httr2 response object
#'         - "raw": raw vector
#'         - "png": Character vector of file paths if successful
#' @export
#' @examples
#' \dontrun{
#' # Get URLs
#' get_company_logos(c("AAPL", "MSFT"))
#'
#' # Download PNGs
#' get_company_logos(c("AAPL", "MSFT"), output = "png", file_paths = "logos/company")
#' }
get_company_logos <- function(symbols, output = c("png", "url", "request", "response", "raw"), file_paths = NULL) {
  output <- match.arg(output)

  if (length(symbols) == 0) {
    stop("No symbols provided")
  }

  if (!is.null(file_paths) && length(symbols) != length(file_paths)) {
    stop("Number of symbols must match number of file paths")
  }

  # Handle file paths for png output
  if (output == "png") {
    file_paths <- handle_png_paths(symbols, file_paths)
  }

  # Get ticker info using yfinancer
  tickers <- tryCatch(yfinancer::get_tickers(symbols), error = function(e) {
    return(list())
  })
  if (length(tickers) == 0) {
    warning("No symbols found")
    return(setNames(vector("list", length(symbols)), symbols))
  }

  # Get company info including website for all tickers
  info <- lapply(
    tickers,
    function(ticker) {
      tryCatch(
        yfinancer::get_info(ticker, modules = "summaryProfile"),
        error = function(e) NULL
      )
    }
  )
  info <- setNames(info, tickers$symbol)

  # Create result list with symbol names
  result <- setNames(vector("list", length(symbols)), symbols)

  # Get valid websites
  valid_idx <- seq_along(info)[!sapply(info, function(x) is.null(x$website))]
  if (length(valid_idx) > 0) {
    websites <- sapply(info[valid_idx], `[[`, "website")
    logos <- get_website_logos(websites, output = output, file_paths = file_paths[valid_idx])
    result[symbols[valid_idx]] <- logos
  }

  # Warn about missing websites
  invalid_symbols <- setdiff(symbols, symbols[valid_idx])
  if (length(invalid_symbols) > 0) {
    warning(
      call. = FALSE,
      "No company website information found for: ",
      paste(invalid_symbols, collapse = ", ")
    )
  }

  result
}
