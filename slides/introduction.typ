#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let course_title = "Analyse de données"
#let course_author = "Steven Golovkine"

#let accent = rgb("#00897b")
#let accent-dark = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")

#let card(
  title,
  body,
  fill: pale,
  stroke: rgb("#bedbd5"),
  height: auto,
) = block(
  width: 100%,
  height: height,
  inset: 11pt,
  radius: 5pt,
  fill: fill,
  stroke: 0.8pt + stroke,
  breakable: false,
)[
  #text(size: 15pt, weight: "bold", fill: accent-dark)[#title]
  #v(0.35em)
  #text(size: 12.5pt, fill: ink)[#body]
]

#let auto-card(
  title,
  body,
  fill: pale,
  stroke: rgb("#bedbd5"),
  height: auto,
) = card(
  title,
  body,
  fill: fill,
  stroke: stroke,
  height: height,
)

#let tag(body, fill: accent) = box(
  inset: (x: 8pt, y: 3pt),
  radius: 10pt,
  fill: fill,
)[#text(size: 10.5pt, weight: "bold", fill: white)[#body]]

#let step(number, title, body) = block(
  width: 100%,
  height: 0.95in,
  inset: 8pt,
  radius: 4pt,
  fill: rgb("#f7f9fa"),
  stroke: 0.6pt + rgb("#d8e0e3"),
  breakable: false,
)[
  #box(
    width: 1.6em,
    height: 1.6em,
    fill: accent,
    radius: 50%,
    inset: 0pt,
  )[#align(center + horizon)[#text(size: 10pt, weight: "bold", fill: white)[#number]]]
  #h(0.45em)
  #text(size: 12.5pt, weight: "bold", fill: ink)[#title]
  #v(0.2em)
  #text(size: 10.5pt, fill: muted)[#body]
]

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · #course_title],
  config-info(
    title: [#course_title],
    subtitle: [Introduction],
    author: [#course_author],
    date: [Automne 2026],
    institution: [STT-2200],
  ),
)

#set text(lang: "fr")
#set par(justify: false, leading: 0.68em)
#set list(indent: 1.05em, body-indent: 0.45em, spacing: 0.35em)

#title-slide()

== Plan du cours

#grid(
  columns: (1fr, 1fr),
  gutter: 0.85em,
  card([1 · Partir d'une question], [
    Unités statistiques, variables, matrice de données et types de questions.
  ], height: 1.08in),
  card([2 · Apprentissage supervisé], [
    Régression, classification, généralisation et évaluation.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.08in),
  card([3 · Apprentissage non supervisé], [
    Réduction de dimension, regroupement et interprétation.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.08in),
  card([4 · Modéliser avec rigueur], [
    Démarche d'analyse, validation, limites et biais.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.08in),
)

#v(0.8em)
#align(center)[
  #text(size: 16pt, weight: "bold", fill: accent-dark)[
    Question → données → représentation → méthode → décision
  ]
]

= Partir d'une question

== Qu'est-ce que l'analyse de données?

#align(center)[
  #block(width: 88%, inset: 14pt, radius: 6pt, fill: pale)[
    #align(center)[
      #text(size: 22pt, weight: "bold", fill: accent-dark)[
        Extraire de l'information d'un jeu de données
      ]
    ]
  ]
]

#v(0.7em)

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.5em,
  align: horizon,
  card([Observer], [Mesurer des variables sur des unités statistiques.], height: 1.15in),
  text(size: 22pt, fill: accent)[→],
  card([Apprendre], [Découvrir des structures ou estimer une relation.], height: 1.15in),
  text(size: 22pt, fill: accent)[→],
  card([Agir], [Interpréter, visualiser, prédire ou décider.], height: 1.15in),
)

#v(0.7em)
#text(size: 14pt, fill: muted)[
  L'analyse de données est proche de l'apprentissage statistique et du
  #emph[machine learning]. Le point de départ reste toutefois une question,
  pas un algorithme.
]

== Du terrain à la matrice

#grid(
  columns: (1fr, 1.35fr),
  gutter: 1.1em,
  [
    #auto-card([Unité statistique], [
      L'objet élémentaire étudié : personne, pays, transaction, image, journée…
    ], height: 0.88in)
    #v(0.6em)
    #auto-card([Observation], [
      Toutes les valeurs mesurées sur une unité statistique.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.88in)
    #v(0.6em)
    #auto-card([Variable], [
      Une caractéristique commune aux unités : revenu, catégorie, durée…
    ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.88in)
  ],
  [
    #align(center)[
      #text(size: 19pt, weight: "bold", fill: ink)[Une matrice $n times p$]
      #v(0.6em)
      #block(width: 90%, inset: 14pt, radius: 6pt, fill: rgb("#f7f9fa"))[
        #align(center)[
          $ X = (x_(i j))_(1 <= i <= n, 1 <= j <= p) in RR^(n times p) $
        ]
      ]
      #v(0.7em)
      #grid(
        columns: (1fr, 1fr),
        gutter: 0.6em,
        card([$n$ lignes], [Une ligne par observation.], height: 0.85in),
        card([$p$ colonnes], [Une colonne par variable.], height: 0.85in),
      )
      #v(0.65em)
      #text(size: 12.5pt, fill: muted)[
        La nature des variables détermine les résumés, les graphiques et les
        distances qui ont un sens.
      ]
    ]
  ],
)

== Un jeu de données, quatre objectifs

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Décrire], [
    *Question* — Que s'est-il passé?

    *Sortie* — Résumés, distributions, comparaisons.
  ], height: 1.28in),
  card([Explorer], [
    *Question* — Quelle structure se dégage?

    *Sortie* — Axes, groupes, associations, anomalies.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.28in),
  card([Prédire], [
    *Question* — Que vaudra la réponse pour une nouvelle observation?

    *Sortie* — Valeur, classe ou probabilité prédite.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.28in),
  card([Expliquer une intervention], [
    *Question* — Que changerait une action?

    *Sortie* — Effet causal sous des hypothèses explicites.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.28in),
)

#v(0.6em)
#align(center)[
  #tag([Association ≠ prédiction ≠ causalité], fill: rgb("#b45309"))
]

== Exemple directeur : l'espérance de vie

#grid(
  columns: (0.9fr, 1.4fr),
  gutter: 1em,
  [
    #auto-card([Une observation], [Un pays membre de l'ONU.])
    #v(0.55em)
    #auto-card([Variables], [
      - espérance de vie;
      - PIB par habitant;
      - dépenses de santé;
      - fertilité;
      - urbanisation;
      - niveau d'éducation.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"))
  ],
  [
    #auto-card([Questions possibles], [
      #grid(
        columns: (auto, 1fr),
        gutter: 0.4em,
        tag([D]), [Quelle est la distribution entre les pays?],
        tag([E], fill: rgb("#7c3aed")), [Quels pays ont des profils similaires?],
        tag([E], fill: rgb("#7c3aed")), [Peut-on résumer les indicateurs par deux axes?],
        tag([P], fill: rgb("#2563eb")), [Peut-on prévoir l'espérance de vie?],
        tag([C], fill: rgb("#b45309")), [Une hausse des dépenses de santé la ferait-elle augmenter?],
      )
    ], fill: rgb("#f7f9fa"), stroke: rgb("#d8e0e3"))
    #v(0.65em)
    #text(size: 12pt, fill: muted)[
      Le même tableau peut soutenir plusieurs analyses. L'objectif choisi
      détermine les hypothèses et la validation nécessaires.
    ]
  ],
)

== Avant de choisir une méthode

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([1 · Question], [
    Quel résultat veut-on produire, pour quelle population et quel usage?
  ], height: 1.05in),
  card([2 · Données], [
    Qui est observé? Comment les variables ont-elles été mesurées?
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.05in),
  card([3 · Représentation], [
    Quelles transformations, échelles ou distances sont pertinentes?
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.05in),
)

#v(0.8em)

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.6em,
  card([Méthode], [Ajuster un modèle ou construire une représentation.], height: 0.88in),
  text(size: 23pt, fill: accent)[↔],
  card([Critère], [Évaluer la performance, la stabilité et l'utilité.], height: 0.88in),
)

#v(0.75em)
#align(center)[
  #text(size: 16pt, weight: "bold", fill: accent-dark)[
    Une méthode sophistiquée peut répondre parfaitement à la mauvaise question.
  ]
]

= Apprentissage supervisé

== Apprendre à partir de réponses observées

#grid(
  columns: (1.25fr, 1fr),
  gutter: 1em,
  [
    #auto-card([Données d'apprentissage], [
      Des couples $(x_i, y_i)$, pour $i = 1, dots, n$.

      - $x_i in RR^p$ : variables explicatives;
      - $y_i$ : réponse observée.
    ])
    #v(0.7em)
    #auto-card([Objectif], [
      Construire une règle $hat(f)$ qui prédit la réponse d'une nouvelle
      observation $x$.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"))
  ],
  [
    #align(center)[
      #text(size: 18pt, weight: "bold", fill: ink)[Relation générale]
      #v(0.7em)
      #block(width: 100%, inset: 16pt, radius: 6pt, fill: rgb("#f7f9fa"))[
        #align(center)[#text(size: 25pt)[$Y = f(X) + epsilon$]]
      ]
      #v(0.8em)
      #text(size: 12.5pt, fill: muted)[
        $f$ porte la structure systématique. $epsilon$ rassemble le bruit, les
        variables absentes et la variabilité non expliquée.
      ]
    ]
  ],
)

== Régression ou classification?

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Régression], [
    #tag([Réponse quantitative])

    *Exemples* — prix, température, durée, revenu.

    *Critères* — erreur quadratique moyenne, erreur absolue moyenne.

    *Question* — « Combien? »
  ], height: 2.25in),
  card([Classification], [
    #tag([Réponse qualitative], fill: rgb("#2563eb"))

    *Exemples* — fraude, diagnostic, type de document.

    *Critères* — exactitude, sensibilité, spécificité, précision, rappel.

    *Question* — « Quelle classe? »
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.25in),
)

#v(0.7em)
#auto-card([Le critère dépend de l'usage], [
  Une erreur rare mais grave peut compter davantage que le taux d'erreur moyen.
  Avec des classes déséquilibrées, l'exactitude globale peut être trompeuse.
], fill: pale-orange, stroke: rgb("#ead4ad"))

== Généraliser à de nouvelles observations

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Entraînement], [Estimer les paramètres du modèle.], height: 1.08in),
  text(size: 22pt, fill: accent)[→],
  card([Validation], [Choisir la méthode et ses hyperparamètres.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.08in),
  text(size: 22pt, fill: accent)[→],
  card([Test], [Estimer une seule fois la performance finale.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.08in),
)

#v(0.9em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Sous-ajustement], [
    Modèle trop rigide : il manque une structure importante.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in),
  card([Sur-ajustement], [
    Modèle trop flexible : il mémorise les particularités de l'entraînement.
  ], fill: rgb("#fcecec"), stroke: rgb("#ecc1c1"), height: 0.95in),
)

#v(0.65em)
#align(center)[
  #text(size: 16pt, weight: "bold", fill: accent-dark)[
    Bonne performance d'entraînement ≠ bonne généralisation
  ]
]

== La fuite d'information

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Procédure biaisée], [
    1. Imputer ou standardiser tout le jeu de données.
    2. Séparer ensuite entraînement et test.
    3. Obtenir un score artificiellement optimiste.
  ], fill: rgb("#fcecec"), stroke: rgb("#ecc1c1"), height: 1.65in),
  card([Procédure correcte], [
    1. Séparer les données.
    2. Ajuster les transformations sur l'entraînement.
    3. Appliquer ces transformations au test.
  ], fill: pale, stroke: rgb("#bedbd5"), height: 1.65in),
)

#v(0.8em)
#auto-card([Règle pratique], [
  Toute opération qui « apprend » des données — imputation, standardisation,
  sélection de variables ou réduction de dimension — appartient au protocole
  d'entraînement.
], fill: pale-blue, stroke: rgb("#c7d8e4"))

= Apprentissage non supervisé

== Apprendre sans réponse désignée

#grid(
  columns: (1.15fr, 1fr),
  gutter: 1em,
  [
    #auto-card([Données], [
      Des observations $x_1, dots, x_n$, sans réponse $y_i$ désignée.
    ])
    #v(0.65em)
    #auto-card([Objectif], [
      Construire une représentation qui révèle des régularités utiles.
    ], fill: pale-purple, stroke: rgb("#d9cbe4"))
  ],
  [
    #auto-card([Ce que l'on cherche], [
      - axes de variation;
      - groupes d'observations;
      - proximités entre modalités;
      - variables redondantes;
      - observations atypiques.
    ], fill: rgb("#f7f9fa"), stroke: rgb("#d8e0e3"))
  ],
)

#v(0.75em)
#align(center)[
  #text(size: 15.5pt, weight: "bold", fill: accent-dark)[
    Sans réponse observée, la validation dépend davantage de la stabilité et de
    l'interprétation.
  ]
]

== Réduire la dimension

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.75em,
  align: horizon,
  card([Espace initial], [
    $p$ variables, parfois redondantes et difficiles à visualiser.
  ], height: 1.02in),
  text(size: 28pt, fill: accent)[→],
  card([Représentation synthétique], [
    Quelques axes qui préservent une propriété importante.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.02in),
)

#v(0.8em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([ACP], [Variables quantitatives; préserver la variabilité.], height: 1.08in),
  card([AFC], [Tableau de contingence; comparer des profils.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.08in),
  card([ACM], [Variables qualitatives; décrire les associations.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.08in),
)

#v(0.7em)
#text(size: 13pt, fill: muted)[
  Une projection en deux dimensions est une approximation : une proximité mal
  représentée sur les axes ne doit pas être surinterprétée.
]

== Regrouper les observations

#grid(
  columns: (1fr, 1.25fr),
  gutter: 0.9em,
  [
    #auto-card([Trois conceptions d'un groupe], [
      - proximité à un centre : $k$-means;
      - hiérarchie de distances : classification hiérarchique;
      - appartenance probabiliste : mélanges.
    ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 2.05in)
  ],
  [
    #auto-card([Des choix qui changent le résultat], [
      - représentation des observations;
      - échelle et standardisation;
      - mesure de dissimilarité;
      - nombre de groupes demandé;
      - initialisation de l'algorithme.
    ], fill: rgb("#f7f9fa"), stroke: rgb("#d8e0e3"), height: 2.05in)
  ],
)

#v(0.75em)
#auto-card([Exemple], [
  Regrouper des clients selon leurs achats vise à découvrir des segments
  pertinents — pas à prédire une étiquette connue à l'avance.
], fill: pale-orange, stroke: rgb("#ead4ad"))

== Valider sans réponse observée

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([Critère interne], [
    Géométrie des données : compacité, séparation, inertie expliquée.
  ], height: 1.18in),
  card([Critère externe], [
    Information indépendante qui n'a pas servi à construire la représentation.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.18in),
  card([Stabilité], [
    Persistance du résultat quand l'échantillon ou les paramètres changent.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.18in),
)

#v(0.9em)
#align(center)[
  #block(width: 86%, inset: 13pt, radius: 6pt, fill: pale-orange, stroke: 0.8pt + rgb("#ead4ad"))[
    #align(center)[
      #text(size: 15.5pt, weight: "bold", fill: rgb("#8a4b08"))[
        Plusieurs solutions peuvent être défendables.
      ]
      #v(0.25em)
      #text(size: 12.5pt, fill: ink)[
        On recherche une représentation utile, stable et interprétable — pas
        nécessairement une partition « vraie ».
      ]
    ]
  ]
]

= Modéliser avec rigueur

== Une démarche complète

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 0.45em,
  step([1], [Question], [Population, unité, résultat attendu.]),
  step([2], [Collecte], [Provenance, échantillonnage, unités.]),
  step([3], [Préparer], [Nettoyer, explorer, documenter.]),
  step([4], [Représenter], [Transformer, standardiser, sélectionner.]),
)

#v(0.6em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.5em,
  step([5], [Ajuster], [Estimer les paramètres du modèle.]),
  step([6], [Valider], [Performance, stabilité, sensibilité.]),
  step([7], [Communiquer], [Interpréter, limiter, reproduire.]),
)

#v(0.8em)
#align(center)[
  #text(size: 16pt, weight: "bold", fill: accent-dark)[
    Une analyse est une boucle : un diagnostic peut ramener à une étape antérieure.
  ]
]

== Représentation, méthode et critère

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Représentation], [Variables, transformations, distance.], height: 0.95in),
  text(size: 22pt, fill: accent)[↔],
  card([Méthode], [Modèle, algorithme, hyperparamètres.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.95in),
  text(size: 22pt, fill: accent)[↔],
  card([Critère], [Erreur, stabilité, interprétabilité.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.95in),
)

#v(0.9em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Paramètre], [
    Estimé à partir des données d'entraînement : coefficient, centre d'un groupe…
  ], height: 1.05in),
  card([Hyperparamètre], [
    Choisi par validation : nombre de groupes, force de régularisation…
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.05in),
)

#v(0.65em)
#text(size: 13pt, fill: muted)[
  Changer un seul de ces éléments peut changer le résultat. Un protocole doit
  documenter les choix, pas seulement le nom de l'algorithme.
]

== Une analyse responsable

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.55em,
  card([Représentation], [Qui est présent dans les données — et qui ne l'est pas?], height: 1.18in),
  card([Évaluation], [Les erreurs affectent-elles certains groupes davantage?], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.18in),
  card([Mesure], [Les variables mesurent-elles réellement le phénomène visé?], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.18in),
  card([Déploiement], [La décision peut-elle être expliquée, contestée ou corrigée?], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.18in),
  card([Collecte], [La confidentialité influence-t-elle la participation?], fill: rgb("#fcecec"), stroke: rgb("#ecc1c1"), height: 1.18in),
  card([Dérive temporelle], [Les données représentent-elles encore les conditions futures?], fill: rgb("#f7f9fa"), stroke: rgb("#d8e0e3"), height: 1.18in),
)

#v(0.65em)
#align(center)[
  #text(size: 14.5pt, weight: "bold", fill: accent-dark)[
    La force de la conclusion doit correspondre à l'information réellement disponible.
  ]
]

== À retenir

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([1], [La question précède l'algorithme.], height: 1.05in),
  card([2], [La représentation des données fait partie du modèle.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.05in),
  card([3], [Le supervisé prédit une réponse; le non supervisé construit une représentation.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.05in),
  card([4], [La validation doit reproduire l'usage futur des résultats.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.05in),
  card([5], [Une bonne performance ne garantit ni causalité ni équité.], fill: rgb("#fcecec"), stroke: rgb("#ecc1c1"), height: 1.05in),
  card([6], [Une analyse convaincante explicite ses hypothèses et ses limites.], fill: rgb("#f7f9fa"), stroke: rgb("#d8e0e3"), height: 1.05in),
)

#v(0.65em)
#align(center)[
  #text(size: 18pt, weight: "bold", fill: accent-dark)[Questions?]
]
