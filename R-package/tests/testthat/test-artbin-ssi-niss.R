library(testthat)
library(artbin)

# Run all ssi/niss Stata commands in a single session and return a named list
# of expected values. Returns NULL if Stata is unavailable.
.stata_ssi_niss_expected <- local({
  stata_path <- "/home/thompson/bin/stata/stata-mp"
  niss_adopath <- "/home/thompson/software/artbin/testing"

  if (!requireNamespace("RStata", quietly = TRUE) || !file.exists(stata_path)) {
    NULL
  } else {
    options(RStata.StataPath = stata_path, RStata.StataVersion = 19)
    tmpfile <- tempfile(fileext = ".txt")
    on.exit(unlink(tmpfile))

    stata_code <- sprintf("
adopath ++ \"%s\"

ssi .05 .05, alpha(.05) power(.9) non
local ssi1 = r(ss)
ssi 0.2 0.1, alpha(.05) power(.8) non
local ssi2 = r(ss)
ssi 0.3 0.1, alpha(.025) power(.7) non
local ssi3 = r(ss)
ssi 0.5 0.3, alpha(.025) power(.9) non
local ssi4 = r(ss)
ssi 0.6 0.05, alpha(.05) power(.8) non
local ssi5 = r(ss)
ssi 0.8 0.1, alpha(.025) power(.7) non
local ssi6 = r(ss)

niss 0.7 0.9 0.2, alpha(0.025) power(0.9) aratio(1)
local niss1 = r(N_obs)
niss 0.75 0.85 0.1, alpha(0.025) power(0.9) aratio(1)
local niss2 = r(N_obs)
niss 0.8 0.7 0.15, alpha(0.05) power(0.9) aratio(1)
local niss3 = r(N_obs)
niss 0.85 0.8 0.1, alpha(0.025) power(0.9) aratio(1)
local niss4 = r(N_obs)
niss 0.9 0.9 0.05, alpha(0.05) power(0.9) aratio(1)
local niss5 = r(N_obs)
niss 0.7 0.75 0.15, alpha(0.025) power(0.9) aratio(1)
local niss6 = r(N_obs)

niss 0.7 0.9 0.2, alpha(0.025) power(0.9) aratio(2)
local niss7 = r(N_obs)
niss 0.75 0.85 0.1, alpha(0.025) power(0.9) aratio(3)
local niss8 = r(N_obs)
niss 0.8 0.7 0.15, alpha(0.05) power(0.9) aratio(4)
local niss9 = r(N_obs)
niss 0.85 0.8 0.1, alpha(0.025) power(0.9) aratio(2)
local niss10 = r(N_obs)
niss 0.9 0.9 0.05, alpha(0.05) power(0.9) aratio(4)
local niss11 = r(N_obs)
niss 0.7 0.75 0.15, alpha(0.025) power(0.9) aratio(3)
local niss12 = r(N_obs)

file open f using \"%s\", write replace
file write f \"`ssi1' `ssi2' `ssi3' `ssi4' `ssi5' `ssi6'\" _n
file write f \"`niss1' `niss2' `niss3' `niss4' `niss5' `niss6'\" _n
file write f \"`niss7' `niss8' `niss9' `niss10' `niss11' `niss12'\" _n
file close f
", niss_adopath, tmpfile)

    suppressMessages(RStata::stata(stata_code))

    lines <- readLines(tmpfile)
    vals <- lapply(lines, function(l) as.integer(strsplit(trimws(l), "\\s+")[[1]]))
    list(
      ssi   = setNames(vals[[1]], paste0("ssi",   1:6)),
      niss1 = setNames(vals[[2]], paste0("niss",  1:6)),
      niss2 = setNames(vals[[3]], paste0("niss",  7:12))
    )
  }
})

skip_no_stata <- function() {
  if (is.null(.stata_ssi_niss_expected)) skip("Stata not available")
}

# ---------------------------------------------------------------------------
# SSI comparisons
# ssi alpha is one-sided; artbin alpha is two-sided
# ssi takes (failure_prob, ni_margin); artbin pr = c(failure_prob, failure_prob)
# ---------------------------------------------------------------------------

test_that("SSI - p=0.95, d=0.05, alpha=0.05 one-sided, power=0.9", {
  skip_no_stata()
  r <- artbin(pr = c(0.05, 0.05), margin = 0.05, alpha = 0.1, power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi1"]])
})

test_that("SSI - p=0.8, d=0.1, alpha=0.05 one-sided, power=0.8", {
  skip_no_stata()
  r <- artbin(pr = c(0.2, 0.2), margin = 0.1, alpha = 0.1, power = 0.8, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi2"]])
})

test_that("SSI - p=0.7, d=0.1, alpha=0.025 one-sided, power=0.7", {
  skip_no_stata()
  r <- artbin(pr = c(0.3, 0.3), margin = 0.1, alpha = 0.05, power = 0.7, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi3"]])
})

test_that("SSI - p=0.5, d=0.3, alpha=0.025 one-sided, power=0.9", {
  skip_no_stata()
  r <- artbin(pr = c(0.5, 0.5), margin = 0.3, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi4"]])
})

test_that("SSI - p=0.4, d=0.05, alpha=0.05 one-sided, power=0.8", {
  skip_no_stata()
  r <- artbin(pr = c(0.6, 0.6), margin = 0.05, alpha = 0.1, power = 0.8, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi5"]])
})

test_that("SSI - p=0.2, d=0.1, alpha=0.025 one-sided, power=0.7", {
  skip_no_stata()
  r <- artbin(pr = c(0.8, 0.8), margin = 0.1, alpha = 0.05, power = 0.7, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$ssi[["ssi6"]])
})

# ---------------------------------------------------------------------------
# NISS comparisons (equal allocation)
# niss takes (success_prob_0, success_prob_1, ni_margin)
# artbin pr = c(1 - success_0, 1 - success_1)
# ---------------------------------------------------------------------------

test_that("NISS - p0=0.7, p1=0.9, d=0.2, alpha=0.025 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.3, 0.1), margin = 0.2, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss1"]])
})

test_that("NISS - p0=0.75, p1=0.85, d=0.1, alpha=0.025 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.25, 0.15), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss2"]])
})

test_that("NISS - p0=0.8, p1=0.7, d=0.15, alpha=0.05 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.2, 0.3), margin = 0.15, alpha = 0.05, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss3"]])
})

test_that("NISS - p0=0.85, p1=0.8, d=0.1, alpha=0.025 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.15, 0.2), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss4"]])
})

test_that("NISS - p0=0.9, p1=0.9, d=0.05, alpha=0.05 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.1, 0.1), margin = 0.05, alpha = 0.05, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss5"]])
})

test_that("NISS - p0=0.7, p1=0.75, d=0.15, alpha=0.025 one-sided, power=0.9, aratio=1:1", {
  skip_no_stata()
  r <- artbin(pr = c(0.3, 0.25), margin = 0.15, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss1[["niss6"]])
})

# ---------------------------------------------------------------------------
# NISS comparisons (unequal allocation)
# ---------------------------------------------------------------------------

test_that("NISS - p0=0.7, p1=0.9, d=0.2, alpha=0.025 one-sided, power=0.9, aratio=1:2", {
  skip_no_stata()
  r <- artbin(pr = c(0.3, 0.1), margin = 0.2, alpha = 0.025, onesided = TRUE,
              power = 0.9, aratios = c(1, 2), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss7"]])
})

test_that("NISS - p0=0.75, p1=0.85, d=0.1, alpha=0.025 one-sided, power=0.9, aratio=1:3", {
  skip_no_stata()
  r <- artbin(pr = c(0.25, 0.15), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, aratios = c(1, 3), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss8"]])
})

test_that("NISS - p0=0.8, p1=0.7, d=0.15, alpha=0.05 one-sided, power=0.9, aratio=1:4", {
  skip_no_stata()
  r <- artbin(pr = c(0.2, 0.3), margin = 0.15, alpha = 0.05, onesided = TRUE,
              power = 0.9, aratios = c(1, 4), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss9"]])
})

test_that("NISS - p0=0.85, p1=0.8, d=0.1, alpha=0.025 one-sided, power=0.9, aratio=1:2", {
  skip_no_stata()
  r <- artbin(pr = c(0.15, 0.2), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, aratios = c(1, 2), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss10"]])
})

test_that("NISS - p0=0.9, p1=0.9, d=0.05, alpha=0.05 one-sided, power=0.9, aratio=1:4", {
  skip_no_stata()
  r <- artbin(pr = c(0.1, 0.1), margin = 0.05, alpha = 0.05, onesided = TRUE,
              power = 0.9, aratios = c(1, 4), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss11"]])
})

test_that("NISS - p0=0.7, p1=0.75, d=0.15, alpha=0.025 one-sided, power=0.9, aratio=1:3", {
  skip_no_stata()
  r <- artbin(pr = c(0.3, 0.25), margin = 0.15, alpha = 0.025, onesided = TRUE,
              power = 0.9, aratios = c(1, 3), wald = TRUE)
  expect_equal(r$n, .stata_ssi_niss_expected$niss2[["niss12"]])
})
