#' Get logos from websites using Clearbit Logo API
#' @param websites Character vector of website URLs
#' @param output Character string specifying the output type. One of "url" (default),
#'        "request", "response", "raw", or "png".
#' @param file_paths Character string specifying the path(s) where to save PNG files.
#'        When output = "png" and file_paths is NULL (default), files are saved in the
#'        working directory as "logo_DOMAIN.png". For custom paths, "_DOMAIN.png" will
#'        be appended for each website.
#' @return Named list of results for each website
#' @examples
#' \dontrun{
#' # Get URLs
#' get_website_logos(c("apple.com", "microsoft.com"))
#'
#' # Download PNGs
#' get_website_logos(c("apple.com", "microsoft.com"), "png", file_paths = "logos/logo")
#' }
#' @export
get_website_logos <- function(websites, output = c("png", "url", "request", "response", "raw"), file_paths = NULL) {
  output <- match.arg(output)
  if (length(websites) == 0) {
    stop("No websites provided")
  }

  if (!is.null(file_paths) && length(websites) != length(file_paths)) {
    stop("Number of websites must match number of file paths")
  }

  # Handle file paths for png output
  if (output == "png") {
    file_paths <- handle_png_paths(websites, file_paths)
  }

  # Clean websites
  websites <- sub("^https?://", "", websites)
  websites <- sub("/$", "", websites)
  websites <- sub("^www\\.", "", websites)

  # Create URLs
  urls <- paste0("https://logo.clearbit.com/https://", websites)

  # Process each website
  results <- if (is.null(file_paths)) {
    Map(function(url, website) {
      process_output(url = url, nm = website, output = output, path = NULL)
    }, urls, websites)
  } else {
    Map(function(url, website, file_path) {
      process_output(url = url, nm = website, output = output, path = file_path)
    }, urls, websites, file_paths)
  }

  stats::setNames(results, websites)
}
