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
#let pale-red = rgb("#fcecec")

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
  #v(0.32em)
  #text(size: 12.3pt, fill: ink)[#body]
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

#let tag(body, fill: accent) = box(
  inset: (x: 8pt, y: 3pt),
  radius: 10pt,
  fill: fill,
)[#text(size: 10.5pt, weight: "bold", fill: white)[#body]]

#let check(body) = block(
  width: 100%,
  height: 0.72in,
  inset: 8pt,
  radius: 4pt,
  fill: rgb("#f7f9fa"),
  stroke: 0.6pt + rgb("#d8e0e3"),
  breakable: false,
)[
  #text(size: 14pt, weight: "bold", fill: accent)[✓]
  #h(0.35em)
  #text(size: 11.3pt, fill: ink)[#body]
]

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · #course_title],
  config-info(
    title: [#course_title],
    subtitle: [Révisions essentielles],
    author: [#course_author],
    date: [Automne 2026],
    institution: [STT-2200],
  ),
)

#set text(lang: "fr")
#set par(justify: false, leading: 0.68em)
#set list(indent: 1.05em, body-indent: 0.45em, spacing: 0.32em)

#title-slide()

== Plan du cours

#grid(
  columns: (1fr, 1fr),
  gutter: 0.85em,
  card([1 · Algèbre linéaire], [
    Matrices, géométrie, valeurs propres, projections et optimisation.
  ], height: 1.08in),
  card([2 · Probabilités], [
    Incertitude, variables aléatoires, moments et dépendance.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.08in),
  card([3 · Statistiques], [
    Échantillons, estimateurs, covariance empirique et interprétation.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.08in),
  card([4 · Programmation reproductible], [
    Organisation, environnements, contrôle de version et rapports.
  ], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.08in),
)

#v(0.8em)
#align(center)[
  #text(size: 16pt, weight: "bold", fill: accent-dark)[
    Représenter → quantifier l'incertitude → estimer → reproduire
  ]
]

= Algèbre linéaire

== Les données comme matrice

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #formula([$X = (x_(i j)) in RR^(n times p)$], height: 1.2in)
    #v(0.65em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.6em,
      card([$n$ lignes], [Une ligne par observation.], height: 1.2in),
      card([$p$ colonnes], [Une colonne par variable.], height: 1.2in),
    )
  ],
  [
    #card([Dimensions compatibles], [
      Si $A in RR^(n times p)$ et $B in RR^(p times q)$, alors
      $A B in RR^(n times q)$.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.2in)
    #v(0.65em)
    #card([Transposition], [
      $A^top in RR^(p times n)$ et

      $(A B)^top = B^top A^top$.
    ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.2in)
  ],
)

#v(0.65em)
#align(center)[#tag([Toujours vérifier les dimensions avant de calculer.])]

== Produit scalaire et géométrie

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([Produit scalaire], [
    $chevron.l u, v chevron.r = u^top v$

    Il mesure l'alignement de deux vecteurs.
  ], height: 1.55in),
  card([Norme euclidienne], [
    $norm(u) = sqrt(u^top u)$

    Elle mesure la longueur du vecteur.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.55in),
  card([Orthogonalité], [
    $u^top v = 0$

    Les deux directions sont perpendiculaires.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.55in),
)

#v(0.9em)
#card([En analyse de données], [
  Distances, projections, variances et critères quadratiques s'expriment avec
  ces trois objets géométriques.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in)

== Inverse, déterminant et trace

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([Inverse], [
    $A A^(-1) = A^(-1) A = I_n$

    Résoudre conceptuellement $A x = b$.
  ], height: 1.65in),
  card([Déterminant], [
    $det(A) != 0 <=> A$ est inversible.

    Facteur de dilatation des volumes.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.65in),
  card([Trace], [
    $tr(A) = sum_(i=1)^n a_(i i)$

    Somme des éléments diagonaux.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.65in),
)

#v(0.8em)
#formula([
  $(A B)^(-1) = B^(-1) A^(-1) quad
  det(A B) = det(A) det(B) quad
  tr(A + B) = tr(A) + tr(B)$
], height: 0.9in)

== Pourquoi l'ordre de l'inverse est-il renversé?

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Inverse à droite], [
    $(A B)(B^(-1) A^(-1))$

    $= A(B B^(-1))A^(-1)$

    $= I_n$
  ], height: 2.25in),
  card([Inverse à gauche], [
    $(B^(-1) A^(-1))(A B)$

    $= B^(-1)(A^(-1) A)B$

    $= I_n$
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.25in),
)

#v(0.65em)
#align(center)[
  #text(size: 15pt, weight: "bold", fill: accent-dark)[
    Pour annuler une composition, on défait d'abord la dernière opération.
  ]
]

== Trois familles de matrices

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([Symétrique], [
    $A^top = A$

    Valeurs propres réelles et directions propres orthogonales.
  ], height: 1.75in),
  card([Définie positive], [
    $u^top A u > 0$ pour $u != 0$.

    Toutes les valeurs propres sont positives.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.75in),
  card([Orthogonale], [
    $Q^top Q = I_n$

    $Q^(-1) = Q^top$ et les distances sont conservées.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.75in),
)

#v(0.75em)
#text(size: 13pt, fill: muted)[
  Les matrices de covariance et de corrélation sont symétriques et
  semi-définies positives. Cette structure rend possible leur analyse spectrale.
]

== Une covariance est semi-définie positive

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Point de départ], [
    Soit $Sigma = "Cov"(X)$ et une direction $u$.

    La projection aléatoire est $u^top X$.
  ], height: 1.75in),
  card([Identité clé], [
    $u^top Sigma u = "Var"(u^top X) >= 0$

    Une variance ne peut jamais être négative.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.75in),
)

#v(0.75em)
#card([Quand la matrice est-elle singulière?], [
  Si une combinaison linéaire non triviale des variables est constante, sa
  variance est nulle : il existe alors une direction $u != 0$ telle que
  $u^top Sigma u = 0$.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.1in)

== Valeurs propres et quotient de Rayleigh

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Direction propre], [
    $A u = lambda u$, avec $u != 0$.

    Dans cette direction, $A$ agit comme une simple mise à l'échelle.
  ], height: 1.65in),
  card([Quotient de Rayleigh], [
    $R_A(u) = (u^top A u) / (u^top u)$

    Pour une covariance, il mesure la variance dans la direction $u$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.65in),
)

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Matrice symétrique], [Valeurs propres réelles; directions propres orthogonales.], height: 0.95in),
  card([Matrice positive], [Valeurs propres positives ou nulles.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.95in),
)

== Théorème de décomposition spectrale

#align(center)[
  #block(width: 88%, inset: 15pt, radius: 6pt, fill: pale, stroke: 1pt + rgb("#bedbd5"))[
    #text(size: 17pt, weight: "bold", fill: accent-dark)[Théorème]
    #v(0.4em)
    #text(size: 14pt, fill: ink)[
      Toute matrice symétrique réelle $A$ s'écrit
    ]
    #v(0.45em)
    #align(center)[#text(size: 24pt)[$A = Q Lambda Q^top$]]
    #v(0.45em)
    #text(size: 13pt, fill: ink)[
      où $Q$ est orthogonale et $Lambda = "diag"(lambda_1, dots, lambda_n)$.
      Les colonnes de $Q$ forment une base orthonormée de vecteurs propres.
    ]
  ]
]

#v(0.65em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Déterminant], [$det(A) = product_(i=1)^n lambda_i$], height: 0.9in),
  card([Trace], [$tr(A) = sum_(i=1)^n lambda_i$], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.9in),
)

== Projections et optimisation quadratique

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Projection sur une direction], [
    Pour $norm(u) = 1$,

    coordonnée : $u^top x$

    projection : $u u^top x$.
  ], height: 2.05in),
  card([Projection sur un sous-espace], [
    Si les colonnes de $U$ sont orthonormées,

    $P = U U^top$

    vérifie $P^top = P$ et $P^2 = P$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.05in),
)

#v(0.6em)
#formula([
  $max_(u^top u = 1) u^top A u = lambda_"max"(A)$
], fill: pale-orange, height: 0.85in)

== Le lien avec l'analyse de données

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.7em,
  card([ACP], [
    Vecteurs propres : axes de projection.

    Valeurs propres : variances expliquées.
  ], height: 1.65in),
  card([Analyse discriminante], [
    Maximiser la séparation entre groupes relativement à leur dispersion.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.65in),
  card([Méthodes factorielles], [
    Transformer un critère géométrique en coordonnées interprétables.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.65in),
)

#v(0.8em)
#align(center)[
  #text(size: 15pt, weight: "bold", fill: accent-dark)[
    Directions propres = directions privilégiées; valeurs propres = importance.
  ]
]

= Probabilités

== Modéliser l'incertitude

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Espace des possibles], [
    $S$ rassemble tous les résultats possibles.

    Un évènement $E$ est un sous-ensemble de $S$.
  ], height: 1.55in),
  card([Mesure de probabilité], [
    $PP(E)$ quantifie la plausibilité de l'évènement.

    $0 <= PP(E) <= 1$ et $PP(S) = 1$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.55in),
)

#v(0.75em)
#formula([
  $PP(union.big_(i=1)^infinity E_i) = sum_(i=1)^infinity PP(E_i)$
  #h(0.6em) si les $E_i$ sont mutuellement exclusifs.
], height: 0.95in)

#v(0.55em)
#text(size: 13pt, fill: muted)[
  Les probabilités décrivent les résultats possibles et leur fréquence attendue,
  pas le résultat certain d'une expérience particulière.
]

== Conditionnement et indépendance

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Probabilité conditionnelle], [
    Pour $PP(F) > 0$,

    $PP(E | F) = PP(E ∩ F) / PP(F)$.

    On met à jour l'univers en sachant $F$.
  ], height: 2.0in),
  card([Indépendance], [
    $PP(E ∩ F) = PP(E) PP(F)$

    ou, si $PP(F) > 0$,

    $PP(E | F) = PP(E)$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.0in),
)

#v(0.65em)
#align(center)[#tag([Indépendance = connaître F ne change pas la probabilité de E.])]

== Variables aléatoires

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Discrète], [
    Ensemble fini ou dénombrable de valeurs.

    Distribution décrite par $PP(X = x)$.

    Exemple : nombre de succès.
  ], height: 1.85in),
  card([Continue], [
    Une densité $f$ vérifie

    $PP(X in A) = integral_A f(x) dif x$.

    Pour une valeur fixée, $PP(X = x) = 0$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.85in),
)

#v(0.7em)
#card([Fonction de répartition], [
  $F_X(t) = PP(X <= t)$ caractérise entièrement la distribution, dans les cas
  discret comme continu.
], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.95in)

== Espérance et théorème de transfert

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Cas discret], [
    $EE(X) = sum_x x PP(X = x)$

    $EE(g(X)) = sum_x g(x) PP(X = x)$
  ], height: 1.65in),
  card([Cas continu], [
    $EE(X) = integral x f(x) dif x$

    $EE(g(X)) = integral g(x) f(x) dif x$
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.65in),
)

#v(0.75em)
#card([Idée du transfert], [
  Pour calculer l'espérance de $g(X)$, il n'est pas nécessaire de déterminer
  d'abord la distribution de $g(X)$ : on moyenne directement $g(x)$ selon la
  distribution de $X$.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.1in)

== Linéarité et variance

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Linéarité de l'espérance], [
    $EE(X + Y) = EE(X) + EE(Y)$

    $EE(a X) = a EE(X)$

    Aucune indépendance n'est nécessaire.
  ], height: 1.9in),
  card([Variance], [
    $"Var"(X) = EE((X - EE(X))^2)$

    $= EE(X^2) - EE(X)^2$

    $"Var"(a X + b) = a^2 "Var"(X)$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.9in),
)

#v(0.7em)
#align(center)[
  #text(size: 14.5pt, weight: "bold", fill: accent-dark)[
    L'écart-type $sigma(X) = sqrt("Var"(X))$ s'exprime dans la même unité que $X$.
  ]
]

== Variables aléatoires indépendantes

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Définition], [
    Pour tous ensembles $A$ et $B$,

    $PP(X in A, Y in B)$

    $= PP(X in A) PP(Y in B)$.
  ], height: 1.9in),
  card([Conséquence], [
    Si les espérances existent,

    $EE(X Y) = EE(X) EE(Y)$.

    De plus, $g(X)$ et $h(Y)$ restent indépendantes.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.9in),
)

#v(0.6em)
#card([Deux lancers de pièce], [
  Si $X$ et $Y$ indiquent l'obtention de face aux premier et second lancers,
  alors $PP(X=x,Y=y)=1/4=(1/2)(1/2)$ : la distribution conjointe se factorise.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.05in)

== Covariance et corrélation

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Covariance], [
    $"Cov"(X,Y)$

    $= EE((X-EE(X))(Y-EE(Y)))$

    Dépend des unités de mesure.
  ], height: 1.85in),
  card([Corrélation], [
    $"Corr"(X,Y) = "Cov"(X,Y)/(sigma(X) sigma(Y))$

    Sans unité et comprise entre $-1$ et $1$.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.85in),
)

#v(0.7em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Indépendance], [Implique une covariance nulle.], height: 0.85in),
  card([Covariance nulle], [N'implique généralement pas l'indépendance.], fill: pale-red, stroke: rgb("#ecc1c1"), height: 0.85in),
)

== Vecteurs aléatoires

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  [
    #card([Moyenne et covariance], [
      $mu = EE(X)$

      $Sigma = EE((X-mu)(X-mu)^top)$

      La diagonale contient les variances; les autres termes, les covariances.
    ], height: 2.05in)
  ],
  [
    #card([Loi normale multivariée], [
      $X tilde cal(N)_p(mu, Sigma)$

      Sa densité dépend de la distance quadratique

      #align(center)[$(x-mu)^top Sigma^(-1)(x-mu)$]
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.05in)
  ],
)

#v(0.65em)
#text(size: 13pt, fill: muted)[
  La normale multivariée intervient notamment dans l'analyse discriminante et
  dans les modèles de mélanges gaussiens.
]

= Statistiques

== De la population à l'échantillon

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.55em,
  align: horizon,
  card([Population], [Distribution théorique et paramètres inconnus.], height: 1.15in),
  text(size: 24pt, fill: accent)[→],
  card([Échantillon], [$X_1, dots, X_n$ indépendantes et de même distribution.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.15in),
)

#v(0.85em)
#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.55em,
  align: horizon,
  card([Estimateur], [Fonction aléatoire de l'échantillon avant l'observation.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.15in),
  text(size: 24pt, fill: accent)[→],
  card([Estimation], [Valeur numérique obtenue après avoir observé les données.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.15in),
)

== Moyenne et covariance empiriques

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Moyenne empirique], [
    $hat(mu) = 1/n sum_(i=1)^n X_i$

    Centre du nuage d'observations.
  ], height: 1.6in),
  card([Covariance empirique], [
    $hat(Sigma) = 1/(n-1) sum_(i=1)^n$
    $(X_i-hat(mu))(X_i-hat(mu))^top$

    Dispersion et dépendances linéaires.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.6in),
)

#v(0.8em)
#card([Pourquoi $n-1$?], [
  Une contrainte est utilisée pour estimer la moyenne à partir des mêmes
  observations. La correction par $n-1$ rend l'estimateur de covariance sans biais.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.05in)

== Des estimateurs sans biais

#align(center)[
  #formula([
    $EE(hat(mu)) = mu quad "et" quad EE(hat(Sigma)) = Sigma$
  ], fill: pale, height: 1.05in)
]

#v(0.8em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Pour la moyenne], [
    $EE(hat(mu))$
    $= 1/n sum_(i=1)^n EE(X_i)$
    $= mu$.
  ], height: 1.5in),
  card([Pour la covariance], [
    La somme des carrés centrés par $hat(mu)$ a pour espérance $(n-1)Sigma$.
    La division par $n-1$ corrige donc le biais.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.5in),
)

== Corrélation empirique

#grid(
  columns: (1fr, auto, 1fr),
  gutter: 0.6em,
  align: horizon,
  card([Écarts-types], [
    $hat(D) = "diag"(hat(sigma)_1, dots, hat(sigma)_p)$
  ], height: 1.2in),
  text(size: 24pt, fill: accent)[→],
  card([Corrélation], [
    $hat(R) = hat(D)^(-1) hat(Sigma) hat(D)^(-1)$
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.2in),
)

#v(0.85em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Pourquoi standardiser?], [Comparer des variables dont les unités ou les ordres de grandeur diffèrent.], height: 1.05in),
  card([Application], [ACP fondée sur les corrélations plutôt que sur les covariances.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.05in),
)

== Interpréter une estimation

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Variabilité], [
    Un nouvel échantillon produirait une autre estimation.
  ], height: 1.2in),
  card([Représentativité], [
    Une grande taille ne corrige pas un biais de sélection.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.2in),
  card([Stabilité], [
    Axes, groupes et modèles héritent de l'incertitude des données.
  ], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.2in),
)

#v(0.75em)
#card([Évaluation prédictive], [
  Un taux d'erreur de validation estime une performance future : il n'est pas
  une vérité exacte. La validation croisée réduit une partie de la variabilité,
  sans réparer un échantillon mal défini ni une fuite d'information.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.15in)

= Programmation reproductible

== Qu'est-ce qu'une analyse reproductible?

#align(center)[
  #block(width: 88%, inset: 14pt, radius: 6pt, fill: pale, stroke: 0.9pt + rgb("#bedbd5"))[
    #align(center)[
      #text(size: 18pt, weight: "bold", fill: accent-dark)[Reproductibilité]
      #v(0.45em)
      #text(size: 13.5pt, fill: ink)[
        Une autre personne peut reconstruire les résultats à partir des mêmes
        données, du même code et des mêmes instructions.
      ]
    ]
  ]
]

#v(0.75em)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 0.55em,
  card([Entrées], [Données et provenance.], height: 0.95in),
  card([Code], [Transformations versionnées.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 0.95in),
  card([Environnement], [Versions des dépendances.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 0.95in),
  card([Exécution], [Procédure explicite et testée.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in),
)

== Organiser un projet

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #block(
      width: 100%,
      height: 2.8in,
      inset: 11pt,
      radius: 5pt,
      fill: rgb("#f7f9fa"),
      stroke: 0.7pt + rgb("#d8e0e3"),
    )[
      #text(size: 11.5pt, font: "DejaVu Sans Mono")[
        projet/
        #linebreak()├── README.md
        #linebreak()├── data/
        #linebreak()│   ├── raw/
        #linebreak()│   └── processed/
        #linebreak()├── src/
        #linebreak()├── reports/
        #linebreak()├── results/
        #linebreak()└── tests/
      ]
    ]
  ],
  [
    #card([Séparer les rôles], [
      - données brutes en lecture seule;
      - données transformées régénérables;
      - fonctions et étapes dans `src/`;
      - rapports distincts des résultats;
      - tests automatiques;
      - commande d'exécution dans `README.md`.
    ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.8in)
  ],
)

#v(0.55em)
#align(center)[#tag([Les données brutes sont une entrée, pas un espace de travail.])]

== Une chaîne de calcul explicite

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 0.35em,
  align: horizon,
  card([Importer], [Types, noms, provenance.], height: 1.05in),
  text(size: 20pt, fill: accent)[→],
  card([Valider], [Unités, plages, manque.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.05in),
  text(size: 20pt, fill: accent)[→],
  card([Transformer], [Variables, filtres, jointures.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.05in),
  text(size: 20pt, fill: accent)[→],
  card([Produire], [Modèles, figures, rapports.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.05in),
)

#v(0.85em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Paramètres explicites], [Chemins, graines, seuils et hyperparamètres regroupés dans une configuration.], height: 1.0in),
  card([Contrôles automatiques], [Arrêter l'exécution si une hypothèse essentielle n'est pas satisfaite.], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.0in),
)

== Dépendances et environnement

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([R], [
    `renv` crée un environnement propre au projet.

    `renv.lock` enregistre les versions.

    `snapshot()` fige; `restore()` reconstruit.
  ], height: 2.0in),
  card([Python], [
    `venv` isole les bibliothèques.

    `uv.lock` verrouille les dépendances.

    `uv sync` reconstruit l'environnement.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.0in),
)

#v(0.65em)
#card([À documenter aussi], [
  Version du langage, système d'exploitation, bibliothèques système et matériel
  lorsque le calcul en dépend. Un conteneur ne remplace pas la documentation.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.0in)

== Aléatoire et déterminisme

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([R], [
    `set.seed(2026)`

    Documenter aussi `RNGkind()` et `RNGversion()` pour une expérience sensible.
  ], height: 1.65in),
  card([Python / NumPy], [
    `rng = np.random.default_rng(2026)`

    Utiliser un générateur explicite plutôt qu'un état global caché.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.65in),
)

#v(0.7em)
#card([Une graine ne suffit pas toujours], [
  L'algorithme du générateur, le parallélisme, les bibliothèques numériques et le
  matériel peuvent modifier les résultats. On documente la graine *et*
  l'environnement.
], fill: pale-red, stroke: rgb("#ecc1c1"), height: 1.1in)

== Contrôle de version avec Git

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([À versionner], [
    - code;
    - documentation;
    - configurations;
    - petits fichiers de données autorisés;
    - tests.
  ], height: 2.05in),
  card([Bonnes pratiques], [
    - commits petits et cohérents;
    - messages informatifs;
    - relire les différences;
    - utiliser `.gitignore`;
    - ne jamais enregistrer de secret.
  ], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 2.05in),
)

#v(0.6em)
#align(center)[
  #text(size: 14.5pt, weight: "bold", fill: accent-dark)[
    Git conserve l'histoire des fichiers; il ne remplace ni sauvegarde ni archivage.
  ]
]

== Rapports exécutables

#grid(
  columns: (1fr, 1fr),
  gutter: 0.9em,
  card([Principe], [
    Relier dans un même document :

    - texte;
    - code;
    - tableaux;
    - figures;
    - résultats numériques.
  ], height: 2.1in),
  card([Risque des notebooks], [
    Un état caché peut faire dépendre une cellule d'un objet absent du document
    final.

    Redémarrer puis tout exécuter dans l'ordre.
  ], fill: pale-red, stroke: rgb("#ecc1c1"), height: 2.1in),
)

#v(0.6em)
#card([Objectif opérationnel], [
  Une commande unique devrait lancer l'analyse complète ou produire le rapport.
  Sinon, l'ordre des commandes et leurs entrées doivent être documentés.
], fill: pale-orange, stroke: rgb("#ead4ad"), height: 0.95in)

== Liste de vérification

#grid(
  columns: (1fr, 1fr),
  gutter: 0.5em,
  check([Données sources et provenance identifiées.]),
  check([Transformations réalisées par du code versionné.]),
  check([Chemins relatifs à la racine du projet.]),
  check([Paramètres et graines explicites.]),
  check([Versions des dépendances verrouillées.]),
  check([Sorties supprimables puis régénérables.]),
  check([Rapport exécutable dans un environnement propre.]),
  check([Hypothèses vérifiées automatiquement.]),
  check([Installation et exécution décrites dans le README.]),
  check([Limites de reproduction documentées.]),
)

== À retenir

#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Algèbre linéaire], [La géométrie des matrices structure les méthodes multivariées.], height: 1.02in),
  card([Probabilités], [Les distributions transforment l'incertitude en objets calculables.], fill: pale-blue, stroke: rgb("#c7d8e4"), height: 1.02in),
  card([Statistiques], [Un estimateur varie avec l'échantillon et doit être interprété avec ses limites.], fill: pale-purple, stroke: rgb("#d9cbe4"), height: 1.02in),
  card([Reproductibilité], [Un résultat doit pouvoir être reconstruit à partir d'entrées et d'instructions explicites.], fill: pale-orange, stroke: rgb("#ead4ad"), height: 1.02in),
)

#v(0.75em)
#align(center)[
  #text(size: 18pt, weight: "bold", fill: accent-dark)[Questions?]
]
