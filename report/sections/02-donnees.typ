#pagebreak()
= Données et variables

== Source et couverture temporelle

Les cours journaliers ajustés de Microsoft (MSFT), Apple (AAPL), Alphabet (GOOGL)
et Meta Platforms (META) sont téléchargés depuis Yahoo Finance via la bibliothèque
Python yfinance (paramètre `auto_adjust=True`), ce qui garantit une correction
automatique pour les divisions d'actions et les versements de dividendes. Les
facteurs Fama-French à cinq facteurs en fréquence quotidienne sont extraits de la
bibliothèque de données de Kenneth French (Ken French Data Library), puis convertis
de l'échelle en pourcentage vers l'échelle décimale avant la fusion. La période
d'observation s'étend du 5 janvier 2021 au 30 décembre 2025. Les données sont
restreintes aux séances de bourse effectives par une fusion interne (inner join)
sur l'index de dates, ce qui garantit l'absence de valeurs manquantes et une
cohérence temporelle parfaite entre les variables. L'échantillon final comprend
T = 1 253 observations quotidiennes.

== Variables

La variable dépendante est le rendement excédentaire quotidien de MSFT
(msft_excess), défini comme le rendement logarithmique de MSFT diminué du taux
sans risque journalier (Rf) fourni par la bibliothèque de Kenneth French. Le
rendement logarithmique est calculé selon la transformation r#sub[t] = ln(P#sub[t] /
P#sub[t-1]), où P#sub[t] désigne le cours de clôture ajusté à la date t. Les cinq
facteurs Fama-French constituent les variables explicatives : le facteur de marché
(mkt_rf), la prime de taille (smb), la prime de valeur (hml), la rentabilité (rmw)
et l'investissement (cma). Pour l'analyse comparative des entreprises pairs, les
rendements excédentaires d'Apple (aapl_excess), Alphabet (googl_excess) et Meta
(meta_excess) sont construits selon la même procédure.

== Traitement des données

La fréquence quotidienne a été retenue délibérément : avec T = 1 253 observations,
l'échantillon dépasse largement le seuil minimal requis pour que les propriétés
asymptotiques des estimateurs MCO soient valides. La fusion interne sur les dates
de cotation assure qu'aucune observation ne comporte de valeur manquante, qu'il
s'agisse d'un jour férié américain absent de l'un des fichiers ou d'une incohérence
de calendrier entre Yahoo Finance et la bibliothèque de Kenneth French. Aucune
imputation ni interpolation n'a été pratiquée.
