test_that("get_company_logos validates input parameters", {
  # Test invalid output parameter
  expect_error(get_company_logos("AAPL", output = "invalid"))

  # Test missing path with png output
  expect_error(get_company_logos("AAPL", output = "png", path = NULL))

  # Test empty symbols vector
  expect_error(get_company_logos(character(0)))
})

test_that("get_company_logos handles invalid symbols", {
  skip_if_offline()
  skip_on_cran()

  # Test invalid symbol
  expect_warning(result <- get_company_logos("INVALID"))
  expect_type(result, "list")
  expect_named(result, "INVALID")
  expect_null(result$INVALID)
})

test_that("get_company_logos handles tickers where get_info fails", {
  skip_if_offline()
  skip_on_cran()

  symbols <- c("AAPL", "SPAXX")
  result <- get_company_logos(symbols, output = "url")

  expect_named(result, symbols)
  # SPAXX should be handled gracefully, either as error string or NULL
  expect_true(is.character(result[["SPAXX"]]) || is.null(result[["SPAXX"]]))
  # AAPL should return a non-NULL, non-error result (likely a URL or list)
  expect_false(is.null(result[["AAPL"]]))
  expect_false(identical(result[["AAPL"]], "Error Fetching Info"))
})

test_that("get_company_logos returns correct output types", {
  skip_if_offline()
  skip_on_cran()

  # Test URL output
  result <- get_company_logos("AAPL", output = "url")
  expect_type(result, "list")
  expect_named(result, "AAPL")
  expect_match(result$AAPL, "^https?://", all = FALSE)

  # Test request output
  result <- get_company_logos("AAPL", output = "request")
  expect_type(result, "list")
  expect_named(result, "AAPL")
  expect_s3_class(result$AAPL, "httr2_request")

  # Test response output
  result <- get_company_logos("AAPL", output = "response")
  expect_type(result, "list")
  expect_named(result, "AAPL")
  expect_s3_class(result$AAPL, "httr2_response")

  # Test raw output
  # Test raw output
  result <- get_company_logos("AAPL", output = "raw")
  expect_type(result, "list")
  expect_named(result, "AAPL")
  expect_type(result$AAPL, "raw")
})

test_that("get_company_logos handles multiple symbols", {
  skip_if_offline()
  skip_on_cran()

  symbols <- c("AAPL", "MSFT")
  result <- get_company_logos(symbols, output = "url")

  expect_type(result, "list")
  expect_named(result, symbols)
  expect_length(result, 2)

  # Check that valid URLs are returned
  expect_match(result$AAPL, "^https?://", all = FALSE)
  expect_match(result$MSFT, "^https?://", all = FALSE)
})

test_that("get_company_logos can save PNG files", {
  skip_if_offline()
  skip_on_cran()

  # Create temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))

  # Test PNG output
  file_path <- file.path(temp_dir, "logo.png")
  result <- get_company_logos("AAPL", output = "png", file_paths = file_path)
  expect_type(result, "list")
  expect_named(result, "AAPL")
  expect_equal(result$AAPL, file_path)
  expect_true(file.exists(file_path))
})
