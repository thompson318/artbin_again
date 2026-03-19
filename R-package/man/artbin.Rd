\name{artbin}
\alias{artbin}
\title{Sample Size and Power for Binary Outcome Trials}

\description{
  \code{artbin} is part of the ART suite (\emph{Assessment of Resources for
  Trials}).  It calculates the power or total sample size for various tests
  comparing \emph{K} anticipated event probabilities across groups.  Power is
  calculated when \code{n} is supplied; otherwise total sample size is
  estimated for the requested power.

  \code{artbin} supports the design of superiority, non-inferiority and
  substantial-superiority trials.  For two-arm trials it calls
  \code{art2bin} (translated from \code{art2bin.ado} v1.01); for multi-group
  trials it uses the k-group unconditional or conditional algorithm.

  Translated from the Stata \code{artbin} package v2.1.2 (Marley-Zagar
  \emph{et al.}, 2023).
}

\usage{
artbin(pr, margin = NULL, alpha = 0.05, aratios = NULL,
       favourable = FALSE, unfavourable = FALSE, condit = FALSE,
       local_alt = FALSE, doses = NULL, n = 0L, ngroups = NULL,
       onesided = FALSE, power = NULL, trend = FALSE, nvmethod = NULL,
       ap2 = 0, ccorrect = FALSE, wald = FALSE, force = FALSE,
       noround = FALSE, ltfu = NULL, convcrit = 1e-7)
}

\arguments{
  \item{pr}{Required.  Numeric vector of anticipated event probabilities
    (\eqn{\pi_1, \pi_2, \ldots, \pi_K}), all strictly in \eqn{(0,1)}, length
    at least 2.  \eqn{\pi_1} is the control group; \eqn{\pi_2, \pi_3, \ldots}
    are the treatment groups.}

  \item{margin}{Margin for a non-inferiority (NI) or substantial-superiority
    (SS) trial.  Default \code{NULL} (equivalently 0 = superiority).
    \itemize{
      \item For an \emph{unfavourable} outcome: null hypothesis is
        \eqn{\pi_2 - \pi_1 \ge m}; \eqn{m > 0} gives NI, \eqn{m < 0} gives SS.
      \item For a \emph{favourable} outcome the inequalities are reversed:
        \eqn{m < 0} gives NI, \eqn{m > 0} gives SS.
    }
    Must lie strictly between -1 and 1.  Only valid for two-arm trials.}

  \item{alpha}{Significance level (type I error probability).  Default 0.05.
    Used as two-sided unless \code{onesided = TRUE}.}

  \item{aratios}{Numeric vector of allocation ratios (weights).  Default
    \code{NULL} = equal allocation.  For two arms a single value \code{r}
    means ratio 1:\code{r}.  For example \code{aratios = c(1, 2)} allocates
    twice as many participants to group 2 as to group 1.}

  \item{favourable}{Logical; force the outcome to be classified as favourable.
    If omitted, \code{artbin} infers favourability from \code{pr} and
    \code{margin}: favourable if \eqn{\pi_2 > \pi_1 + m}.}

  \item{unfavourable}{Logical; force the outcome to be classified as
    unfavourable.}

  \item{condit}{Logical; use Peto's conditional test (hypergeometric
    distribution).  This test conditions on the total number of events and
    uses Peto's one-step approximation to the log odds ratio.  Only available
    for k-group superiority trials.  Implies \code{local_alt = TRUE}.
    Cannot be combined with \code{wald}.  Default \code{FALSE}.}

  \item{local_alt}{Logical; use the local alternative approximation, i.e.
    estimate the null variance using the null hypothesis proportions only.
    Valid when the treatment effect is small (odds ratios between about 0.5
    and 2).  The default (distant) uses the variance both under the null and
    the alternative.  Cannot be combined with \code{wald}.  Default
    \code{FALSE}.}

  \item{doses}{Numeric vector of dose scores for a linear trend test in
    multi-group trials.  Implies \code{trend = TRUE}.  If \code{trend = TRUE}
    and \code{doses} is omitted, default doses are \eqn{1, 2, \ldots, K}.
    Not permitted for two-arm trials.}

  \item{n}{Total sample size.  If \code{n > 0} the corresponding power is
    returned.  Cannot be specified together with \code{power}.  Default 0
    (compute sample size).}

  \item{ngroups}{Number of groups.  Ignored (with a message) if it does not
    match \code{length(pr)}.}

  \item{onesided}{Logical; treat \code{alpha} as a one-sided significance
    level.  For two-arm trials or trend tests.  Default \code{FALSE} (alpha
    is two-sided; internally halved to give a one-sided level).}

  \item{power}{Required power in \eqn{(0, 1)}.  Default 0.8.  Cannot be
    specified together with \code{n > 0}.}

  \item{trend}{Logical; use a linear trend test across groups (multi-group
    trials only).  Default \code{FALSE}.  See also \code{doses}.}

  \item{nvmethod}{Null variance method for the two-arm art2bin calculation:
    \itemize{
      \item 1 = sample estimate (Wald)
      \item 2 = fixed marginal totals
      \item 3 = constrained maximum likelihood (default score test)
    }
    Default \code{NULL}: set to 1 if \code{wald = TRUE}, otherwise 3.}

  \item{ap2}{Alternative hypothesis probability for group 2; used only for
    NI trials (Blackwelder-type).  Default 0 (uses \code{pr[2]}).}

  \item{ccorrect}{Logical; apply a continuity correction.  Not available for
    \code{condit} or multi-group trials.  Default \code{FALSE}.}

  \item{wald}{Logical; use the Wald test.  Cannot be combined with
    \code{condit} or \code{local_alt}.  Default \code{FALSE} (score test).}

  \item{force}{Logical; override the inferred favourable/unfavourable
    classification.  Useful for observational studies where the exposure is
    harmful.  Default \code{FALSE}.}

  \item{noround}{Logical; suppress rounding of per-group sample sizes up to
    the nearest integer.  Default \code{FALSE}.}

  \item{ltfu}{Loss-to-follow-up fraction in \eqn{[0, 1)}.  Total sample size
    is divided by \eqn{1 - \code{ltfu}} before rounding.  The expected events
    are unaffected (computed on the observable participants).  Default
    \code{NULL} (no loss to follow-up).}

  \item{convcrit}{Convergence criterion for the iterative k-group distant
    score bisection.  Default \code{1e-7}.}
}

\value{
  A named list with the following components:
  \describe{
    \item{\code{n}}{Total sample size (sum of all groups).}
    \item{\code{n1}, \code{n2}, ...}{Per-group sample sizes.}
    \item{\code{D}}{Total expected number of events.}
    \item{\code{D1}, \code{D2}, ...}{Per-group expected events.}
    \item{\code{power}}{Achieved power.}
    \item{\code{alpha}}{Alpha as supplied.}
  }
  The same quantities are returned whether \code{artbin} computed sample size
  from power or power from sample size.
}

\details{
  \subsection{Methods}{
    \code{artbin} computes sample size/power for the unconditional chi-squared
    test (Pearson) or the conditional test based on the hypergeometric
    distribution with Peto's one-step approximation to the odds ratio.

    For two-arm trials, the calculation uses the Farrington-Manning score
    statistic (default, \code{nvmethod = 3}) or the Wald statistic
    (\code{wald = TRUE}).  Sample size/power is calculated under either local
    or distant alternatives.  Under local alternatives the null-hypothesis
    covariance matrix is used for both null and alternative; this is
    appropriate when the odds ratio under the alternative is between about 0.5
    and 2.  The default is distant alternatives.

    All calculations assume the difference in proportions is normally
    distributed (or the score statistic for the conditional test).  This
    approximation may fail with very small sample sizes; use \code{ccorrect}
    in such cases.  As a rule of thumb, distrust results when any expected
    cell count is below 5.

    The expected number of events is calculated from the rounded sample sizes
    (unless \code{noround = TRUE}).
  }

  \subsection{One-sided tests}{
    For two-arm trials and trend tests, \code{artbin} always evaluates power
    in one direction.  When \code{onesided = FALSE} (default), \code{alpha}
    is halved before use, so \code{alpha(0.05)} is equivalent to
    \code{alpha(0.025) onesided}.  Multi-group trials (non-trend) are always
    two-sided; \code{onesided} is not allowed for those.
  }

  \subsection{Loss to follow-up}{
    When \code{ltfu} is specified, the sample size is inflated by
    \eqn{1/(1-\code{ltfu})}.  Events are computed on the observable
    (non-lost) participants, so \code{D} is unchanged.
  }

  \subsection{Observational studies}{
    \code{artbin} can be used for observational studies exploring a
    protective or harmful factor.  For a harmful risk factor the
    favourable/unfavourable classification is reversed; use \code{force} to
    override the automatic inference.
  }
}

\section{Note on scale}{
  All calculations are on the scale of the difference in proportions.  For
  superiority trials the results on other scales (e.g. odds ratio) are very
  similar.  For NI and SS trials the choice of scale matters considerably;
  see Quartagno \emph{et al.} (2020).
}

\references{
  Marley-Zagar E, White IR, Royston P, Barthel F, Parmar MKB, Babiker AG.
  artbin: Extended sample size for randomised trials with binary outcomes.
  \emph{Stata J} 2023; 23(1): 24--52.
  \doi{10.1177/1536867X231161971}

  Quartagno M, Walker AS, Babiker AG \emph{et al.}  Handling an uncertain
  control group event risk in non-inferiority trials: non-inferiority
  frontiers and the power-stabilising transformation.
  \emph{Trials} 2020; 21: 145.
  \doi{10.1186/s13063-020-4070-4}

  Blackwelder WC.  Proving the null hypothesis in clinical trials.
  \emph{Control Clin Trials} 1982; 3(4): 345--353.

  Pocock SJ.  \emph{Clinical Trials: A Practical Approach.}  Wiley, 1983.
}

\examples{
## Example 1: Two-arm superiority (Wald) -- Pocock 1983
## Reduces death probability from 10\% to 5\%, 90\% power
artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)
# Total n = 1156 (578 per arm)

## Example 2: Score test gives the same result as Stata power command
artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9)

## Example 3: One-sided NI trial -- 90\% survival in each arm,
## treatment no more than 5 percentage points worse
artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)
# 457 per arm

## Example 4: Four-arm superiority trial
artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
# 44 per arm

## Example 5: STREAM trial -- complex NI design with ltfu and 1:2 allocation
## (Nunn et al. 2019; Marley-Zagar et al. 2023, section 3)
artbin(pr = c(0.7, 0.75), margin = -0.1, power = 0.8,
       aratios = c(1, 2), wald = TRUE, ltfu = 0.2)
# Total n = 398  (133 control + 265 treatment)

## NI -- Blackwelder 1982 (score test default)
artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9)

## With continuity correction
artbin(pr = c(0.1, 0.2), ccorrect = TRUE)

## Trend test across four groups
artbin(pr = c(0.15, 0.25, 0.35, 0.45), trend = TRUE)

## Unequal allocation (1:2:2:2)
artbin(pr = c(0.15, 0.25, 0.35, 0.45), aratios = c(1, 2, 2, 2))

## Power calculation given n
artbin(pr = c(0.05, 0.1), alpha = 0.05, n = 1156, wald = TRUE)
}

\author{
  Original Stata package: Abdel Babiker, Friederike Barthel, Babak
  Choodari-Oskooei, Patrick Royston, Ella Marley-Zagar, Ian White
  (MRC Clinical Trials Unit at UCL).

  R translation: translated from Stata artbin v2.1.2 / art2bin v1.01.
}

\seealso{
  \code{\link[stats]{power.prop.test}} for a simpler two-sample proportion
  test in base R.
}
