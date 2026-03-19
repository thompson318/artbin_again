library(testthat)
library(artbin)

test_that("ccorrect - Pocock p=(0.05,0.1) alpha=5% power=90%", {
  r <- artbin(pr = c(0.05, 0.1), margin = 0, alpha = 0.05, power = 0.9, ccorrect = TRUE)
  expect_equal(r$n / 2, 621)
})

test_that("ccorrect - p=(0.03,0.07) alpha=5% power=95%", {
  r <- artbin(pr = c(0.03, 0.07), margin = 0, alpha = 0.05, power = 0.95, ccorrect = TRUE)
  expect_equal(r$n / 2, 818)
})

test_that("ccorrect - p=(0.1,0.2) alpha=5% power=85%", {
  r <- artbin(pr = c(0.1, 0.2), margin = 0, alpha = 0.05, power = 0.85, ccorrect = TRUE)
  expect_equal(r$n / 2, 247)
})

test_that("ccorrect - p=(0.1,0.01) alpha=2.5% power=80%", {
  r <- artbin(pr = c(0.1, 0.01), margin = 0, alpha = 0.025, power = 0.8, ccorrect = TRUE)
  expect_equal(r$n / 2, 143)
})

test_that("ccorrect - p=(0.15,0.2) alpha=10% power=90%", {
  r <- artbin(pr = c(0.15, 0.2), margin = 0, alpha = 0.1, power = 0.90, ccorrect = TRUE)
  expect_equal(r$n / 2, 1027)
})

test_that("ccorrect - p=(0.3,0.1) alpha=5% power=90%", {
  r <- artbin(pr = c(0.3, 0.1), margin = 0, alpha = 0.05, power = 0.90, ccorrect = TRUE)
  expect_equal(r$n / 2, 92)
})
