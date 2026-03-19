# Contributing to artbin (R package)

Thank you for your interest in contributing. This R package is a translation of
the Stata `artbin` package v2.1.x developed at the MRC Clinical Trials Unit at
UCL.

## Scope

This package aims to preserve the behaviour of the Stata package exactly. When
in doubt, the Stata implementation is the reference. Contributions that add new
functionality should first be discussed with the maintainer.

## Reporting bugs

Please open an issue describing:

- The `artbin()` call that produced the unexpected result
- The output you received and the output you expected
- The corresponding Stata `artbin` result, if you have access to Stata

## Making changes

1. Fork the repository and create a branch from `main`.
2. Make your changes in `R/`.
3. Run the test suite and ensure all tests pass:

   ```r
   devtools::test()
   ```

4. If you fix a bug or add behaviour, add a test in `tests/testthat/` that
   covers it. See the existing test files for style:

   | File | Covers |
   |---|---|
   | `test-artbin-ni.R` | Non-inferiority and substantial-superiority |
   | `test-artbin-sup.R` | Superiority |
   | `test-artbin-ccorrect.R` | Continuity correction |
   | `test-artbin-kgroup.R` | K-group (>2 arms) |
   | `test-artbin-ltfu.R` | Loss to follow-up |
   | `test-artbin-rounding.R` | Rounding behaviour |
   | `test-artbin-errors.R` | Input validation and error messages |
   | `test-artbin-ssi-niss.R` | Comparison with Stata `ssi` and `niss` commands (requires Stata) |

5. Run `R CMD check` and resolve any errors or warnings:

   ```r
   devtools::check()
   ```

6. Open a pull request with a clear description of what changed and why.

## Test correspondence

`Stata2R/test-correspondence.md` (in the repository root) maps each Stata
certification test to the corresponding R test. Please keep this document
up to date when adding or changing tests.

## Code style

- Follow base-R conventions; avoid introducing new package dependencies.
- Internal helpers should be prefixed with `.` and kept in `R/utils.R`.
- Match variable names and logic structure to the Stata source where possible,
  to make future audits straightforward.

## Contact

Maintainer: Ian White <ian.white@lshtm.ac.uk>
