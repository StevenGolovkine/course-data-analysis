// STT-2200 : les k plus proches voisins.
// Source : lectures/supervised.typ, introduction et section <knn>.
// Exemple reproductible : codes/k_plus_proches_voisins.R.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/k_plus_proches_voisins.typ
// L'option --root . autorise l'accès aux figures du dossier voisin.
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let accent = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")

#let card(title, body, fill: pale, height: 2.45in) = block(
  width: 100%, height: height, inset: 12pt, radius: 5pt,
  fill: fill, stroke: 0.7pt + rgb("#cbdedb"), breakable: false,
)[
  #align(left + top)[
    #text(size: 20pt, weight: "bold", fill: accent)[#title]
    #v(0.4em)
    #text(size: 18pt, fill: ink)[#body]
  ]
]

#let formula(body) = block(
  width: 100%, inset: 12pt, radius: 5pt,
  fill: rgb("#f7f9fa"), stroke: 0.7pt + rgb("#d8e0e3"),
  breakable: false,
)[#align(center)[#text(size: 20pt, fill: ink)[#body]]]

#let takeaway(body, fill: pale) = block(
  width: 100%, inset: 11pt, radius: 5pt, fill: fill, breakable: false,
)[#text(size: 18pt, weight: "bold", fill: accent)[#body]]

#let small(body) = text(size: 16pt, fill: muted)[#body]

#let course-table(columns: (), ..cells) = {
  set text(size: 17pt)
  table(
    columns: columns, inset: 8pt, align: center + horizon,
    stroke: 0.6pt + rgb("#d4dfe1"),
    fill: (x, y) => if y == 0 { pale } else { none },
    ..cells,
  )
}

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · La méthode des $k$ plus proches voisins],
  config-info(
    title: [La méthode des $k$ plus proches voisins],
    subtitle: [STT-2200],
    author: [Steven Golovkine],
    date: [Automne 2026],
    institution: [Université Laval],
  ),
)

#set text(lang: "fr", size: 18pt, fill: ink)
#set par(justify: false, leading: 0.4em)
#set list(indent: 1em, body-indent: 0.4em, spacing: 0.4em)
#set enum(indent: 1em, body-indent: 0.4em, spacing: 0.45em)
#show raw: set text(size: 16pt)

#title-slide()

= Prédire par voisinage

== Une réponse connue pendant l'apprentissage

#formula([
  $ cal(D) = {(x_i, y_i)}_(i=1)^n, quad
    x_i "un vecteur de" p "variables explicatives", quad hat(y) = hat(f)(x) $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([Classification], [
    Prédire une *catégorie*.

    Exemple : l'espèce d'un manchot à partir de ses quatre mesures corporelles.
  ], height: 2.25in),
  card([Régression], [
    Prédire une *quantité*.

    Exemple : la masse d'un manchot à partir des trois autres mesures corporelles.
  ], fill: pale-blue, height: 2.25in),
)

#v(0.7em)
#takeaway([Les variables explicatives doivent être disponibles au moment de prédire.])

== Les notations

#course-table(
  columns: (1fr, 3.8fr),
  [*Symbole*], [*Signification*],
  [$n$], [Nombre d'observations d'entraînement],
  [$p$], [Nombre de variables explicatives],
  [$K$], [Nombre de classes, en classification],
  [$k$], [Nombre de voisins retenus, avec $1 <= k <= n$],
  [$d(x, x_i)$], [Distance entre une nouvelle observation et l'observation $i$],
  [$cal(N)_k (x)$], [Indices des $k$ voisins d'entraînement retenus pour $x$],
)

#v(0.65em)
#takeaway([Le nombre de voisins $k$ et le nombre de classes $K$ sont distincts.])

== L'algorithme des k-NN

#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([1 · Préparer], [
    Les variables, avec les paramètres appris sur l'entraînement.
  ], height: 1.5in),
  card([2 · Calculer les distances], [
    De la nouvelle observation à chaque exemple connu.
  ], fill: pale-blue, height: 1.5in),
  card([3 · Retenir les voisins], [
    Les $k$ plus proches, avec une règle d'égalité fixée à l'avance.
  ], fill: pale-purple, height: 1.5in),
  card([4 · Combiner les réponses], [
    Vote en classification, moyenne en régression.
  ], fill: pale-orange, height: 1.5in),
)

#v(0.7em)
#takeaway([
  La recherche des voisins utilise les variables explicatives.
  La réponse de la nouvelle observation reste inconnue.
])

== Une méthode locale et non paramétrique

#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([Ce que la méthode conserve], [
    Les observations d'entraînement et leurs réponses.

    Le voisinage change selon le point à prédire.
  ], height: 2.65in),
  card([Ce qu'il faut choisir], [
    Les variables, leur préparation, la distance, $k$ et les poids.

    L'hypothèse utile : la proximité doit informer sur la réponse.
  ], fill: pale-blue, height: 2.65in),
)

#v(0.85em)
#takeaway([
  « Non paramétrique » : aucune équation globale avec un nombre fixé de
  coefficients. Les choix de méthode restent essentiels.
])

= Classification et régression

== Le vote des voisins

#formula([
  $ hat(eta)_g (x) = 1/k sum_(i in cal(N)_k (x)) bold(1)\{y_i = g\} $
  $ hat(g)(x) = op("argmax", limits: #true)_(g in {1, dots, K})
    hat(eta)_g (x) $
])

#v(0.6em)
- Chaque voisin apporte une voix.
- L'indicatrice vaut 1 pour un voisin de classe $g$, et 0 sinon.
- La classe ayant le plus de voix gagne, selon la règle de départage.

#v(0.45em)
#text(size: 17pt, fill: muted)[
  Avec plusieurs classes, gagner ne demande pas forcément plus de 50 % des voix.
  Une proportion locale n'est pas une garantie de probabilité bien calibrée.
]

== Exemple : cinq voisins du point origine

On cherche la classe de $x = (0, 0)^top$, avec la distance euclidienne.

#course-table(
  columns: (0.7fr, 1.6fr, 1.2fr, 0.8fr),
  [*Rang*], [*Coordonnées*], [*Distance*], [*Classe*],
  [1], [$(0.2, 0)$], [0,2], [B],
  [2], [$(0, 0.4)$], [0,4], [A],
  [3], [$(-0.5, 0)$], [0,5], [A],
  [4], [$(0, -0.7)$], [0,7], [B],
  [5], [$(0.8, 0.6)$], [1,0], [B],
)

#v(0.65em)
#takeaway([
  $k=1$ : B. #h(0.7em) $k=3$ : A, avec 2 voix sur 3.
  #h(0.7em) $k=5$ : B, avec 3 voix sur 5.
])

== Deux voisinages, deux décisions

#align(center)[
  #image("../figures/knn_voisinage.svg", width: 88%, height: 3.85in,
    fit: "contain",
    alt: "Le même point est classé A avec trois voisins puis B avec cinq voisins.")
]

#text(size: 17pt, fill: muted)[
  Le cercle passe par le $k$-ième voisin. Les numéros renvoient au tableau.
  Les deux points les plus éloignés sont hors des cinq voisins du tableau.
]

== Deux sortes d'égalités

#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([Égalité de distances], [
    Plusieurs points sont à la distance du $k$-ième voisin.

    Pour en garder exactement $k$, on peut utiliser un ordre stable des lignes.
  ], height: 2.6in),
  card([Égalité de voix], [
    Plusieurs classes ont le même nombre maximal de voix.

    On peut retenir la classe du premier voisin parmi les classes ex aequo.
  ], fill: pale-blue, height: 2.6in),
)

#v(0.7em)
#takeaway([
  Un $k$ impair évite l'égalité pour deux classes et un vote uniforme.
  Avec trois classes, 5 voix peuvent se répartir en 2, 2 et 1.
], fill: pale-orange)

#v(0.35em)
#text(size: 17pt, fill: muted)[
  Ces règles font partie de la méthode et précèdent son évaluation.
]


== La moyenne des voisins en régression

#formula([
  $ hat(f)_k (x) = 1/k sum_(i in cal(N)_k (x)) y_i $
])

#v(0.65em)
Pour trois réponses $10$, $12$ et $14$ :

$ hat(f)_3 (x) = (10 + 12 + 14)/3 = 12. $

La moyenne minimise la somme des erreurs *quadratiques* des voisins :

$ hat(f)_k (x) = op("argmin", limits: #true)_a
  sum_(i in cal(N)_k (x)) (y_i-a)^2. $

#v(0.55em)
#text(size: 17pt, fill: muted)[
  Une médiane minimise plutôt la somme des erreurs absolues et résiste davantage aux réponses extrêmes.
]


== Donner davantage de poids aux voisins proches

#formula([
  $ hat(f)_k (x) =
    (sum_(i in cal(N)_k (x)) w_i (x) y_i) /
    (sum_(i in cal(N)_k (x)) w_i (x)) $
])

On impose $w_i (x) >= 0$ et une somme des poids strictement positive.
Un choix possible, si $d(x,x_i)>0$, est $w_i (x)=d(x,x_i)^(-1)$.

#v(0.55em)
#course-table(
  columns: (1fr, 1fr, 1fr),
  [*Voisin*], [*Distance*], [*Réponse*],
  [1], [1], [10],
  [2], [3], [14],
)

#v(0.45em)
Moyenne uniforme : $12$. Moyenne pondérée : $(10 + 14/3)/(1 + 1/3) = 11$.


= Choix de $k$


== Le compromis biais-variance

#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([Petit $k$], [
    Prédiction très locale, capable de suivre des détails fins.

    Plus sensible au bruit, aux étiquettes erronées et aux observations atypiques.
  ]),
  card([Grand $k$], [
    Prédiction généralement plus stable.

    Risque de mélanger des régions différentes et d'effacer une structure utile.
  ], fill: pale-blue),
)

#v(0.7em)
#takeaway([
  À $k=n$, avec des poids uniformes : classe la plus fréquente en classification
  (hors égalité), et moyenne globale en régression.
])

== L'effet de $k$ sur les régions de décision

#align(center)[
  #image("../figures/knn_frontieres.svg", width: 100%, height: 3.55in,
    fit: "contain",
    alt: "Sur le même échantillon simulé, les régions isolées du modèle à un "
      + "voisin disparaissent en utilisant neuf puis cinquante et un voisins.")
]

#text(size: 17pt, fill: muted)[
  Même échantillon simulé, avec quelques étiquettes bruitées.
  L'apparence de la frontière sur l'entraînement ne suffit pas à choisir $k$.
]

== Pourquoi l'erreur d'entraînement peut tromper

Supposons $k=1$ et des vecteurs explicatifs d'entraînement tous distincts.

- Chaque observation est son propre plus proche voisin, à distance nulle.
- Sa prédiction recopie donc sa réponse, même si celle-ci contient du bruit.
- L'erreur sur l'entraînement vaut zéro.

#v(0.8em)
#takeaway([
  Pour évaluer la généralisation, l'observation évaluée doit être absente
  de l'ensemble dans lequel on cherche ses voisins.
], fill: pale-orange)



== Le choix de $k$ par validation croisée

On compare, par exemple, $k in {1,3,5,7,9,15,21,31}$ sur les *mêmes plis*.

#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([1 · Partager], [
    Réserver un test final, puis diviser l'entraînement en plis.
  ], height: 1.45in),
  card([2 · Préparer], [
    Pour chaque pli, apprendre la préparation des données sur les autres plis.
  ], fill: pale-blue, height: 1.45in),
  card([3 · Prédire], [
    Prédire le pli réservé pour chaque valeur candidate de $k$.
  ], fill: pale-purple, height: 1.45in),
  card([4 · Comparer], [
    Comparer les erreurs de validation et appliquer le départage prévu.
  ], fill: pale-orange, height: 1.45in),
)

#v(0.7em)
#takeaway([
  Chaque $k$ doit être au plus égal à l'effectif d'entraînement dans chaque pli.
  Aucune valeur n'est universellement optimale.
])

== La procédure complète reste dans les plis

#course-table(
  columns: (1.2fr, 2.1fr, 2.1fr),
  [*Étape*], [*Partie entraînement*], [*Partie validation*],
  [Préparation], [Estimer centrage, réduction, imputation…],
    [Appliquer ces paramètres],
  [Variables ou ACP], [Apprendre la sélection ou les axes],
    [Appliquer la transformation],
  [k-NN], [Conserver les exemples préparés],
    [Chercher les voisins et prédire],
  [Évaluation], [Aucun usage des réponses de validation],
    [Comparer prédictions et réponses],
)

#v(0.7em)
#takeaway([
  Après les choix : réapprendre sur tout l'entraînement, puis évaluer le test
  une fois. Le test ne choisit ni $k$, ni la distance, ni les poids.
])

= Forces et limites

== Une règle flexible et interprétable localement

- Aucune relation linéaire ni distribution normale des classes n'est imposée.
- Les régions de décision peuvent suivre des formes irrégulières.
- Les voisins permettent d'examiner les exemples à l'origine d'une prédiction.

#v(0.85em)
#takeaway([
  L'explication par les voisins reste pertinente seulement si les variables
  et la distance représentent une similarité utile pour la tâche.
])

== La difficulté des grandes dimensions

Illustration : des données uniformes dans un cube unité de dimension $p$.
Un sous-cube de côté $h$ occupe une fraction $h^p$ du volume.

#formula([$ h^p = 0.1 quad arrow.r.double quad h = 0.1^(1/p) $])

#v(0.5em)
#course-table(
  columns: (1fr, 1fr, 1fr),
  [*Dimension $p$*], [*Volume couvert*], [*Côté $h$*],
  [2], [10 %], [0,32],
  [10], [10 %], [0,79],
  [50], [10 %], [0,95],
)

#v(0.55em)
#takeaway([
  Pour couvrir la même fraction du volume, le voisinage s'étend sur
  une grande partie de chaque coordonnée.
])

== Classes rares et régions peu observées

#grid(
  columns: (1fr, 1fr), gutter: 0.8em, align: left + top,
  card([Une classe rare], [
    Un grand voisinage peut être dominé par la classe fréquente.

    Une petite région utile peut disparaître dans le vote.
  ], height: 2.5in),
  card([Un point éloigné], [
    Les k-NN renvoient une prédiction même quand tous les voisins sont loin.

    Un vote unanime peut donc concerner une région mal couverte.
  ], fill: pale-orange, height: 2.5in),
)

#v(0.8em)
#takeaway([
  Examiner les sensibilités par classe et les distances aux voisins,
  en complément de l'exactitude globale.
])

== Une extrapolation limitée en régression

Avec des poids non négatifs et une somme des poids positive :

#formula([
  $ min_(i in cal(N)_k (x)) y_i <= hat(f)_k (x)
    <= max_(i in cal(N)_k (x)) y_i $
])

#v(0.65em)
La prédiction est une moyenne des réponses observées dans le voisinage.

Si les réponses des voisins sont $10$, $12$ et $14$, elle reste dans $[10,14]$,
même si une tendance suggère une valeur plus grande.

#v(0.6em)
#takeaway([
  Les k-NN ne prolongent pas une tendance au-delà des réponses observées.
  Cette limite est importante aux bords du domaine d'entraînement.
])

== Un coût reporté sur la prédiction

Pour chaque nouvelle observation, une recherche directe demande :

#v(0.5em)
#course-table(
  columns: (2fr, 1.2fr),
  [*Opération*], [*Ordre du coût*],
  [Calcul de $n$ distances sur $p$ variables], [$O(n p)$],
  [Tri complet des distances], [$O(n log n)$],
  [Stockage des données et des réponses], [$O(n p)$],
)

#v(0.7em)
Des structures de recherche peuvent accélérer le calcul, surtout
en faible dimension. Leur avantage diminue souvent quand $p$ augmente.

