# Demand Estimation and Algorithmic Pricing in Hotel Search

Two-part applied econometrics project: causal demand estimation on a
large-scale online hotel search dataset, and a structural replication of an
algorithmic-collusion pricing model.

## Part 1 — Hotel Search: Causal Demand Estimation

Using the Expedia *Personalizing Hotel Searches* dataset (~9.9M impressions,
399,344 search sessions, 136,886 properties), this part estimates the causal
effect of price on click-through and booking probability while addressing two
sources of endogeneity: unobserved hotel quality and algorithmically
determined display position.

Identification leans on the `random_bool = 1` subsample (~30% of the data), in
which Expedia's ranking algorithm is switched off and hotels appear in random
order. Eight specifications are estimated — pooled OLS, OLS on random-order
sessions only, OLS on the IV sample, within-session fixed effects, IV/2SLS, and
double/debiased ML with gradient-boosted nuisance functions — so that the
sample restriction and the estimator change can be separated from one another.

**Headline result.** The preferred within-session fixed-effects estimate is a
log-price semi-elasticity of −0.0298 for clicks and −0.0049 for bookings. A 10%
price increase lowers click probability by about 0.28 percentage points, or
roughly 6% of the baseline click rate.

**On the IV specification.** The first stage is strong (partial F = 261,010,
Shea partial R² = 0.43). The problem is the exclusion restriction: the
instrument is the hotel's own historical Expedia rate, which plausibly proxies
persistent unobserved quality. The 2SLS estimate is *less* negative than OLS on
identical rows — the opposite of what quality-driven endogeneity predicts, and
evidence that the instrument carries the signal it was meant to purge. It is
reported as a diagnostic, not as a causal estimate.

A sequential search model (Ursu, Seiler and Honka, 2024) is then estimated by
simulated maximum likelihood, separating consumer preferences from
position-dependent search costs. Search costs rise about 4.7% per position
down the page.

## Part 2 — Algorithmic Pricing: Q-Learning Replication

A replication of the N = 3 algorithmic pricing environment of Liu, Wang and
Ghose (2026), in which firms use Q-learning over a restricted rule set
(*Undercut / Match / Above*) rather than the full price grid, compared against
the unconstrained Q-learning collusion results of Calvano et al. (2020, *AER*).

**What replicates.** The collusion index reproduces exactly: Δ = 1.000 ± 0.000
across 50 seeds, with the market locking at the monopoly price and 100% of runs
converging and passing a one-shot Nash deviation check. The commitment-length
sweep confirms the mechanism, with a critical threshold at K\* = 5.

**What does not.** State robustness holds in only **28%** of runs, against the
100% reported in the paper. The collusive outcome is reached reliably but
supported fragilely, which qualifies the headline result.

The section also argues that because *Match* sets a seller's price equal to its
rival's, coordination is a primitive of the action space rather than something
the algorithms discover — so Δ = 1.00 here is a weaker claim than Calvano et
al.'s emergent collusion under unconstrained competition.

An extension replaces the perfect competitor-price signal with a noisy private
draw and derives predictions for price-transparency regulation under Article
6(1)(j) of the EU Digital Markets Act.

## Repository structure

```
├── notebooks/
│   ├── part1_hotel_demand_estimation.ipynb
│   └── part2_algorithmic_pricing_qlearning.ipynb
├── report/
│   ├── Rekovets_Report.tex        # source
│   ├── Rekovets_Report.pdf        # compiled
│   └── figures/                   # extracted from notebook outputs
├── scripts/
│   ├── check_report_matches_notebooks.py
│   ├── compare_notebook_results.py
│   └── execute_notebook.py
├── .github/workflows/          # verify on push; reproduce Part 2 on a schedule
├── Makefile
├── requirements.txt
└── LICENSE
```

## Reproducibility

Every number in the report traces to a saved notebook output, and this is
enforced mechanically rather than by inspection.

```bash
make verify      # check the report against the notebook outputs (seconds, no data)
make report      # verify, then rebuild the PDF
make rerun-part2 # re-execute Part 2 and diff it against the committed results
```

`scripts/check_report_matches_notebooks.py` extracts every number from the
report's LaTeX source and fails if any of them cannot be found in the executed
notebook outputs, which keeps the write-up from drifting away from the code as
the analysis is rerun. Report tables are generated programmatically from the
fitted model objects (Part 1, final cell) rather than transcribed by hand.

`scripts/compare_notebook_results.py` compares two runs of the same notebook,
ignoring wall-clock timings and object reprs, and fails if any number differs.

### What runs automatically

| Check | Where | Data needed |
|---|---|---|
| Report matches notebook outputs | CI, every push | none |
| Report compiles | CI, every push | none |
| Part 2 re-executed end to end and compared | CI, monthly + on demand | none |
| Part 1 re-executed end to end and compared | local only | Expedia parquet |

Part 2 is self-contained — pure numpy, seeded per run — so re-executing it is a
genuine end-to-end reproduction. It takes about 40 minutes, which is why it
runs on a schedule rather than on every push (`.github/workflows/`).

Part 1 depends on the ~9.9M-row Expedia dataset, which is not redistributable
through this repository, so it cannot run in CI. Reproduce it locally:

```bash
EXPEDIA_PARQUET=/path/to/train_processed.parquet make rerun-part1
```

Without that variable the notebook falls back to `./data`, and will build the
processed parquet from the raw Kaggle CSV on first run.

## Data

The Expedia dataset is not included here due to its size. It is publicly
available from the Kaggle *Personalize Expedia Hotel Searches* competition:
<https://www.kaggle.com/c/expedia-personalized-sort>

## Environment

```bash
pip install -r requirements.txt
```

## Author

Anastasiia Rekovets

## AI tool usage

Claude was used as a coding assistant for syntax and debugging, and for a
review pass over the analysis and write-up.
