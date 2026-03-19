# .artbin_kgroup() - k-group sample size/power calculation
# pr        : vector of event probabilities (length = ngroups)
# alpha     : significance level (already doubled for onesided by caller)
# AR        : normalized allocation ratios (sum = 1, length = ngroups)
# ngroups   : number of groups
# n         : total sample size for power calc (0 = calculate SS)
# power     : desired power (for SS calc)
# condit    : use conditional (Peto) test
# local_alt : use local alternative
# trend     : use trend test
# wald      : use Wald test
# doses_vec : custom dose scores (NULL = default 0,1,...,K)
# convcrit  : convergence criterion for bisection

.artbin_kgroup <- function(pr, alpha, AR, ngroups, n = 0, power = 0.8,
                           condit = FALSE, local_alt = FALSE,
                           trend = FALSE, wald = FALSE,
                           doses_vec = NULL, convcrit = 1e-7) {

  K    <- ngroups - 1
  PI   <- pr
  pibar <- sum(PI * AR)
  s_val <- pibar * (1 - pibar)
  S_var <- PI * (1 - PI)
  sbar  <- sum(S_var * AR)

  ss   <- (n == 0)
  if (ss) beta <- 1 - power

  do_trend <- trend || !is.null(doses_vec)

  if (do_trend) {
    # Linear trend test
    if (is.null(doses_vec)) doses_vec <- seq_len(ngroups) - 1
    dose_mean <- sum(doses_vec * AR)
    DOSE <- doses_vec - dose_mean

    if (!condit) {
      # Unconditional trend
      MU    <- PI - pibar
      tr_val <- sum(MU * DOSE * AR)
      q0_tr  <- sum(DOSE^2 * AR) * s_val

      if (local_alt) {
        q1_tr <- q0_tr
      } else {
        q1_tr <- sum(DOSE^2 * S_var * AR)
      }

      if (wald) {
        a_base <- sqrt(q1_tr) * qnorm(1 - alpha / 2)
      } else {
        a_base <- sqrt(q0_tr) * qnorm(1 - alpha / 2)
      }

      if (ss) {
        a_total <- a_base + sqrt(q1_tr) * qnorm(power)
        n_est   <- (a_total / tr_val)^2
        D_val   <- n_est * pibar
        list(n = n_est, power = power, D = D_val)
      } else {
        a_calc <- abs(tr_val) * sqrt(n) - a_base
        beta   <- 1 - pnorm(a_calc / sqrt(q1_tr))
        D_val  <- n * pibar
        list(n = n, power = 1 - beta, D = D_val)
      }

    } else {
      # Conditional trend (Peto)
      v_val <- pibar * (1 - pibar)
      LOR   <- log(PI / (1 - PI)) - log(PI[1] / (1 - PI[1]))
      LOR[1] <- 0
      LOR   <- LOR - sum(LOR * AR)

      q0_tr  <- sum(DOSE^2 * AR)
      tr_val <- sum(DOSE * LOR * AR)
      a_z    <- qnorm(1 - alpha / 2)

      if (ss) {
        a_calc <- sqrt(q0_tr) * (a_z + qnorm(power))
        l_val  <- (a_calc / tr_val)^2
        d_val  <- l_val
        l_val  <- sqrt(l_val * (l_val - 4 * v_val))
        d_val  <- (d_val + l_val) / (2 * (1 - pibar))
        n_est  <- d_val / pibar
        D_val  <- d_val
        list(n = n_est, power = power, D = D_val)
      } else {
        d_val  <- n * pibar
        l_val  <- d_val * (n - d_val) / (n - 1)
        a_calc <- abs(tr_val) * sqrt(l_val / q0_tr) - a_z
        beta   <- 1 - pnorm(a_calc)
        D_val  <- d_val
        list(n = n, power = 1 - beta, D = D_val)
      }
    }

  } else if (!condit) {
    # Unconditional, no trend
    MU <- PI - pibar
    a_crit <- qchisq(1 - alpha, K)

    if (wald) {
      # Wald test: K x K variance-covariance matrix of contrasts vs group 1
      VA <- matrix(0, K, K)
      for (k in seq_len(K)) {
        for (l in seq_len(K)) {
          kk <- k + 1L; ll <- l + 1L
          VA[k, l] <- S_var[kk] * ((k == l) / AR[kk] - 1) - S_var[ll] + sbar
        }
      }
      MU_sub <- matrix(MU[-1], ncol = 1)
      q0_val <- as.numeric(t(MU_sub) %*% solve(VA) %*% MU_sub)
    } else {
      q0_val <- sum(MU^2 * AR) / s_val
    }

    if (local_alt || wald) {
      # Direct formula
      if (ss) {
        n_est <- .npnchi2(K, a_crit, beta) / q0_val
        D_val <- n_est * pibar
        list(n = n_est, power = power, D = D_val)
      } else {
        beta  <- pchisq(a_crit, K, ncp = n * q0_val)
        D_val <- n * pibar
        list(n = n, power = 1 - beta, D = D_val)
      }

    } else {
      # Distant score: iterative bisection using _pe2
      a0_val <- (sum(S_var) - sbar) / s_val
      q1_val <- sum(MU^2 * S_var * AR) / s_val^2
      W_var  <- 1 - 2 * AR
      a1_val <- (sum(S_var^2 * W_var) + sbar^2) / s_val^2

      if (ss) {
        n_curr  <- .npnchi2(K, a_crit, beta) / q0_val
        b0_curr <- .pe2(a0_val, q0_val, a1_val, q1_val, K, n_curr, a_crit)

        if (abs(b0_curr - beta) > convcrit) {
          if (b0_curr < beta) {
            nu_v <- n_curr; nl_v <- n_curr / 2
          } else {
            nl_v <- n_curr; nu_v <- 2 * n_curr
          }
          repeat {
            n_curr  <- (nl_v + nu_v) / 2
            b0_curr <- .pe2(a0_val, q0_val, a1_val, q1_val, K, n_curr, a_crit)
            if (abs(b0_curr - beta) <= convcrit) break
            if (b0_curr < beta) nu_v <- n_curr else nl_v <- n_curr
            if ((nu_v - nl_v) <= convcrit) break
          }
        }
        n_est <- n_curr
        D_val <- n_est * pibar
        list(n = n_est, power = power, D = D_val)

      } else {
        beta  <- .pe2(a0_val, q0_val, a1_val, q1_val, K, n, a_crit)
        D_val <- n * pibar
        list(n = n, power = 1 - beta, D = D_val)
      }
    }

  } else {
    # Conditional (Peto's approximation to log-odds ratio)
    v_val <- pibar * (1 - pibar)
    LOR   <- log(PI / (1 - PI)) - log(PI[1] / (1 - PI[1]))
    LOR[1] <- 0
    LOR   <- LOR - sum(LOR * AR)

    q0_val <- sum(LOR^2 * AR)
    a_crit <- qchisq(1 - alpha, K)

    if (ss) {
      l_val <- .npnchi2(K, a_crit, beta)
      d_val <- l_val
      l_val <- sqrt(l_val * (l_val - 4 * q0_val * v_val))
      d_val <- (d_val + l_val) / (2 * q0_val * (1 - pibar))
      n_est <- d_val / pibar
      D_val <- d_val
      list(n = n_est, power = power, D = D_val)
    } else {
      d_val <- n * pibar
      l_val <- d_val * (n - d_val) * q0_val / (n - 1)
      beta  <- pchisq(a_crit, K, ncp = l_val)
      D_val <- d_val
      list(n = n, power = 1 - beta, D = D_val)
    }
  }
}
