#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let course_title = "Analyse exploratoire"
#let course_author = "Steven Golovkine"

#let accent = rgb("#00897b")
#let accent-dark = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")
#let pale-red = rgb("#fcecec")

#let card(
  title,
  body,
  fill: pale,
  stroke: rgb("#bedbd5"),
  height: auto,
  title-size: 15pt,
  body-size: 12.3pt,
) = block(
  width: 100%,
  height: height,
  inset: 11pt,
  radius: 5pt,
  fill: fill,
  stroke: 0.8pt + stroke,
  breakable: false,
)[
  #text(size: title-size, weight: "bold", fill: accent-dark)[#title]
  #v(0.32em)
  #text(size: body-size, fill: ink)[#body]
]

#let formula(body, fill: rgb("#f7f9fa"), height: auto) = block(
  width: 100%,
  height: height,
  inset: 12pt,
  radius: 5pt,
  fill: fill,
  stroke: 0.7pt + rgb("#d8e0e3"),
  breakable: false,
)[#align(center + horizon)[#text(size: 18pt, fill: ink)[#body]]]

#let tag(body, fill: accent, size: 11pt) = box(
  inset: (x: 7pt, y: 3pt),
  radius: 10pt,
  fill: fill,
)[#text(size: size, weight: "bold", fill: white)[#body]]

#let takeaway(body, fill: pale) = block(
  width: 100%,
  inset: (x: 13pt, y: 10pt),
  radius: 5pt,
  fill: fill,
  stroke: 0.8pt + rgb("#bedbd5"),
  breakable: false,
)[
  #align(center)[
    #text(size: 18pt, weight: "bold", fill: accent-dark)[#body]
  ]
]

#let metric(title, equation, question, fill: pale, stroke: rgb("#bedbd5")) = card(
  title,
  [
    #align(center)[#text(size: 17pt)[#equation]]
    #v(0.35em)
    #question
  ],
  fill: fill,
  stroke: stroke,
  height: 1.48in,
  body-size: 11.5pt,
)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · #course_title],
  config-info(
    title: [#course_title],
    subtitle: [STT-2200],
    author: [#course_author],
    date: [Automne 2026],
    institution: [Université Laval],
  ),
)

#set text(lang: "fr")
#set par(justify: false, leading: 0.68em)
#set list(indent: 1.05em, body-indent: 0.45em, spacing: 0.32em)
#set enum(indent: 1.05em, body-indent: 0.45em, spacing: 0.3em)

#title-slide()

== Plan du cours

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([1 · Question], [
    Objectif, population, unité et décision.
  ], height: 1.02in),
  card([2 · Données], [
    Qualité, provenance et représentation.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.02in),
  card([3 · Distance], [
    Traduire ce que signifie « se ressembler ».
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.02in),
)

#v(0.65em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.65em,
  card([4 · Erreur], [
    Mesurer la qualité et le coût des décisions.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in),
  card([5 · Validation], [
    Estimer la performance sur de nouvelles données.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.02in),
)

#v(0.75em)
#takeaway([
  Une méthode n'est défendable que si ses choix répondent à la question.
])

= De la question à la méthode

== L'exploration prépare une décision

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 0.28em,
  align: horizon,
  card([1], [Définir l'objectif.], height: 0.95in, title-size: 17pt, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([2], [Collecter et préparer.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.95in, title-size: 17pt, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([3], [Élaborer et valider.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.95in, title-size: 17pt, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([4], [Mettre en œuvre.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in, title-size: 17pt, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([5], [Suivre et améliorer.], fill: pale-red, stroke: rgb("#ecc1c1"), height: 0.95in, title-size: 17pt, body-size: 10.8pt),
)

#v(0.85em)
#grid(
  columns: (1fr, 1.35fr),
  gutter: 0.8em,
  card([La partie visible], [
    Le modèle peut parfois tenir en quelques lignes de code.
  ], height: 1.18in),
  card([Le travail déterminant], [
    Formats, unités, valeurs manquantes, doublons, catégories et documentation.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.18in),
)

#v(0.65em)
#takeaway([L'analyse exploratoire relie les données à une décision explicite.])

== Une bonne question contraint l'analyse

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.9em,
  card([Quatre éléments à préciser], [
    - *Population* — à qui la conclusion s'applique-t-elle?
    - *Unité* — que représente une ligne?
    - *Cible* — quelle variable ou décision?
    - *Résultat* — description, comparaison, prédiction ou segmentation?
  ], height: 2.35in),
  [
    #card([Trop vague], [
      « Analyser les données clients. »
    ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 0.86in)
    #v(0.55em)
    #card([Opérationnelle], [
      « Peut-on prédire quels clients achèteront le nouveau produit d'épargne? »
    ], fill: pale, stroke: rgb("#bedbd5"), height: 1.18in)
  ],
)

#v(0.7em)
#text(size: 14pt, fill: muted)[
  Une question précise limite les explorations sans direction et détermine le
  protocole d'évaluation.
]

== Quatre choix structurent une méthode

#grid(
  columns: (1fr, 1fr),
  gutter: 0.72em,
  card([Espace d'observation], [
    Comment représenter chaque unité statistique?
  ], height: 1.12in),
  card([Distance ou similarité], [
    Quelles différences doivent compter?
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.12in),
  card([Modèle ou algorithme], [
    Quelle structure veut-on extraire?
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.12in),
  card([Erreur, coût ou perte], [
    Comment reconnaître une bonne solution?
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.12in),
)

#v(0.65em)
#takeaway([
  Changer un seul objet peut changer le résultat et son interprétation.
])

== Les données ne parlent jamais seules

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Avant de modéliser], [
    - Que mesure réellement chaque variable?
    - Qui manque dans l'échantillon?
    - Que signifie une absence ou un zéro?
    - Quelles contraintes ont façonné la collecte?
  ], height: 2.05in),
  card([Après le déploiement], [
    - Surveiller les entrées.
    - Détecter la dérive des données.
    - Réévaluer les hypothèses.
    - Réentraîner ou revoir la question.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.05in),
)

#v(0.7em)
#card([Exemple], [
  Une absence d'achat peut traduire un manque d'intérêt, une rupture de stock,
  un problème d'accès ou une observation incomplète.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in)

= Représenter les données

== La qualité précède la sophistication

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Population et structure], [
    - représentativité;
    - unité statistique;
    - dépendance entre observations;
    - déséquilibre des classes.
  ], height: 1.8in),
  card([Valeurs et formats], [
    - valeurs manquantes;
    - doublons et incohérences;
    - unités et échelles;
    - valeurs extrêmes et modalités rares.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.8in),
)

#v(0.7em)
#card([Un piège courant], [
  Les codes `NA`, `N/A`, `?` et `Inconnu` peuvent représenter la même
  absence. Les conserver comme quatre catégories crée une structure artificielle.
], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.02in)

== La provenance donne du sens aux valeurs

#grid(
  columns: (0.9fr, 1.3fr),
  gutter: 0.9em,
  card([D'où viennent-elles?], [
    - systèmes internes;
    - enquêtes;
    - capteurs;
    - expériences;
    - dépôts publics.
  ], height: 2.12in),
  card([Que faut-il documenter?], [
    - source, licence et date d'accès;
    - population et échantillonnage;
    - période et territoire;
    - définition et unité des variables;
    - filtres, exclusions et transformations;
    - changements de collecte.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 2.12in),
)

#v(0.7em)
#takeaway([
  Conserver les données brutes; produire la base analysée par transformations versionnées.
])

== Une ligne, une unité; une colonne, une variable

#grid(
  columns: (1fr, 1.08fr),
  gutter: 0.9em,
  [
    #card([Données tidy], [
      - une variable par colonne;
      - une observation par ligne;
      - une seule valeur par cellule.
    ], height: 1.6in)
    #v(0.6em)
    #card([Le format de collecte], [
      Il faut parfois pivoter, séparer une colonne ou réunir plusieurs fichiers.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.05in)
  ],
  card([L'unité statistique], [
    L'objet élémentaire sur lequel porte l'observation.

    Individu, transaction, pays, image, pixel, document…

    Elle fixe le niveau d'agrégation et dépend de la question, pas seulement du fichier.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 2.95in),
)

== Le type d'une variable limite les opérations

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 0.5em,
  card([Numérique], [
    Âge, revenu, température.
  ], height: 1.18in, body-size: 11.4pt),
  card([Nominale], [
    Région, programme d'étude.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.18in, body-size: 11.4pt),
  card([Binaire asymétrique], [
    Fraude ou symptôme rare.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.18in, body-size: 11.4pt),
  card([Ordinale], [
    Faible, moyen, élevé.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.18in, body-size: 11.4pt),
)

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Coder n'est pas mesurer], [
    Associer 1, 2 et 3 à des modalités conserve parfois un ordre, mais ne rend
    pas les écarts comparables.
  ], height: 1.25in),
  card([Objets riches], [
    Texte, courbe, image et réseau demandent une représentation adaptée avant
    toute distance ou modélisation.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.25in),
)

== L'espace d'observation formalise les données

#formula([
  $cal(X) = cal(X)_1 times cal(X)_2 times dots times cal(X)_p$
], height: 0.9in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Variables numériques], [
    $p$ mesures donnent souvent $cal(X)=RR^p$.
  ], height: 1.35in),
  card([Données mixtes], [
    $RR_+^3 times cal(R) times cal(S)$ combine quantités et catégories.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.35in),
  card([Objets structurés], [
    Courbe dans $cal(C)([a,b])$, image dans $[0,1]^(h times w times 3)$.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.35in),
)

#v(0.7em)
#takeaway([
  La représentation choisie détermine les distances et les modèles possibles.
])

= Mesurer les ressemblances

== Une distance formalise « proche »

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.9em,
  card([Quatre propriétés], [
    Pour tous $x,y,z in cal(X)$:

    1. $d(x,y) >= 0$
    2. $d(x,y)=0 <=> x=y$
    3. $d(x,y)=d(y,x)$
    4. $d(x,y) <= d(x,z)+d(z,y)$
  ], height: 2.55in),
  [
    #card([Distance], [
      Plus elle augmente, plus les observations sont dissemblables.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.12in)
    #v(0.55em)
    #card([Similarité], [
      Plus elle augmente, plus les observations se ressemblent.

      $s(x,y)=1/(1+d(x,y))$
    ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.28in)
  ],
)

== Les unités changent la géométrie

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Minkowski], [
    $d_q(x,y)=(sum_(j=1)^p |x_j-y_j|^q)^(1/q)$

    $q=1$: Manhattan

    $q=2$: euclidienne
  ], height: 1.75in),
  card([Standardisation], [
    $z_j(x)=(x_j-mu_j)/sigma_j$

    Chaque différence est mesurée en nombre d'écarts-types.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.75in),
)

#v(0.7em)
#card([Exemple], [
  Dans un profil « âge, revenu, achats », le revenu exprimé en dollars domine
  souvent la distance brute. Standardiser change les voisins jugés les plus proches.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in)

== Les présences rares changent la distance

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Hamming], [
    $d_H(x,y)=sum_(j=1)^p 1(x_j != y_j)$

    Compte tous les désaccords entre variables qualitatives.
  ], height: 1.62in),
  card([Jaccard], [
    $J=M_11/(M_11+M_10+M_01)$

    Ignore les doubles absences lorsque seules les présences sont informatives.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.62in),
)

#v(0.65em)
#takeaway([
  Pour des paniers d'achat très clairsemés, deux absences communes disent peu.
], fill: pale-orange)

== Choisir une distance, c'est choisir un sens

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Profils numériques], [
    Euclidienne standardisée si les dimensions doivent peser de façon comparable.
  ], height: 1.62in, body-size: 11.5pt),
  card([Paniers d'achat], [
    Jaccard si les achats communs comptent davantage que les absences communes.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.62in, body-size: 11.5pt),
  card([Données mixtes], [
    Combiner distances numériques et qualitatives avec des poids justifiés.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.62in, body-size: 11.5pt),
)

#v(0.8em)
#card([Question à poser], [
  Deux observations proches doivent-elles partager des valeurs, des catégories,
  une trajectoire, des voisins ou une conséquence pratique?
], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.02in)

= Mesurer l'erreur

== Erreur, coût et perte désignent le même critère

#formula([
  $Y = f(X) + epsilon$
], height: 0.9in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Information systématique], [
    $f(X)$ représente ce que les variables explicatives apportent sur la réponse.
  ], height: 1.35in),
  card([Part non expliquée], [
    $epsilon$ regroupe bruit, variables absentes et variabilité naturelle.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.35in),
)

#v(0.65em)
#takeaway([
  Une fonction d'erreur, de coût ou de perte quantifie la qualité d'une décision.
], fill: pale-orange)

== MSE et MAE ne pénalisent pas les mêmes erreurs

#grid(
  columns: (1fr, 1fr),
  gutter: 0.85em,
  card([Erreur quadratique moyenne], [
    $ "MSE" = 1/n sum_(i=1)^n (y_i-hat(y)_i)^2 $

    Les grandes erreurs pèsent fortement.
  ], height: 1.75in),
  card([Erreur absolue moyenne], [
    $ "MAE" = 1/n sum_(i=1)^n |y_i-hat(y)_i| $

    L'erreur typique est plus robuste aux valeurs extrêmes.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.75in),
)

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Choisir la MSE], [
    Quand les erreurs extrêmes ont des conséquences disproportionnées.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in),
  card([Choisir la MAE], [
    Quand l'écart absolu habituel correspond mieux à l'usage.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.02in),
)

== La matrice de confusion compte quatre décisions

#align(center)[
  #set text(size: 13pt)
  #set par(justify: false)
  #table(
    columns: (1.25fr, 1fr, 1fr),
    align: center + horizon,
    inset: 11pt,
    stroke: 0.7pt + rgb("#cfd8dc"),
    fill: (x, y) => if y == 0 or x == 0 { rgb("#eef3f1") },
    [], [*Prédit positif*], [*Prédit négatif*],
    [*Réel positif*], [Vrai positif (VP)], [Faux négatif (FN)],
    [*Réel négatif*], [Faux positif (FP)], [Vrai négatif (VN)],
  )
]

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Cas manqués], [
    Les faux négatifs sont positifs en réalité, mais non détectés.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.02in),
  card([Fausses alertes], [
    Les faux positifs sont négatifs en réalité, mais signalés à tort.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in),
)

== Quatre mesures répondent à quatre questions

#grid(
  columns: (1fr, 1fr),
  gutter: 0.62em,
  metric([Sensibilité], [$"VP"/("VP"+"FN")$], [Parmi les positifs, combien sont détectés?]),
  metric([Spécificité], [$"VN"/("VN"+"FP")$], [Parmi les négatifs, combien sont écartés?], fill: pale-blue, stroke: rgb("#c7d8e4")),
  metric([Précision], [$"VP"/("VP"+"FP")$], [Parmi les alertes, combien sont réellement positives?], fill: pale-purple, stroke: rgb("#d9cbe4")),
  metric([Rappel], [$"VP"/("VP"+"FN")$], [Autre nom de la sensibilité.], fill: pale-orange, stroke: rgb("#ead4ad")),
)

#v(0.55em)
#text(size: 13.5pt, fill: muted)[
  Abaisser le seuil augmente généralement la sensibilité, mais réduit la
  spécificité. La précision dépend aussi de la fréquence de la classe positive.
]

== Une exactitude élevée peut masquer l'échec

#grid(
  columns: (0.82fr, 1.3fr),
  gutter: 0.9em,
  card([1 000 transactions], [
    - 20 fraudes;
    - 16 détectées;
    - 4 manquées;
    - 30 fausses alertes.
  ], height: 2.05in),
  [
    #formula([
      $"Sensibilité" = "Rappel" = 16/20 = 80%$
    ], height: 0.72in)
    #v(0.42em)
    #formula([
      $"Spécificité" = 950/980 approx 96,9%$
    ], fill: pale-blue, height: 0.72in)
    #v(0.42em)
    #formula([
      $"Précision" = 16/46 approx 34,8%$
    ], fill: pale-purple, height: 0.72in)
  ],
)

#v(0.65em)
#takeaway([
  Une bonne spécificité peut coexister avec beaucoup de fausses alertes.
])

== Le coût réel doit guider le critère

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.62em,
  card([Dépistage], [
    Manquer une maladie peut coûter davantage qu'un examen complémentaire.
  ], height: 1.55in, body-size: 11.5pt),
  card([Fraude], [
    Le coût dépend du montant, de la vérification et de la relation client.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.55in, body-size: 11.5pt),
  card([Stocks], [
    Rupture, stockage et gaspillage rendent les erreurs asymétriques.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.55in, body-size: 11.5pt),
)

#v(0.8em)
#card([Conséquence], [
  Le seuil de décision et la mesure de performance doivent refléter les
  conséquences pratiques, pas seulement le nombre d'erreurs.
], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.02in)

== Biais, variance et bruit décomposent l'erreur

#formula([
  $ EE((Y_0-hat(f)(x_0))^2)
    = "Biais"(hat(f)(x_0))^2
    + "Var"(hat(f)(x_0))
    + sigma^2 $
], height: 1.05in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.62em,
  card([Biais²], [
    Écart systématique entre la prédiction moyenne et la relation réelle.
  ], height: 1.42in, body-size: 11.5pt),
  card([Variance], [
    Sensibilité de la prédiction au choix de l'échantillon d'entraînement.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.42in, body-size: 11.5pt),
  card([Bruit $sigma^2$], [
    Variabilité irréductible avec les variables disponibles.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.42in, body-size: 11.5pt),
)

#v(0.65em)
#text(size: 13.5pt, fill: muted)[
  Le biais statistique n'est ni un biais de collecte ni un biais social.
]

== La flexibilité crée un compromis

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Sous-ajustement], [
    Biais élevé

    Variance faible
  ], height: 1.52in),
  text(size: 22pt, fill: accent)[→],
  card([Compromis utile], [
    Structure captée

    Stabilité suffisante
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.52in),
  text(size: 22pt, fill: accent)[→],
  card([Sur-ajustement], [
    Biais faible

    Variance élevée
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.52in),
)

#v(0.8em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Entraînement], [
    L'erreur diminue généralement avec la flexibilité.
  ], height: 1.02in),
  card([Nouvelles données], [
    L'erreur diminue, atteint un minimum, puis remonte souvent.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in),
)

= Valider pour généraliser

== Trois ensembles, trois rôles

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Entraînement], [
    Estimer les paramètres et les transformations.
  ], height: 1.55in),
  card([Validation], [
    Comparer les méthodes, régler les hyperparamètres et le seuil.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.55in),
  card([Test], [
    Estimer une seule fois la performance finale.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.55in),
)

#v(0.75em)
#takeaway([
  Si le résultat du test modifie le modèle, le test est devenu une validation.
], fill: pale-red)

== La séparation doit imiter l'usage futur

#grid(
  columns: (1fr, 1fr),
  gutter: 0.68em,
  card([Aléatoire], [
    Observations indépendantes issues de la même population.
  ], height: 1.2in),
  card([Stratifiée], [
    Proportions des classes préservées dans chaque ensemble.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.2in),
  card([Par groupe], [
    Toutes les visites d'un patient restent ensemble.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.2in),
  card([Temporelle], [
    Le passé entraîne; une période ultérieure valide et teste.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.2in),
)

#v(0.62em)
#text(size: 13.5pt, fill: muted)[
  Les proportions 60–20–20 ou 70–15–15 sont des points de départ. Les effectifs
  utiles, la rareté des classes et le nombre de groupes comptent davantage.
]

== Une fuite rend l'évaluation trop optimiste

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.55em,
  align: horizon,
  card([Procédure incorrecte], [
    Imputer, standardiser ou sélectionner sur toute la base.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.5in),
  text(size: 24pt, fill: rgb("#b91c1c"))[×],
  card([Procédure correcte], [
    Ajuster la transformation sur l'entraînement, puis l'appliquer ailleurs.
  ], fill: pale, stroke: rgb("#bedbd5"), height: 1.5in),
)

#v(0.75em)
#card([Autres fuites], [
  Une date future, une observation du même individu ou une variable construite
  après l'événement à prédire peuvent transmettre de l'information interdite.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.12in)

#v(0.65em)
#takeaway([Toute transformation apprise fait partie du modèle.])

== Chaque observation peut servir à valider

#align(center)[
  #set text(size: 11pt)
  #set par(justify: false)
  #table(
    columns: (0.75fr, 0.72fr, 0.72fr, 0.72fr, 0.72fr, 0.72fr),
    align: center + horizon,
    inset: 7pt,
    stroke: 0.6pt + rgb("#d8e0e3"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
    [*Tour*], [*Pli 1*], [*Pli 2*], [*Pli 3*], [*Pli 4*], [*Pli 5*],
    [1], [#tag([V], fill: rgb("#b45309"))], [E], [E], [E], [E],
    [2], [E], [#tag([V], fill: rgb("#b45309"))], [E], [E], [E],
    [3], [E], [E], [#tag([V], fill: rgb("#b45309"))], [E], [E],
    [4], [E], [E], [E], [#tag([V], fill: rgb("#b45309"))], [E],
    [5], [E], [E], [E], [E], [#tag([V], fill: rgb("#b45309"))],
  )
]

#v(0.65em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([E · Entraînement], [
    Ajuster toute la procédure sur quatre plis.
  ], height: 1.0in),
  card([V · Validation], [
    Prédire le pli tenu à l'écart, puis calculer son erreur.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.0in),
)

#v(0.55em)
#text(size: 13.5pt, fill: muted)[
  Les prédictions hors pli proviennent toujours d'un modèle qui n'a pas vu
  l'observation correspondante.
]

== L'erreur globale pondère les plis

#formula([
  $ "Err"_k = 1/n_k sum_(i in I_k) L(y_i, hat(f)^(-k)(x_i)) $
], height: 0.85in)

#v(0.5em)
#formula([
  $ hat("Err")_("CV") = sum_(k=1)^K n_k/n "Err"_k $
], fill: pale-blue, height: 0.85in)

#v(0.65em)
#card([Exemple à cinq plis égaux], [
  Erreurs: 18 %, 22 %, 20 %, 16 % et 24 %.

  Moyenne: $(18%+22%+20%+16%+24%)/5=20%$.

  L'étendue de 16 % à 24 % révèle aussi une sensibilité au découpage.
], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.25in)

== Le choix de $K$ est un compromis

#align(center)[
  #set text(size: 11.5pt)
  #set par(justify: false)
  #table(
    columns: (0.65fr, 1.25fr, 1.8fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    inset: 8pt,
    stroke: 0.6pt + rgb("#d8e0e3"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
    [*$K$*], [*Atout*], [*Limite*],
    [5], [Calcul plus rapide], [Chaque modèle utilise 80 % des données],
    [10], [Bon compromis général], [Deux fois plus d'ajustements],
    [$n$], [Entraînement sur $n-1$ cas], [Coûteux; erreurs très corrélées],
  )
]

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Choix courant], [
    $K=5$ ou $K=10$ convient à de nombreux problèmes indépendants.
  ], height: 1.02in),
  card([Répéter], [
    Plusieurs partitions réduisent la dépendance à une seule graine aléatoire.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.02in),
)

== Le réglage reste à l'intérieur des plis

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Candidats], [
    Degrés, profondeurs, pénalités…
  ], height: 1.25in, body-size: 11.2pt),
  text(size: 21pt, fill: accent)[→],
  card([Boucle intérieure], [
    Choisir les hyperparamètres.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.25in, body-size: 11.2pt),
  text(size: 21pt, fill: accent)[→],
  card([Boucle extérieure], [
    Évaluer toute la sélection.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.25in, body-size: 11.2pt),
)

#v(0.75em)
#card([Validation croisée imbriquée], [
  La boucle intérieure règle le modèle; la boucle extérieure estime sa
  performance. Avec un test indépendant, celui-ci reste réservé à l'évaluation finale.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.12in)

#v(0.6em)
#text(size: 13.5pt, fill: muted)[
  Utiliser les mêmes scores pour choisir et annoncer la performance produit une
  estimation optimiste.
]

== Une bonne moyenne ne suffit pas

#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Rapporter], [
    - moyenne des erreurs;
    - dispersion entre les plis;
    - effectifs et classes;
    - règle de séparation.
  ], height: 1.72in),
  card([Vérifier], [
    - même contexte futur;
    - ordre temporel respecté;
    - groupes non séparés;
    - transformations sans fuite.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.72in),
)

#v(0.7em)
#card([Interprétation], [
  Les erreurs des plis ne sont pas indépendantes puisque leurs entraînements se
  chevauchent. Leur dispersion décrit une stabilité observée, pas automatiquement
  un intervalle de confiance valide.
], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.18in)

== Une analyse défendable relie tous les choix

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 0.32em,
  align: horizon,
  card([Question], [Population et usage.], height: 0.92in, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([Données], [Unité et qualité.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.92in, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([Méthode], [Espace et distance.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.92in, body-size: 10.8pt),
  text(size: 19pt, fill: accent)[→],
  card([Décision], [Erreur et validation.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.92in, body-size: 10.8pt),
)

#v(0.8em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([1], [
    La représentation correspond-elle au phénomène?
  ], height: 1.18in),
  card([2], [
    Le critère reflète-t-il le coût réel des erreurs?
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.18in),
  card([3], [
    La validation reproduit-elle l'usage futur?
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.18in),
)

#v(0.65em)
#takeaway([
  Une performance n'a de sens qu'à l'intérieur d'un protocole explicite.
])
