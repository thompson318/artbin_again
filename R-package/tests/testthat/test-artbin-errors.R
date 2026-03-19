library(testthat)
library(artbin)

test_that("error: pr too few elements", {
  expect_error(artbin(pr = c(0.1)), regexp = "length >= 2")
})

test_that("error: pr out of range high", {
  expect_error(artbin(pr = c(1.1, 0.5)), regexp = "out of range")
})

test_that("error: pr out of range zero", {
  expect_error(artbin(pr = c(0, 0.5)), regexp = "out of range")
})

test_that("error: equal probabilities 2-arm superiority", {
  expect_error(artbin(pr = c(0.1, 0.1)), regexp = "equal")
})

test_that("error: alpha out of range", {
  expect_error(artbin(pr = c(0.1, 0.2), alpha = 0), regexp = "alpha")
  expect_error(artbin(pr = c(0.1, 0.2), alpha = 1), regexp = "alpha")
})

test_that("error: power out of range", {
  expect_error(artbin(pr = c(0.1, 0.2), margin = 0.1, power = 0), regexp = "power")
  expect_error(artbin(pr = c(0.1, 0.2), margin = 0.1, power = 1), regexp = "power")
})

test_that("error: n negative", {
  expect_error(artbin(pr = c(0.05, 0.1), margin = 0.1, n = -500), regexp = "range")
})

test_that("error: margin with >2 groups", {
  expect_error(artbin(pr = c(0.05, 0.1, 0.2), margin = 0.1), regexp = "margin")
})

test_that("error: trend for 2-arm", {
  expect_error(artbin(pr = c(0.1, 0.3), trend = TRUE), regexp = "trend")
})

test_that("error: ccorrect for >2 groups", {
  expect_error(artbin(pr = c(0.05, 0.1, 0.2), ccorrect = TRUE), regexp = "continuity")
})

test_that("error: onesided for >2 groups (no trend)", {
  expect_error(artbin(pr = c(0.05, 0.1, 0.2), onesided = TRUE), regexp = "[Oo]ne-sided")
})

test_that("error: local and wald", {
  expect_error(artbin(pr = c(0.1, 0.2), local_alt = TRUE, wald = TRUE), regexp = "[Ll]ocal")
})

test_that("error: wald and nvm!=1", {
  expect_error(artbin(pr = c(0.1, 0.2), wald = TRUE, nvmethod = 3), regexp = "nvm")
})

test_that("error: n and power both specified", {
  expect_error(artbin(pr = c(0.1, 0.2), n = 100, power = 0.8), regexp = "both")
})

test_that("ngroups mismatch gives warning not error", {
  expect_message(artbin(pr = c(0.1, 0.2, 0.3), ngroups = 2), regexp = "[Mm]ismatch")
})

test_that("error: ltfu >= 1", {
  expect_error(artbin(pr = c(0.1, 0.2), ltfu = 1), regexp = "ltfu")
})

test_that("error: ap2 out of range", {
  expect_error(artbin(pr = c(0.2, 0.2), margin = 0.1, ap2 = 1.5), regexp = "Group 2")
})
