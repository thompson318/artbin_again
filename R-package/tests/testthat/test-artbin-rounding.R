library(testthat)
library(artbin)

check_rounding <- function(...) {
  r_nr <- artbin(..., noround = TRUE)
  r_rd <- artbin(...)
  narms <- sum(grepl("^n[0-9]+$", names(r_rd)))

  for (i in seq_len(narms)) {
    ni_nr <- r_nr[[paste0("n", i)]]
    ni_rd <- r_rd[[paste0("n", i)]]
    # Rounded n[i] == ceiling of unrounded
    expect_equal(ni_rd, ceiling(ni_nr))
    # D[i]/n[i] ratio preserved
    expect_true(abs(r_rd[[paste0("D", i)]] / ni_rd -
                    r_nr[[paste0("D", i)]] / ni_nr) < 1e-9)
  }
  if (narms == 2) {
    expect_equal(r_rd$D, r_rd$D1 + r_rd$D2)
    expect_equal(r_rd$n, r_rd$n1 + r_rd$n2)
  } else if (narms == 3) {
    expect_equal(r_rd$D, r_rd$D1 + r_rd$D2 + r_rd$D3)
    expect_equal(r_rd$n, r_rd$n1 + r_rd$n2 + r_rd$n3)
  }
}

test_that("rounding: 2-arm NI aratio(1,2)", {
  check_rounding(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2))
})

test_that("rounding: 2-arm sup aratio(1,2)", {
  check_rounding(pr = c(0.02, 0.04), aratios = c(1, 2))
})

test_that("rounding: 2-arm sup aratio(10,17)", {
  check_rounding(pr = c(0.2, 0.3), aratios = c(10, 17))
})

test_that("rounding: 3-arm aratio(3,2,1)", {
  check_rounding(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1), convcrit = 1e-8)
})

test_that("rounding: 3-arm trend", {
  check_rounding(pr = c(0.02, 0.04, 0.06), trend = TRUE, convcrit = 1e-8)
})
