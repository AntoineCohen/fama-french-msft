#pagebreak()
= Annexes

Le code source complet est fourni dans le fichier `src/analysis.R` joint à la soumission.
Chaque section du script comporte un commentaire `# Voir p.X` renvoyant aux pages du présent rapport.
Le tableau ci-dessous indique la correspondance entre les sections du rapport et les blocs du script.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, center),
    table.header([*Section du rapport*], [*Bloc du script*], [*Lignes*]),
    [Statistiques descriptives],        [`# ---- 0b. Descriptive statistics table ----`], [30–66],
    [Table des hypothèses],             [`# ---- 0c. Hypotheses table ----`],             [67–93],
    [Table des variables FF5],          [`# ---- 0d. FF5 variables table ----`],           [94–123],
    [Résultats — CAPM],                 [`# ---- 1. CAPM regression ----`],               [124–136],
    [Résultats — FF3],                  [`# ---- 1b. FF3 regression ----`],               [137–155],
    [Résultats — FF5],                  [`# ---- 2. FF5 regression ----`],                [156–204],
    [Comparaison entre pairs],          [`# ---- 3. Peer comparison ----`],               [205–221],
    [H2 — Normalité],                   [`# ---- 4. H2 — Normality ----`],                [222–267],
    [H3 — Homoscédasticité],            [`# ---- 5. H3 — Homoskedasticity ----`],         [268–363],
    [H4 — Autocorrélation],             [`# ---- 6. H4 — Autocorrelation ----`],          [364–440],
    [H6 — Multicolinéarité],            [`# ---- 7. H6 — Multicollinearity ----`],        [441–516],
    [Corrections H3 et H4],             [`# ---- 9. Corrections ----`],                   [517–623],
  ),
  kind: table,
  supplement: "Tableau",
  caption: [Correspondance sections du rapport — blocs du script `src/analysis.R`],
)
