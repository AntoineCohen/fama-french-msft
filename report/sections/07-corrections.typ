#pagebreak()
= Corrections

Les corrections suivantes sont présentées à titre pédagogique. Les tests diagnostiques n'ayant pas détecté de violation significative à α = 0,01, les estimations MCO demeurent les estimateurs BLUE dans ce cadre.

== Corrections pour H3 : Hétéroscédasticité

Quatre estimateurs sont comparés pour illustrer les effets d'une éventuelle correction de l'hétéroscédasticité :

- *MCO (référence)* : estimateur de base présenté pour comparaison, sans correction de l'hétéroscédasticité.
- *MCP (Moindres Carrés Pondérés)* : correction par pondération supposant une variance proportionnelle à la valeur absolue du facteur de marché |Mkt-RF|, de sorte que les observations à forte volatilité reçoivent un poids plus faible.
- *MCGF (Moindres Carrés Généralisés Faisables)* : correction par estimation de la fonction de variance via une régression auxiliaire du logarithme des résidus au carré sur les régresseurs, permettant d'estimer h(X) et de pondérer en conséquence.
- *White robuste* : correction des écarts-types par l'estimateur sandwich HC1 sans refittage du modèle ; les coefficients MCO sont inchangés, seules les erreurs standard sont ajustées.

#figure(
  include("../../outputs/tables/h3_corrections.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Comparaison des estimateurs avec corrections pour l'hétéroscédasticité],
)

== Corrections pour H4 : Autocorrélation

Trois estimateurs sont comparés pour illustrer les effets d'une éventuelle correction de l'autocorrélation :

- *MCO (référence)* : estimateur de base présenté pour comparaison, sans correction de l'autocorrélation.
- *Prais-Winsten* : quasi-différenciation AR(1) qui transforme le modèle pour éliminer l'autocorrélation du premier ordre ; la première observation est préservée par la transformation #math.sqrt[1 − ρ²] pour éviter la perte d'une observation.
- *Newey-West* : écarts-types HAC (hétéroscédasticité et autocorrélation robustes) sans refittage ; la bande passante retenue est p = ⌊4 · (T/100)^(2/9)⌋ conformément à la formule du cours.

#figure(
  include("../../outputs/tables/h4_corrections.typ"),
  kind: table,
  supplement: "Tableau",
  caption: [Comparaison des estimateurs avec corrections pour l'autocorrélation],
)
