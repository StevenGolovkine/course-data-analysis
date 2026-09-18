// STT-2200 — ACP. Source : lectures/dimension_reduction.typ,
// introduction et section « L'analyse en composantes principales ».
// Compilation depuis la racine :
// typst compile --root . slides/dimension_reduction.typ
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let accent = rgb("#00897b")
#let accent-dark = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")

#let card(title, body, fill: pale, height: 1.85in) = block(
  width: 100%, height: height, inset: 12pt, radius: 5pt,
  fill: fill, stroke: 0.7pt + rgb("#cbdedb"), breakable: false,
)[
  #align(left + top)[
    #text(size: 20pt, weight: "bold", fill: accent-dark)[#title]
    #v(0.4em)
    #text(size: 18pt, fill: ink)[#body]
  ]
]

#let formula(body, height: auto) = block(
  width: 100%, height: height, inset: 12pt, radius: 5pt,
  fill: rgb("#f7f9fa"), stroke: 0.7pt + rgb("#d8e0e3"),
  breakable: false,
)[#align(center + horizon)[#text(size: 20pt, fill: ink)[#body]]]

#let takeaway(body, fill: pale) = block(
  width: 100%, inset: 11pt, radius: 5pt, fill: fill, breakable: false,
)[#text(size: 18pt, weight: "bold", fill: accent-dark)[#body]]

#let small(body) = text(size: 14pt, fill: muted)[#body]

#let course-table(columns: (), ..cells) = {
  set text(size: 17pt)
  table(
    columns: columns, inset: 9pt, align: center + horizon,
    stroke: 0.6pt + rgb("#d4dfe1"),
    fill: (x, y) => if y == 0 { pale } else { none },
    ..cells,
  )
}

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · Analyse en composantes principales],
  config-info(
    title: [Analyse en composantes principales],
    subtitle: [STT-2200],
    author: [Steven Golovkine],
    date: [Automne 2026],
    institution: [Université Laval],
  ),
)

#set text(lang: "fr", size: 18pt, fill: ink)
#set par(justify: false, leading: 0.4em)
#set list(indent: 1em, body-indent: 0.4em, spacing: 0.35em)
#set enum(indent: 1em, body-indent: 0.4em, spacing: 0.35em)
#show raw: set text(size: 15pt)

#title-slide()

= Représenter les données

== Sélection de variables et nouvelles coordonnées

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Sélection de variables], [
    Garder certaines variables originales.

    *Exemple :* conserver uniquement la note de l'examen final.
  ], height: 2in),
  card([Construction de composantes], [
    Combiner les variables en quelques scores.

    *Exemple :* résumer plusieurs évaluations par un niveau commun.
  ], fill: pale-blue, height: 2in),
)

#v(0.7em)
#takeaway([L'ACP construit de nouvelles coordonnées à partir de variables quantitatives.])

== Le principe géométrique de l'ACP

#grid(
  columns: (1.45fr, 1fr), gutter: 0.8em, align: horizon,
  image("../figures/acp_principe.svg", width: 100%, height: 3.5in,
    fit: "contain"),
  [
    *CP1* suit la direction de plus grande variance des projections.

    *CP2* lui est perpendiculaire et résume la variation restante.

    Dans ces données simulées, CP1 conserve *90 %* de la variance.
  ],
)

#v(0.5em)
#takeaway([Garder tous les axes change le repère. En supprimer réduit la dimension.])

== Centrer le nuage

#formula([
  $ z_(i j) = x_(i j) - overline(x)_j, quad
    overline(x)_j = 1/n sum_(i=1)^n x_(i j) $
])

#v(0.8em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Effet géométrique], [
    Le point moyen devient l'origine. Les distances entre observations
    restent identiques.
  ]),
  card([Exemple : une note sur 20], [
    Si la moyenne vaut 12, une note de 14 donne une valeur centrée de 2 points.
  ], fill: pale-blue),
)

== ACP centrée ou centrée réduite

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([ACP centrée], [
    $ z_(i j) = x_(i j) - overline(x)_j $

    Analyse de la *covariance*.

    Les variables les plus dispersées pèsent davantage.
  ], height: 2.75in),
  card([ACP centrée réduite], [
    $ z_(i j) = (x_(i j) - overline(x)_j) / s_j $

    Analyse de la *corrélation*.

    Chaque variance initiale vaut 1.
  ], fill: pale-blue, height: 2.75in),
)


== La standardisation est un choix d'analyse

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Unités différentes], [
    Le prix en dollars peut dominer la superficie d'un logement en mètres carrés.

    Réduire supprime cet effet d'unité.
  ], height: 2.5in),
  card([Poids des variables], [
    Une variance égale à 1 donne autant de poids initial à une mesure peu fiable
    qu'à une mesure précise.
  ], fill: pale-orange, height: 2.5in),
)

#v(0.7em)
#takeaway([Le choix des variables et de leur échelle définit la géométrie analysée.])

= Construire les composantes

== Données, directions et scores

#course-table(
  columns: (1fr, 1fr, 3fr),
  [*Objet*], [*Dimension*], [*Interprétation*],
  [$Z$], [$n times p$], [Données centrées, éventuellement réduites],
  [$alpha_k$], [$p times 1$], [Direction unitaire du $k$-ième axe],
  [$Y_k = Z alpha_k$], [$n times 1$], [Scores des individus sur cet axe],
  [$A_q$], [$p times q$], [Les $q$ directions conservées],
  [$T_q = Z A_q$], [$n times q$], [Tableau des coordonnées réduites],
)

#v(0.65em)
#text(size: 17pt, fill: muted)[
  Les $n$ observations ont le même poids. Les variances utilisent le diviseur $n-1$.
]

== Variance d'une projection

La covariance empirique des données centrées est

#formula([$ hat(Sigma) = 1/(n-1) Z^top Z. $])

#v(0.65em)
Pour une direction unitaire $alpha$, le vecteur des scores est $y = Z alpha$.

#formula([
  $ op("Var")(y) = 1/(n-1) y^top y = alpha^top hat(Sigma) alpha. $
])

#v(0.65em)
#text(size: 17pt, fill: muted)[
  La contrainte $alpha^top alpha = 1$ fixe l'échelle : multiplier les
  coefficients par $c$ multiplierait la variance par $c^2$.
]

== Le premier axe : un problème d'optimisation

#formula([
  $ alpha_1 = op("arg max", limits: #true)_(alpha^top alpha = 1)
    alpha^top hat(Sigma) alpha $
])

#v(0.6em)
Le Lagrangien introduit la contrainte de norme :

$ cal(L)(alpha, lambda) = alpha^top hat(Sigma) alpha
  - lambda (alpha^top alpha - 1). $

La condition de stationnarité donne

$ 2 hat(Sigma) alpha - 2 lambda alpha = 0
  quad arrow.r.double quad hat(Sigma) alpha = lambda alpha. $

#v(0.5em)
#takeaway([Les directions candidates sont les vecteurs propres de la covariance.])

== Pourquoi choisir la plus grande valeur propre ?

Par le théorème spectral, $hat(Sigma)$ possède une base orthonormée
$(u_1, dots, u_p)$ et des valeurs propres
$lambda_1 >= dots >= lambda_p >= 0$.

Pour tout vecteur unitaire, $alpha = sum_j c_j u_j$ avec $sum_j c_j^2 = 1$.

#formula([
  $ alpha^top hat(Sigma) alpha = sum_(j=1)^p lambda_j c_j^2
    <= lambda_1. $
])

#v(0.7em)
La borne est atteinte avec $alpha_1 = u_1$.
Ainsi, $Y_1 = Z alpha_1$ et $op("Var")(Y_1) = lambda_1$.

== Les axes suivants et la non-corrélation

L'axe $k$ maximise la variance sous deux contraintes :

- $alpha_k^top alpha_k = 1$ ;
- $alpha_k^top alpha_j = 0$ pour tout $j < k$.

#formula([
  $ hat(Sigma) alpha_k = lambda_k alpha_k, quad Y_k = Z alpha_k $
  $ op("Cov")(Y_k, Y_l) = alpha_k^top hat(Sigma) alpha_l
    = lambda_l alpha_k^top alpha_l $
])

#v(0.65em)
#takeaway([
La variance de $Y_k$ vaut $lambda_k$.

Les composantes sont non corrélées, ce qui n'implique pas leur indépendance.
])

== Représentation réduite et rang

#formula([
  $ A_q = (alpha_1 | dots | alpha_q), quad T_q = Z A_q, quad A_q^top A_q = I_q, $
  $ 1/(n-1) T_q^top T_q = op("diag")(lambda_1, dots, lambda_q). $
])

#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Chaque ligne de $T_q$], [
    Les $q$ scores d'une observation :

    $ y_(i k) = sum_(j=1)^p alpha_(j k) z_(i j), k = 1, dots, q. $
  ], height: 2.2in),
  card([Nombre d'axes non nuls], [
    Exactement $r$ composantes ont une variance strictement positive.
    
    $ r = op("rang")(Z) <= min(n-1, p). $
  ], fill: pale-blue, height: 2.2in),
)


= Mesurer la variance conservée

== L'inertie mesure la dispersion autour du centre

#grid(
  columns: (1.2fr, 1fr), gutter: 0.8em, align: horizon,
  image("../figures/acp_inertie.svg", width: 100%),
  [
    Pour des données centrées, $g = 0$.

    $ I = 1/(n-1) sum_(i=1)^n norm(z_i)^2 $

    Une distance deux fois plus grande apporte un terme quatre fois plus grand.
  ],
)

#v(0.55em)
#text(size: 17pt, fill: muted)[
  Avec une normalisation par $n$, l'inertie vaut $(n-1) / n I$.
  Les proportions de variance conservée restent identiques.
]

== L'inertie est la somme des valeurs propres

#formula([
  $ I = sum_(j=1)^p op("Var")(Z_j) = op("tr")(hat(Sigma))
    = sum_(k=1)^p lambda_k $
])

#v(0.75em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Changement de repère], [
    $ norm(z_i)^2 = sum_(k=1)^p y_(i k)^2. $

    L'orthonormalité conserve les distances et l'inertie totale.
  ], height: 2.4in),
  card([ACP centrée réduite], [
    Chaque variable a une variance égale à 1.

    L'inertie totale vaut donc 
    
    $ I = p. $
  ], fill: pale-blue, height: 2.4in),
)

== Variance expliquée par un axe et par plusieurs axes

#formula([
  $ r_k = lambda_k / (sum_(j=1)^p lambda_j), quad
    R_q = (sum_(k=1)^q lambda_k) / (sum_(j=1)^p lambda_j). $
])

#v(0.75em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Exemple], [
    CP1 : 60 % ; CP2 : 22 %.

    Le premier plan conserve 82% de la variance totale.
  ], height: 1.8in),
  card([Part omise], [
    Les 18 % restants correspondent à des différences invisibles dans ce plan.
  ], fill: pale-orange, height: 1.8in),
)

#v(0.55em)
#text(size: 17pt, fill: muted)[
  « Expliquée » signifie conservée par la projection, sans interprétation causale.
]


== Reconstruction et variance perdue

#formula([
  $ hat(Z)_q = T_q A_q^top, quad hat(z)_i = sum_(k=1)^q y_(i k) alpha_k, $
  $ 1/(n-1) sum_(i=1)^n norm(z_i-hat(z)_i)^2
    = sum_(k=q+1)^p lambda_k = I(1-R_q) $
])

#v(0.75em)
Parmi les projections orthogonales de dimension $q$, l'ACP est celle qui minimise
l'erreur quadratique de reconstruction.

#v(0.65em)
#takeaway([Pour revenir aux unités originales : multiplier par $s_j$ si les
  variables ont été réduites, puis ajouter $overline(x)_j$.])

= Exemple : deux évaluations

== Deux examens corrélés

Chaque étudiant est décrit par ses deux notes centrées réduites.
On suppose une corrélation empirique de $0.8$.

#formula([
  $ hat(Sigma) = mat(1, 0.8; 0.8, 1), quad
    det(hat(Sigma)-lambda I_2) = (1-lambda)^2-0.8^2. $
])

#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Première direction], [
    $ lambda_1 = 1.8, quad alpha_1 = 1/sqrt(2) vec(1, 1) $
  ], height: 1.8in),
  card([Seconde direction], [
    $ lambda_2 = 0.2, quad alpha_2 = 1/sqrt(2) vec(1, -1) $
  ], fill: pale-blue, height: 1.8in),
)

== Niveau commun et contraste

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Niveau commun : 90 %], [
    $ Y_1 = (Z_1 + Z_2)/sqrt(2) $

    Les deux notes contribuent dans le même sens.
  ], height: 2.2in),
  card([Contraste : 10 %], [
    $ Y_2 = (Z_1 - Z_2)/sqrt(2) $

    Un score positif indique une première note standardisée plus élevée.
  ], fill: pale-orange, height: 2.2in),
)

#v(0.65em)
#course-table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  [*Profil*], [$z_1$], [$z_2$], [$y_1$], [$y_2$],
  [A], [1], [1], [$sqrt(2)$], [0],
  [B], [1], [-1], [0], [$sqrt(2)$],
  [C], [0], [0], [0], [0],
)

== Un nouveau repère pour les mêmes étudiants

#align(center)[
  #image("../figures/acp_exemple_reperes.svg", height: 3.85in)
]

#v(0.3em)
#takeaway([Les deux composantes conservent toutes les distances.

  B et C se distinguent uniquement sur le second axe.
])

== Réduire à une seule composante

#grid(
  columns: (1.15fr, 1fr), gutter: 0.8em, align: horizon,
  image("../figures/acp_exemple_projection.svg", width: 100%, height: 4in,
    fit: "contain"),
  [
    La reconstruction vaut

    $ hat(z)_i = y_(i 1) alpha_1. $

    *A* reste au point $(1,1)$.

    *B* et *C* ont la même reconstruction : $(0,0)$.

    Pour B, l'erreur au carré vaut *2*, malgré les *90 %* conservés globalement.
  ],
)

= Choisir le nombre de composantes

== Un seuil de variance cumulée

Pour un seuil $tau$, choisir le plus petit $q$ tel que $R_q >= tau$.
Exemple d'une ACP centrée réduite de six variables :

#v(0.5em)
#course-table(
  columns: (1fr, 1fr, 1.4fr, 1.4fr),
  [*Rang* $k$], [$lambda_k$], [*Part* $r_k$], [*Cumul* $R_k$],
  [1], [3,0], [50 %], [50 %],
  [2], [1,5], [25 %], [75 %],
  [3], [0,9], [15 %], [90 %],
  [4], [0,3], [5 %], [95 %],
  [5], [0,2], [3,3 %], [98,3 %],
  [6], [0,1], [1,7 %], [100 %],
)

#v(0.6em)
#takeaway([Seuil de 80 % ou de 90 % : $q = 3$. Seuil de 95 % : $q = 4$.])

== Éboulis et variance cumulée

#align(center)[
  #image("../figures/acp_nombre_composantes.svg", height: 4.5in)
]

#text(size: 17pt, fill: muted)[
  Dans cet exemple, le coude illustratif au rang 4 suggère $q = 4$.
  Sa position reste un jugement visuel à justifier.
]

== Plusieurs règles, plusieurs choix possibles

#course-table(
  columns: (1.35fr, 2.2fr, 0.7fr, 1fr),
  [*Règle*], [*Critère*], [$q$], [$R_q$],
  [Kaiser], [$lambda_k > 1$], [2], [75 %],
  [Jolliffe], [$lambda_k > 0.7$], [3], [90 %],
  [Variance cumulée], [$R_q >= 90%$], [3], [90 %],
  [Coude illustratif], [Rupture au rang 4], [4], [95 %],
)

#v(0.7em)
- Les seuils de Kaiser et Jolliffe concernent l'ACP *centrée réduite*.
- Ces règles sont des repères heuristiques.
- Examiner le contenu des axes proches du seuil et l'objectif de l'analyse.

== Composantes retenues et axes affichés

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Trois composantes retenues], [
    $R_3 = 90%$ concerne l'espace formé par les trois premiers axes factoriels $Y_1$, $Y_2$ et $Y_3$.
  ], height: 1.65in),
  card([Deux plans différents], [
    $(Y_1,Y_2)$ conserve 75 %.

    $(Y_1,Y_3)$ conserve 65 %.
  ], fill: pale-blue, height: 1.65in),
)


= Interpréter les plans factoriels

== Lire la carte des individus

L'observation $i$ a pour coordonnées $(y_(i 1), y_(i 2))$ dans le premier plan factoriel.

- Donner un sens aux axes à partir des variables avant de décrire les profils.
- Utiliser la même échelle sur les deux axes pour lire les distances.
- Deux points proches peuvent différer sur les composantes omises.

#v(0.5em)
#course-table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [*Individu*], [$y_1$], [$y_2$], [$y_3$],
  [D], [0,1], [0,1], [3],
  [E], [0,1], [0,1], [-3],
)

#v(0.5em)
#takeaway([D et E se superposent dans le premier plan, mais leur distance vaut 6.])

== Coefficients, scores et corrélations

#course-table(
  columns: (1.2fr, 1.5fr, 2.5fr),
  [*Quantité*], [*Notation*], [*Ce qu'elle décrit*],
  [Coefficient], [$alpha_(j k)$], [Poids de la variable $j$ dans l'axe $k$],
  [Score], [$y_(i k)$], [Position de l'observation $i$ sur l'axe $k$],
  [Corrélation], [$rho_(j k)$], [Association entre la variable $j$ et l'axe $k$],
)

#v(0.75em)
Dans une ACP centrée réduite, pour $lambda_k > 0$ :

#formula([$ rho_(j k) = op("corr")(Z_j, Y_k)
  = sqrt(lambda_k) alpha_(j k). $])

== Le cercle des corrélations des deux examens

#grid(
  columns: (1.2fr, 1fr), gutter: 0.8em, align: horizon,
  image("../figures/acp_cercle_correlations.svg", width: 100%, height: 3.7in,
    fit: "contain"),
  [
    $Z_1 : (0.949, 0.316)$

    $Z_2 : (0.949, -0.316)$

    Les deux notes augmentent avec le niveau commun $Y_1$.

    Leurs corrélations avec $Y_2$ ont des signes opposés.
  ],
)

#v(0.45em)
#text(size: 17pt, fill: muted)[
  Les flèches atteignent le cercle car les deux axes représentent toute
  la variation. Le cosinus de leur angle vaut exactement 0,8.
]

== Longueurs et angles des flèches

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Longueur au carré], [
    $rho_(j 1)^2 + rho_(j 2)^2 <= 1$.

    Cette somme mesure la part de variation de la variable restituée par le plan.
  ], height: 2.5in),
  card([Angles, si les flèches sont longues], [
    Angle petit : corrélation positive.

    Près de $180 degree$ : négative.

    Près de $90 degree$ : proche de zéro.
  ], fill: pale-blue, height: 2.5in),
)


== Contribution et qualité d'un individu

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Contribution à l'axe], [
    $ "ctr"_(i k) = y_(i k)^2 / ((n-1)lambda_k) $

    Part de l'inertie de l'axe portée par l'individu.

    Somme sur les individus : *1*.
  ], height: 2.75in),
  card([Qualité sur l'axe], [
    $ cos^2_(i k) = y_(i k)^2 / norm(z_i)^2 $

    Part de l'écart de l'individu au centre restituée par l'axe.

    Somme sur les axes : *1*.
  ], fill: pale-blue, height: 2.75in),
)

#v(0.65em)
#text(size: 17pt, fill: muted)[
  Contributions définies pour $lambda_k > 0$ ; cosinus carrés définis
  pour $norm(z_i) > 0$. Dans un plan, additionner les cosinus carrés de ses axes.
]

== Les profils A, B et C : deux lectures complémentaires

Dans le nuage de 45 étudiants : $lambda_1 = 1.8$ et $lambda_2 = 0.2$.
La contribution moyenne d'un individu est $1/45 approx 2.22%$.

#v(0.6em)
#course-table(
  columns: (0.7fr, 1.2fr, 1.2fr, 1.3fr, 1.3fr),
  [*Profil*], [*Contribution* à $Y_1$], [*Contribution* à $Y_2$],
  [*Qualité* sur $Y_1$], [*Qualité* sur $Y_2$],
  [A], [2,53 %], [0 %], [100 %], [0 %],
  [B], [0 %], [22,73 %], [0 %], [100 %],
  [C], [0 %], [0 %], [Non définie], [Non définie],
)

#v(0.65em)
#text(size: 17pt, fill: muted)[
  Les observations A et B sont à la même distance du centre. L' observation B porte près du quart de l'inertie du second axe, qui est beaucoup plus faible.
]

== Contribution et qualité d'une variable

Pour une ACP centrée réduite et $lambda_k > 0$ :

#formula([
  $ "ctr"^"var"_(j k) = rho_(j k)^2/lambda_k = alpha_(j k)^2,
    quad "qualité"_(j k) = rho_(j k)^2 $
])

#v(0.6em)
#course-table(
  columns: (2fr, 1fr, 1fr),
  [*Indicateur*], [*Axe* $Y_1$], [*Axe* $Y_2$],
  [Contribution], [50 %], [50 %],
  [Qualité de représentation], [90 %], [10 %],
)

#v(0.6em)
#text(size: 17pt, fill: muted)[
  Sur un axe, les contributions des variables totalisent 1.
  Le repère $1/p$ est une contribution moyenne, pas un seuil de qualité.
]

= Limites et restitution

== Une réduction linéaire et un critère de variance

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un cercle], [
    $(cos(theta), sin(theta))$ dépend d'un seul angle.

    Pour une distribution uniforme sur le cercle, un axe conserve seulement *50 %* de la variance et confond des positions distinctes.
  ], height: 2.9in),
  card([Une cible portée par un axe faible], [
    $Y_1$ et $Y_2$ sont indépendantes, de variances 9 et 1.

    Si la cible est $W = Y_2$, garder seulement $Y_1$ conserve *90 %*
    de la variance mais perd toute l'information sur la cible.
  ], fill: pale-orange, height: 2.9in),
)

#v(0.6em)
#text(size: 17pt, fill: muted)[
  L'optimalité concerne la reconstruction quadratique par projection
  orthogonale. Elle ne garantit pas la pertinence pour chaque objectif.
]


== Questions pour interpréter une ACP

1. Quelles variables et quelle préparation définissent la géométrie ?
2. Quelle variance le plan affiché conserve-t-il ?
3. Quelles variables donnent un sens aux axes ?
4. Quels individus et quelles variables contribuent le plus ?
5. Leurs cosinus carrés permettent-ils de commenter ce plan ?
6. Quels axes omis ou choix de préparation faut-il examiner ?

#v(0.6em)
#takeaway([Les axes décrivent les données choisies. Ils ne démontrent ni
  une causalité, ni une classification validée.])
