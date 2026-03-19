# R Landscape for Binary Outcome Sample Size / Power

This document surveys existing R packages that compute sample size or power for
binary outcomes, assessing their overlap with and gaps relative to `artbin`.

---

## Packages reviewed

### `pwr` (v1.3-0)

**Functions:** `pwr.2p.test()`, `pwr.2p2n.test()`, `pwr.p.test()`

| Feature | pwr |
|---|---|
| Two-arm superiority | Yes (`pwr.2p.test`) |
| Non-inferiority / SS margins | No |
| k-group (>2 arms) | No |
| Unequal allocation | Via `pwr.2p2n.test` (fixed n per arm) |
| Continuity correction | No |
| Conditional (Peto) test | No |
| Local alternatives | No |
| Loss to follow-up | No |
| Score / Wald choice | Always uses arc-sine (Cohen h) — different method |

**Verdict:** Covers only basic two-arm superiority using the arc-sine transformation.
Not suitable as a drop-in replacement for `artbin`.

---

### `TrialSize` (v1.4)

**Functions:** `TwoSampleProportion.NIS()`, `TwoSampleProportion.Superiority()`,
  `MultipleArms.Omnibus.test()`, many others.

| Feature | TrialSize |
|---|---|
| Two-arm superiority | Yes |
| Non-inferiority (Wald) | Yes (`TwoSampleProportion.NIS`) |
| Substantial-superiority | Not directly |
| k-group (>2 arms) | Yes (`MultipleArms.Omnibus.test`) |
| Unequal allocation | Some functions |
| Continuity correction | Some functions |
| Conditional (Peto) test | No |
| Local alternatives | No |
| Loss to follow-up | No |
| Score / Wald / Local choice | Wald in NI functions; score elsewhere |

**Verdict:** Closest existing R package to `artbin`. Covers NI and k-group separately
but lacks unified interface, conditional test, local/distant choice, ltfu, and the
constrained-ML null-variance method (nvmethod=3 / score default).

---

### `samplesize` (v0.2-4)

**Functions:** `n.for.2p()`, `n.for.equivtest.2p()`, `n.for.noninferior.2p()`

| Feature | samplesize |
|---|---|
| Two-arm superiority | Yes |
| Non-inferiority | Yes |
| Substantial-superiority | No |
| k-group | No |
| Unequal allocation | No |
| Continuity correction | No |
| Conditional / Local / Wald | No |
| Loss to follow-up | No |

**Verdict:** Simple functions for two-arm designs only. No k-group, no ltfu, limited
method options.

---

### `gsDesign` (v3.6.1)

**Functions:** `nBinomial()`, `nBinomial1Sample()`, `twoStageTTE()`, …

| Feature | gsDesign |
|---|---|
| Two-arm superiority | Yes (`nBinomial`) |
| Non-inferiority | Yes (via `delta1` / one-sided) |
| Substantial-superiority | Yes (negative NI margin) |
| k-group | No |
| Unequal allocation | Yes |
| Score / Wald choice | Score (Farrington–Manning) |
| Continuity correction | No |
| Conditional / Local | No |
| Loss to follow-up | No |
| Group sequential extensions | Yes |

**Verdict:** Good two-arm NI/SS coverage with Farrington–Manning score test (same
method as artbin's default). No k-group. Part of a larger group-sequential framework.

---

### `clinfun` (v1.1.4)

**Functions:** `ph2simon()`, `bskt.size()`, `crit.vals.ph2()` — focused on Phase II
single-arm designs.

**Verdict:** Not relevant to multi-arm binary outcome SS.

---

### `rpact` (v3.4.2)

**Functions:** `getSampleSizeProportion()`, `getPowerProportion()`

| Feature | rpact |
|---|---|
| Two-arm superiority | Yes |
| Non-inferiority | Yes |
| k-group | No |
| Score / Wald choice | Score |
| Unequal allocation | Yes |
| Continuity correction | No |
| Conditional / Local | No |
| Loss to follow-up | No |
| Adaptive/sequential designs | Yes |

**Verdict:** Strong two-arm coverage; no k-group support.

---

### `Hmisc` (v5.1)

**Functions:** `bpower()`, `bsamsize()`

| Feature | Hmisc |
|---|---|
| Two-arm superiority | Yes |
| Non-inferiority | No |
| k-group | No |
| Continuity correction | Yes |
| Conditional / Local / Wald | No |
| Loss to follow-up | No |

**Verdict:** Basic two-arm only; useful continuity-correction support.

---

## Summary comparison

| Feature | artbin | pwr | TrialSize | gsDesign | rpact |
|---|:---:|:---:|:---:|:---:|:---:|
| Two-arm superiority | ✓ | ✓ | ✓ | ✓ | ✓ |
| Non-inferiority | ✓ | – | ✓ | ✓ | ✓ |
| Substantial-superiority | ✓ | – | partial | ✓ | ✓ |
| k-group (>2 arms) | ✓ | – | ✓ | – | – |
| Constrained-ML null variance (score) | ✓ | – | – | ✓ | ✓ |
| Wald test | ✓ | – | ✓ | – | – |
| Local alternatives | ✓ | – | – | – | – |
| Conditional (Peto) test | ✓ | – | – | – | – |
| Continuity correction | ✓ | – | partial | – | – |
| Unequal allocation | ✓ | partial | partial | ✓ | ✓ |
| Loss to follow-up | ✓ | – | – | – | – |
| Trend test (k-group) | ✓ | – | – | – | – |
| Unified interface (single function) | ✓ | – | – | – | – |

---

## Conclusion

No existing R package replicates the full `artbin` feature set. The R `artbin`
translation fills a genuine gap. For users who need only two-arm NI/SS designs,
`gsDesign::nBinomial()` or `rpact::getSampleSizeProportion()` are the closest
alternatives (both use Farrington–Manning score, the same as artbin's default). For
k-group superiority, `TrialSize::MultipleArms.Omnibus.test()` covers a subset of
cases. No package combines NI/SS + k-group + conditional + ltfu in a single function.
