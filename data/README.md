# data/

Put your GWAS summary-statistics files here. By default `config.R` expects:

- `data/exposure.tsv`
- `data/outcome.tsv`

Everything in this folder **except this README is git-ignored** (see `../.gitignore`),
so summary stats and any individual-level data stay out of version control.

Each file should be a per-SNP table with (at minimum) the columns listed in the
main [README](../README.md#input-data-format). Column names are configurable in
`config.R` — you don't have to rename your files, just map the columns.
