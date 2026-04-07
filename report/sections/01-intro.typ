#pagebreak()
= Introduction et hypothèses de travail

Les modèles d'évaluation des actifs financiers constituent un enjeu central de la
finance empirique depuis les années 1960. Le modèle d'évaluation des actifs financiers
(CAPM), introduit par Sharpe (1964) et Lintner (1965), postule qu'une seule source
de risque systématique, l'exposition au portefeuille de marché, suffit à expliquer
la prime de rendement attendue d'un actif. Or, des anomalies empiriques persistantes
ont mis en évidence que le CAPM sous-explicite une partie non négligeable de la
variation des rendements boursiers. En réponse, Fama et French (1993) proposent un
modèle à trois facteurs qui ajoute deux primes de risque supplémentaires au facteur
de marché (Mkt-RF) : la prime de taille (SMB, Small Minus Big), qui capture l'écart
de rendement entre les petites et les grandes capitalisations, et la prime de valeur
(HML, High Minus Low), qui reflète l'écart entre les titres à fort et à faible ratio
book-to-market. Ce modèle constitue une référence incontournable de la littérature
en finance empirique, dont il améliore sensiblement le pouvoir explicatif par rapport
au CAPM original.

Face à des anomalies résiduelles que le modèle à trois facteurs ne parvient pas à
capter, notamment la sous-performance des entreprises peu rentables et des
entreprises à investissement agressif, Fama et French (2015) étendent leur
spécification à cinq facteurs. Deux variables supplémentaires complètent le modèle :
le facteur de rentabilité (RMW, Robust Minus Weak), qui mesure l'écart de rendement
entre les firmes à rentabilité opérationnelle élevée et celles à rentabilité faible,
et le facteur d'investissement (CMA, Conservative Minus Aggressive), qui capture
l'écart entre les entreprises à politique d'investissement prudente et celles à
politique agressive. La motivation principale avancée par les auteurs est
l'amélioration de la valorisation des petites capitalisations, dont le CAPM et le
modèle à trois facteurs rendent imparfaitement compte. Le modèle FF5 constitue
aujourd'hui l'une des références les plus utilisées en finance empirique pour
décomposer les sources de risque systématique.

== Motivation économique

Microsoft Corporation (MSFT) représente un cas d'étude particulièrement pertinent
pour l'application du modèle FF5. Depuis 2022, le partenariat stratégique avec
OpenAI et l'intégration de l'intelligence artificielle dans l'ensemble de la suite
Copilot ont transformé le profil de croissance de l'entreprise, faisant de MSFT
l'une des valeurs centrales de la vague IA des méga-capitalisations technologiques.
Cette position confère à l'entreprise un profil financier distinctif au regard de
chacun des cinq facteurs du modèle.

En ce qui concerne le facteur de taille (SMB), Microsoft figure parmi les plus
grandes capitalisations mondiales : sa taille implique un chargement négatif attendu
sur ce facteur, les grandes capitalisations ayant historiquement des rendements
inférieurs aux petites. Pour le facteur de valeur (HML), MSFT est un titre de
croissance, dont la valorisation repose essentiellement sur des flux futurs plutôt
que sur des actifs nets, ce qui se traduit par un faible ratio book-to-market et un
chargement négatif attendu. Le facteur de rentabilité (RMW) joue en sens inverse :
les marges opérationnelles de Microsoft comptent parmi les plus élevées du secteur
technologique, ce qui laisse anticiper un chargement positif sur ce facteur. Enfin,
le facteur d'investissement (CMA) devrait être négatif, reflétant la stratégie
d'investissement agressive de l'entreprise, notamment les dépenses massives en
recherche-développement et en infrastructure d'intelligence artificielle.

== Hypothèses de travail

Ces caractéristiques permettent de formuler cinq hypothèses de travail testables,
présentées dans le tableau ci-dessous.

#figure(
  include("../../outputs/tables/hypotheses.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Hypothèses de travail sur les chargements factoriels de MSFT],
)

Le présent travail applique le modèle de Fama et French (2015) aux rendements
quotidiens de Microsoft Corporation (MSFT), sur la période du 5 janvier 2021 au
30 décembre 2025. La question de recherche est la suivante : le modèle de Fama et
French à cinq facteurs explique-t-il mieux les rendements excédentaires de MSFT que
le CAPM, et les chargements factoriels sont-ils cohérents avec le profil financier
connu de l'entreprise ?
