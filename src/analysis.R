# Purpose    : FF5 factor model estimation and Gauss-Markov diagnostics for MSFT
# Data source: data/processed/ff5_daily.csv (produced by src/pipeline.py)
# Output     : outputs/tables/*.typ, outputs/figures/*.pdf
# Author     : Antoine C. and Noah D.-G.
# Date       : 2026-03

# ---- 0. Packages and data ----

library(car)
library(corrplot)
library(ggplot2)
library(lmtest)
library(modelsummary)
library(moments)
library(prais)
library(sandwich)
library(tinytable)

dir.create("outputs/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

# Log returns achieve stationarity by construction (differencing the log price series).
# No unit root test is required — stationarity is ensured a priori by the transformation.

ff5_data <- read.csv(file.path("data", "processed", "ff5_daily.csv"))

# Five FF5 factor column names — used repeatedly for subsetting and semi-standardized effects
factor_cols <- c("mkt_rf", "smb", "hml", "rmw", "cma")

# ---- 0b. Descriptive statistics table ---- # Voir p. 6
# Mean, sd, min, max, skewness, kurtosis, JB p-value for all 6 series.
# Exported as a Typst table for Section 3.

vars_desc   <- c("msft_excess", "mkt_rf", "smb", "hml", "rmw", "cma")
var_labels  <- c("MSFT (excédentaire)", "Mkt-RF", "SMB", "HML", "RMW", "CMA")

desc_rows <- mapply(function(v, label) {
  x  <- ff5_data[[v]]
  jb <- moments::jarque.test(x)
  list(
    label    = label,
    moyenne  = mean(x),
    ecart    = sd(x),
    minimum  = min(x),
    maximum  = max(x),
    skewness = moments::skewness(x),
    kurtosis = moments::kurtosis(x),
    jb_p     = jb$p.value
  )
}, vars_desc, var_labels, SIMPLIFY = FALSE)

desc_df <- data.frame(
  Variable    = sapply(desc_rows, `[[`, "label"),
  Moyenne     = sapply(desc_rows, `[[`, "moyenne"),
  `Écart-type` = sapply(desc_rows, `[[`, "ecart"),
  Minimum     = sapply(desc_rows, `[[`, "minimum"),
  Maximum     = sapply(desc_rows, `[[`, "maximum"),
  Skewness    = sapply(desc_rows, `[[`, "skewness"),
  Kurtosis    = sapply(desc_rows, `[[`, "kurtosis"),
  `JB (p)`    = sapply(desc_rows, `[[`, "jb_p"),
  check.names = FALSE
)

tt(desc_df, digits = 4) |>
  save_tt(file.path("outputs", "tables", "descriptive_stats.typ"), overwrite = TRUE)

# ---- 0c. Hypotheses table ---- # Voir p. 4
# Static lookup table: factor hypotheses for MSFT. Typst math strings pass through
# tinytable unchanged because save_tt(.typ) outputs raw Typst markup.
# Single-quoted strings allow embedded double quotes (Typst math text mode: "Mkt-RF").

hyp_df <- data.frame(
  `Hypothèse` = c(
    'H1 : $beta_"mkt" > 1$',
    'H2 : $beta_"smb" < 0$',
    'H3 : $beta_"hml" < 0$',
    'H4 : $beta_"rmw" > 0$',
    'H5 : $beta_"cma" < 0$'
  ),
  `Signe attendu` = c("Positif, > 1", "Négatif", "Négatif", "Positif", "Négatif"),
  `Justification économique` = c(
    "MSFT amplifie les mouvements de marché en tant que valeur technologique de croissance",
    "MSFT figure parmi les plus grandes capitalisations mondiales",
    "Profil de croissance, valorisation fondée sur les flux futurs, faible ratio book-to-market",
    "Rentabilité opérationnelle élevée et soutenue, marges parmi les plus hautes du secteur",
    "Stratégie d'investissement agressive, dépenses R&D et infrastructure IA massives"
  ),
  check.names = FALSE
)

tt(hyp_df, align = "lcl") |>
  save_tt(file.path("outputs", "tables", "hypotheses.typ"), overwrite = TRUE)

# ---- 0d. FF5 variables table ---- # Voir p. 9
# Static lookup table: variable definitions for Section 4 (model specification).

var_df <- data.frame(
  Variable = c(
    '$R_(i,t) - R_(f,t)$',
    '$"Mkt-RF"_t$',
    '$"SMB"_t$',
    '$"HML"_t$',
    '$"RMW"_t$',
    '$"CMA"_t$',
    '$alpha_i$',
    '$epsilon_(i,t)$'
  ),
  `Définition` = c(
    "Rendement excédentaire quotidien de MSFT",
    "Rendement excédentaire du portefeuille de marché",
    "Prime de taille (Small Minus Big)",
    "Prime de valeur (High Minus Low)",
    "Prime de rentabilité (Robust Minus Weak)",
    "Prime d'investissement (Conservative Minus Aggressive)",
    "Intercept (rendement anormal)",
    "Terme d'erreur"
  ),
  check.names = FALSE
)

tt(var_df, align = "ll") |>
  save_tt(file.path("outputs", "tables", "variables_ff5.typ"), overwrite = TRUE)

# ---- 1. CAPM regression ---- # Voir p. 10
# CAPM regression — Section 5

model_capm <- lm(msft_excess ~ mkt_rf, data = ff5_data)

# Print coefficient table with 95% confidence intervals.
print(summary(model_capm)); print(confint(model_capm))

# "A one-unit increase in Mkt-RF leads to beta_hat variation in MSFT excess return,
#  on average, ceteris paribus."

cat(sprintf("CAPM Adj. R² = %.4f\n", summary(model_capm)$adj.r.squared))

# ---- 1b. FF3 regression ---- # Voir p. 10
# FF3 regression (three factors) — Section 5

model_ff3 <- lm(msft_excess ~ mkt_rf + smb + hml, data = ff5_data)
print(summary(model_ff3)); print(confint(model_ff3))
cat(sprintf("FF3  Adj. R² = %.4f\n", summary(model_ff3)$adj.r.squared))
cat(sprintf(
  "Improvement over CAPM: +%.4f\n",
  summary(model_ff3)$adj.r.squared - summary(model_capm)$adj.r.squared
))

modelsummary(
  list("FF3 - MSFT" = model_ff3),
  output = file.path("outputs", "tables", "ff3_msft.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# ---- 2. FF5 regression ---- # Voir p. 11
# FF5 regression (five factors) — Section 5

model_ff5 <- lm(msft_excess ~ mkt_rf + smb + hml + rmw + cma, data = ff5_data)

# Confidence intervals reveal whether each factor loading is precisely estimated.
print(summary(model_ff5)); print(confint(model_ff5))

# Adjusted R² comparison shows how much the five additional factors explain beyond beta alone.
cat(sprintf("FF5  Adj. R² = %.4f\n", summary(model_ff5)$adj.r.squared))
cat(sprintf(
  "Improvement over CAPM: +%.4f\n",
  summary(model_ff5)$adj.r.squared - summary(model_capm)$adj.r.squared
))

# Semi-standardized marginal effects express each factor's economic impact in return units
# (beta_hat * sigma_X) — comparable across factors with different scales.
sigma_x <- apply(ff5_data[, factor_cols], 2, sd)
semi_std <- coef(model_ff5)[factor_cols] * sigma_x
cat("\nSemi-standardized marginal effects (beta_hat * sigma_X):\n")
print(sort(abs(semi_std), decreasing = TRUE))

# Side-by-side CAPM vs FF5 table for the report's model comparison section.
modelsummary(
  list("CAPM" = model_capm, "FF3" = model_ff3, "FF5" = model_ff5),
  output = file.path("outputs", "tables", "capm_ff5_comparison.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# Standalone CAPM table — used in Section 5 before introducing FF5.
modelsummary(
  list("CAPM - MSFT" = model_capm),
  output  = file.path("outputs", "tables", "capm_msft.typ"),
  stars   = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fmt     = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# Standalone FF5 MSFT table with all five factor coefficients for the main results section.
modelsummary(
  list("FF5 - MSFT" = model_ff5),
  output = file.path("outputs", "tables", "ff5_msft.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# ---- 3. Peer comparison ---- # Voir p. 13

# Three peer tech companies estimated with the same FF5 specification.
# These regressions serve the discussion section only — no repeated full diagnostics.
model_aapl <- lm(aapl_excess ~ mkt_rf + smb + hml + rmw + cma, data = ff5_data)
model_googl <- lm(googl_excess ~ mkt_rf + smb + hml + rmw + cma, data = ff5_data)
model_meta <- lm(meta_excess ~ mkt_rf + smb + hml + rmw + cma, data = ff5_data)

# Four-column table allows direct visual comparison of factor loadings across tech peers.
modelsummary(
  list("MSFT" = model_ff5, "AAPL" = model_aapl, "GOOGL" = model_googl, "META" = model_meta),
  output = file.path("outputs", "tables", "peers_ff5.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# ---- 4. H2 — Normality ---- # Voir p. 15
# H2 — Normality: Jarque-Bera test — Section 6

# Jarque-Bera test: H0 = residuals are normally distributed.
# moments::jarque.test() is required per locked decisions (not tseries::jarque.bera.test()).
jb_test <- moments::jarque.test(resid(model_ff5))

# Q-Q plot of FF5 residuals — visualises departure from normality in the tails.
resid_data <- data.frame(resid = resid(model_ff5))
p_qq <- ggplot(resid_data, aes(sample = resid)) +
  stat_qq(color = "#CC5500", alpha = 0.3) +
  stat_qq_line(color = "#17375E", linewidth = 0.8) +
  labs(
    title = "Q-Q plot des résidus - Modèle FF5",
    x = "Quantiles théoriques", y = "Quantiles observés"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h2_qq.pdf"), plot = p_qq, width = 8, height = 5)

# Histogram of FF5 residuals — density-scaled so a fitted normal curve can be overlaid.
# The normal curve uses the residual mean and sd to visually assess departure from normality.
resid_mean <- mean(resid_data$resid)
resid_sd <- sd(resid_data$resid)

p_hist <- ggplot(resid_data, aes(x = resid)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "#CC5500", alpha = 0.7, color = "white") +
  stat_function(fun = dnorm, args = list(mean = resid_mean, sd = resid_sd),
                color = "#17375E", linewidth = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#4D4D4D") +
  labs(
    title = "Histogramme des résidus - Modèle FF5",
    x = "Résidus", y = "Densité"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h2_histogram.pdf"), plot = p_hist, width = 8, height = 5)

cat("\n==== Récapitulatif H2 - Normalité ====\n")
cat(sprintf("Jarque-Bera : JB = %.3f, p = %.4e\n", jb_test$statistic, jb_test$p.value))
if (jb_test$p.value < 0.01) {
  cat("Décision (alpha = 0.01) : H0 REJETÉE - résidus non normaux.\n")
  cat("Interprétation : queues épaisses typiques des rendements financiers quotidiens.\n")
} else {
  cat("Décision (alpha = 0.01) : H0 NON rejetée - normalité non rejetée.\n")
}

# ---- 5. H3 — Homoskedasticity ---- # Voir p. 15
# H3 — Homoskedasticity: GQ, Glejser, BP, White — Section 6

# Goldfeld-Quandt test: H0 = variance is constant across the range of Mkt-RF.
# Data must be sorted by the suspected heteroskedastic variable before running gqtest().
# fraction = 0.25 matches professor's Ch.4-Application1 pattern.
ff5_sorted <- ff5_data[order(ff5_data$mkt_rf), ]
model_sorted <- lm(msft_excess ~ mkt_rf + smb + hml + rmw + cma, data = ff5_sorted)
gq_test <- gqtest(model_sorted, fraction = 0.25)

# Glejser test — manual auxiliary OLS (no dedicated R function exists).
# Regress |residuals| on all regressors: H0 = no relationship (homoskedastic).
glejser_model <- lm(abs(resid(model_ff5)) ~ mkt_rf + smb + hml + rmw + cma,
  data = ff5_data
)
glejser_f <- summary(glejser_model)$fstatistic
glejser_pval <- pf(glejser_f[1], glejser_f[2], glejser_f[3], lower.tail = FALSE)

# Breusch-Pagan test: H0 = homoskedasticity (linear relationship between variance and X).
bp_test <- bptest(model_ff5)

# White test: extends BP to include squared terms and all cross-products.
# For FF5 (5 regressors): 5 linear + 5 squared + C(5,2)=10 cross-products = 20 terms total.
white_formula <- ~ mkt_rf + smb + hml + rmw + cma +
  I(mkt_rf^2) + I(smb^2) + I(hml^2) + I(rmw^2) + I(cma^2) +
  I(mkt_rf * smb) + I(mkt_rf * hml) + I(mkt_rf * rmw) + I(mkt_rf * cma) +
  I(smb * hml) + I(smb * rmw) + I(smb * cma) +
  I(hml * rmw) + I(hml * cma) + I(rmw * cma)
white_test <- bptest(model_ff5, varformula = white_formula, data = ff5_data)

# Residuals vs fitted values — visual check for heteroskedastic variance patterns.
diag_data <- data.frame(fitted = fitted(model_ff5), resid = resid(model_ff5))
p_rvf <- ggplot(diag_data, aes(x = fitted, y = resid)) +
  geom_point(alpha = 0.3, color = "#CC5500") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#4D4D4D") +
  geom_smooth(method = "loess", se = FALSE, color = "#17375E") +
  labs(
    title = "Résidus vs valeurs ajustées - Modèle FF5",
    x = "Valeurs ajustées", y = "Résidus"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h3_resid_vs_fitted.pdf"), plot = p_rvf, width = 8, height = 5)

# Squared residuals vs fitted values — global pattern detection.
# A fan or funnel shape here confirms heteroskedasticity before pinpointing the source factor.
diag_data$resid2 <- resid(model_ff5)^2
p_r2_fitted <- ggplot(diag_data, aes(x = fitted, y = resid2)) +
  geom_point(alpha = 0.3, color = "#CC5500") +
  geom_smooth(method = "loess", se = FALSE, color = "#17375E") +
  labs(
    title = "Résidus² vs valeurs ajustées - Modèle FF5",
    x = "Valeurs ajustées (y-hat)", y = "Résidus²"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h3_resid2_vs_fitted.pdf"),
       plot = p_r2_fitted, width = 8, height = 5)

# Squared residuals vs each FF5 factor — identify which regressor drives variance.
# If the ŷ plot shows a pattern, these plots reveal which factor(s) are the source.
factor_labels <- c(
  mkt_rf = "Mkt-RF", smb = "SMB", hml = "HML", rmw = "RMW", cma = "CMA"
)
for (fac in factor_cols) {
  p_fac <- ggplot(
    data.frame(x = ff5_data[[fac]], resid2 = diag_data$resid2),
    aes(x = x, y = resid2)
  ) +
    geom_point(alpha = 0.3, color = "#CC5500") +
    geom_smooth(method = "loess", se = FALSE, color = "#17375E") +
    labs(
      title = sprintf("Résidus² vs %s - Modèle FF5", factor_labels[fac]),
      x = factor_labels[fac], y = "Résidus²"
    ) +
    theme_minimal()
  # Strip underscores from column name for filename (e.g. mkt_rf → mktrf).
  fac_fname <- gsub("_", "", fac)
  ggsave(
    file.path("outputs", "figures", sprintf("h3_resid2_vs_%s.pdf", fac_fname)),
    plot = p_fac, width = 8, height = 5
  )
}

cat("\n==== Récapitulatif H3 - Homoscédasticité ====\n")
cat(sprintf("Goldfeld-Quandt : F = %.3f,  p = %.4f\n", gq_test$statistic, gq_test$p.value))
cat(sprintf("Glejser         : F = %.3f,  p = %.4f\n", glejser_f[1], glejser_pval))
cat(sprintf("Breusch-Pagan   : BP = %.3f, p = %.4f\n", bp_test$statistic, bp_test$p.value))
cat(sprintf("White           : BP = %.3f, p = %.4f\n", white_test$statistic, white_test$p.value))
cat(sprintf("\nDécision (alpha = 0.01) : "))
# Reject if any test p < 0.01 — conservative approach flags any evidence of heteroskedasticity.
h3_reject <- any(c(gq_test$p.value, glejser_pval, bp_test$p.value, white_test$p.value) < 0.01)
if (h3_reject) {
  cat("H0 REJETÉE - hétéroscédasticité détectée.\n")
} else {
  cat("H0 NON rejetée - homoscédasticité non rejetée.\n")
}

# ---- 6. H4 — Autocorrelation ---- # Voir p. 17
# H4 — Autocorrelation: DW, BG, Ljung-Box — Section 6

# Durbin-Watson test: H0 = no first-order autocorrelation in residuals.
dw_test <- dwtest(model_ff5)

# Breusch-Godfrey test at orders 1, 2, and 4 — matches professor's Ch.4-Application2 pattern.
# More general than DW: handles higher-order autocorrelation and lagged regressors.
bg_test_1 <- bgtest(model_ff5, order = 1)
bg_test_2 <- bgtest(model_ff5, order = 2)
bg_test_4 <- bgtest(model_ff5, order = 4)

# Ljung-Box test: H0 = no autocorrelation up to lag k.
# CRITICAL: lag must be strictly greater than fitdf or Box.test() returns NaN p-value.
# For FF5 (k=5 regressors): lag=10 gives 5 effective degrees of freedom (10 - 5 = 5).
# For CAPM (k=1 regressor): lag=4, fitdf=1 (professor's Ch.4-App2 pattern).
# Professor's Ch.4-App2 uses lag=4 for a 1-regressor model (fitdf=2).
# lag=10 is the correct adaptation for FF5 — deviation is intentional and documented.
lb_test_ff5 <- Box.test(resid(model_ff5), lag = 10, type = "Ljung-Box", fitdf = 5)
lb_test_capm <- Box.test(resid(model_capm), lag = 4, type = "Ljung-Box", fitdf = 1)

# Residuals over time — visual scan for systematic patterns or structural breaks.
time_data <- data.frame(index = seq_len(nrow(ff5_data)), resid = resid(model_ff5))
p_time <- ggplot(time_data, aes(x = index, y = resid)) +
  geom_line(color = "#CC5500", alpha = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#4D4D4D") +
  labs(
    title = "Résidus au cours du temps - Modèle FF5",
    x = "Observation", y = "Résidus"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h4_resid_over_time.pdf"), plot = p_time, width = 8, height = 5)

# Resid(t) vs resid(t-1) scatter — slope near zero confirms absence of first-order autocorrelation.
n_obs <- length(resid(model_ff5))
lag_data <- data.frame(
  resid_t   = resid(model_ff5)[2:n_obs],
  resid_lag = resid(model_ff5)[1:(n_obs - 1)]
)
p_lag <- ggplot(lag_data, aes(x = resid_lag, y = resid_t)) +
  geom_point(alpha = 0.3, color = "#CC5500") +
  geom_smooth(method = "lm", se = FALSE, color = "#17375E") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#4D4D4D") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#4D4D4D") +
  labs(
    title = "Résidus(t) vs Résidus(t-1) - Modèle FF5",
    x = "Résidus(t-1)", y = "Résidus(t)"
  ) +
  theme_minimal()
ggsave(file.path("outputs", "figures", "h4_resid_lag.pdf"), plot = p_lag, width = 8, height = 5)

# ACF correlogram — base R acf() cannot use ggsave(); use pdf()/dev.off() for vector output.
pdf(file.path("outputs", "figures", "h4_acf.pdf"), width = 8, height = 5)
acf(resid(model_ff5),
  main = "Corrélogramme des résidus - Modèle FF5",
  col = "#CC5500", lwd = 2
)
dev.off()

cat("\n==== Récapitulatif H4 - Autocorrélation ====\n")
cat(sprintf("Durbin-Watson       : DW = %.4f, p = %.4f\n", dw_test$statistic, dw_test$p.value))
cat(sprintf("Breusch-Godfrey (1) : LM = %.3f, p = %.4f\n", bg_test_1$statistic, bg_test_1$p.value))
cat(sprintf("Breusch-Godfrey (2) : LM = %.3f, p = %.4f\n", bg_test_2$statistic, bg_test_2$p.value))
cat(sprintf("Breusch-Godfrey (4) : LM = %.3f, p = %.4f\n", bg_test_4$statistic, bg_test_4$p.value))
cat(sprintf("Ljung-Box (FF5)     : Q = %.3f, p = %.4f\n", lb_test_ff5$statistic, lb_test_ff5$p.value))
cat(sprintf("Ljung-Box (CAPM)    : Q = %.3f, p = %.4f\n", lb_test_capm$statistic, lb_test_capm$p.value))
h4_reject <- any(c(
  dw_test$p.value, bg_test_1$p.value, bg_test_2$p.value,
  bg_test_4$p.value, lb_test_ff5$p.value
) < 0.01)
cat(sprintf("\nDécision (alpha = 0.01) : "))
if (h4_reject) {
  cat("H0 REJETÉE - autocorrélation détectée.\n")
} else {
  cat("H0 NON rejetée - absence d'autocorrélation non rejetée.\n")
}

# ---- 7. H6 — Multicollinearity ---- # Voir p. 18
# H6 — Multicollinearity: VIF, Klein, Farrar-Glauber — Section 6

# Pairwise correlations between the five Fama-French factors reveal whether any two factors
# move together so strongly that OLS cannot separate their individual effects on MSFT returns.
cor_matrix <- cor(ff5_data[, factor_cols])

# corrplot cannot use ggsave() — use pdf()/dev.off() for vector output.
pdf(file.path("outputs", "figures", "h6_corrplot.pdf"), width = 7, height = 7)
corrplot(cor_matrix,
  method = "color", type = "upper", addCoef.col = "#4D4D4D",
  tl.col = "#17375E", number.cex = 0.8,
  title = "Matrice de corrélation - Facteurs FF5",
  mar = c(0, 0, 2, 0)
)
dev.off()

cat("\n==== Récapitulatif H6 - Multicolinéarité ====\n")

# VIF — variance inflation factors for each FF5 regressor.
# Rule of thumb: VIF > 10 = severe, VIF > 5 = moderate concern.
vif_values <- car::vif(model_ff5)
cat("\nVIF:\n"); print(round(vif_values, 4))

# Critère de Klein — R² of each auxiliary regression (one factor on the other four)
# compared to the overall FF5 model R². If R²_aux > R²_model, collinearity is problematic.
r2_ff5 <- summary(model_ff5)$r.squared
klein_r2 <- sapply(factor_cols, function(v) {
  other <- setdiff(factor_cols, v)
  summary(lm(as.formula(paste(v, "~", paste(other, collapse = " + "))), data = ff5_data))$r.squared
})
cat(sprintf("\nKlein - R² global FF5 = %.4f\n", r2_ff5))
cat("Critère de Klein (R² auxiliaire par facteur):\n")
print(round(klein_r2, 4))
cat(sprintf("Facteurs avec R²_aux > R²_global: %s\n",
    paste(names(klein_r2)[klein_r2 > r2_ff5], collapse = ", ")))

# Farrar-Glauber — chi-square test for overall multicollinearity.
# χ² = -[n - 1 - (2k+5)/6] × ln|det(R)| with df = k(k-1)/2.
k_fg   <- length(factor_cols)
n_fg   <- nrow(ff5_data)
fg_chi2 <- -(n_fg - 1 - (2 * k_fg + 5) / 6) * log(det(cor_matrix))
fg_df   <- k_fg * (k_fg - 1) / 2
fg_pval <- pchisq(fg_chi2, df = fg_df, lower.tail = FALSE)
cat(sprintf("\nFarrar-Glauber χ²(%.0f) = %.3f, p = %.4e\n", fg_df, fg_chi2, fg_pval))

# Export multicollinearity summary table (VIF + Klein) to Typst.
factor_labels_5 <- c("Mkt-RF", "SMB", "HML", "RMW", "CMA")
mc_df <- data.frame(
  Facteur            = factor_labels_5,
  VIF                = round(as.numeric(vif_values), 3),
  `R² auxiliaire`    = round(klein_r2, 4),
  `Klein OK`         = ifelse(klein_r2 > r2_ff5, "Non", "Oui"),
  check.names        = FALSE
)

tt(mc_df, digits = 4) |>
  save_tt(file.path("outputs", "tables", "h6_multicollinearity.typ"), overwrite = TRUE)

# ---- 8. H1, H5, H7, H8 — Qualitative discussion (comments only) ----

# H1 — Linearity: The FF5 model is linear by specification (OLS). Residuals vs fitted
#       plot (section 5) provides visual confirmation. No formal test per professor's approach.

# H5 — No perfect multicollinearity: R would drop collinear variables automatically.
#       All 5 regressors retained in lm() output → no perfect multicollinearity.
#       Approximate multicollinearity assessed via correlation matrix (section 7).

# H7 — Exogeneity: FF5 factors are constructed from independent portfolios by Fama-French.
#       They are predetermined relative to individual stock returns. Exogeneity assumed
#       by model specification (standard in asset pricing literature).

# H8 — Correct specification: The FF5 model is the standard specification in asset pricing.
#       RESET test is not in professor's course. The improvement in Adj. R² from CAPM to FF5
#       (section 2) supports the relevance of additional factors.

# ---- 9. Corrections ---- # Voir p. 20
# Corrections for H3 and H4 — Section 7
# Corrections shown for pedagogical completeness. Diagnostic tests (sections 5-6)
# determine whether violations were actually detected.

# --- H3 Corrections (heteroskedasticity) ---

# MCP: Weighted Least Squares — assumed variance proportional to |Mkt-RF|.
# The + 1e-8 prevents division by zero on days where mkt_rf = 0.
model_mcp <- lm(msft_excess ~ mkt_rf + smb + hml + rmw + cma,
  data = ff5_data,
  weights = 1 / (abs(ff5_data$mkt_rf) + 1e-8)
)

# MCGF: Feasible GLS — estimate h(X) from auxiliary log-variance regression.
# Step 1: regress log(residuals²) on all regressors to model the variance function.
# Step 2: exponentiate fitted values to recover h_hat as WLS weights.
log_resid2 <- log(resid(model_ff5)^2)
model_aux <- lm(log_resid2 ~ mkt_rf + smb + hml + rmw + cma, data = ff5_data)
h_hat <- exp(fitted(model_aux))
model_mcgf <- lm(msft_excess ~ mkt_rf + smb + hml + rmw + cma,
  data = ff5_data,
  weights = 1 / h_hat
)

# White robust: HC1 sandwich standard errors — corrects SEs without refitting the model.
# Applies the degrees-of-freedom correction factor n/(n-k) preferred for smaller samples.
vcov_white <- vcovHC(model_ff5, type = "HC1")

# H3 comparison table: MCO vs MCP vs MCGF vs White robust.
# vcov= list supplies the appropriate covariance matrix for each column's SE computation.
liste_modeles_h3 <- list(
  "MCO"             = model_ff5,
  "MCP"             = model_mcp,
  "MCGF"            = model_mcgf,
  "White (robuste)" = model_ff5
)
vcov_liste_h3 <- list(
  "MCO"             = vcov(model_ff5),
  "MCP"             = vcov(model_mcp),
  "MCGF"            = vcov(model_mcgf),
  "White (robuste)" = vcov_white
)
modelsummary(liste_modeles_h3,
  vcov = vcov_liste_h3,
  output = file.path("outputs", "tables", "h3_corrections.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1), fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

# --- H4 Corrections (autocorrelation) ---

# Prais-Winsten: corrects AR(1) autocorrelation via quasi-differencing.
# CRITICAL: prais_winsten() objects are NOT compatible with modelsummary.
# Workaround: extract rho, manually build quasi-differenced variables, run lm().

# Step 1: Run Prais-Winsten to obtain the final AR(1) coefficient rho.
ff5_data$t <- seq_len(nrow(ff5_data))
model_pw <- prais_winsten(msft_excess ~ mkt_rf + smb + hml + rmw + cma,
  data = ff5_data, index = "t"
)
rho_final <- as.numeric(tail(model_pw$rho, 1))
T_obs <- nrow(ff5_data)


# Step 2: Build quasi-differenced data manually using the Prais-Winsten transformation.
# First observation uses sqrt(1 - rho²) scaling; remaining observations use (y_t - rho*y_{t-1}).
fac_cols <- c("mkt_rf", "smb", "hml", "rmw", "cma")
y_star <- numeric(T_obs)
x_star <- matrix(NA, T_obs, 5)

# First observation: Prais-Winsten transformation preserves it with variance correction.
y_star[1] <- sqrt(1 - rho_final^2) * ff5_data$msft_excess[1]
x_star[1, ] <- sqrt(1 - rho_final^2) * as.numeric(ff5_data[1, fac_cols])

# Remaining observations: quasi-differencing removes the AR(1) component.
for (i in 2:T_obs) {
  y_star[i] <- ff5_data$msft_excess[i] - rho_final * ff5_data$msft_excess[i - 1]
  x_star[i, ] <- as.numeric(ff5_data[i, fac_cols]) -
    rho_final * as.numeric(ff5_data[i - 1, fac_cols])
}
colnames(x_star) <- paste0(fac_cols, "_star")
data_star <- as.data.frame(cbind(y_star = y_star, x_star))
model_pw_lm <- lm(y_star ~ ., data = data_star)

# Newey-West: HAC standard errors — corrects for both heteroskedasticity and autocorrelation.
# Bandwidth p = floor(4 * (T/100)^(2/9)) matches professor's Ch.4-Application2 formula.
p_nw <- floor(4 * (T_obs / 100)^(2 / 9))
vcov_nw <- NeweyWest(model_ff5, lag = p_nw, prewhite = FALSE)

# H4 comparison table: MCO vs Prais-Winsten vs Newey-West.
liste_modeles_h4 <- list(
  "MCO"           = model_ff5,
  "Prais-Winsten" = model_pw_lm,
  "Newey-West"    = model_ff5
)
vcov_liste_h4 <- list(
  "MCO"           = vcov(model_ff5),
  "Prais-Winsten" = vcov(model_pw_lm),
  "Newey-West"    = vcov_nw
)
modelsummary(liste_modeles_h4,
  vcov = vcov_liste_h4,
  output = file.path("outputs", "tables", "h4_corrections.typ"),
  stars = c("***" = 0.01, "**" = 0.05, "*" = 0.1), fmt = 4,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)
