test_that("get_website_logos validates input parameters", {
  # Test NULL input
  expect_error(get_website_logos(NULL))

  # Test invalid output parameter
  expect_error(get_website_logos("example.com", output = "invalid"))

  # Test empty websites vector
  expect_error(get_website_logos(character(0)))
})

test_that("get_website_logos cleans website URLs correctly", {
  skip_if_offline()
  skip_on_cran()

  websites <- c(
    "http://example.com",
    "https://example.com",
    "www.example.com",
    "example.com/",
    "example.com"
  )

  result <- get_website_logos(websites, output = "url")
  expect_type(result, "list")
  expect_length(result, 5)

  # All results should be named 'example.com'
  expect_equal(names(result), rep("example.com", 5))

  # All URLs should be properly formatted
  expect_true(all(grepl("^https://logo\\.clearbit\\.com/https://example\\.com$", unlist(result))))
})

test_that("get_website_logos returns correct output types", {
  skip_if_offline()

  # Test URL output
  result <- get_website_logos("apple.com", output = "url")
  expect_type(result, "list")
  expect_named(result, "apple.com")
  expect_match(result$apple.com, "^https?://", all = FALSE)

  # Test request output
  result <- get_website_logos("apple.com", output = "request")
  expect_type(result, "list")
  expect_named(result, "apple.com")
  expect_s3_class(result$apple.com, "httr2_request")

  # Test response output
  result <- get_website_logos("apple.com", output = "response")
  expect_type(result, "list")
  expect_named(result, "apple.com")
  expect_s3_class(result$apple.com, "httr2_response")

  # Test raw output
  result <- get_website_logos("apple.com", output = "raw")
  expect_type(result, "list")
  expect_named(result, "apple.com")
  expect_type(result$apple.com, "raw")
})

test_that("get_website_logos handles multiple websites", {
  skip_if_offline()

  websites <- c("apple.com", "microsoft.com")
  result <- get_website_logos(websites, output = "url")

  expect_type(result, "list")
  expect_named(result, websites)
  expect_length(result, 2)

  # Check that valid URLs are returned
  expect_match(result$apple.com, "^https?://", all = FALSE)
  expect_match(result$microsoft.com, "^https?://", all = FALSE)
})

test_that("get_website_logos can save PNG files", {
  skip_if_offline()

  # Create temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))

  # Test PNG output
  result <- get_website_logos("apple.com", output = "png", file_paths = file.path(temp_dir, "logo.png"))
  expect_type(result, "list")
  expect_named(result, "apple.com")
  expect_equal(result$apple.com, file.path(temp_dir, "logo.png"))
  expect_true(file.exists(file.path(temp_dir, "logo.png")))
})
