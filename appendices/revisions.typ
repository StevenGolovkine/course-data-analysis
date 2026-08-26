#import "../styles/notes.typ": note, property-box, proof, set-qed-symbol, theorem

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

Le produit scalaire de deux vecteurs $u, v in RR^n$ est $chevron.l u, v chevron.r = u^top v$. Il détermine la norme euclidienne $norm(u) = sqrt(u^top u)$ et l'orthogonalité: $u$ et $v$ sont orthogonaux lorsque $u^top v = 0$.

#note[
  Avant tout calcul matriciel, il faut vérifier les dimensions. Cette habitude
  permet souvent de repérer une formule incorrecte sans effectuer le calcul.
]

=== Inverse d'une matrice

Une matrice carrée $A$ est *inversible* s'il existe une matrice $A^(-1)$ telle
que

$ A A^(-1) = A^(-1) A = I_n. $

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

Le *déterminant* est un scalaire associé à une matrice carrée. Il mesure le facteur
par lequel la transformation linéaire dilate les volumes; son signe contient en
plus une information d'orientation. Une matrice est inversible si et seulement
si son déterminant est non nul.

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

La *trace* d'une matrice carrée $A = (a_(i j))$ est la somme de ses éléments
diagonaux:

$ tr(A) = sum_(i=1)^n a_(i i). $

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

Une matrice carrée $A$ est *symétrique* lorsque $A^top = A$. Les matrices de
covariance et de corrélation sont symétriques, ce qui leur donne des propriétés
spectrales particulièrement utiles pour l'analyse en composantes principales et les méthodes factorielles.

Une matrice symétrique $A$ est *définie positive* lorsque

$ u^top A u > 0 $

pour tout vecteur non nul $u$. Elle est *semi-définie positive* lorsque
$u^top A u >= 0$.

Une matrice carrée $Q$ est *orthogonale* lorsque

$ Q^top Q = Q Q^top = I_n. $

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

Soit $A in cal(M)_n (RR)$. Un scalaire $λ$ est une *valeur propre* de $A$ s'il
existe un vecteur non nul $u in RR^n$ tel que

$ A u = λ u. $

Le vecteur $u$ est alors un *vecteur propre* associé à $λ$. Dans sa direction, la transformation $A$ agit comme une simple multiplication du vecteur $u$ par $λ$. Les valeurs propres sont les solutions de l'équation caractéristique

$ det(A - λ I_n) = 0. $

Pour tout vecteur non nul $u in RR^n$, la quantité

$ R_A (u) = (u^top A u) / (u^top u) $

est appelée *quotient de Rayleigh*. Dans le cas où $A$ est une matrice de covariance, le coefficient de Rayleigh est toujours positif ou nul. Il mesure la variance de la projection d'un vecteur aléatoire sur la direction $u$. C'est une propriété fondamentale de l'analyse en composantes principales.

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

Une matrice carrée $A$ est *diagonalisable* s'il existe une matrice inversible
$P$ et une matrice diagonale $Λ$ telles que

$ A = P Λ P^(-1). $

La diagonale de $Λ$ contient les valeurs propres de $A$ et les colonnes de $P$
sont des vecteurs propres correspondants. Cette représentation ramène l'action
de $A$ à des mises à l'échelle indépendantes dans les directions propres.

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

Si $u$ est un vecteur unitaire, le nombre $chevron.l u, x chevron.r = u^top x$ est la coordonnée de $x$ dans la direction $u$, et le vecteur $u u^top x$ est la projection orthogonale de $x$ sur cette direction.

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
Puisque les colonnes de $U$ sont orthonormées, $U^top U = I_k$. La
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

#note[
  On peut retenir le schéma suivant: une matrice symétrique décrit une géométrie,
  ses vecteurs propres en donnent les directions privilégiées et ses valeurs
  propres quantifient l'importance de ces directions.
]

== Probabilités et statistiques

Une variable aléatoire formalise un résultat incertain. Sa distribution indique
les probabilités des valeurs possibles. L'espérance mesure une valeur moyenne,
la variance mesure la dispersion, et la covariance mesure la dépendance linéaire
entre deux variables.

Pour un vecteur aléatoire, la matrice de covariance résume les variances sur la
diagonale et les covariances hors diagonale. La matrice de corrélation normalise
ces covariances afin de comparer des variables sur des échelles différentes.

Les notions d'indépendance, de covariance et de corrélation sont distinctes. Une
covariance nulle signifie absence de relation linéaire, pas nécessairement
indépendance.

== Estimation empirique

En pratique, les moyennes, variances, covariances et taux d'erreur sont inconnus.
On les estime à partir d'un échantillon. La moyenne empirique résume la position
centrale. La matrice de covariance empirique alimente directement plusieurs
méthodes du cours, notamment l'ACP.

Il faut garder en tête que ces objets sont eux-mêmes estimés. Si l'échantillon
est petit ou non représentatif, les axes, distances et modèles obtenus peuvent
être instables.

L'évaluation prédictive suit la même logique. Un taux d'erreur mesuré sur un jeu
de validation est une estimation de la performance future, pas une vérité exacte.
La validation croisée réduit une partie de cette variabilité, mais ne corrige pas
un échantillon mal défini.

== Programmation reproductible

Le cours ne dépend pas d'un langage unique. R, Python, Julia et SAS peuvent
servir à réaliser les exercices, mais R et Python sont les choix les plus
courants pour l'analyse de données moderne.

Quelques principes de programmation sont indépendants du langage:

- écrire un code lisible et reproductible;
- nommer clairement les variables;
- séparer importation, nettoyage, modélisation et visualisation;
- conserver les paramètres importants dans un endroit explicite;
- fixer les graines aléatoires lorsque l'on compare des méthodes;
- documenter les transformations appliquées aux données;
- éviter de modifier manuellement les fichiers sources sans trace.

Un résultat reproductible n'est pas seulement un résultat que l'on peut refaire.
C'est aussi un résultat dont on peut comprendre les choix: données utilisées,
variables exclues, transformations, modèles, paramètres et versions des outils.

== Synthèse méthodologique

Une démarche rigoureuse commence par une exploration descriptive, s'appuie sur
l'expertise du domaine, compare plusieurs approches, valide les résultats et
documente les limites. Il n'existe pas d'algorithme universellement meilleur. Le
principe de *no free lunch* rappelle qu'une méthode performante dans un cadre
peut échouer dans un autre.

Plusieurs thèmes restent centraux en pratique:

- définir de bonnes variables explicatives, ou *feature engineering*;
- détecter et traiter les valeurs aberrantes;
- gérer les données manquantes;
- construire un protocole entraînement-validation-test;
- mesurer la représentativité des données;
- surveiller un modèle après son déploiement;
- communiquer l'incertitude à des non spécialistes.
