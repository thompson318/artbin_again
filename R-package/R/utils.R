# .npnchi2(df, x, p)
# Returns ncp such that pchisq(x, df, ncp) = p
# Translates Stata's npnchi2(df, x, p)
.npnchi2 <- function(df, x, p) {
  f <- function(ncp) pchisq(x, df, ncp = ncp) - p
  upper <- max(x, 1) * 2
  while (f(upper) > 0) upper <- upper * 2
  uniroot(f, interval = c(0, upper), tol = 1e-12)$root
}

# .pe2(a0, q0, a1, q1, k, n, a_crit)
# Compute beta (type II error) for k-group distant score test
# Translates Stata's _pe2 subroutine
.pe2 <- function(a0, q0, a1, q1, k, n, a_crit) {
  b0v <- a0 + n * q0
  b1v <- a1 + 2 * n * q1
  lv  <- b0v^2 - k * b1v
  fv  <- sqrt(lv * (lv + k * b1v))
  lv  <- (lv + fv) / b1v
  fv  <- a_crit * (k + lv) / b0v
  pchisq(fv, k, ncp = lv)
}

# .cc(n, adiff, ratio, deflate)
# Continuity correction for 2-arm trials
# Translates Stata's _cc subroutine
.cc <- function(n, adiff, ratio = 1, deflate = FALSE) {
  a_val <- (ratio + 1) / (adiff * ratio)
  if (deflate) {
    ((2 * n - a_val)^2) / (4 * n)
  } else {
    cf <- ((1 + sqrt(1 + 2 * a_val / n))^2) / 4
    n * cf
  }
}
