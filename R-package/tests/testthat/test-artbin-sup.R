library(testthat)
library(artbin)

test_that("Superiority - Pocock 1983 SS (Wald)", {
  r <- artbin(pr = c(0.05, 0.1), alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 578)
})

test_that("Superiority - Sealed envelope SS (Wald)", {
  r <- artbin(pr = c(0.1, 0.2), alpha = 0.1, power = 0.8, wald = TRUE)
  expect_equal(r$n / 2, 155)
})

test_that("Superiority - Pocock 1983 power (Wald)", {
  r <- artbin(pr = c(0.05, 0.1), alpha = 0.05, n = 1156, wald = TRUE)
  expect_equal(round(r$power, 1), 0.9)
})

test_that("Superiority - Sealed envelope power (Wald)", {
  r <- artbin(pr = c(0.1, 0.2), alpha = 0.1, n = 310, wald = TRUE)
  expect_equal(round(r$power, 1), 0.8)
})

test_that("Superiority SS = power back-calculation", {
  r_ss <- artbin(pr = c(0.05, 0.1), alpha = 0.05, power = 0.9, wald = TRUE)
  r_pw <- artbin(pr = c(0.05, 0.1), alpha = 0.05, n = r_ss$n, wald = TRUE)
  expect_equal(round(r_pw$power, 1), 0.9)
})
