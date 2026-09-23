// STT-2200 : introduction à l'apprentissage non supervisé.
// Source : lectures/unsupervised.typ, section « Introduction » uniquement.
// Figures et vérification numérique : figures/unsupervised_introduction.py.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/unsupervised.typ
// --root . autorise l'accès au dossier voisin figures/.
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let accent = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")

#let card(title, body, fill: pale, height: 2.2in) = block(
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
  set text(size: 18pt)
  table(
    columns: columns, inset: 8pt, align: center + horizon,
    stroke: 0.6pt + rgb("#d4dfe1"),
    fill: (x, y) => if y == 0 { pale } else { none },
    ..cells,
  )
}

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => [STT-2200 · Apprentissage non supervisé],
  config-info(
    title: [Apprentissage non supervisé],
    subtitle: [Introduction · STT-2200],
    author: [Steven Golovkine],
    date: [Automne 2026],
    institution: [Université Laval],
  ),
)

#set text(lang: "fr", size: 18pt, fill: ink)
#set par(justify: false, leading: 0.4em)
#set list(indent: 1em, body-indent: 0.4em, spacing: 0.4em)
#set enum(indent: 1em, body-indent: 0.4em, spacing: 0.4em)
#show raw: set text(size: 16pt)

#title-slide()

= Construire des groupes

== Le parcours du cours

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Groupes et similarité], [
    Comprendre ce que l'on cherche sans variable réponse.
  ], height: 1.55in),
  card([Qualité d'une partition], [
    Relier les critères aux distances dans les groupes et entre groupes.
  ], fill: pale-blue, height: 1.55in),
  card([Exemple numérique], [
    Comparer trois partitions des mêmes six observations.
  ], fill: pale-purple, height: 1.55in),
  card([Stabilité et interprétation], [
    Examiner les choix de l'analyse et la portée des résultats.
  ], fill: pale-orange, height: 1.55in),
)

== Classification supervisée et regroupement

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Classification supervisée], [
    On observe des couples $(x_i,y_i)$.

    Les classes $y_i$ guident l'ajustement.

    On cherche à prédire la classe d'une nouvelle observation.
  ], height: 2.65in),
  card([Regroupement non supervisé], [
    On observe des vecteurs $x_i$ à $p$ composantes.

    Aucune réponse $y_i$ ne guide l'ajustement.

    Les groupes constituent un résultat à interpréter.
  ], fill: pale-blue, height: 2.65in),
)
#v(0.7em)
#takeaway([
  Le non supervisé comprend aussi la réduction de dimension et le repérage
  d'observations atypiques.
])

== La similarité dépend de la question

#course-table(
  columns: (1.2fr, 3fr),
  [*Choix*], [*Conséquence pour le regroupement*],
  [Variables], [Décrire la taille, la forme ou un autre aspect des observations.],
  [Représentation], [Transformer, coder ou standardiser les mesures.],
  [Distance], [Définir quelles différences rendent deux observations éloignées.],
)
#v(0.7em)
#takeaway([Un même tableau peut conduire à plusieurs regroupements pertinents.])
#v(0.4em)
#small([
  Les variables peuvent être quantitatives ou qualitatives.
  Leur nature guide le choix de la représentation et de la distance.
])

== Exemple : les profils des manchots

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Mesures utilisées], [
    Longueur et profondeur du bec.

    Longueur de la nageoire.

    Masse corporelle.
  ], height: 2.3in),
  card([Espèce mise de côté], [
    `species` ne participe pas à l'ajustement.

    Les groupes décrivent des profils morphologiques, qui peuvent recouper
    partiellement les espèces.
  ], fill: pale-blue, height: 2.3in),
)
#v(0.65em)
#takeaway([
  Un tableau groupes × espèces peut aider à décrire le résultat après l'ajustement.
])
#v(0.35em)
#small([
  Si l'espèce sert à choisir les variables ou $K$, cette comparaison utilise
  une information externe et ne vérifie plus ces choix de façon indépendante.
])

== Définition d'une partition

Une partition $cal(C)=(C_1,dots,C_K)$ répartit les indices des $n$ observations.
#v(0.5em)
#formula([
  $ C_g != emptyset, quad C_g inter C_h=emptyset quad (g != h) $
  $ union.big_(g=1)^K C_g={1,dots,n}, quad n_g=abs(C_g), quad sum_(g=1)^K n_g=n $
])
#v(0.6em)
#takeaway([Chaque observation appartient à un seul groupe non vide.])
#v(0.4em)
#small([
  $K$ compte les groupes, $g$ les indexe et $j$ indexe les $p$ variables.
  Le $k$ des plus proches voisins comptait des voisins.
])

== Les numéros des groupes sont arbitraires

#course-table(
  columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
  [*Observation*], [1], [2], [3], [4],
  [Partition P], [1], [1], [2], [2],
  [Partition Q], [2], [2], [1], [1],
)
#v(0.75em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Les étiquettes changent], [
    Aucune observation ne conserve son numéro de groupe.
  ], height: 1.8in),
  card([Les groupes restent identiques], [
    Les observations 1 et 2 restent ensemble, comme les observations 3 et 4.
  ], fill: pale-blue, height: 1.8in),
)

== Au-delà d'une partition stricte

#grid(
  columns: (1fr, 1fr, 1fr), gutter: 0.7em,
  card([Hiérarchie], [
    Plusieurs niveaux de regroupement emboîtés.
  ], height: 2.3in),
  card([Modèle de mélange], [
    Des probabilités d'appartenance aux composantes du modèle.
  ], fill: pale-blue, height: 2.3in),
  card([Méthode par densité], [
    Des groupes et, éventuellement, des observations isolées laissées à part.
  ], fill: pale-purple, height: 2.3in),
)
#v(0.7em)
#takeaway([La forme du résultat dépend de la méthode et de la question posée.])

= Comparer la qualité des partitions

== Les inerties dans un espace euclidien

Pour des variables numériques, $overline(x)$ est la moyenne globale
et $overline(x)_g$ celle du groupe $g$.
#v(0.4em)
#formula([$ T=sum_(i=1)^n norm(x_i-overline(x))^2 = W+B $])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Inertie intra-groupe], [
    $ W=sum_(g=1)^K sum_(i in C_g) norm(x_i-overline(x)_g)^2 $

    Dispersion autour des centres de groupe.
  ], height: 2.3in),
  card([Inertie inter-groupe], [
    $ B=sum_(g=1)^K n_g norm(overline(x)_g-overline(x))^2 $

    Éloignement des centres du centre global.
  ], fill: pale-blue, height: 2.3in),
)
#v(0.6em)
#small([
  Ici, $T$, $W$ et $B$ sont des scalaires, sans division par $n$.
  Cette décomposition utilise le carré de la distance euclidienne.
])

== Le pseudo-$R^2$

#formula([$ R^2=B/T=1-W/T, quad T>0 $])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Part d'inertie inter-groupe], [
    Une valeur élevée correspond à une faible dispersion interne
    relativement à l'inertie totale.

    Le score ne mesure pas une exactitude de classification.
  ], height: 2.6in),
  card([Effet du nombre de groupes], [
    Scinder les groupes peut réduire $W$.

    Avec un groupe par observation, $W=0$ et $R^2=1$.

    Ce critère seul ne permet pas de choisir $K$.
  ], fill: pale-orange, height: 2.6in),
)

== L'indice de Calinski-Harabasz

#formula([
  $ op("CH") = (B/(K-1))/(W/(n-K)) = B/W times (n-K)/(K-1) $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une comparaison corrigée], [
    Mettre en rapport les dispersions inter-groupe et intra-groupe.

    Tenir compte de $K$ et de $n$.
  ], height: 2.2in),
  card([Conditions et lecture], [
    $1<K<n$ et $W>0$.

    Une grande valeur favorise la séparation relative à la dispersion interne.
  ], fill: pale-blue, height: 2.2in),
)
#v(0.45em)
#small([
  Comparer les mêmes observations dans le même espace.
  Aucun seuil universel de qualité et aucune interprétation probabiliste.
])

== Silhouette : les distances moyennes

Pour $i in C_g$ avec $n_g>1$, on utilise une distance $d$ entre observations.
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans son groupe : $a_i$], [
    $ a_i=1/(n_g-1) sum_(ell in C_g, ell != i) d(x_i,x_ell) $

    Distance moyenne aux autres membres de son groupe.
  ], height: 2.5in),
  card([Vers les autres groupes : $b_i$], [
    $ b_i=min_(h != g) 1/n_h sum_(ell in C_h) d(x_i,x_ell) $

    Calculer une moyenne par autre groupe, puis retenir la plus petite.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.65em)
#takeaway([
  $b_i$ compare des distances moyennes à des groupes entiers,
  et non des distances aux centroïdes ou au voisin le plus proche.
])

== Interpréter la silhouette d'une observation

#formula([$ s_i=(b_i-a_i)/max(a_i,b_i), quad -1 <= s_i <= 1 $])
#v(0.65em)
#course-table(
  columns: (1fr, 1fr, 2.6fr),
  [*Valeur*], [*Distances*], [*Lecture géométrique*],
  [Proche de 1], [$a_i << b_i$], [Observation proche de son groupe et éloignée des autres.],
  [Proche de 0], [$a_i approx b_i$], [La distinction entre deux groupes est peu nette.],
  [Négative], [$a_i>b_i$], [Un autre groupe est plus proche en moyenne.],
)
#v(0.5em)
#small([Une silhouette négative invite à examiner l'affectation, sans révéler une vraie étiquette.])

== Silhouette moyenne et cas particuliers

#formula([$ overline(s)=1/n sum_(i=1)^n s_i, quad 2 <= K <= n-1 $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Moyenne sur les observations], [
    Chaque observation a le même poids.

    Un grand groupe contribue davantage qu'un petit groupe à la moyenne globale.
  ], height: 2.3in),
  card([Conventions], [
    Groupe réduit à une observation : $s_i=0$.

    Cas dégénéré $a_i=b_i=0$ : $s_i=0$.

    Examiner aussi les silhouettes individuelles.
  ], fill: pale-orange, height: 2.3in),
)
#v(0.4em)
#small([
  Référence : #link("https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/silhouette.html")[documentation R de `cluster::silhouette`].
])

== L'indice de Dunn

#formula([$ D=delta/Delta, quad K>=2, quad Delta>0 $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Séparation minimale], [
    $ delta=min_(g != h) min_(i in C_g, ell in C_h) d(x_i,x_ell) $

    La plus petite distance entre deux observations de groupes différents.
  ], height: 2.5in),
  card([Diamètre maximal], [
    $ Delta=max_g max_(i,ell in C_g) d(x_i,x_ell) $

    La plus grande distance entre deux observations d'un même groupe.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.5em)
#small([
  Cette définition favorise les groupes séparés et compacts.
  Les distances extrêmes rendent l'indice sensible aux observations atypiques.
])

= Trois partitions des mêmes observations

== Les partitions A, B et C

Les six valeurs sont $0,1,2,8,9,10$, avec $d(x_i,x_ell)=abs(x_i-x_ell)$.
#v(0.3em)
// Source : exemple numérique de l'introduction, sans ajustement d'algorithme.
#align(center)[
  #image("../figures/unsupervised_partitions.svg", width: 95%, height: 3.75in,
    fit: "contain", alt: "A regroupe 0, 1, 2 et 8, 9, 10. B regroupe 0, 1, 8 "
      + "et 2, 9, 10. C isole 0 puis regroupe 1, 2 et 8, 9, 10.")
]
#small([Les couleurs et symboles indiquent les groupes à l'intérieur de chaque partition.])

== Partition A : inerties et Calinski-Harabasz

#formula([
  $ overline(x)=5, quad T=sum_(i=1)^6 (x_i-5)^2=100 $
])
#v(0.5em)
Les groupes ${0,1,2}$ et ${8,9,10}$ ont pour centres *1* et *9*.
#v(0.4em)
#formula([
  $ W=(1+0+1)+(1+0+1)=4, quad B=100-4=96 $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Pseudo-$R^2$], [
    $ R^2=1-4/100=0.96 $
  ], height: 1.55in),
  card([Calinski-Harabasz], [
    $ op("CH")=96/4 times (6-2)/(2-1)=96 $
  ], fill: pale-blue, height: 1.55in),
)

== Partition A : silhouette de la valeur 2

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Son groupe : ${0,1,2}$], [
    Distances aux autres membres : 2 et 1.

    $ a_i=(2+1)/2=1.5 $
  ], height: 2.15in),
  card([L'autre groupe : ${8,9,10}$], [
    Distances aux trois membres : 6, 7 et 8.

    $ b_i=(6+7+8)/3=7 $
  ], fill: pale-blue, height: 2.15in),
)
#v(0.65em)
#formula([$ s_i=(7-1.5)/max(1.5,7)=5.5/7 approx 0.786 $])
#v(0.55em)
#takeaway([La valeur 2 est bien plus proche de son groupe que de l'autre, en moyenne.])

== Partition A : indice de Dunn

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Écart entre les groupes], [
    La paire la plus proche relie 2 à 8.

    $ delta=8-2=6 $
  ], height: 2.1in),
  card([Diamètre d'un groupe], [
    Les deux groupes ont le même diamètre.

    $ Delta=max(2-0,10-8)=2 $
  ], fill: pale-blue, height: 2.1in),
)
#v(0.65em)
#formula([$ D=6/2=3 $])
#v(0.55em)
#takeaway([L'écart minimal entre groupes vaut trois fois le diamètre maximal interne.])

== Comparaison des quatre critères

#course-table(
  columns: (1fr, 0.5fr, 0.7fr, 1.2fr, 0.9fr, 1.6fr, 0.8fr),
  [*Partition*], [*$K$*], [*$W$*], [*Pseudo-$R^2$*], [*CH*],
  [*Silhouette moyenne*], [*Dunn*],
  [A], [2], [4], [96 %], [96], [0,831], [3],
  [B], [2], [76], [24 %], [1,26], [0,030], [0,125],
  [C], [3], [2,5], [97,5 %], [58,5], [0,493], [0,5],
)
#v(0.75em)
#takeaway([À nombre de groupes égal, les quatre critères préfèrent A à B.])
#v(0.4em)
#small([
  Les observations et leur représentation sont identiques.
  Dans les quatre colonnes de critères, on préfère ici les valeurs élevées.
])

== Les silhouettes individuelles

// Valeurs calculées directement à partir des trois partitions du cours.
#align(center)[
  #image("../figures/unsupervised_silhouettes.svg", width: 97%, height: 3.9in,
    fit: "contain", alt: "Silhouettes des six observations pour A, B et C. "
      + "Toutes sont positives pour A. Les valeurs 2 et 8 ont une silhouette "
      + "de moins 0,6 pour B. Le singleton 0 a une silhouette nulle pour C.")
]
#takeaway([
  Dans B, les valeurs 2 et 8 ont $s_i=-0.6$.
  Dans C, les valeurs 0 (singleton) et 1 ($a_i=b_i$) ont une silhouette nulle.
])

== Un pseudo-$R^2$ plus élevé ne suffit pas

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Partition A], [
    ${0,1,2}$ et ${8,9,10}$.

    $W=4$ et $R^2=96\%$.

    Deux groupes séparés par un grand écart.
  ], height: 2.45in),
  card([Partition C], [
    ${0}$, ${1,2}$ et ${8,9,10}$.

    $W=2.5$ et $R^2=97.5\%$.

    Isoler 0 crée deux groupes très proches à gauche.
  ], fill: pale-orange, height: 2.45in),
)
#v(0.65em)
#takeaway([
  CH, la silhouette moyenne et Dunn favorisent A,
  malgré le pseudo-$R^2$ plus élevé de C.
])
#v(0.35em)
#small([D'autres données peuvent conduire les critères à préférer des partitions différentes.])

= Stabilité et interprétation

== Deux formes de stabilité

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Sensibilité au point de départ], [
    Garder les mêmes observations.

    Répéter l'algorithme avec plusieurs initialisations.

    Comparer les partitions obtenues.
  ], height: 2.65in),
  card([Sensibilité aux données], [
    Modifier légèrement les mesures ou rééchantillonner les observations.

    Réajuster le regroupement.

    Examiner les groupes qui persistent.
  ], fill: pale-blue, height: 2.65in),
)
#v(0.65em)
#takeaway([
  La stabilité des initialisations ne suffit pas à établir la stabilité
  aux variations des données.
])

== Comparer les appartenances par paires

Pour deux partitions des mêmes observations, on peut comparer les couples
qui restent dans un même groupe.
#v(0.5em)
#formula([
  $ M_(i ell)=cases(1 & "si " i " et " ell " sont dans le même groupe",
    0 & "sinon") $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Insensible aux numéros], [
    Échanger les noms des groupes ne change pas $M$.
  ], height: 1.7in),
  card([Lecture de la stabilité], [
    Examiner quelles paires restent ensemble dans les partitions comparées.
  ], fill: pale-blue, height: 1.7in),
)
#v(0.4em)
#small([En cas de sous-échantillonnage, comparer les observations communes.])

== Une projection montre une partie de la géométrie

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ce que le graphique apporte], [
    Repérer des profils, des chevauchements apparents et des observations isolées.

    Comparer visuellement plusieurs partitions.
  ], height: 2.5in),
  card([Ce qu'il peut masquer], [
    Une projection en deux ou trois dimensions peut perdre des directions
    qui séparent les groupes.

    Les distances projetées peuvent différer des distances utilisées.
  ], fill: pale-orange, height: 2.5in),
)
#v(0.65em)
#takeaway([Le graphique complète les diagnostics dans l'espace de l'analyse.])

== La démarche d'analyse

#enum(
  tight: false, spacing: 0.8em,
  [Définir les observations, les variables et la similarité recherchée.],
  [Traiter les valeurs manquantes et examiner transformations, unités et valeurs atypiques.],
  [Comparer les nombres de groupes, les initialisations ou les méthodes lorsque ces choix sont incertains.],
  [Examiner les critères et la stabilité, puis décrire les groupes dans les unités originales.],
  [Relier les différences entre groupes à la question de départ.],
)
#v(0.65em)
#takeaway([Effectifs, centres et dispersions rendent la partition interprétable.])

== Exploration descriptive et utilisation future

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Décrire les données disponibles], [
    Toutes les observations peuvent participer à l'exploration descriptive.

    Les conclusions portent sur ce jeu de données et sur les choix de l'analyse.
  ], height: 2.65in),
  card([Affecter de nouveaux individus], [
    Apprendre les transformations et le regroupement sur l'entraînement.

    Définir une règle d'affectation pour les nouvelles observations, sans utiliser
    leurs réponses.
  ], fill: pale-blue, height: 2.65in),
)
#v(0.65em)
#small([
  Cette séparation s'applique aussi lorsque les groupes deviennent des variables
  d'entrée d'un modèle prédictif.
])

== La portée des noms attribués aux groupes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une description à justifier], [
    Décrire les caractéristiques qui distinguent les groupes.

    Vérifier les effectifs et la diversité interne avant de leur donner un nom.
  ], height: 2.45in),
  card([Des limites à conserver], [
    Un algorithme peut découper un nuage continu.

    Une partition ne démontre ni l'existence de catégories naturelles
    ni un mécanisme causal.
  ], fill: pale-orange, height: 2.45in),
)
#v(0.65em)
#takeaway([L'utilité d'une partition dépend de la question, de sa stabilité et de son interprétation.])

== Questions de compréhension

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Groupes et qualité], [
    Deux partitions avec des numéros différents peuvent-elles être identiques ?

    Pourquoi ne pas maximiser seulement le pseudo-$R^2$ ?
  ], height: 2.6in),
  card([Diagnostic et validation], [
    Comment calculer $b_i$ pour trois groupes ?

    Une partition stable à l'initialisation est-elle nécessairement stable
    au rééchantillonnage ?
  ], fill: pale-blue, height: 2.6in),
)
#v(0.65em)
#takeaway([Un critère résume une propriété géométrique, à confronter au sens des groupes.])

== Ressources et fichiers du cours

- *Notes* : `lectures/unsupervised.typ`, section « Introduction ».
- *Données de l'exemple morphologique* : `assets/penguins.csv`.
- *Silhouette* : #link("https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/silhouette.html")[documentation de `cluster::silhouette`].
- *Figures et calculs de l'exemple numérique* : `figures/unsupervised_introduction.py`.

#v(0.7em)
#small([
  Les partitions A, B et C illustrent la comparaison des critères.
  Elles ne résultent pas ici de l'exécution d'un algorithme.
])
#v(0.65em)
#formula([`typst compile --root . slides/unsupervised.typ`])
