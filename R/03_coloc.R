# R/03_coloc.R
# Colocalization at a single locus with coloc.abf: do the exposure and outcome
# share one causal variant, or two distinct variants in LD?
#
# Input:  exposure/outcome summary stats (via config.R) restricted to the locus
# Output: results/coloc_summary.csv  (posterior probs H0..H4)
#
# Posterior hypotheses:
#   H0 no signal | H1 exposure only | H2 outcome only
#   H3 both, different variants | H4 both, SAME variant (colocalized)

source("config.R")
source("R/utils.R")
suppressMessages(library(coloc))

# --- Region check -----------------------------------------------------------
if (is.null(config$coloc_chr) || is.null(config$coloc_start) || is.null(config$coloc_end)) {
  stop("Set coloc_chr / coloc_start / coloc_end in config.R to define the locus.",
       call. = FALSE)
}

step("Reading summary stats and restricting to the locus")
exp_dt <- read_sumstats(config$exposure_file)
out_dt <- read_sumstats(config$outcome_file)

in_region <- function(dt) {
  dt[chr == config$coloc_chr & pos >= config$coloc_start & pos <= config$coloc_end]
}
exp_dt <- in_region(exp_dt)
out_dt <- in_region(out_dt)

# Keep SNPs present in both, aligned by rsID.
common <- intersect(exp_dt$SNP, out_dt$SNP)
if (length(common) < 2) stop("Fewer than 2 shared SNPs in the locus.", call. = FALSE)
exp_dt <- exp_dt[SNP %in% common][order(SNP)]
out_dt <- out_dt[SNP %in% common][order(SNP)]
message("  ", length(common), " shared SNP(s) in the locus")

# --- Build coloc datasets ---------------------------------------------------
# varbeta = se^2. MAF from effect-allele freq. N from per-SNP or global config.
mk_dataset <- function(dt, type, n_global, case_prop = NULL) {
  N <- if (!is.null(n_global)) n_global else dt$samplesize
  d <- list(
    snp     = dt$SNP,
    beta    = dt$beta,
    varbeta = dt$se^2,
    MAF     = pmin(dt$eaf, 1 - dt$eaf),
    N       = N,
    type    = type
  )
  if (type == "cc") {
    if (is.null(case_prop)) stop("outcome_case_prop must be set for a case-control trait.")
    d$s <- case_prop
  }
  d
}

exp_ds <- mk_dataset(exp_dt, config$exposure_type, config$exposure_n)
out_ds <- mk_dataset(out_dt, config$outcome_type,  config$outcome_n,
                     case_prop = config$outcome_case_prop)

check_dataset(exp_ds); check_dataset(out_ds)

# --- Run coloc.abf ----------------------------------------------------------
step("Running coloc.abf")
res <- coloc.abf(exp_ds, out_ds,
                 p1 = config$p1, p2 = config$p2, p12 = config$p12)

summ <- as.data.frame(t(res$summary))
write.csv(summ, result_path("coloc_summary.csv"), row.names = FALSE)
step("Saved -> ", result_path("coloc_summary.csv"))

pp4 <- res$summary["PP.H4.abf"]
message(sprintf("  PP.H4 (shared causal variant) = %.3f%s",
                pp4, if (pp4 > 0.75) "  -> strong colocalization" else ""))
