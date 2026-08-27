#import "../styles/notes.typ": definition-box, example, property-box, proof, remark, set-qed-symbol, theorem

#set-qed-symbol[$square$]

= Annexe : Révisions

Les méthodes d'analyse de données reposent sur quelques outils d'algèbre linéaire, de probabilités, de statistiques et de programmation. Cette annexe rassemble les idées à garder actives pendant la lecture des chapitres.

Ces révisions ne sont pas séparées des méthodes. Elles expliquent pourquoi les
algorithmes fonctionnent, ce qu'ils optimisent et dans quelles conditions leurs
résultats sont interprétables.

== Algèbre linéaire

L'algèbre linéaire fournit le bloc de base de l'analyse de données multivariées. Un jeu de données contenant $n$ observations et $p$ variables se représente classiquement par une matrice $X$ de taille $n times p$. Chaque ligne de $X$ décrit une observation et chaque colonne une variable. Les combinaisons de variables, les changements de coordonnées, les projections, les mesures de dispersion et la plupart des manipulations des données peuvent alors s'exprimer par des opérations sur des matrices et des vecteurs.

=== Notations et dimensions

On note $cal(M)_(n,p)(RR)$ l'ensemble des matrices réelles à $n$ lignes et $p$
colonnes, et $cal(M)_n (RR)$ l'ensemble des matrices carrées de taille $n$. Un
vecteur $u in RR^n$ est considéré comme une matrice colonne de taille $n times 1$.
La matrice identité $I_n$ contient des $1$ sur sa diagonale et des $0$ ailleurs.

Si $A in cal(M)_(n,p)(RR)$ et $B in cal(M)_(p,q)(RR)$, le produit $A B$ est défini
et appartient à $cal(M)_(n,q)(RR)$. L'ordre des facteurs est important: en
général, $A B != B A$. La transposée $A^top$ échange les lignes et les colonnes, et
renverse l'ordre d'un produit:

$ (A B)^top = B^top A^top. $

#definition-box(supplement: "Définition")[
Le *produit scalaire* de deux vecteurs $u, v in RR^n$ est
$chevron.l u, v chevron.r = u^top v$. Il détermine la *norme euclidienne*
$norm(u) = sqrt(u^top u)$. Les vecteurs $u$ et $v$ sont *orthogonaux* lorsque
$u^top v = 0$.
]

#remark[
  Avant tout calcul matriciel, il faut vérifier les dimensions. Cette habitude
  permet souvent de repérer une formule incorrecte sans effectuer le calcul.
]

=== Inverse d'une matrice

#definition-box(supplement: "Définition")[
Une matrice carrée $A$ est *inversible* s'il existe une matrice $A^(-1)$ telle
que

$ A A^(-1) = A^(-1) A = I_n. $
]

L'inverse matriciel permet notamment d'écrire la solution du système $A x = b$ sous la forme $x = A^(-1) b$. Cette écriture est utile pour raisonner, même si les logiciels résolvent habituellement le système directement, sans calculer explicitement l'inverse.

#property-box(supplement: "Propriétés")[
Si $A$ et $B$ sont inversibles, leur produit l'est aussi et

$ (A B)^(-1) = B^(-1) A^(-1). $

]

#proof(title: "Preuve")[
Il suffit de vérifier que $B^(-1) A^(-1)$ est un inverse à gauche et à
droite de $A B$:

$ (A B)(B^(-1) A^(-1)) = A (B B^(-1)) A^(-1) = I_n, $

$ (B^(-1) A^(-1))(A B) = B^(-1) (A^(-1) A) B = I_n. $

Les deux produits étant égaux à l'identité, l'inverse de $A B$ est bien
$B^(-1) A^(-1)$.
]

=== Déterminant et trace

#definition-box(supplement: "Définition")[
Le *déterminant* est un scalaire associé à une matrice carrée. Il mesure le facteur
par lequel la transformation linéaire dilate les volumes; son signe contient en
plus une information d'orientation. Une matrice est inversible si et seulement
si son déterminant est non nul.
]

#property-box(supplement: "Propriétés")[
Pour des matrices carrées $A$ et $B$,

+ $det(A^top) = det(A)$;
+ $det(A B) = det(A) det(B)$;
+ si $A$ est inversible, $det(A^(-1)) = det(A)^(-1)$.
]

#proof(title: "Preuve")[
La première identité découle de la formule de Leibniz: transposer la
matrice revient à remplacer chaque permutation par sa permutation inverse, qui a
le même signe. La deuxième est obtenue par la formule de Cauchy--Binet. Enfin,

$ 1 = det(I_n) = det(A A^(-1)) = det(A) det(A^(-1)), $

ce qui donne la troisième identité puisque $det(A) != 0$.

Voir #link("https://mbernste.github.io/posts/determinantsformula/")[ici] pour une démonstration plus détaillée.
]

#definition-box(supplement: "Définition")[
La *trace* d'une matrice carrée $A = (a_(i j))$ est la somme de ses éléments
diagonaux:

$ tr(A) = sum_(i=1)^n a_(i i). $
]

#property-box(supplement: "Propriétés")[
Soit $A$ et $B$ appartenant à $cal(M)_n (RR)$, et $M$ et $N$ appartenant à $cal(M)_(n,p)(RR)$, la trace vérifie notamment

- $tr(A^top) = tr(A)$;
- $tr(A + B) = tr(A) + tr(B)$;
- $tr(M N^top) = tr(N^top M)$.
]

#proof(title: "Preuve")[
La transposition ne modifie aucun élément diagonal, donc
$tr(A^top) = tr(A)$. La linéarité de la somme donne

$ tr(A + B) = sum_(i=1)^n (a_(i i) + b_(i i)) = tr(A) + tr(B). $

Enfin, en développant les produits diagonaux,

$ tr(M N^top)
  = sum_(i=1)^n sum_(j=1)^p m_(i j) n_(i j)
  = sum_(j=1)^p sum_(i=1)^n n_(i j) m_(i j)
  = tr(N^top M). $
]

Cette dernière identité relie la trace au produit scalaire entre matrices. Elle
apparaît fréquemment lorsqu'une somme de carrés est réécrite sous forme
matricielle, par exemple dans les critères d'inertie ou d'erreur quadratique.

=== Matrices symétriques, définies positives et orthogonales

#definition-box(supplement: "Définition")[
Une matrice carrée $A$ est *symétrique* lorsque $A^top = A$.

Une matrice symétrique $A$ est *définie positive* lorsque

$ u^top A u > 0 $

pour tout vecteur non nul $u$. Elle est *semi-définie positive* lorsque
$u^top A u >= 0$.

Une matrice carrée $Q$ est *orthogonale* lorsque

$ Q^top Q = Q Q^top = I_n. $
]

Les matrices de covariance et de corrélation sont symétriques, ce qui leur donne
des propriétés spectrales particulièrement utiles pour l'analyse en composantes
principales et les méthodes factorielles.

#property-box(supplement: "Propriétés")[

1. Une matrice de covariance est semi-définie positive. Elle peut ne pas être
   définie positive lorsqu'il existe une dépendance linéaire exacte entre les
   variables.

2. Si $Q$ est orthogonale, alors $Q^(-1) = Q^top$. Ses colonnes forment une base
   orthonormée et la transformation $u arrow.r Q u$ conserve les produits
   scalaires, les normes, les angles et les distances euclidiennes.
]

#proof(title: "Preuve")[
Soit $Σ$ la matrice de covariance d'un vecteur aléatoire $X$. Pour tout
$u in RR^n$,

$ u^top Σ u = "Var"(u^top X) >= 0, $

donc $Σ$ est semi-définie positive. Si une combinaison linéaire non triviale des
variables est constante, sa variance est nulle. La matrice $Σ$ est alors
singulière.

Par ailleurs, l'égalité $Q^top Q = I_n$ montre directement que
$Q^(-1) = Q^top$. Pour tous $u, v in RR^n$,

$ (Q u)^top (Q v) = u^top Q^top Q v = u^top v. $

En prenant $v = u$, on obtient $norm(Q u) = norm(u)$. La conservation des angles
et des distances en découle.
]

Géométriquement, une matrice orthogonale représente une rotation, une réflexion
ou une combinaison des deux.

=== Valeurs et vecteurs propres

#definition-box(supplement: "Définition")[
Soit $A in cal(M)_n (RR)$. Un scalaire $λ$ est une *valeur propre* de $A$ s'il
existe un vecteur non nul $u in RR^n$ tel que

$ A u = λ u. $

Le vecteur $u$ est alors un *vecteur propre* associé à $λ$. Dans sa direction, la transformation $A$ agit comme une simple multiplication du vecteur $u$ par $λ$. Les valeurs propres sont les solutions de l'équation caractéristique

$ det(A - λ I_n) = 0. $

Pour tout vecteur non nul $u in RR^n$, la quantité

$ R_A (u) = (u^top A u) / (u^top u) $

est appelée *quotient de Rayleigh*. Dans le cas où $A$ est une matrice de covariance, le coefficient de Rayleigh est toujours positif ou nul. Il mesure la variance de la projection d'un vecteur aléatoire sur la direction $u$. C'est une propriété fondamentale de l'analyse en composantes principales.
]

#property-box(supplement: "Propriétés")[

1. Si $u$ est un vecteur propre associé à $λ$, alors $c u$ est également un vecteur propre pour tout $c != 0$.

2. Si $A$ est symétrique, deux vecteurs propres associés à des valeurs propres
   distinctes sont orthogonaux.

3. Toutes les valeurs propres d'une matrice symétrique réelle sont réelles.

4. Les valeurs propres d'une matrice définie positive sont strictement
   positives. Celles d'une matrice semi-définie positive sont non négatives.
]

#proof(title: "Preuve")[
Pour la première propriété,

$ A(c u) = c A u = c λ u = λ(c u). $

Pour la deuxième, soient $u_1$ et $u_2$ associés à $λ_1 != λ_2$. La symétrie de
$A$ donne

$ λ_1 u_1^top u_2
  = (A u_1)^top u_2
  = u_1^top A^top u_2
  = u_1^top A u_2
  = λ_2 u_1^top u_2. $

Ainsi, $(λ_1 - λ_2) u_1^top u_2 = 0$, donc $u_1^top u_2 = 0$.

Pour établir la troisième propriété, autorisons temporairement un vecteur propre
complexe $z$ et notons $z^* = overline(z)^top$ sa transposée conjuguée. Puisque
$A$ est réelle et symétrique, le scalaire $z^* A z$ est réel. Par conséquent,

$ λ = (z^* A z) / (z^* z) in RR. $

Enfin, si $u$ est un vecteur propre réel non nul, alors

$ λ = (u^top A u) / (u^top u). $

Le dénominateur est strictement positif. Le signe de $λ$ est donc celui imposé
au numérateur par le caractère défini positif ou semi-défini positif de $A$.
Comme l'échelle d'un vecteur propre est arbitraire, on choisit souvent
$norm(u) = 1$.
]

=== Diagonalisation et décomposition spectrale

#definition-box(supplement: "Définition")[
Une matrice carrée $A$ est *diagonalisable* s'il existe une matrice inversible
$P$ et une matrice diagonale $Λ$ telles que

$ A = P Λ P^(-1). $

La diagonale de $Λ$ contient les valeurs propres de $A$ et les colonnes de $P$
sont des vecteurs propres correspondants. Cette représentation ramène l'action
de $A$ à des mises à l'échelle indépendantes dans les directions propres.
]

#theorem[Décomposition spectrale][
Toute matrice symétrique réelle $A$ admet une décomposition

$ A = Q Λ Q^top, $

où $Q$ est orthogonale et $Λ = "diag"(λ_1, dots, λ_n)$ est diagonale. Les
colonnes de $Q$ forment une base orthonormée de vecteurs propres.
]

#proof(title: "Preuve")[
Une démonstration consiste à maximiser le quotient de Rayleigh sur la sphère
unité, puis à répéter le raisonnement dans le sous-espace orthogonal au premier
vecteur propre.
]

#property-box(supplement: "Propriétés")[
Si $A$ est diagonalisable et si ses valeurs propres, répétées selon leur
multiplicité, sont $λ_1, dots, λ_n$, alors

$ det(A) = product_(i=1)^n λ_i quad "et" quad tr(A) = sum_(i=1)^n λ_i. $
]

#proof(title: "Preuve")[
Écrivons $A = P Λ P^(-1)$. La
multiplicativité du déterminant donne

$ det(A)
  = det(P) det(Λ) det(P^(-1))
  = det(Λ)
  = product_(i=1)^n λ_i. $

La cyclicité de la trace donne de même

$ tr(A)
  = tr(P Λ P^(-1))
  = tr(P^(-1) P Λ)
  = tr(Λ)
  = sum_(i=1)^n λ_i. $
]

La décomposition spectrale explique pourquoi une matrice de covariance peut être
décrite par des axes orthogonaux et par la variance portée par chacun de ces
axes. En particulier, la variance totale $tr(Σ)$ est la somme des variances
portées par les axes propres.

=== Projections et optimisation quadratique

#definition-box(supplement: "Définition")[
Si $u$ est un vecteur unitaire, le nombre
$chevron.l u, x chevron.r = u^top x$ est la coordonnée de $x$ dans la direction
$u$, et le vecteur $u u^top x$ est la *projection orthogonale* de $x$ sur cette
direction.
]

#property-box(supplement: "Propriétés")[

1. Si les colonnes de $U in cal(M)_(n,p)(RR)$ sont orthonormées, alors
   $P = U U^top$ est la matrice de projection orthogonale sur l'espace engendré
   par ces colonnes.

2. Si $A$ est symétrique, le maximum de $u^top A u$ sous la contrainte
   $u^top u = 1$ est sa plus grande valeur propre. Il est atteint par tout vecteur
   propre unitaire associé à cette valeur propre.

3. Si $A$ et $B$ sont symétriques et si $B$ est définie positive, maximiser
   $u^top A u$ sous la contrainte $u^top B u = 1$ conduit au problème généralisé

   $ A u = λ B u. $
]

#proof(title: "Preuve")[
Puisque les colonnes de $U$ sont orthonormées, $U^top U = I_p$. La
matrice $P = U U^top$ est symétrique et idempotente:

$ P^top = P quad "et" quad P^2 = U(U^top U)U^top = P. $

Elle est donc la projection orthogonale sur l'espace engendré par les colonnes de
$U$.

Pour la deuxième propriété, ordonnons les valeurs propres de $A$ de sorte que
$λ_1 >= dots >= λ_n$ et écrivons $A = Q Λ Q^top$. Tout vecteur unitaire s'écrit
$u = Q c$ avec $c^top c = 1$. Alors

$ u^top A u
  = c^top Λ c
  = sum_(i=1)^n λ_i c_i^2
  <= λ_1 sum_(i=1)^n c_i^2
  = λ_1. $

L'égalité est atteinte lorsque $u$ est un vecteur propre unitaire associé à
$λ_1$.

Enfin, la méthode des multiplicateurs de Lagrange appliquée à
$u^top A u$ sous la contrainte $u^top B u = 1$ donne la condition
$2 A u - 2 λ B u = 0$, soit $A u = λ B u$. Une multiplication à gauche par
$u^top$ montre alors que

$ u^top A u = λ u^top B u = λ. $

La valeur propre $λ$ est donc aussi la valeur du critère optimisé.
]

Ce principe relie directement l'algèbre linéaire aux méthodes d'analyse de données:

- en ACP, les vecteurs propres de la matrice de covariance donnent les axes de
  projection et les valeurs propres donnent les variances expliquées;
- en analyse discriminante, une direction est choisie pour maximiser la
  séparation entre groupes relativement à la dispersion à l'intérieur des
  groupes;
- dans plusieurs méthodes factorielles, une décomposition spectrale transforme
  un critère géométrique en coordonnées interprétables.

#remark[
  On peut retenir le schéma suivant: une matrice symétrique décrit une géométrie,
  ses vecteurs propres en donnent les directions privilégiées et ses valeurs
  propres quantifient l'importance de ces directions.
]

== Probabilités

Les probabilités fournissent un modèle mathématique de l'incertitude. Elles ne
prédisent pas le résultat d'une expérience particulière, mais décrivent les
résultats possibles et la fréquence avec laquelle ils devraient apparaître si
l'expérience était répétée.

=== Modéliser le hasard

#definition-box(supplement: "Définition")[
L'*espace des possibles* $S$ est l'ensemble de tous les résultats possibles
d'une expérience. Un *évènement* $E$ est un sous-ensemble de $S$.

Une *mesure de probabilité* $PP$ associe un nombre $PP(E)$ à chaque évènement $E$ et vérifie les axiomes suivants:

1. $0 <= PP(E) <= 1$ pour tout évènement $E$;
2. $PP(S) = 1$;
3. si $E_1, E_2, dots$ sont mutuellement exclusifs, alors

   $ PP(union.big_(i=1)^infinity E_i) = sum_(i=1)^infinity PP(E_i). $
]

#remark[
  Pour un lancer de pièce, l'espace des possibles peut être formé des résultats
  « pile » et « face ». Pour une durée de vie, il peut être $RR_+$. Le choix de
  l'espace et des probabilités dépend du phénomène étudié et de l'information
  disponible.
]

#definition-box(supplement: "Définition")[
Soient $E$ et $F$ deux évènements tels que $PP(F) > 0$. La *probabilité
conditionnelle* de $E$ sachant $F$ est

$ PP(E | F) = PP(E ∩ F) / PP(F). $

Les évènements $E$ et $F$ sont *indépendants* lorsque

$ PP(E ∩ F) = PP(E) PP(F). $
]

#property-box(supplement: "Propriétés")[
Si $PP(F) > 0$, alors

$ PP(E ∩ F) = PP(E | F) PP(F). $

De plus, $E$ et $F$ sont indépendants si et seulement si
$PP(E | F) = PP(E)$.
]

#proof(title: "Preuve")[
La première égalité est obtenue en multipliant la définition de
$PP(E | F)$ par $PP(F)$. En la combinant avec
$PP(E ∩ F) = PP(E) PP(F)$, puis en divisant par $PP(F)$, on obtient la
caractérisation de l'indépendance.
]

=== Variables aléatoires

Une variable aléatoire transforme le résultat d'une expérience en une valeur
sur laquelle des calculs sont possibles. Sa distribution décrit les probabilités
des valeurs ainsi obtenues.

#definition-box(supplement: "Définition")[
Une *variable aléatoire* $X$ est une fonction qui associe une valeur numérique à
chaque résultat de l'expérience.

La *distribution* d'une variable aléatoire $X$ est l'application qui associe à
un ensemble $A$ la probabilité $PP(X in A)$.

- La variable $X$ est *discrète* si elle prend un ensemble fini ou dénombrable de
  valeurs. Sa distribution est alors déterminée par les scalaires $PP(X = x)$.
- La variable $X$ est *continue* s'il existe une function $f$, appelée la *densité* de $X$, telle que

  $ PP(X in A) = integral_A f(x) dif x, $

  avec $f(x) >= 0$ et $integral_(RR^d) f(x) dif x = 1$. Dans ce cas,
  $PP(X = x) = 0$ pour toute valeur fixée $x$.
]

#definition-box(supplement: "Définition")[
L'*espérance* de $X$, lorsqu'elle existe, est la moyenne de ses valeurs pondérées
par leur probabilité. Elle est donnée par

$ EE(X) = sum_x x PP(X = x) $

dans le cas discret et par

$ EE(X) = integral_(RR^d) x f(x) dif x $

dans le cas continu.
]

#theorem[Transfert de l'espérance][
Soit $g: RR^d arrow.r RR$ une fonction telle que $EE(g(X))$ existe.

- Si $X$ est discrète, alors
  $EE(g(X)) = sum_x g(x) PP(X = x)$.
- Si $X$ est continue de densité $f$, alors
  $EE(g(X)) = integral_(RR^d) g(x) f(x) dif x$.
]

#proof(title: "Preuve")[
La variable $g(X)$ hérite sa distribution de celle de $X$. Appliquer la
définition de l'espérance à cette distribution revient à sommer ou à intégrer
$g(x)$ selon la distribution de $X$, ce qui donne les deux formules.
]

#property-box(supplement: "Propriétés")[
Soient $X$ et $Y$ deux variables aléatoires dont les espérances existent, et soit $a in RR$. Alors

1. $EE(X + Y) = EE(X) + EE(Y)$;
2. $EE(a X) = a EE(X)$.
]

#proof(title: "Preuve")[
Ces deux identités découlent du théorème de transfert et de la linéarité des
sommes dans le cas discret ou des intégrales dans le cas continu.
]

#definition-box(supplement: "Définition")[
Si $EE(X^2)$ existe, la *variance* de $X$ est

$ "Var"(X) = EE((X - EE(X))^2). $

Elle mesure la dispersion autour de l'espérance. L'*écart-type* est défini par
$sigma(X) = sqrt("Var"(X))$ et s'exprime dans la même unité que $X$.
]

#property-box(supplement: "Propriétés")[
Pour une variable aléatoire $X$ dont les moments nécessaires existent et pour des
constantes $a$ et $b$,

1. $"Var"(X) = EE(X^2) - EE(X)^2$;
2. $"Var"(a X + b) = a^2 "Var"(X)$.
]

#proof(title: "Preuve")[
Pour la première identité, on développe le carré dans la définition:

$ EE((X - EE(X))^2)
  = EE(X^2) - 2 EE(X) EE(X) + EE(X)^2
  = EE(X^2) - EE(X)^2. $

Enfin, $a X + b - EE(a X + b) = a(X - EE(X))$. Élever au carré et prendre
l'espérance donne la deuxième identité.
]

#definition-box(supplement: "Définition")[
La *fonction de répartition* de $X$ est la fonction

$ F_X (t) = PP(X <= t), quad t in RR. $

Elle caractérise entièrement la distribution de $X$, qu'elle soit discrète ou
continue.
]

#definition-box(supplement: "Définition")[
Deux variables aléatoires $X$ et $Y$ sont *indépendantes* si, pour tous ensembles
$A$ et $B$, les évènements ${X in A}$ et ${Y in B}$ sont indépendants, c'est-à-dire

$ PP(X in A, Y in B) = PP(X in A) PP(Y in B). $
]

#example[Deux lancers de pièce][
On lance deux fois une pièce équilibrée. Soit $X$ l'indicatrice de l'évènement
« obtenir face au premier lancer » et $Y$ l'indicatrice de l'évènement
« obtenir face au second lancer ». Pour tous $x, y in brace.l 0, 1 brace.r$,

$ PP(X = x, Y = y)
  = 1 / 4
  = 1 / 2 times 1 / 2
  = PP(X = x) PP(Y = y). $

La distribution conjointe se factorise donc en produit des distributions
marginales: les variables $X$ et $Y$ sont indépendantes.
]

#property-box(supplement: "Propriétés")[
Si $X$ et $Y$ sont indépendantes, alors $g(X)$ et $h(Y)$ sont indépendantes pour
toutes fonctions $g$ et $h$. De plus, lorsque les espérances existent,

$ EE(X Y) = EE(X) EE(Y). $
]

#proof(title: "Preuve")[
Les évènements définis à partir de $g(X)$ et de $h(Y)$ peuvent être réécrits comme
des évènements portant séparément sur $X$ et sur $Y$. Ils sont donc indépendants.
La factorisation de la distribution conjointe permet ensuite de séparer la somme
ou l'intégrale définissant $EE(X Y)$ en un produit de deux espérances.
]

=== Covariance et corrélation

#definition-box(supplement: "Définition")[
Pour deux variables aléatoires $X_1$ et $X_2$ ayant des moments d'ordre deux, la
*covariance* est

$ "Cov"(X_1, X_2)
  = EE((X_1 - EE(X_1))(X_2 - EE(X_2))). $

Lorsque les écarts-types sont non nuls, la *corrélation* est la covariance normalisée par les écarts-types:

$ "Corr"(X_1, X_2)
  = "Cov"(X_1, X_2) / (sigma(X_1) sigma(X_2)). $

Pour un vecteur $X in RR^p$ de moyenne $μ = EE(X)$, la matrice de covariance est

$ Σ = "Cov"(X) = EE((X - μ)(X - μ)^top). $

Sa diagonale contient les variances et ses éléments hors diagonale contiennent
les covariances.
]

Une covariance ou une corrélation positive indique que les variables tendent à
évoluer dans le même sens. Un signe négatif indique qu'elles tendent à évoluer en
sens opposés. La corrélation facilite les comparaisons parce qu'elle ne dépend
pas des unités de mesure.

#property-box(supplement: "Propriétés")[
Pour des variables aléatoires ayant des moments d'ordre deux,

1. $"Cov"(X, Y) = EE(X Y) - EE(X) EE(Y)$;
2. $"Cov"(X, Y) = "Cov"(Y, X)$;
3. $"Cov"(X + a Z, Y) = "Cov"(X, Y) + a "Cov"(Z, Y)$;
4. si $X$ et $Y$ sont indépendantes, alors $"Cov"(X, Y) = 0$;
5. lorsque la corrélation est définie, $-1 <= "Corr"(X, Y) <= 1$.
]

#proof(title: "Preuve")[
La première identité s'obtient en développant le produit centré et en utilisant
la linéarité de l'espérance. La deuxième découle de la commutativité du produit,
et la troisième de la linéarité de l'espérance. Si $X$ et $Y$ sont indépendantes,
$EE(X Y) = EE(X) EE(Y)$, ce qui prouve la quatrième propriété. Enfin,
l'inégalité de Cauchy--Schwarz appliquée aux variables centrées donne

$ |"Cov"(X, Y)| <= sigma(X) sigma(Y), $

d'où la dernière propriété après division par les écarts-types.
]

#remark[
  Une covariance nulle signifie seulement qu'aucune relation *linéaire* n'est
  détectée. Elle n'implique généralement pas l'indépendance. L'implication
  inverse est cependant vraie : l'indépendance entraîne une covariance nulle
  lorsque les moments existent.
]

=== Vecteurs aléatoires

Un *vecteur aléatoire* rassemble plusieurs variables aléatoires:

$ X = (X_1, dots, X_p)^top. $

La distribution d'une composante $X_j$ est une *distribution marginale*. Si les
composantes sont continues et indépendantes, leur densité conjointe se factorise:

$ f_X (x_1, dots, x_p) = product_(j=1)^p f_(X_j)(x_j). $

L'indépendance signifie que connaître certaines composantes n'apporte aucune
information sur les autres. Elle est plus forte que l'absence de dépendance
linéaire.

#definition-box(supplement: "Définition")[
  Si $Σ$ est définie positive, on dit que $X$ suit une loi normale de dimension $p$, de moyenne $μ$ et de covariance $Σ$, lorsque sa densité est

  $ f_X(x) = 1 / ((2 pi)^(p/2) det(Σ)^(1/2))
    exp(-1/2 (x - μ)^top Σ^(-1) (x - μ)). $

  On note alors $X tilde cal(N)_p (μ, Σ)$.
]

Cette distribution intervient notamment dans l'analyse discriminante et les modèles de mélanges gaussiens.



== Statistiques

La statistique utilise les données observées pour décrire une population, estimer
des quantités inconnues et évaluer l'incertitude associée à ces estimations. Elle
relie ainsi les objets probabilistes théoriques aux calculs réalisés sur un
échantillon.

=== Échantillon et estimateurs

#definition-box(supplement: "Définition")[
Un *échantillon aléatoire* de taille $n$ issu d'une distribution est une suite
$X_1, dots, X_n$ de variables aléatoires indépendantes ayant cette même
distribution. Les valeurs effectivement observées sont notées
$x_1, dots, x_n$.

Un *estimateur* d'une quantité inconnue $θ$ est une fonction de l'échantillon. Il
est donc lui-même aléatoire avant l'observation des données.
]

Supposons que les observations soient des vecteurs de $RR^p$ de moyenne $μ$ et
de covariance $Σ$. L'estimateur usuel de la moyenne est la moyenne empirique:

$ hat(μ) = 1 / n sum_(i=1)^n X_i. $

La matrice de covariance empirique est

$ hat(Σ) = 1 / (n - 1) sum_(i=1)^n
  (X_i - hat(μ))(X_i - hat(μ))^top. $

La division par $n - 1$, plutôt que par $n$, corrige le fait que la moyenne $μ$
est elle-même remplacée par son estimateur $hat(μ)$.

#property-box(supplement: "Propriétés")[
Si $X_1, dots, X_n$ sont indépendantes, de même moyenne $μ$ et de même covariance
$Σ$, alors

$ EE(hat(μ)) = μ quad "et" quad EE(hat(Σ)) = Σ. $

Les estimateurs $hat(μ)$ et $hat(Σ)$ sont donc sans biais.
]

#proof(title: "Preuve")[
La linéarité de l'espérance donne

$ EE(hat(μ)) = 1 / n sum_(i=1)^n EE(X_i) = μ. $

Posons $Z_i = X_i - μ$ et $overline(Z) = hat(mu) - μ$. L'identité

$ sum_(i=1)^n (X_i - hat(mu))(X_i - hat(mu))^top
  = sum_(i=1)^n Z_i Z_i^top - n overline(Z) overline(Z)^top $

et l'indépendance donnent
$EE(sum_(i=1)^n Z_i Z_i^top) = n Σ$ ainsi que
$EE(overline(Z) overline(Z)^top) = frac(Σ, n, style: "horizontal")$.
L'espérance du membre de gauche vaut donc $(n - 1)Σ$. La division par $n - 1$ donne $EE(hat(Σ)) = Σ$.
]

=== Corrélation empirique

Soit $hat(D)$ la matrice diagonale contenant les écarts-types empiriques:

$ hat(D) = "diag"(hat(Σ)^(1/2)_(1 1), dots, hat(Σ)^(1/2)_(p p)). $

Si aucun de ces écarts-types n'est nul, la matrice de corrélation empirique est

$ hat(R) = hat(D)^(-1) hat(Σ) hat(D)^(-1). $

Cette normalisation place toutes les variables sur une échelle comparable. Elle
est particulièrement importante lorsque les unités ou les ordres de grandeur
diffèrent, par exemple avant une ACP fondée sur les corrélations.

=== Interpréter une estimation

Les moyennes, covariances, corrélations et taux d'erreur calculés sur un
échantillon varieraient si l'on recueillait de nouvelles données. Une estimation
doit donc toujours être interprétée avec sa variabilité et avec les conditions
de collecte de l'échantillon.

Si l'échantillon est petit, les estimations peuvent être instables. S'il n'est
pas représentatif de la population ciblée, augmenter sa taille ne corrige pas
nécessairement le biais de sélection. Les axes de l'ACP, les distances, les groupes
et les modèles prédictifs héritent directement de ces limites.

L'évaluation prédictive suit la même logique. Un taux d'erreur mesuré sur un jeu
de validation estime une performance future et n'est pas une vérité exacte. La
validation croisée réduit une partie de la variabilité de cette estimation, mais
elle ne corrige ni un échantillon mal défini ni une fuite d'information entre
l'entraînement et la validation.

#remark[
  Une formule correcte ne garantit pas une estimation pertinente. Il faut aussi
  vérifier l'indépendance des observations, la représentativité de l'échantillon,
  le mécanisme de données manquantes et la stabilité des résultats.
]

== Programmation reproductible

L'analyse de données ne dépend pas d'un langage unique. R, Python, Julia ou SAS
peuvent servir à réaliser les analyses. Les outils changent, mais les principes
restent les mêmes: il faut pouvoir retrouver les données utilisées, comprendre
chaque transformation et reconstruire les résultats dans un environnement
logiciel documenté.

#definition-box(supplement: "Définition")[
Une analyse est *reproductible* lorsqu'une autre personne peut, à partir des mêmes données, du même code et des mêmes instructions, reconstruire les résultats annoncés.

La reproductibilité exige donc au moins quatre éléments: les entrées, le code, la
configuration de l'environnement et une procédure d'exécution explicite.
]

Reproduire une analyse ne signifie pas seulement obtenir le même tableau final ou les mêmes graphiques finaux. Il faut aussi pouvoir comprendre les choix effectués: observations exclues, variables construites, traitement des données manquantes, paramètres, modèles comparés et critères de validation. Le guide #link(
  "https://book.the-turing-way.org/reproducible-research/reproducible-research/"
)[*The Turing Way*] propose une introduction plus complète à ces pratiques.

=== Organiser un projet

Toutes les composantes d'une analyse devraient être regroupées sous une racine
de projet. Les chemins sont écrits relativement à cette racine plutôt qu'à un
dossier propre à un ordinateur. Une organisation simple peut être:

```text
projet/
├── README.md
├── data/
│   ├── raw/
│   └── processed/
├── src/
├── reports/
├── results/
├── tests/
```

Les noms exacts importent moins que la séparation des rôles:

- `data/raw/` contient les données originales, conservées en lecture seule;
- `data/processed/` contient des données produites par le code de nettoyage;
- `src/` contient les fonctions et les étapes de calcul;
- `reports/` contient les documents qui combinent explications, code et résultats;
- `results/` contient les tableaux, figures ou modèles qui peuvent être régénérés;
- `tests/` contient les vérifications automatiques;
- `README.md` explique l'objectif du projet et la commande permettant de le
  reconstruire.

Le flux de calcul devrait donc aller des données brutes vers les résultats sans étape manuelle cachée. Une correction faite directement dans un tableur, une figure retouchée après sa création ou une valeur copiée à la main rompent cette chaîne. Si une intervention manuelle est incontournable, elle doit être consignée et transformée en instruction reproductible autant que possible.

#remark[
  Les données brutes constituent une entrée, pas un espace de travail. On ne les
  écrase pas ! On produit une nouvelle version nettoyée tout en conservant la
  source et la trace des transformations.
]

=== Code, paramètres et entrées

Une analyse robuste sépare l'importation, la validation des données, le
nettoyage, la construction des variables, la modélisation et la production des
figures. Chaque étape reçoit des entrées identifiables et produit des sorties
explicites. Cette séparation facilite la vérification et évite de devoir relancer
des traitements coûteux qui n'ont pas changé.

Les choix qui influencent les résultats ne devraient pas être dispersés dans le code. Les chemins, graines (_seed_), variables sélectionnées, hyperparamètres choisis et seuils des $p$-valeurs peuvent être regroupés au début d'un script ou dans un fichier de configuration. Il faut préférer des noms décrivant le rôle des objets à des noms courts dont le sens dépend du contexte.

Quelques contrôles simples pour détecter rapidement les erreurs:

- vérifier les noms et les types des colonnes à l'importation;
- vérifier les unités, les catégories autorisées et les plages plausibles des différentes variables;
- compter les lignes du jeu de données avant et après chaque filtrage ou jointure;
- regarder les valeurs manquantes et les doublons;
- tester les fonctions qui réalisent les transformations importantes;
- arrêter l'exécution lorsqu'une hypothèse essentielle n'est pas satisfaite.

=== Dépendances et environnement

Un script correct aujourd'hui peut produire un autre résultat après la mise à jour d'une bibliothèque ou librairie. Il faut donc enregistrer les versions des dépendances et fournir un moyen de reconstruire l'environnement.

- En R, #link("https://rstudio.github.io/renv/")[`renv`] crée un environnement
  propre au projet. Le fichier `renv.lock` enregistre les versions, tandis que
  `renv::snapshot()` et `renv::restore()` permettent respectivement de figer et
  de restaurer cet environnement.
- En Python, le module officiel #link(
    "https://docs.python.org/3/library/venv.html"
  )[`venv`] isole les bibliothèques d'un projet. Un gestionnaire tel que
  #link("https://docs.astral.sh/uv/concepts/projects/sync/")[`uv`] peut en plus
  verrouiller les dépendances dans `uv.lock` et synchroniser l'environnement.

Il peut également être utile d'enregistrer les versions du langage, du système d'exploitation et, lorsque le calcul en dépend, des bibliothèques système ou du matériel. Un conteneur, type _Docker_, peut être justifié lorsque cette configuration est complexe, mais il ne remplace ni la documentation ni une organisation claire.

#remark[
  Un fichier qui énumère seulement les noms des bibliothèques ne suffit pas
  toujours. Une reproduction fidèle demande généralement des versions précises
  et une commande testée pour restaurer l'environnement.
]

=== Aléatoire et déterminisme

Les séparations entraînement-test, la validation croisée, les initialisations et les simulations utilisent souvent des nombres pseudo-aléatoires. Pour comparer deux méthodes dans les mêmes conditions, il faut fixer et documenter une graine (_seed_) du générateur. Cela permet de reproduire exactement la même suite de nombres, ainsi que conserver les indices des partitions importantes.

En R, `set.seed(2026)` initialise le générateur. La #link(
  "https://stat.ethz.ch/R-manual/R-devel/library/base/html/Random.html"
)[documentation officielle sur les générateurs aléatoires] décrit aussi
`RNGkind()` et `RNGversion()`. En Python avec NumPy, il est préférable de créer un
générateur explicite, par exemple `rng = np.random.default_rng(2026)`; voir la
#link("https://numpy.org/doc/stable/reference/random/generator.html")[documentation
de `numpy.random.Generator`].

Fixer une graine ne garantit toutefois pas une identité absolue entre toutes les
machines et toutes les versions. L'algorithme du générateur, le parallélisme, les
bibliothèques numériques et le matériel peuvent modifier l'ordre des opérations
ou la suite produite. Pour une expérience importante, on documente donc la graine
*et* l'environnement.

=== Contrôle de version

Un système de contrôle de version enregistre l'évolution des fichiers et permet de retrouver l'origine d'une modification. Avec Git, les changements sont regroupés en *commits* décrivant une étape cohérente. Le livre  #link("https://git-scm.com/book/fr/v2")[*Pro Git*] présente les notions de dépôt, historique, branche et collaboration.

Quelques pratiques sont particulièrement utiles:

- effectuer des commits petits et cohérents avec un message informatif;
- relire les différences avant chaque commit;
- versionner le code, la documentation et les fichiers de configuration;
- utiliser `.gitignore` pour les environnements locaux et les sorties
  régénérables;
- ne jamais enregistrer de mot de passe, de jeton d'accès (_token_) ou de donnée
  confidentielle dans le dépôt;
- conserver une copie distante lorsque la politique de confidentialité le
  permet.

Git ne remplace pas une stratégie de sauvegarde ou d'archivage. Les données
volumineuses, sensibles ou soumises à une licence peuvent nécessiter un stockage
séparé. Le dépôt doit alors contenir les instructions et les identifiants
permettant d'obtenir la bonne version des données, sans exposer leur contenu.

=== Rapports exécutables

Un rapport exécutable relie directement le texte, le code, les tableaux et les figures. Il réduit les erreurs de copier-coller et permet de régénérer les résultats lorsque les données ou les paramètres changent. Quarto prend en charge R, Python et Julia. Sa #link(
  "https://quarto.org/docs/computations/execution-options.html"
)[documentation sur l'exécution] explique notamment comment contrôler l'évaluation du code et l'affichage des résultats.

Les carnets de notes (_notebooks_) interactifs restent vulnérables à un état caché: une cellule peut dépendre d'un objet créé plus tôt mais absent du document final. Avant de diffuser un rapport, il faut redémarrer l'environnement et exécuter le document complet, dans l'ordre, idéalement à partir d'une copie propre du projet.

Une commande unique devrait suffire pour lancer l'analyse complète ou produire
le rapport. Si plusieurs commandes sont nécessaires, leur ordre et leurs entrées
doivent apparaître dans le `README.md`.

=== Liste de vérification

Avant de considérer une analyse comme reproductible, on vérifie que:

    - les données sources et leur provenance sont identifiées;
    - les transformations sont réalisées par du code versionné;
    - les chemins sont relatifs à la racine du projet;
    - les paramètres et les graines sont explicites;
    - les versions des dépendances sont verrouillées;
    - les sorties peuvent être supprimées puis régénérées;
    - le rapport s'exécute dans un environnement propre;
    - les hypothèses sur les données sont vérifiées automatiquement;
    - le `README.md` décrit l'installation et l'exécution;
    - les limites de reproduction sont documentées.

#remark[
  Le test le plus révélateur consiste à repartir d'une copie neuve du dépôt et à
  suivre uniquement les instructions écrites. Toute intervention improvisée
  signale une dépendance cachée qui doit être supprimée ou documentée.
]
