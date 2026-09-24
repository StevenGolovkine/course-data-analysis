#import "../styles/slides.typ": *

#show : course-slides.with(title: [Analyse de données])

#title-slide()

== Plan du cours

#grid(
  columns: (1fr, 1fr),
  gutter: 0.85em,
  card([1 · Partir d'une question], [
    Unités statistiques, variables, données et types de questions.
  ], height: 1.46in),
  card([2 · Apprentissage supervisé], [
    Régression, classification, généralisation et évaluation.
  ], fill: pale-blue, height: 1.46in),
  card([3 · Apprentissage non supervisé], [
    Réduction de dimension, regroupement et interprétation.
  ], fill: pale-purple, height: 1.46in),
  card([4 · Modéliser], [
    Démarche d'analyse, validation, limites et biais.
  ], fill: pale-orange, height: 1.46in),
)

#pause
#v(0.8em)
#takeaway([
  question → données → représentation → méthode → décision
])

= Partir d'une question

== Qu'est-ce que l'analyse de données?

#takeaway([Extraire de l'information d'un jeu de données.])

#pause

#v(0.7em)

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.5em,
  align: horizon,
  card([Observer], [Mesurer des variables sur des unités statistiques.], height: 1.55in),
  text(size: 22pt, fill: accent)[→],
  card([Apprendre], [Découvrir des structures ou estimer une relation.], height: 1.55in),
  text(size: 22pt, fill: accent)[→],
  card([Agir], [Interpréter, visualiser, prédire ou décider.], height: 1.55in),
)

#v(0.7em)
#small[
  L'analyse de données est proche de l'apprentissage statistique et du
  #emph[machine learning].

  Le point de départ reste toutefois une question, pas un algorithme.
]

== Du terrain à la matrice

#grid(
  columns: (1fr, 1.35fr),
  gutter: 1.1em,
  [
    #card([Unité statistique], [
      L'objet élémentaire étudié : personne, pays, transaction, image, journée, ...
    ], height: 1.48in)
    #v(0.3em)
    #card([Observation], [
      Toutes les valeurs mesurées sur une unité statistique.
    ], fill: pale-blue, height: 1.48in)
    #v(0.3em)
    #card([Variable], [
      Une caractéristique commune aux unités statistiques : revenu, catégorie, durée, ...
    ], fill: pale-purple, height: 1.48in)
  ],
  [
    #align(center)[
      #text(size: 20pt, weight : "bold", fill: accent-dark)[Une matrice $n times p$]
      #v(0.3em)
      #formula([$ X = (x_(i j))_(1 <= i <= n, 1 <= j <= p) in RR^(n times p) $])
      #v(0.7em)
      #grid(
        columns: (1fr, 1fr),
        gutter: 0.6em,
        card([$n$ lignes], [Une ligne par observation.], height: 1.25in),
        card([$p$ colonnes], [Une colonne par variable.], height: 1.25in),
      )
    ]
  ],
)

== Un jeu de données, quatre objectifs

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Décrire], [
    *Question* — Que s'est-il passé ?

    *Sortie* — Résumés, distributions, comparaisons.
  ], height: 1.73in),
  card([Explorer], [
    *Question* — Quelle structure se dégage ?

    *Sortie* — Axes factoriels, groupes, associations, anomalies.
  ], fill: pale-purple, height: 1.73in),
  card([Prédire], [
    *Question* — Que vaudra la réponse pour une nouvelle observation ?

    *Sortie* — Valeur, classe ou probabilité prédite.
  ], fill: pale-blue, height: 1.73in),
  card([Expliquer une intervention], [
    *Question* — Que changerait une action ?

    *Sortie* — Effet causal sous des hypothèses explicites.
  ], fill: pale-orange, height: 1.73in),
)

#pause

#v(0.6em)
#takeaway([
  Association ≠ prédiction ≠ causalité
])

== Exemple : l'espérance de vie

#grid(
  columns: (0.9fr, 1.4fr),
  gutter: 1em,
  [
    #card([Une unité], [Un pays membre de l'ONU.])
    #v(0.55em)
    #card([Variables possible], [
      - espérance de vie;
      - PIB par habitant;
      - dépenses de santé;
      - fertilité;
      - urbanisation;
      - niveau d'éducation.
    ], fill: pale-purple)
  ],
  [
    #card([Questions possibles], [
      #grid(
        columns: (auto, 1fr),
        gutter: 0.4em,
        tag([D]), [Quelle est la distribution entre les pays ?],
        tag([E], fill: rgb("#7c3aed")), [Quels pays ont des profils similaires ?],
        tag([E], fill: rgb("#7c3aed")), [Peut-on résumer les indicateurs par deux axes factoriels ?],
        tag([P], fill: rgb("#2563eb")), [Peut-on prévoir l'espérance de vie ?],
        tag([C], fill: rgb("#b45309")), [Une hausse des dépenses de santé ferait-elle augmenter l'espérance de vie ?],
      )
    ], fill: pale-gray)
  ],
)

#pause

#small[
  Le même jeu de données peut soutenir plusieurs analyses.

  L'objectif choisi détermine les hypothèses et la validation nécessaires.
]

== Avant de choisir une méthode

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([1 · Question], [
    Quel résultat veut-on produire, pour quelle population et quel usage?
  ], height: 1.5in),
  card([2 · Données], [
    Qui est observé? Comment les variables ont-elles été mesurées?
  ], fill: pale-blue, height: 1.5in),
  card([3 · Représentation], [
    Quelles transformations, échelles ou distances sont pertinentes?
  ], fill: pale-purple, height: 1.5in),
)

#pause

#v(0.8em)

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.6em,
  card([Méthode], [Ajuster un modèle ou construire une représentation.], height: 1.19in),
  text(size: 23pt, fill: accent)[↔],
  card([Critère], [Évaluer la performance, la stabilité et l'utilité de la méthode.], height: 1.19in),
)

#pause

#v(0.75em)
#takeaway([
  Une méthode sophistiquée peut répondre parfaitement à la mauvaise question.
])

= Apprentissage supervisé

== Apprendre à partir de réponses observées

#grid(
  columns: (1.25fr, 1fr),
  gutter: 1em,
  [
    #card([Données d'apprentissage], [
      Des pairs d'observations $(x_i, y_i)$, pour $i = 1, dots, n$ :

      - $x_i in RR^p$ : variables explicatives;
      - $y_i$ : réponse observée.
    ])
    #v(0.7em)
    #card([Objectif], [
      Construire une règle $hat(f)$ qui prédit la réponse d'une nouvelle
      observation $x$.
    ], fill: pale-blue)
  ],
  [
    #align(center)[
      #text(size: 20pt, weight : "bold", fill: accent-dark)[Relation générale]
      #v(0.7em)
      #formula([$ Y = f(X) + epsilon $])
      #v(0.8em)
      #small[
        $f$ représente la structure systématique. $epsilon$ contient le bruit, les variables absentes et la variabilité non expliquée.
      ]
    ]
  ],
)

== Régression ou classification?

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Régression], [
    #align(center)[
      #tag([Réponse quantitative])
    ]

    *Exemples* — prix, température, durée, revenu.

    *Critères* — erreur quadratique moyenne, erreur absolue moyenne.

    *Question* — « Combien ? »
  ], height: 3.04in),
  card([Classification], [
    #align(center)[
      #tag([Réponse qualitative], fill: rgb("#2563eb"))
    ]

    *Exemples* — fraude, diagnostic, type de document.

    *Critères* — exactitude, sensibilité, spécificité, précision, rappel.

    *Question* — « Quelle classe ? »
  ], fill: pale-blue, height: 3.04in),
)

#pause

#v(0.7em)
#card([Le critère dépend de l'usage], [
  Une erreur rare mais grave peut compter davantage que le taux d'erreur moyen.

  Avec des classes déséquilibrées, l'exactitude globale peut être trompeuse.
], fill: pale-orange)

== Généraliser à de nouvelles observations

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Jeu d'entraînement], [Estimer les paramètres du modèle.], height: 1.46in),
  text(size: 22pt, fill: accent)[→],
  card([Jeu de validation], [Choisir la méthode et ses hyperparamètres.], fill: pale-blue, height: 1.46in),
  text(size: 22pt, fill: accent)[→],
  card([Jeu de test], [Estimer une seule fois la performance finale.], fill: pale-purple, height: 1.46in),
)

#pause

#v(0.9em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Sous-ajustement → modèle trop rigide], [
    Il manque une structure importante.
  ], fill: pale-orange, height: 1.5in),
  card([Sur-ajustement → modèle trop flexible], [
    Il mémorise les particularités de l'entraînement.
  ], fill: pale-red, height: 1.5in),
)

#pause

#v(0.65em)
#takeaway([
  Bonne performance d'entraînement ≠ bonne généralisation
])

== La fuite d'information

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Procédure biaisée], [
    1. Imputer ou standardiser tout le jeu de données.
    2. Séparer ensuite les jeux d'entraînement et de test.
    3. Obtenir un score artificiellement optimiste.
  ], fill: pale-red, height: 2.23in),
  card([Procédure correcte], [
    1. Séparer les données.
    2. Ajuster les transformations sur le jeu d'entraînement.
    3. Appliquer ces transformations au jeu de test.
  ], fill: pale, height: 2.23in),
)

#pause

#v(0.8em)
#card([Règle pratique], [
  Toute opération qui « apprend » des données (imputation, standardisation,
  sélection de variables ou réduction de dimension) appartient au protocole
  d'entraînement.
], fill: pale-blue)

= Apprentissage non supervisé

== Apprendre sans réponse désignée

#grid(
  columns: (1.15fr, 1fr),
  gutter: 1em,
  [
    #card([Données], [
      Des observations $x_1, dots, x_n$, sans réponse $y_i$ désignée.
    ])
    #v(0.65em)
    #card([Objectif], [
      Construire une représentation qui révèle des régularités utiles.
    ], fill: pale-blue)
  ],
  [
    #card([Ce que l'on cherche], [
      - axes de variation;
      - groupes d'observations;
      - proximités entre modalités;
      - variables redondantes;
      - observations atypiques.
    ], fill: pale-gray)
  ],
)

#pause

#v(0.75em)
#takeaway([
  Sans réponse observée, la validation de la méthode dépend davantage de la stabilité et de l'interprétation.
])

== Réduire la dimension

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.75em,
  align: horizon,
  card([Espace initial], [
    $p$ variables, parfois redondantes et difficiles à visualiser.
  ], height: 1.38in),
  text(size: 28pt, fill: accent)[→],
  card([Représentation synthétique], [
    Quelques axes qui préservent une propriété importante.
  ], fill: pale-purple, height: 1.38in),
)

#pause

#v(0.8em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([ACP], [Variables quantitatives; préserver la variabilité.], height: 1.46in),
  card([AFC], [Tableau de contingence; comparer des profils.], fill: pale-blue, height: 1.46in),
  card([ACM], [Variables qualitatives; décrire les associations.], fill: pale-purple, height: 1.46in),
)

#pause

#v(0.7em)
#small[
  Une projection en dimension réduite est une approximation : une proximité mal
  représentée sur les axes ne doit pas être surinterprétée.
]

== Regrouper les observations

#grid(
  columns: (1fr, 1.25fr),
  gutter: 0.9em,
  [
    #card([Trois conceptions d'un groupe], [
      - proximité à un centre : $k$-means;
      - hiérarchie de distances : classification hiérarchique;
      - appartenance probabiliste : modèles de mélange.
    ], fill: pale-purple, height: 2.77in)
  ],
  [
    #card([Des choix qui changent le résultat], [
      - représentation des observations;
      - échelle et standardisation;
      - mesure de dissimilarité;
      - nombre de groupes demandé;
      - initialisation de l'algorithme.
    ], fill: pale-blue, height: 2.77in)
  ],
)

#v(0.75em)
#card([Exemple], [
  Regrouper des clients selon leurs achats vise à découvrir des segments
  pertinents, pas à prédire une étiquette connue à l'avance.
], fill: pale-orange)

== Valider sans réponse observée

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([Critère interne], [
    Géométrie des données : compacité, séparation, inertie expliquée.
  ], height: 1.59in),
  card([Critère externe], [
    Information indépendante qui n'a pas servi à construire la représentation.
  ], fill: pale-blue, height: 1.59in),
  card([Stabilité], [
    Persistance du résultat quand l'échantillon ou les paramètres changent.
  ], fill: pale-purple, height: 1.59in),
)

#pause

#v(0.9em)
#card([Plusieurs solutions peuvent être défendables], [
  On recherche une représentation utile, stable et interprétable, et pas
  nécessairement une partition « vraie ».
], fill: pale-orange)

= Modéliser

== Une démarche complète

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  column-gutter: 0.5em,
  row-gutter: 0.3em,
  align: horizon,

  card([1 · Question], [Population, unité, résultat attendu.], height: 1.25in),
  text(size: 22pt, fill: accent)[→],
  card([2 · Collecte], [Provenance, échantillonnage, unités.], fill: pale-blue, height: 1.25in),
  text(size: 22pt, fill: accent)[→],
  card([3 · Préparer], [Nettoyer, explorer, documenter.], fill: pale-purple, height: 1.25in),

  [], [], [], [],
  align(center)[#text(size: 22pt, fill: accent)[↓]],

  card([6 · Valider], [Performance, stabilité, sensibilité.], fill: pale-blue, height: 1.25in),
  text(size: 22pt, fill: accent)[←],
  card([5 · Ajuster], [Estimer les paramètres du modèle.], height: 1.25in),
  text(size: 22pt, fill: accent)[←],
  card([4 · Représenter], [Transformer, standardiser, sélectionner.], fill: pale-orange, height: 1.25in),

  align(center)[#text(size: 22pt, fill: accent)[↓]], [], [], [], [],

  card([7 · Communiquer], [Interpréter, limiter, reproduire.], fill: pale-purple, height: 1.25in),
  text(size: 22pt, fill: accent)[→],
  card([1 · Question], [Population, unité, résultat attendu.], fill: pale-orange, height: 1.25in),
  text(size: 22pt, fill: accent)[→],
  text(size: 22pt, fill: accent)[...]
)


== Représentation, méthode et critère

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Représentation], [Variables, transformations, distance.], height: 1.28in),
  text(size: 22pt, fill: accent)[↔],
  card([Méthode], [Modèle, algorithme, hyperparamètres.], fill: pale-blue, height: 1.28in),
  text(size: 22pt, fill: accent)[↔],
  card([Critère], [Erreur, stabilité, interprétabilité.], fill: pale-purple, height: 1.28in),
)

#pause

#v(0.9em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Paramètre], [
    Estimé à partir des données d'entraînement : coefficient, centroïde…
  ], height: 1.42in),
  card([Hyperparamètre], [
    Choisi par validation : nombre de groupes, force de régularisation…
  ], fill: pale-blue, height: 1.42in),
)

#pause

#v(0.65em)
#small[
  Changer un seul de ces éléments peut changer le résultat.

  Un protocole doit documenter les choix, pas seulement le nom de l'algorithme.
]

== Une analyse responsable

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.55em,
  card([Représentation], [Qui est présent dans les données — et qui ne l'est pas?], height: 1.59in),
  card([Évaluation], [Les erreurs affectent-elles certains groupes davantage?], fill: pale-blue, height: 1.59in),
  card([Mesure], [Les variables mesurent-elles réellement le phénomène visé?], fill: pale-purple, height: 1.59in),
  card([Déploiement], [La décision peut-elle être expliquée, contestée ou corrigée?], fill: pale-orange, height: 1.59in),
  card([Collecte], [La confidentialité influence-t-elle la participation?], fill: pale-red, height: 1.59in),
  card([Dérive temporelle], [Les données représentent-elles encore les conditions futures?], fill: pale-gray, height: 1.59in),
)

#pause

#v(0.65em)
#takeaway([
  La force de la conclusion doit correspondre à l'information réellement disponible.
])
