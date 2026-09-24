#import "../styles/notes.typ": *

= Réduction de dimension

== Introduction

Un grand nombre de variables complique la visualisation, augmente le coût de calcul, favorise les corrélations redondantes et peut rendre les modèles instables. La réduction de dimension cherche à remplacer les variables initiales par un plus petit nombre de variables synthétiques qui conservent l'information utile.

Réduire la dimension ne signifie pas seulement supprimer des variables. Une méthode peut-étre plus intéressante consiste à construire de nouveaux axes de représentation, souvent comme des combinaisons des variables initiales, puis à travailler dans cet espace réduit. On passe alors d'une représentation où chaque variable a son propre axe, et donc son propre rôle, à une représentation où quelques dimensions (axes) résument les principales structures du jeu de données.

#remark[
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
Cette espace doit être interprété avec prudence : une projection simplifie les données, donc elle conserve certaines structures et en efface d'autres.

== L'analyse en composantes principales

=== Principe

#definition(title: [Analyse en composantes principales])[
  L'analyse en composantes principales (ACP) s'applique à un tableau de $n$
  observations décrites par $p$ variables quantitatives. Chaque observation est
  un point dans un espace à $p$ dimensions. L'ACP cherche de nouveaux axes pour
  résumer ce nuage de points avec moins de dimensions, tout en conservant le plus
  possible de sa dispersion. Les directions sont les *axes principaux* ; les
  coordonnées sur ces axes sont les *composantes principales* ou scores.
]

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

#definition(title: [ACP centrée et ACP centrée réduite])[
  Une *ACP centrée* travaille sur les valeurs centrées $z_(i j)$ et analyse la matrice de covariance des variables originales. Elle donne davantage de poids aux variables dont la variance est élevée. Ce choix est pertinent lorsque les échelles sont comparables et que les différences de dispersion ont un sens pour l'analyse.

  Une *ACP centrée réduite*, aussi appelée ACP normée, divise également chaque variable par son écart-type empirique $s_j$ :

  $ z_(i j) = (x_(i j) - overline(x)_j) / s_j, $
  $ s_j = sqrt(Var(X_j))
    = sqrt(1/(n-1) sum_(i=1)^n (x_(i j)-overline(x)_j)^2). $

  Les variables transformées ont alors une moyenne nulle et une variance égale à 1. Leur matrice de covariance est la matrice de corrélation des variables originales. Cette approche est généralement adaptée lorsque les unités ou les ordres de grandeur diffèrent.
]

#example[
  Pour décrire des logements par leur superficie et leur prix, une ACP centrée peut être dominée par le prix, dont les valeurs sont plus dispersées. De plus, exprimer le prix en dollars plutôt qu'en euros ou exprimer la superficie en pieds carrés plutôt qu'en mètres carrés modifie le résultat. La standardisation supprime cet effet d'unité et donne à chaque variable la même variance initiale.
]

La standardisation reste un *choix* d'analyse : elle peut aussi donner beaucoup
de poids à une variable peu informative. Avant le calcul, il faut examiner les
valeurs extrêmes et traiter les données manquantes.

#remark[
  Les variables constantes n'apportent aucune dispersion et doivent être retirées avant une division par leur écart-type, qui est nul.
]

=== Construction des composantes

#definition(title: [Matrice de covariance empirique])[
  Notons $Zmat = (z_(i j)) in RR^(n times p)$ la matrice des données, avec $n >= 2$ observations en lignes et $p$ variables en colonnes. On suppose que chaque colonne est centrée, donc
  $ sum_(i=1)^n z_(i j) = 0 quad "pour tout" quad j. $
  Les observations ont le même poids et l'on suppose qu'au moins une variable a une variance non nulle. La matrice de covariance empirique est donnée par

  $ hat(Sigma) = 1 / (n - 1) Zmat^top Zmat in RR^(p times p). $
]


#remark[
  Si les colonnes de $Zmat$ ont été réduites, $hat(Sigma)$ est la matrice de corrélation empirique des variables originales.
]

Ainsi, la matrice $hat(Sigma)$ est symétrique et semi-définie positive, car pour tout $alpha in RR^p, alpha != 0$, en utilisant la norme euclidienne, on trouve que

$ alpha^top hat(Sigma) alpha = 1 / (n - 1) norm(Zmat alpha)^2 >= 0. $

#definition(title: [Score et variance d'une projection])[
  Une direction (axe) est représentée par un vecteur unitaire $alpha in RR^p$, c'est-à-dire $norm(alpha)^2 = alpha^top alpha = 1$. Si $z_i$ désigne le vecteur colonne correspondant à la ligne $i$ de $Zmat$, la coordonnée de cette observation sur la direction $alpha$ est donnée par $y_i = alpha^top z_i = chevron.l alpha, z_i chevron.r$. Le vecteur des coordonnées des $n$ observations dans la direction donnée par $alpha$ est donc $y = Zmat alpha in RR^n$. Il est centré car les colonnes de $Zmat$ le sont. Sa variance empirique vaut

  $ Var(y) = 1 / (n - 1) sum_(i=1)^n y_i^2
    = 1 / (n - 1) y^top y = alpha^top hat(Sigma) alpha. $
]

L'ACP cherche ainsi des directions unitaires qui maximisent cette forme quadratique.

#remark[
  La contrainte de norme fixe l'échelle des coefficients. En effet, multiplier $alpha$ par $c != 0$ multiplierait la variance par $c^2$, sans changer la direction géométrique.
]

#definition(title: [Premier axe principal])[
  Le premier axe résout le problème :

  $ alpha_1 = argmax_(alpha^top alpha = 1)
    alpha^top hat(Sigma) alpha. $
]

#property(title: [Variance maximale])[
  Si $lambda_1$ est la plus grande valeur propre de $hat(Sigma)$, alors
  $max_(alpha^top alpha=1) alpha^top hat(Sigma) alpha=lambda_1$.
  Un vecteur propre unitaire associé à $lambda_1$ fournit un premier axe principal.
]

#proof[
  On applique à la matrice symétrique $hat(Sigma)$ le résultat sur le quotient
  de Rayleigh (voir plus bas). En notant $u_1,dots,u_p$ ses vecteurs propres
  orthonormés, associés à $lambda_1 >= dots >= lambda_p >= 0$, le maximum est
  atteint pour $alpha_1=u_1$. Ainsi, $Y_1=Zmat alpha_1$ et $Var(Y_1)=lambda_1$.
]

*Composantes suivantes.* Pour $2 <= k <= p$, on maximise la même variance en imposant en plus l'orthogonalité aux directions déjà retenues. Si $cal(A)_k$ est l'ensemble des vecteurs $alpha$ tels que $alpha^top alpha = 1$ et $alpha^top alpha_j = 0$ pour tout $j < k$, alors :

$ alpha_k = argmax_(alpha in cal(A)_k)
  alpha^top hat(Sigma) alpha. $

Les contraintes excluent les $k-1$ premières directions propres. Le même
résultat, appliqué au sous-espace orthogonal restant, donne la variance maximale
$lambda_k$, atteinte pour $alpha_k=u_k$. On obtient des directions orthonormées
vérifiant :

$ hat(Sigma) alpha_k = lambda_k alpha_k, quad "et" quad Y_k = Zmat alpha_k. $

Le coefficient $alpha_(j k)$ est le poids de la variable $j$ dans la composante $k$. Il est commun à toutes les observations. Le *score* de l'observation $i$ sur cette composante, i.e. la coordonnée de l'observation $i$ sur la direction $k$, est donnée par

$ y_(i k) = alpha_k^top z_i = sum_(j=1)^p alpha_(j k) z_(i j). $

#property(title: [Variance et covariance des composantes])[
  Chaque composante a pour variance la valeur propre correspondante,
  $Var(Y_k)=lambda_k$, et deux composantes distinctes ont une covariance nulle,
  $Cov(Y_k,Y_l)=0$ pour $k != l$.
]

#proof[
  Les vecteurs de scores étant centrés, leur covariance empirique s'écrit :

  $ Cov(Y_k, Y_l) = 1 / (n - 1) Y_k^top Y_l
    = alpha_k^top hat(Sigma) alpha_l = lambda_l alpha_k^top alpha_l. $

  Pour $k = l$, on retrouve $Var(Y_k) = lambda_k$. Pour $k != l$, l'orthogonalité
  des directions donne $Cov(Y_k, Y_l) = 0$.
]

#remark(title: [Décorrélation et indépendance])[
  Les composantes de variance non nulle
  ont donc une corrélation empirique nulle deux à deux. Cette propriété ne
  démontre pas une indépendance probabiliste.
]

*Représentation réduite.* Pour conserver $q$ composantes, avec $1 <= q <= p$, on rassemble les composantes principales dans une matrice $A_q = (alpha_1, dots, alpha_q) in RR^(p times q)$. La matrice des données réduites $T_q = (Y_1, dots, Y_q)$ est donnée par

$ T_q = Zmat A_q in RR^(n times q), quad "avec" quad A_q^top A_q = I_q. $

La matrice de covariance de $T_q$ est donc
$ 1 / (n - 1) T_q^top T_q = A_q^top hat(Sigma) A_q
  = diag(lambda_1, dots, lambda_q). $

Ici, $I_q$ est la matrice identité de taille $q$ et $diag$ désigne une
matrice diagonale. Chaque ligne de $T_q$ contient les $q$ scores d'une observation.
Le rang $r = rang(Zmat)$ est au plus $min(n - 1, p)$, à cause du centrage.
Il y a donc exactement $r$ composantes de variance strictement positive; les
autres ont des scores tous nuls.

#remark[
  Pour une valeur propre simple, le vecteur propre unitaire est défini au signe
  près. Si une valeur propre est multiple, toute base orthonormée de son
  sous-espace propre convient :
  les axes individuels ne sont alors pas uniques. Pour $q < p$, une séparation
  stricte $lambda_q > lambda_(q+1)$ garantit l'unicité du sous-espace engendré
  par les $q$ premières directions, même si l'orientation de certains axes
  dans ce sous-espace peut varier.
]

En pratique, on peut calculer les composantes avec une décomposition en valeurs
singulières réduite $Zmat = U D V^top$, où $r=rang(Zmat)$,
$U in RR^(n times r)$ et $V in RR^(p times r)$ ont des colonnes orthonormées.
On a $D=diag(d_1,dots,d_r)$, avec $d_1 >= dots >= d_r > 0$.
En notant $U_k$ et $V_k$ leurs $k$-ièmes colonnes, on obtient, pour
$1 <= k <= r$ :

$ alpha_k = V_k, quad lambda_k = d_k^2 / (n - 1), quad "et" quad Y_k = d_k U_k. $

Cette formulation réalise la même ACP sans former explicitement $Zmat^top Zmat$,
avec les mêmes possibilités de choix du signe et des bases des sous-espaces
propres. Conserver seulement $q<r$ termes donne une approximation de rang $q$,
et non une égalité avec la matrice initiale.

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

#definition(title: [Inertie totale en ACP])[
  Pour les observations $z_1, dots, z_n in RR^p$, le centre de gravité est $g = 1 / n sum_(i=1)^n z_i$. Dans le cadre de l'ACP, $g = 0$, puisque les variables ont été centrées. En utilisant la normalisation par $n - 1$ de la variance empirique, on définit l'inertie totale par

  $ inertia = 1 / (n - 1) sum_(i=1)^n norm(z_i - g)^2
    = 1 / (n - 1) sum_(i=1)^n norm(z_i)^2. $
]

Le centrage ne change pas les distances au centre : il déplace simplement le centre de gravité à l'origine de l'espace. En revanche, réduire les variables change les distances et donc l'inertie analysée.

#remark[
  L'inertie géométrique est souvent définie comme la moyenne des distances au
  carré, avec le diviseur $n$. Elle vaut alors $(n - 1) / n inertia$. Le choix entre
  ces deux normalisations ne change ni les axes de l'ACP ni les proportions
  d'inertie expliquée, à condition de l'appliquer de manière cohérente.
]

*Lien avec la variance.* Le carré de la distance à l'origine est la somme des
carrés des coordonnées. En échangeant les deux sommes, on obtient :

$ inertia = sum_(j=1)^p (1 / (n - 1) sum_(i=1)^n z_(i j)^2)
  = sum_(j=1)^p Var(Z_j) = tr(hat(Sigma)). $

Ici, $Z_j$ est la $j$-ième colonne de $Zmat$ et la trace $tr$ d'une matrice
est la somme de ses éléments diagonaux. L'inertie totale est donc la somme des
variances des variables préparées. Dans une ACP centrée réduite, elle vaut $p$,
puisque chacune des $p$ variables a une variance égale à 1.

*Répartition entre les axes.* Les axes de l'ACP forment un repère orthonormé. Le théorème de Pythagore donne, pour chaque observation :

$ norm(z_i)^2 = sum_(k=1)^p y_(i k)^2. $

Un changement de repère orthonormé conserve ainsi les distances au centre, et donc l'inertie totale. En sommant sur les observations et en utilisant $Var(Y_k) = lambda_k$, on trouve

$ inertia = sum_(k=1)^p (1 / (n - 1) sum_(i=1)^n y_(i k)^2)
  = sum_(k=1)^p lambda_k. $

Chaque valeur propre $lambda_k$ mesure donc l'inertie portée par l'axe $k$. L'ACP répartit la dispersion du nuage entre des directions orthogonales, ordonnées de la plus dispersée à la moins dispersée.

#definition(title: [Proportions de variance expliquée])[
  La proportion de variance expliquée par la composante $k$ et la proportion de variance expliquée cumulée sur les $q$ premières composantes sont respectivement :

  $ r_k = lambda_k / (sum_(j=1)^p lambda_j)
    quad "et" quad R_q = (sum_(k=1)^q lambda_k) / (sum_(j=1)^p lambda_j). $
]

La quantité $1 - R_q$ mesure donc la part de variance perdue dans la représentation réduite. Dans ce cas, « expliquée » signifie « conservée par la projection ». Il ne s'agit pas d'une explication causale des données.

#example[
  Si les deux premières composantes expliquent respectivement $60%$ et $22%$ de la variance, le premier plan factoriel en conserve $82%$. Les $18%$ restants correspondent à des différences entre observations qui ne sont pas visibles dans ce plan facotriel. Ce bon résumé global ne garantit pas que chaque observation ou chaque variable y soit bien représentée.
]

L'ACP peut aussi être comprise comme une méthode de reconstruction. En effet, on peut approcher $z_i$ par

$ hat(z)_i = sum_(k=1)^q y_(i k) alpha_k. $

L'inertie perdue correspond exactement à l'erreur de reconstruction, avec la
même normalisation :

$ 1 / (n - 1) sum_(i=1)^n norm(z_i - hat(z)_i)^2
  = sum_(k=q+1)^p lambda_k = inertia (1 - R_q). $

Parmi les projections orthogonales sur des sous-espaces de dimension $q$,
l'ACP minimise la somme des carrés des erreurs de reconstruction. Conserver
le plus de variance et perdre le moins d'information au sens de cette erreur
quadratique sont donc deux formulations du même problème. Pour retrouver les
unités originales, on multiplie chaque valeur reconstruite par l'écart-type
correspondant si les variables ont été réduites, puis on ajoute leur moyenne.

=== Étude de cas : deux variables

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

$ Var(Y_1) = 1 / 2 (1 + 1 + 2 times 0.8) = 1.8, $
$ Var(Y_2) = 1 / 2 (1 + 1 - 2 times 0.8) = 0.2. $

Leur covariance est nulle, car $Cov(Y_1, Y_2) = (Var(Z_1) - Var(Z_2)) / 2 = 0$. L'inertie totale vaut $1.8 + 0.2 = 2$, comme la somme des variances des deux notes centrées réduites. La première composante en conserve $1.8 / 2 = 90%$, et la seconde $0.2 / 2 = 10%$.

*Lecture de trois profils.* Le calcul des scores donne :

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  align: center,
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

*Graphique des valeurs propres et règle du coude.* L'éboulis représente les valeurs propres $lambda_k$ en fonction du rang $k$ de la composante (cf. @fig-acp-nombre-composantes). On cherche une rupture de pente : avant le coude, les axes apportent une part importante de la variance; et après le coude, les gains deviennent plus faibles. Cette lecture sert à repérer un compromis, sans imposer au préalable un pourcentage.

Dans l'exemple, la courbe s'aplatit à partir de la quatrième valeur propre, $lambda_4 = 0.3$ : les suivantes, $0.2$ et $0.1$, ne diminuent plus que de $0.1$ à chaque étape. On situe donc ici le coude au rang $k = 4$ et l'on retient $q = 4$ composantes, qui conservent $95%$ de la variance. La position du coude reste toutefois une appréciation visuelle et plusieurs ruptures peuvent être plausibles. L'important est de justifier le choix retenu, et non de l'imposer.

#example[
  Supposons au contraire que six variables standardisées soient non corrélées, avec six valeurs propres toutes égales à $1$. L'éboulis est horizontal. Il n'existe pas de coude ni de direction de variance privilégiée. Deux axes ne conservent que $33.3%$ de la variance. Il en faut cinq pour dépasser $80%$, et les six pour atteindre $90%$. Une forte réduction de dimension résumerait donc mal la dispersion de ces données.
]

*Règles de Kaiser et de Jolliffe.* Dans une ACP centrée réduite, la valeur propre moyenne vaut $1$, puisque la somme des $p$ valeurs propres vaut $p$. La règle de Kaiser conserve celles qui sont strictement supérieures à $1$ : chaque axe retenu porte alors plus de variance qu'une variable standardisée prise seule. La règle de Jolliffe abaisse ce seuil à $0.7$ et retient donc davantage d'axes ou le même nombre.

Dans notre exemple à six variables, la règle de Kaiser conserve les composantes de rangs $k = 1$ et $k = 2$ ($3.0$ et $1.5$) : le choix est donc $q = 2$, avec $R_2 = 75%$. La règle de Jolliffe conserve les trois premières composantes ($3.0$, $1.5$ et $0.9$) : le choix est $q = 3$, avec $R_3 = 90%$. Ces règles peuvent donc conduire à des choix différents. Leurs seuils sont des repères heuristiques. Ils ne s'appliquent pas tels quels à une ACP sur des variables non réduites, dont les variances dépendent des unités de mesure. Dans le cas de six valeurs propres égales à $1$, la règle stricte de Kaiser ne retient même aucun axe, ce qui illustre la nécessité de l'interpréter plutôt que de l'appliquer seule.


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

*Interprétabilité et objectif de l'analyse.* Une composante de faible variance peut représenter une opposition intéressante. Dans l'exemple des deux examens, le premier axe conserve $90%$ de la variance, alors que le second distingue les étudiants ayant des résultats contrastés entre les deux évaluations. Si cette différence est au centre de la question étudiée, il est utile de conserver les deux composantes.

Pour une utilisation prédictive, on peut comparer plusieurs valeurs de $q$ par validation croisée de l'ensemble du modèle. Le critère devient alors la qualité des prédictions sur des observations qui n'ont pas servi à ajuster le modèle, et non le seul pourcentage de variance des variables explicatives. Le centrage, la réduction, l'ACP et le modèle prédictif doivent être ajustés dans chaque pli d'entraînement. Un éventuel jeu de test final reste réservé à l'évaluation après le choix de $q$.

En pratique, on examine l'éboulis, la variance cumulée et le contenu des axes proches du seuil retenu ensemble. On peut ensuite justifier le choix de façon concrète : « Nous retenons trois composantes, qui conservent $90%$ de la variance. Les axes suivants apportent chacun au plus $5%$ de la variance expliquée et ne modifient pas l'interprétation recherchée. » Cette dernière appréciation doit être vérifiée à partir des variables et des observations représentées sur ces axes.

=== Lecture des plans factoriels

Un plan factoriel est un plan défini par deux composantes principales, par
exemple $(Y_1, Y_2)$ ou $(Y_1, Y_3)$. Sa lecture combine deux représentations :
la carte des individus, qui montre les profils des observations, et le cercle
des corrélations, qui aide à comprendre le sens des axes à partir des variables.

*Identifier le plan et la variance représentée.* Chaque axe doit indiquer son
rang et son pourcentage de variance expliquée. La part de variance conservée
par un plan est la somme des pourcentages de ses deux axes.

#example[
  Dans l'exemple à six variables de la sous-section précédente, les trois
  premières composantes expliquent respectivement $50%$, $25%$ et $15%$ de la
  variance. Le plan $(Y_1, Y_2)$ en représente donc $75%$, tandis que le plan
  $(Y_1, Y_3)$ en représente $65%$. Ce dernier peut être utile pour examiner
  une opposition portée par le troisième axe. Le cumul $R_3 = 90%$ concerne
  les trois composantes ensemble. Il ne décrit pas à lui seul la qualité d'un
  graphique à deux dimensions.
]

*Lire la carte des individus.* Dans le premier plan, l'observation $i$ est placée au point $(y_(i 1), y_(i 2))$. Deux individus à droite ont des scores positifs sur le premier axe, mais leur position verticale peut les distinguer sur le second. Ces positions ne prennent un sens concret qu'après avoir interprété les axes à l'aide des variables.

Les distances doivent être lues dans la géométrie des données utilisées pour l'ACP. Des points éloignés dans le plan ont des profils différents dans cette géométrie. En revanche, deux points proches peuvent différer sur les composantes omises. La projection raccourcit les distances et peut masquer des écarts. Pour comparer visuellement les distances, il faut utiliser la même échelle sur les deux axes du graphique.

#example[
  Reprenons les profils A, B et C de la @fig-acp-exemple-reperes. Le premier axe décrit le niveau commun aux deux notes, et le second leur contraste. Le point A, de score $(sqrt(2), 0)$, se trouve à droite : ses deux notes sont supérieures à leurs moyennes respectives. Le point B, de scores $(0, sqrt(2))$, se trouve en haut : sa première note standardisée dépasse la seconde. Le point C, de scores $(0, 0)$, est au centre : il correspond exactement aux deux notes moyennes. Les positions de A et B expriment donc deux caractéristiques différentes : un niveau commun élevé et un fort contraste.
]

Dans une ACP comportant davantage de composantes, être proche de l'origine
du plan signifie seulement avoir des scores faibles sur les deux axes affichés.
Cela ne suffit pas pour conclure que le profil est moyen dans l'espace complet.

#example[
  Considérons deux individus D et E dont les scores sur trois composantes sont
  $(0.1, 0.1, 3)$ et $(0.1, 0.1, -3)$. Dans le plan $(Y_1, Y_2)$, ils se
  superposent près de l'origine. Pourtant, leur distance dans l'espace des
  trois composantes vaut $6$, entièrement selon $Y_3$. Le plan $(Y_1, Y_3)$
  révèle immédiatement cette différence. Leur proximité dans le premier plan
  ne traduit donc pas une ressemblance de leurs profils complets.
]

*Lire le cercle des corrélations.* Chaque variable $Z_j$ peut être représentée par une flèche partant de l'origine. Dans le premier plan factoriel, son extrémité a pour coordonnées $(rho_(j 1), rho_(j 2))$, où $rho_(j k) = Corr(Z_j, Y_k)$. Pour une ACP centrée réduite et un axe de variance non nulle, ces coordonnées se calculent à partir des coefficients de l'axe :

$ rho_(j k) = sqrt(lambda_k) alpha_(j k). $

Ces corrélations ne doivent pas être confondues avec les coefficients
$alpha_(j k)$ ni avec les scores des individus. Une corrélation proche de
$1$ signifie que la variable augmente généralement avec le score sur l'axe;
une corrélation proche de $-1$ signifie qu'elle évolue en sens inverse. Une
corrélation proche de $0$ traduit une association linéaire faible, voire
inexistante, entre la variable et la composante.

L'extrémité de chaque flèche appartient au disque unité, car
$rho_(j 1)^2 + rho_(j 2)^2 <= 1$. Cette somme mesure la qualité de représentation
de la variable dans le plan. Une flèche qui atteint presque le cercle indique
que les deux axes résument bien sa variation. Une flèche courte indique que
sa variation est surtout portée par d'autres axes.

#example[
  Pour les deux examens, les coordonnées des variables sont
  $Z_1 : (sqrt(0.9), sqrt(0.1))$ et
  $Z_2 : (sqrt(0.9), -sqrt(0.1))$, soit environ $(0.949, 0.316)$ et
  $(0.949, -0.316)$. Les deux notes sont fortement corrélées positivement à
  $Y_1$, ce qui justifie l'interprétation de cet axe comme un niveau commun.
  Leurs corrélations avec $Y_2$ ont des signes opposés : cet axe compare la
  réussite relative aux deux examens. Les deux flèches atteignent le cercle,
  puisque le plan contient ici toutes les composantes (cf. @fig-acp-cercle-correlations)
]

#figure(
  image("../figures/acp_cercle_correlations.svg", width: 78%,
    alt: "Cercle des corrélations des deux examens. La variable Z1 pointe "
      + "vers les coordonnées 0,949 et 0,316; Z2 pointe vers 0,949 et moins "
      + "0,316. Les deux flèches atteignent le cercle unité et forment un "
      + "angle d'environ 37 degrés. Elles sont orientées vers les valeurs "
      + "positives du premier axe et de part et d'autre du second."),
  caption: [Cercle des corrélations de l'exemple des deux examens. Les variables
    sont bien représentées et forment un angle d'environ $37 degree$.
    Le cosinus de cet angle vaut $0.8$, leur corrélation. Leurs directions
    communes sur $Y_1$ et opposées sur $Y_2$ expliquent le sens des deux axes.],
) <fig-acp-cercle-correlations>

*Interpréter les angles et nommer les axes.* Lorsque les deux variables sont
bien représentées dans le plan, l'angle entre leurs flèches renseigne sur leur
corrélation :

- un petit angle suggère une forte corrélation positive;
- un angle proche de $180 degree$ suggère une forte corrélation négative;
- un angle proche de $90 degree$ suggère une corrélation proche de zéro.

Cette lecture est exacte lorsque le plan représente entièrement les deux
variables; elle devient une approximation lorsque certaines de leurs
composantes sont omises. Elle est peu fiable pour des flèches courtes. Par
ailleurs, une corrélation nulle ne démontre pas une indépendance.

#example[
  Dans une autre ACP portant sur davantage de variables, une variable de coordonnées $(0.1, 0.2)$ dans le cercle des corrélations n'a que $5%$ de sa variance représentée dans ce plan ($0.1^2 + 0.2^2 = 0.05$). Sa flèche courte ne signifie pas que la variable est constante ou inutile. Il faut examiner d'autres axes avant d'interpréter ses relations avec les autres variables.
]

Pour nommer un axe, on examine les variables qui lui sont fortement corrélées,
les signes de ces corrélations et les contributions. On décrit ensuite les
individus à partir de ce sens donné à l'axe. La proximité entre deux individus
se lit sur leur plan, et les relations entre variables sur le cercle des
corrélations : les scores et les corrélations ont des échelles différentes.

Une lecture complète consiste ainsi à identifier la variance du plan, donner
un sens aux axes à partir des variables, puis examiner les profils des
individus. Les contributions et les qualités de représentation, détaillées
ci-dessous, permettent de vérifier les interprétations et de choisir les
autres plans à consulter.

#remark[
  Le signe d'un axe d'ACP est arbitraire. Multiplier ses coefficients et ses
  scores par $-1$ inverse l'orientation du graphique sans changer l'analyse.
  Les termes « positif » et « négatif » décrivent une orientation, pas un jugement
  sur les observations.
]

=== Contribution et qualité de représentation

Ces deux notions répondent à des questions différentes. La contribution mesure la part d'un individu ou d'une variable dans l'inertie d'un axe : elle aide à identifier les éléments qui définissent cet axe. La qualité de représentation mesure la part du profil d'un individu, ou de la variation d'une variable, restituée par un axe ou un plan.

La différence vient du dénominateur. La contribution rapporte une quantité
à l'inertie de l'axe, tandis que la qualité la rapporte à l'inertie de
l'élément représenté. On considère les observations ayant servi à calculer
l'ACP, de même poids. Les contributions aux axes sont définies pour
$lambda_k > 0$.

#definition(title: [Contribution d'un individu])[
  Puisque les scores sont centrés,
  $sum_(l=1)^n y_(l k)^2 = (n - 1) lambda_k$. La contribution de l'individu $i$
  à l'axe $k$ est donc la fraction de cette somme des carrés qui lui revient :

  $ ctr_(i k) = y_(i k)^2 / (sum_(l=1)^n y_(l k)^2)
    = y_(i k)^2 / ((n - 1) lambda_k). $
]

Pour un axe fixé, les contributions des $n$ individus totalisent $1$, soit
$100%$. Leur moyenne vaut donc $1 / n$. Un individu dont la contribution
dépasse $1 /n$ porte une part de l'inertie de l'axe supérieure à la moyenne.
Il mérite une attention particulière pour interpréter l'axe, sans être
nécessairement une observation aberrante. Quelques individus très contributifs
peuvent fortement influencer l'orientation de l'axe.

#example[
  Dans le nuage des deux examens, $n = 45$, $lambda_1 = 1.8$ et
  $lambda_2 = 0.2$. Le profil A a pour scores $(sqrt(2), 0)$ et le profil B
  $(0, sqrt(2))$. Leurs contributions non nulles sont :

  $ ctr_(A 1) = 2 / (44 times 1.8) approx 2.53%, quad
    ctr_(B 2) = 2 / (44 times 0.2) approx 22.73%. $

  Le repère moyen vaut $1 / 45 approx 2.22%$. A contribue légèrement plus que
  la moyenne au premier axe, tandis que B porte près du quart de l'inertie
  du second. Pourtant, A et B sont à la même distance du centre : leur
  distance au carré vaut $2$. La différence vient de l'inertie totale des
  axes, beaucoup plus faible sur $Y_2$. Les contributions de A à $Y_2$ et de
  B à $Y_1$ sont nulles.
]

#definition(title: [Qualité de représentation d'un individu])[
  Notons $d_i^2 = norm(z_i)^2$ le carré de la distance de l'individu au centre, dans les données utilisées pour l'ACP. L'orthonormalité du repère principal donne $d_i^2 = sum_(k=1)^p y_(i k)^2$. Si $d_i > 0$, la qualité sur l'axe $k$ est :

  $ cos^2_(i k) = y_(i k)^2 / d_i^2
    = y_(i k)^2 / (sum_(ell=1)^p y_(i ell)^2). $
]

Ce rapport est le cosinus carré de l'angle entre le vecteur $z_i$ et l'axe
$k$ : sa projection sur cet axe a pour longueur $abs(y_(i k))$. Il est compris
entre $0$ et $1$. Une valeur proche de $1$ signifie que l'axe restitue presque
tout l'écart de cet individu au centre; une valeur proche de $0$ signifie que
cet écart se situe surtout dans d'autres directions.

Pour un individu fixé, les cosinus carrés sur les $p$ axes totalisent $1$.
Pour un plan, on additionne ceux des deux axes affichés. Plus généralement,
la qualité de représentation sur les $q$ premières composantes est :

$ Q_i (q) = sum_(k=1)^q cos^2_(i k)
  = (sum_(k=1)^q y_(i k)^2) / (sum_(k=1)^p y_(i k)^2). $

La part $1 - Q_i (q)$ est la fraction de sa distance au carré perdue par la
projection. L'erreur de reconstruction vérifie
$norm(z_i - hat(z)_i)^2 = d_i^2 (1 - Q_i (q))$.
Pour un individu exactement au centre, $d_i = 0$. Ces rapports ne sont pas
définis, même si sa reconstruction est exacte.

#example[
  Pour A et B, $d_A^2 = d_B^2 = 2$. Leurs qualités de représentation se lisent
  directement à partir des scores :

  #table(
    columns: (1fr, 1fr, 1fr, 1.5fr),
    align: center,
    table.header([*Profil*], [*Sur $Y_1$*], [*Sur $Y_2$*], [*Plan $(Y_1, Y_2)$*]),
    [A], [$100%$], [$0%$], [$100%$],
    [B], [$0%$], [$100%$], [$100%$],
    [C], [Non défini], [Non défini], [Non défini],
  )

  Le premier axe représente parfaitement A, mais perd tout l'écart de B au
  centre. Ainsi, les $90%$ de variance globale conservés par $Y_1$ ne donnent
  pas la qualité de représentation de chaque étudiant. Dans le plan complet,
  A et B sont tous deux parfaitement représentés. Pour C, qui est au centre,
  le cosinus carré n'est pas défini : le rapport serait $0 / 0$.
]

*Pourquoi les deux indicateurs peuvent différer ?* Pour un individu non situé
au centre, les deux formules sont reliées par :

$ ctr_(i k) = d_i^2 / ((n - 1) lambda_k) cos^2_(i k). $

À qualité égale sur un même axe, un individu plus éloigné du centre contribue
donc davantage. Un point proche du centre peut être très bien représenté
tout en apportant peu d'inertie à l'axe. Inversement, un point éloigné peut
contribuer fortement à un axe tout en conservant une grande partie de son
profil dans d'autres directions.

#example[
  Dans une autre ACP à trois variables, supposons que la somme des scores
  au carré sur le premier axe vaille $100$. Un individu de scores $(1, 0, 0)$
  contribue à hauteur de $1 / 100 = 1%$ à cet axe, tout en y étant représenté
  à $100%$.

  Un second individu de scores $(3, 4, 0)$ contribue à hauteur de
  $9 / 100 = 9%$, mais sa qualité sur cet axe vaut seulement
  $9 / (9 + 16) = 36%$. Il contribue neuf fois plus que le premier, tout en
  étant moins bien représenté. Le plan $(Y_1, Y_2)$ restitue en revanche
  entièrement les deux profils.
]

*Contribution et qualité de représentation d'une variable.* Dans une ACP
centrée réduite, chaque variable $Z_j$ a une variance égale à $1$. En notant
$rho_(j k) = Corr(Z_j, Y_k)$, sa qualité de représentation sur l'axe $k$
est $rho_(j k)^2$. Sur le plan $(Y_1, Y_2)$, elle vaut
$rho_(j 1)^2 + rho_(j 2)^2$, le carré de la longueur de sa flèche dans le cercle
des corrélations.

La relation $rho_(j k) = sqrt(lambda_k) alpha_(j k)$ donne
$sum_(j=1)^p rho_(j k)^2 = lambda_k$, puisque le vecteur $alpha_k$ est unitaire.
La contribution de la variable $j$ à cet axe, notée ici
$ctr^("var")_(j k)$ pour la distinguer de celle d'un individu, est donc :

$ ctr^("var")_(j k) = rho_(j k)^2 / lambda_k = alpha_(j k)^2. $

Sur un axe fixé, les contributions des $p$ variables totalisent $1$ et donc le repère
moyen est $1 / p$. La qualité indique quelle part de la variation de la
variable est conservée, tandis que la contribution compare son rôle à celui
des autres variables dans cet axe.

#example[
  Pour chacun des deux examens, les coefficients au carré valent $1 / 2$
  sur les deux axes. En revanche, les corrélations au carré valent $0.9$
  sur $Y_1$ et $0.1$ sur $Y_2$. Pour chacune des variables $Z_1$ et $Z_2$ :

  #table(
    columns: (2fr, 1fr, 1fr),
    align: (left, center, center),
    table.header([*Indicateur*], [*Axe $Y_1$*], [*Axe $Y_2$*]),
    [Contribution], [$50%$], [$50%$],
    [Qualité de représentation], [$90%$], [$10%$],
  )

  Les deux notes participent à parts égales à la construction de chaque axe.
  Cela ne signifie pas que chaque axe restitue la moitié de leur variation :
  le second n'en conserve que $10%$. Une contribution de $50%$ à un axe de
  faible variance peut donc coexister avec une faible qualité sur cet axe.
  Dans le plan complet, la qualité de chaque variable vaut $90% + 10% = 100%$.
]

*Utilisation pour l'interprétation.* On repère d'abord les individus et les variables qui contribuent le plus à un axe, puis on vérifie leur qualité de représentation sur les axes que l'on souhaite commenter. Les repères $1 / n$ et $1 / p$ servent à comparer les contributions à la contribution moyenne. Ce ne sont cependant pas des seuils de qualité de représentation. Les contributions se lisent axe par axe, tandis que les cosinus carrés s'additionnent sur les axes d'un plan pour évaluer sa qualité.

Enfin, ces deux indicateurs utilisent des carrés : ils ne donnent pas le sens
des oppositions. Il faut revenir aux signes des scores et des corrélations
pour décrire les profils et nommer les axes.

=== Pratique de l'ACP

Une ACP demande de préciser la question étudiée, de justifier la préparation des données et de relier les résultats numériques au sens des variables. Une démarche pratique peut suivre les étapes suivantes :

1. *Définir l'analyse.* Préciser ce que représente une ligne et sélectionner les variables quantitatives qui décrivent le phénomène étudié. Un identifiant numérique n'est pas une mesure à inclure. Une catégorie connue peut servir à grouper les points après le calcul, sans participer à la construction des axes. Elle est alors une information supplémentaire.
2. *Examiner et préparer les données.* Vérifier les unités, les distributions, les valeurs manquantes, les variables constantes et les observations extrêmes. L'ACP usuelle exige une matrice numérique complète. Ainsi, une exclusion ou une imputation doit être justifiée et documentée. Une valeur extrême peut être une erreur de saisie ou une observation réelle intéressante. Elle ne doit donc pas être supprimée automatiquement.
3. *Choisir la géométrie.* Centrer les variables et décider si elles doivent être réduites. La réduction donne à chacune une variance initiale égale à $1$. Sans réduction, les variables les plus dispersées pèsent davantage. Des unités identiques ne suffisent donc pas à rendre les deux choix équivalents. Conserver les moyennes et les écarts-types utilisés.
4. *Calculer et retenir les composantes.* Obtenir les valeurs propres, les directions et les scores, puis choisir le nombre $q$ de composantes en combinant variance cumulée, éboulis et interprétabilité. Distinguer le nombre de composantes conservées des deux axes affichés sur chaque figure.
5. *Interpréter les résultats.* Examiner d'abord les corrélations et les contributions des variables pour donner un sens aux axes. Décrire ensuite les individus à partir de leurs scores, en vérifiant leurs cosinus carrés. Un pourcentage élevé de variance globale ne dispense pas de cette vérification individuelle.
6. *Vérifier et restituer.* Consulter les axes omis et les observations très
   contributives. Si plusieurs préparations sont raisonnables, comparer leurs
   résultats. Le compte rendu doit indiquer les données utilisées, la
   préparation, le choix de $q$, la variance conservée et les principales
   interprétations, avec leurs limites.

==== Étude de cas : Palmer Penguins

Le jeu `penguins` du projet `palmerpenguins` #footnote("https://allisonhorst.github.io/palmerpenguins/") contient $344$ observations de manchots des espèces `Adelie`, `Chinstrap` et `Gentoo`, collectées dans l'archipel Palmer, en Antarctique, entre 2007 et 2009. Les données proviennent de Kristen Gorman et du programme Palmer Station LTER.

On utilise les quatre mesures `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g`, en conservant leurs noms originaux. Les trois premières sont en millimètres et la dernière en grammes. Le dictionnaire des variables #footnote("https://allisonhorst.github.io/palmerpenguins/reference/penguins.html") décrit aussi `species`, `island`, `sex` et `year`.

#example[
  Une question possible est : peut-on résumer les différences morphologiques entre manchots par quelques composantes, et comment les espèces se répartissent-elles dans les plans obtenus ? Seules les quatre variables quantitatives entrent dans l'ACP. La variable `species` sert à colorer les points après le calcul. Les variables `island`, `sex` et `year` restent également hors de la construction des axes : même si `year` est numérique, ce n'est pas une mesure morphologique.
]

*Préparation des mesures.* Deux observations sont incomplètes sur les quatre mesures retenues : les lignes $4$ et $272$, en numérotant les lignes de données du fichier à partir de $1$. Pour cet exemple, on les exclut sans imputation et on conserve $n = 342$ observations : $151$ `Adelie`, $68$ `Chinstrap` et $123$ `Gentoo`.

Le filtrage porte uniquement sur les variables utilisées dans l'ACP. Neuf des observations conservées ont une valeur manquante pour `sex`, mais cela n'empêche pas de calculer leurs scores. Une suppression des lignes incomplètes sur toutes les colonnes réduirait inutilement l'échantillon à $333$ individus pour la question étudiée ici.

On choisit une ACP centrée réduite, car les unités et les dispersions diffèrent fortement. Sur les $342$ observations, les écarts-types de `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g` valent respectivement environ $5.46$, $1.97$, $14.06$ et $801.95$, dans leurs unités propres. Les moyennes et les écarts-types sont calculés sur l'ensemble des observations conservées. On ne centre pas séparément chaque espèce, afin de conserver leurs écarts de moyennes. Les variables standardisées $Z_1, Z_2, Z_3, Z_4$ suivent l'ordre des quatre noms indiqué ci-dessus.

*Choix du nombre de composantes.* Les calculs sur ces données donnent les
résultats suivants :

#table(
  columns: (1fr, 1.2fr, 1.4fr, 1.4fr),
  align: center,
  table.header([*Rang $k$*], [*$lambda_k$*], [*Variance $r_k$*], [*Cumul $R_k$*]),
  [$1$], [$2.7538$], [$68.84%$], [$68.84%$],
  [$2$], [$0.7725$], [$19.31%$], [$88.16%$],
  [$3$], [$0.3652$], [$9.13%$], [$97.29%$],
  [$4$], [$0.1085$], [$2.71%$], [$100%$],
)

Les valeurs propres totalisent $4$, l'inertie des quatre variables réduites.
Un seuil de variance cumulée de $95%$ conduit à retenir $q = 3$, avec
$R_3 approx 97.29%$. Le plan $(Y_1, Y_2)$ reste utile pour visualiser les
individus, mais il ne conserve que $88.16%$ de la variance. Les $9.13%$ portés
par le troisième axe ne sont pas visibles dans ce plan.

La règle stricte de Kaiser conduirait à $q = 1$ et celle de Jolliffe à
$q = 2$. Le deuxième axe apporte pourtant $19.31%$ de variance et le troisième
$9.13%$. Le choix dépend donc de l'objectif : deux axes pour un premier
graphique, trois composantes pour dépasser le seuil de $95%$ retenu ici.

*Interprétation des axes et des individus.* On oriente le premier axe vers
les valeurs élevées de `flipper_length_mm` et le second vers les valeurs
élevées de `bill_depth_mm`. Les corrélations des variables avec ces axes et
leur qualité de représentation dans le plan $(Y_1, Y_2)$ sont :

#table(
  columns: (2.3fr, 1fr, 1fr, 1.25fr),
  align: (left, center, center, center),
  table.header([*Variable*], [*$rho_(j 1)$*], [*$rho_(j 2)$*], [*Qualité du plan*]),
  [`bill_length_mm`], [$0.755$], [$0.525$], [$84.61%$],
  [`bill_depth_mm`], [$-0.664$], [$0.701$], [$93.30%$],
  [`flipper_length_mm`], [$0.956$], [$0.002$], [$91.37%$],
  [`body_mass_g`], [$0.910$], [$0.074$], [$83.35%$],
)

Le premier axe associe des valeurs élevées de `flipper_length_mm`,
`body_mass_g` et `bill_length_mm` à des valeurs plus faibles de `bill_depth_mm`.
Les variables `flipper_length_mm` et `body_mass_g` contribuent ensemble à
environ $63.25%$ de cet axe. Il faut donc commenter cette combinaison de
mesures, plutôt que supposer que toutes augmentent dans le même sens.

Le second axe est principalement construit par `bill_depth_mm` et
`bill_length_mm`, dont les contributions valent respectivement $63.64%$ et
$35.64%$. Pour `bill_depth_mm`, la qualité sur cet axe seul vaut environ
$49.17%$. La contribution de $63.64%$ décrit son rôle dans l'axe, tandis que
les $49.17%$ décrivent la part de sa propre variation conservée par cet axe.

#figure(
  image("../figures/acp_palmerpenguins.svg", width: 100%,
    alt: "ACP centrée réduite de 342 observations Palmer Penguins. À gauche, "
      + "les scores sur Y1 et Y2, qui expliquent 68,84 et 19,31 pour cent "
      + "de la variance, colorés selon species. Gentoo se situe surtout à "
      + "droite; Adelie et Chinstrap se recouvrent en partie. L'individu 327 "
      + "est entouré près du centre. À droite, le cercle des corrélations "
      + "affiche bill_length_mm, bill_depth_mm, flipper_length_mm et body_mass_g."),
  caption: [ACP de Palmer Penguins sur les quatre mesures complètes. Les
    couleurs et les formes indiquent `species`, ajoutée après le calcul.
    Le premier plan conserve $88.16%$ de la variance; les trois composantes
    retenues en conservent $97.29%$. L'individu 327 illustre une faible
    qualité de représentation dans le premier plan.],
) <fig-acp-palmerpenguins>

Les `Gentoo` se situent surtout du côté positif de $Y_1$, associé notamment
à de grandes valeurs de `flipper_length_mm` et de `body_mass_g`. Les
`Chinstrap` ont en moyenne des scores plus élevés sur $Y_2$ que les `Adelie`,
mais leurs nuages se recouvrent en partie. Cette structure apparaît sans
avoir fourni `species` à l'ACP. Elle décrit l'échantillon et ne mesure pas
la précision d'un classificateur sur de nouveaux individus.

*Vérification de la représentation.* Les qualités des variables dans le
premier plan vont de $83.35%$ à $93.30%$. Leurs directions donnent donc une
lecture utile de leurs relations, avec une part de variation encore omise.
Les qualités individuelles peuvent être beaucoup plus faibles.

#example[
  L'individu de la ligne $327$ du fichier original est un `Chinstrap`, de
  mesures $(48.1, 16.4, 199, 3325)$ dans l'ordre des quatre variables et
  dans leurs unités respectives. Ses scores sont environ
  $(-0.177, 0.061, 1.336, 0.352)$.

  On obtient $Q_327 (2) approx 1.81%$. Son point est proche du centre dans le premier plan, alors que son écart au centre se situe surtout sur $Y_3$. Le plan $(Y_1, Y_3)$ permet donc de mieux décrire ce profil. Cette faible qualité relative ne signifie pas que l'observation est aberrante.
]

Le choix de la réduction des données a ici un effet particulièrement marqué. Sans réduction, `body_mass_g` représente environ $99.96%$ de l'inertie initiale avec les unités du fichier. Le premier axe d'une ACP seulement centrée conserve alors environ $99.99%$ de la variance. Ce pourcentage très élevé reflète surtout le poids numérique de la masse exprimée en grammes. Il ne signifie pas que les quatre mesures sont toutes bien résumées. La réduction permet d'accorder la même variance initiale à chaque variable.


#example[
  Un compte rendu possible est : « Nous réalisons une ACP centrée réduite de `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g` sur les $342$ observations complètes du jeu de données Palmer Penguins. Trois composantes conservent $97.29%$ de la variance. Le premier plan en représente $88.16%$ et distingue notamment les `Gentoo` selon $Y_1$. Le deuxième axe décrit surtout la variation conjointe de `bill_depth_mm` et de `bill_length_mm`. Certains individus, comme celui de la ligne 327, nécessitent l'examen du troisième axe. »
]

=== Limites

L'ACP fournit une représentation optimale pour un critère précis : parmi les projections orthogonales de dimension $q$, elle minimise l'erreur quadratique de reconstruction des données. Cette propriété ne garantit ni que la structure étudiée soit linéaire, ni que la variance conservée corresponde à l'information recherchée. Ses limites concernent donc le choix du critère, la préparation des données et l'interprétation des résultats.

*Une réduction linéaire.* Les composantes sont des combinaisons linéaires des
variables. Elles décrivent un sous-espace affine dans l'espace original,
après réintroduction de la moyenne. Si le nuage suit une courbe ou une surface
courbe, il peut être nécessaire de conserver plusieurs axes, même lorsque
la position des observations dépend de peu de paramètres.

#example[
  Considérons une distribution uniforme sur le cercle unité. Une observation
  a pour coordonnées $(cos(theta), sin(theta))$. Sa position peut être décrite par
  un seul angle $theta$, mais toute projection sur une droite confond des
  positions distinctes du cercle. Les deux valeurs propres sont égales :
  une seule composante conserve $50%$ de la variance, et il faut les deux
  pour reconstruire exactement les points. Une dimension intrinsèque faible
  ne garantit donc pas qu'une réduction linéaire de même dimension soit
  satisfaisante.
]

Il faut examiner la forme du nuage et les erreurs de reconstruction pour
repérer cette situation. Une transformation des variables peut rendre une
relation plus linéaire, mais elle change aussi la géométrie et le sens de
l'analyse.

*La variance n'est pas une mesure universelle d'information.* L'ACP ne reçoit
aucune variable réponse. Une direction de forte variance peut traduire un
effet secondaire, une différence de protocole de mesure ou du bruit. À
l'inverse, une composante de faible variance peut porter une opposition
importante ou être utile pour prédire une cible. La proportion $R_q$ mesure la
variance conservée des variables analysées, mais il ne mesure pas une performance
prédictive.

#example[
  Dans un modèle théorique, supposons que deux composantes centrées et
  indépendantes $Y_1$ et $Y_2$ aient des variances respectives de $9$ et $1$.
  La cible à prédire est $W = Y_2$. Conserver seulement $Y_1$ préserve $90%$
  de la variance, mais n'apporte aucune information sur les variations de
  $W$, puisque les deux composantes sont indépendantes. La composante
  supprimée aurait au contraire permis de prédire exactement la cible.
]

Pour un objectif prédictif, le nombre de composantes doit donc être évalué
avec le modèle qui les utilise. Pour une analyse descriptive, il faut examiner
le contenu des axes de faible variance avant de les écarter.

*Un bon résumé global peut masquer certains profils.* L'erreur minimisée est
une somme sur tous les individus. L'ACP ne garantit pas une même qualité de
représentation pour chacun, et elle ne cherche pas à préserver chaque distance
ou chaque voisinage. Des observations proches dans un plan peuvent différer
fortement sur les axes omis.


*Une dépendance au choix des variables et à leur échelle.* Sans réduction, les variables les plus dispersées dominent l'inertie. Dans l'exemple `palmerpenguins`, la masse `body_mass_g` exprimée en grammes détermine presque toute l'inertie de l'ACP seulement centrée. La réduction corrige cet effet d'unité, mais donner la même variance initiale à toutes les variables reste un choix. Une mesure peu fiable peut alors peser autant qu'une mesure précise.

La standardisation ne corrige pas non plus le déséquilibre entre des groupes
de variables. Inclure plusieurs mesures presque identiques d'un même aspect
lui donne davantage de poids dans les distances, même si chaque colonne est
réduite. Il faut donc justifier la sélection des variables, leur éventuelle
pondération et les transformations appliquées. Les axes décrivent le tableau
ainsi construit, et non une structure indépendante de ces choix.

*Une sensibilité aux observations extrêmes.* La covariance et l'inertie
utilisent des écarts au carré : à centre et axe fixés, un score dix fois plus
grand apporte un terme cent fois plus grand à la somme des carrés. Quelques
observations éloignées peuvent ainsi modifier fortement les directions
principales. Le centrage et la réduction usuels restent sensibles à ces
observations, car leurs moyennes et leurs écarts-types le sont eux-mêmes.

Il faut examiner les individus très contributifs et revenir aux mesures
initiales. Une analyse de sensibilité peut comparer les axes avec et sans
une observation suspecte, en explicitant cette comparaison. Une contribution
élevée ne suffit cependant pas à justifier sa suppression. En effet, l'observation
peut décrire une partie réelle du phénomène étudié.

*Des axes estimés sur un échantillon.* Les directions dépendent de la matrice
de covariance empirique. Elles peuvent varier d'un échantillon à l'autre,
notamment lorsque l'effectif est faible par rapport au nombre de variables
ou lorsque plusieurs valeurs propres sont proches. Si $p >= n$, le rang des
données centrées est au plus $n - 1$ : les valeurs propres nulles qui en
résultent ne prouvent pas que la population possède la même faible dimension.

#example[
  Si $lambda_1$ et $lambda_2$ sont presque égales, une petite modification
  des données peut faire tourner les deux premiers axes et changer leurs
  coefficients. Si ces deux valeurs propres sont bien séparées de
  $lambda_3$, le plan qu'ils engendrent peut pourtant rester stable. Il est
  alors plus solide d'interpréter le plan commun que d'attribuer un sens
  très précis à chacun de ses axes.
]

On peut examiner cette stabilité en répétant l'ACP sur des rééchantillonnages
et en comparant les sous-espaces obtenus. Une simple inversion du signe d'un
axe ne constitue pas une instabilité géométrique : elle conserve sa direction
et les distances.

*Des contraintes sur les données analysées.* L'ACP usuelle travaille sur des
variables quantitatives et une matrice pleine. Attribuer les codes $1$, $2$
et $3$ aux modalités de `species` créerait des distances arbitraires entre
elles. Ainsi, ces codes ne deviennent pas des mesures quantitatives pertinentes.

Les valeurs manquantes demandent également un traitement explicite. Supprimer
des lignes peut modifier la population représentée si les observations
incomplètes ont des caractéristiques particulières. Remplacer les valeurs
manquantes par la moyenne réduit artificiellement la dispersion de la variable
et peut fausser les corrélations. Le résultat doit donc être interprété en tenant
compte de la méthode retenue et de l'ampleur des données manquantes.

*Une interprétation descriptive, à valider pour d'autres usages.* Les axes sont des combinaisons mathématiques de variables. Un nom comme « taille » ou « niveau général » est une interprétation à étayer par leurs coefficients et leurs corrélations. Cela ne démontre pas l'existence d'un mécanisme causal. De même, des groupes visibles dans un plan ne constituent pas, à eux seuls, une classification validée. La non-corrélation des composantes n'implique pas leur indépendance. L'ACP n'exige d'ailleurs pas que les données suivent une loi normale.

Lorsque les composantes servent de variables prédictives, le centrage, la
réduction, une éventuelle imputation et les axes doivent être ajustés
uniquement sur les données d'entraînement. Les mêmes paramètres sont ensuite
appliqués aux observations de validation ou de test. En validation croisée,
il faut répéter cette préparation dans chaque pli d'entraînement, y compris
pour comparer plusieurs valeurs de $q$. Calculer d'abord l'ACP sur tout le
jeu transmettrait de l'information sur les données de validation aux axes,
même sans utiliser la variable réponse.

Enfin, projeter de nouvelles observations suppose que les mêmes variables
soient mesurées de façon comparable. Une modification des instruments, des
conditions de collecte ou de la population peut rendre les axes appris
moins représentatifs. Une bonne reconstruction sur l'échantillon initial
ne garantit donc pas la même qualité sur de nouvelles données.

== L'analyse factorielle des correspondances

=== Tableau de contingence et profils

L'analyse factorielle des correspondances (AFC) s'applique à un tableau de contingence croisant deux variables qualitatives. Elle cherche à résumer les associations entre leurs modalités et représente les modalités de ligne et de colonne sur des axes communs. Les points d'un plan d'AFC sont donc des catégories (ou modalités), et non les individus qui ont servi à construire le tableau.

#definition(title: [Tableau de contingence et marges])[
  Considérons un tableau $N = (n_(i j))$ comportant $I$ lignes et $J$ colonnes.
  La cellule $n_(i j)$ compte les individus qui possèdent simultanément la modalité
  $i$ de la première variable et la modalité $j$ de la seconde. On note les
  effectifs marginaux et l'effectif total

  $
    n_(i +) = sum_(j=1)^J n_(i j), quad
    n_(+ j) = sum_(i=1)^I n_(i j), quad
    n = sum_(i=1)^I sum_(j=1)^J n_(i j).
  $
]

#example(title: [Programme et type d'admission])[
  Le tableau suivant décrit $200$ étudiants selon leur
  programme et leur type d'admission. Chaque étudiant appartient à un seul
  programme et à une seule catégorie d'admission.

  #table(
    columns: (1.3fr, 1fr, 1.1fr, 1.5fr, 0.8fr),
    align: center,
    table.header([*Programme*], [*Directe*], [*Passerelle*],
      [*Reprise d'études*], [*Total*]),
    [Sciences], [60], [25], [15], [100],
    [Lettres], [10], [35], [15], [60],
    [Gestion], [10], [10], [20], [40],
    [*Total*], [*80*], [*70*], [*50*], [*200*],
  )
]

Une comparaison des seuls effectifs serait dominée par les programmes les plus
nombreux. L'AFC compare plutôt les *profils*, i.e. les distributions
conditionnelles. Le profil-ligne du programme $i$ est le vecteur dont les
coordonnées sont

$ a_(i j) = n_(i j) / n_(i +), quad j = 1, ..., J, quad "et" quad sum_(j=1)^J a_(i j) = 1. $

Ainsi, le profil de Sciences est $(0.60, 0.25, 0.15)$ : parmi les étudiants de
Sciences, 60~% ont une admission directe, 25~% passent par une passerelle et
15~% sont en reprise d'études. Deux programmes ayant ces mêmes proportions ont
le même profil, même si l'un accueille deux fois plus d'étudiants que l'autre.

Symétriquement, le profil-colonne de l'admission $j$ a pour coordonnées
$ b_(i j) = n_(i j) / n_(+ j),quad i = 1, ..., I, quad "et" quad sum_(i=1)^I b_(i j) = 1. $
Parmi les $80$ admissions directes, $60$ concernent Sciences. Le profil de Admission directe est $(0.75, 0.125, 0.125)$. Le dénominateur change donc selon la
question : répartition des admissions dans un programme, ou répartition des
programmes pour un type d'admission donné.

#definition(title: [Fréquences relatives et masses])[
  On introduit les fréquences relatives et les masses des modalités :

  $
    p_(i j) = n_(i j) / n, quad
    r_i = n_(i +) / n, quad c_j = n_(+ j) / n, quad i = 1, ..., I, quad j = 1, ..., J.
  $
]

Les masses des programmes sont $r = (0.50, 0.30, 0.20)^top$ et celles des
admissions sont $c = (0.40, 0.35, 0.25)^top$. Elles pondèrent les points dans
l'analyse : comparer les profils ne revient pas à donner le même poids à
toutes les catégories. On suppose les masses strictement positives. Une ligne
ou une colonne entièrement nulle doit donc être retirée.

Le profil moyen des lignes est $c$, car $sum_(i=1)^I r_i a_(i j) = c_j$.
De même, le profil moyen des colonnes est $r$, car $sum_(j=1)^J c_j b_(i j) = r_i$.
Ces moyennes sont pondérées par les masses, et non calculées en donnant le même poids à chaque profil.

#figure(
  image("../figures/afc_profils.svg", width: 100%,
    alt: "Profils d'admission de trois programmes fictifs. Sciences compte "
      + "60 pour cent d'admissions directes, Lettres 58,3 pour cent de "
      + "passerelles et Gestion 50 pour cent de reprises d'études. Le profil "
      + "d'ensemble est de 40, 35 et 25 pour cent respectivement."),
  caption: [Profils-lignes et profil moyen pondéré. Chaque barre représente
    100~% des étudiants du groupe concerné. L'AFC étudie les différences de
    composition entre ces barres.],
)

=== Indépendance, distance du chi-deux et inertie

*Situation de référence.* Si les deux variables considérées étaient indépendantes, connaître l'une ne modifierait pas la distribution de l'autre. Ainsi, dans l'exemple précédent, connaître le programme ne modifierait pas la distribution des types d'admissions. Tous les profils-lignes seraient égaux à $c$, et tous les profils-colonnes à $r$. Le tableau de fréquences correspondant est $r c^top$. L'effectif attendu dans la cellule $(i,j)$ est donc

$ e_(i j) = n r_i c_j = (n_(i +) n_(+ j)) / n. $

Pour Sciences et l'admission directe, on attendrait $(100 times 80) / 200 = 40$ étudiants, contre $60$ observés. Cette combinaison semble surreprésentée. En effet, son effectif vaut $1.5$ fois l'effectif attendu. À l'inverse, Sciences et la reprise d'études comptent $15$ étudiants, contre $25$ attendus. Une association se juge ainsi par rapport aux marges du tableau, et non à la seule taille d'un effectif.

#definition(title: [Distance du chi-deux entre profils])[
  L'AFC utilise la distance du $chi^2$ pour comparer des profils. Pour deux profils-lignes $i$ et $ell$, elle est définie par

  $ d_(chi^2)^2(i, ell) = sum_(j=1)^J (a_(i j) - a_(ell j))^2 / c_j. $

  Pour deux profils-colonnes $j$ et $h$, la définition symétrique est

  $ d_(chi^2)^2(j, h) = sum_(i=1)^I (b_(i j) - b_(i h))^2 / r_i. $
]

La pondération tient compte de la fréquence de chaque modalité. Un même écart
de proportion pèse davantage dans une colonne rare que dans une colonne très
fréquente. Par exemple, un écart de $0.10$ contribue pour $0.10^2 / 0.25 = 0.04$
dans la colonne Reprise d'études, contre $0.10^2 / 0.40 = 0.025$ dans la colonne
Directe. Ce choix de distance donne un sens relatif aux écarts, mais peut aussi
amplifier les fluctuations de catégories rares.

#definition(title: [Inertie totale en AFC])[
  Comme en ACP, l'inertie est une
  dispersion autour du centre. Ici, les points sont les profils, la distance est
  celle du $chi^2$ et les poids sont les masses. En notant

  $
    d_i^2 = sum_(j=1)^J (a_(i j) - c_j)^2 / c_j, quad
    delta_j^2 = sum_(i=1)^I (b_(i j) - r_i)^2 / r_i,
  $

  l'inertie totale s'écrit

  $
    inertia = sum_(i=1)^I r_i d_i^2
           = sum_(j=1)^J c_j delta_j^2
           = sum_(i=1)^I sum_(j=1)^J
             (p_(i j) - r_i c_j)^2 / (r_i c_j).
  $
]

Les nuages de lignes et de colonnes ont la même inertie : il s'agit de deux
descriptions de la même association, et non de deux inerties à additionner.
On retrouve la statistique de Pearson du test d'indépendance :

$
  chi^2 = sum_(i=1)^I sum_(j=1)^J (n_(i j) - e_(i j))^2 / e_(i j),
  quad "et" quad inertia = chi^2 / n.
$

Dans l'exemple, $chi^2 = 47.75$ et $inertia = 47.75 / 200 = 0.23875$.
Une inertie nulle correspond à une indépendance exacte dans le tableau observé :
tous les profils de chaque nuage coïncident avec leur centre. Plus l'inertie
est grande, plus les profils s'en écartent, pour cette géométrie.

#remark[
  L'AFC décrit la structure du tableau. Elle ne constitue pas à elle seule un
  test d'indépendance. Multiplier tous les effectifs par deux ne change ni les
  profils, ni l'inertie, ni la carte, mais double $chi^2$. L'interprétation d'une
  valeur $p$ dépend en outre du plan d'échantillonnage et des conditions du test.
]

=== Construction des axes factoriels

L'AFC peut se voir comme une ACP des profils, avec leurs masses et la distance du $chi^2$. Sa construction repose sur la décomposition en valeurs singulières de la matrice des écarts à l'indépendance. Posons $P = N/n$, $D_r = diag(r_1, dots, r_I)$ et $D_c = diag(c_1, dots, c_J)$, puis

$
  S = D_r^(-1/2) (P - r c^top) D_c^(-1/2), quad "avec" quad S_(i j) = (p_(i j) - r_i c_j) / sqrt(r_i c_j).
$

La soustraction de $r c^top$ retire la situation d'indépendance. Les facteurs
diagonaux appliquent les pondérations liées aux marges. La somme des carrés des
éléments de $S$ est précisément l'inertie $inertia$.

Pour un tableau qui n'est pas exactement indépendant, la décomposition en valeurs singulières de $S$ est

$
  S = U D V^top, quad D = diag(sigma_1, dots, sigma_(r_S)),
  quad sigma_1 >= dots >= sigma_(r_S) > 0,
$

où $U^top U = V^top V = I_(r_S)$ et $I_(r_S)$ est la matrice identité d'ordre $r_S$.
Le nombre d'axes non triviaux vérifie $r_S = rang(S) <= min(I-1, J-1)$.
Les contraintes sur les marges expliquent la perte d'une dimension de chaque
côté. Un tableau à deux lignes ne peut donc fournir qu'un seul axe non trivial,
même s'il possède beaucoup de colonnes.

Les *coordonnées principales* des lignes et des colonnes sont respectivement
les lignes des matrices#footnote[
  Pour les conventions de coordonnées et leur calcul, voir
  #link("https://doi.org/10.18637/jss.v020.i03")[Nenadić et Greenacre (2007),
  _Correspondence Analysis in R, with Two- and Three-dimensional Graphics :
  The ca Package_].
] :

$ F = D_r^(-1/2) U D, quad G = D_c^(-1/2) V D. $

Ainsi, $F_(i k)$ est la coordonnée du profil-ligne $i$ sur l'axe $k$, et
$G_(j k)$ celle du profil-colonne $j$. Dans l'espace complet des $r_S$ axes, les
distances euclidiennes entre lignes de $F$ reproduisent exactement les distances
du chi-deux entre profils-lignes. Il en va de même pour $G$ et les
profils-colonnes. En ne conservant que $q$ axes, on projette les points : les
distances peuvent diminuer, ce qui impose de contrôler la qualité de
représentation avant d'interpréter une proximité.

L'inertie de l'axe $k$ est la valeur propre $lambda_k = sigma_k^2$. Elle vérifie

$
  sum_(i=1)^I r_i F_(i k)^2
  = sum_(j=1)^J c_j G_(j k)^2
  = lambda_k, quad "et" quad
  sum_(k=1)^(r_S) lambda_k = inertia.
$

Le premier axe conserve le plus d'inertie possible ; les suivants résument
successivement l'inertie restante dans des directions orthogonales. Pour $q$
axes retenus, la proportion cumulée est

$ R_q = (sum_(k=1)^q lambda_k) / inertia, quad 1 <= q <= r_S. $

Le choix de $q$ repose sur la décroissance des valeurs propres, l'inertie cumulée
et l'interprétation des axes. La règle de Kaiser de l'ACP normée ne se transpose
pas telle quelle : le seuil $lambda_k > 1$ n'est pas une référence adaptée à
l'AFC.

#example[
  Notre tableau $3 times 3$ possède deux axes non triviaux :

  #table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr), align: center,
    table.header([*Axe $k$*], [*Valeur propre*], [*Inertie expliquée*],
      [*Inertie cumulée*]),
    [1], [0,17021], [71,29~%], [71,29~%],
    [2], [0,06854], [28,71~%], [100~%],
  )

  Un seul axe résume la principale opposition, mais laisse de côté 28,71~% de
  l'inertie. Un seuil cumulé de 80~% conduit ici à retenir $q = 2$. Le plan
  conserve alors toute l'inertie parce qu'il contient tous les axes non
  triviaux. Cela ne signifie pas que l'association est parfaite : les
  pourcentages décrivent la part de l'inertie représentée, pas la force absolue
  de la liaison.
]

=== Représentation barycentrique

Les deux nuages sont liés par des relations de transition. Pour les exprimer
comme des barycentres, il faut distinguer les coordonnées principales $F, G$
des coordonnées standard

$ Phi = D_r^(-1/2) U = F D^(-1), quad
  Gamma = D_c^(-1/2) V = G D^(-1). $

Dans les coordonnées standard, l'inertie pondérée de chaque axe vaut $1$ ; dans
les coordonnées principales, elle vaut $lambda_k$. On obtient donc les relations

$ F = D_r^(-1) P Gamma, quad G = D_c^(-1) P^top Phi, $

soit, coordonnée par coordonnée,

$ F_(i k) = sum_(j=1)^J a_(i j) Gamma_(j k), quad
  G_(j k) = sum_(i=1)^I b_(i j) Phi_(i k). $

Comme les coefficients d'un profil sont positifs ou nuls et de somme $1$, une
ligne en coordonnées principales est le barycentre des colonnes en coordonnées
standard, pondéré par son profil-ligne. La relation inverse utilise les profils
colonnes, avec les colonnes en coordonnées principales et les lignes en
coordonnées standard.

#example[
  Sur le premier axe de l'exemple, les coordonnées standard des admissions sont
  environ $1.2243$ pour Directe, $-0.7883$ pour Passerelle et $-0.8553$ pour
  Reprise d'études. Le profil de Sciences donne donc

  $ F_("Sciences", 1)
    approx 0.60 times 1.2243 + 0.25 times (-0.7883) + 0.15 times (-0.8553)
    approx 0.4092. $

  La forte proportion d'admissions directes tire ce programme du côté positif
  de l'axe. Un programme ayant exactement le profil moyen $c$ serait placé à
  l'origine sur tous les axes.
]

Une carte dite symétrique, comme celle ci-dessous, affiche les deux ensembles
en coordonnées principales $F$ et $G$. Dans cette convention, la relation devient

$ F_(i k) = 1 / sigma_k sum_(j=1)^J a_(i j) G_(j k). $

Le facteur $1/sigma_k$ est essentiel : une ligne n'est généralement pas le
barycentre direct des colonnes telles qu'elles sont dessinées sur cette carte.
Une carte asymétrique représentant $F$ et $Gamma$ permet la lecture barycentrique
directe pour les lignes, mais les distances entre colonnes n'y sont plus les
distances du $chi^2$. Il faut donc connaître la convention du graphique fourni
par le logiciel avant d'en interpréter les distances.

=== Lecture du plan factoriel

*Lire les oppositions.* Le premier axe oppose Sciences aux deux autres
programmes et l'admission directe aux deux autres types d'admission. Cela
correspond aux profils : les admissions directes représentent 60~% des
étudiants de Sciences, contre 16,7~% en Lettres et 25~% en Gestion. Le second
axe distingue surtout Gestion et la reprise d'études, en haut, de Lettres et
la passerelle, en bas. La reprise d'études représente 50~% des admissions en
Gestion, contre 25~% dans l'ensemble du tableau ; la passerelle représente
58,3~% des admissions en Lettres, contre 35~% dans l'ensemble.

Le signe d'un axe est arbitraire : inverser simultanément les signes des
coordonnées des lignes et des colonnes ne change ni les distances ni les
associations. Les noms donnés aux axes doivent décrire leurs oppositions,
plutôt que donner un sens intrinsèque aux côtés positif et négatif.

#figure(
  image("../figures/afc_plan.svg", width: 95%,
    alt: "Carte symétrique de l'AFC du tableau fictif. Sciences et Directe sont "
      + "du côté positif du premier axe. Le deuxième axe oppose Gestion et "
      + "Reprise d'études, en haut, à Lettres et Passerelle, en bas. Les deux "
      + "axes expliquent respectivement 71,29 et 28,71 pour cent de l'inertie."),
  caption: [Carte symétrique : programmes et admissions en coordonnées
    principales. Les deux axes représentent toute l'inertie de ce tableau.
    Les distances s'interprètent à l'intérieur de chaque ensemble de points.],
)

*Distinguer les distances.* Deux programmes proches ont des profils d'admission
semblables si les axes affichés les représentent bien. Deux admissions proches
ont des répartitions semblables entre programmes, sous la même réserve. En
revanche, la distance entre un programme et une admission n'est pas une
distance du $chi^2$ entre profils : ces points appartiennent à deux espaces
initiaux différents. La proximité d'un cercle et d'un triangle ne mesure donc
pas directement leur association, même dans un plan qui conserve toute l'inertie.

Pour relier les deux ensembles, on examine leurs positions sur les axes et on
revient aux écarts à l'indépendance. Avec tous les axes, l'identité suivante
exprime précisément ce lien :

$ p_(i j) / (r_i c_j) - 1
  = sum_(k=1)^(r_S) (F_(i k) G_(j k)) / sigma_k. $

Des coordonnées de même signe contribuent à une surreprésentation sur un axe ;
des signes opposés contribuent à une sous-représentation. C'est la somme sur
les axes qui reconstitue l'association. Pour Gestion et Reprise d'études, le
rapport observé/attendu vaut $20/10 = 2$, ce qui confirme leur association
positive dans le tableau.

*Situer l'origine.* Un programme dont le profil est moyen se trouve à
l'origine. Un point éloigné de l'origine dans l'espace complet possède un
profil spécifique. Sur un plan partiel, un point proche du centre peut au
contraire s'écarter du profil moyen sur un axe non affiché. La distance au
centre du graphique ne suffit donc pas à décider qu'une modalité est banale.

=== Contributions et qualité de représentation

Comme en ACP, ces deux diagnostics répondent à des questions différentes.
La *contribution* indique quelles modalités construisent un axe. Pour les
lignes et les colonnes, elle vaut respectivement

$
  ctr_(i k)^r = (r_i F_(i k)^2) / lambda_k, quad
  ctr_(j k)^c = (c_j G_(j k)^2) / lambda_k.
$

Sur chaque axe, les contributions des lignes somment à $1$, et celles des
colonnes somment aussi à $1$. On analyse ces deux ensembles séparément : on
n'additionne pas la contribution d'un programme à celle d'une admission.
Les valeurs $1/I$ et $1/J$ donnent des repères de contribution moyenne, sans
constituer des seuils de significativité.

La *qualité de représentation* mesure la part de la distance d'une modalité
à son profil moyen qui est visible sur l'axe. Elle est donnée par les cosinus
carrés

$
  cos^2_(i k) = F_(i k)^2 / d_i^2, quad
  cos^2_(j k) = G_(j k)^2 / delta_j^2.
$

Pour un plan ou un espace de $q$ axes, on somme ces cosinus carrés sur les axes
retenus. La qualité est comprise entre $0$ et $1$ ; elle vaut $1$ dans l'espace
complet des $r_S$ axes. Pour un profil exactement moyen, la distance au centre est
nulle et ce rapport n'est pas défini.

#example[
  Pour Sciences, $r_i = 0.50$, $F_(i 1) approx 0.40923$ et
  $d_i^2 approx 0.16857$. On obtient

  $ ctr_(i 1)^r
    approx (0.50 times 0.40923^2) / 0.17021 approx 0.492, quad
    cos^2_(i 1) approx 0.40923^2 / 0.16857 approx 0.993. $

  Sciences apporte ainsi 49,2~% de l'inertie du premier axe, tandis que cet
  axe représente 99,3~% de l'écart de Sciences au profil moyen. Le premier
  pourcentage décrit le rôle du programme dans l'axe ; le second décrit ce
  que l'axe montre du programme.
]

Les résultats pour les trois programmes précisent la lecture du plan :

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr, 1fr), align: center,
  table.header([*Programme*], [*Contribution axe 1*], [*Contribution axe 2*],
    [*Qualité axe 1*], [*Qualité axe 2*]),
  [Sciences], [49,2~%], [0,8~%], [99,3~%], [0,7~%],
  [Lettres], [38,9~%], [31,1~%], [75,6~%], [24,4~%],
  [Gestion], [11,9~%], [68,1~%], [30,3~%], [69,7~%],
)

Le premier axe dépend surtout de Sciences et de Lettres ; le second dépend
surtout de Gestion. Bien que l'axe 1 explique 71,29~% de l'inertie totale,
il ne représente que 30,3~% de l'écart du profil de Gestion au profil moyen.
L'inertie expliquée globalement ne garantit donc pas une bonne représentation
de chaque modalité. Du côté des admissions, Directe contribue pour 60,0~% au
premier axe ; Reprise d'études et Passerelle contribuent respectivement pour
56,7~% et 43,2~% au second.

=== Pratique et limites de l'AFC

Une analyse suit la progression suivante :

1. *Construire et vérifier le tableau.* Préciser la population, les catégories
   et le traitement des valeurs manquantes. Examiner les marges et les
   cellules peu remplies. L'AFC s'applique directement aux effectifs : il ne
   faut pas centrer et réduire les colonnes du tableau comme pour une ACP.
2. *Examiner les profils et les écarts à l'indépendance.* Repérer les
   différences de composition et les combinaisons surreprésentées ou
   sous-représentées avant de chercher à nommer des axes.
3. *Choisir le nombre $q$ d'axes.* Examiner les valeurs propres et l'inertie
   cumulée, puis vérifier quelles modalités sont bien représentées. Un plan
   lisible peut laisser de côté une opposition substantielle.
4. *Interpréter conjointement la carte et les diagnostics.* Nommer les axes à
   partir des contributions, vérifier les cosinus carrés et confronter les
   associations proposées aux effectifs attendus et aux profils.

*Projeter un profil supplémentaire.* On peut situer un nouveau programme sans
modifier les axes déjà construits. Si son profil d'admission est
$(a_(ast 1), dots, a_(ast J))$, avec des proportions de somme $1$ sur les mêmes
catégories, sa coordonnée projetée est

$ F_(ast k) = sum_(j=1)^J a_(ast j) Gamma_(j k). $

Le programme est alors supplémentaire : il ne contribue ni aux axes ni à
l'inertie du tableau actif. Par exemple, un programme dont le profil est
$(0.40, 0.35, 0.25)$ est projeté à l'origine. Si l'on souhaite au contraire
qu'il participe à la construction des axes, il faut refaire l'analyse du
tableau augmenté.

*Des modalités rares parfois instables.* La distance du $chi^2$ donne un poids
élevé à certains écarts impliquant de petites valeurs. Quelques observations
peuvent alors déplacer fortement une modalité rare, voire orienter un axe.
Une grande distance à l'origine ne signifie toutefois pas automatiquement une
forte contribution, puisque celle-ci dépend aussi de la masse. Il faut examiner
les effectifs et la stabilité de l'interprétation. Un regroupement de
catégories doit avoir un sens dans le domaine étudié.

*Des zéros à interpréter.* Une cellule nulle n'empêche pas le calcul si ses deux
marges sont positives. Il faut distinguer une combinaison simplement absente
de l'échantillon d'une combinaison impossible par construction. Ces zéros
structurels peuvent organiser la carte et rendre le modèle d'indépendance
usuel peu pertinent. Cependant, une ligne ou une colonne entièrement nulle
n'a ni profil ni distance définis.

*Une analyse dépendante du tableau choisi.* Modifier les catégories, filtrer
une partie de la population ou changer le traitement des valeurs manquantes
modifie les marges et donc la géométrie. La carte décrit les associations dans
le tableau analysé. Elle n'établit pas une relation causale et ne permet pas
de déduire le parcours d'un étudiant particulier. Enfin, les propriétés du
cercle des corrélations de l'ACP ne s'appliquent pas aux angles entre modalités
sur une carte d'AFC.

== L'ACM

=== Plusieurs variables qualitatives

L'analyse des correspondances multiples, ou ACM, généralise l'AFC à plusieurs
variables qualitatives. Elle est particulièrement utile pour les questionnaires
ou les enquêtes comportant plusieurs questions à choix multiples.

Chaque variable est transformée en modalités binaires par codage disjonctif
complet. Si une question possède trois modalités, elle devient trois colonnes
binaires. Un individu reçoit un 1 pour la modalité choisie et 0 pour les autres.

#definition(title: [Tableau de Burt])[
  Le tableau de Burt, obtenu comme produit du tableau disjonctif transposé par le
  tableau disjonctif, croise toutes les modalités entre elles.
]

L'ACM peut être vue comme une AFC appliquée au tableau disjonctif complet ou au tableau de Burt.

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
dimensions. Elle transforme les proximités entre observations en probabilités :
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

#remark[
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
formelle. On l'utilise souvent après une étape de prétraitement : standardisation,
filtrage de variables, ACP préalable ou choix d'une distance adaptée.

Certaines implémentations permettent aussi de projeter de nouvelles observations
dans une carte apprise. Cela rend UMAP plus pratique que t-SNE dans des flux de
données ou dans un protocole où l'on souhaite comparer entraînement et
validation.

== Autoencodeurs

=== Représentation latente

#definition(title: [Autoencodeur])[
  Un autoencodeur est un réseau de neurones entraîné à reconstruire ses entrées.
  Il est composé de deux parties : un encodeur qui transforme l'observation initiale
  en représentation latente de plus faible dimension, puis un décodeur qui tente de
  reconstruire l'observation à partir de cette représentation.
]

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

- TriMap construit la carte à partir de triplets : une observation doit rester
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
variables initiales et à vérifier les conclusions par des mesures simples :
profils moyens, distances, contributions, stabilité des groupes ou performance
sur un jeu de validation.

#exercises[

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
]
