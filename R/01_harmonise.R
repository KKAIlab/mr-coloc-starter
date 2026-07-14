# R/01_harmonise.R
# Load exposure & outcome summary stats, select instruments, and harmonise
# alleles so that betas are aligned to the same effect allele.
#
# Output: results/harmonised.rds  (a TwoSampleMR "harmonised" data frame)

source("config.R")
source("R/utils.R")
suppressMessages(library(TwoSampleMR))

step("Reading exposure: ", config$exposure_file)
exp_raw <- read_sumstats(config$exposure_file)

step("Reading outcome:  ", config$outcome_file)
out_raw <- read_sumstats(config$outcome_file)

# --- Select exposure instruments (genome-wide significant SNPs) -------------
step("Selecting instruments at p < ", format(config$instrument_pval))
exp_sig <- exp_raw[pval < config$instrument_pval]
if (nrow(exp_sig) == 0) {
  stop("No SNPs pass instrument_pval. Loosen the threshold in config.R.", call. = FALSE)
}
message("  ", nrow(exp_sig), " candidate instrument(s) before clumping")

# Format for TwoSampleMR
exposure_dat <- format_data(
  as.data.frame(exp_sig), type = "exposure",
  snp_col = "SNP", beta_col = "beta", se_col = "se", pval_col = "pval",
  effect_allele_col = "effect_allele", other_allele_col = "other_allele",
  eaf_col = "eaf", samplesize_col = "samplesize"
)
exposure_dat$exposure <- config$exposure_name

# LD clumping to keep independent instruments.
# Note: clump_data() queries the IEU API by default; for offline use, supply a
# local reference panel via ld_clump() from the ieugwasr package.
exposure_dat <- tryCatch(
  clump_data(exposure_dat, clump_r2 = config$clump_r2, clump_kb = config$clump_kb),
  error = function(e) {
    warning("Clumping failed (", conditionMessage(e),
            "). Proceeding WITHOUT clumping — instruments may be correlated.")
    exposure_dat
  }
)
message("  ", nrow(exposure_dat), " independent instrument(s) after clumping")

# --- Pull the same SNPs from the outcome ------------------------------------
step("Extracting instruments from the outcome")
outcome_dat <- format_data(
  as.data.frame(out_raw[SNP %in% exposure_dat$SNP]), type = "outcome",
  snp_col = "SNP", beta_col = "beta", se_col = "se", pval_col = "pval",
  effect_allele_col = "effect_allele", other_allele_col = "other_allele",
  eaf_col = "eaf", samplesize_col = "samplesize"
)
outcome_dat$outcome <- config$outcome_name

# --- Harmonise --------------------------------------------------------------
step("Harmonising alleles")
dat <- harmonise_data(exposure_dat, outcome_dat, action = 2)
message("  ", sum(dat$mr_keep), " SNP(s) retained for MR")

saveRDS(dat, result_path("harmonised.rds"))
step("Saved -> ", result_path("harmonised.rds"))
