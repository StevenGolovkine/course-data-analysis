#import "../styles/notes.typ": note, example

= Réduction de dimension

== Pourquoi réduire la dimension ?

Un grand nombre de variables complique la visualisation, augmente le coût de
calcul, favorise les corrélations redondantes et peut rendre les modèles
instables. La réduction de dimension cherche à remplacer les variables initiales
par un plus petit nombre de variables synthétiques qui conservent l'information
utile.

Réduire la dimension ne signifie pas seulement supprimer des colonnes. Une
méthode plus riche consiste à construire de nouveaux axes, souvent comme
combinaisons des variables initiales, puis à travailler dans cet espace réduit.

#note[
  La réduction de dimension est une étape exploratoire. Elle aide à voir une
  structure, à compresser l'information ou à préparer une méthode prédictive,
  mais elle ne remplace pas l'interprétation statistique.
]

== Analyse en composantes principales

L'analyse en composantes principales, ou ACP, s'applique à des variables
numériques. Elle cherche des directions orthogonales de variation maximale. La
première composante explique le plus de variance possible, la seconde explique
le plus de variance restante sous contrainte d'être orthogonale à la première,
et ainsi de suite.

Soit $X$ un vecteur centré de $p$ variables et $Σ$ sa matrice de covariance. On
cherche une combinaison linéaire:

$ Y_1 = alpha_1^T X $

dont la variance est maximale sous la contrainte que $alpha_1$ soit de norme
1. La solution est donnée par l'équation aux valeurs propres:

$ Σ alpha_1 = λ_1 alpha_1 $

La première composante principale est associée à la plus grande valeur propre.
Les composantes suivantes correspondent aux valeurs propres suivantes, ordonnées
de la plus grande à la plus petite.

== Interprétation de l'ACP

Chaque valeur propre mesure la variance expliquée par une composante. La
proportion de variance expliquée par la composante $k$ est:

$ λ_k / sum_(j=1)^p λ_j $

Les premières composantes donnent donc une représentation de faible dimension
qui conserve une grande part de la variance totale.

#example[
  Si les deux premières composantes expliquent 82 pour cent de la variance d'un
  jeu de données à dix variables, un graphique dans le plan principal donne une
  image raisonnable de la structure globale. Il peut montrer des groupes, des
  observations atypiques ou des variables fortement associées.
]

== Pratique de l'ACP

En pratique, la matrice de covariance est inconnue et doit être estimée à partir
des données. On centre les variables, on calcule la matrice de covariance ou de
corrélation, puis on diagonalise cette matrice.

Il faut standardiser les variables lorsque leurs unités ou leurs ordres de
grandeur diffèrent. Sinon, une variable très dispersée peut dominer les axes
principaux même si elle n'est pas plus informative.

Pour choisir le nombre de composantes, on peut utiliser:

- la proportion de variance expliquée, par exemple atteindre 80 pour cent;
- la règle de Kaiser, pour une ACP sur corrélations, qui garde les valeurs
  propres supérieures à 1;
- la règle de Joliffe, qui utilise parfois un seuil de 0.7;
- le graphique des valeurs propres, aussi appelé règle du coude;
- l'interprétabilité des axes et l'objectif de l'analyse.

== Limites de l'ACP

L'ACP est linéaire: elle cherche des axes qui sont des combinaisons linéaires
des variables. Elle conserve la variance, pas nécessairement l'information utile
pour une tâche supervisée. Elle est sensible aux variables mal standardisées, aux
valeurs extrêmes et aux relations non linéaires.

Lorsque les composantes sont utilisées comme variables prédictives, il faut les
calculer uniquement à partir des données d'entraînement puis appliquer la même
transformation aux données de validation ou de test.

== Analyse factorielle des correspondances

L'analyse factorielle des correspondances, ou AFC, s'applique à un tableau de
contingence croisant deux variables qualitatives. Elle représente simultanément
les modalités de ligne et de colonne dans un espace de faible dimension.

L'AFC part des fréquences relatives du tableau. Elle compare les profils-lignes
et les profils-colonnes plutôt que les effectifs bruts. Un profil-ligne décrit,
pour une modalité de la première variable, la distribution conditionnelle des
modalités de la seconde variable.

#example[
  Si l'on croise le programme d'étude et le type d'admission des étudiants, une
  ligne du tableau décrit la répartition des types d'admission pour un programme
  donné. Deux programmes proches dans la représentation AFC ont des profils
  d'admission semblables.
]

== Indépendance et distance du chi-deux

Si les deux variables qualitatives sont indépendantes, les fréquences conjointes
sont proches du produit des fréquences marginales. L'AFC étudie les écarts à
cette situation d'indépendance.

La distance utilisée est la distance du chi-deux. Elle pondère les écarts par
les fréquences marginales, ce qui évite qu'une modalité très fréquente impose à
elle seule la structure géométrique. L'inertie totale est liée à la statistique
du test du chi-deux d'indépendance.

== Représentation barycentrique

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

== Analyse des correspondances multiples

L'analyse des correspondances multiples, ou ACM, généralise l'AFC à plusieurs
variables qualitatives. Elle est particulièrement utile pour les questionnaires
ou les enquêtes comportant plusieurs questions à choix multiples.

Chaque variable est transformée en modalités binaires par codage disjonctif
complet. Si une question possède trois modalités, elle devient trois colonnes
binaires. Un individu reçoit un 1 pour la modalité choisie et 0 pour les autres.

Le tableau de Burt, obtenu comme produit du tableau disjonctif transposé par le
tableau disjonctif, croise toutes les modalités entre elles. L'ACM peut être vue
comme une AFC appliquée au tableau disjonctif complet ou au tableau de Burt.

== Encodage et regroupement des modalités

Le choix des modalités est crucial. Pour une variable continue que l'on souhaite
inclure dans une ACM, il faut d'abord la discrétiser en classes. Ce découpage
fait perdre de l'information et doit être guidé par le contexte, les
distributions observées et l'objectif de l'analyse.

Pour les variables qualitatives, certaines modalités peuvent être trop rares.
Il est préférable de les regrouper de manière interprétable plutôt que de les
répartir arbitrairement dans d'autres catégories.

== Comparaison rapide

- ACP: variables numériques, axes de variance maximale.
- AFC: deux variables qualitatives, profils d'un tableau de contingence.
- ACM: plusieurs variables qualitatives, questionnaire ou données catégorielles
  multiples.

Dans les trois cas, l'objectif est de produire une représentation de faible
dimension qui conserve une structure importante des données.

== Exercices

1. Expliquez pourquoi une ACP sur des variables non standardisées peut être
   trompeuse.
2. Dans une ACP, que signifie une valeur propre élevée ?
3. Donnez un exemple de tableau de contingence adapté à une AFC.
4. Décrivez comment construire un tableau disjonctif complet pour trois
   questions à choix multiples.
