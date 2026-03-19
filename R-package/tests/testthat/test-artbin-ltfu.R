library(testthat)
library(artbin)

test_that("ltfu: SS inflated relative to no-ltfu", {
  r0 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE)
  r1 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, ltfu = 0.1)
  expect_true(abs(r1$n - r0$n / 0.9) < 1e-6)
})

test_that("ltfu: events unchanged", {
  r0 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE)
  r1 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, ltfu = 0.1)
  expect_true(abs(r1$D - r0$D) < 1e-6)
})

test_that("ltfu: power consistent with n->power", {
  r_pow <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, n = 1000, ltfu = 0.1)
  r_ss  <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, n = 900)
  expect_true(abs(r_pow$power - r_ss$power) < 1e-6)
})

test_that("STREAM trial n=398", {
  r <- artbin(pr = c(0.7, 0.75), margin = -0.1, power = 0.8,
              aratios = c(1, 2), wald = TRUE, ltfu = 0.2)
  expect_equal(r$n, 398)
})
