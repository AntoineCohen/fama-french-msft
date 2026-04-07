#import "template/elsearticle.typ": *

#show: elsearticle.with(
  title: [Modèle de Fama-French à cinq facteurs sur Microsoft : \ estimation MCO, diagnostics et corrections économétriques],
  authors: (
    (name: [Antoine C.], affiliations: ("a",)),
    (name: [Noah D.-G.], affiliations: ("a",)),
  ),
  affiliations: (
    "a": [Licence 3 Économie-Finance, Université Catholique de Lille],
  ),
  abstract: [
    Ce projet applique le modèle de Fama-French à cinq facteurs aux rendements
    journaliers excédentaires de Microsoft (MSFT) sur la période janvier 2021 –
    décembre 2025 (T = 1 253 observations). L'estimation par les moindres carrés
    ordinaires produit un R² ajusté de 0,679, soit un gain de 12,16 points de
    pourcentage par rapport au CAPM. Aucun coefficient alpha significatif n'est
    détecté (p = 0,76), résultat cohérent avec l'hypothèse d'efficience des
    marchés. Les diagnostics de Gauss-Markov confirment la validité des estimateurs
    MCO, à l'exception de la normalité des résidus, traitée par le théorème
    central limite.
  ],
  keywords: ("Fama-French", "CAPM", "MSFT", "Gauss-Markov", "MCO"),
  date: datetime(year: 2026, month: 4, day: 1),
  format: "preprint",
  paper: "a4",
)

#set text(lang: "fr")

// Caption : "Tableau 1. – Titre" / "Fig. 1. – Titre"
#show figure.caption: it => context [
  #it.supplement #it.counter.display(it.numbering). – #it.body
]
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: table): set figure(supplement: "Tableau")
#show figure.where(kind: image): set figure(supplement: "Fig.")
#set figure(placement: none)

#outline(title: [Sommaire])
#outline(title: [Liste des tableaux], target: figure.where(kind: table))
#outline(title: [Liste des figures], target: figure.where(kind: image))

#include "sections/01-intro.typ"
#include "sections/02-donnees.typ"
#include "sections/03-descriptives.typ"
#include "sections/04-modele.typ"
#include "sections/05-resultats.typ"
#include "sections/06-diagnostics.typ"
#include "sections/07-corrections.typ"
#include "sections/conclusion.typ"
#include "sections/appendice.typ"
