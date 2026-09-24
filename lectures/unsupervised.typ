#import "../styles/notes.typ": *

= Apprentissage non supervisé

== Introduction

Dans le cadre non supervisé de @def-apprentissage-non-supervise, ce chapitre
porte sur le *regroupement* (_clustering_). Il complète le chapitre consacré
à la réduction de dimension en étudiant les partitions et les hiérarchies
d'observations.

Le regroupement cherche à réunir des observations similaires et à distinguer
des ensembles qui présentent des profils différents. Cette similarité n'est
pas donnée une fois pour toutes : elle dépend des variables, de leur
représentation et de la distance choisie. Un même tableau peut donc conduire
à plusieurs regroupements pertinents pour des questions différentes.

=== Des groupes à construire, sans étiquettes à prédire

On considère $n$ observations $x_i=(x_(i 1), dots, x_(i p))^top$ décrits par $p$ variables explicatives. Ces variables explicatives peuvent être qualitative ou quantitative. Contrairement à la classification supervisée, on ne dispose pas d'une classe $y_i$ à reproduire pendant l'ajustement. Les groupes sont un résultat de l'analyse, et leurs numéros n'ont pas de signification intrinsèque : échanger les noms « groupe 1 » et « groupe 2 » ne change pas la partition.

#example[
  Dans le jeu de données Palmer Penguins, on peut regrouper les manchots à partir de
  `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g`, sans
  utiliser `species`. On cherche alors des profils morphologiques dans les
  mesures. Les groupes obtenus peuvent correspondre en partie aux espèces,
  mais aussi refléter d'autres différences de taille ou de forme.

  La variable `species` pourra ensuite servir à décrire les groupes par un
  tableau croisé. Si elle intervient pour choisir les variables ou le nombre
  de groupes, l'analyse utilise alors une information externe sur les classes.
  Cette comparaison ne constitue donc plus une vérification indépendante des choix.
]

#definition(title: [Partition en groupes])[
  Une *partition* en $K$ groupes est une collection $cal(C)=(C_1, dots, C_K)$ d'ensembles d'indices non vides, disjoints deux à deux, dont la réunion est ${1, dots, n}$. Chaque observation appartient alors à un seul groupe. On note $n_g=abs(C_g)$ l'effectif du groupe $g$.
]

Dans la suite, $K$ désigne le nombre de groupes, $g$ leur indice et $j$ celui
d'une variable. Le $K$ de $k$-means compte des groupes, tandis que le $k$ des
plus proches voisins comptait des voisins.

Toutes les méthodes non supervisées ne produisent pas une telle partition
stricte : une hiérarchie fournit plusieurs niveaux de regroupement, un modèle
de mélange donne des probabilités d'appartenance, et une méthode par densité
peut laisser des observations isolées hors des groupes.

=== Comparer la qualité des partitions

#definition(title: [Inerties d'une partition])[
  Notons $overline(x)_g=1/n_g sum_(i in C_g) x_i$ le centroïde du groupe $g$
  et $overline(x)=1/n sum_(i=1)^n x_i$ la moyenne globale. Les inerties
  *intra-groupe*, *inter-groupe* et *totale* sont respectivement

  $ W = sum_(g=1)^K sum_(i in C_g) norm(x_i-overline(x)_g)^2, $
  $ B = sum_(g=1)^K n_g norm(overline(x)_g-overline(x))^2, $
  $ T = sum_(i=1)^n norm(x_i-overline(x))^2. $

  Ces quantités sont des scalaires, sans normalisation. Elles correspondent
  aux traces des matrices de dispersion $W$, $B$ et $T$ définies dans le
  chapitre sur Fisher. Pour les mêmes données, l'inertie utilisée en ACP
  vaut $inertia=T/(n-1)$.
]

#property(title: [Décomposition de l'inertie])[
  L'inertie totale est la somme des inerties intra-groupe et inter-groupe :

  $ T = W + B. $
]

#proof[
  Dans chaque groupe, on écrit
  $x_i-overline(x)=(x_i-overline(x)_g)+(overline(x)_g-overline(x))$.
  Après développement du carré de la norme et sommation, les termes croisés
  s'annulent puisque $sum_(i in C_g)(x_i-overline(x)_g)=0$.
]

#definition(title: [Part d'inertie inter-groupe])[
  Lorsque $T>0$, on définit le pseudo-$R^2$ par

  $ R^2 = B/T = 1-W/T. $
]

Ce n'est ni une proportion d'observations correctement classées, ni une preuve de l'existence de groupes naturels. En augmentant $K$, on peut réduire l'inertie intra-groupe jusqu'à zéro en plaçant chaque observation dans son propre groupe. Utiliser seulement le pseudo-$R^2$ ne permet donc pas de choisir $K$.

#definition(title: [Indice de Calinski-Harabasz])[
  Pour $1<K<n$ et $W>0$, cet indice compare les
  dispersions inter-groupe et intra-groupe en tenant compte du nombre de groupes :

  $ CH = B/W times (n-K)/(K-1). $
]

Une valeur élevée indique une forte séparation relativement à la dispersion interne. L'indice se compare entre partitions des mêmes observations dans le même espace. Sa valeur n'est pas une probabilité ni un seuil universel de qualité.

#definition(title: [Silhouette d'une observation])[
  Pour une observation $i$ dans un groupe $C_g$
  comptant au moins deux points, on définit les quantités suivantes :

  $ a_i = 1/(n_g-1) sum_(ell in C_g, ell != i) d(x_i,x_ell), quad "et" quad
   b_i = min_(h != g) 1/n_h sum_(ell in C_h) d(x_i,x_ell). $

  La quantité $a_i$ est sa distance moyenne aux autres membres de son groupe. Pour calculer la quantité $b_i$, on mesure sa distance moyenne à chaque autre groupe et on garde la plus petite. Il ne s'agit donc ni de la distance au voisin individuel le plus proche, ni de la distance au centroïde le plus proche. La silhouette vaut

  $ s_i = (b_i-a_i)/max(a_i,b_i). $
]

Ce critère est compris entre $-1$ et $1$. Une valeur proche de $1$ décrit un point
proche de son groupe et éloigné des autres. Une valeur proche de $0$ signale
une frontière peu nette. Une valeur négative indique qu'un autre groupe est
plus proche en moyenne et invite à examiner l'affectation. Ce diagnostic
géométrique ne révèle pas une « vraie » étiquette inconnue.

Par convention, on attribue $s_i=0$ à un groupe réduit à une seule observation,
ainsi qu'au cas dégénéré $a_i=b_i=0$. La silhouette moyenne se calcule pour
$2 <= K <= n-1$.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/silhouette.html")[documentation
  de `cluster::silhouette`] pour la définition et le traitement des singletons.
]

#definition(title: [Indice de Dunn])[
  Une définition courante utilise le rapport

  $ D = (min_(g != h) min_(i in C_g, ell in C_h) d(x_i,x_ell)) /
        (max_g max_(i,ell in C_g) d(x_i,x_ell)). $
]

Le numérateur est la plus petite distance entre deux groupes, et le
dénominateur le plus grand diamètre d'un groupe. Pour un diamètre maximal
non nul, une grande valeur favorise des groupes séparés et compacts.
Comme il repose sur des distances extrêmes,
cet indice peut être fortement modifié par une seule observation atypique.

#example(title: [Comparer trois partitions des mêmes observations], breakable: true)[
  Considérons les six valeurs suivante : $0,1,2,8,9,10$, et considérons la distance $d(x_i,x_ell)=abs(x_i-x_ell)$. Leur moyenne est $5$ et leur inertie totale, calculée sans division par $n$, vaut $ T=sum_(i=1)^6 (x_i-5)^2=100. $

  On compare les partitions suivantes, en écrivant les valeurs dans les
  groupes plutôt que les indices des observations :

  - *A* : ${0,1,2}$ et ${8,9,10}$ ;
  - *B* : ${0,1,8}$ et ${2,9,10}$ ;
  - *C* : ${0}$, ${1,2}$ et ${8,9,10}$.

  Pour *A*, les centroïdes sont $1$ et $9$. On obtient

  $ W=(1+0+1)+(1+0+1)=4, quad B=T-W=96, $
  $ R^2=1-4/100=0.96, quad CH=96/4 times (6-2)/(2-1)=96. $

  Pour l'observation de valeur $2$, les distances moyennes sont
  $a_i=(2+1)/2=1.5$ et $b_i=(6+7+8)/3=7$ : sa silhouette vaut donc
  $s_i=(7-1.5)/7 approx 0.786$. La silhouette moyenne est calculée sur les
  six observations. Enfin, la plus petite distance entre les deux groupes
  est $8-2=6$ et leur diamètre maximal est $2$, d'où $D=6/2=3$.

  Les mêmes calculs pour les trois partitions donnent :

  #table(
    columns: (1fr, 0.45fr, 0.65fr, 1fr, 0.8fr, 1.3fr, 0.7fr),
    align: center,
    table.header([*Partition*], [*$K$*], [*$W$*], [*Pseudo-$R^2$*],
    [*CH*], [*Silhouette moyenne*], [*Dunn*]),
    [A], [2], [4], [96~%], [96], [0,831], [3],
    [B], [2], [76], [24~%], [1,26], [0,030], [0,125],
    [C], [3], [2,5], [97,5~%], [58,5], [0,493], [0,5],
  )

  À nombre de groupes égal, tous les critères préfèrent *A* à *B*. Dans *B*,
  les valeurs $2$ et $8$ ont chacune une silhouette de $-0.6$ : elles sont
  en moyenne plus proches de l'autre groupe que du leur.

  Passer de *A* à *C* réduit encore $W$ et augmente le pseudo-$R^2$.
  Pourtant, CH, la silhouette moyenne et Dunn diminuent : isoler $0$ crée
  deux groupes proches à la place de ${0,1,2}$. La silhouette de ce singleton
  vaut $0$ par convention. Ici, ces trois critères favorisent donc *A*, malgré
  le pseudo-$R^2$ plus élevé de *C*.
]

Ces critères ne mesurent pas exactement la même notion de qualité. Ils
privilégient certaines géométries et peuvent proposer des nombres de groupes
différents. Leurs résultats doivent être confrontés aux profils des groupes
et à la question qui motive l'analyse.

=== Stabilité, interprétation et démarche pratique

Une partition utile doit être suffisamment stable pour que son interprétation
ne dépende pas d'une observation arbitraire. Il faut distinguer deux vérifications :

- répéter l'algorithme avec plusieurs initialisations examine sa sensibilité au point de départ ;
- modifier légèrement les données ou les rééchantillonner examine la sensibilité des groupes à l'échantillon.

Des initialisations qui donnent toujours la même solution ne prouvent pas à elles seules une stabilité aux variations des données.

Pour comparer deux partitions, on doit tenir compte du caractère arbitraire de leurs numéros. On peut notamment examiner quels couples d'observations restent regroupés, plutôt que comparer directement les étiquettes des groupes « 1 », « 2 », etc. Une visualisation aide également, mais une projection en deux ou trois dimensions peut masquer des séparations ou des chevauchements présents dans l'espace complet.

Une démarche d'analyse en apprentissage non supervisée suit ainsi plusieurs étapes :

1. Définir les observations, les variables et le type de similarité recherché.
2. Traiter les valeurs manquantes, choisir les transformations et examiner
   l'effet des unités et des observations atypiques.
3. Comparer des partitions selon plusieurs nombres de groupes, initialisations
   ou méthodes lorsque ces choix sont incertains.
4. Examiner les critères internes et la stabilité, puis décrire les effectifs,
   les centres, les dispersions et les profils dans les unités originales.
5. Vérifier que les différences observées répondent à la question initiale.

Pour une exploration descriptive, on peut utiliser toutes les observations
disponibles. Si les groupes doivent ensuite servir à affecter de nouveaux
individus ou à alimenter un modèle prédictif, les transformations et le
regroupement doivent être appris sur les données d'entraînement et appliqués
aux nouvelles observations sans utiliser leurs réponses.

#remark[
  Un algorithme peut découper un nuage continu sans que des groupes nettement séparés existent dans la population. Les noms attribués aux groupes sont des descriptions à justifier. En effet, ils ne démontrent ni des catégories naturelles ni des mécanismes causaux.
]


== Les $k$-moyennes <kmeans>

=== Principe et critère à minimiser

La méthode des *$k$-moyennes* (*$k$-means)*, répartit des observations numériques autour de $K$ centroïdes. Le nombre $K$ est fixé pour un ajustement donné. On travaille dans l'espace choisi après les éventuelles transformations. Les vecteurs $x_i$ ci-dessous désignent les observations dans cet espace.

#definition(title: [Critère des k-moyennes])[
  Pour une partition $cal(C)$ et des centres $mu_1, dots, mu_K$, on considère

  $ Q(cal(C),mu_1,dots,mu_K)
    = sum_(g=1)^K sum_(i in C_g) norm(x_i-mu_g)^2. $

  On cherche à minimiser ce critère à la fois sur les affectations et sur les centres.
]

#property(title: [Centre optimal d'un groupe])[
  Si la partition $cal(C)$ est fixée, le centre du groupe $g$ qui minimise
  la somme des distances euclidiennes au carré est sa moyenne $overline(x)_g$.
]

#proof[
  Pour tout vecteur $m$,

  $ sum_(i in C_g) norm(x_i-m)^2
    = sum_(i in C_g) norm(x_i-overline(x)_g)^2
      + n_g norm(m-overline(x)_g)^2. $

  Le second terme est positif ou nul et s'annule pour $m=overline(x)_g$.
]

En remplaçant chaque centre par cette moyenne, le critère devient exactement
l'inertie intra-groupe $W(cal(C))$. Le centroïde peut être un point qui
n'existe pas parmi les observations, il l'est d'ailleurs généralement. Il résume la position moyenne des observations du groupe.

La moyenne est donc liée au carré de la distance euclidienne. Remplacer la distance euclidienne par une autre dissimilarité tout en conservant la même mise à jour des moyennes ne garantit plus la minimisation du critère $Q$ correspondant.

=== L'algorithme de Lloyd

Explorer toutes les partitions possibles est trop coûteux dès que le nombre d'observations devient important. L'algorithme de Lloyd alterne deux problèmes plus simples, chacun résolu exactement conditionnellement à l'autre.

*Initialisation.* À l'itération $t=0$, on choisit $K$ centres initiaux $mu_g^((0))$ aléatoirement, par exemple parmi des observations distinctes. Ce mode d'initialisation exige au moins $K$ observations distinctes dans les données.

*Affectation.* À l'itération $t+1$, chaque observation rejoint le centre le
plus proche, suivant une distance euclidienne :

$ c_i^((t+1)) = argmin_(g in {1,dots,K}) norm(x_i-mu_g^((t)))^2, quad
  C_g^((t+1)) = {i : c_i^((t+1))=g}. $

En cas d'égalité, on applique une règle de départage fixée. Cette étape
n'augmente pas le critère, puisque les centres sont inchangés et que chaque
observation choisit sa meilleure affectation.

*Mise à jour.* On note $n_g^((t+1)) = abs(C_g^((t+1)))$. Pour chaque groupe non vide, on recalcule la moyenne :

$ mu_g^((t+1)) = 1/n_g^((t+1)) sum_(i in C_g^((t+1))) x_i. $

Cette étape n'augmente pas non plus le critère, puisque la moyenne minimise
la somme des distances au carré pour les affectations fixées. On répète les
deux étapes jusqu'à stabilisation des affectations ou jusqu'à une règle
d'arrêt numérique, avec un nombre maximal d'itérations.

La valeur du critère décroît au sens large et reste positive ou nulle.
En arithmétique exacte, avec des groupes non vides et un départage cohérent
des égalités, la procédure finit par se stabiliser. Cela garantit un point
fixe de ces mises à jour, mais pas le minimum global du critère. Si un groupe
devient vide, sa moyenne n'est pas définie : l'implémentation doit prévoir
une stratégie, par exemple réinitialiser ce centre sur une observation mal
représentée.

#example[
  Reprenons les observations $0,1,2,8,9,10$ avec $K=2$, en initialisant les centres à $0$ et $2$. La valeur $1$ est à égale distance des deux centres. On l'affecte au premier groupe selon la règle de départage fixée.

  La première affectation donne $C_1={0,1}$ et $C_2={2,8,9,10}$. Les centres
  recalculés sont $0.5$ et $7.25$, et l'inertie intra-groupe vaut $39.25$.

  À l'affectation suivante, la valeur $2$ rejoint le premier groupe. Les
  groupes deviennent ${0,1,2}$ et ${8,9,10}$, leurs centres $1$ et $9$,
  et l'inertie vaut $4$. Les affectations suivantes restent identiques :
  l'algorithme est stabilisé.
]

=== Initialisation et solutions locales

Deux initialisations peuvent conduire à deux partitions stables différentes, avec des valeurs de $W$ différentes. Il est donc utile de lancer plusieurs ajustements pour le même $K$ et de conserver celui de plus faible inertie intra-groupe. Le nombre d'initialisations et le nombre d'itérations par initialisation sont deux réglages distincts. En effet, laisser plus longtemps évoluer une partition déjà stable ne lui permet pas de quitter cette solution.

#example[
    Considérons les quatre points $(-2,-1)$, $(-2,1)$, $(2,-1)$ et $(2,1)$,
    avec $K=2$. Une séparation gauche/droite donne les centres $(-2,0)$ et $(2,0)$ et une inertie intra-groupe $W=4$. Une séparation bas/haut donne les centres $(0,-1)$ et $(0,1)$ et une inertie intra-groupe $W=16$.

    Dans les deux cas, chaque point est affecté à son centre le plus proche et chaque centre est la moyenne de son groupe. Les deux partitions sont donc stables pour l'algorithme de Lloyd, alors que la seconde est moins bonne pour le critère.

    #figure(
    image("../figures/kmeans_initialisations.svg", width: 100%,
      alt: "Les mêmes quatre sommets d'un rectangle sont regroupés à gauche "
        + "selon leur position gauche ou droite, avec une inertie de 4, et à "
        + "droite selon leur position basse ou haute, avec une inertie de 16. "
        + "Les deux partitions sont stables pour l'algorithme de Lloyd."),
    caption: [Deux solutions obtenues pour $K=2$. À gauche, les centres initiaux
      étaient les deux points du bas ; à droite, les deux points de gauche.
      Les segments relient les observations à leur centroïde final.],
  )
]


L'initialisation *$k$-means++* cherche à mieux répartir les centres lors de l'initialisation. Elle choisit un premier point au hasard, puis les suivants avec une probabilité proportionnelle au carré de leur distance au centre déjà choisi le plus proche. Les régions encore mal couvertes ont ainsi davantage de chances de recevoir un centre. Cette initialisation améliore souvent le départ de l'algorithme, sans garantir que l'ajustement final atteigne l'optimum global.

Fixer une graine aléatoire permet de reproduire un calcul ; cela ne rend pas sa partition meilleure. Pour examiner la sensibilité à l'initialisation, il faut comparer plusieurs départs, leurs inerties et leurs affectations.

=== Géométrie des groupes et affectation d'un nouveau point

Pour des centres de groupes fixés, les observations sont réparties en régions de
Voronoï : la région du centre $mu_g$ contient les points plus proches de ce
centre que des autres. La frontière entre deux centres distincts vérifie

$ norm(x-mu_g)^2 = norm(x-mu_h)^2, $

soit, après simplification,

$ 2(mu_h-mu_g)^top x = norm(mu_h)^2-norm(mu_g)^2. $

La frontière est donc une droite en dimension deux et un hyperplan en
dimension supérieure. Chaque région est une intersection de demi-espaces et
est convexe. Les groupes ne sont pas obligatoirement des sphères, mais le
critère favorise une faible dispersion autour d'un centre dans la géométrie
euclidienne retenue.

Pour affecter une nouvelle observation, on lui applique les transformations
déjà estimées, puis on choisit le centre le plus proche :

$ hat(c)(x) = argmin_(g in {1,dots,K}) norm(x-mu_g)^2. $

Les centres restent alors fixes. Inclure cette observation dans un nouvel
ajustement répond à une autre question et peut déplacer les centres ainsi
que les anciennes affectations. La proximité à un centre ne fournit pas,
à elle seule, une probabilité d'appartenance à un groupe.

=== Choisir le nombre de groupes

Pour chaque valeur candidate de $K$, on compare plusieurs initialisations.
L'inertie minimale théorique $W_K^*$ est non croissante avec $K$ : on peut
scinder un groupe sans augmenter la somme des carrés. Minimiser directement
$W_K^*$ sur $K$ conduirait donc à multiplier les groupes. Les valeurs obtenues
par un algorithme local peuvent exceptionnellement ne pas suivre cette
décroissance si certains ajustements restent dans de mauvaises solutions.

La *méthode du coude* cherche une rupture dans la courbe des inerties : après une forte baisse, chaque groupe supplémentaire apporte une amélioration plus modeste. Lorsque les observations ne sont pas bien séparées, plusieurs coudes peuvent être plausibles, ou aucun coude ne ressortir clairement.

On peut compléter cette lecture par la *silhouette moyenne* et l'indice de
*Calinski-Harabasz*. Ces critères comparent des compromis entre compacité et
séparation, sans nécessairement sélectionner le même $K$. La silhouette est
calculée avec une distance explicitement choisie.

Le choix final tient aussi compte des effectifs, des profils et de la stabilité
des groupes. Une subdivision supplémentaire peut être utile pour une question
précise, même si elle ne maximise pas un indice global. Inversement, un
nouveau groupe constitué de quelques valeurs extrêmes peut traduire une
sensibilité du critère plutôt qu'un profil d'intérêt.

#example(title: [Retenir trois groupes plutôt que quatre], breakable: true)[
  Considérons les neuf observations
  $0,1,2,10,11,12,20,21,22$, avec la distance euclidienne, sans transformation.
  Leur moyenne est $11$ et leur inertie totale vaut $T=606$.

  Pour chaque $K$, on retient une partition qui minimise l'inertie intra-groupe.
  Dans ce petit exemple, on peut vérifier ce minimum en examinant toutes les
  découpes des valeurs ordonnées en $K$ groupes consécutifs. Les partitions
  retenues sont les suivantes, avec les groupes écrits en termes de valeurs :

  - $K=1$ : toutes les observations dans un même groupe ;
  - $K=2$ : ${0,1,2}$ et ${10,11,12,20,21,22}$ ;
  - $K=3$ : ${0,1,2}$, ${10,11,12}$ et ${20,21,22}$ ;
  - $K=4$ : ${0}$, ${1,2}$, ${10,11,12}$ et ${20,21,22}$.

  Pour $K=2$ et $K=4$, plusieurs partitions atteignent le même minimum
  d'inertie ; les critères ci-dessous correspondent aux partitions indiquées.

  #block(breakable: false)[
    #table(
      columns: (0.5fr, 1fr, 1.5fr, 1fr),
      align: center,
      table.header([*$K$*], [*Inertie $W$*], [*Silhouette moyenne*], [*CH*]),
      [1], [606], [—], [—],
      [2], [156], [0,641], [20,19],
      [*3*], [*6*], [*0,862*], [*300*],
      [4], [4,5], [0,628], [222,78],
    )
  ]

  *Lecture du coude.* Ajouter un deuxième groupe réduit $W$ de $450$, puis
  un troisième le réduit encore de $150$. En revanche, le quatrième groupe
  ne fait gagner que $1.5$. La courbe des inerties présente donc un coude
  marqué à $K=3$ : au-delà, le gain devient faible.

  *Confronter les critères et les profils.* Parmi les valeurs comparées,
  la silhouette moyenne et CH sont aussi maximaux pour $K=3$. Les centres
  sont alors $1$, $11$ et $21$, et chaque groupe contient trois observations
  proches. Passer à quatre groupes isole la valeur $0$ de ses voisines $1$
  et $2$, sans faire apparaître un nouvel ensemble nettement séparé.
  On retient donc ici *trois groupes*, même si quatre groupes donnent une
  inertie plus petite. La silhouette et CH ne sont pas définis pour $K=1$
]

=== Étude de cas : Palmer Penguins

On regroupe les manchots à partir des quatre mesures `bill_length_mm`,
`bill_depth_mm`, `flipper_length_mm` et `body_mass_g`. Les deux observations
auxquelles il manque une de ces mesures sont retirées et les $342$ autres sont
conservées. Les données sont centrées et réduites avec les écarts-types
empiriques, de diviseur $n-1$. Il s'agit d'une exploration descriptive de
l'ensemble disponible : `species` n'intervient ni dans les distances,
ni dans les ajustements, ni dans le choix de $K$.

On compare $K=1, dots, 8$ avec $50$ initialisations par valeur. On utilise la fonction `kmeans` de R avec l'algorithme de Hartigan-Wong, qui optimise le même critère d'inertie par une procédure différente de l'alternance de Lloyd.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/kmeans.html")[documentation
  de `stats::kmeans`], notamment les arguments `algorithm`, `nstart` et `iter.max`.
] L'inertie totale vaut ici $T=4 times (342-1)=1364$ : chacune des quatre
variables réduites a une somme de carrés égale à $341$.

#table(
  columns: (0.6fr, 1.2fr, 1.2fr, 1.3fr, 1fr), align: center,
  table.header([*$K$*], [*Inertie $W$*], [*Pseudo-$R^2$*],
    [*Silhouette moyenne*], [*CH*]),
  [1], [1364,00], [0,00~%], [—], [—],
  [*2*], [*564,05*], [*58,65~%*], [*0,532*], [*482,2*],
  [3], [378,28], [72,27~%], [0,447], [441,7],
  [4], [299,52], [78,04~%], [0,400], [400,4],
  [5], [231,92], [83,00~%], [0,378], [411,3],
  [6], [203,72], [85,06~%], [0,372], [382,7],
  [7], [186,41], [86,33~%], [0,335], [352,7],
  [8], [170,47], [87,50~%], [0,299], [334,1],
)

La silhouette moyenne est maximale pour $K=2$ parmi les valeurs évaluées.
L'indice de Calinski-Harabasz donne ici le même choix. On retient donc deux
groupes pour cette description. L'inertie continue de diminuer au-delà,
mais le passage à trois groupes ne donne pas une meilleure silhouette moyenne.
Cela ne démontre pas qu'il existe exactement deux sous-populations naturelles.

#figure(
  image("../figures/kmeans_choix_k.svg", width: 100%,
    alt: "Sur Palmer Penguins, l'inertie intra-groupe diminue de 1364 pour "
      + "un groupe à 564 pour deux groupes, puis continue à diminuer. "
      + "La silhouette moyenne est maximale à deux groupes, avec 0,532."),
  caption: [Choisir $K$ sur les quatre mesures réduites. La baisse de l'inertie
    ne suffit pas à arrêter le nombre de groupes. Le trait vertical indique
    $K=2$, retenu ici à partir de la silhouette moyenne.],
)

*Décrire les groupes.* Pour faciliter la présentation, les groupes sont
numérotés par masse moyenne croissante. Cette renumérotation ne modifie ni
les affectations ni le critère. Les centroïdes, reconvertis dans les unités
originales, donnent les profils suivants :

#table(
  columns: (2fr, 1.2fr, 1.2fr), align: center,
  table.header([*Variable*], [*Groupe 1*], [*Groupe 2*]),
  [Effectif], [219], [123],
  [`bill_length_mm`], [41,91], [47,50],
  [`bill_depth_mm`], [18,37], [14,98],
  [`flipper_length_mm`], [191,78], [217,19],
  [`body_mass_g`], [3710,73], [5076,02],
)

Le groupe 2 rassemble des individus en moyenne plus lourds, aux nageoires et
au bec plus longs, mais dont le bec est moins profond. Ces moyennes décrivent
des tendances : elles ne signifient pas que tous les individus d'un groupe
dépassent tous ceux de l'autre sur chaque mesure.

#figure(
  image("../figures/kmeans_palmerpenguins.svg", width: 92%,
    alt: "Les 342 manchots sont projetés sur les deux premières composantes "
      + "principales, avec une couleur par groupe de k-means. Le groupe 1 "
      + "contient 219 individus et le groupe 2 en contient 123. Les croix "
      + "représentent les projections des centroïdes."),
  caption: [Visualisation de la partition sur un plan d'ACP. Les $k$-means sont
    ajustés dans l'espace des quatre mesures réduites ; l'ACP sert uniquement
    à afficher le résultat. Les croix sont les centroïdes projetés. Les
    pourcentages des axes décrivent la variance conservée par l'ACP et se
    distinguent du pseudo-$R^2$ de la partition.],
)

*Comparer après l'ajustement.* Le tableau croisant les groupes avec `species`
montre que le groupe 1 rassemble les $151$ `Adelie` et les $68$ `Chinstrap`,
tandis que le groupe 2 contient les $123$ `Gentoo`. Les deux groupes ne
reproduisent donc pas les trois espèces. Ils résument une séparation
morphologique forte pour les variables et la pondération choisies, sans
obligation de retrouver une classification biologique donnée.


=== Limites et variantes

*Une géométrie liée aux centres.* Les $k$-means fonctionnent particulièrement
bien lorsque la distance à une moyenne résume convenablement chaque groupe.
Ils peuvent couper un groupe très étendu ou fusionner de petits groupes
voisins lorsque les dispersions et les effectifs diffèrent fortement.
Ils n'imposent pas formellement des tailles égales ou des covariances
sphériques identiques, mais ces différences peuvent rendre leur critère peu
adapté à la structure recherchée.

Deux anneaux concentriques illustrent cette limite : avec $K=2$, la frontière
entre les deux centres est une droite, qui ne peut pas séparer un anneau
intérieur d'un anneau extérieur. Des méthodes par densité, des méthodes
spectrales ou une autre représentation peuvent être plus pertinentes selon
le problème.

*Une sensibilité aux valeurs extrêmes.* Les distances sont élevées au carré
et les centres sont des moyennes. Une observation très éloignée peut déplacer
un centre ou former à elle seule un groupe, au détriment d'autres distinctions.
La standardisation par l'écart-type est elle-même sensible aux valeurs extrêmes.
Il faut donc comprendre ces observations et examiner leur effet sur la
partition, plutôt que les supprimer automatiquement.

*Des groupes même sans séparation nette.* Les k-means affectent toutes les
observations à un centre, y compris les points isolés et les observations
aux frontières. Une partition stable ou une baisse importante de $W$ ne
garantit pas une interprétation substantielle. Les différences de distance
aux centres peuvent renseigner sur une ambiguïté, sans devenir pour autant
des probabilités d'appartenance.


== La classification hiérarchique <classification-hierarchique>

=== Principe

Les $k$-moyennes produisent une partition pour un nombre de groupes fixé.
La classification hiérarchique cherche plutôt à organiser les observations
à *plusieurs niveaux de regroupement*. Des profils très proches peuvent former
de petits groupes, qui se réunissent ensuite en ensembles plus larges.

#definition(title: [Classification hiérarchique et dendrogramme])[
  Une classification hiérarchique construit des partitions *emboîtées* :
  chaque groupe d'une partition fine est entièrement inclus dans un groupe
  de toute partition plus grossière.

  Un *dendrogramme* représente cette hiérarchie par un arbre. Ses feuilles
  correspondent aux observations et ses nœuds internes aux regroupements.
  La hauteur d'un nœud indique la valeur du critère lors de la fusion.
]

Deux démarches sont possibles :

- la *classification ascendante hiérarchique* (*CAH*, ou méthode agglomérative)
  part de $n$ groupes d'une observation et fusionne deux groupes à chaque étape ;
- une méthode *descendante* part d'un seul groupe et le subdivise progressivement.
  Elle exige un critère de division et n'est pas, en général, l'inverse d'une CAH.

On étudie ici la démarche ascendante. Après $r$ fusions, pour
$r in \{0,dots,n-1\}$, la partition $cal(C)^(r)$ contient $n-r$ groupes.
La dernière fusion réunit toutes les observations. L'emboîtement impose une
contrainte forte : *deux observations réunies ne seront plus séparées*.

#example[
  Une enquête peut faire apparaître quatre profils de pratiques : deux profils
  surtout orientés vers les activités individuelles et deux vers les activités
  collectives. Une partition en quatre groupes décrit les différences fines ;
  une coupe plus haute de la même hiérarchie peut résumer ces profils par deux
  grandes familles. Les deux descriptions correspondent à des niveaux différents,
  sans qu'il soit nécessaire d'en déclarer une seule « vraie ».
]

Le dendrogramme n'est pas un arbre de classification supervisée comme CART.
Il n'apprend pas des questions successives sur les variables pour prédire une
réponse : il représente les regroupements des observations déjà analysées.

=== Construire une classification ascendante

On commence par choisir les variables, leur éventuelle transformation et une
dissimilarité $d_(i ell)=d(x_i,x_ell)$ entre observations. Pour des mesures
quantitatives, la distance euclidienne est un choix courant. Si les unités ou
les dispersions diffèrent fortement, on peut travailler sur les variables
centrées et réduites. Ce choix modifie la pondération des variables et doit
être justifié, comme pour les $k$-moyennes.

Une fois les dissimilarités fixées, on choisit un *critère de liaison*
$D(A,B)$ entre deux groupes non vides et disjoints $A$ et $B$. L'algorithme
suit alors les étapes suivantes :

1. Initialiser les groupes par les singletons $\{1\},dots,\{n\}$.
2. Parmi les paires de groupes actuels, choisir celle qui minimise $D(A,B)$.
3. Remplacer $A$ et $B$ par leur réunion $A union B$, et enregistrer la fusion
   ainsi que sa hauteur.
4. Recalculer les liaisons entre ce nouveau groupe et les groupes restants.
5. Répéter jusqu'à ne conserver qu'un seul groupe.

On ne choisit donc pas les $n-1$ plus petites distances du tableau initial :
les comparaisons portent sur des groupes qui changent après chaque fusion.
En cas d'égalité du critère, il faut une règle de départage ; l'ordre des
observations ou le logiciel peut alors modifier certaines branches.

La méthode est *gloutonne*. Elle retient la meilleure fusion immédiate,
sans examiner toutes les hiérarchies possibles. Elle n'utilise pas
d'initialisation aléatoire dans sa forme classique, mais ce caractère
déterministe ne garantit ni l'optimalité globale ni la stabilité statistique.

=== Distances entre groupes

Notons $n_A=abs(A)$ et $n_B=abs(B)$ les effectifs de deux groupes. Une distance
entre deux observations ne définit pas à elle seule une distance entre groupes.
Les principales liaisons répondent à des questions différentes.

*Liaison simple, ou plus proche voisin.* Elle utilise la paire la plus proche :

$ D_"simple" (A,B)=min_(i in A, ell in B) d_(i ell). $

Deux groupes peuvent donc être fusionnés dès qu'un seul de leurs membres les
rapproche. Cette liaison peut suivre des formes allongées ou irrégulières, mais
présente un *effet de chaîne* : une succession de points proches peut relier
des ensembles dont les extrémités sont très éloignées.

*Liaison complète, ou plus distant voisin.* Elle utilise la paire la plus éloignée :

$ D_"complète" (A,B)=max_(i in A, ell in B) d_(i ell). $

Elle évite qu'un unique point de contact suffise à réunir deux groupes et tend
à produire des groupes de faible diamètre. Une observation extrême peut en
revanche maintenir un groupe à l'écart ou modifier fortement une fusion.

*Liaison moyenne.* On calcule la moyenne de toutes les distances entre les
deux groupes :

$ D_"moyenne" (A,B)=1/(n_A n_B) sum_(i in A) sum_(ell in B) d_(i ell). $

Chaque paire d'observations a le même poids. Après la fusion de $A$ et $B$,
la liaison avec un autre groupe $C$ se met à jour par

$ D_"moyenne" (A union B,C)
  =n_A/(n_A+n_B) D_"moyenne" (A,C)
   +n_B/(n_A+n_B) D_"moyenne" (B,C). $

Il ne s'agit donc pas de la moyenne non pondérée de deux anciennes liaisons,
sauf si $n_A=n_B$. Cette méthode est aussi appelée *UPGMA*.

*Liaison par centroïdes.* Pour des observations dans un espace euclidien,
elle utilise les moyennes $overline(x)_A$ et $overline(x)_B$ :

$ D_"centroïdes" (A,B)=norm(overline(x)_A-overline(x)_B). $

La distance entre moyennes est différente de la moyenne des distances.
Des groupes étendus, voire entrelacés, peuvent avoir des centroïdes proches.
Les conventions de calcul et d'affichage, notamment l'emploi des distances
ou de leurs carrés, doivent être vérifiées dans le logiciel.

#example[
  *Quatre résumés des mêmes distances.* En une dimension, prenons
  $A=\{0,2\}$ et $B=\{3,5\}$, avec $d(x_i,x_ell)=abs(x_i-x_ell)$.
  Les quatre distances entre les groupes sont $3$, $5$, $1$ et $3$.

  On obtient $D_"simple" (A,B)=1$, $D_"complète" (A,B)=5$ et
  $D_"moyenne" (A,B)=(3+5+1+3)/4=3$. Les centroïdes sont $1$ et $4$,
  donc $D_"centroïdes" (A,B)=3$ également. Cette dernière égalité est
  particulière à cet exemple ; les définitions restent différentes.
]

Ces liaisons sont des critères de regroupement ; elles ne satisfont pas
nécessairement tous les axiomes d'une distance sur les ensembles. Les liaisons
simple, complète et moyenne peuvent utiliser des dissimilarités adaptées à des
données non quantitatives. La méthode de Ward demande un cadre plus précis.

=== La méthode de Ward et l'inertie

Ward cherche à conserver des groupes dont les observations sont proches
de leur centroïde. On conserve les inerties sans normalisation introduites
au début du chapitre. Pour un groupe $A$, notons

$ W(A)=sum_(i in A) norm(x_i-overline(x)_A)^2. $

Si l'on fusionne $A$ et $B$, le nouveau centroïde est
$overline(x)_(A union B)=(n_A overline(x)_A+n_B overline(x)_B)/(n_A+n_B)$.
Les autres groupes ne changent pas : la variation de l'inertie intra-groupe
totale est donc

$ Delta W(A,B)=W(A union B)-W(A)-W(B). $

#property(title: [Coût d'une fusion selon Ward])[
  Pour la distance euclidienne et des observations de même poids,

  $ Delta W(A,B)=(n_A n_B)/(n_A+n_B)
      norm(overline(x)_A-overline(x)_B)^2. $

  À chaque étape, Ward fusionne les deux groupes dont ce coût est le plus faible.
]

Pour retrouver la formule, on décompose chaque écart à la nouvelle moyenne
en un écart au centroïde du groupe et un déplacement de ce centroïde. Les
termes croisés s'annulent ; il reste
$n_A norm(overline(x)_A-overline(x)_(A union B))^2
+n_B norm(overline(x)_B-overline(x)_(A union B))^2$.
En remplaçant le nouveau centroïde par sa moyenne pondérée, on obtient
l'expression annoncée.

Ward ne consiste donc pas simplement à fusionner les centroïdes les plus
proches : *les effectifs interviennent*. Dans l'exemple précédent, les deux
groupes ont chacun deux points et des moyennes distantes de $3$, d'où
$Delta W=(2 times 2)/(2+2) times 3^2=9$.
Pour deux singletons, ce coût serait la moitié du carré de leur distance.

*Quelle hauteur afficher ?* On peut construire le dendrogramme avec
$Delta W$ comme hauteur, mais ce n'est pas la convention de tous les logiciels.
Avec des distances euclidiennes ordinaires en entrée, `hclust` de R et
`method = "ward.D2"` affichent

$ h(A,B)=sqrt(2 Delta W(A,B)). $

Les deux conventions donnent le même ordre de fusion, mais des hauteurs
numériques différentes. Le script du cours vérifie cette identité à chaque
fusion. Il faut fournir `dist(x)` à `ward.D2`, et non `dist(x)^2` :
la méthode effectue elle-même la mise au carré nécessaire.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/hclust.html")[documentation
  de `stats::hclust`] et la distinction entre `ward.D` et `ward.D2`.
  La convention euclidienne de Ward est également décrite dans la
  #link("https://docs.scipy.org/doc/scipy/reference/generated/scipy.cluster.hierarchy.linkage.html")[documentation de `scipy.cluster.hierarchy.linkage`].
]

L'interprétation par une augmentation de somme des carrés suppose une géométrie
euclidienne. Appliquer Ward à une dissimilarité quelconque ne suffit pas à lui
donner cette interprétation. Avec des variables standardisées, l'inertie porte
sur ces variables transformées, et non sur les mesures dans leurs unités initiales.

=== Exemple : construire une hiérarchie à la main

On reprend six observations unidimensionnelles, sans transformation :

$ A=0, quad B=1, quad C=2, quad D=8, quad E=9, quad F=10. $

On utilise Ward. Les premières distances présentent des égalités ; pour fixer
la présentation, on retient successivement les fusions du tableau ci-dessous.
Ce sont aussi celles produites par le script R avec cet ordre d'observations.
La notation $"AB"$ désigne le groupe $\{A,B\}$.

#block(breakable: false)[
  #table(
    columns: (0.65fr, 1.8fr, 1fr, 1.15fr, 0.65fr), align: center,
    table.header([*Étape*], [*Groupes fusionnés*], [*$Delta W$*],
      [*Hauteur $h$*], [*$K$*]),
    [1], [$A$ et $B$], [0,5], [1], [5],
    [2], [$D$ et $E$], [0,5], [1], [4],
    [3], [$"AB"$ et $C$], [1,5], [1,732], [3],
    [4], [$"DE"$ et $F$], [1,5], [1,732], [2],
    [5], [$"ABC"$ et $"DEF"$], [96], [13,856], [1],
  )
]

La première fusion coûte $(1 times 1)/(1+1) times (0-1)^2=0.5$.
À la troisième étape, le groupe $"AB"$ a pour moyenne $0.5$ et pour effectif $2$ :
le fusionner avec $C$ coûte
$(2 times 1)/(2+1) times (0.5-2)^2=1.5$.

Après quatre fusions, les groupes sont $\{0,1,2\}$ et $\{8,9,10\}$, de
moyennes $1$ et $9$. Leur inertie intra-groupe vaut
$W=0.5+0.5+1.5+1.5=4$. La dernière fusion ajoute
$(3 times 3)/(3+3) times (1-9)^2=96$, d'où $W=100$ pour un seul groupe :
on retrouve l'inertie totale.

Plus généralement, en partant des singletons d'inertie nulle, l'inertie de
la coupe en $K$ groupes est la somme des coûts des $n-K$ premières fusions.
Ce lien relie directement la hiérarchie de Ward aux critères de partition
définis au début du chapitre.

#figure(
  image("../figures/cah_exemple.svg", width: 100%,
    alt: "Dendrogramme de Ward des valeurs 0, 1, 2, 8, 9 et 10. Une coupe à hauteur 2,5 donne deux groupes ; un zoom montre qu'une coupe à 1,3 donne quatre groupes."),
  caption: [Hiérarchie de Ward et deux coupes. À gauche, la dernière fusion
    réunit deux ensembles bien séparés. À droite, le zoom montre les fusions
    de hauteurs $1$ et $sqrt(3)$. Les couleurs repèrent les deux grandes branches ;
    elles ne représentent pas la partition en quatre groupes du zoom.],
)

=== Lire un dendrogramme

*Suivre les fusions.* On part des observations, en bas, puis on remonte leurs
branches. Deux observations appartiennent au même groupe à partir du premier
nœud qui leur est commun. La hauteur de ce nœud résume leur rapprochement dans
la hiérarchie ; elle est parfois appelée *dissimilarité cophénétique*. Elle
n'est pas nécessairement leur distance initiale.

*Ne pas interpréter l'axe horizontal comme une distance.* On peut permuter les
deux branches issues d'un nœud sans changer aucun groupe ni aucune hauteur.
Deux feuilles voisines sur le dessin ne sont donc pas nécessairement les deux
observations les plus proches. C'est la hauteur de leur réunion et la structure
des branches qu'il faut lire.

*Passer à une partition.* Lorsque les hauteurs sont non décroissantes, une
coupe horizontale à une hauteur $h$ regroupe les observations reliées sous
cette coupe. Si la droite ne passe par aucun nœud, le nombre de branches
verticales qu'elle traverse est le nombre de groupes $K$.

Dans l'exemple, une coupe à $h=2.5$ produit $\{A,B,C\}$ et $\{D,E,F\}$.
Une coupe à $h=1.3$ donne $\{A,B\}$, $\{C\}$, $\{D,E\}$ et $\{F\}$.
Il s'agit de deux partitions extraites du même arbre, sans nouvel ajustement.

On peut aussi demander directement $K$ groupes en conservant les $n-K$
premières fusions. *Une coupe par hauteur et une coupe par nombre ne sont pas
toujours équivalentes.* Ici, deux fusions ont la même hauteur $sqrt(3)$ :
aucune droite horizontale, en dehors des nœuds, ne donne exactement trois
groupes. `cutree(arbre, k = 3)` utilise l'ordre enregistré des fusions pour
conserver $\{A,B,C\}$, $\{D,E\}$ et $\{F\}$. L'autre ordre des deux fusions
ex æquo donnerait $\{A,B\}$, $\{C\}$ et $\{D,E,F\}$.#footnote[
  La #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cutree.html")[documentation
  de `stats::cutree`] distingue les arguments `k` et `h` et précise la condition
  de monotonie pour une coupe par hauteur.
]

#remark(title: [Des hauteurs qui peuvent redescendre])[
  La liaison par centroïdes peut produire une *inversion* : une fusion a
  une hauteur inférieure à celle d'une fusion précédente. Par exemple, pour
  $A=(-1,0)^top$, $B=(1,0)^top$ et $C=(0,1.8)^top$, les points $A$ et $B$
  sont les plus proches, à distance $2$. Leur centroïde est $(0,0)^top$,
  à distance $1.8$ de $C$ : la fusion suivante est plus basse.

  La hiérarchie reste emboîtée, mais la lecture par coupe horizontale devient
  problématique. Ce phénomène ne se produit pas pour les liaisons simple,
  complète et moyenne, ni pour Ward dans le cadre euclidien utilisé ici.
]

=== Choisir le nombre de groupes

La hiérarchie reporte le choix de $K$ ; elle ne le résout pas automatiquement.
Plusieurs niveaux peuvent être utiles selon la question étudiée.

*Examiner les sauts de fusion.* Une forte augmentation du critère indique
qu'une fusion réunit des groupes nettement moins semblables que les précédents.
On peut couper juste avant ce saut. Dans l'exemple, le passage de deux groupes
à un seul coûte $96$ unités d'inertie, contre $1.5$ pour chacune des deux
fusions précédentes : une description en deux groupes est naturelle.
Le saut doit être interprété selon le critère et sa convention d'affichage ;
les hauteurs de méthodes différentes ne sont pas directement comparables.

*Comparer les partitions extraites.* Pour les valeurs candidates de $K$, on
calcule les silhouettes dans la distance choisie, ou des critères comme
Calinski-Harabasz dans un espace euclidien. On examine aussi les effectifs et
les profils : un groupe minuscule peut signaler une observation isolée plutôt
qu'une subdivision utile. Diminuer seulement l'inertie de Ward conduirait,
comme pour les $k$-moyennes, à multiplier les groupes.

*Étudier la stabilité.* On peut refaire l'analyse après rééchantillonnage,
sur des sous-échantillons ou avec des choix de préparation plausibles.
Comparer la fréquence avec laquelle des observations sont regroupées aide
à distinguer une séparation robuste d'une branche fragile. Une grande hauteur
de fusion n'est, à elle seule, ni une probabilité ni un test de significativité.

Une contrainte d'usage peut enfin fixer le niveau pertinent : deux grandes
familles pour une synthèse, puis plusieurs sous-groupes pour une description
plus fine. Ce choix doit rester explicite.

=== Étude de cas : Palmer Penguins

On reprend les $342$ manchots complets pour `bill_length_mm`, `bill_depth_mm`,
`flipper_length_mm` et `body_mass_g`. Les quatre mesures sont centrées et
réduites avec les écarts-types de diviseur $n-1$, comme pour les $k$-moyennes.
L'analyse est descriptive et utilise l'ensemble disponible. `species`
n'intervient ni dans les distances, ni dans Ward, ni dans la sélection de $K$.

Le script `codes/classification_hierarchique.R` reproduit la hiérarchie,
les diagnostics et les tableaux. Le cœur de l'ajustement est le suivant :

```r
penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[variables]), ]
z <- scale(d[variables])
distances <- dist(z, method = "euclidean")
arbre <- hclust(distances, method = "ward.D2")

K_candidats <- 2:8
silhouettes <- sapply(K_candidats, function(K) {
  groupes <- cutree(arbre, k = K)
  mean(cluster::silhouette(groupes, distances)[, "sil_width"])
})
K_retenu <- K_candidats[which.max(silhouettes)]
groupes <- cutree(arbre, k = K_retenu)
plot(arbre, labels = FALSE, hang = -1)
rect.hclust(arbre, k = K_retenu)
```

Une seule hiérarchie fournit toutes les partitions candidates. La silhouette
est calculée avec les distances euclidiennes initiales entre mesures réduites,
et non avec les hauteurs du dendrogramme. En cas d'égalité exacte du maximum,
le script retient le plus petit $K$.

#block(breakable: false)[
  #table(
    columns: (0.6fr, 1.2fr, 1.2fr, 1.4fr), align: center,
    table.header([*$K$*], [*Inertie $W$*], [*Pseudo-$R^2$*], [*Silhouette moyenne*]),
    [*2*], [*564,05*], [*58,65~%*], [*0,532*],
    [3], [391,72], [71,28~%], [0,454],
    [4], [315,67], [76,86~%], [0,418],
    [5], [240,92], [82,34~%], [0,363],
    [6], [220,19], [83,86~%], [0,335],
    [7], [199,63], [85,36~%], [0,305],
    [8], [181,36], [86,70~%], [0,259],
  )
]

La silhouette moyenne est maximale pour $K=2$ parmi les coupes comparées.
La dernière fusion a une hauteur d'environ $40.00$, contre $18.57$ pour
l'avant-dernière. Une coupe entre ces hauteurs donne deux groupes. L'augmentation
finale d'inertie est $40.00^2/2 approx 800$, ce qui retrouve, à l'arrondi près,
$T-W_2=1364-564.05=799.95$.

#figure(
  image("../figures/cah_palmerpenguins.svg", width: 100%,
    alt: "Dendrogramme de Ward des 342 manchots, coupé en deux groupes de 219 et 123 individus. La silhouette moyenne des coupes de deux à huit groupes atteint son maximum, 0,532, à deux groupes."),
  caption: [Ward sur les quatre mesures standardisées de Palmer Penguins.
    Les étiquettes individuelles sont masquées pour rendre la hiérarchie lisible.
    La coupe représentée et les couleurs correspondent à $K=2$, retenu par
    silhouette moyenne parmi les valeurs étudiées.],
)

*Décrire la coupe retenue.* Pour la présentation, le script numérote les groupes
par `body_mass_g` moyen croissant. Le groupe 1 contient $219$ individus et
présente une masse moyenne de $3710.73$~g ; le groupe 2 contient $123$ individus
et présente une moyenne de $5076.02$~g. Le second groupe a aussi, en moyenne,
un bec et des nageoires plus longs, mais un bec moins profond.

Le tableau croisé calculé *après* l'ajustement donne :

#block(breakable: false)[
  #table(
    columns: (1fr, 1fr, 1fr, 1fr), align: center,
    table.header([*Groupe*], [*Adelie*], [*Chinstrap*], [*Gentoo*]),
    [1], [151], [68], [0],
    [2], [0], [0], [123],
  )
]

Cette coupe retrouve la partition en deux groupes présentée dans la
#link(<kmeans>)[section sur les $k$-moyennes]. Elle ne sépare pas les trois espèces. La correspondance biologique
sert ici à interpréter la partition ; elle n'a pas servi à construire la
hiérarchie ou à choisir sa coupe.

*Vérifier l'effet de la liaison.* Sur les mêmes distances et à $K=2$, les
résultats suivants montrent que le choix de liaison peut compter autant que
le nombre de groupes :

#block(breakable: false)[
  #table(
    columns: (1.2fr, 1fr, 1fr, 1.4fr), align: center,
    table.header([*Liaison*], [*Petit groupe*], [*Grand groupe*], [*Silhouette moyenne*]),
    [Simple], [1], [341], [0,253],
    [Complète], [123], [219], [0,532],
    [Moyenne], [123], [219], [0,532],
    [Ward], [123], [219], [0,532],
  )
]

La liaison simple relie progressivement presque tous les manchots et laisse
un singleton dans la coupe en deux groupes. Sa silhouette est moins élevée et
ses effectifs très déséquilibrés invitent à examiner cette solution. Ce résultat
ne condamne pas la liaison simple dans toute analyse : il décrit sa sensibilité
aux chemins de proximité dans ces données.

=== Comparaison avec les k-moyennes

Ward et les $k$-moyennes utilisent la même notion d'inertie intra-groupe
euclidienne, mais ne l'optimisent pas de la même manière. Pour un $K$ fixé,
les $k$-moyennes peuvent réaffecter les observations à des centres. Ward choisit
des fusions successives et conserve toutes les décisions précédentes.

Une coupe de Ward ne minimise donc pas nécessairement l'inertie parmi toutes
les partitions en $K$ groupes. Sur Palmer Penguins, pour $K=3$, elle donne
$W approx 391.72$, contre $378.28$ pour la solution de $k$-moyennes présentée
précédemment. L'accord à $K=2$ ne s'étend donc pas à tous les niveaux.

En contrepartie, Ward fournit une hiérarchie cohérente : les groupes à $K=3$
subdivisent nécessairement ceux à $K=2$. Deux ajustements indépendants de
$k$-moyennes avec ces nombres de groupes n'ont pas cette contrainte.
On peut aussi utiliser les centroïdes d'une coupe de Ward pour initialiser
des $k$-moyennes ; les réaffectations éventuelles abandonnent alors l'emboîtement
initial.

=== Forces et limites

*Une description à plusieurs niveaux.* Le dendrogramme montre comment les
groupes s'organisent et permet d'explorer plusieurs coupes sans réajuster la
méthode. Cette représentation est particulièrement utile lorsque les niveaux
fins et grossiers ont chacun une interprétation. Avec beaucoup d'observations,
il faut toutefois masquer les étiquettes, zoomer sur certaines branches ou
résumer les profils pour que le dessin reste lisible.

*Des choix de géométrie déterminants.* Variables, standardisation, dissimilarité
et liaison définissent ce que signifie « être proche ». Des variables
corrélées peuvent donner plusieurs fois du poids à une même caractéristique.
Les valeurs extrêmes peuvent former de petites branches ou modifier les
fusions ; ni le dendrogramme ni la standardisation ne les rendent inoffensives.

*Des fusions irréversibles.* Une réunion mal choisie au début affecte toutes
les coupes suivantes. Une petite perturbation des données peut aussi changer
l'ordre de fusions presque ex æquo. Obtenir exactement le même arbre à chaque
exécution sur un tableau fixé ne démontre pas qu'on l'obtiendrait sur un
autre échantillon.

*Un coût qui croît avec l'effectif.* Stocker toutes les distances nécessite
$n(n-1)/2$ nombres, soit une mémoire d'ordre $n^2$. Pour $n=10^4$, cela
représente près de $50$ millions de distances et environ $400$ Mo en nombres
de huit octets, avant les autres structures de calcul. Le temps dépend de
l'algorithme et de la liaison. Des pré-regroupements ou des approximations
peuvent faciliter l'analyse de grands jeux, mais modifient la hiérarchie recherchée.

*Une méthode descriptive, sans règle de prédiction automatique.* Ajouter une
observation et reconstruire l'arbre peut modifier les groupes existants.
L'affecter au centroïde le plus proche d'une coupe est une règle supplémentaire,
qui ne reproduit pas nécessairement la CAH sur les données augmentées.

Enfin, un arbre est construit même lorsque les données ne présentent pas de
groupes nettement séparés. Une coupe utile doit être soutenue par les profils,
les effectifs, des diagnostics adaptés et la stabilité, plutôt que par la seule
apparence du dendrogramme.

== Le mélange de gaussiennes

=== Modèle probabiliste

Les mélanges de gaussiennes proposent une approche probabiliste du regroupement.
On suppose que les données proviennent de $K$ sous-populations, chacune décrite
par une loi normale multivariée avec sa moyenne, sa covariance et son poids.

#definition(title: [Mélange de gaussiennes])[
  La densité du modèle peut s'écrire :

  $ f(x) = sum_(g=1)^K pi_g phi_g(x) $

  où $pi_g$ est le poids du groupe $g$ et $phi_g$ la densité normale multivariée de
  moyenne $mu_g$ et de matrice de covariance $Sigma_g$. Les poids vérifient
  $pi_g >= 0$ et $sum_(g=1)^K pi_g=1$.
]

Chaque observation a alors des probabilités d'appartenance aux groupes, plutôt
qu'une affectation strictement déterministe. On parle de classification souple.

=== Algorithme EM

Les étiquettes de groupe étant inconnues, on maximise la vraisemblance marginale
à l'aide de l'algorithme EM.

- Étape E : estimer les probabilités d'appartenance de chaque observation à
  chaque groupe.
- Étape M : mettre à jour les poids, les moyennes et les matrices de covariance.

Ces deux étapes sont répétées jusqu'à stabilisation de la vraisemblance. Comme
pour les k-means, l'algorithme peut converger vers une solution locale; plusieurs
initialisations sont donc utiles.

=== Géométrie des groupes

La forme des matrices de covariance détermine la géométrie des groupes :
sphères de même taille, sphères de tailles différentes, ellipsoïdes alignées
avec les axes ou ellipsoïdes libres.

Cette flexibilité rend les mélanges gaussiens plus riches que les k-means. Ils
peuvent représenter des groupes elliptiques, de tailles différentes et avec des
incertitudes variables. En contrepartie, ils demandent plus de paramètres et sont
plus sensibles aux petits effectifs.

=== Choisir le modèle

Dans les mélanges gaussiens, on ajuste souvent plusieurs modèles pour différentes
valeurs de $K$ et différentes contraintes de covariance. On compare ensuite les
modèles à l'aide de critères pénalisés comme AIC ou BIC. Le BIC favorise
généralement des modèles plus parcimonieux.

Il faut aussi vérifier que les groupes trouvés ont un sens substantiel. Un
modèle probabiliste peut séparer des observations pour améliorer la
vraisemblance sans produire des groupes utiles pour l'analyse.

=== Comparaison avec les k-means

Les k-means peuvent être vus comme une version très contrainte d'un mélange
gaussien : les groupes sont associés à des centres et la frontière dépend de la
distance au centroïde. Les mélanges gaussiens ajoutent des poids, des covariances
et des probabilités d'appartenance.

En pratique, les k-means sont simples et rapides; les mélanges gaussiens sont
plus expressifs et fournissent une mesure d'incertitude sur l'appartenance aux
groupes.

== Méthodes non supervisées modernes

=== Clustering par densité

Les méthodes par densité cherchent des régions où les observations sont plus
concentrées que dans le reste de l'espace. Elles sont utiles lorsque les groupes
ne sont pas sphériques, lorsque leur taille varie ou lorsque certaines
observations doivent être considérées comme du bruit.

DBSCAN est la méthode classique de cette famille. Elle regroupe les observations
qui appartiennent à des zones suffisamment denses et marque comme atypiques les
points isolés. Son principal défaut est le choix délicat d'un rayon de voisinage
unique lorsque les densités varient selon les régions.

HDBSCAN prolonge cette idée en construisant une hiérarchie de groupes fondée sur
la densité. Il permet d'extraire les groupes les plus stables et de laisser
certaines observations non affectées. C'est un bon complément aux k-means, car il
n'impose ni centres, ni formes sphériques, ni affectation obligatoire de tous les
points.

#remark[
  Les méthodes par densité restent dépendantes du choix de la distance. En grande
  dimension, il est souvent préférable de travailler après une réduction de
  dimension ou dans un espace de représentation adapté.
]

=== Clustering sur graphes

Une autre approche consiste à transformer les observations en graphe. Les noeuds
représentent les observations, et les arêtes relient des observations proches ou
similaires. Le regroupement devient alors un problème de détection de
communautés.

Cette formulation est naturelle pour les réseaux sociaux, les graphes de
relations, les données biologiques ou les graphes de plus proches voisins
construits à partir de données tabulaires. Elle permet de détecter des groupes
qui ne sont pas bien décrits par un centroïde ou par une loi gaussienne.

L'algorithme de Leiden améliore l'algorithme de Louvain pour la détection de
communautés. Il cherche des partitions de bonne qualité tout en évitant certains
groupes mal connectés. En pratique, il est très utilisé lorsque l'on construit un
graphe de voisins, par exemple après une étape de réduction de dimension ou de
calcul d'embeddings.

=== Représentations apprises et embeddings

Les méthodes modernes séparent souvent deux problèmes : apprendre une bonne
représentation des observations, puis regrouper les observations dans cet espace.
Cette stratégie est particulièrement utile pour les images, les textes, les sons
ou les données très hautement dimensionnelles.

Un autoencodeur peut apprendre une représentation latente en reconstruisant ses
entrées. Deep Embedded Clustering, ou DEC, combine cette idée avec un objectif de
clustering : le réseau apprend simultanément un espace latent et des affectations
de groupes.

Pour des données textuelles, on peut produire des embeddings avec un modèle de
langage, réduire la dimension si nécessaire, puis appliquer HDBSCAN ou k-means.
BERTopic suit cette logique : il regroupe des documents représentés par des
embeddings, puis décrit chaque groupe par des mots caractéristiques.

#example[
  Pour analyser des réponses libres à un questionnaire, on peut transformer les
  textes en embeddings, regrouper les réponses proches, puis décrire chaque
  groupe par quelques phrases représentatives. Le regroupement sert alors à
  organiser la lecture qualitative.
]

=== Prolongements

Plusieurs directions récentes prolongent ces idées.

- DeepCluster utilise des affectations de clustering comme pseudo-étiquettes
  pour apprendre des représentations visuelles.
- SwAV apprend des représentations en imposant une cohérence entre les
  affectations de différentes vues augmentées d'une même observation.
- Les autoencodeurs masqués apprennent à reconstruire une partie cachée des
  données, ce qui fournit une représentation utile sans étiquettes.
- scVI utilise un modèle génératif profond pour apprendre une représentation
  latente de données de transcriptomique unicellulaire.

Ces méthodes sont puissantes, mais elles déplacent une partie du problème vers
le choix de l'architecture, des augmentations, de la fonction de perte et des
paramètres d'entraînement. Dans un cours d'analyse des données, elles sont donc
à présenter comme des prolongements : elles enrichissent les outils classiques,
mais ne remplacent pas la validation, l'interprétation et le retour aux données
initiales.

#exercises[

  1. Expliquez pourquoi les k-means sont sensibles aux valeurs extrêmes.
  2. Comparez la liaison simple et la liaison complète.
  3. Que signifie une silhouette moyenne proche de zéro ?
  4. Dans un mélange gaussien, pourquoi contraindre les matrices de covariance
     peut-il améliorer la généralisation ?
  5. Pourquoi faut-il standardiser les variables avant d'utiliser une distance
     euclidienne ?
  6. Donnez un exemple où une classification hiérarchique serait plus informative
     qu'une partition directe.
  7. Pourquoi HDBSCAN peut-il être plus adapté que les k-means pour des groupes de
     forme irrégulière ?
  8. Comment peut-on utiliser un graphe de plus proches voisins pour faire du
     clustering ?
  9. Pourquoi les embeddings sont-ils utiles avant de regrouper des textes ou des
     images ?
]
