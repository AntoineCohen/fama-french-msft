#pagebreak()
= Statistiques descriptives

#figure(
  include("../../outputs/tables/descriptive_stats.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Statistiques descriptives des variables du modèle FF5],
)

La variable dépendante, le rendement excédentaire quotidien de MSFT, présente sur
la période 2021–2025 une distribution caractéristique des séries de rendements
financiers en haute fréquence. La moyenne est positive, ce qui signifie que MSFT
a surperformé le taux sans risque en moyenne sur l'ensemble de la période. Cette
performance agrégée masque toutefois une hétérogénéité temporelle marquée : la
période d'étude inclut la forte correction boursière du secteur technologique de
2022, consécutive au resserrement monétaire de la Réserve fédérale américaine,
suivie d'un rebond soutenu en 2023–2024 porté par l'essor de l'intelligence
artificielle, dont Microsoft est un acteur central via ses investissements dans
OpenAI et l'intégration de Copilot dans ses produits. L'amplitude de variation
est donc élevée, avec des observations extrêmes dans les deux sens correspondant
à des annonces de résultats trimestriels et à des événements de marché majeurs.

La distribution des rendements excédentaires quotidiens de MSFT présente des queues
épaisses, phénomène bien documenté pour les séries de rendements financiers à haute
fréquence. Cette caractéristique se manifeste par une kurtosis excédentaire positive,
indiquant que les événements extrêmes sont plus fréquents que ce que prédirait une
distribution normale. Ce constat est cohérent avec la littérature empirique sur les
rendements boursiers quotidiens et sera examiné formellement dans la section 6
(vérification de l'hypothèse de normalité des résidus), où le test de Jarque-Bera
et le graphique quantile-quantile permettront d'évaluer l'écart à la normalité.

Les cinq facteurs Fama-French présentent des distributions également centrées proche
de zéro, conformément à leurs définitions comme différences de rendements de
portefeuilles construits selon des critères de taille, de valorisation, de rentabilité
et d'investissement. Le facteur de marché Mkt-RF affiche la variance la plus élevée
parmi les cinq facteurs, ce qui reflète l'exposition aux fluctuations générales
du marché boursier américain. Les facteurs SMB et HML présentent des ordres de
grandeur inférieurs à Mkt-RF, tandis que RMW et CMA, construits sur des
caractéristiques fondamentales plus stables, tendent à afficher une volatilité
encore plus modérée. L'ensemble de ces facteurs est exprimé en rendements
quotidiens décimaux après conversion depuis l'échelle en pourcentage fournie
par la bibliothèque de Kenneth French.
