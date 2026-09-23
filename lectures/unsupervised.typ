#import "../styles/notes.typ": note, example

#show figure.caption: set align(left)

= Apprentissage non supervisé

== Introduction

En apprentissage non supervisé, aucune variable réponse n'est utilisée pour
guider l'ajustement. On cherche une organisation dans les observations, e.g des
proximités, des groupes, une hiérarchie ou des axes de variation. L'objectif
peut être de résumer les données, de décrire des profils ou de repérer des
observations atypiques. La réduction de dimension appartient à cette famille. Ce chapitre porte surtout sur le *regroupement* (_clustering_).

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

Une partition en $K$ groupes est une collection $cal(C)=(C_1, dots, C_K)$ d'ensembles d'indices non vides, disjoints deux à deux, dont la réunion est ${1, dots, n}$. Chaque observation appartient alors à un seul groupe. On note $n_g=abs(C_g)$ l'effectif du groupe $g$. Dans la suite, $K$ désigne le nombre de groupes, $g$ leur indice et $j$ celui d'une variable. Le $K$ de $k$-means compte des groupes, tandis que le $k$ des plus proches voisins comptait des voisins.

Toutes les méthodes non supervisées ne produisent pas une telle partition
stricte : une hiérarchie fournit plusieurs niveaux de regroupement, un modèle
de mélange donne des probabilités d'appartenance, et une méthode par densité
peut laisser des observations isolées hors des groupes.

=== Comparer la qualité des partitions

L'inertie totale du nuage de points $T$ est égale à l'inertie intra-groupe $W$ plus l'inertie inter-groupe $B$ :
$ T = W + B. $

*Part d'inertie inter-groupe.* Lorsque $T>0$, on définit le pseudo-$R^2$ par

$ R^2 = B/T = 1-W/T. $

Ce n'est ni une proportion d'observations correctement classées, ni une preuve de l'existence de groupes naturels. En augmentant $K$, on peut réduire l'inertie intra-groupe jusqu'à zéro en plaçant chaque observation dans son propre groupe. Utiliser seulement le pseudo-$R^2$ ne permet donc pas de choisir $K$.

*Indice de Calinski-Harabasz.* Pour $1<K<n$ et $W>0$, cet indice compare les
dispersions inter-groupe et intra-groupe en tenant compte du nombre de groupes :

$ op("CH") = B/W times (n-K)/(K-1). $

Une valeur élevée indique une forte séparation relativement à la dispersion interne. L'indice se compare entre partitions des mêmes observations dans le même espace. Sa valeur n'est pas une probabilité ni un seuil universel de qualité.

*Silhouette d'une observation.* Pour une observation $i$ dans un groupe $C_g$
comptant au moins deux points, on définit les quantités suivantes :

$ a_i = 1/(n_g-1) sum_(ell in C_g, ell != i) d(x_i,x_ell), quad "et" quad
 b_i = min_(h != g) 1/n_h sum_(ell in C_h) d(x_i,x_ell). $

La quantité $a_i$ est sa distance moyenne aux autres membres de son groupe. Pour calculer la quantité $b_i$, on mesure sa distance moyenne à chaque autre groupe et on garde la plus petite. Il ne s'agit donc ni de la distance au voisin individuel le plus proche, ni de la distance au centroïde le plus proche. La silhouette vaut

$ s_i = (b_i-a_i)/max(a_i,b_i). $

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

*Indice de Dunn.* Une définition courante utilise le rapport

$ D = (min_(g != h) min_(i in C_g, ell in C_h) d(x_i,x_ell)) /
      (max_g max_(i,ell in C_g) d(x_i,x_ell)). $

Le numérateur est la plus petite distance entre deux groupes, et le
dénominateur le plus grand diamètre d'un groupe. Pour un diamètre maximal
non nul, une grande valeur favorise des groupes séparés et compacts.
Comme il repose sur des distances extrêmes,
cet indice peut être fortement modifié par une seule observation atypique.

#example(breakable: true)[
  *Comparer trois partitions des mêmes observations.* Considérons les six valeurs suivante : $0,1,2,8,9,10$, et considérons la distance $d(x_i,x_ell)=abs(x_i-x_ell)$. Leur moyenne est $5$ et leur inertie totale, calculée sans division par $n$, vaut $ T=sum_(i=1)^6 (x_i-5)^2=100. $

  On compare les partitions suivantes, en écrivant les valeurs dans les
  groupes plutôt que les indices des observations :

  - *A* : ${0,1,2}$ et ${8,9,10}$ ;
  - *B* : ${0,1,8}$ et ${2,9,10}$ ;
  - *C* : ${0}$, ${1,2}$ et ${8,9,10}$.

  Pour *A*, les centroïdes sont $1$ et $9$. On obtient

  $ W=(1+0+1)+(1+0+1)=4, quad B=T-W=96, $
  $ R^2=1-4/100=0.96, quad op("CH")=96/4 times (6-2)/(2-1)=96. $

  Pour l'observation de valeur $2$, les distances moyennes sont
  $a_i=(2+1)/2=1.5$ et $b_i=(6+7+8)/3=7$ : sa silhouette vaut donc
  $s_i=(7-1.5)/7 approx 0.786$. La silhouette moyenne est calculée sur les
  six observations. Enfin, la plus petite distance entre les deux groupes
  est $8-2=6$ et leur diamètre maximal est $2$, d'où $D=6/2=3$.

  Les mêmes calculs pour les trois partitions donnent :

  #table(
    columns: (1fr, 0.45fr, 0.65fr, 1fr, 0.8fr, 1.3fr, 0.7fr),
    align: center, inset: 4pt, stroke: 0.4pt + luma(210),
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

Une démarche d'analyse en apprentissage non-supervisée suit ainsi plusieurs étapes :

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

#note[
  Un algorithme peut découper un nuage continu sans que des groupes nettement séparés existent dans la population. Les noms attribués aux groupes sont des descriptions à justifier. En effet, ils ne démontrent ni des catégories naturelles ni des mécanismes causaux.
]


== Les $k$-means <kmeans>

=== Principe et critère à minimiser

La méthode des *k-means*, ou *$K$-moyennes*, répartit des observations numériques
autour de $K$ centroïdes. Le nombre $K$ est fixé pour un ajustement donné.
On travaille dans l'espace choisi après les éventuelles transformations ;
les vecteurs $x_i$ ci-dessous désignent les observations dans cet espace.

Pour une partition $cal(C)$ et des centres $mu_1, dots, mu_K$, on considère

$ Q(cal(C),mu_1,dots,mu_K)
  = sum_(g=1)^K sum_(i in C_g) norm(x_i-mu_g)^2. $

On cherche à minimiser ce critère à la fois sur les affectations et sur les
centres. Si la partition est fixée, le meilleur centre du groupe $g$ est sa
moyenne $overline(x)_g$, car, pour tout vecteur $m$,

$ sum_(i in C_g) norm(x_i-m)^2
  = sum_(i in C_g) norm(x_i-overline(x)_g)^2
    + n_g norm(m-overline(x)_g)^2. $

Le second terme est positif ou nul et s'annule pour $m=overline(x)_g$.
En remplaçant chaque centre par cette moyenne, le critère devient exactement
l'inertie intra-groupe $W(cal(C))$. Le centroïde peut être un point qui
n'existe pas parmi les observations : il résume leur position moyenne.

La moyenne est donc liée au *carré de la distance euclidienne*. Remplacer la
distance par une autre dissimilarité tout en conservant la même mise à jour
des moyennes ne garantit plus la minimisation du critère correspondant.

=== L'algorithme de Lloyd

Explorer toutes les partitions possibles est trop coûteux dès que les données
deviennent nombreuses. L'algorithme de Lloyd alterne deux problèmes plus
simples, chacun résolu exactement conditionnellement à l'autre.

*Initialisation.* On choisit $K$ centres initiaux $mu_g^(0)$, par exemple parmi
des observations distinctes. Ce mode d'initialisation exige au moins $K$
profils distincts dans les données.

*Affectation.* À l'itération $t+1$, chaque observation rejoint le centre le
plus proche :

$ c_i^(t+1) = op("argmin")_(g in {1,dots,K}) norm(x_i-mu_g^(t))^2, quad
  C_g^(t+1) = {i : c_i^(t+1)=g}. $

En cas d'égalité, on applique une règle de départage fixée. Cette étape
n'augmente pas le critère, puisque les centres sont inchangés et que chaque
observation choisit sa meilleure affectation.

*Mise à jour.* Pour chaque groupe non vide, on recalcule la moyenne :

$ mu_g^(t+1) = 1/abs(C_g^(t+1)) sum_(i in C_g^(t+1)) x_i. $

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
  Reprenons $0,1,2,8,9,10$ avec $K=2$, en initialisant les centres à $0$ et $2$.
  La valeur $1$ est à égale distance des deux centres ; on l'affecte au premier
  groupe selon la règle de départage fixée.

  La première affectation donne $C_1={0,1}$ et $C_2={2,8,9,10}$. Les centres
  recalculés sont $0.5$ et $7.25$, et l'inertie intra-groupe vaut $39.25$.

  À l'affectation suivante, la valeur $2$ rejoint le premier groupe. Les
  groupes deviennent ${0,1,2}$ et ${8,9,10}$, leurs centres $1$ et $9$,
  et l'inertie vaut $4$. Les affectations suivantes restent identiques :
  l'algorithme est stabilisé.
]

=== Initialisation et solutions locales

Deux initialisations peuvent conduire à deux partitions stables différentes,
avec des valeurs de $W$ différentes. Il est donc utile de lancer plusieurs
ajustements pour le même $K$ et de conserver celui de plus faible inertie.
Le nombre d'initialisations et le nombre d'itérations par initialisation sont
deux réglages distincts : laisser plus longtemps évoluer une partition déjà
stable ne lui permet pas de quitter cette solution.

#example[
  Considérons les quatre points $(-2,-1)$, $(-2,1)$, $(2,-1)$ et $(2,1)$,
  avec $K=2$. Une séparation gauche/droite donne les centres $(-2,0)$ et
  $(2,0)$ et une inertie $W=4$. Une séparation bas/haut donne les centres
  $(0,-1)$ et $(0,1)$ et une inertie $W=16$.

  Dans les deux cas, chaque point est affecté à son centre le plus proche et
  chaque centre est la moyenne de son groupe. Les deux partitions sont donc
  stables pour Lloyd, alors que la seconde est moins bonne pour le critère.
]

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

L'initialisation *k-means++* cherche à mieux répartir les centres de départ.
Elle choisit un premier point au hasard, puis les suivants avec une probabilité
proportionnelle au carré de leur distance au centre déjà choisi le plus
proche. Les régions encore mal couvertes ont ainsi davantage de chances de
recevoir un centre. Cette initialisation améliore souvent le départ, sans
garantir que l'ajustement final atteigne l'optimum global.

Fixer une graine aléatoire permet de reproduire un calcul ; cela ne rend pas
sa partition meilleure. Pour examiner la sensibilité à l'initialisation, il
faut comparer plusieurs départs, leurs inerties et leurs affectations.

=== Géométrie des groupes et affectation d'un nouveau point

Pour des centres fixés, les observations sont réparties en régions de
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

$ hat(c)(x) = op("argmin")_(g in {1,dots,K}) norm(x-mu_g)^2. $

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

La *méthode du coude* cherche une rupture dans la courbe des inerties : après
une forte baisse, chaque groupe supplémentaire apporte une amélioration plus
modeste. Pour les six valeurs $0,1,2,8,9,10$, on passe de $W=100$ avec un groupe
à $W=4$ avec deux groupes ; un troisième groupe peut ramener $W$ à $2.5$.
Le gain principal vient ici du passage à deux groupes. Dans des données moins
nettement séparées, plusieurs coudes peuvent être plausibles, ou aucun coude
ne ressortir clairement.

On peut compléter cette lecture par la *silhouette moyenne* et l'indice de
*Calinski–Harabasz*. Ces critères comparent des compromis entre compacité et
séparation, sans nécessairement sélectionner le même $K$. La silhouette est
calculée avec une distance explicitement choisie ; dans l'exemple qui suit,
on utilise les distances euclidiennes, et non leurs carrés.

Le choix final tient aussi compte des effectifs, des profils et de la stabilité
des groupes. Une subdivision supplémentaire peut être utile pour une question
précise, même si elle ne maximise pas un indice global. Inversement, un
nouveau groupe constitué de quelques valeurs extrêmes peut traduire une
sensibilité du critère plutôt qu'un profil d'intérêt.

=== Exemple pratique : Palmer Penguins

On regroupe les manchots à partir des quatre mesures `bill_length_mm`,
`bill_depth_mm`, `flipper_length_mm` et `body_mass_g`. Les deux observations
auxquelles il manque une de ces mesures sont retirées ; les $342$ autres sont
conservées. Les données sont centrées et réduites avec les écarts-types
empiriques, de diviseur $n-1$. Il s'agit d'une exploration descriptive de
l'ensemble disponible : `species` n'intervient ni dans les distances,
ni dans les ajustements, ni dans le choix de $K$.

Le script `codes/k_means.R` compare $K=1, dots, 8$ avec $50$ initialisations
par valeur et une graine fixée à $2200$. Il utilise la fonction `kmeans` de R
avec l'algorithme de Hartigan–Wong, qui optimise le même critère d'inertie par
une procédure différente de l'alternance de Lloyd.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/stats/html/kmeans.html")[documentation
  de `stats::kmeans`], notamment les arguments `algorithm`, `nstart` et `iter.max`.
] L'inertie totale vaut ici $T=4 times (342-1)=1364$ : chacune des quatre
variables réduites a une somme de carrés égale à $341$.

#table(
  columns: (0.6fr, 1.2fr, 1.2fr, 1.3fr, 1fr), align: center,
  inset: 4pt, stroke: 0.4pt + luma(210),
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
L'indice de Calinski–Harabasz donne ici le même choix. On retient donc deux
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
  inset: 6pt, stroke: 0.4pt + luma(210),
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
  caption: [Visualisation de la partition sur un plan d'ACP. Les k-means sont
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

Le calcul des critères, les profils et ce tableau croisé se reproduisent dans
R, depuis la racine du projet :

```r
source("codes/k_means.R", encoding = "UTF-8")
```

Pour ajuster directement une partition avec la même préparation, les
opérations essentielles sont les suivantes ; le script complet réalise en
plus la comparaison de plusieurs valeurs de $K$ :

#block(breakable: true)[
```r
penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
x <- penguins[complete.cases(penguins[variables]), variables]
z <- scale(x)
set.seed(2200)
modele <- kmeans(z, centers = 2, nstart = 50, iter.max = 100,
                 algorithm = "Hartigan-Wong")
modele$size
modele$tot.withinss
mean(cluster::silhouette(modele$cluster, dist(z))[, "sil_width"])
```
]

Les nouvelles observations doivent être réduites avec les moyennes et les
écarts-types conservés dans `attr(z, "scaled:center")` et
`attr(z, "scaled:scale")`, puis comparées aux centres de `modele$centers`.
Les numéros des groupes renvoyés par le logiciel restent arbitraires.

=== Limites et variantes

*Une géométrie liée aux centres.* Les k-means fonctionnent particulièrement
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

*Des variantes qui changent le critère ou le calcul.* Les *$K$-médoïdes*
choisissent comme représentant une observation réelle de chaque groupe et
minimisent une somme de dissimilarités à ces représentants. Ils permettent
d'autres distances et sont généralement plus robustes aux valeurs extrêmes,
avec un coût de calcul souvent supérieur. Avec la distance de Manhattan,
une mise à jour par médianes coordonnée par coordonnée conduit plutôt aux
*$K$-médianes*.

Enfin, les *mini-batch k-means* mettent à jour les centres à partir de petits
lots d'observations et peuvent accélérer l'analyse de grands tableaux, au prix
d'une optimisation approchée. Pour Lloyd, le calcul direct des affectations
coûte de l'ordre de $n K p$ par itération ; multiplier les initialisations
multiplie aussi ce travail. La vitesse de calcul ne dispense pas de choisir
une représentation pertinente et de vérifier la stabilité des résultats.


== La classification hiérarchique

=== Principe

La classification hiérarchique produit une suite de partitions imbriquées. Elle
peut être représentée par un dendrogramme, c'est-à-dire un arbre qui montre dans
quel ordre les observations ou les groupes sont fusionnés.

Deux familles existent:

- les méthodes ascendantes, qui commencent avec une observation par groupe et
  fusionnent progressivement les groupes les plus proches;
- les méthodes descendantes, qui commencent avec toutes les observations dans un
  seul groupe et divisent progressivement les groupes.

Les méthodes ascendantes sont les plus utilisées en pratique.

=== Distances entre groupes

Pour fusionner des groupes, il faut définir une distance entre ensembles
d'observations.

- Plus proche voisin: distance minimale entre deux observations des groupes.
  Cette méthode accepte des formes irrégulières mais peut créer des chaînes.
- Plus distant voisin: distance maximale entre deux observations des groupes.
  Elle produit des groupes compacts mais est sensible aux valeurs extrêmes.
- Moyenne: moyenne de toutes les distances entre paires d'observations.
- Centroïde: distance entre les moyennes des groupes.
- Ward: fusion qui minimise l'augmentation d'inertie intra-groupe.

Le choix de liaison influence fortement le dendrogramme. Il doit être cohérent
avec la nature des groupes attendus et la distance entre observations.

=== Lire un dendrogramme

Un dendrogramme ne fournit pas automatiquement le nombre de groupes. On peut
choisir une coupe à partir:

- d'une connaissance métier ou d'une contrainte opérationnelle;
- d'une rupture visible dans les hauteurs de fusion;
- d'un critère d'inertie;
- d'un indice de silhouette;
- de la stabilité des groupes sous rééchantillonnage.

Une grande hauteur de fusion indique que deux groupes étaient assez éloignés
avant d'être réunis. Une coupe horizontale du dendrogramme transforme la
hiérarchie en partition.

=== Forces et limites

La classification hiérarchique est utile lorsque l'on veut comprendre plusieurs
niveaux de regroupement. Elle ne demande pas de choisir immédiatement le nombre
de groupes et produit une visualisation interprétable.

Elle devient plus coûteuse lorsque le nombre d'observations est grand. Elle est
aussi sensible au choix de distance et de liaison. Une fusion réalisée tôt ne
peut pas être corrigée plus tard dans les méthodes ascendantes classiques.

== Le mélange de gaussiennes

=== Modèle probabiliste

Les mélanges de gaussiennes proposent une approche probabiliste du regroupement.
On suppose que les données proviennent de $K$ sous-populations, chacune décrite
par une loi normale multivariée avec sa moyenne, sa covariance et son poids.

La densité du modèle peut s'écrire:

$ f(x) = sum_(k=1)^K pi_k phi_k(x) $

où $pi_k$ est le poids du groupe $k$ et $phi_k$ la densité normale multivariée de
moyenne $mu_k$ et de matrice de covariance $Sigma_k$.

Chaque observation a alors des probabilités d'appartenance aux groupes, plutôt
qu'une affectation strictement déterministe. On parle de classification souple.

=== Algorithme EM

Les étiquettes de groupe étant inconnues, on maximise la vraisemblance marginale
à l'aide de l'algorithme EM.

- Étape E: estimer les probabilités d'appartenance de chaque observation à
  chaque groupe.
- Étape M: mettre à jour les poids, les moyennes et les matrices de covariance.

Ces deux étapes sont répétées jusqu'à stabilisation de la vraisemblance. Comme
pour les k-means, l'algorithme peut converger vers une solution locale; plusieurs
initialisations sont donc utiles.

=== Géométrie des groupes

La forme des matrices de covariance détermine la géométrie des groupes:
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
gaussien: les groupes sont associés à des centres et la frontière dépend de la
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

#note[
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

Les méthodes modernes séparent souvent deux problèmes: apprendre une bonne
représentation des observations, puis regrouper les observations dans cet espace.
Cette stratégie est particulièrement utile pour les images, les textes, les sons
ou les données très hautement dimensionnelles.

Un autoencodeur peut apprendre une représentation latente en reconstruisant ses
entrées. Deep Embedded Clustering, ou DEC, combine cette idée avec un objectif de
clustering: le réseau apprend simultanément un espace latent et des affectations
de groupes.

Pour des données textuelles, on peut produire des embeddings avec un modèle de
langage, réduire la dimension si nécessaire, puis appliquer HDBSCAN ou k-means.
BERTopic suit cette logique: il regroupe des documents représentés par des
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
à présenter comme des prolongements: elles enrichissent les outils classiques,
mais ne remplacent pas la validation, l'interprétation et le retour aux données
initiales.

#heading(level: 2, outlined: false)[Exercices]

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
