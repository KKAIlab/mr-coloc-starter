# example/

**Synthetic** GWAS summary statistics for trying the pipeline end-to-end — no real
data, safe to commit. Generated with a fixed seed so results are reproducible.

| file | rows | what's in it |
|---|---|---|
| `example_exposure.tsv` | 190 SNPs | 40 independent genome-wide-significant instruments (true causal effect **θ ≈ 0.35**) + a 150-SNP locus on chr1 |
| `example_outcome.tsv` | 190 SNPs | matched SNPs; outcome = θ·exposure + noise, plus a **shared causal variant** at the chr1 locus |
| `mr_scatter_example.png` | — | MR scatter below, rendered from these files |

## Try it

Point `config.R` at these files:

```r
exposure_file = "example/example_exposure.tsv"
outcome_file  = "example/example_outcome.tsv"
# for coloc (the shared-signal locus):
coloc_chr = 1, coloc_start = 154500000, coloc_end = 154800000
outcome_type = "cc", outcome_case_prop = 0.3
```

Then run `R/01_harmonise.R` → `R/02_mr.R` → `R/03_coloc.R`.

Expected: MR (IVW) recovers a slope of **~0.34**, and coloc returns a high **PP.H4**
(shared causal variant) at the chr1 locus.

> These numbers are simulated to *demonstrate* a positive result — they are not a
> real biological finding.
