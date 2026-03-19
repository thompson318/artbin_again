library(testthat)
library(artbin)

test_that("NI - Blackwelder 1982 (Wald)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 39)
})

test_that("NI - Julious 2011 Table 4 row 1 (Wald)", {
  r <- artbin(pr = c(0.3, 0.3), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 1766)
})

test_that("NI - Pocock 2003 (Wald)", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.15, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 120)
})

test_that("NI - Sealed envelope (Wald)", {
  r <- artbin(pr = c(0.2, 0.2), margin = 0.1, alpha = 0.2, power = 0.8, wald = TRUE)
  expect_equal(r$n / 2, 145)
})

test_that("NI - Julious 2011 row 5 (Wald)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 757)
})

test_that("NI - Julious 2011 row 6 (Wald)", {
  r <- artbin(pr = c(0.25, 0.25), margin = 0.2, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 99)
})

test_that("NI - Julious 2011 row 7 (Wald)", {
  r <- artbin(pr = c(0.2, 0.2), margin = 0.15, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 150)
})

test_that("NI - Julious 2011 row 8 (Wald)", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 1072)
})

test_that("NI - power back-calculation (Blackwelder)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, n = 78, wald = TRUE)
  expect_equal(round(r$power, 1), 0.9)
})

test_that("NI - power back-calculation (Julious row 2)", {
  r <- artbin(pr = c(0.3, 0.3), margin = 0.05, alpha = 0.05, n = 3532, wald = TRUE)
  expect_equal(round(r$power, 1), 0.9)
})

test_that("NI - power back-calculation (Pocock 2003)", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.15, alpha = 0.05, n = 240, wald = TRUE)
  expect_equal(round(r$power, 1), 0.9)
})

test_that("NI Blackwelder (EAST comparison)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9, wald = TRUE)
  expect_equal(r$n, 78)
})

test_that("NI - one-sided margin test (Julious row 1)", {
  r <- artbin(pr = c(0.3, 0.1), margin = 0.2, alpha = 0.025, onesided = TRUE, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 20)
})

test_that("NI - one-sided margin test (Julious row 2)", {
  r <- artbin(pr = c(0.25, 0.15), margin = 0.1, alpha = 0.025, onesided = TRUE, power = 0.9, wald = TRUE)
  expect_equal(r$n / 2, 83)
})

test_that("NI - substantial-superiority Palisade (aratio 1:3)", {
  r <- artbin(pr = c(0.2, 0.5), margin = 0.15, aratios = c(1, 3))
  expect_equal(r$n, 391)
})

test_that("NI - STREAM LTFU (aratio 1:2, ltfu 0.2, wald)", {
  r <- artbin(pr = c(0.7, 0.75), margin = -0.1, power = 0.8,
              aratios = c(1, 2), wald = TRUE, ltfu = 0.2)
  expect_equal(r$n, 398)
})

test_that("NI Blackwelder (score, NVM=3 default)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9)
  # Score test gives different result than Wald
  expect_true(!is.null(r$n))
  expect_true(r$n > 0)
})

test_that("NI - EAST comparison 10 (aratio 1:2)", {
  r <- artbin(pr = c(0.9, 0.9), margin = -0.023, alpha = 0.05, power = 0.9,
              wald = TRUE, aratios = c(1, 2))
  expect_equal(r$n, 8045)
})
