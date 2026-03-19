# Package Strategy Recommendation

## Recommendation: New standalone R package

The R `artbin` package should be published as a new standalone CRAN package
rather than contributed to an existing R package.

## Why not contribute to an existing package

**TrialSize** — the closest in scope, but effectively unmaintained (last CRAN
update 2020), has a fragmented API (dozens of disconnected functions), and
accepting a unified `artbin()` interface would require significant API design
coordination with maintainers who are not active.

**gsDesign / rpact** — share the Farrington-Manning score method, but are
group-sequential frameworks where a binary SS function is a small component of
a large opinionated system. The k-group, conditional, and local/distant options
do not fit their design.

**pwr / samplesize / Hmisc** — too limited in scope; contributing would mean
expanding the package's remit beyond what those maintainers likely want.

## Why a new package is the right call

1. **The feature combination is genuinely novel.** No existing package has
   NI/SS + k-group + conditional + local/distant + ltfu + continuity correction
   in a single function. It is not a subset of anything currently on CRAN.

2. **The name matches the Stata package.** Researchers who used `artbin` in
   Stata will find `library(artbin)` immediately.

3. **The citation maps cleanly.** The Stata Journal paper (Marley-Zagar *et
   al.*, 2023) cites `artbin` specifically. A CRAN package of the same name
   extends that citation naturally.

4. **Control over the interface.** The Stata team knows their design decisions
   in detail — rounding behaviour, nvmethod defaults, onesided handling.
   Contributing to someone else's package means negotiating every one of those
   choices with external maintainers.

## Recommended next step

Submit to CRAN. The package already passes `R CMD check` with 0 errors and 0
warnings, and 103 tests pass. CRAN submission would make the package properly
citable as a standalone R package and accessible without requiring users to
install from source.
