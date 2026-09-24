// STT-2200 — Analyse factorielle des correspondances (AFC).
// Source : lectures/dimension_reduction.typ,
// section « L'analyse factorielle des correspondances ».
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/analyse_factorielle_correspondances.typ
#import "../styles/slides.typ": *
#import "../styles/math.typ": diag, rang, ctr, inertia

#show: course-slides.with(
  title: [Analyse factorielle des correspondances],
  footer-title: [Analyse factorielle des correspondances],
)

#title-slide()

= Des effectifs aux profils

== À quelles questions répond l'AFC ?

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux variables qualitatives], [
    On croise les modalités dans un *tableau de contingence*.

    Exemple : programme d'études et type d'admission.
  ], height: 2.3in),
  card([Une représentation des associations], [
    Quels programmes ont des profils d'admission semblables ?

    Quelles modalités caractérisent les différences ?
  ], fill: pale-blue, height: 2.3in),
)

#v(0.65em)
#takeaway([Les points du plan sont des modalités, et non des étudiants.])

== Un exemple fil conducteur : 200 étudiants

#course-table(
  columns: (1.2fr, 1fr, 1fr, 1.35fr, 0.8fr),
  table.header([*Programme*], [*Directe*], [*Passerelle*],
    [*Reprise d'études*], [*Total*]),
  [Sciences], [60], [25], [15], [100],
  [Lettres], [10], [35], [15], [60],
  [Gestion], [10], [10], [20], [40],
  [*Total*], [*80*], [*70*], [*50*], [*200*],
)

#v(0.65em)
#formula([
  $ N = (n_(i j)), quad n_(i +) = sum_j n_(i j), quad
    n_(+ j) = sum_i n_(i j), quad n = sum_(i,j) n_(i j) $
])
#v(0.4em)
#small([Données fictives du chapitre : $I = 3$ programmes et $J = 3$ types d'admission.])

== Le dénominateur dépend de la question

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Profil-ligne], [
    Répartition des admissions *dans un programme*.

    $ a_(i j) = n_(i j) / n_(i +) $

    Sciences : $(0.60, 0.25, 0.15)$.

    La somme sur $j$ vaut 1.
  ], height: 3.1in),
  card([Profil-colonne], [
    Répartition des programmes *pour une admission*.

    $ b_(i j) = n_(i j) / n_(+ j) $

    Directe : $(0.75, 0.125, 0.125)$.

    La somme sur $i$ vaut 1.
  ], fill: pale-blue, height: 3.1in),
)

#v(0.65em)
#takeaway([L'AFC compare des distributions conditionnelles, pas les seuls effectifs.])

== Comparer les compositions des programmes

#align(center)[
  #image("../figures/afc_profils.svg", width: 95%, height: 3.8in,
    fit: "contain",
    alt: "Profils d'admission : Sciences 60 %, 25 %, 15 % ; Lettres 16,7 %, "
      + "58,3 %, 25 % ; Gestion 25 %, 25 %, 50 %. Le profil global est "
      + "40 %, 35 %, 25 % pour Directe, Passerelle et Reprise d'études.")
]

#v(0.35em)
#takeaway([Chaque barre représente 100 % du groupe, quelle que soit sa taille.])

== Les masses pondèrent les profils

#formula([$ p_(i j) = n_(i j) / n, quad P = (p_(i j)) $])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Masses des lignes], [
    $ r_i = n_(i +) / n $

    $ r = (0.50, 0.30, 0.20)^top $

    Sciences représente la moitié des étudiants.
  ], height: 2.35in),
  card([Masses des colonnes], [
    $ c_j = n_(+ j) / n $

    $ c = (0.40, 0.35, 0.25)^top $

    Un quart des étudiants sont en reprise d'études.
  ], fill: pale-blue, height: 2.35in),
)

#v(0.45em)
#small([Toutes les masses doivent être positives : retirer les lignes ou colonnes entièrement nulles.])

== Le centre de chaque nuage est un profil moyen

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Nuage des lignes], [
    Le profil moyen est $c$.

    $ sum_(i=1)^I r_i a_(i j) = c_j $

    Ici : $(0.40, 0.35, 0.25)$.
  ], height: 2.6in),
  card([Nuage des colonnes], [
    Le profil moyen est $r$.

    $ sum_(j=1)^J c_j b_(i j) = r_i $

    Ici : $(0.50, 0.30, 0.20)$.
  ], fill: pale-blue, height: 2.6in),
)

#v(0.65em)
#takeaway([Les moyennes sont pondérées par les masses, pas calculées à poids égaux.])

= Indépendance et géométrie

== L'indépendance fournit la situation de référence

#formula([
  $ P = r c^top, quad e_(i j) = n r_i c_j
    = (n_(i +) n_(+ j)) / n $
])

#v(0.55em)
#course-table(
  columns: (1.3fr, 1fr, 1fr, 1.4fr),
  table.header([*Effectifs attendus*], [*Directe*], [*Passerelle*], [*Reprise d'études*]),
  [Sciences], [40], [35], [25],
  [Lettres], [24], [21], [15],
  [Gestion], [16], [14], [10],
)

#v(0.65em)
#takeaway([Sous l'indépendance, tous les profils-lignes sont égaux à $c$.])

== Mesurer la surreprésentation ou la sous-représentation

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Sciences et admission directe], [
    Observé : 60. Attendu : 40.

    $ n_(i j) / e_(i j) = 60 / 40 = 1.5 $

    Cette combinaison est *surreprésentée* par rapport à l'indépendance.
  ], height: 2.65in),
  card([Sciences et reprise d'études], [
    Observé : 15. Attendu : 25.

    $ n_(i j) / e_(i j) = 15 / 25 = 0.6 $

    Cette combinaison est *sous-représentée* par rapport à l'indépendance.
  ], fill: pale-blue, height: 2.65in),
)

#v(0.65em)
#takeaway([Le repère pertinent est l'effectif attendu, pas la valeur zéro.])

== La distance du chi-deux compare les profils

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Entre deux lignes], [
    $ d_(chi^2)^2(i, ell) = sum_(j=1)^J
      (a_(i j) - a_(ell j))^2 / c_j $

    Comparer les répartitions des admissions de deux programmes.

    Pondération par $1 / c_j$.
  ], height: 3.15in),
  card([Entre deux colonnes], [
    $ d_(chi^2)^2(j, h) = sum_(i=1)^I
      (b_(i j) - b_(i h))^2 / r_i $

    Comparer les répartitions des programmes de deux admissions.

    Pondération par $1 / r_i$.
  ], fill: pale-blue, height: 3.15in),
)

#v(0.55em)
#small([Il s'agit ici des distances au carré. Deux profils identiques sont à distance nulle.])

== Pourquoi les modalités rares pèsent-elles davantage ?

Un écart de *10 points de pourcentage* contribue différemment selon la masse.

#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Admission directe], [
    Masse : $c_j = 0.40$.

    $ 0.10^2 / 0.40 = 0.025 $
  ], height: 1.85in),
  card([Reprise d'études], [
    Masse : $c_j = 0.25$.

    $ 0.10^2 / 0.25 = 0.040 $
  ], fill: pale-blue, height: 1.85in),
)

#v(0.65em)
#takeaway([Un même écart pèse plus pour une modalité rare ; ses fluctuations aussi.])

== L'inertie résume l'écart à l'indépendance

#formula([
  $ inertia = sum_(i=1)^I sum_(j=1)^J
    (p_(i j) - r_i c_j)^2 / (r_i c_j) = chi^2 / n $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dispersion des lignes], [
    $ d_i^2 = sum_j (a_(i j) - c_j)^2 / c_j $

    $ inertia = sum_i r_i d_i^2 $
  ], height: 2.05in),
  card([Dispersion des colonnes], [
    $ delta_j^2 = sum_i (b_(i j) - r_i)^2 / r_i $

    $ inertia = sum_j c_j delta_j^2 $
  ], fill: pale-blue, height: 2.05in),
)

#v(0.6em)
#takeaway([Les deux nuages ont la même inertie : on ne les additionne pas.])

== Inertie descriptive et statistique du chi-deux

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans notre tableau], [
    $ chi^2 = sum_(i,j) (n_(i j) - e_(i j))^2 / e_(i j) $

    $ chi^2 = 47.75 $

    $ inertia = 47.75 / 200 = 0.23875 $
  ], height: 2.9in),
  card([Si tous les effectifs doublent], [
    Profils et masses inchangés.

    Même inertie et même carte.

    Mais $chi^2$ double : il dépend de la taille de l'échantillon.
  ], fill: pale-blue, height: 2.9in),
)

#v(0.65em)
#takeaway([L'AFC décrit les associations ; elle ne remplace pas un test statistique.])

= Construire les axes factoriels

== Standardiser les écarts à l'indépendance

#formula([
  $ S = D_r^(-1/2) (P - r c^top) D_c^(-1/2) $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Matrices des masses], [
    $ D_r = diag(r_1, dots, r_I) $

    $ D_c = diag(c_1, dots, c_J) $

    Matrices diagonales à éléments positifs.
  ], height: 2.6in),
  card([Résidus standardisés], [
    $ S_(i j) = (p_(i j) - r_i c_j) / sqrt(r_i c_j) $

    $ sum_(i,j) S_(i j)^2 = inertia $

    La matrice $S$ porte toute l'inertie.
  ], fill: pale-blue, height: 2.6in),
)

== Une décomposition en valeurs singulières

#formula([
  $ S = U D V^top, quad D = diag(sigma_1, dots, sigma_(r_S)) $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Axes non triviaux], [
    $ sigma_1 >= dots >= sigma_(r_S) > 0 $

    Les colonnes de $U$ et de $V$ sont orthonormales.

    On omet les valeurs singulières nulles.
  ], height: 2.7in),
  card([Combien d'axes au maximum ?], [
    $ r_S = rang(S) <= min(I - 1, J - 1) $

    Tableau $3 times 3$ : au plus 2 axes.

    Tableau à 2 lignes : au plus 1 axe.
  ], fill: pale-blue, height: 2.7in),
)

== Les coordonnées principales donnent la carte

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Lignes], [
    $ F = D_r^(-1/2) U D $

    $F_(i k)$ est la coordonnée du programme $i$ sur l'axe $k$.

    Un point par programme.
  ], height: 2.7in),
  card([Colonnes], [
    $ G = D_c^(-1/2) V D $

    $G_(j k)$ est la coordonnée de l'admission $j$ sur l'axe $k$.

    Un point par type d'admission.
  ], fill: pale-blue, height: 2.7in),
)

#v(0.65em)
#takeaway([Avec tous les axes, les distances dans chaque nuage reproduisent celles du chi-deux.])

== Chaque axe porte une partie de l'inertie

#formula([
  $ lambda_k = sigma_k^2, quad
    sum_i r_i F_(i k)^2 = sum_j c_j G_(j k)^2 = lambda_k $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ordre des axes], [
    Le premier conserve le plus d'inertie.

    Les suivants résument la structure restante, dans des directions orthogonales.
  ], height: 2.25in),
  card([Part cumulée sur $q$ axes], [
    $ sum_(k=1)^(r_S) lambda_k = inertia $

    $ R_q = (sum_(k=1)^q lambda_k) / inertia $
  ], fill: pale-blue, height: 2.25in),
)

== Deux axes suffisent pour notre exemple

#course-table(
  columns: (0.65fr, 1fr, 1.2fr, 1.2fr),
  table.header([*Axe*], [*$lambda_k$*], [*Part d'inertie*], [*Part cumulée*]),
  [1], [0,17021], [71,29 %], [71,29 %],
  [2], [0,06854], [28,71 %], [100 %],
)

#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un axe], [
    Résumé principal, mais 28,71 % de l'inertie reste hors de la droite.
  ], height: 1.6in),
  card([Le plan complet], [
    Les deux axes restituent toute l'inertie du tableau.
  ], fill: pale-blue, height: 1.6in),
)

== Choisir la dimension sans confondre les critères

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Choix de $q$], [
    Examiner l'éboulis des valeurs propres, l'inertie cumulée et l'interprétation.

    Pour atteindre 80 % ici, il faut les deux axes.
  ], height: 2.7in),
  card([Deux précautions], [
    La règle « valeur propre supérieure à 1 » de l'ACP normée ne s'applique pas.

    100 % d'inertie représentée ne signifie pas une association parfaite.
  ], fill: pale-orange, height: 2.7in),
)

#v(0.65em)
#takeaway([La part représentée mesure la fidélité du résumé, pas la force absolue de l'association.])

= Barycentres et lecture du plan

== Coordonnées principales et coordonnées standard

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Coordonnées principales], [
    $ F = D_r^(-1/2) U D $

    $ G = D_c^(-1/2) V D $

    Inertie pondérée sur l'axe $k$ : $lambda_k$ pour chaque nuage.
  ], height: 2.9in),
  card([Coordonnées standard], [
    $ Phi = F D^(-1) = D_r^(-1/2) U $

    $ Gamma = G D^(-1) = D_c^(-1/2) V $

    Inertie pondérée sur chaque axe : 1 pour chaque nuage.
  ], fill: pale-blue, height: 2.9in),
)

#v(0.55em)
#small([On travaille uniquement avec les axes de valeur singulière strictement positive.])

== Les formules de transition sont barycentriques

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une ligne à partir des colonnes], [
    $ F_(i k) = sum_(j=1)^J a_(i j) Gamma_(j k) $

    Coordonnée principale de la ligne = moyenne des coordonnées *standard* des colonnes.

    Poids : son profil-ligne.
  ], height: 3.15in),
  card([Une colonne à partir des lignes], [
    $ G_(j k) = sum_(i=1)^I b_(i j) Phi_(i k) $

    Coordonnée principale de la colonne = moyenne des coordonnées *standard* des lignes.

    Poids : son profil-colonne.
  ], fill: pale-blue, height: 3.15in),
)

#v(0.55em)
#takeaway([Ces relations expliquent pourquoi les deux nuages sont liés.])

== Exemple : placer Sciences sur le premier axe

#course-table(
  columns: (1.3fr, 1fr, 1fr, 1.3fr),
  table.header([], [*Directe*], [*Passerelle*], [*Reprise d'études*]),
  [Profil de Sciences], [0,60], [0,25], [0,15],
  [Coordonnée $Gamma_(j 1)$], [1,2243], [−0,7883], [−0,8553],
)

#v(0.75em)
#formula([
  $ F_("Sciences", 1)
    approx 0.60 times 1.2243 + 0.25 times (-0.7883)
      + 0.15 times (-0.8553)
    approx 0.4092 $
])

#v(0.7em)
#takeaway([Le poids élevé de l'admission directe place Sciences du côté positif de l'axe 1.])

== Vérifier la convention de représentation

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Carte symétrique : $F$ et $G$], [
    Deux nuages en coordonnées principales.

    Distances du chi-deux dans chaque nuage, si tous les axes sont gardés.

    $ F_(i k) = 1 / sigma_k sum_j a_(i j) G_(j k) $
  ], height: 3.2in),
  card([Carte asymétrique : $F$ et $Gamma$], [
    Lignes principales, colonnes standard.

    Barycentres directement lisibles.

    Les distances entre colonnes ne sont plus celles du chi-deux.
  ], fill: pale-blue, height: 3.2in),
)

#v(0.55em)
#small([Sur une carte symétrique, le facteur $1 / sigma_k$ ne doit pas être oublié.])

== Le plan factoriel de notre tableau

#align(center)[
  #image("../figures/afc_plan.svg", height: 4.35in, width: 100%, fit: "contain",
    alt: "Carte symétrique : Sciences et Directe sont du côté positif de l'axe 1. "
      + "Gestion et Reprise d'études sont du côté positif de l'axe 2, Lettres "
      + "et Passerelle du côté négatif. Les deux axes portent 100 % de l'inertie.")
]
#small([Carte symétrique : $F$ et $G$. Axe 1 : 71,29 %. Axe 2 : 28,71 %.])

== Donner un sens aux oppositions

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Axe 1 : admission directe], [
    Sciences et Directe sont du côté positif.

    Lettres et Gestion sont de l'autre côté.

    Sciences : 60 % d'admissions directes, contre 40 % globalement.
  ], height: 3in),
  card([Axe 2 : reprise et passerelle], [
    Gestion et Reprise s'opposent à Lettres et Passerelle.

    Gestion : 50 % de reprises, contre 25 % globalement.

    Lettres : 58,3 % de passerelles, contre 35 %.
  ], fill: pale-blue, height: 3in),
)

#v(0.55em)
#takeaway([Le signe d'un axe est arbitraire : inverser les deux nuages ne change pas l'analyse.])

== Quelles distances peut-on interpréter ?

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans un même nuage], [
    Deux programmes proches ont des profils d'admission semblables.

    Deux admissions proches ont des répartitions de programmes semblables.

    Vérifier la qualité sur le plan retenu.
  ], height: 3.1in),
  card([Entre les deux nuages], [
    Une distance programme–admission ne mesure *pas directement* leur association.

    Cela reste vrai même si le plan restitue 100 % de l'inertie.

    Revenir aux profils et aux effectifs attendus.
  ], fill: pale-orange, height: 3.1in),
)

#v(0.55em)
#small([Une projection sur moins d'axes réduit les distances : elle peut masquer des différences.])

== Relier les coordonnées à l'association

#formula([
  $ p_(i j) / (r_i c_j) - 1 =
    sum_(k=1)^(r_S) (F_(i k) G_(j k)) / sigma_k $
])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une somme sur les axes], [
    Même signe : contribution positive.

    Signes opposés : contribution négative.

    Tous les axes donnent le rapport exact.
  ], height: 2.45in),
  card([Gestion et reprise d'études], [
    Observé : 20. Attendu : 10.

    $ n_(i j) / e_(i j) = 2 $

    Une surreprésentation confirmée par le tableau.
  ], fill: pale-blue, height: 2.45in),
)

== Être proche du centre : deux situations

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans l'espace complet], [
    L'origine représente le profil moyen.

    Une faible distance au centre indique un profil peu spécifique.

    Un profil égal à $c$ donne une ligne à l'origine.
  ], height: 2.8in),
  card([Sur un plan réduit], [
    Une modalité proche du centre peut avoir des coordonnées importantes sur les axes omis.

    Une position centrale ne suffit donc pas à conclure.
  ], fill: pale-orange, height: 2.8in),
)

#v(0.65em)
#takeaway([Toujours distinguer la position projetée de la position dans l'espace complet.])

= Contributions et qualité

== Les contributions indiquent qui construit l'axe

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Contribution d'une ligne], [
    $ ctr_(i k)^r = (r_i F_(i k)^2) / lambda_k $

    $ sum_i ctr_(i k)^r = 1 $

    Repère moyen : $1 / I$.
  ], height: 2.7in),
  card([Contribution d'une colonne], [
    $ ctr_(j k)^c = (c_j G_(j k)^2) / lambda_k $

    $ sum_j ctr_(j k)^c = 1 $

    Repère moyen : $1 / J$.
  ], fill: pale-blue, height: 2.7in),
)

#v(0.65em)
#takeaway([Les contributions totalisent 100 % séparément pour les lignes et les colonnes.])
#v(0.35em)
#small([Les contributions moyennes sont des repères descriptifs, pas des seuils de significativité.])

== Les cosinus carrés mesurent la qualité de représentation

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Qualité sur un axe], [
    Pour une ligne : $ cos^2_(i k) = F_(i k)^2 / d_i^2 $.

    Pour une colonne : $ cos^2_(j k) = G_(j k)^2 / delta_j^2 $.

    Part de la distance au centre visible sur cet axe.
  ], height: 2.95in),
  card([Qualité sur un plan], [
    Additionner les cosinus carrés des axes retenus.

    Proche de 1 : point bien représenté.

    Proche de 0 : l'essentiel de son écart au centre est ailleurs.
  ], fill: pale-blue, height: 2.95in),
)

#v(0.55em)
#small([Pour un profil exactement moyen, la distance au centre est nulle : le cosinus carré est indéfini.])

== Exemple : Sciences sur le premier axe

#small([$r_i = 0.50$, $F_(i 1) approx 0.40923$, $d_i^2 approx 0.16857$, $lambda_1 approx 0.17021$.])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Contribution : 49,2 %], [
    $ (0.50 times 0.40923^2) / 0.17021 approx 0.492 $

    Sciences fournit près de la moitié de l'inertie de l'axe 1.
  ], height: 2.35in),
  card([Qualité : 99,3 %], [
    $ 0.40923^2 / 0.16857 approx 0.993 $

    L'axe 1 restitue presque toute la distance de Sciences au centre.
  ], fill: pale-blue, height: 2.35in),
)

#v(0.65em)
#takeaway([Contribution : rôle dans l'axe. Cosinus carré : fidélité pour le point.])

== Une bonne inertie globale ne suffit pas pour chaque point

#course-table(
  columns: (1.1fr, 1fr, 1fr, 1fr, 1fr),
  table.header([*Programme*], [*Contrib.\ axe 1*], [*Contrib.\ axe 2*],
    [*$cos^2$\ axe 1*], [*$cos^2$\ axe 2*]),
  [Sciences], [49,2 %], [0,8 %], [99,3 %], [0,7 %],
  [Lettres], [38,9 %], [31,1 %], [75,6 %], [24,4 %],
  [Gestion], [11,9 %], [68,1 %], [30,3 %], [69,7 %],
)

#v(0.75em)
#takeaway([
  L'axe 1 porte 71,29 % de l'inertie globale, mais ne représente
  que 30,3 % de l'écart de Gestion au centre.
])
#v(0.4em)
#small([Les contributions somment à 100 % par colonne ; les qualités somment à 100 % par ligne sur le plan complet.])

= Conduire et discuter l'analyse

== Une démarche en quatre étapes

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Vérifier le tableau], [
    Population, modalités, valeurs manquantes, marges positives et faibles effectifs.
  ], height: 1.65in),
  card([2. Examiner les profils], [
    Comparer les compositions et les effectifs attendus sous l'indépendance.
  ], fill: pale-blue, height: 1.65in),
  card([3. Choisir les axes], [
    Valeurs propres, inertie cumulée et qualité des modalités étudiées.
  ], fill: pale-purple, height: 1.65in),
  card([4. Interpréter et vérifier], [
    Contributions, cosinus carrés, oppositions et retour au tableau initial.
  ], fill: pale-orange, height: 1.65in),
)

#v(0.55em)
#takeaway([Ne pas centrer-réduire les colonnes d'effectifs comme pour une ACP.])

== Projeter un profil supplémentaire

Un nouveau programme a un profil $a_*$ sur les *mêmes types d'admission*,
avec $sum_j a_(* j) = 1$.

#v(0.55em)
#formula([$ F_(* k) = sum_(j=1)^J a_(* j) Gamma_(j k) $])

#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Projection sans réajustement], [
    Le nouveau profil ne change ni les axes ni l'inertie des modalités actives.
  ], height: 1.7in),
  card([Exemple : le profil moyen], [
    $(0.40, 0.35, 0.25)$ se projette à l'origine sur tous les axes.
  ], fill: pale-blue, height: 1.7in),
)

#v(0.4em)
#small([Pour rendre le nouveau programme actif, il faut refaire l'AFC du tableau augmenté.])

== Modalités rares et cellules nulles

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Modalités rares], [
    Quelques observations peuvent déplacer fortement un profil.

    Une grande distance au centre n'implique pas une forte contribution : la masse compte.

    Regrouper seulement si le sens le justifie.
  ], height: 3.2in),
  card([Que signifie un zéro ?], [
    Une cellule nulle est permise si les marges restent positives.

    Distinguer une absence observée d'une combinaison impossible.

    Un zéro structurel peut rendre l'indépendance peu pertinente.
  ], fill: pale-orange, height: 3.2in),
)

== Ce que la carte ne permet pas de conclure

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Association, pas causalité], [
    Le lien entre programme et admission ne prouve pas un effet causal.

    Une carte de modalités ne prédit pas le comportement de chaque individu.
  ], height: 2.65in),
  card([Une géométrie propre à l'AFC], [
    Changer les catégories ou la population change les masses et la carte.

    Les règles d'angles du cercle des corrélations de l'ACP ne s'appliquent pas.
  ], fill: pale-orange, height: 2.65in),
)

#v(0.65em)
#takeaway([L'interprétation dépend du tableau étudié et de la convention de coordonnées.])

== À vous de jouer : Lettres et Passerelle

#course-table(
  columns: (1.5fr, 1fr, 1fr, 1fr),
  table.header([*Cellule étudiée*], [*Observé*], [*Total Lettres*], [*Total Passerelle*]),
  [Lettres × Passerelle], [35], [60], [70],
)

#v(0.6em)
L'effectif total vaut 200.

+ Quel est l'effectif attendu sous l'indépendance ?
+ Quelle est la part de passerelles en Lettres, comparée à la part globale ?
+ La combinaison est-elle surreprésentée ou sous-représentée ?

== Correction : revenir au tableau

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Effectif attendu et rapport], [
    $ e_(i j) = (60 times 70) / 200 = 21 $

    $ n_(i j) / e_(i j) = 35 / 21 approx 1.67 $

    La combinaison est surreprésentée.
  ], height: 2.7in),
  card([Comparer les proportions], [
    En Lettres : $35 / 60 approx 58.3 %$.

    Globalement : $70 / 200 = 35 %$.

    Le profil confirme l'association lue dans le tableau.
  ], fill: pale-blue, height: 2.7in),
)

#v(0.65em)
#takeaway([La proximité visuelle ne remplace jamais la vérification des proportions.])

== L'essentiel à retenir

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([L'objet], [
    Résumer les associations entre deux variables qualitatives à partir des profils.
  ], height: 1.65in),
  card([La géométrie], [
    Masses, distance du chi-deux et inertie par rapport à l'indépendance.
  ], fill: pale-blue, height: 1.65in),
  card([La lecture], [
    Oppositions et distances dans un même nuage, avec une qualité suffisante.
  ], fill: pale-purple, height: 1.65in),
  card([Les diagnostics], [
    Contributions pour expliquer les axes ; cosinus carrés pour interpréter les points.
  ], fill: pale-orange, height: 1.65in),
)

#v(0.55em)
#small([Support : chapitre « Réduction de dimension », section « L'analyse factorielle des correspondances ».])
