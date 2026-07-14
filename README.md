# mr-coloc-starter

A minimal, runnable **starter kit for Mendelian randomization (MR) and colocalization** analysis in statistical genetics, using the standard R stack: [`TwoSampleMR`](https://mrcieu.github.io/TwoSampleMR/) and [`coloc`](https://chr1swallace.github.io/coloc/).

The goal is to give you a clean, well-commented skeleton you can point at your own GWAS summary statistics — not a black box. Each step is a separate script you can read, run, and adapt.

---

## What's inside

```
mr-coloc-starter/
├── install.R            # install the required R packages (run once)
├── config.R             # all file paths & parameters live here — edit this first
├── R/
│   ├── utils.R          # shared helper functions
│   ├── 01_harmonise.R   # load + harmonise exposure & outcome summary stats
│   ├── 02_mr.R          # two-sample MR (IVW, Egger, weighted median, ...)
│   └── 03_coloc.R       # colocalization at a locus (coloc.abf)
├── data/                # put your summary-stat files here (git-ignored)
└── results/             # tables & plots are written here (git-ignored)
```

---

## What these methods do (one-liner each)

- **Mendelian randomization** uses genetic variants as instrumental variables to test whether an *exposure* (e.g. a biomarker) causally affects an *outcome* (e.g. a disease) — robust to reverse causation and much confounding.
- **Colocalization** asks whether an exposure and an outcome share the *same causal variant* at a locus, rather than two distinct variants in linkage disequilibrium — a common false-positive trap for MR.

Running both together is standard practice: MR for the causal direction/effect, coloc as a sanity check that the signal is the same variant.

---

## Quick start

### 1. Install packages (once)

```r
source("install.R")
```

### 2. Point the pipeline at your data

Open **`config.R`** and set the paths + column names for your exposure and outcome
summary statistics. Everything downstream reads from this one file.

### 3. Run the steps

```r
source("R/01_harmonise.R")   # -> results/harmonised.rds
source("R/02_mr.R")          # -> results/mr_results.csv + scatter/forest plots
source("R/03_coloc.R")       # -> results/coloc_summary.csv
```

Each script can be run on its own once the previous one has produced its output.

---

## Input data format

You need **GWAS summary statistics** for both the exposure and the outcome. A minimal
per-SNP table has these columns (names are configurable in `config.R`):

| column | meaning |
|---|---|
| `SNP` | rsID |
| `effect_allele` / `other_allele` | alleles |
| `beta` | effect size (log-OR for binary traits) |
| `se` | standard error of `beta` |
| `pval` | p-value |
| `eaf` | effect-allele frequency (needed for coloc MAF) |
| `samplesize` | per-SNP N (or set a global N in `config.R`) |

> Summary-stat files are **git-ignored** — see `data/README.md`. Never commit
> individual-level data.

---

## Notes

- This is a **template**, not a published analysis. Sensible defaults are set, but the
  right instrument p-value threshold, clumping parameters, and coloc priors depend on
  your study — they're all surfaced in `config.R` with comments.
- If you use OpenGWAS/IEU data, `TwoSampleMR::extract_instruments()` and
  `extract_outcome_data()` can replace the local-file readers in `01_harmonise.R`.

## References

- Hemani et al. (2018) *The MR-Base platform.* eLife. (TwoSampleMR)
- Giambartolomei et al. (2014) *Bayesian test for colocalisation.* PLoS Genet. (coloc)
