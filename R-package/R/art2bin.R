# .art2bin() - Internal 2-arm sample size/power calculation
# p0, p1 : event probabilities (control, intervention)
# margin  : NI margin (default 0 = superiority)
# n       : total sample size (0 = calculate SS)
# n0_in, n1_in : per-group sizes when computing power
# ar10    : n1/n0 allocation ratio (default 1)
# alpha   : significance level (already one-sided if onesided=TRUE)
# power   : desired power
# nvmethod: 1=sample est, 2=fixed marginal, 3=constrained ML
# onesided: use one-sided alpha
# ccorrect: continuity correction
# local_alt: local alternative
# wald    : Wald test
# noround : suppress rounding (default TRUE - artbin handles rounding)

.art2bin <- function(p0, p1, margin = 0, n = 0, n0_in = 0, n1_in = 0,
                     ar10 = 1, alpha = 0.05, power = 0.8,
                     nvmethod = 3, onesided = FALSE, ccorrect = FALSE,
                     local_alt = FALSE, wald = FALSE, noround = TRUE) {

  mrg <- margin

  # Determine null variance estimates
  if (nvmethod == 1) {
    p0null <- p0
    p1null <- p1
  } else if (nvmethod == 2) {
    p0null <- (p0 + ar10 * p1 - ar10 * mrg) / (1 + ar10)
    p1null <- (p0 + ar10 * p1 + mrg) / (1 + ar10)
    if (!all(c(p0null, p1null) > 0 & c(p0null, p1null) < 1)) {
      stop("Event probabilities and/or margin are incompatible with fixed marginal totals method")
    }
  } else {
    # nvmethod == 3: constrained maximum likelihood (cubic equation)
    a_c <- 1 + ar10
    b_c <- mrg * (ar10 + 2) - 1 - ar10 - p0 - ar10 * p1
    c_c <- (mrg - 1 - ar10 - 2 * p0) * mrg + p0 + ar10 * p1
    d_c <- p0 * mrg * (1 - mrg)
    v_c <- (b_c / (3 * a_c))^3 - (b_c * c_c) / (6 * a_c^2) + d_c / (2 * a_c)
    u_c <- sign(v_c) * sqrt((b_c / (3 * a_c))^2 - c_c / (3 * a_c))
    toosmall <- 1e-12
    cos_arg <- if (abs(v_c) <= toosmall && abs(u_c^3) <= toosmall) 0 else v_c / u_c^3
    cos_arg <- max(-1, min(1, cos_arg))
    w_c <- (pi + acos(cos_arg)) / 3
    p0null <- 2 * u_c * cos(w_c) - b_c / (3 * a_c)
    p1null <- p0null + mrg
    if (!all(c(p0null, p1null) > 0 & c(p0null, p1null) < 1)) {
      stop("Constrained ML failed: please contact the artbin authors")
    }
  }

  D_val <- abs(p1 - p0 - mrg)

  if (onesided) {
    za <- qnorm(1 - alpha)
  } else {
    za <- qnorm(1 - alpha / 2)
  }
  zb <- qnorm(power)

  snull <- sqrt(p0null * (1 - p0null) + p1null * (1 - p1null) / ar10)
  salt  <- sqrt(p0 * (1 - p0) + p1 * (1 - p1) / ar10)

  ss <- (n == 0 && n0_in == 0 && n1_in == 0)

  if (ss) {
    if (local_alt) {
      m <- ((za * snull + zb * snull) / D_val)^2
    } else if (wald) {
      m <- ((za * salt + zb * salt) / D_val)^2
    } else {
      m <- ((za * snull + zb * salt) / D_val)^2
    }

    if (ccorrect) {
      m <- .cc(m, D_val, ar10, deflate = FALSE)
    }

    if (!noround) {
      n0_out <- ceiling(m)
      n1_out <- ceiling(ar10 * m)
    } else {
      n0_out <- m
      n1_out <- ar10 * m
    }
    n_out <- n0_out + n1_out
    Dart  <- n0_out * p0 + n1_out * p1

    list(n = n_out, n0 = n0_out, n1 = n1_out,
         power = power, alpha = alpha, Dart = Dart)

  } else {
    # Power calculation: need n0_in
    if (n > 0 && n0_in == 0) {
      n0_in <- n / (1 + ar10)
      n1_in <- n - n0_in
    }

    if (ccorrect) {
      n0_in <- .cc(n0_in, D_val, ar10, deflate = TRUE)
    }

    if (local_alt) {
      Power_out <- pnorm((D_val * sqrt(n0_in) - za * snull) / snull)
    } else if (wald) {
      Power_out <- pnorm((D_val * sqrt(n0_in) - za * salt) / salt)
    } else {
      Power_out <- pnorm((D_val * sqrt(n0_in) - za * snull) / salt)
    }

    Dart <- n0_in * p0 + n1_in * p1

    list(power = Power_out, alpha = alpha, Dart = Dart)
  }
}
