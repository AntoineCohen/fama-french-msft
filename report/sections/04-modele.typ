#pagebreak()
= Modèle et méthode d'estimation

== Modèle CAPM (référence)

Le modèle d'évaluation des actifs financiers (CAPM) constitue le point de départ
naturel de l'analyse. Dans ce cadre, le rendement excédentaire de MSFT est supposé
être une fonction linéaire du rendement excédentaire du marché, augmentée d'un terme
d'erreur.

$ R_(i,t) - R_(f,t) = alpha_i + beta_"mkt" (R_(m,t) - R_(f,t)) + epsilon_(i,t) $

où $R_(i,t) - R_(f,t)$ est le rendement excédentaire de MSFT, $R_(m,t) - R_(f,t)$ le
rendement excédentaire du portefeuille de marché (Mkt-RF), $alpha_i$ l'intercept
(rendement anormal), $beta_"mkt"$ la sensibilité au risque de marché, et
$epsilon_(i,t)$ le terme d'erreur. Un alpha significativement positif indiquerait que
MSFT génère des rendements supérieurs à ce que son exposition au risque de marché
prédit, ce qui serait interprété comme une sur-performance relative au CAPM.

== Modèle Fama-French à trois facteurs

Fama et French (1993) étendent le CAPM en ajoutant deux primes de risque
supplémentaires : la prime de taille (SMB) et la prime de valeur (HML). Cette
spécification intermédiaire constitue une étape analytique importante avant
l'introduction du modèle complet à cinq facteurs.

$ R_(i,t) - R_(f,t) = alpha_i + beta_"mkt" (R_(m,t) - R_(f,t)) + beta_"smb" "SMB"_t + beta_"hml" "HML"_t + epsilon_(i,t) $

Le facteur SMB (Small Minus Big) mesure l'écart de rendement entre les portefeuilles
de petites et de grandes capitalisations. Le facteur HML (High Minus Low) capte
l'écart entre les titres à fort et à faible ratio book-to-market. Pour MSFT, grande
capitalisation à profil de croissance, les chargements attendus sur ces deux facteurs
sont négatifs (H2 et H3).

== Modèle Fama-French à cinq facteurs

Fama et French (2015) étendent leur modèle en ajoutant deux facteurs supplémentaires
pour capter les anomalies liées à la rentabilité et à la politique d'investissement.

$ R_(i,t) - R_(f,t) = alpha_i + beta_"mkt" (R_(m,t) - R_(f,t)) + beta_"smb" "SMB"_t + beta_"hml" "HML"_t + beta_"rmw" "RMW"_t + beta_"cma" "CMA"_t + epsilon_(i,t) $

#figure(
  include("../../outputs/tables/variables_ff5.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Variables du modèle FF5],
)

L'intercept du modèle FF5 s'interprète comme le rendement anormal résiduel, après
avoir contrôlé pour l'ensemble des cinq sources de risque systématique. Les
résultats de l'estimation FF5 et la comparaison avec le CAPM sont présentés en
section 5.

== Méthode d'estimation

Les trois modèles (CAPM, FF3, FF5) sont estimés par la méthode des moindres carrés
ordinaires (MCO). Le recours aux MCO est justifié par plusieurs arguments. D'abord,
la relation entre le rendement excédentaire de MSFT et les facteurs Fama-French est
spécifiée comme linéaire, conformément à la littérature théorique et empirique.
Ensuite, les facteurs Fama-French sont construits à partir de portefeuilles
indépendants des rendements de MSFT, ce qui assure leur prédétermination et fonde
l'hypothèse d'exogénéité des régresseurs. Enfin, la taille de l'échantillon
(T = 1 253 observations) est suffisante pour s'appuyer sur les propriétés
asymptotiques des estimateurs MCO, notamment la normalité asymptotique des
coefficients par le théorème central limite, indépendamment de la distribution exacte
des termes d'erreur. La validité de l'estimateur MCO repose sur la vérification des
hypothèses de Gauss-Markov, qui font l'objet d'un examen systématique en section 6.

Afin de rendre comparables les effets marginaux des facteurs, dont les échelles
diffèrent, des effets marginaux semi-standardisés sont calculés pour le modèle FF5.
Ces effets, obtenus en multipliant chaque coefficient estimé par l'écart-type de
son facteur, expriment l'impact d'une variation d'un écart-type de chaque facteur
sur le rendement excédentaire de MSFT. Ce traitement permet d'identifier les
facteurs dont l'effet économique est le plus prononcé, au-delà des différences
d'échelle entre les variables.

Le seuil de significativité retenu pour l'ensemble des tests est alpha = 0,01,
conformément à la convention du cours, adaptée à la taille d'échantillon de
n ≈ 1 250 observations.
