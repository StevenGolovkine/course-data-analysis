#import "../styles/notes.typ": note, example

#show figure.caption: set align(left)

= Réduction de dimension

== Introduction

Un grand nombre de variables complique la visualisation, augmente le coût de calcul, favorise les corrélations redondantes et peut rendre les modèles instables. La réduction de dimension cherche à remplacer les variables initiales par un plus petit nombre de variables synthétiques qui conservent l'information utile.

Réduire la dimension ne signifie pas seulement supprimer des variables. Une méthode peut-étre plus intéressante consiste à construire de nouveaux axes de représentation, souvent comme des combinaisons des variables initiales, puis à travailler dans cet espace réduit. On passe alors d'une représentation où chaque variable a son propre axe, et donc son propre rôle, à une représentation où quelques dimensions (axes) résument les principales structures du jeu de données.

#note[
  La réduction de dimension est une étape exploratoire. Elle aide à voir une
  structure, à compresser l'information ou à préparer une méthode prédictive,
  mais elle ne remplace pas l'interprétation statistique.
]

=== Deux idées différentes

Il faut distinguer deux familles d'approches. Toutes deux permettent de décrire
les observations avec moins de variables, mais elles ne produisent pas le même
type de représentation.

- La *sélection de variables* garde certaines variables originales et en élimine
  d'autres, par exemple parce qu'elles sont redondantes ou peu utiles pour
  l'objectif de l'analyse. Les variables retenues conservent leur sens et leurs
  unités, ce qui facilite l'interprétation. En revanche, l'information propre aux
  variables supprimées n'est plus directement disponible.
- La *réduction de dimension*, au sens de construction de nouvelles variables,
  résume plusieurs variables originales par des variables synthétiques, appelées
  axes, composantes, facteurs ou dimensions. Une même dimension peut combiner
  l'information de plusieurs variables. On conserve ainsi certaines structures
  communes, mais les nouvelles dimensions sont parfois plus difficiles à
  interpréter que les mesures initiales.

#example[
  Supposons que trois évaluations d'un même cours donnent des notes fortement
  corrélées. Une sélection pourrait ne garder que la note de l'examen final :
  chaque étudiant serait alors décrit par une mesure déjà présente dans les
  données. Une réduction de dimension pourrait plutôt construire un score
  synthétique combinant les trois notes, par exemple une moyenne pondérée.
  Ce score résumerait leur tendance commune, mais masquerait certaines
  différences entre les profils : deux étudiants peuvent obtenir le même score
  avec des notes différentes aux trois évaluations.
]

Au sens large, la sélection de variables est donc aussi une façon de réduire la
dimension. La distinction porte ici sur le choix entre conserver des variables
existantes et construire de nouvelles coordonnées.

Les méthodes étudiées dans ce chapitre appartiennent surtout à la
seconde famille. Elles ne disent pas seulement quelles variables sont utiles :
elles proposent une nouvelle géométrie des données. Chaque observation y est
décrite par ses coordonnées sur quelques dimensions, et la méthode choisie
détermine quelles caractéristiques des données sont préservées au mieux, comme
la variance ou les relations de voisinage.

=== Choisir une méthode

Le choix de la méthode de réduction de dimension dépend d'abord du type de variables.

- L'analyse en composantes principales (ACP) s'applique à un tableau de variables numériques et quantitatives.
- L'analyse factorielle des correspondances (AFC) s'applique à un tableau de contingence croisant deux variables qualitatives.
- L'analyse des correspondances multiples (ACM) s'applique à plusieurs variables qualitatives, souvent issues d'un questionnaire.
- Les méthodes $t$-SNE et UMAP s'utilisent surtout pour visualiser des voisinages dans des données complexes, comme des images ou du texte.
- Les autoencodeurs apprennent une représentation latente par un modèle prédictif, souvent non linéaire.

Dans tous les cas, l'objectif est de construire un espace de faible dimension.
Cette espace doit être interprété avec prudence: une projection simplifie les données, donc elle conserve certaines structures et en efface d'autres.

== L'analyse en composantes principales

=== Principe

L'analyse en composantes principales (ACP) s'applique à un tableau de $n$
observations décrites par $p$ variables quantitatives. Chaque observation est
un point dans un espace à $p$ dimensions. L'ACP cherche de nouveaux axes pour
résumer ce nuage de points avec moins de dimensions, tout en conservant le plus
possible de sa dispersion. Ces axes sont appelés *composantes principales*, *facteurs* ou *axes factoriels*.

Lorsque deux variables sont fortement corrélées, leur nuage de points est
allongé dans une direction. On peut alors résumer une grande partie de leur
variation par la position des observations le long de cette direction. L'ACP
généralise cette idée à un nombre quelconque de variables.

#figure(
  image("../figures/acp_principe.svg", width: 100%,
    alt: "Nuage de points allongé selon une diagonale. Le premier axe principal,"
      + " CP1, suit cette direction et conserve 90 pour cent de la variance. "
      + "CP2 lui est perpendiculaire. Les pointillés relient les observations "
      + "à leurs projections orthogonales sur CP1."),
  caption: [Exemple d'une ACP sur des données centrées simulées en deux dimensions. Les axes CP1 et CP2 sont perpendiculaires. CP1 conserve $90%$ de la variance. Ne garder que cet axe revient à projeter les observations sur la droite verte; les pointillés montrent les écarts perdus.],
) <fig-acp-principe>


La première composante correspond à la direction sur laquelle les projections des observations ont la plus grande variance. La deuxième maximise cette variance parmi les directions perpendiculaires à la première, et ainsi de suite. Les axes sont donc orthogonaux, et les composantes obtenues sont non corrélées entre elles. Cela ne signifie cependant pas qu'elles sont indépendantes.

Si l'on conserve tous les axes, on effectue seulement un changement de coordonnées. La réduction de dimension intervient lorsqu'on ne garde que les $q$ premières composantes. Avec $q < p$, on abandonne alors les directions associées aux plus faibles variances.

=== Préparer les données : centrer et réduire

Le choix de l'échelle des variables détermine le nuage de points analysé. On commence par centrer chaque variable, i.e. soustraire sa moyenne. Le centre du nuage devient ainsi l'origine du repère. Si $x_(i j)$ est la valeur de la variable $j$ pour l'observation $i$, la valeur centrée est :

$ z_(i j) = x_(i j) - overline(x)_j quad "où" quad overline(x)_j = frac(1, n) sum_(i=1)^n x_(i j). $

Une *ACP centrée* travaille sur les valeurs centrées $z_(i j)$ et analyse la matrice de covariance des variables originales. Elle donne davantage de poids aux variables dont la variance est élevée. Ce choix est pertinent lorsque les échelles sont comparables et que les différences de dispersion ont un sens pour l'analyse.

Une *ACP centrée réduite*, aussi appelée ACP normée, divise également chaque variable par son écart-type empirique $s_j$ :

$ z_(i j) = (x_(i j) - overline(x)_j) / s_j quad "où" quad overline(x)_j = frac(1, n) sum_(i=1)^n x_(i j) quad "et" quad s_j = sqrt(frac(1, n - 1) sum_(i=1)^n (x_(i j) - overline(x)_j)^2). $

Les variables transformées ont alors une moyenne nulle et une variance égale à 1. Leur matrice de covariance est la matrice de corrélation des variables originales. Cette approche est généralement adaptée lorsque les unités ou les ordres de grandeur diffèrent.

#example[
  Pour décrire des logements par leur superficie et leur prix, une ACP centrée peut être dominée par le prix, dont les valeurs sont plus dispersées. De plus, exprimer le prix en dollars plutôt qu'en euros ou exprimer la superficie en pieds carrés plutôt qu'en mètres carrés modifie le résultat. La standardisation supprime cet effet d'unité et donne à chaque variable la même variance initiale.
]

La standardisation reste un *choix* d'analyse : elle peut aussi donner beaucoup
de poids à une variable peu informative. Avant le calcul, il faut examiner les
valeurs extrêmes et traiter les données manquantes.

#note[
  Les variables constantes n'apportent aucune dispersion et doivent être retirées avant une division par leur écart-type, qui est nul.
]

=== Construction des composantes

Notons $Z = (z_(i j)) in RR^(n times p)$ la matrice des données, avec $n >= 2$ observations en lignes et $p$ variables en colonnes. On suppose que chaque colonne est centrée, donc 
$ sum_(i=1)^n z_(i j) = 0 quad "pour tout" quad j. $
Les observations ont le même poids et l'on suppose qu'au moins une variable a une variance non nulle. La matrice de covariance empirique est donnée par 

$ hat(Sigma) = 1 / (n - 1) Z^top Z in RR^(p times p). $

#note[
  Si les colonnes de $Z$ ont été réduites, $hat(Sigma)$ est la matrice de corrélation empirique des variables originales.
]

Ainsi, la matrice $hat(Sigma)$ est symétrique et semi-définie positive, car pour tout $alpha in RR^p, alpha != 0$, en utilisant la norme euclidienne, on trouve que 

$ alpha^top hat(Sigma) alpha = 1 / (n - 1) norm(Z alpha)^2 >= 0. $

*Variance d'une projection.* Une direction (axe) est représentée par un vecteur unitaire $alpha in RR^p$, c'est-à-dire $norm(alpha)^2 = alpha^top alpha = 1$. Si $z_i$ désigne le vecteur colonne correspondant à la ligne $i$ de $Z$, la coordonnée de cette observation sur la direction $alpha$ est donnée par $y_i = alpha^top z_i = chevron.l alpha, z_i chevron.r$. Le vecteur des coordonnées des $n$ observations dans la direction donnée par $alpha$ est donc $y = Z alpha in RR^n$. Il est centré car les colonnes de $Z$ le sont. Sa variance empirique vaut

$ s^2(y) = 1 / (n - 1) sum_(i=1)^n y_i^2
  = 1 / (n - 1) y^top y = alpha^top hat(Sigma) alpha $

L'ACP cherche ainsi des directions unitaires qui maximisent cette forme quadratique. 

#note[
  La contrainte de norme fixe l'échelle des coefficients. En effet, multiplier $alpha$ par $c != 0$ multiplierait la variance par $c^2$, sans changer la direction géométrique.
]

*Première composante.* Le premier axe résout le problème :

$ alpha_1 = op("arg max", limits: #true)_(alpha^top alpha = 1)
  alpha^top hat(Sigma) alpha. $

Pour obtenir les directions candidates, on introduit le lagrangien :

$ cal(L)(alpha, lambda) = alpha^top hat(Sigma) alpha - lambda (alpha^top alpha - 1). $

Comme $hat(Sigma)$ est symétrique, la condition de stationnarité par rapport à $alpha$
donne :

$ nabla_alpha cal(L) = 2 hat(Sigma) alpha - 2 lambda alpha = 0
  quad arrow.r.double quad hat(Sigma) alpha = lambda alpha. $

Une direction candidate est donc un vecteur propre unitaire de $hat(Sigma)$. En multipliant cette égalité à gauche par $alpha^top$, on obtient $alpha^top hat(Sigma) alpha = lambda$. La variance sur cette direction est la valeur propre associée au vecteur propre $alpha$. Cette condition ne suffit cependant pas à identifier le maximum, puisqu'elle est vérifiée par tous les vecteurs propres unitaires.

Le théorème spectral permet de conclure. Il existe une base orthonormée $(u_1, dots, u_p)$ de vecteurs propres de $hat(Sigma)$, avec les valeurs propres ordonnées $lambda_1 >= lambda_2 >= dots >= lambda_p >= 0$. Tout vecteur unitaire $alpha$ s'écrit comme combinaison linéaire des vecteurs propres :

$ alpha = sum_(j=1)^p c_j u_j, quad "où" quad sum_(j=1)^p c_j^2 = 1. $

Par conséquent,

$ alpha^top hat(Sigma) alpha = sum_(j=1)^p lambda_j c_j^2
  <= lambda_1 sum_(j=1)^p c_j^2 = lambda_1. $

La borne est atteinte pour $alpha_1 = u_1$. La première composante principale est donc $Y_1 = Z alpha_1$ et sa variance est $s^2(Y_1) = lambda_1$.

*Composantes suivantes.* Pour $2 <= k <= p$, on maximise la même variance en imposant en plus l'orthogonalité aux directions déjà retenues. Si $cal(A)_k$ est l'ensemble des vecteurs $alpha$ tels que $alpha^top alpha = 1$ et $alpha^top alpha_j = 0$ pour tout $j < k$, alors :

$ alpha_k = op("arg max", limits: #true)_(alpha in cal(A)_k)
  alpha^top hat(Sigma) alpha. $

En choisissant successivement $alpha_j = u_j$, ces contraintes imposent $c_1 = dots = c_(k-1) = 0$ dans la décomposition précédente. La variance ne peut donc pas dépasser $lambda_k$, et cette borne est atteinte pour $alpha_k = u_k$. On obtient ainsi des directions orthonormées vérifiant :

$ hat(Sigma) alpha_k = lambda_k alpha_k, quad "et" quad Y_k = Z alpha_k. $

Le coefficient $alpha_(j k)$ est le poids de la variable $j$ dans la composante $k$. Il est commun à toutes les observations. Le *score* de l'observation $i$ sur cette composante, i.e. la coordonnée de l'observation $i$ sur la direction $k$, est donnée par

$ y_(i k) = alpha_k^top z_i = sum_(j=1)^p alpha_(j k) z_(i j). $

*Variance et covariance des composantes.* Les vecteurs de scores étant centrés,
leur covariance empirique s'écrit :

$ s(Y_k, Y_l) = 1 / (n - 1) Y_k^top Y_l
  = alpha_k^top hat(Sigma) alpha_l = lambda_l alpha_k^top alpha_l. $

Pour $k = l$, on retrouve $s^2(Y_k) = lambda_k$. Pour $k != l$, l'orthogonalité
des directions donne $s(Y_k, Y_l) = 0$. Les composantes de variance non nulle
ont donc une corrélation empirique nulle deux à deux. Cette propriété ne
démontre toujours pas une indépendance probabiliste.

*Représentation réduite.* Pour conserver $q$ composantes, avec $1 <= q <= p$, on rassemble les composantes principales dans une matrice $A_q = (alpha_1, dots, alpha_q) in RR^(p times q)$. La matrice des données réduites $T_q = (Y_1, dots, Y_q)$ est donnée par

$ T_q = Z A_q in RR^(n times q), quad "avec" quad A_q^top A_q = I_q. $

La matrice de covariance de $T_q$ est donc
$ 1 / (n - 1) T_q^top T_q = A_q^top hat(Sigma) A_q
  = op("diag")(lambda_1, dots, lambda_q). $

Ici, $I_q$ est la matrice identité de taille $q$ et $op("diag")$ désigne une
matrice diagonale. Chaque ligne de $T_q$ contient les $q$ scores d'une observation.
Le rang $r = op("rang")(Z)$ est au plus $min(n - 1, p)$, à cause du centrage.
Il y a donc exactement $r$ composantes de variance strictement positive; les
autres ont des scores tous nuls.

#note[
  Pour une valeur propre simple, le vecteur propre unitaire est défini au signe
  près. Si une valeur propre est multiple, toute base orthonormée de son
  sous-espace propre convient :
  les axes individuels ne sont alors pas uniques. Pour $q < p$, une séparation
  stricte $lambda_q > lambda_(q+1)$ garantit l'unicité du sous-espace engendré
  par les $q$ premières directions, même si l'orientation de certains axes
  dans ce sous-espace peut varier.
]

En pratique, on peut calculer les composantes avec une décomposition en valeurs singulières $Z = U D V^top$, où $U in RR^(n times q)$ et $V in RR^(p times q)$ sont des matrices dont les colonnes sont orthonormées, et $D = op("diag")(d_1, dots, d_q)$ avec $d_1 >= dots >= d_q > 0$. En notant $U_k$ et $V_k$ leurs $k$-ièmes colonnes, on obtient, pour $1 <= k <= q$ :

$ alpha_k = V_k, quad lambda_k = d_k^2 / (n - 1), quad "et" quad Y_k = d_k U_k. $

Cette formulation réalise la même ACP sans former explicitement $Z^top Z$,
avec les mêmes possibilités de choix du signe et des bases des sous-espaces
propres.

=== Inertie et variance expliquée

L'*inertie* mesure la dispersion globale d'un nuage de points autour de son centre de gravité, i.e. du point moyen. L'idée est de mesurer la distance de chaque observation à ce centre, de prendre son carré, puis d'additionner ces quantités. Un nuage compact a une faible inertie, à l'inverse un nuage très dispersé a une inertie élevée, à échelle et nombre d'observations comparables. Le carré des distances donne davantage de poids aux points éloignés. En effet, une distance au centre deux fois plus grande apporte une contribution quatre fois plus élevée à la somme.

#figure(
  image("../figures/acp_inertie.svg", width: 75%,
    alt: "Nuage de points dont chaque observation est reliée au centre g. "
      + "Un segment mis en évidence représente la distance d_i entre "
      + "l'observation z_i et ce centre."),
  caption: [Chaque observation est reliée au centre $g$ du nuage simulé.
    La longueur $d_i$ mesure la distance de $z_i$ au centre. L'inertie cumule
    les carrés de ces distances, avec la normalisation retenue.],
) <fig-acp-inertie>

Pour les observations $z_1, dots, z_n in RR^p$, le centre de gravité est $g = 1 / n sum_(i=1)^n z_i$. Dans le cadre de l'ACP, $g = 0$, puisque les variables ont été centrées. En utilisant la normalisation par $n - 1$ de la variance empirique, on définit l'inertie totale par

$ I_("total") = 1 / (n - 1) sum_(i=1)^n norm(z_i - g)^2
  = 1 / (n - 1) sum_(i=1)^n norm(z_i)^2. $

Le centrage ne change pas les distances au centre : il déplace simplement le centre de gravité à l'origine de l'espace. En revanche, réduire les variables change les distances et donc l'inertie analysée.

#note[
  L'inertie géométrique est souvent définie comme la moyenne des distances au
  carré, avec le diviseur $n$. Elle vaut alors $(n - 1) / n I$. Le choix entre
  ces deux normalisations ne change ni les axes de l'ACP ni les proportions
  d'inertie expliquée, à condition de l'appliquer de manière cohérente.
]

*Lien avec la variance.* Le carré de la distance à l'origine est la somme des
carrés des coordonnées. En échangeant les deux sommes, on obtient :

$ I = sum_(j=1)^p (1 / (n - 1) sum_(i=1)^n z_(i j)^2)
  = sum_(j=1)^p s^2(Z_j) = op("tr")(hat(Sigma)). $

Ici, $Z_j$ est la $j$-ième colonne de $Z$ et la trace $op("tr")$ d'une matrice
est la somme de ses éléments diagonaux. L'inertie totale est donc la somme des
variances des variables préparées. Dans une ACP centrée réduite, elle vaut $p$,
puisque chacune des $p$ variables a une variance égale à 1.

*Répartition entre les axes.* Les axes de l'ACP forment un repère orthonormé. Le théorème de Pythagore donne, pour chaque observation :

$ norm(z_i)^2 = sum_(k=1)^p y_(i k)^2. $

Un changement de repère orthonormé conserve ainsi les distances au centre, et donc l'inertie totale. En sommant sur les observations et en utilisant $s^2(Y_k) = lambda_k$, on trouve 

$ I = sum_(k=1)^p (1 / (n - 1) sum_(i=1)^n y_(i k)^2)
  = sum_(k=1)^p lambda_k. $

Chaque valeur propre $lambda_k$ mesure donc l'inertie portée par l'axe $k$. L'ACP répartit la dispersion du nuage entre des directions orthogonales, ordonnées de la plus dispersée à la moins dispersée.

*Variance expliquée.* La proportion de variance expliquée par la composante $k$ et la proportion de variance expliquée cumulée sur les $q$ premières composantes sont respectivement :

$ r_k = lambda_k / (sum_(j=1)^p lambda_j)
  quad "et" quad R_q = (sum_(k=1)^q lambda_k) / (sum_(j=1)^p lambda_j). $

La quantité $1 - R_q$ mesure donc la part de variance perdue dans la représentation réduite. Dans ce cas, « expliquée » signifie « conservée par la projection ». Il ne s'agit pas d'une explication causale des données.

#example[
  Si les deux premières composantes expliquent respectivement $60%$ et $22%$ de la variance, le premier plan factoriel en conserve $82%$. Les $18%$ restants correspondent à des différences entre observations qui ne sont pas visibles dans ce plan facotriel. Ce bon résumé global ne garantit pas que chaque observation ou chaque variable y soit bien représentée.
]

L'ACP peut aussi être comprise comme une méthode de reconstruction. En effet, on peut approcher $z_i$ par

$ hat(z)_i = sum_(k=1)^q y_(i k) alpha_k. $

L'inertie perdue correspond exactement à l'erreur de reconstruction, avec la
même normalisation :

$ 1 / (n - 1) sum_(i=1)^n norm(z_i - hat(z)_i)^2
  = sum_(k=q+1)^p lambda_k = I (1 - R_q). $

Parmi les projections orthogonales sur des sous-espaces de dimension $q$,
l'ACP minimise la somme des carrés des erreurs de reconstruction. Conserver
le plus de variance et perdre le moins d'information au sens de cette erreur
quadratique sont donc deux formulations du même problème. Pour retrouver les
unités originales, on multiplie chaque valeur reconstruite par l'écart-type
correspondant si les variables ont été réduites, puis on ajoute leur moyenne.

=== Exemple à deux variables

Imaginons une classe dans laquelle chaque étudiant a passé deux évaluations : un examen intermédiaire et un examen final, tous deux notés sur 20. Chaque étudiant est une observation, et les deux variables initiales sont ses notes aux deux examens. Pour comparer sa position dans la classe d'un examen à l'autre, on centre et réduit séparément chaque série de notes. On appelle $Z_1$ et $Z_2$ les deux variables ainsi obtenues.

#example[
  Supposons qu'à l'examen intermédiaire, la moyenne de la classe soit de 12 sur
  20 et l'écart-type de 2 points. Un étudiant ayant obtenu 14 sur 20 a une note
  standardisée de $(14 - 12) / 2 = 1$. Il dépasse la moyenne de 2 points, soit
  exactement un écart-type. Une note de 10 sur 20 donne $(10 - 12) / 2 = -1$,
  et une note de 12 sur 20 donne $0$. Pour l'examen final, on effectue le même
  calcul avec la moyenne et l'écart-type propres à cet examen.
]

Une valeur standardisée indique donc un écart à la moyenne exprimé en unités
d'écart-type. Un étudiant peut avoir la même valeur standardisée aux deux
examens même si ses notes sur 20 diffèrent. On suppose ici que la corrélation
empirique entre $Z_1$ et $Z_2$ est $0.8$ : les étudiants ayant une note élevée
au premier examen tendent aussi à avoir une note élevée au second. Comme les
deux variables standardisées ont chacune une variance égale à 1, leur matrice
de corrélation est

$ hat(Sigma) = mat(1, 0.8; 0.8, 1). $

*Calcul des axes.* Les valeurs propres sont les solutions de :

$ det(hat(Sigma) - lambda I_2) = (1 - lambda)^2 - 0.8^2 = 0. $

On obtient $lambda_1 = 1.8$ et $lambda_2 = 0.2$. Des vecteurs propres unitaires (de norme 1) associés sont :

$ alpha_1 = 1 / sqrt(2) (1, 1)^top, quad
  alpha_2 = 1 / sqrt(2) (1, -1)^top. $

Les composantes principales sont donc :

$ Y_1 = (Z_1 + Z_2) / sqrt(2), quad
  Y_2 = (Z_1 - Z_2) / sqrt(2). $

Le premier axe suit la diagonale $z_1 = z_2$ : il représente le niveau commun
aux deux notes. Le second suit la diagonale $z_1 = -z_2$ : il représente leur
contraste. Avec le signe choisi, un score $y_2 > 0$ signifie que la première
note standardisée est plus élevée que la seconde. Les deux axes sont
perpendiculaires.

*Passage au repère principal.* Les graphiques suivants utilisent les mêmes
45 observations simulées, dont les variances empiriques valent exactement 1
et la corrélation $0.8$. Les trois profils A, B et C mis en évidence font partie
de ce nuage. Dans le nouveau repère, le nuage est allongé horizontalement,
car la dispersion est plus forte sur $Y_1$ que sur $Y_2$. Les deux composantes
étant conservées, ce changement de coordonnées ne perd aucune information.

#figure(
  image("../figures/acp_exemple_reperes.svg", width: 100%,
    alt: "Deux graphiques des mêmes observations. À gauche, les deux notes "
      + "standardisées ont une corrélation de 0,8; CP1 suit la diagonale "
      + "croissante et CP2 la diagonale décroissante. À droite, les scores "
      + "principaux forment un nuage surtout dispersé horizontalement. "
      + "Les profils A, B et C sont repérés dans les deux graphiques."),
  caption: [À gauche, le nuage dans le repère des notes standardisées et les
    directions principales. À droite, les mêmes observations dans le repère
    $(Y_1, Y_2)$. Les unités et les échelles sont identiques : le changement de
    repère conserve les distances entre les points.],
) <fig-acp-exemple-reperes>

*Variance conservée.* On peut vérifier directement les variances des deux
composantes à partir de celles des notes et de leur covariance :

$ s^2(Y_1) = 1 / 2 (1 + 1 + 2 times 0.8) = 1.8, $
$ s^2(Y_2) = 1 / 2 (1 + 1 - 2 times 0.8) = 0.2. $

Leur covariance est nulle, car $s(Y_1, Y_2) = (s^2(Z_1) - s^2(Z_2)) / 2 = 0$. L'inertie totale vaut $1.8 + 0.2 = 2$, comme la somme des variances des deux notes centrées réduites. La première composante en conserve $1.8 / 2 = 90%$, et la seconde $0.2 / 2 = 10%$.

*Lecture de trois profils.* Le calcul des scores donne :

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  align: center,
  inset: 6pt,
  stroke: 0.4pt + luma(210),
  table.header([*Profil*], [$z_1$], [$z_2$], [$y_1$], [$y_2$]),
  [A], [$1$], [$1$], [$sqrt(2)$], [$0$],
  [B], [$1$], [$-1$], [$0$], [$sqrt(2)$],
  [C], [$0$], [$0$], [$0$], [$0$],
)

Le profil A est au-dessus de la moyenne dans les deux évaluations : sa première
composante est positive et son contraste est nul. Le profil B combine une note
au-dessus de la moyenne et une note au-dessous : son niveau commun est nul,
mais son contraste est élevé. Le profil C est à la moyenne dans les deux
évaluations. B et C ont donc le même score sur $Y_1$, malgré des notes différentes.

*Réduction à une seule composante.* Ne garder que $Y_1$ revient à projeter
chaque observation sur la première direction. Dans les coordonnées des notes
standardisées, la reconstruction est :

$ hat(z)_i = y_(i 1) alpha_1
  = ((z_(i 1) + z_(i 2)) / 2, (z_(i 1) + z_(i 2)) / 2)^top. $

Les deux notes reconstruites sont ainsi égales à leur moyenne. Le profil A
est reconstruit exactement, car il se trouve déjà sur la diagonale. Le profil B
est reconstruit par $(0, 0)$ et devient confondu avec C : l'écart entre ses deux
notes a disparu.

#figure(
  image("../figures/acp_exemple_projection.svg", width: 55%,
    alt: "Projection du nuage sur la diagonale de la première composante. "
      + "Les pointillés relient chaque observation à sa reconstruction. "
      + "A reste à la position 1,1, tandis que B, initialement en 1,-1, "
      + "est projeté au centre, où se trouve déjà C."),
  caption: [Réduction à CP1 dans le repère des notes standardisées. Les cercles
    vides sont les reconstructions et les pointillés représentent les écarts
    perdus. Le segment orange souligne la projection de B sur C. A et C
    sont déjà sur l'axe et restent à leur place.],
) <fig-acp-exemple-projection>

Pour chaque observation, le carré de l'erreur de reconstruction est :

$ norm(z_i - hat(z)_i)^2 = y_(i 2)^2
  = (z_(i 1) - z_(i 2))^2 / 2. $

Cette erreur vaut $0$ pour A et C, mais $2$ pour B. Sur l'ensemble du nuage, la somme des erreurs au carré divisée par $n - 1$ vaut $lambda_2 = 0.2$, soit $10%$ de l'inertie totale. Conserver $90%$ de la variance donne donc un bon résumé global, sans garantir que chaque profil soit bien représenté. Ici, la composante de faible variance porte précisément la différence entre B et C.

=== Choisir le nombre de composantes

Choisir le nombre $q$ de composantes revient à chercher un compromis entre
la simplicité de la représentation et la quantité d'information conservée.
Ajouter un axe ne diminue jamais la variance expliquée sur les données qui ont
servi à calculer l'ACP, mais cet axe peut apporter peu à l'interprétation ou à
une tâche prédictive. Il n'existe donc pas de nombre de composantes qui
convienne à tous les objectifs.

Ici, $k$ désigne le rang d'une composante, $lambda_k$ sa valeur propre et $q$ désigne le nombre de composantes retenues. On conserve les composantes de rang $k = 1, dots, q$. La dernière composante retenue a donc le rang $k = q$. Enfin, $R_q$ désigne la variance expliquée cumulée par ces $q$ premières composantes.

Il faut aussi distinguer le nombre de composantes retenues pour l'analyse du nombre d'axes affichés sur un graphique. On peut retenir quatre composantes et les examiner à l'aide de plusieurs plans factoriels à deux dimensions.

*Variance expliquée cumulée.* On fixe un seuil $tau$, par exemple $0.80$,
$0.90$ ou $0.95$, puis on retient le plus petit entier $q$ tel que $R_q >= tau$.

Le choix du seuil exprime la perte de variance que l'on accepte : retenir
au moins $90%$ de la variance revient à en perdre au plus $10%$. Ce seuil
ne garantit cependant pas la qualité de représentation de chaque observation
ou de chaque variable.

Considérons une ACP centrée réduite portant sur six variables dont les valeurs
propres sont présentées dans le @table-acp-variance-cumulee. Leur somme est bien
égale à $6$, qui correspond à l'inertie totale des variables standardisées. Dans
la dernière colonne, on pose $q = k$ : ainsi, pour la ligne de rang $k = 3$,
le cumul des trois premières composantes vaut $R_3$.

#figure(
  table(
    columns: (1fr, 1fr, 1.5fr, 1.5fr),
    align: center,
    inset: 6pt,
    stroke: 0.4pt + luma(210),
    table.header([*Rang* $k$], [$lambda_k$], [*Variance expliquée*], [*Cumul* $R_q$ ($q = k$)]),
    [1], [$3.0$], [$50%$], [$50%$],
    [2], [$1.5$], [$25%$], [$75%$],
    [3], [$0.9$], [$15%$], [$90%$],
    [4], [$0.3$], [$5%$], [$95%$],
    [5], [$0.2$], [$3.3%$], [$98.3%$],
    [6], [$0.1$], [$1.7%$], [$100%$],
  )
) <table-acp-variance-cumulee>

Avec $q = 2$, on conserve $R_2 = 75%$ de la variance, cela ne suffit pas pour atteindre un seuil de $80%$. On choisit $q = 3$ pour atteindre $80%$ ou $90%$, et $q = 4$ pour atteindre $95%$. Le choix du seuil change donc directement la dimension retenue. Un plan factoriel limité aux deux premiers axes reste possible, mais elle masque notamment les $15%$ portés par le troisième axe.

*Graphique des valeurs propres et règle du coude.* L'éboulis représente les
valeurs propres $lambda_k$ en fonction du rang $k$ de la composante. On cherche
une rupture de pente : avant le coude, les axes apportent une part importante
de la variance; après, les gains deviennent plus faibles. Cette lecture sert
à repérer un compromis, sans imposer au préalable un pourcentage.

Dans l'exemple, la courbe s'aplatit à partir de la quatrième valeur propre,
$lambda_4 = 0.3$ : les suivantes, $0.2$ et $0.1$, ne diminuent plus que de
$0.1$ à chaque étape. On situe donc ici le coude au rang $k = 4$ et l'on
retient $q = 4$ composantes, qui conservent $95%$ de la variance. La position du
coude reste toutefois une appréciation visuelle; plusieurs ruptures peuvent
être plausibles.

#example[
  Supposons au contraire que six variables standardisées soient non corrélées,
  avec six valeurs propres toutes égales à $1$. L'éboulis est horizontal : il
  n'existe pas de coude ni de direction de variance privilégiée. Deux axes
  ne conservent que $2 / 6$, soit environ $33.3%$ de la variance. Il en faut
  cinq pour dépasser $80%$, et les six pour atteindre $90%$. Une forte réduction
  de dimension résumerait donc mal la dispersion de ces données.
]

*Règles de Kaiser et de Jolliffe.* Dans une ACP centrée réduite, la valeur propre
moyenne vaut $1$, puisque la somme des $p$ valeurs propres vaut $p$. La règle
de Kaiser conserve celles qui sont strictement supérieures à $1$ : chaque axe
retenu porte alors plus de variance qu'une variable standardisée prise seule.
La règle de Jolliffe abaisse ce seuil à $0.7$ et retient donc davantage d'axes,
ou le même nombre.

Dans notre exemple à six variables, Kaiser conserve les composantes de rangs
$k = 1$ et $k = 2$ ($3.0$ et $1.5$) : le choix est donc $q = 2$, avec
$R_2 = 75%$. Jolliffe conserve les trois premiers rangs ($3.0$, $1.5$ et $0.9$) :
le choix est $q = 3$, avec $R_3 = 90%$. Ces règles peuvent donc conduire à des
choix différents. Leurs seuils sont des repères heuristiques : ils ne
s'appliquent pas tels quels à une ACP sur des variables non réduites, dont
les variances dépendent des unités de mesure. Dans le cas de six valeurs
propres égales à $1$, la règle stricte de Kaiser ne retient même aucun axe,
ce qui illustre la nécessité de l'interpréter plutôt que de l'appliquer seule.

#figure(
  image("../figures/acp_nombre_composantes.svg", width: 100%,
    alt: "À gauche, décroissance des six valeurs propres : 3, 1,5, 0,9, 0,3, "
      + "0,2 et 0,1. Les seuils de Kaiser et Jolliffe conduisent respectivement "
      + "à deux et trois composantes. Le coude est repéré au rang quatre, "
      + "ce qui conduit à retenir quatre composantes. À droite, la variance cumulée atteint 90 pour cent "
      + "à trois composantes et 95 pour cent à quatre composantes. Les seuils "
      + "de 80 et 90 pour cent retiennent donc trois composantes, celui de "
      + "95 pour cent en retient quatre."),
  caption: [À gauche, $lambda_k$ est tracée en fonction du rang $k$; le repère
    vertical en $k = q$ marque la dernière composante retenue. À droite,
    $R_q$ est tracée en fonction du nombre $q$ de composantes, et l'on choisit
    le plus petit $q$ qui atteint le seuil. Les lignes horizontales indiquent
    les seuils. Le coude illustratif au rang $k = 4$ conduit ici au choix
    $q = 4$; sa position reste une appréciation visuelle.],
) <fig-acp-nombre-composantes>

*Interprétabilité et objectif de l'analyse.* Une composante de faible variance
peut représenter une opposition intéressante. Dans l'exemple des deux examens,
le premier axe conserve $90%$ de la variance, mais le second distingue les
étudiants ayant des résultats contrastés entre les deux évaluations. Si cette
différence est au centre de la question étudiée, il est utile de conserver
les deux composantes.

Pour une utilisation prédictive, on compare plusieurs valeurs de $q$ par
validation croisée de l'ensemble du modèle. Le critère devient alors la qualité
des prédictions sur des observations qui n'ont pas servi à ajuster le modèle,
et non le seul pourcentage de variance des variables explicatives.

#example[
  Supposons que l'on utilise les composantes pour prédire une note future.
  Pour $q = 2, 3, 4, 6$, la validation croisée donne respectivement des racines
  de l'erreur quadratique moyenne de $5.1$, $4.0$, $3.6$ et $3.9$ points.
  Parmi ces choix, quatre composantes donnent la plus faible erreur moyenne.
  Garder les six conserve toute la variance des variables explicatives, mais
  n'améliore pas ici la prédiction. Ces résultats sont illustratifs : dans une
  analyse réelle, on examine aussi la variabilité des erreurs entre les plis.
]

Le centrage, la réduction, l'ACP et le modèle prédictif doivent être ajustés
dans chaque pli d'entraînement. Un éventuel jeu de test final reste réservé
à l'évaluation après le choix de $q$.

En pratique, on examine ensemble l'éboulis, la variance cumulée et le contenu
des axes proches du seuil retenu. On peut ensuite justifier le choix de façon
concrète : « Nous retenons trois composantes, qui conservent $90%$ de la
variance; les axes suivants apportent chacun au plus $5%$ et ne modifient pas
l'interprétation recherchée. » Cette dernière appréciation doit être vérifiée
à partir des variables et des observations représentées sur ces axes.

=== Lecture des cartes factorielles

La *carte des individus* place les observations selon leurs scores sur deux
composantes, généralement les deux premières. Chaque axe doit indiquer son
pourcentage de variance expliquée. Des points éloignés dans ce plan ont des
profils différents selon les dimensions affichées. En revanche, deux points
proches peuvent différer sur les composantes omises : une projection raccourcit
les distances et peut masquer des écarts.

Un point proche de l'origine a des scores faibles sur les axes affichés, mais
n'est pas nécessairement proche du profil moyen dans l'espace complet. Pour
donner un sens aux positions des individus, il faut examiner les variables
associées à chaque axe.

Le *cercle des corrélations* représente chaque variable par ses corrélations
avec les deux composantes. Ses coordonnées dans le premier plan sont donc
$"corr"(Z_j, Y_1)$ et $"corr"(Z_j, Y_2)$. Une variable proche du cercle est
bien représentée dans ce plan; une variable proche de l'origine l'est peu.
Lorsque les deux variables sont bien représentées :

- des flèches de même direction suggèrent une corrélation positive;
- des flèches de directions opposées suggèrent une corrélation négative;
- un angle proche de 90 degrés suggère une corrélation proche de zéro.

Ces lectures d'angles deviennent peu fiables pour des variables mal représentées.
Pour nommer un axe, on cherche les variables qui lui sont fortement corrélées et
on décrit ce qu'elles ont en commun ou ce qu'elles opposent. Un axe associé
positivement à plusieurs notes peut, par exemple, représenter un niveau de
réussite commun.

#note[
  Le signe d'un axe d'ACP est arbitraire. Multiplier ses coefficients et ses
  scores par $-1$ inverse l'orientation du graphique sans changer l'analyse.
  Les termes « positif » et « négatif » décrivent une orientation, pas un jugement
  sur les observations.
]

=== Contribution et qualité de représentation

Ces deux notions répondent à des questions différentes. La *contribution*
indique dans quelle mesure une observation ou une variable participe à la
construction d'un axe. La *qualité de représentation* indique dans quelle mesure
un axe ou un plan restitue le profil d'une observation ou la variation d'une
variable.

Pour des observations de même poids, la contribution de l'individu $i$ à l'axe
$k$, de variance non nulle, est :

$ "ctr"_(i k) = y_(i k)^2 / ((n - 1) lambda_k) $

Les contributions des $n$ individus à un axe totalisent 1. Une valeur supérieure
à $1 / n$ indique une contribution supérieure à la moyenne, sans constituer à
elle seule une preuve d'anomalie. Quelques observations très contributives
peuvent fortement influencer l'orientation de l'axe.

La qualité de représentation d'un individu sur cet axe est mesurée par le
*cosinus carré* :

$ cos^2_(i k) = y_(i k)^2 / (sum_(j=1)^p z_(i j)^2) $

Le dénominateur est le carré de sa distance à l'origine dans l'espace préparé.
Pour un plan, on additionne les cosinus carrés des deux axes. Une valeur proche
de 1 signifie que le plan restitue presque toute cette distance. Ce rapport
n'est pas défini pour une observation exactement au centre du nuage.

Pour une variable, la qualité de représentation dans un plan est la somme de
ses corrélations au carré avec les axes du plan. Dans une ACP centrée réduite,
sa contribution à un axe est le carré du coefficient $alpha_(j k)$.
Une variable peut être bien représentée sur un axe sans en être la principale
contributrice. Il faut donc consulter les deux indicateurs avant d'interpréter
les cartes.

=== Pratique de l'ACP

Une analyse peut suivre les étapes suivantes :

1. Définir les observations et les variables quantitatives pertinentes pour la
   question étudiée; examiner les données manquantes et les valeurs extrêmes.
2. Choisir une ACP centrée ou centrée réduite et préparer les données.
3. Calculer les axes, les scores et les valeurs propres.
4. Examiner la variance expliquée pour choisir le nombre de composantes.
5. Interpréter les axes à partir des variables, de leurs contributions et de
   leurs qualités de représentation, puis décrire les individus.
6. Vérifier que les conclusions restent cohérentes en consultant d'autres plans
   ou en examinant l'influence des observations les plus contributives.

=== Limites

L'ACP est linéaire : un petit nombre d'axes peut mal résumer une structure
courbe. Elle est sensible à l'échelle des variables et aux valeurs extrêmes,
qui peuvent attirer les axes dans leur direction. La standardisation ne
supprime pas cette sensibilité aux observations atypiques.

L'ACP ne reçoit aucune variable réponse. Elle conserve la variance, qui n'est
pas nécessairement l'information la plus utile pour prédire une cible. Une
composante de faible variance peut être prédictive, tandis qu'une composante
de forte variance peut surtout refléter du bruit ou un effet secondaire.
De même, des groupes visibles sur une carte demandent une interprétation et
une validation; l'ACP n'est pas en elle-même une méthode de classification.

Lorsque les composantes servent de variables prédictives, le centrage, la
réduction et les axes doivent être appris uniquement sur les données
d'entraînement. On applique ensuite ces mêmes moyennes, écarts-types et
coefficients aux nouvelles observations. En validation croisée, cette
préparation doit être répétée dans chaque pli d'entraînement pour éviter une
fuite d'information.

== L'AFC

=== Tableau de contingence et profils

L'analyse factorielle des correspondances, ou AFC, s'applique à un tableau de
contingence croisant deux variables qualitatives. Elle représente simultanément
les modalités de ligne et de colonne dans un espace de faible dimension.

L'AFC part des fréquences relatives du tableau. Elle compare les profils-lignes
et les profils-colonnes plutôt que les effectifs bruts. Un profil-ligne décrit,
pour une modalité de la première variable, la distribution conditionnelle des
modalités de la seconde variable. Un profil-colonne décrit l'information
symétrique.

#example[
  Si l'on croise le programme d'étude et le type d'admission des étudiants, une
  ligne du tableau décrit la répartition des types d'admission pour un programme
  donné. Deux programmes proches dans la représentation AFC ont des profils
  d'admission semblables.
]

=== Indépendance et distance du chi-deux

Si les deux variables qualitatives sont indépendantes, les fréquences conjointes
sont proches du produit des fréquences marginales. L'AFC étudie les écarts à
cette situation d'indépendance.

La distance utilisée est la distance du chi-deux. Elle pondère les écarts par
les fréquences marginales, ce qui évite qu'une modalité très fréquente impose à
elle seule la structure géométrique. L'inertie totale est liée à la statistique
du test du chi-deux d'indépendance.

Autrement dit, l'AFC met en évidence les associations qui s'écartent le plus de
ce que l'on observerait si les deux variables étaient indépendantes.

=== Représentation barycentrique

Une propriété utile de l'AFC est la double représentation barycentrique. Les
modalités de ligne peuvent être vues comme des barycentres pondérés des
modalités de colonne, et inversement. Cela rend les cartes factorielles
interprétables: une proximité entre modalités suggère une association dans le
tableau, à condition de vérifier la qualité de représentation.

#note[
  Sur une carte d'AFC, il faut interpréter les directions, les oppositions et
  les contributions. Deux points proches du centre peuvent être mal représentés
  ou peu contributifs; leur proximité brute n'est pas toujours informative.
]

=== Lecture pratique

Pour interpréter une AFC, on regarde:

- les modalités qui contribuent fortement aux axes;
- les oppositions entre modalités de ligne;
- les oppositions entre modalités de colonne;
- les modalités éloignées de l'origine, souvent plus spécifiques;
- la qualité de représentation des points dans le plan affiché.

Une carte d'AFC n'est pas seulement un graphique décoratif. Elle doit être reliée
au tableau de contingence: les associations visibles doivent correspondre à des
écarts concrets entre profils.

== L'ACM

=== Plusieurs variables qualitatives

L'analyse des correspondances multiples, ou ACM, généralise l'AFC à plusieurs
variables qualitatives. Elle est particulièrement utile pour les questionnaires
ou les enquêtes comportant plusieurs questions à choix multiples.

Chaque variable est transformée en modalités binaires par codage disjonctif
complet. Si une question possède trois modalités, elle devient trois colonnes
binaires. Un individu reçoit un 1 pour la modalité choisie et 0 pour les autres.

Le tableau de Burt, obtenu comme produit du tableau disjonctif transposé par le
tableau disjonctif, croise toutes les modalités entre elles. L'ACM peut être vue
comme une AFC appliquée au tableau disjonctif complet ou au tableau de Burt.

=== Individus et modalités

L'ACM représente à la fois les individus et les modalités. Deux individus proches
ont tendance à partager des modalités semblables. Deux modalités proches sont
souvent choisies par des individus aux profils semblables.

Les axes d'une ACM opposent donc des profils de réponses. Par exemple, dans une
enquête sur les habitudes d'étude, un premier axe peut opposer des étudiants
très organisés à des étudiants qui déclarent travailler de manière irrégulière.
Un second axe peut distinguer les habitudes individuelles des habitudes
collectives.

=== Encodage et regroupement des modalités

Le choix des modalités est crucial. Pour une variable continue que l'on souhaite
inclure dans une ACM, il faut d'abord la discrétiser en classes. Ce découpage
fait perdre de l'information et doit être guidé par le contexte, les
distributions observées et l'objectif de l'analyse.

Pour les variables qualitatives, certaines modalités peuvent être trop rares.
Il est préférable de les regrouper de manière interprétable plutôt que de les
répartir arbitrairement dans d'autres catégories.

On peut aussi déclarer certaines variables ou modalités comme supplémentaires.
Elles sont alors projetées sur la carte sans contribuer à la construction des
axes. Cette pratique est utile pour interpréter les dimensions sans laisser une
variable illustrative dominer la géométrie.

=== Interprétation et limites

L'ACM est très utile pour résumer des données qualitatives nombreuses, mais son
inertie est souvent plus difficile à lire que celle de l'ACP. Le codage
disjonctif complet augmente le nombre de colonnes et dilue mécaniquement les
pourcentages d'inertie. Une faible proportion d'inertie expliquée n'implique
donc pas nécessairement que la carte soit inutile.

Comme pour l'AFC, l'interprétation doit s'appuyer sur les contributions, les
qualités de représentation et le retour aux données initiales. Une modalité rare
peut attirer un axe à elle seule; elle doit alors être examinée avant de conclure
qu'elle révèle une structure générale.

#example[
  Dans un questionnaire étudiant, les modalités "jamais", "parfois", "souvent"
  et "toujours" ne doivent pas être regroupées mécaniquement. Leur ordre et leur
  sens substantiel doivent guider la construction des catégories utilisées dans
  l'ACM.
]

== t-SNE

=== Idée générale

t-SNE, pour *t-distributed stochastic neighbor embedding*, est une méthode non
linéaire principalement utilisée pour produire des cartes en deux ou trois
dimensions. Elle transforme les proximités entre observations en probabilités:
deux observations proches dans l'espace initial doivent avoir une forte
probabilité d'être voisines dans la représentation réduite.

L'algorithme cherche ensuite une carte de faible dimension dont les probabilités
de voisinage ressemblent à celles de l'espace initial. La comparaison se fait
par une divergence de Kullback-Leibler. La loi de Student utilisée dans l'espace
réduit aide à éviter que tous les points soient tassés au centre de la carte.

=== Interprétation

t-SNE est très efficace pour faire apparaître des groupes locaux, surtout dans
des données de grande dimension comme des images, des textes vectorisés ou des
données biologiques. En revanche, les distances entre groupes, la taille des
groupes et leur densité apparente peuvent être trompeuses.

#note[
  Une carte t-SNE ne doit pas être lue comme une carte géographique. Deux points
  voisins sont souvent réellement semblables, mais deux groupes éloignés ne sont
  pas nécessairement très différents au sens statistique.
]

=== Paramètres importants

Le paramètre le plus connu est la perplexité. Il contrôle approximativement le
nombre de voisins pris en compte autour de chaque observation. Une petite
perplexité met en avant des structures très locales; une grande perplexité donne
une vision plus lissée.

En pratique, il faut aussi surveiller l'initialisation, le taux d'apprentissage,
le nombre d'itérations et la graine aléatoire. Une bonne habitude consiste à
comparer plusieurs cartes et à vérifier que les structures observées existent
aussi dans les données initiales ou dans une ACP préalable.

== UMAP

=== Principe

UMAP, pour *uniform manifold approximation and projection*, est une méthode non
linéaire fondée sur un graphe de plus proches voisins. Elle construit d'abord
une représentation des voisinages dans l'espace initial, puis cherche une carte
de faible dimension qui conserve autant que possible cette structure de graphe.

Comme t-SNE, UMAP est surtout utilisé pour la visualisation exploratoire. Il est
souvent plus rapide sur de grands jeux de données et conserve parfois mieux une
part de structure globale, même si cette structure doit toujours être validée.

=== Paramètres importants

Le paramètre `n_neighbors` contrôle l'équilibre entre structure locale et
structure plus globale. Une petite valeur accentue les voisinages immédiats; une
grande valeur donne une carte plus continue. Le paramètre `min_dist` contrôle le
degré de compacité des groupes dans l'espace projeté.

La métrique utilisée est aussi importante. Pour des données numériques
standardisées, la distance euclidienne est fréquente. Pour des textes, des
vecteurs creux ou des données binaires, d'autres similarités peuvent être plus
pertinentes.

=== Usages

UMAP est utile pour explorer des données complexes avant une analyse plus
formelle. On l'utilise souvent après une étape de prétraitement: standardisation,
filtrage de variables, ACP préalable ou choix d'une distance adaptée.

Certaines implémentations permettent aussi de projeter de nouvelles observations
dans une carte apprise. Cela rend UMAP plus pratique que t-SNE dans des flux de
données ou dans un protocole où l'on souhaite comparer entraînement et
validation.

== Autoencodeurs

=== Représentation latente

Un autoencodeur est un réseau de neurones entraîné à reconstruire ses entrées.
Il est composé de deux parties: un encodeur qui transforme l'observation initiale
en représentation latente de plus faible dimension, puis un décodeur qui tente de
reconstruire l'observation à partir de cette représentation.

Si la dimension latente est petite, le modèle doit apprendre un résumé utile des
données. Contrairement à l'ACP, ce résumé peut être non linéaire. Cela permet de
capturer des structures complexes, au prix d'une interprétation souvent plus
difficile.

=== Fonction de perte

L'entraînement repose sur une erreur de reconstruction. Pour des données
numériques, on utilise souvent une erreur quadratique. Pour des données binaires
ou des comptages, on choisit une fonction de perte adaptée à la nature des
données.

La réduction de dimension correspond alors à la sortie de l'encodeur. On peut
utiliser cette représentation latente pour visualiser les observations, alimenter
un modèle prédictif ou comparer des profils.

=== Autoencodeurs variationnels

Les autoencodeurs variationnels, ou VAE, ajoutent une structure probabiliste à
l'espace latent. L'encodeur ne produit pas seulement un point, mais une
distribution latente. Le modèle combine une erreur de reconstruction et une
pénalité qui rapproche l'espace latent d'une distribution de référence.

Les VAE sont particulièrement utiles lorsque l'on veut générer de nouvelles
observations, lisser des données bruitées ou construire une représentation
latente régulière. Ils demandent cependant plus de données, plus de réglages et
une validation plus soigneuse que les méthodes factorielles classiques.

== Autres

=== Prolongements

Les méthodes suivantes peuvent être présentées comme prolongements, selon le
temps disponible et le type de données étudié.

- TriMap construit la carte à partir de triplets: une observation doit rester
  plus proche d'une deuxième observation que d'une troisième. Cette idée est
  utile pour discuter de la préservation de la structure globale.
- PaCMAP utilise des paires proches, moyennement proches et éloignées afin de
  mieux équilibrer la structure locale et la structure globale.
- PHATE s'appuie sur une géométrie de diffusion. Il est particulièrement adapté
  aux trajectoires, aux transitions continues et aux données biologiques comme
  les données de cellules individuelles.
- UMAP paramétrique remplace une partie de l'optimisation UMAP par un réseau de
  neurones. Il apprend une fonction de projection, ce qui facilite l'ajout de
  nouvelles observations.

=== Message à retenir

Ces méthodes modernes produisent des visualisations puissantes, mais elles ne
suppriment pas le besoin d'interprétation statistique. Elles dépendent du choix
de la distance, du graphe de voisins, des paramètres et parfois de
l'initialisation.

Une bonne pratique consiste à comparer plusieurs méthodes, à revenir aux
variables initiales et à vérifier les conclusions par des mesures simples:
profils moyens, distances, contributions, stabilité des groupes ou performance
sur un jeu de validation.

#heading(level: 2, outlined: false)[Questions rapides]

1. Expliquez pourquoi une ACP sur des variables non standardisées peut être
   trompeuse.
2. Dans une ACP, que signifie une valeur propre élevée ?
3. Donnez un exemple de tableau de contingence adapté à une AFC.
4. Décrivez comment construire un tableau disjonctif complet pour trois
   questions à choix multiples.
5. Pourquoi faut-il être prudent avec les modalités rares en ACM ?
6. Pourquoi une carte t-SNE ne suffit-elle pas à prouver l'existence de groupes
   statistiques ?
7. Quel paramètre d'UMAP contrôle l'équilibre entre structure locale et globale ?
8. Dans un autoencodeur, quelle partie du modèle fournit la représentation
   réduite ?
