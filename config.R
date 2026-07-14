# config.R — edit this file first. All paths and parameters live here.
# Sourced by every script in R/.

config <- list(

  # ---- Input files (put your summary stats in data/) ----------------------
  exposure_file = "data/exposure.tsv",   # exposure GWAS summary statistics
  outcome_file  = "data/outcome.tsv",    # outcome  GWAS summary statistics

  # ---- Trait labels (used in output tables / plots) -----------------------
  exposure_name = "Exposure",
  outcome_name  = "Outcome",

  # ---- Column mapping -----------------------------------------------------
  # Map YOUR file's column names to what the pipeline expects.
  # Same mapping is assumed for both files; adjust in utils.R if they differ.
  cols = list(
    SNP           = "SNP",
    effect_allele = "effect_allele",
    other_allele  = "other_allele",
    beta          = "beta",
    se            = "se",
    pval          = "pval",
    eaf           = "eaf",           # effect-allele freq (needed for coloc)
    samplesize    = "samplesize",    # per-SNP N; or use the globals below
    chr           = "chr",
    pos           = "pos"
  ),

  # If per-SNP sample size is missing, set global Ns here (else leave NULL).
  exposure_n = NULL,
  outcome_n  = NULL,

  # ---- MR: instrument selection ------------------------------------------
  instrument_pval  = 5e-8,   # genome-wide significance for exposure instruments
  clump_r2         = 0.001,  # LD clumping r^2 threshold
  clump_kb         = 10000,  # LD clumping window (kb)

  # ---- Colocalization -----------------------------------------------------
  # coloc runs on a single locus. Define the window (build must match your data).
  coloc_chr        = NULL,   # e.g. 1
  coloc_start      = NULL,   # e.g. 154400000
  coloc_end        = NULL,   # e.g. 154800000
  # Trait types for coloc: "quant" (continuous) or "cc" (case-control).
  exposure_type    = "quant",
  outcome_type     = "cc",
  outcome_case_prop = NULL,  # proportion of cases, required when type = "cc"
  # coloc.abf priors (defaults are the coloc package defaults).
  p1 = 1e-4, p2 = 1e-4, p12 = 1e-5,

  # ---- Output -------------------------------------------------------------
  results_dir = "results"
)
