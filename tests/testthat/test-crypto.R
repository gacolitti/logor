test_that("get_crypto_logos validates input parameters", {
  # Test invalid output parameter
  expect_error(get_crypto_logos("BTC", output = "invalid"))

  # Test missing path with png output
  expect_error(get_crypto_logos("BTC", output = "png", path = NULL))
})

test_that("get_crypto_logos handles empty or invalid symbols", {
  # Test empty symbols vector
  expect_error(get_crypto_logos(character(0)))

  # Test invalid symbol
  expect_warning(result <- get_crypto_logos("INVALID"))
  expect_type(result, "list")
  expect_named(result, "INVALID")
  expect_null(result$INVALID)
})

test_that("get_logo_url handles invalid input", {
  expect_warning(result <- get_logo_url(NULL, "BTC"))
  expect_null(result)

  expect_warning(result <- get_logo_url(list(), "BTC"))
  expect_null(result)
})

test_that("find_coin_data handles invalid input", {
  # Test with NULL input
  expect_warning(result <- find_coin_data(NULL, "BTC"))
  expect_null(result)

  # Test with empty list
  expect_warning(result <- find_coin_data(list(), "BTC"))
  expect_null(result)

  # Test with malformed coin data
  bad_data <- list(list(wrong_field = "value"))
  expect_warning(result <- find_coin_data(bad_data, "BTC"))
  expect_null(result)
})

test_that("get_crypto_logos returns correct output types", {
  skip_if_offline()

  # Test URL output
  result <- get_crypto_logos("BTC", output = "url")
  expect_type(result, "list")
  expect_named(result, "BTC")
  expect_match(result$BTC, "^https?://", all = FALSE)

  # Test request output
  result <- get_crypto_logos("BTC", output = "request")
  expect_type(result, "list")
  expect_named(result, "BTC")
  expect_s3_class(result$BTC, "httr2_request")

  # Test response output
  result <- get_crypto_logos("BTC", output = "response")
  expect_type(result, "list")
  expect_named(result, "BTC")
  expect_s3_class(result$BTC, "httr2_response")

  # Test raw output
  result <- get_crypto_logos("BTC", output = "raw")
  expect_type(result, "list")
  expect_named(result, "BTC")
  expect_type(result$BTC, "raw")
})

test_that("get_crypto_logos handles multiple symbols", {
  skip_if_offline()

  symbols <- c("BTC", "ETH")
  result <- get_crypto_logos(symbols, output = "url")

  expect_type(result, "list")
  expect_named(result, symbols)
  expect_length(result, 2)

  # Check that valid URLs are returned
  expect_match(result$BTC, "^https?://", all = FALSE)
  expect_match(result$ETH, "^https?://", all = FALSE)
})

test_that("get_crypto_logos can save PNG files", {
  skip_if_offline()

  # Create temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))

  # Test PNG output
  result <- get_crypto_logos("BTC", output = "png", file_paths = file.path(temp_dir, "logo_BTC.png"))
  expect_type(result, "list")
  expect_named(result, "BTC")
  expect_equal(result$BTC, file.path(temp_dir, "logo_BTC.png"))
  expect_true(file.exists(file.path(temp_dir, "logo_BTC.png")))
})
