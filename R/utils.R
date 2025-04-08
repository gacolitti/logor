#' Handle file paths for PNG output
#'
#' @param x Character vector of names
#' @param file_paths Character string specifying the path(s) where to save the PNG file(s)
#' @return Character vector of file paths
#' @keywords internal
handle_png_paths <- function(x, file_paths = NULL) {
  if (is.null(file_paths) && length(x) == 1) {
    file_paths <- "logo.png" # Will be appended with _SYMBOL.png
  } else if (is.null(file_paths) && length(x) > 1) {
    file_paths <- paste0("logo_", x, ".png")
  }
  # Create directories if they don't exist
  sapply(file_paths, function(x) dir.create(dirname(x), recursive = TRUE, showWarnings = FALSE))
  file_paths
}

#' Process output based on the requested type
#' @noRd
process_output <- function(url, nm, output, path = NULL) {
  if (output == "url") {
    return(url)
  }

  # Create request
  req <- httr2::request(url)

  if (output == "request") {
    return(req)
  }

  # Perform request and process based on output type
  tryCatch(
    {
      resp <- httr2::req_perform(req)

      if (output == "response") {
        return(resp)
      }

      # Get raw response
      raw_data <- httr2::resp_body_raw(resp)

      if (output == "raw") {
        return(raw_data)
      }

      if (output == "png" && !is.null(path)) {
        writeBin(raw_data, path)
        return(invisible(path))
      }
    },
    error = function(e) {
      warning("Failed to fetch logo for symbol: ", nm, " (Error: ", e$message, ")")
      return(NULL)
    }
  )
}
