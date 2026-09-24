// STT-2200 : les k-moyennes.
// Source : lectures/unsupervised.typ, section <kmeans>.
// Données et calculs : codes/k_means.R.
// Figures Python : figures/k_means.py et figures/kmeans_exemples.py.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/k_moyennes.typ
// --root . autorise l'accès aux figures du dossier voisin.
#import "../styles/slides.typ": *

#show : course-slides.with(title: [Les $k$-moyennes])

#title-slide()

= Le critère des k-moyennes

== Le parcours du cours

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Critère et centroïdes], [
    Relier les moyennes à la minimisation des distances au carré.
  ], height: 1.55in),
  card([Algorithme de Lloyd], [
    Suivre les affectations et les mises à jour des centres.
  ], fill: pale-blue, height: 1.55in),
  card([Initialisation et choix de $k$], [
    Distinguer une solution stable, un bon départ et un nombre de groupes utile.
  ], fill: pale-purple, height: 1.55in),
  card([Exemple Palmer Penguins], [
    Décrire les groupes et examiner les limites de leur interprétation.
  ], fill: pale-orange, height: 1.55in),
)

== Les objets du problème

#course-table(
  columns: (1.1fr, 3.5fr),
  [*Notation*], [*Rôle*],
  [$x_i in RR^p$], [Observation numérique, après les transformations choisies],
  [$k$], [Nombre de groupes, fixé pour un ajustement],
  [$C_1,dots,C_k$], [Partition des indices des $n$ observations],
  [$mu_1,dots,mu_k$], [Centres ou centroïdes dans le même espace que les données],
  [$n_g=abs(C_g)$], [Effectif du groupe $g$],
)
#v(0.65em)
#takeaway([On ajuste les groupes et les centres sans variable réponse.])

== Une somme de distances au carré

#formula([
  $ Q(cal(C),mu_1,dots,mu_k)
    =sum_(g=1)^k sum_(i in C_g) norm(x_i-mu_g)^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Affectations inconnues], [
    Pour chaque observation, choisir le centre qui la représente.
  ], height: 1.85in),
  card([Centres inconnus], [
    Placer chaque centre de façon à limiter les écarts dans son groupe.
  ], fill: pale-blue, height: 1.85in),
)
#v(0.65em)
#takeaway([Les k-moyennes cherchent à minimiser $Q$ sur ces deux ensembles de choix.])

== Pourquoi le centroïde est une moyenne

Pour un groupe non vide $C_g$ fixé, notons $overline(x)_g$ sa moyenne.
#v(0.4em)
#formula([
  $ sum_(i in C_g) norm(x_i-m)^2
    =sum_(i in C_g) norm(x_i-overline(x)_g)^2
    +n_g norm(m-overline(x)_g)^2 $
])
#v(0.5em)
*Preuve.* Écrire $x_i-m=(x_i-overline(x)_g)+(overline(x)_g-m)$.
Le terme croisé s'annule car $sum_(i in C_g)(x_i-overline(x)_g)=0$.
#v(0.4em)
Le dernier terme est positif ou nul. Il s'annule exactement pour
$m=overline(x)_g$. #h(1fr) $square$
#v(0.65em)
#takeaway([À groupes fixés, la moyenne minimise la somme des distances euclidiennes au carré.])

== Inertie et choix de la distance

#formula([
  $ mu_g=overline(x)_g quad => quad
    Q=W(cal(C))=sum_(g=1)^k sum_(i in C_g) norm(x_i-overline(x)_g)^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Lien avec l'introduction], [
    $T=W+B$ dans l'espace euclidien choisi.

    À données fixées, minimiser $W$ revient à maximiser $B$.
  ], height: 2.4in),
  card([Une moyenne adaptée au critère], [
    Le centroïde peut être absent du jeu de données.

    Avec une autre dissimilarité, la moyenne n'est plus nécessairement
    le meilleur centre.
  ], fill: pale-blue, height: 2.4in),
)

== Les unités modifient les distances

Notons $e_j>0$ l'écart-type empirique de la variable $j$.
#v(0.4em)
#formula([
  $ z_(i j)=(x_(i j)-overline(x)_j)/e_j, quad
    norm(z_i-z_ell)^2=sum_(j=1)^p (x_(i j)-x_(ell j))^2/e_j^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Centrer], [
    Soustraire la même moyenne à tous les points conserve leurs distances.
  ], height: 1.7in),
  card([Réduire], [
    Diviser par les écarts-types change le poids relatif des variables.
  ], fill: pale-blue, height: 1.7in),
)
#v(0.5em)
#small([La standardisation est un choix d'analyse. Une variable constante demande un traitement préalable.])

= L'algorithme de Lloyd

== Initialiser les centres

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un nombre de groupes fixé], [
    Choisir $k$ pour cet ajustement.

    Initialiser $mu_1^((0)),dots,mu_k^((0))$, par exemple avec $k$ observations
    distinctes tirées au hasard.
  ], height: 2.4in),
  card([Deux étapes à répéter], [
    Affecter chaque observation au centre le plus proche.

    Recalculer les moyennes des groupes obtenus.
  ], fill: pale-blue, height: 2.4in),
)
#v(0.65em)
#takeaway([Lloyd alterne deux minimisations simples, chacune conditionnelle à l'autre.])
#v(0.35em)
#small([L'initialisation par des observations exige au moins $k$ observations distinctes.])

== Étape d'affectation

#formula([
  $ c_i^((t+1))=op("argmin", limits: #true)_(g in {1,dots,k})
    norm(x_i-mu_g^((t)))^2 $
  $ C_g^((t+1))={i:c_i^((t+1))=g} $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Centres inchangés], [
    Chaque observation choisit le centre qui minimise sa propre contribution à $Q$.
  ], height: 1.8in),
  card([Égalité de distance], [
    Appliquer une règle de départage fixée, par exemple choisir le premier centre.
  ], fill: pale-blue, height: 1.8in),
)

== Étape de mise à jour

#formula([
  $ mu_g^((t+1))=1/n_g^((t+1)) sum_(i in C_g^((t+1))) x_i,
    quad n_g^((t+1))=abs(C_g^((t+1))) $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Groupes inchangés], [
    Remplacer chaque centre par la moyenne de son groupe.

    Cette mise à jour minimise $Q$ pour les affectations courantes.
  ], height: 2.3in),
  card([Groupe vide], [
    Si $n_g^((t+1))=0$, la moyenne n'existe pas.

    L'implémentation doit prévoir une stratégie, comme réinitialiser ce centre.
  ], fill: pale-orange, height: 2.3in),
)

== Décroissance et arrêt de l'algorithme

#formula([$ Q_(t+1)<=Q_t, quad Q_t>=0 $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une amélioration à chaque étape], [
    L'affectation puis la mise à jour n'augmentent pas le critère.

    Une étape peut laisser sa valeur inchangée.
  ], height: 2.35in),
  card([Un arrêt à contrôler], [
    Affectations stabilisées ou règle d'arrêt numérique.

    Un nombre maximal d'itérations évite une exécution indéfinie.

  ], fill: pale-blue, height: 2.35in),
)
#v(0.45em)
#small([
  En arithmétique exacte, avec des groupes non vides et un départage cohérent,
  Lloyd se stabilise. Le minimum global n'est pas garanti.
])

== Exemple : première affectation

Valeurs $0,1,2,8,9,10$, avec $k=2$ et centres initiaux $0$ et $2$.
#v(0.5em)
#course-table(
  columns: (1fr, 1.4fr, 1.4fr, 1.2fr),
  [*$x_i$*], [*Distance² à 0*], [*Distance² à 2*], [*Groupe*],
  [0], [0], [4], [1],
  [1], [1], [1], [1],
  [2], [4], [0], [2],
  [8], [64], [36], [2],
  [9], [81], [49], [2],
  [10], [100], [64], [2],
)
#v(0.65em)
#takeaway([La valeur 1 rejoint le groupe 1 selon la règle de départage. Ici, $Q=150$.])

== Exemple : deux mises à jour

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Première mise à jour], [
    Groupes ${0,1}$ et ${2,8,9,10}$.

    $ mu_1=0.5, quad mu_2=7.25 $

    $ W=39.25 $
  ], height: 2.65in),
  card([Deuxième mise à jour], [
    La valeur 2 rejoint le groupe 1.

    Groupes ${0,1,2}$ et ${8,9,10}$.

    $ mu_1=1, quad mu_2=9, quad W=4 $
  ], fill: pale-blue, height: 2.65in),
)
#v(0.65em)
#takeaway([Les affectations suivantes restent identiques : l'algorithme est stabilisé.])

== L'évolution des centres et des groupes

// Exemple déterministe de la section k-moyennes, figure créée en Python.
#align(center)[
  #image("../figures/kmeans_lloyd_etapes.svg", width: 98%, height: 4.1in,
    fit: "contain", alt: "Trois états de Lloyd sur 0, 1, 2, 8, 9, 10. "
      + "Les centres passent de 0 et 2 à 0,5 et 7,25, puis à 1 et 9. "
      + "Le critère passe de 150 à 39,25 puis 4.")
]
#small([
  Les croix indiquent les centres, décalés sous les observations pour la lecture.
  Après la première mise à jour, la réaffectation de 2 reste à effectuer.
])

= Initialisation et géométrie

== Deux solutions stables pour les mêmes données

// Source : figures/k_means.py, exemple des quatre sommets d'un rectangle.
#align(center)[
  #image("../figures/kmeans_initialisations.svg", width: 97%, height: 4.2in,
    fit: "contain", alt: "Quatre sommets d'un rectangle. Le découpage "
      + "gauche-droite est stable avec W égal à 4. Le découpage bas-haut "
      + "est également stable avec W égal à 16.")
]
#small([
  Dans les deux partitions, chaque centre est la moyenne de son groupe
  et chaque point rejoint son centre le plus proche.
])

== Plusieurs départs et davantage d'itérations

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Plusieurs initialisations], [
    Explorer plusieurs solutions pour le même $k$.

    Retenir celle de plus faible inertie $W$ parmi les ajustements réalisés.
  ], height: 2.4in),
  card([Plus d'itérations par départ], [
    Laisser chaque ajustement atteindre son critère d'arrêt.

    Prolonger un point fixe ne permet pas de quitter cette solution.
  ], fill: pale-blue, height: 2.4in),
)
#v(0.65em)
#takeaway([Une graine fixe rend le calcul reproductible, sans améliorer la partition.])

== L'initialisation k-means++

#enum(
  tight : false, spacing : 0.7em,
  [Choisir un premier centre au hasard parmi les observations.],
  [Pour chaque observation, calculer la distance au centre déjà choisi le plus proche.],
  [Tirer le centre suivant avec une probabilité proportionnelle au carré de cette distance.],
  [Répéter jusqu'à disposer de $k$ centres, puis lancer l'algorithme.],
)
#v(0.6em)
#formula([
  $ D_i^2=min_(g " déjà choisi") norm(x_i-mu_g)^2,
    quad P("choisir " x_i)=D_i^2/(sum_ell D_ell^2) $
])
#v(0.5em)
#small([Des centres mieux répartis peuvent améliorer le départ, sans garantir le minimum global.])

== Les régions de Voronoï

Entre deux centres distincts, l'égalité des distances donne
#v(0.4em)
#formula([
  $ norm(x-mu_g)^2=norm(x-mu_h)^2 $
  $ 2(mu_h-mu_g)^top x=norm(mu_h)^2-norm(mu_g)^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Frontières linéaires], [
    Une droite en dimension 2, un hyperplan en dimension supérieure.
  ], height: 1.8in),
  card([Régions convexes], [
    Chaque région est une intersection de demi-espaces définis par les autres centres.
  ], fill: pale-blue, height: 1.8in),
)
#v(0.4em)
#small([Le critère favorise la compacité autour des centres. Les régions ne sont pas nécessairement des sphères.])

== Affecter une nouvelle observation

Appliquer les transformations déjà estimées, puis utiliser les centres fixés.
#v(0.4em)
#formula([
  $ hat(c)(x)=op("argmin", limits: #true)_(g in {1,dots,k}) norm(x-mu_g)^2 $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Exemple : $x=6$], [
    Avec les centres 1 et 9 :

    $ (6-1)^2=25, quad (6-9)^2=9 $

    Affectation au groupe 2.
  ], height: 2.2in),
  card([Un modèle inchangé], [
    Les centres ne bougent pas.

    Inclure ce point dans un nouvel ajustement peut déplacer les centres
    et changer d'anciennes affectations.
  ], fill: pale-blue, height: 2.2in),
)
#v(0.4em)
#small([La proximité à un centre ne fournit pas, à elle seule, une probabilité d'appartenance.])

= Choisir le nombre de groupes

== Pourquoi l'inertie seule ne choisit pas $k$

Notons $W_k^*$ la plus faible inertie possible avec $k$ groupes.
#v(0.4em)
#formula([$ W_(k+1)^*<=W_k^* $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Argument de découpage], [
    Scinder un groupe conserve ou réduit la somme des carrés.

    Avec un groupe par observation, l'inertie vaut zéro.
  ], height: 2.35in),
  card([Résultats d'un algorithme local], [
    Les ajustements calculés n'atteignent pas toujours $W_k^*$.

    Une remontée de l'inertie peut signaler un mauvais départ ou un problème
    de convergence.
  ], fill: pale-orange, height: 2.35in),
)
#v(0.4em)
#small([Pour chaque valeur candidate de $k$, comparer plusieurs initialisations.])

== Le coude et les critères complémentaires

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Courbe des inerties], [
    Rechercher une rupture après laquelle un groupe supplémentaire apporte
    peu de réduction de $W$.

    Plusieurs coudes, ou aucun coude net, sont possibles.
  ], height: 2.6in),
  card([Séparation et interprétation], [
    Comparer silhouette moyenne et Calinski-Harabasz.

    Examiner les effectifs, les profils et la stabilité.

    Les critères peuvent proposer des choix différents.
  ], fill: pale-blue, height: 2.6in),
)
#v(0.65em)
#takeaway([Le choix de $k$ doit répondre à la question de l'analyse.])

== Exemple : neuf observations sur une droite

#formula([
  $ 0,1,2,10,11,12,20,21,22, quad overline(x)=11, quad T=606 $
])
#v(0.6em)
#course-table(
  columns: (0.5fr, 4.5fr),
  [*$k$*], [*Groupes retenus, écrits en termes de valeurs*],
  [1], [Toutes les observations],
  [2], [${0,1,2}$ et ${10,11,12,20,21,22}$],
  [3], [${0,1,2}$, ${10,11,12}$ et ${20,21,22}$],
  [4], [${0}$, ${1,2}$, ${10,11,12}$ et ${20,21,22}$],
)
#v(0.6em)
#small([
  Ici, les minima d'inertie se vérifient par toutes les découpes consécutives
  des valeurs ordonnées. Plusieurs partitions sont optimales pour $k=2$ et $k=4$.
])

== Exemple : un coude à trois groupes

// Source : exemple numérique du chapitre, minima vérifiés par énumération.
#align(center)[
  #image("../figures/kmeans_coude_exemple.svg", width: 98%, height: 4.0in,
    fit: "contain", alt: "L'inertie minimale vaut 606, 156, 6 puis 4,5 pour "
      + "1 à 4 groupes. La silhouette vaut 0,641, 0,862 puis 0,628 pour "
      + "2 à 4 groupes. Le coude et le maximum de silhouette se situent à 3.")
]
#takeaway([Les gains successifs d'inertie sont 450, 150 puis seulement 1,5.])

== Exemple : trois groupes plutôt que quatre

#course-table(
  columns: (0.6fr, 1.2fr, 2fr, 1.3fr),
  [*$k$*], [*Inertie $W$*], [*Silhouette moyenne*], [*CH*],
  [1], [606], [—], [—],
  [2], [156], [0,641], [20,19],
  [*3*], [*6*], [*0,862*], [*300*],
  [4], [4,5], [0,628], [222,78],
)
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Trois groupes], [
    Centres 1, 11 et 21.

    Trois observations proches dans chaque groupe.
  ], height: 1.75in),
  card([Quatrième groupe], [
    Isoler 0 de ses voisines 1 et 2 apporte peu de gain et dégrade les deux indices.
  ], fill: pale-orange, height: 1.75in),
)
#v(0.35em)
#small([Silhouette euclidienne. Silhouette et CH ne sont pas définis pour $k=1$.])

= Exemple Palmer Penguins

== Préparer les quatre mesures morphologiques

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Observations et variables], [
    Longueur et profondeur du bec, longueur de la nageoire et masse corporelle.

    Retirer les deux lignes incomplètes. Il reste 342 manchots.
  ], height: 2.65in),
  card([Espace de l'analyse], [
    Centrer et réduire les quatre mesures.

    Utiliser les écarts-types empiriques, de diviseur $n-1$.

    Garder `species` hors de l'ajustement et du choix de $k$.
  ], fill: pale-blue, height: 2.65in),
)
#v(0.65em)
#formula([$ T=4 times (342-1)=1364 $])
#v(0.35em)
#small([Exploration descriptive de l'ensemble disponible. Chaque variable réduite contribue 341 à $T$.])

== Les réglages de l'exemple R

#course-table(
  columns: (1.4fr, 3fr),
  [*Réglage*], [*Choix dans le script du cours*],
  [Nombre de groupes], [$k=1,dots,8$],
  [Initialisations], [`nstart = 50` pour chaque $k$],
  [Itérations maximales], [`iter.max = 100` par initialisation],
  [Algorithme], [`algorithm = "Hartigan-Wong"`],
  [Graine], [`set.seed(2200)`],
)
#v(0.7em)
#takeaway([Hartigan-Wong optimise le même critère que Lloyd, avec une procédure différente.])
#v(0.4em)
#small([
  `stats::kmeans` permet aussi `algorithm = "Lloyd"`.
  Référence : #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/kmeans.html")[documentation R de `kmeans`].
])

== Les critères pour $k=1,dots,8$

#course-table(
  columns: (0.5fr, 1.1fr, 1.2fr, 1.7fr, 1fr),
  [*$k$*], [*Inertie $W$*], [*Pseudo-$R^2$*], [*Silhouette moyenne*], [*CH*],
  [1], [1364,00], [0,00 %], [—], [—],
  [*2*], [*564,05*], [*58,65 %*], [*0,532*], [*482,2*],
  [3], [378,28], [72,27 %], [0,447], [441,7],
  [4], [299,52], [78,04 %], [0,400], [400,4],
  [5], [231,92], [83,00 %], [0,378], [411,3],
  [6], [203,72], [85,06 %], [0,372], [382,7],
  [7], [186,41], [86,33 %], [0,335], [352,7],
  [8], [170,47], [87,50 %], [0,299], [334,1],
)
#v(0.65em)
#takeaway([Parmi ces valeurs, la silhouette moyenne et CH sont maximaux pour $k=2$.])

== L'inertie diminue au-delà du choix retenu

// Source : figures/k_means.py et codes/k_means.R, quatre mesures réduites.
#align(center)[
  #image("../figures/kmeans_choix_k.svg", width: 98%, height: 4.1in,
    fit: "contain", alt: "Sur Palmer Penguins, l'inertie décroît jusqu'à "
      + "8 groupes. La silhouette moyenne atteint son maximum à 2 groupes.")
]
#small([
  On retient deux groupes pour cette description.
  Ce choix ne démontre pas l'existence de deux sous-populations naturelles.
])

== Les profils dans les unités originales

#course-table(
  columns: (2fr, 1fr, 1fr),
  [*Caractéristique*], [*Groupe 1*], [*Groupe 2*],
  [Effectif], [219], [123],
  [Longueur du bec (mm)], [41,91], [47,50],
  [Profondeur du bec (mm)], [18,37], [14,98],
  [Longueur de la nageoire (mm)], [191,78], [217,19],
  [Masse corporelle (g)], [3710,73], [5076,02],
)
#v(0.65em)
#takeaway([
  En moyenne, le groupe 2 est plus lourd, avec un bec et des nageoires plus longs,
  mais un bec moins profond.
])
#v(0.4em)
#small([
  Groupes numérotés par masse moyenne croissante.
  Les moyennes décrivent des tendances, sans imposer un ordre entre tous les individus.
])

== Visualiser la partition sur un plan d'ACP

// L'ajustement emploie les quatre variables, l'ACP sert uniquement à l'affichage.
#align(center)[
  #image("../figures/kmeans_palmerpenguins.svg", width: 95%, height: 4.15in,
    fit: "contain", alt: "Projection des 342 manchots sur les deux premières "
      + "composantes principales. Le groupe 1 compte 219 individus, "
      + "le groupe 2 en compte 123. Les croix indiquent les centres projetés.")
]
#small([
  Croix : centroïdes projetés. L'ajustement utilise les quatre mesures réduites.
  Les pourcentages décrivent l'ACP et diffèrent du pseudo-$R^2$ de la partition.
])

== Comparaison descriptive avec les espèces

#course-table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  [*Groupe*], [*Adelie*], [*Chinstrap*], [*Gentoo*], [*Total*],
  [1], [151], [68], [0], [219],
  [2], [0], [0], [123], [123],
)
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une comparaison après ajustement], [
    `species` n'intervient ni dans les distances, ni dans l'ajustement,
    ni dans le choix de $k$.
  ], height: 2.1in),
  card([Deux groupes, trois espèces], [
    Le groupe 1 réunit Adelie et Chinstrap.

    La partition résume une forte séparation morphologique.
  ], fill: pale-blue, height: 2.1in),
)
#v(0.4em)
#small([Ce tableau ne constitue pas une matrice d'erreurs de classification supervisée.])

== Reproduire les résultats en R

Depuis la racine du dépôt, le script réalise l'exploration complète.

#block(fill: pale-gray, inset: 12pt, radius: 5pt)[
```r
source("codes/k_means.R")

criteres       # inertie, pseudo-R2, silhouette et CH
K_retenu       # nombre de groupes retenu : 2
profils        # effectifs et moyennes dans les unités originales

table(Groupe = groupes, Species = d$species)
```
]
#v(0.65em)
#takeaway([Les calculs vérifient la décomposition $T=W+B$ et l'affectation au centre le plus proche.])
#v(0.4em)
#small([Dépendance : `cluster` pour la silhouette. Données locales : `assets/penguins.csv`.])

= Limites et précautions

== Des formes que les centres résument mal

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dispersions et effectifs différents], [
    L'algorithme peut couper un groupe très étendu ou fusionner de petits groupes voisins.

    L'égalité des tailles ou des covariances n'est pas une contrainte formelle.
  ], height: 2.65in),
  card([Deux anneaux concentriques], [
    Avec $k=2$, la frontière entre les centres est une droite.

    Elle ne peut séparer un anneau intérieur d'un anneau extérieur.
  ], fill: pale-orange, height: 2.65in),
)
#v(0.65em)
#small([
  Selon la géométrie recherchée, envisager une autre représentation,
  une méthode par densité ou une méthode spectrale.
])

== Valeurs extrêmes et séparation peu nette

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une forte sensibilité aux extrêmes], [
    Les distances au carré et les moyennes amplifient leur influence.

    Une observation peut déplacer un centre ou former un groupe isolé.

    L'écart-type est lui aussi sensible aux extrêmes.
  ], height: 2.95in),
  card([Une affectation pour chaque point], [
    Les k-moyennes découpent aussi un nuage continu.

    Les observations isolées ou proches d'une frontière reçoivent un groupe.

    Les distances ne sont pas des probabilités d'appartenance.
  ], fill: pale-orange, height: 2.95in),
)
#v(0.6em)
#takeaway([Examiner les observations atypiques et leur effet, sans les supprimer automatiquement.])

== Les vérifications d'une analyse

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Espace choisi], [
    Variables, valeurs manquantes, unités et transformations documentées.
  ], height: 1.6in),
  card([Ajustements], [
    Plusieurs départs, convergence contrôlée et comparaison des inerties.
  ], fill: pale-blue, height: 1.6in),
  card([Nombre de groupes], [
    Critères, effectifs et profils confrontés à la question de départ.
  ], fill: pale-purple, height: 1.6in),
  card([Stabilité], [
    Sensibilité aux initialisations et aux variations des données examinée séparément.
  ], fill: pale-orange, height: 1.6in),
)

== Questions de compréhension

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Critère et algorithme], [
    Pourquoi mettre à jour les centres avec des moyennes ?

    Pourquoi une solution stable peut-elle avoir une inertie trop élevée ?
  ], height: 2.5in),
  card([Choix et interprétation], [
    Pourquoi ne pas retenir automatiquement le plus grand $k$ ?

    Que signifie retrouver deux groupes de manchots alors que trois espèces existent ?
  ], fill: pale-blue, height: 2.5in),
)
#v(0.65em)
#takeaway([Le critère, l'algorithme et l'interprétation des groupes répondent à des questions distinctes.])

== Ressources et fichiers du cours

- *Notes* : `lectures/unsupervised.typ`, section « Les k-moyennes ».
- *Exemple reproductible* : `codes/k_means.R`.
- *Données* : `assets/penguins.csv` et `assets/penguins_README.md`.
- *Fonction R* : #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/kmeans.html")[documentation de `stats::kmeans`].
- *Figures Python* : `figures/k_means.py` et `figures/kmeans_exemples.py`.

#v(0.65em)
#small([
  Palmer Penguins : Horst, Hill et Gorman (2020).
  Données collectées par Kristen Gorman et le programme Palmer Station LTER.
])
#v(0.65em)
#formula([`typst compile --root . slides/k_moyennes.typ`])
