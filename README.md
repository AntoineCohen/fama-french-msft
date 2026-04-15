# Fama-French Five-Factor Model on Microsoft — OLS, Diagnostics & Corrections

OLS estimation of the Fama-French five-factor model on MSFT daily excess returns (2021–2025), with full Gauss-Markov diagnostics and econometric corrections.

**[View report (PDF)](main.pdf)**

---

## Quick start

```bash
# 1. Install Python dependencies
pip install -r requirements.txt

# 2. Download prices and factors, build the dataset
python src/pipeline.py          # → data/processed/ff5_daily.csv

# 3. Install R dependencies
Rscript -e "renv::restore()"

# 4. Run regressions and diagnostics
Rscript src/analysis.R          # → outputs/tables/*.typ, outputs/figures/*.pdf

# 5. Compile the report
typst compile report/main.typ main.pdf --root .
```

Or with Make:

```bash
make all
```

---

## Project structure

```
.
├── src/
│   ├── pipeline.py       # Data acquisition and log excess return computation
│   └── analysis.R        # Model estimation, diagnostics, corrections
├── report/
│   ├── main.typ          # Typst entry point
│   ├── template/         # Localised elsearticle template (French)
│   └── sections/         # One .typ file per section
├── data/processed/       # Generated — ff5_daily.csv (gitignored)
├── outputs/              # Generated — tables and figures (gitignored)
├── requirements.txt
├── Makefile
└── main.pdf              # Compiled report
```

---

## Data sources

- **Stock prices** — Yahoo Finance via [`yfinance`](https://github.com/ranaroussi/yfinance) (split- and dividend-adjusted daily close, 2021–2025)
- **FF5 factors** — [Ken French Data Library](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html), daily frequency, converted from percent to decimal

---

## Reproducibility

R package versions are managed with [`renv`](https://rstudio.github.io/renv/). Run `renv::restore()` in R to install the exact versions used.

Required R packages: `car`, `corrplot`, `ggplot2`, `lmtest`, `modelsummary`, `moments`, `prais`, `sandwich`, `tinytable`

> **Note:** The Typst report uses a locally copied and French-localised version of the [`elsearticle`](https://github.com/maucejo/elsearticle) template. No external Typst package installation required beyond `--root .` for the output path.

---

*Économétrie · Antoine C. · Noah D.-G. | Note : 20/20 | S6, Université Catholique de Lille*
