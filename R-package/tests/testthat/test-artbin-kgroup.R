library(testthat)
library(artbin)

test_that("3-group local score", {
  r <- artbin(pr = c(0.1, 0.2, 0.3), local_alt = TRUE)
  expect_equal(r$n, 234)
  expect_equal(r$n1, 78); expect_equal(r$n2, 78); expect_equal(r$n3, 78)
})

test_that("3-group distant score", {
  r <- artbin(pr = c(0.1, 0.2, 0.3))
  expect_equal(r$n, 231)
  expect_equal(r$n1, 77); expect_equal(r$n2, 77); expect_equal(r$n3, 77)
})

test_that("4-group alpha=0.1 power=0.9", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  expect_equal(r$n, 176)
})

test_that("onesided trend gives same as doubled alpha", {
  r1 <- artbin(pr = c(0.1, 0.2, 0.3), trend = TRUE, alpha = 0.05, onesided = TRUE)
  r2 <- artbin(pr = c(0.1, 0.2, 0.3), trend = TRUE, alpha = 0.1)
  expect_equal(r1$n, r2$n)
})

test_that("3-group power back-calculation", {
  r_ss <- artbin(pr = c(0.1, 0.2, 0.3))
  r_pw <- artbin(pr = c(0.1, 0.2, 0.3), n = r_ss$n)
  expect_equal(round(r_pw$power, 1), 0.8)
})

test_that("3-group conditional local", {
  r <- artbin(pr = c(0.1, 0.3, 0.4), condit = TRUE)
  expect_true(r$n > 0)
})

test_that("3-group trend test", {
  r <- artbin(pr = c(0.1, 0.2, 0.3), trend = TRUE)
  # Trend test gives smaller SS than omnibus (from test_every_option.do)
  r_omni <- artbin(pr = c(0.1, 0.2, 0.3))
  expect_true(r$n < r_omni$n)
})

test_that("3-group unequal allocation", {
  r <- artbin(pr = c(0.1, 0.2, 0.3), aratios = c(3, 2, 1))
  expect_true(r$n > 0)
  expect_true(r$n1 > r$n3)  # more in first group
})

test_that("k-group D = n * pibar (noround)", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), noround = TRUE)
  pibar <- mean(c(0.2, 0.3, 0.4))
  expect_true(abs(r$D - r$n * pibar) < 1e-9)
})
