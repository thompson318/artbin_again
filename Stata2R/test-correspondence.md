# Test Correspondence: Stata → R

This document maps each Stata certification test to the corresponding R testthat
test(s) in `R-package/tests/testthat/`.

---

## artbin_testing_1.do  →  `test-artbin-ni.R`

**Stata file:** `testing/artbin_testing_1.do`
**Stata Journal item:** Item 1 — Non-inferiority and substantial-superiority sample size/power

| Stata test | Expected value | R test name |
|---|---|---|
| Blackwelder 1982 SS (wald, α=10%, β=10%, d=20%) | n/2 = 39 | `"NI - Blackwelder 1982 (Wald)"` |
| Julious 2011 Table 4 row 1 (wald, p=0.3, d=5%, α=2.5%) | n/2 = 1766 | `"NI - Julious 2011 Table 4 row 1 (Wald)"` |
| Pocock 2003 (wald, p=0.15, d=15%, α=5%) | n/2 = 120 | `"NI - Pocock 2003 (Wald)"` |
| Sealed envelope (wald, p=0.2, d=10%, α=10%) | n/2 = 145 | `"NI - Sealed envelope (Wald)"` |
| Julious row 5 (wald, p=0.1, d=5%, α=2.5%) | n/2 = 757 | `"NI - Julious 2011 row 5 (Wald)"` |
| Julious row 6 (wald, p=0.25, d=20%, α=2.5%) | n/2 = 99 | `"NI - Julious 2011 row 6 (Wald)"` |
| Julious row 7 (wald, p=0.2, d=15%, α=2.5%) | n/2 = 150 | `"NI - Julious 2011 row 7 (Wald)"` |
| Julious row 8 (wald, p=0.15, d=5%, α=2.5%) | n/2 = 1072 | `"NI - Julious 2011 row 8 (Wald)"` |
| Power back-calc Blackwelder (n=78) | power ≈ 0.9 | `"NI - power back-calculation (Blackwelder)"` |
| Power back-calc Julious row 2 (n=3532) | power ≈ 0.9 | `"NI - power back-calculation (Julious row 2)"` |
| Power back-calc Pocock 2003 (n=240) | power ≈ 0.9 | `"NI - power back-calculation (Pocock 2003)"` |
| Substantial-superiority Palisade (aratio 1:3) | n = 391 | `"NI - substantial-superiority Palisade (aratio 1:3)"` |
| ssi comparisons (6 cases) | match ssi | *not ported — ssi not available in R* |
| niss comparisons (12 cases) | match niss | *not ported — niss not available in R* |
| STREAM LTFU (aratio 1:2, ltfu=0.2, wald) | n = 398 | `"NI - STREAM LTFU (aratio 1:2, ltfu 0.2, wald)"` also `"STREAM trial n=398"` in ltfu file |

---

## artbin_testing_2.do  →  `test-artbin-sup.R`

**Stata file:** `testing/artbin_testing_2.do`
**Stata Journal item:** Item 2 — Superiority sample size/power

| Stata test | Expected value | R test name |
|---|---|---|
| Pocock 1983 SS (wald, pr=(0.05,0.1), α=5%, β=10%) | n/2 = 578 | `"Superiority - Pocock 1983 SS (Wald)"` |
| Sealed envelope SS (wald, pr=(0.1,0.2), α=10%) | n/2 = 155 | `"Superiority - Sealed envelope SS (Wald)"` |
| Pocock 1983 power (n=1156) | power ≈ 0.9 | `"Superiority - Pocock 1983 power (Wald)"` |
| Sealed envelope power (n=310) | power ≈ 0.8 | `"Superiority - Sealed envelope power (Wald)"` |

---

## artbin_testing_3.do  →  `test-artbin-ccorrect.R`

**Stata file:** `testing/artbin_testing_3.do`
**Stata Journal item:** Item 3 — Continuity correction (vs Stata `power` command)

| Stata test | Expected value | R test name |
|---|---|---|
| pr=(0.05,0.1), α=5%, β=10%, ccorrect | n/2 = 621 | `"ccorrect - Pocock p=(0.05,0.1) alpha=5% power=90%"` |
| pr=(0.03,0.07), α=5%, β=5%, ccorrect | n/2 = 818 | `"ccorrect - p=(0.03,0.07) alpha=5% power=95%"` |
| pr=(0.1,0.2), α=5%, β=15%, ccorrect | n/2 = 247 | `"ccorrect - p=(0.1,0.2) alpha=5% power=85%"` |
| pr=(0.1,0.01), α=2.5%, β=20%, ccorrect | n/2 = 143 | `"ccorrect - p=(0.1,0.01) alpha=2.5% power=80%"` |
| pr=(0.15,0.2), α=10%, β=10%, ccorrect | n/2 = 1027 | `"ccorrect - p=(0.15,0.2) alpha=10% power=90%"` |
| pr=(0.3,0.1), α=5%, β=10%, ccorrect | n/2 = 92 | `"ccorrect - p=(0.3,0.1) alpha=5% power=90%"` |

---

## artbin_testing_4.do  →  `test-artbin-ni.R`

**Stata file:** `testing/artbin_testing_4.do`
**Stata Journal item:** Item 4 — NI margin option (onesided, vs Julious 2011 Table 4)

| Stata test | Expected value | R test name |
|---|---|---|
| pr=(0.3,0.1) margin=0.2 onesided (Julious row 1) | n/2 = 20 | `"NI - one-sided margin test (Julious row 1)"` |
| pr=(0.25,0.15) margin=0.1 onesided (Julious row 2) | n/2 = 83 | `"NI - one-sided margin test (Julious row 2)"` |
| 8 further Julious onesided NI cases | n/2 = 1556, 1209, 757, 105, 99, 117, 268, 915 | *not individually ported; covered by numeric checks* |

---

## artbin_testing_5.do  →  `test-artbin-ni.R`

**Stata file:** `testing/artbin_testing_5.do`
**Stata Journal item:** Item 5 — Comparison with Cytel EAST software

| Stata test | Expected value | R test name |
|---|---|---|
| Blackwelder (pr=(0.1,0.1) margin=0.2 α=10%) | n = 78 | `"NI Blackwelder (EAST comparison)"` |
| pr=(0.3,0.3) margin=0.1 α=5% power=0.8 | n = 660 | *not ported* |
| pr=(0.3,0.3) margin=0.05 α=5% | n = 3532 | *not ported* |
| pr=(0.15,0.15) margin=0.15 α=5% | n = 240 | *not ported* |
| pr=(0.2,0.2) margin=0.1 α=20% power=0.8 | n = 290 | *not ported* |
| pr=(0.1,0.1) margin=0.05 α=5% | n = 1514 | *not ported* |
| pr=(0.25,0.25) margin=0.2 α=5% | n = 198 | *not ported* |
| pr=(0.2,0.2) margin=0.15 α=5% | n = 300 | *not ported* |
| pr=(0.15,0.15) margin=0.05 α=5% | n = 2144 | *not ported* |
| EAST 10: pr=(0.9,0.9) margin=-0.023 aratio(1,2) | n = 8045 | `"NI - EAST comparison 10 (aratio 1:2)"` |

---

## artbin_testing_6.do  →  `test-artbin-ni.R`, `test-artbin-errors.R`

**Stata file:** `testing/artbin_testing_6.do`
**Stata Journal item:** Item 6 — onesided switch, ccorrect options

| Stata test | Expected value | R test name |
|---|---|---|
| onesided gives same as onesided(1) (10 cases) | match testing_4 values | covered by `test-artbin-ni.R` margin tests |
| onesided(0) conflict with onesided → error | _rc != 0 | `"error: local and wald"` (analogous; conflict errors) |
| ccorrect condit → error | _rc != 0 | `"error: ccorrect for >2 groups"` (different check) |

---

## artbin_testing_7.do  →  `test-artbin-kgroup.R`, `test-artbin-errors.R`

**Stata file:** `testing/artbin_testing_7.do`
**Stata Journal item:** Item 7 — routing, favourable/unfavourable, conditional, k-group, D

| Stata test | Expected value | R test name |
|---|---|---|
| 3-group local score | n = 234 | `"3-group local score"` |
| 3-group distant score | n = 231 | `"3-group distant score"` |
| 3-group conditional | result > 0 | `"3-group conditional local"` |
| 3-group trend test | n < omnibus n | `"3-group trend test"` |
| onesided trend = doubled alpha | n equal | `"onesided trend gives same as doubled alpha"` |
| 3-group unequal aratios | n1 > n3 | `"3-group unequal allocation"` |
| trend with onesided same as doubled alpha (doses) | match | covered by `"onesided trend gives same as doubled alpha"` |
| Error: trend for 2-arm | _rc != 0 | `"error: trend for 2-arm"` |
| Error: local and wald | _rc != 0 | `"error: local and wald"` |
| Error: wald nvm!=1 | _rc != 0 | `"error: wald and nvm!=1"` |
| D = sum(pi_i * n_i) noround | exact equality | `"k-group D = n * pibar (noround)"` |
| D = n*(0.4 + 0.6*2)/(1+2) noround aratio | exact | *not ported explicitly* |

---

## artbin_errortest_8.do  →  `test-artbin-errors.R`

**Stata file:** `testing/artbin_errortest_8.do`
**Stata Journal item:** Item 8 — error codes

| Stata test | Expected error | R test name |
|---|---|---|
| pr() too few elements | error | `"error: pr too few elements"` |
| pr element out of range (>1) | error | `"error: pr out of range high"` |
| pr element = 0 | error | `"error: pr out of range zero"` |
| Equal probabilities 2-arm | error | `"error: equal probabilities 2-arm superiority"` |
| alpha = 0 or 1 | error | `"error: alpha out of range"` |
| power = 0 or 1 | error | `"error: power out of range"` |
| n negative | error | `"error: n negative"` |
| margin with >2 groups | error | `"error: margin with >2 groups"` |
| ccorrect with >2 groups | error | `"error: ccorrect for >2 groups"` |
| onesided with >2 groups (no trend) | error | `"error: onesided for >2 groups (no trend)"` |
| local and wald together | error | `"error: local and wald"` |
| wald with nvm!=1 | error | `"error: wald and nvm!=1"` |
| n and power both specified | error | `"error: n and power both specified"` |
| ngroups mismatch | warning | `"ngroups mismatch gives warning not error"` |
| ltfu >= 1 | error | `"error: ltfu >= 1"` |
| ap2 out of range | error | `"error: ap2 out of range"` |
| aratios wrong length | error | *not ported — covered by artbin input validation* |

---

## artbin_test_ltfu.do  →  `test-artbin-ltfu.R`

**Stata file:** `testing/artbin_test_ltfu.do`

| Stata test | Expected value | R test name |
|---|---|---|
| SS inflated by 1/(1-ltfu) | n_ltfu = n_base / 0.9 | `"ltfu: SS inflated relative to no-ltfu"` |
| Events unchanged with ltfu | D_ltfu = D_base | `"ltfu: events unchanged"` |
| n→power with ltfu consistent | power(n=1000,ltfu=0.1) = power(n=900) | `"ltfu: power consistent with n->power"` |
| STREAM trial n=398 | n = 398 | `"STREAM trial n=398"` |
| Round-trip SS→power→SS (4 opts) | n recovered | *not ported explicitly* |
| Non-integer ltfu*n | n returned unchanged | *not ported explicitly* |

---

## artbin_test_rounding.do  →  `test-artbin-rounding.R`

**Stata file:** `testing/artbin_test_rounding.do`

| Stata test | Expected value | R test name |
|---|---|---|
| 2-arm NI aratio(1,2): n_i = ceil(unrounded) | exact | `"rounding: 2-arm NI aratio(1,2)"` |
| 2-arm sup aratio(1,2) | exact | `"rounding: 2-arm sup aratio(1,2)"` |
| 2-arm sup aratio(10,17) | exact | `"rounding: 2-arm sup aratio(10,17)"` |
| 3-arm aratio(3,2,1) | exact | `"rounding: 3-arm aratio(3,2,1)"` |
| 3-arm trend | exact | `"rounding: 3-arm trend"` |

---

## Not ported

The following Stata tests were not ported due to dependency on Stata-only commands
(`ssi`, `niss`, `power twoproportions`, `artbin_orig`) or because they test
display/formatting behaviour (output table format, `notable` option) which has no
direct equivalent in the R function interface:

- `ssi` comparisons in testing_1 (Stata-only command)
- `niss` comparisons in testing_1 (Stata-only command)
- `power twoproportions` comparisons in testing_3 — replaced by direct numeric checks
- `artbin_orig` comparisons in testing_7 (Stata v1.1.2 comparison)
- Dialog box testing (artbin_dlgboxtesting_9.do) — replaced by Shiny app
- `notable` output option tests

---

## Coverage summary

| Stata file | Stata tests | R tests ported | Coverage |
|---|:---:|:---:|:---:|
| artbin_testing_1.do | ~25 | 12 | ~48% (ssi/niss comparisons not ported) |
| artbin_testing_2.do | 4 | 4 | 100% |
| artbin_testing_3.do | 6 | 6 | 100% |
| artbin_testing_4.do | 10 | 2 | 20% (rest covered numerically by ni tests) |
| artbin_testing_5.do | 10 | 2 | 20% |
| artbin_testing_6.do | ~15 | partial | via error + ni tests |
| artbin_testing_7.do | ~20 | 7 | ~35% |
| artbin_errortest_8.do | 16 | 14 | 87% |
| artbin_test_ltfu.do | 6 | 4 | 67% |
| artbin_test_rounding.do | 5 | 5 | 100% |
