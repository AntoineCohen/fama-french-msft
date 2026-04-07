#pagebreak()
= Vérification des hypothèses de Gauss-Markov

Le seuil de signification retenu est $alpha = 0,01$ (T = 1 253 observations). Les diagnostics portent sur le modèle FF5.

== H1 : Linéarité

Le modèle FF5 est linéaire par construction. Le graphique résidus-valeurs ajustées (H3) ne révèle aucune courbure systématique. *H1 satisfaite.*

== H2 : Normalité des résidus

Test de Jarque-Bera : JB = 6 406,33, p ≈ 0. *H2 rejetée* à $alpha = 0,01$. Les queues épaisses sont caractéristiques des rendements financiers journaliers. Pour T = 1 253, le théorème central limite garantit la normalité asymptotique des estimateurs ; l'inférence demeure valide.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../../outputs/figures/h2_qq.pdf"),
    image("../../outputs/figures/h2_histogram.pdf"),
  ),
  caption: [Q-Q plot et histogramme des résidus du modèle FF5],
)

== H3 : Homoscédasticité

Goldfeld-Quandt, Glejser, Breusch-Pagan et White : aucun test ne rejette $H_0$ à $alpha = 0,01$. *H3 non rejetée.*

Le graphique des résidus² contre les valeurs ajustées ($hat(y)$) ne révèle aucune structure en éventail ou en entonnoir : la variance conditionnelle est stable sur toute l'étendue des $hat(y)$. En l'absence de patron global, l'examen facteur par facteur confirme qu'aucun régresseur (Mkt-RF, SMB, HML, RMW, CMA) ne fait croître la dispersion des résidus².

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../../outputs/figures/h3_resid_vs_fitted.pdf"),
    image("../../outputs/figures/h3_resid2_vs_fitted.pdf"),
  ),
  caption: [Résidus vs valeurs ajustées (gauche) et résidus² vs valeurs ajustées (droite)],
)

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../../outputs/figures/h3_resid2_vs_mktrf.pdf"),
    image("../../outputs/figures/h3_resid2_vs_smb.pdf"),
    image("../../outputs/figures/h3_resid2_vs_hml.pdf"),
    image("../../outputs/figures/h3_resid2_vs_rmw.pdf"),
  ),
  caption: [Résidus² par facteur : Mkt-RF, SMB, HML, RMW],
)

#figure(
  image("../../outputs/figures/h3_resid2_vs_cma.pdf", width: 50%),
  caption: [Résidus² vs CMA],
)

== H4 : Absence d'autocorrélation

Durbin-Watson, Breusch-Godfrey et Ljung-Box : aucun test ne rejette $H_0$ à $alpha = 0,01$. *H4 non rejetée.*

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../../outputs/figures/h4_resid_over_time.pdf"),
    image("../../outputs/figures/h4_resid_lag.pdf"),
  ),
  caption: [Résidus dans le temps et résidus(t) vs résidus(t-1)],
)

#figure(
  image("../../outputs/figures/h4_acf.pdf", width: 60%),
  caption: [Fonction d'autocorrélation des résidus],
)

== H5 : Absence de multicolinéarité parfaite

Les cinq régresseurs sont retenus dans la sortie `lm()` sans élimination automatique. *H5 satisfaite par construction.*

== H6 : Multicolinéarité approximative

Trois approches complémentaires permettent d'évaluer la multicolinéarité approximative entre les cinq facteurs.

Le *test de Farrar-Glauber* (test du $chi^2$ sur le déterminant de la matrice de corrélation $R$ des régresseurs) teste globalement l'orthogonalité de $X$. La statistique $chi^2 = -[n - 1 - (2k+5)/6] ln|R|$ suit un $chi^2$ à $k(k-1)/2$ degrés de liberté sous $H_0$. Ici $chi^2(10) = 1546,4$, $p approx 0$ : $H_0$ est rejetée, indiquant une structure de corrélation non nulle entre facteurs. Ce rejet s'explique principalement par la grande taille de l'échantillon (T = 1 253) : avec un tel nombre d'observations, des corrélations faibles deviennent statistiquement significatives même en l'absence de problème pratique.

Le *facteur d'inflation de la variance* (VIF) mesure, pour chaque régresseur $X_j$, l'augmentation de la variance de $hat(beta)_j$ due à la corrélation avec les autres facteurs : $"VIF"_j = 1/(1-R_j^2)$. Un VIF inférieur à 5 est généralement considéré acceptable. Tous les VIF sont inférieurs à 2,1 (maximum : HML = 2,04).

Le *critère de Klein* compare le $R^2$ de chaque régression auxiliaire ($X_j$ régressé sur les quatre autres facteurs) au $R^2$ global du modèle FF5 ($R^2 = 0,680$). Si $R^2_"aux" > R^2_"FF5"$, la multicolinéarité est susceptible de biaiser l'estimation. Le $R^2$ auxiliaire maximal est celui de HML (0,510), nettement inférieur à 0,680. Aucun facteur ne satisfait le critère de Klein. Le tableau ci-dessous récapitule les résultats.

#figure(
  include("../../outputs/tables/h6_multicollinearity.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [VIF et critère de Klein pour les facteurs FF5],
)

La matrice de corrélation confirme visuellement l'absence de colinéarité forte : aucun coefficient inter-facteurs n'excède 0,7 en valeur absolue. *H6 non rejetée.*

#figure(
  image("../../outputs/figures/h6_corrplot.pdf", width: 80%),
  caption: [Matrice de corrélation des facteurs FF5],
)

== H7 : Exogénéité

Les facteurs FF5 sont construits à partir de portefeuilles indépendants des rendements de MSFT. *H7 satisfaite par la spécification du modèle.*

== H8 : Spécification correcte

Le modèle FF5 est la référence de Fama et French (2015). Le gain de R² ajusté (0,557 à 0,679) confirme la pertinence des cinq facteurs. *H8 satisfaite.*
