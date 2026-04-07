#pagebreak()
= Résultats économétriques

== Étape 1 : Modèle CAPM

Le modèle CAPM constitue la référence de départ. L'estimation MCO sur la période
2021–2025 (T = 1 253 observations journalières) donne un coefficient de marché
(Mkt-RF) de 1,082, confirmant l'hypothèse H1 : MSFT amplifie légèrement les
variations du marché en tant que valeur technologique de croissance. L'intercept
alpha est positif mais non significatif, résultat cohérent avec l'hypothèse
d'efficience des marchés. Le R² ajusté s'établit à 0,557 : le seul facteur de
marché explique environ 56 % de la variance des rendements excédentaires de MSFT.

#figure(
  include("../../outputs/tables/capm_msft.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Résultats de l'estimation CAPM pour MSFT],
)

== Étape 2 : Modèle Fama-French à trois facteurs

L'extension au modèle FF3 introduit les facteurs SMB et HML en complément du
facteur de marché. Le R² ajusté progresse à 0,663, soit un gain de 10,6 points
de pourcentage par rapport au CAPM. Le coefficient SMB est négatif (−0,445),
confirmant l'hypothèse H2 : en tant que méga-capitalisation, MSFT est exposée à
l'opposé du portefeuille petites capitalisations. Le coefficient HML est également
négatif (−0,375), confirmant l'hypothèse H3 : MSFT présente un profil de
croissance avec un faible ratio book-to-market.

#figure(
  include("../../outputs/tables/ff3_msft.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Résultats de l'estimation FF3 pour MSFT],
)

== Étape 3 : Modèle Fama-French à cinq facteurs

L'extension au modèle FF5 ajoute les facteurs RMW (rentabilité) et CMA
(investissement). Le R² ajusté atteint 0,679, soit un gain total de 12,16 points
de pourcentage par rapport au CAPM. Les coefficients s'interprètent
économiquement comme suit, chacun confirmant une hypothèse de travail :

- *Mkt-RF* (β = 1,041) : confirmant l'hypothèse H1, MSFT présente un risque
  systématique légèrement supérieur au marché, ce qui est cohérent avec son statut
  de valeur technologique de croissance sensible aux cycles d'innovation.
- *SMB* (β = −0,322) : confirmant l'hypothèse H2, l'exposition aux grandes
  capitalisations est confirmée : en tant qu'une des premières capitalisations
  mondiales, MSFT évolue à l'opposé du portefeuille petites capitalisations.
- *HML* (β = −0,379) : confirmant l'hypothèse H3, le profil de valeur de
  croissance est attesté par ce coefficient négatif, reflet d'un faible ratio
  book-to-market et d'une valorisation fondée sur les flux futurs anticipés.
- *RMW* (β = +0,330) : confirmant l'hypothèse H4, ce coefficient positif est
  cohérent avec les marges opérationnelles soutenues de Microsoft, parmi les plus
  élevées du secteur technologique.
- *CMA* (β = −0,265) : confirmant l'hypothèse H5, la stratégie d'investissement
  agressive de MSFT (dépenses massives en R&D et en infrastructure d'intelligence
  artificielle) se traduit par un chargement négatif sur ce facteur.

L'intercept alpha n'est pas significatif (p = 0,76), résultat cohérent avec
l'hypothèse d'efficience des marchés : MSFT ne génère pas de rendements anormaux
significatifs au-delà de son exposition aux cinq facteurs.

#figure(
  include("../../outputs/tables/ff5_msft.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Résultats de l'estimation FF5 pour MSFT],
)

== Comparaison des modèles

Le tableau ci-dessous synthétise la progression du pouvoir explicatif à chaque
étape : CAPM (R² ajusté = 0,557), FF3 (0,663), FF5 (0,679). Le passage du CAPM
au FF3 apporte la plus grande part du gain (+10,6 pp), les facteurs SMB et HML
révélant une partie substantielle du risque systématique non capturée par le seul
facteur de marché. L'ajout de RMW et CMA dans le FF5 apporte un gain additionnel
de 1,6 pp, qui, bien que plus modeste, confirme la pertinence des facteurs de
rentabilité et d'investissement pour l'évaluation de MSFT. Pour autant, environ
32 % de la variance des rendements demeure inexpliquée par le modèle FF5 : cette
fraction résiduelle reflète le risque idiosyncratique propre à l'entreprise et
est cohérente avec l'hypothèse d'efficience de marché.

#figure(
  include("../../outputs/tables/capm_ff5_comparison.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Comparaison des modèles CAPM, FF3 et FF5 pour MSFT],
)

== Comparaison entre pairs technologiques

À titre de contextualisation, le modèle FF5 est également estimé pour trois
entreprises technologiques comparables : Apple (AAPL), Alphabet (GOOGL) et Meta
(META). Cette comparaison ne constitue pas une analyse parallèle complète (aucun
diagnostic de Gauss-Markov n'est répété pour les pairs), mais permet de situer le
profil factoriel de MSFT dans son secteur. Les différences de coefficients entre
entreprises reflètent des positionnements distincts : une profitabilité plus ou moins
élevée selon le facteur RMW, une intensité d'investissement variable selon CMA, et
des profils de valorisation différents selon HML. Ces variations illustrent que le
modèle FF5 capture des caractéristiques économiques spécifiques à chaque firme, et
non un facteur sectoriel uniforme.

#figure(
  include("../../outputs/tables/peers_ff5.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Estimation FF5 pour MSFT et pairs technologiques],
)
