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

= Le critère des $k$-moyennes

== Les notations

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
#takeaway([Les $k$-moyennes cherchent à minimiser $Q$ sur ces deux ensembles.])

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
Le terme croisé s'annule car 
$ sum_(i in C_g)(x_i-overline(x)_g)=0. $
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
#takeaway([L'algorithme de Lloyd alterne deux minimisations simples, chacune conditionnelle à l'autre.])
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
    quad "et" quad n_g^((t+1))=abs(C_g^((t+1))) $
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

#formula([$ Q_(t+1)<=Q_t, quad "et" quad Q_t>=0 $])
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
  l'algorithme de Lloyd se stabilise. Le minimum global n'est cependant pas garanti.
])

== Exemple

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

