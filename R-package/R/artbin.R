#' Sample size and power for binary outcome trials
#'
#' @param pr Numeric vector of anticipated event probabilities (length >= 2,
#'   all strictly in (0,1)).
#' @param margin Non-inferiority or substantial-superiority margin (default
#'   NULL = 0 = superiority).
#' @param alpha Two-sided significance level (default 0.05).
#' @param aratios Numeric vector of allocation ratios (default NULL = equal).
#'   For 2 arms a single value r means 1:r.
#' @param favourable Logical; force outcome to be classed as favourable.
#' @param unfavourable Logical; force outcome to be classed as unfavourable.
#' @param condit Logical; use conditional test (Peto's approximation). Only
#'   for k-group superiority. Default FALSE.
#' @param local_alt Logical; use local alternative. Default FALSE (distant).
#' @param doses Numeric vector of dose scores for trend test. Default NULL.
#' @param n Given total sample size; if > 0 power is calculated. Default 0.
#' @param ngroups Number of groups (ignored if mismatched with length(pr)).
#' @param onesided Logical; one-sided test. Default FALSE.
#' @param power Desired power (default 0.8). Cannot specify with n > 0.
#' @param trend Logical; trend test for k-group designs. Default FALSE.
#' @param nvmethod Null variance method: 1 = sample estimate,
#'   2 = fixed marginal totals, 3 = constrained ML. Default NULL (-> 3,
#'   or 1 if wald = TRUE).
#' @param ap2 Group 2 probability under alternative hypothesis. Default 0
#'   (uses pr[2]).
#' @param ccorrect Logical; continuity correction. Default FALSE.
#' @param wald Logical; use Wald test. Default FALSE.
#' @param force Logical; override outcome direction check. Default FALSE.
#' @param noround Logical; suppress rounding of sample size. Default FALSE.
#' @param ltfu Loss-to-follow-up fraction in [0,1). Default NULL.
#' @param convcrit Convergence criterion for iterative algorithm. Default 1e-7.
#'
#' @return A named list containing:
#'   \item{n}{Total sample size}
#'   \item{n1, n2, ...}{Per-group sample sizes}
#'   \item{power}{Power}
#'   \item{D}{Total expected events}
#'   \item{D1, D2, ...}{Per-group expected events}
#'   \item{alpha}{Alpha (as supplied)}
#' @export
artbin <- function(pr, margin = NULL, alpha = 0.05,
                   aratios = NULL, favourable = FALSE, unfavourable = FALSE,
                   condit = FALSE, local_alt = FALSE, doses = NULL,
                   n = 0L, ngroups = NULL, onesided = FALSE,
                   power = NULL, trend = FALSE, nvmethod = NULL,
                   ap2 = 0, ccorrect = FALSE, wald = FALSE,
                   force = FALSE, noround = FALSE, ltfu = NULL,
                   convcrit = 1e-7) {

  # ---------- Input validation ----------
  if (!is.numeric(pr) || length(pr) < 2)
    stop("pr must be a numeric vector of length >= 2")
  if (any(pr <= 0) || any(pr >= 1))
    stop("Event probabilities out of range: all pr must be in (0,1)")
  if (alpha <= 0 || alpha >= 1)
    stop("alpha() out of range")

  npr <- length(pr)

  # n and power conflict
  if (n > 0 && !is.null(power))
    stop("You can't specify both n() and power()")
  if (n == 0 && is.null(power)) power <- 0.8
  if (!is.null(power) && (power <= 0 || power >= 1))
    stop("power() out of range")
  if (n < 0)
    stop("Sample size n() out of range")

  # ap2 range check
  if (ap2 < 0 || ap2 > 1)
    stop("Group 2 event probability under the alternative hypothesis must be >0 & <1")

  # ltfu range
  if (!is.null(ltfu) && (ltfu < 0 || ltfu >= 1))
    stop("ltfu() out of range: must be in [0,1)")

  # ngroups mismatch
  if (!is.null(ngroups) && ngroups != npr) {
    message("WARNING: Mismatch between the number of proportions and the number of groups specified - ngroups value will be ignored.")
  }
  ngroups <- npr

  # margin
  if (is.null(margin)) margin <- 0
  niss <- (margin != 0)

  if (!is.null(aratios) && length(aratios) > 1 && length(aratios) < npr && npr > 2)
    stop("Please specify the same number of aratios() as pr() for >2 groups")

  # margin only allowed for 2-group designs
  if (niss && npr > 2)
    stop("Can not have margin with >2 groups")

  # Equal event probabilities in 2-arm superiority
  if (npr == 2 && !niss && pr[1] == pr[2])
    stop("Event probabilities can not be equal with 2 groups")

  # Incompatible options
  if (local_alt && wald)
    stop("Local and Wald not allowed together")
  if (condit && wald)
    stop("Conditional and Wald not allowed together")
  if (niss && condit)
    stop("Can not select conditional option for non-inferiority/substantial-superiority trial")
  if (npr == 2 && trend)
    stop("Can not select trend option for a 2-arm trial")
  if (npr == 2 && !is.null(doses))
    stop("Can not select doses option for a 2-arm trial")
  if (ccorrect && ngroups > 2)
    stop("Correction for continuity not allowed in comparison of > 2 groups")
  if (onesided && ngroups > 2 && !trend && is.null(doses))
    stop("One-sided not allowed in comparison of > 2 groups unless trend/doses specified")

  # nvmethod validation
  if (!is.null(nvmethod) && wald && nvmethod != 1)
    stop("Need nvm(1) if Wald specified")
  if (wald && is.null(nvmethod)) nvmethod <- 1
  if (!is.null(nvmethod) && (nvmethod < 1 || nvmethod > 3)) nvmethod <- 3
  if (is.null(nvmethod)) nvmethod <- 3
  if (local_alt && nvmethod != 3)
    stop("Need nvm(3) if local specified")

  # condit + not local => force local with message
  if (condit && !local_alt) {
    message("NOTE: As conditional has been selected local will be used.")
    local_alt <- TRUE
  }

  # ltfu handling
  obsfrac <- if (!is.null(ltfu)) 1 - ltfu else 1

  # When n is given: set noround, handle ltfu
  ntotal <- n
  if (n > 0) {
    noround <- TRUE
    if (!is.null(ltfu)) {
      n <- round(ntotal * obsfrac)
    }
  }

  # Determine onesided as logical
  onesided <- isTRUE(onesided) || (is.numeric(onesided) && onesided > 0)

  # Build allocation ratios
  # allr: raw allocation ratios (length = npr)
  if (is.null(aratios)) {
    allr <- rep(1, npr)
  } else {
    allr <- as.numeric(aratios)
    if (length(allr) == 1 && npr == 2) {
      allr <- c(1, allr)
    } else if (length(allr) < npr) {
      # Extend last ratio (for k-group Stata-style)
      allr <- c(allr, rep(allr[length(allr)], npr - length(allr)))
    }
  }

  if (any(allr <= 0)) stop("Allocation ratio <=0 not allowed")

  # Re-scale so allr[1] == 1
  baseallr <- allr[1]
  allr     <- allr / baseallr
  totalallr <- sum(allr)

  # Normalized allocation ratios (sum to 1) for k-group
  AR_norm <- allr / totalallr

  # ar10 for 2-arm (= allr[2]/allr[1] after normalisation = allr[2])
  ar10 <- if (npr == 2) allr[2] else 1

  # ---------- Routing ----------
  # 2-arm path: goes to art2bin unless condit (which forces k-group local)
  use_art2bin <- (npr == 2 && !condit)

  # Within k-group, the niss==1 (NI/SS) sub-path also calls art2bin.
  # For condit+2arm, we use k-group (but condit with niss is blocked above).

  if (use_art2bin) {
    # ---- 2-arm via art2bin ----

    p1 <- pr[1]; p2 <- pr[2]
    mrg <- margin

    # Determine trial outcome direction
    threshold <- p1 + mrg
    if (p2 == threshold)
      stop("p2 can not equal p1 + margin")

    if (!favourable && !unfavourable) {
      trialoutcome <- if (p2 < threshold) "unfavourable" else "favourable"
      inferred <- TRUE
    } else {
      trialoutcome <- if (unfavourable) "unfavourable" else "favourable"
      inferred <- FALSE
    }

    # Sanity checks
    if (trialoutcome == "unfavourable" && threshold < p2) {
      if (!force) stop("artbin thinks your outcome is favourable. Check your command or use force=TRUE.")
    }
    if (trialoutcome == "favourable" && threshold > p2) {
      if (!force) stop("artbin thinks your outcome is unfavourable. Check your command or use force=TRUE.")
    }

    # onesided flag for art2bin
    os_flag <- onesided

    # ccorrect flag for art2bin
    cc_flag <- ccorrect

    if (n == 0) {
      # Sample size calculation
      res2 <- .art2bin(p0 = p1, p1 = p2, margin = mrg,
                       ar10 = ar10, alpha = alpha, power = power,
                       nvmethod = nvmethod, onesided = os_flag,
                       ccorrect = cc_flag, local_alt = local_alt,
                       wald = wald, noround = TRUE)
      n_unrounded <- res2$n
      Power_out   <- power
    } else {
      # Power calculation
      # Split n into n0/n1 based on allocation (floor as Stata does for n>0)
      n0_p <- floor(n / (1 + ar10))
      n1_p <- floor(n * ar10 / (1 + ar10))
      res2 <- .art2bin(p0 = p1, p1 = p2, margin = mrg,
                       n = n, n0_in = n0_p, n1_in = n1_p,
                       ar10 = ar10, alpha = alpha, power = 0.8,
                       nvmethod = nvmethod, onesided = os_flag,
                       ccorrect = cc_flag, local_alt = local_alt,
                       wald = wald, noround = TRUE)
      n_unrounded <- ntotal
      Power_out   <- res2$power
    }

  } else {
    # ---- k-group path ----

    if (niss) {
      # 2-arm NI/SS through k-group (only reached if condit - but blocked above)
      # This handles the undocumented case: 2-arm, nchi, niss
      p1 <- pr[1]
      p2 <- if (ap2 == 0) p1 else ap2
      ar21 <- ar10

      if (n == 0) {
        alpha_kg <- if (onesided) 2 * alpha else alpha
        res2 <- .art2bin(p0 = p1, p1 = p2, margin = margin,
                         ar10 = ar21, alpha = alpha_kg, power = power,
                         nvmethod = nvmethod, onesided = FALSE,
                         ccorrect = ccorrect, local_alt = local_alt,
                         wald = wald, noround = TRUE)
        n_unrounded <- res2$n
        Power_out   <- power
      } else {
        n0_p <- floor(n / (1 + ar21))
        n1_p <- floor(n * ar21 / (1 + ar21))
        alpha_kg <- if (onesided) 2 * alpha else alpha
        res2 <- .art2bin(p0 = p1, p1 = p2, margin = margin,
                         n0_in = n0_p, n1_in = n1_p,
                         ar10 = ar21, alpha = alpha_kg, power = 0.8,
                         nvmethod = nvmethod, onesided = FALSE,
                         ccorrect = ccorrect, local_alt = local_alt,
                         wald = wald, noround = TRUE)
        n_unrounded <- ntotal
        Power_out   <- res2$power
      }

    } else {
      # k-group superiority
      alpha_kg <- if (onesided) 2 * alpha else alpha

      if (n == 0) {
        resk <- .artbin_kgroup(pr = pr, alpha = alpha_kg, AR = AR_norm,
                               ngroups = ngroups, n = 0, power = power,
                               condit = condit, local_alt = local_alt,
                               trend = trend, wald = wald,
                               doses_vec = doses, convcrit = convcrit)
        n_unrounded <- resk$n
        Power_out   <- power
      } else {
        resk <- .artbin_kgroup(pr = pr, alpha = alpha_kg, AR = AR_norm,
                               ngroups = ngroups, n = n, power = 0.8,
                               condit = condit, local_alt = local_alt,
                               trend = trend, wald = wald,
                               doses_vec = doses, convcrit = convcrit)
        n_unrounded <- ntotal
        Power_out   <- resk$power
      }
    }
  }

  # ---------- Rounding and per-group allocation ----------
  # nbygroup = unrounded n per "unit" of allocation ratio
  nbygroup <- n_unrounded / totalallr

  ssize <- (n == 0 || ntotal == 0)  # TRUE = we calculated SS

  D_total <- 0
  result <- list()
  n_out_total <- 0

  for (a in seq_len(npr)) {
    if (ssize) {
      if (!noround) {
        na_out <- ceiling(nbygroup * allr[a] / obsfrac)
      } else {
        na_out <- nbygroup * allr[a] / obsfrac
      }
      n_out_total <- n_out_total + na_out
    } else {
      na_out <- ntotal * allr[a] / totalallr
      n_out_total <- ntotal
    }

    da_out <- na_out * pr[a] * obsfrac
    D_total <- D_total + da_out

    result[[paste0("n", a)]] <- na_out
    result[[paste0("D", a)]] <- da_out
  }

  result$n     <- n_out_total
  result$D     <- D_total
  result$power <- Power_out
  result$alpha <- alpha

  result
}
