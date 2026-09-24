#import "../styles/notes.typ": *

= Apprentissage supervisé

== Introduction

Ce chapitre met en œuvre le cadre supervisé de @def-apprentissage-supervise.
Il compare plusieurs façons d'apprendre une règle de prédiction à partir
d'observations étiquetées.

Il faut distinguer la tâche de prédiction et celle de l'explication des données. Un classificateur (_classifier_) cherche les caractéristiques qui permettent de prévoir une étiquette ou un nombre donnés. Une variable très dispersée n'est ainsi pas nécessairement utile pour prédire, alors qu'une variable peu dispersée peut devenir essentielle si elle distingue bien les classes.

=== Données, modèle et prédiction

On conserve les notations de l'introduction et on regroupe les couples observés
dans $cal(D)={(x_i,y_i)}_(i=1)^n$. La règle apprise est notée $hat(f)$ et sa
prédiction en $x$ est $hat(y)=hat(f)(x)$.

Avant de choisir une méthode, il faut définir l'unité observée, la population visée et les informations disponibles au moment de la prédiction. Une variable mesurée seulement après la réponse peut être très prédictive dans un fichier historique tout en étant inutilisable dans la situation réelle.

#example[
  Dans le jeu de données Palmer Penguins, on peut chercher à prédire `species`
  à partir de `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et
  `body_mass_g`. Les espèces sont connues pendant l'apprentissage. Pour prédire
  l'espèce d'un nouveau manchot, le modèle ne reçoit que ses quatre mesures.

  Une autre question serait de prédire `body_mass_g` à partir des trois mesures
  de longueur ou de profondeur. La masse devient alors la réponse et doit être
  retirée des variables explicatives. Le même tableau peut ainsi servir à
  plusieurs tâches, mais chacune exige de préciser ce que l'on veut prédire.
]


=== Régression et classification

La distinction entre régression et classification est donnée dans
@def-regression-classification. Pour la classification, on note les classes
$1,dots,K$ : ces nombres sont des étiquettes, sans ordre ni distance numérique
imposés.

Un classificateur peut produire deux sortes de résultats :

- des probabilités estimées $hat(eta)_g (x) approx prob(Y=g bar.v X=x)$ pour chaque classe $g in \{1, dots, K\}$, de somme $1$ ;
- une décision $hat(g)(x)$, obtenue en choisissant une classe à partir de ces
  probabilités et d'une règle de décision.

Par exemple, des probabilités $(0.55, 0.40, 0.05)$ conduisent à choisir la première classe si l'on retient la plus probable. Cette décision est moins tranchée qu'avec $(0.98, 0.01, 0.01)$, alors que l'étiquette prédite est la même. Une probabilité annoncée par un modèle n'est toutefois fiable que si le modèle est convenablement calibré.

=== Familles de méthodes

Ce chapitre présente plusieurs approches de représentation et de prédiction
supervisées, qui partagent le même besoin d'évaluation mais reposent sur des
principes différents.

- Les *$k$ plus proches voisins* prédisent la réponse à partir des observations
  d'entraînement les plus semblables à l'observation à classer ou à prédire.
- L'*analyse discriminante de Fisher* construit des projections qui séparent
  les moyennes des classes relativement à leur dispersion interne. C'est une
  approche géométrique de réduction de dimension supervisée.
- L'*analyse discriminante probabiliste*, linéaire (*LDA*) ou quadratique
  (*QDA*), modélise les distributions des variables dans les classes et utilise
  la formule de Bayes pour obtenir des probabilités et une règle de décision.
- Les *arbres de classification et de régression* découpent l'espace des
  variables par une suite de conditions simples et prédisent dans chaque région.
- Les *méthodes ensemblistes* combinent plusieurs modèles, notamment des arbres,
  pour stabiliser ou améliorer les prédictions.


== Les $k$ plus proches voisins <knn>

=== Principe : prédire à partir d'observations semblables

La méthode des *$k$ plus proches voisins* (*k-NN*, _k-nearest neighbors_), repose sur une idée locale : des observations proches par leurs variables explicatives devraient avoir des réponses semblables. Pour prédire la réponse d'une nouvelle observation $x$, on recherche les $k$ observations d'entraînement les plus proches, puis on combine leurs réponses. La méthode s'utilise aussi bien en classification qu'en régression.#footnote[Voir la #link("https://scikit-learn.org/stable/modules/neighbors.html")[documentation de scikit-learn, _Nearest Neighbors_], pour les variantes de classification, de régression et de recherche des voisins.
]

On utilise les notations : $n$ observations d'entraînement, $p$ variables explicatives et, en classification, $K$ classes. Ici, $k$ désigne le nombre de voisins, avec $1 <= k <= n$. Il ne faut pas le confondre avec le nombre de classes $K$. On choisit une distance $d$ et on note $cal(N)_k (x)$ l'ensemble des indices des $k$ voisins retenus pour $x$. La recherche utilise uniquement les variables explicatives, puisque la réponse de $x$ est précisément ce que l'on cherche à prédire.

L'algorithme suit quatre étapes :

1. Préparer les variables explicatives, notamment leurs échelles, à partir des
   seules données d'entraînement.
2. Calculer les distances entre $x$ et les observations d'entraînement.
3. Retenir les $k$ distances les plus petites, selon une règle de départage
   fixée en cas d'égalité.
4. Faire voter les voisins pour une classification, ou moyenner leurs réponses
   pour une régression.

Contrairement à la régression linéaire, la méthode des k-NN n'estime pas une équation globale $hat(f)$ avec un nombre fixé de coefficients. C'est une méthode *non paramétrique* qui conserve les exemples d'entraînement pour prédire sur les nouvelles observations. Cela ne signifie pas qu'elle soit sans choix ni hypothèses. En effet, sa réussite dépend de la distance, des variables retenues et de la pertinence d'une prédiction locale.

=== Classification par vote des voisins

#definition(title: [Classification par les k plus proches voisins])[
  En faisant l'hypothèse que chaque voisin apporte une voix (donc qu'ils ont le même poids), la proportion locale de la classe $g$ et la décision correspondante sont

  $ hat(eta)_g (x) = 1/k sum_(i in cal(N)_k (x)) ind(y_i=g), quad "et" quad
    hat(g)(x) = argmax_(g in {1, dots, K}) hat(eta)_g (x). $
]

L'indicatrice $ind(y_i=g)$ vaut $1$ si le voisin $i$ appartient à la classe
$g$, et $0$ sinon. On choisit donc la classe la plus représentée dans le
voisinage. Avec plus de deux classes, la classe gagnante n'a pas nécessairement
plus de 50~% des voix. Les proportions locales peuvent servir d'estimations des
probabilités de classe, mais un vote de $2$ voisins sur $3$ ne garantit pas à
lui seul une probabilité bien calibrée de $2/3$.

#example[
    On cherche à classer le point $x=(0,0)^top$ à partir de deux variables
    exprimées sur des échelles comparables. Ses cinq plus proches voisins,
    ordonnés selon la distance euclidienne, sont les suivants :

    #table(
      columns: (0.8fr, 1.5fr, 1.1fr, 0.8fr), align: center,
      table.header([*Voisin*], [*Coordonnées*], [*Distance à $x$*], [*Classe*]),
      [1], [$(0.2, 0)$], [0,2], [B],
      [2], [$(0, 0.4)$], [0,4], [A],
      [3], [$(-0.5, 0)$], [0,5], [A],
      [4], [$(0, -0.7)$], [0,7], [B],
      [5], [$(0.8, 0.6)$], [1,0], [B],
    )

    Pour $k=1$, on prédit B. Pour $k=3$, A reçoit deux voix contre une : on
    prédit A, avec une proportion locale de $2/3$. Pour $k=5$, B reçoit trois
    voix contre deux et redevient la classe prédite. Le choix de $k$ peut donc
    modifier la décision pour une même observation.

    #figure(
    image("../figures/knn_voisinage.svg", width: 100%,
      alt: "Un point à l'origine est classé A avec trois voisins, dont deux A, "
        + "puis B avec cinq voisins, dont trois B. Chaque cercle contient le "
        + "nombre de voisins choisi ; les numéros renvoient au tableau."),
    caption: [Deux voisinages autour du même point. Le cercle passe par le
      $k$-ième voisin ; seuls les points retenus participent au vote. Les deux points les plus éloignés ne figurent pas parmi les cinq premiers voisins du tableau.],
  )
]

*Départager les égalités.* Deux situations sont à distinguer. D'abord,
plusieurs observations peuvent être à la même distance que le $k$-ième voisin.
Pour garder exactement $k$ voisins, il faut préciser lesquelles retenir, par
exemple selon un ordre stable des observations. Ensuite, plusieurs classes
peuvent recevoir le même nombre de voix. On peut alors choisir celle dont le
voisin le plus proche est le plus proche de $x$.

Un $k$ impair évite une égalité de voix avec deux classes et un vote uniforme,
mais pas avec trois classes ou davantage : cinq voisins peuvent donner
$2$ voix à A, $2$ à B et $1$ à C. La règle de départage fait partie de la
méthode et doit être fixée avant l'évaluation.


=== Régression par pondération des voisins

#definition(title: [Régression par les k plus proches voisins])[
  Lorsque la réponse est quantitative, on remplace le vote par la moyenne des
  réponses du voisinage :

  $ hat(f)_k (x) = 1/k sum_(i in cal(N)_k (x)) y_i. $
]

Cette moyenne minimise la somme des erreurs quadratiques sur les réponses des voisins. Si les trois voisins ont pour réponses $10$, $12$ et $14$, la prédiction pour $k=3$ est $12$. Une variante utilisant leur médiane répondrait plutôt à un critère d'erreur absolue et serait moins sensible aux réponses extrêmes.

Dans le vote uniforme comme dans la moyenne simple, un voisin situé tout près
de $x$ a le même poids que le $k$-ième voisin. Une variante attribue des poids
$w_i (x) >= 0$ de somme non nulle, plus élevés pour les points proches :

$ hat(f)_k (x) =
  (sum_(i in cal(N)_k (x)) w_i (x) y_i) /
  (sum_(i in cal(N)_k (x)) w_i (x)). $

Par exemple, on peut prendre $w_i (x)= d(x,x_i)^(-1)$ lorsque toutes les distances
retenues sont strictement positives.

Une distance nulle exige une convention explicite pour éviter une division
par zéro. On peut, dans ce cas, ne faire voter que les voisins retenus dont
les variables explicatives coïncident avec celles de $x$, ou moyenner leurs
réponses en régression. Le choix entre poids uniformes et poids dépendant de
la distance fait lui aussi partie des choix à valider.

=== Choisir le nombre de voisins

Le paramètre $k$ contrôle le degré de localisation de la prédiction.

- Avec un petit $k$, la règle peut suivre des détails fins, mais elle devient sensible au bruit, aux erreurs d'étiquetage ou de mesure et aux observations atypiques. Une seule observation peut changer la décision dans son voisinage.
- Avec un grand $k$, le vote ou la moyenne est généralement plus stable, mais peut mélanger des observations appartenant à des régions différentes et effacer une structure utile.

Ce compromis correspond au compromis entre biais et variance. À l'extrême, $k=1$ utilise une seule réponse connue. Avec $k=n$ et des poids uniformes, la classification prédit partout la classe majoritaire et la régression prédit partout la moyenne globale.

#figure(
  image("../figures/knn_frontieres.svg", width: 100%,
    alt: "Trois classificateurs k-NN sur le même échantillon simulé, avec "
      + "k égal à 1, 9 et 51. Les petites régions isolées présentes pour "
      + "k égal à 1 disparaissent quand le voisinage devient plus large."),
  caption: [Effet de $k$ sur les régions de décision, pour les mêmes données
    simulées avec quelques étiquettes bruitées. Un voisinage plus large atténue
    les détails locaux. L'aspect du graphique d'entraînement ne suffit pas à
    choisir la valeur qui prédit le mieux.],
)

On choisit donc $k$ par jeu de validation ou par validation croisée, par exemple en comparant $k = 1,3,5,7,9,15,21,31$ sur les mêmes plis. Chaque valeur doit être inférieure ou égale à l'effectif d'entraînement dans chaque pli. Il n'existe pas de valeur universelle. Le résultat dépend de la taille de l'échantillon, du bruit, des variables et de la distance.

#remark[
  Pour $k=1$, si les observations d'entraînement ont des vecteurs explicatifs
  distincts, chacune est son propre voisin le plus proche. L'erreur calculée
  sur ces mêmes observations est alors nulle, même avec des étiquettes bruitées.
  Ce résultat ne renseigne pas sur la généralisation. Avec une validation
  laissant une observation de côté, celle-ci doit être retirée de l'ensemble dans lequel on cherche ses voisins.
]

La préparation des variables doit être répétée à l'intérieur de chaque pli :
on calcule les moyennes et écarts-types sur la partie d'entraînement, puis on
transforme la partie de validation avec ces paramètres. Il en va de même pour
une imputation, une sélection de variables ou une réduction de dimension.
Le jeu de test ne sert ni à choisir $k$, ni à choisir la distance ou les poids.

=== Étude de cas : Palmer Penguins

On cherche à prédire `species` à partir de `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g`. On conserve les $342$ observations complètes pour ces quatre mesures. Le partage stratifié donne $240$ observations d'entraînement et $102$ de test. Les noms des espèces sont les réponses à prédire ; ils n'entrent donc pas dans le calcul des distances.

On peut utiliser la distance euclidienne sur les variables centrées et réduites, un vote uniforme et cinq plis stratifiés dans l'entraînement. Les mêmes plis servent pour toutes les valeurs de $k$ candidates. La standardisation est réestimée dans chaque pli. Voici les nombres d'erreurs obtenus en regroupant les prédictions de validation des $240$ observations :

#table(
  columns: (0.8fr, 1.3fr, 1.3fr), align: center,
  table.header([*$k$*], [*Erreurs sur 240*], [*Taux d'erreur*]),
  [1], [4], [1,67~%],
  [3], [3], [1,25~%],
  [5], [4], [1,67~%],
  [7], [4], [1,67~%],
  [9], [4], [1,67~%],
  [*15*], [*3*], [*1,25~%*],
  [21], [5], [2,08~%],
  [31], [6], [2,50~%],
)

Les valeurs $k=3$ et $k=15$ donnent la même erreur minimale. La règle fixée avant l'évaluation retient le plus grand $k$ en cas d'égalité, donc $k=15$, afin de privilégier un voisinage plus large. Ce départage ne signifie pas que $k = 15$ soit intrinsèquement meilleur : les différences de validation portent ici sur très peu d'observations et peuvent changer avec les plis.

On recalcule ensuite les moyennes et écarts-types sur les $240$ observations d'entraînement et on les utilise pour transformer les $102$ observations de test. Chaque prédiction de test repose sur ses $15$ voisins les plus proches parmi les seules observations d'entraînement. On obtient la matrice de confusion suivante, qui compare les espèces réelles et prédites :

#table(
  columns: (1.3fr, 1fr, 1fr, 1fr), align: center,
  table.header([*Espèce réelle*], [*Prédit Adelie*], [*Prédit Chinstrap*],
    [*Prédit Gentoo*]),
  [Adelie], [45], [0], [0],
  [Chinstrap], [4], [16], [0],
  [Gentoo], [0], [0], [37],
)

L'exactitude vaut $98/102 approx 0.96$, soit 96~%. Les quatre erreurs concernent des `Chinstrap` prédits `Adelie` ; la sensibilité de l'espèce `Chinstrap` est donc $16/20=80$~%. Le résultat global ne résume pas à lui seul la performance sur chaque espèce. Il décrit ce partage précis des données, sans garantir la même performance dans une autre population.


=== Forces et limites

*Une règle locale simple et flexible.* La méthode des k-NN ne suppose ni une relation linéaire, ni des distributions normales dans les classes. Il peut suivre des frontières irrégulières et permet d'expliquer une prédiction en examinant les voisins qui y participent. Cette explication dépend toutefois de la pertinence des variables et de la distance choisies.

*La difficulté des grandes dimensions.* Lorsque $p$ augmente, il devient
souvent difficile de trouver assez d'observations réellement proches. Pour
illustrer ce phénomène, supposons les données uniformes dans un cube unité de
dimension $p$. Un sous-cube de côté $h$ représente une fraction $h^p$ du volume.
Pour couvrir 10~% du volume, il faut un côté $h=0.1^(1/p)$, soit environ $0.32$
en dimension $2$, mais $0.79$ en dimension $10$. Le voisinage doit donc
s'étendre sur une grande partie de chaque coordonnée.

C'est un aspect de la malédiction de la dimension. Des variables inutiles
peuvent dégrader les distances même après standardisation. Une sélection de
variables ou une réduction de dimension peut aider, à condition d'être
apprise dans les plis d'entraînement et évaluée pour l'objectif prédictif.

*Classes rares et régions peu observées.* Un grand voisinage peut être dominé par une classe fréquente et masquer une petite région d'une classe rare. Il faut examiner les sensibilités par classe, pas seulement l'exactitude globale. Par ailleurs, la méthode des k-NN donne une prédiction même si les voisins les plus proches sont très éloignés. Ainso, une majorité nette de voix n'est pas une garantie de fiabilité hors des régions bien couvertes par l'entraînement.

*Une extrapolation limitée en régression.* Avec des poids non négatifs, la prédiction est comprise entre les réponses minimale et maximale des voisins. La méthode ne prolonge donc pas une tendance au-delà des valeurs observées comme peut le faire un modèle de régression paramétrique. L'effet est particulièrement visible près des bords du domaine des données.

*Un coût reporté sur la prédiction.* La recherche directe calcule $n$ distances à $p$ coordonnées, soit un coût de l'ordre de $n p$ pour chaque nouvelle observation, auquel s'ajoute la sélection des voisins. Un tri complet a un coût de l'ordre de $n log n$. Il faut aussi conserver les observations d'entraînement. Des structures de recherche peuvent accélérer les calculs, surtout en faible dimension, mais leur avantage diminue souvent lorsque la dimension augmente.

== Analyse discriminante de Fisher <discriminante-fisher>

=== Principe

L'analyse discriminante de Fisher étudie des groupes déjà connus à partir de
variables explicatives quantitatives. Elle construit une représentation de
faible dimension qui met en évidence les différences entre leurs moyennes,
relativement à leur dispersion interne. Elle ne découvre donc pas des classes
sans étiquettes, comme le ferait une méthode de regroupement.

Cette approche repose sur un critère géométrique, sans imposer de loi de
probabilité aux observations dans chaque classe. Elle ne doit donc pas être
confondue avec les modèles probabilistes LDA et QDA. Elle peut servir à préparer une classification, mais le choix d'une projection ne fournit pas à lui seul des probabilités de classe ni une règle d'affectation.

L'idée de Fisher est de construire un score qui est une combinaison linéaire
des variables explicatives :

$ z = a^top x, quad a in RR^p, $

où la direction $a$ rend les moyennes des groupes éloignées après projection,
tout en limitant la dispersion à l'intérieur des groupes. Ajouter une constante
au score déplacerait tous les points de la même quantité, sans modifier cette
séparation. Si l'on souhaite utiliser ce score pour classer, il faut lui
associer une règle de décision supplémentaire.

Contrairement à l'ACP, le choix de l'axe utilise les classes. L'ACP recherche une forte variance totale, alors que l'analyse discriminante de Fisher recherche un contraste entre groupes relativement à leur variabilité interne.

#example[
    Considérons deux classes équiprobables de moyennes $(0,-1)^top$ et $(0,1)^top$, avec la même covariance $diag(9, 0.25)$. Dans chaque classe, la variable $X_1$ varie beaucoup, mais sa distribution est la même pour les deux classes. La variable $X_2$ varie moins à l'intérieur de chaque classe et sépare leurs moyennes.

    La covariance totale est $diag(9, 1.25)$ : l'ACP sur les variables centrées, sans réduction, retient d'abord la direction donnée par $X_1$. La direction donnée par le critère de Fisher est $X_2$. Une direction qui conserve beaucoup de variance n'est donc pas nécessairement celle qui permet de distinguer les classes.

    #figure(
    image("../figures/discriminante_fisher.svg", width: 100%,
      alt: "Deux classes simulées présentent une grande dispersion horizontale "
        + "commune et des moyennes verticales différentes. La projection "
        + "horizontale de l'ACP superpose les classes ; la projection verticale "
        + "de Fisher les sépare."),
    caption: [Variance totale et séparation des classes. À gauche, un échantillon
      simulé ; à droite, les densités des projections sous les lois normales de
      l'exemple. Les directions indiquées sont celles du modèle théorique.],
  )
]


=== Variabilités intra-groupe et inter-groupe

#definition[
  Notons $C_g = {i : y_i=g}$ l'ensemble des indices de la classe $g$, d'effectif
  $n_g$, pour $g = 1, dots, K$. Les moyennes de classe et la moyenne globale sont données par

  $ overline(x)_g = 1/n_g sum_(i in C_g) x_i, quad
    overline(x) = 1/n sum_(i=1)^n x_i = sum_(g=1)^K n_g/n overline(x)_g. $
]

#definition[
  On définit les matrices de dispersion *intra-groupe* $W$, *inter-groupe* $B$
  et *totale* $T$ par, respectivement :

  $
    W = sum_(g=1)^K sum_(i in C_g)
        (x_i-overline(x)_g)(x_i-overline(x)_g)^top,
  $
  $
    B = sum_(g=1)^K n_g (overline(x)_g-overline(x))(overline(x)_g-overline(x))^top,
  $
  $
    T = sum_(i=1)^n (x_i-overline(x))(x_i-overline(x))^top.
  $
]

#figure(
  image("../figures/discriminante_dispersions.svg", width: 100%,
    alt: "Deux groupes de huit et six observations dans un plan. Les traits "
      + "fins relient les observations à leur moyenne de groupe, indiquée "
      + "par une croix. Les flèches épaisses vont de la moyenne globale, "
      + "indiquée par un losange, aux deux moyennes de groupe."),
  caption: [Dispersions intra-groupe et inter-groupe sur des données
    illustratives à deux variables. Les traits fins représentent les écarts
    $x_i-overline(x)_g$ qui interviennent dans $W$. Les flèches épaisses
    représentent les écarts $overline(x)_g-overline(x)$ qui interviennent dans
    $B$, avec une pondération par l'effectif $n_g$ de chaque groupe. La moyenne
    globale est donc plus proche du centre du groupe le plus nombreux.],
)

La quantité $W$ mesure les écarts de chaque observation à la moyenne de sa classe et la quantité $B$ mesure les écarts des moyennes de classe à la moyenne globale, pondérés par les effectifs. Ce sont ici des sommes de produits d'écarts, sans division par des degrés de liberté.

#property(title: [Décomposition de la dispersion])[
  La dispersion totale se décompose exactement en

  $ T = W+B. $
]

#proof[
  En écrivant $x_i-overline(x)=(x_i-overline(x)_g)+(overline(x)_g-overline(x))$
  dans chaque produit d'écarts, puis en sommant, on retrouve $W+B$.
  Les termes croisés disparaissent parce que les écarts à la moyenne somment
  à zéro dans chaque classe.
]

=== Critère de Fisher et axes discriminants

On cherche une combinaison linéaire $z_i=a^top x_i$ qui rende les moyennes
des classes éloignées, sans amplifier excessivement leur dispersion interne.
Une grande distance entre les moyennes projetées ne suffit donc pas : elle
doit être appréciée relativement à la dispersion des observations autour
de ces moyennes. On conserve ici les matrices de dispersion $W$ et $B$
définies précédemment, sans normalisation par des degrés de liberté.

*Un rapport de dispersions.* Pour une direction $a$, les moyennes des scores par groupe sont $overline(z)_g=a^top overline(x)_g$ et la moyenne globale est $overline(z)=a^top overline(x)$. On retrouve alors

$ a^top W a = sum_(g=1)^K sum_(i in C_g) (z_i-overline(z)_g)^2 quad "et" quad
a^top B a = sum_(g=1)^K n_g (overline(z)_g-overline(z))^2. $

#definition[
  Le critère de Fisher d'une direction $a$ telle que $a^top W a>0$ est

  $ J(a) = (a^top B a) / (a^top W a). $

  Un premier axe discriminant est une direction qui maximise ce rapport.
  Son score $z=a^top x$ est appelé une variable discriminante.
]

Le numérateur mesure la séparation des moyennes projetées, pondérée par les
effectifs, et le dénominateur la dispersion à l'intérieur des classes. Ainsi,
$J(a)=0$ signifie que toutes les moyennes projetées coïncident. En effet, une grande
valeur indique une séparation importante relativement à la dispersion interne.
Ce rapport est positif ou nul, mais il n'est pas borné par $1$ et ne représente
pas une probabilité de bonne classification.

Pour tout scalaire $c != 0$, on a $J(c a)=J(a)$ : le facteur $c^2$ s'annule
entre le numérateur et le dénominateur. La longueur et le signe de $a$ ne sont
donc pas déterminés par le critère. Remplacer $a$ par $-a$ retourne simplement
l'axe, sans changer la séparation.

*Du problème d'optimisation aux valeurs propres.* Supposons désormais $W$
définie positive, de sorte que $a^top W a>0$ pour tout $a != 0$. Grâce à
l'invariance par changement d'échelle, le problème précédent est équivalent à

$ "maximiser" quad a^top B a
  quad "sous la contrainte" quad a^top W a=1. $

La contrainte fixe la dispersion intra-groupe projetée à $1$. Elle ne fixe
pas la variance totale du score. Introduisons le lagrangien

$ cal(L)(a,lambda)=a^top B a-lambda(a^top W a-1). $

Puisque $W$ et $B$ sont symétriques, l'annulation du gradient par rapport à $a$
donne $2B a-2lambda W a=0$, soit

$ B a=lambda W a. $

C'est un problème de valeurs propres généralisées, i.e. on compare l'action de
$B$ à celle de $W$. Lorsque $W$ est inversible, on peut aussi écrire
$W^(-1)B a=lambda a$. En multipliant à gauche par $a^top$, on obtient
$J(a)=lambda$. La valeur propre mesure donc directement le critère atteint
sur la direction correspondante. La condition de Lagrange fournit toutefois
plusieurs directions candidates. Il nous reste à identifier celle qui maximise
le rapport.#footnote[
  Une présentation complémentaire figure dans le cours _Multivariate
  Statistics_ de Richard D. Wilkinson, section
  #link("https://rich-d-wilkinson.github.io/MATH3030/8.3-FLDA.html")[« Fisher's
  linear discriminant rule »].
]

#property[
  Si $W$ est définie positive, les valeurs propres généralisées de $(B,W)$
  sont réelles et positives ou nulles. En les ordonnant
  $lambda_1 >= lambda_2 >= dots >= lambda_p >= 0$, on a

  $ max_(a != 0) J(a)=lambda_1. $

  Un vecteur propre généralisé associé à $lambda_1$ définit donc un premier
  axe discriminant.
]

#proof[
  La décomposition spectrale de $W$ définit sa racine carrée symétrique
  $W^(1/2)$ et son inverse $W^(-1/2)$. Posons $u=W^(1/2)a$ et
  $M=W^(-1/2)B W^(-1/2)$. Alors

  $ J(a)=(u^top M u)/(u^top u). $

  La matrice $M$ est symétrique semi-définie positive. Dans une base
  orthonormée de ses vecteurs propres $u_1,dots,u_p$, écrivons
  $u=sum_(j=1)^p c_j u_j$. Le rapport devient

  $ J(a)=(sum_(j=1)^p lambda_j c_j^2)/(sum_(j=1)^p c_j^2)
    <= lambda_1. $

  L'égalité est atteinte pour $u=u_1$, donc pour $a=W^(-1/2)u_1$.
  Enfin, $M u_j=lambda_j u_j$ équivaut à
  $B a_j=lambda_j W a_j$ avec $a_j=W^(-1/2)u_j$. Ce sont bien
  les valeurs propres généralisées recherchées.
]

Cette transformation donne aussi une lecture géométrique. En effet, appliquer
$W^(-1/2)$ aux données ramène la dispersion intra-groupe à la matrice identité.
Dans cet espace transformé, on cherche les directions où les moyennes des
classes, pondérées par leurs effectifs, sont les plus dispersées. Ce n'est
donc pas une ACP du nuage initial, mais une recherche de dispersion des
centres des classes après correction de la dispersion interne.#footnote[
  Voir la section « Mathematical formulation of LDA dimensionality reduction »
  de la #link("https://scikit-learn.org/stable/modules/lda_qda.html#mathematical-formulation-of-lda-dimensionality-reduction")[documentation
  de scikit-learn] pour cette interprétation géométrique.
]

*Construire les axes suivants.* Le deuxième axe maximise le même critère
parmi les directions satisfaisant $a^top W a_1=0$, et ainsi de suite.
On peut choisir les vecteurs $a_k$ de façon à vérifier

$ a_k^top W a_k=1, quad a_k^top W a_ell=0 quad "si" quad k != ell. $

Les axes sont ainsi orthogonaux pour la métrique définie par $W$, mais pas
nécessairement pour le produit scalaire usuel. En effet, ici, on n'impose pas
$a_k^top a_ell=0$. Chaque nouvel axe décrit un contraste entre groupes
complémentaire aux précédents, avec $J(a_k)=lambda_k$. En cas de valeurs
propres égales, les axes associés ne sont pas uniques. Différentes bases
du même sous-espace discriminant conviennent.

*Le cas de deux classes.* Posons $d=overline(x)_2-overline(x)_1$. Puisque
$n=n_1+n_2$, les écarts des moyennes à la moyenne globale sont

$ overline(x)_1-overline(x)=-(n_2/n)d, quad
  overline(x)_2-overline(x)=(n_1/n)d. $

En remplaçant dans la définition de $B$, on trouve

$ B=((n_1 n_2)/n)d d^top quad "et" quad
  J(a)=((n_1 n_2)/n) (a^top d)^2/(a^top W a). $

Si $d != 0$, la matrice $B$ est de rang $1$. Il existe donc un seul axe
discriminant de valeur propre positive, qui vérifie

$ a_1 prop W^(-1)d, quad
  lambda_1=((n_1 n_2)/n)d^top W^(-1)d. $

La différence des moyennes donne le contraste recherché, tandis que $W^(-1)$
tient compte des dispersions et des corrélations internes. Si $W$ est
diagonale, le coefficient de la variable $j$ est proportionnel à
$d_j/W_(j j)$. Un grand écart de moyennes peut donc être compensé par une
grande dispersion intra-groupe. Si $d=0$, tous les rapports valent zéro et donc
le critère ne privilégie aucune direction.

#example[
  Considérons deux classes d'effectifs $n_1=n_2=10$, dont les moyennes et la
  dispersion intra-groupe sont

  $ overline(x)_1=(0,0)^top, quad overline(x)_2=(2,1)^top,
    quad W=mat(16,0;0,4). $

  On obtient $d=(2,1)^top$ et $B=5d d^top=mat(20,10;10,5)$. La direction
  optimale est proportionnelle à

  $ W^(-1)d=(1/8,1/4)^top prop (1,2)^top. $

  On peut donc utiliser le score $z=x_1+2x_2$. La deuxième variable reçoit
  un coefficient plus élevé malgré son plus petit écart de moyennes :
  sa dispersion interne est quatre fois plus faible.

  Pour $a=(1,2)^top$, les moyennes projetées sont $0$ et $4$, d'où

  $ a^top B a=80, quad a^top W a=32, quad J(a)=80/32=2.5. $

  En utilisant seulement $x_1$ ou seulement $x_2$, on obtiendrait
  respectivement $20/16=1.25$ et $5/4=1.25$. La combinaison est donc plus
  discriminante au sens de Fisher que chacune des deux variables isolées.
  Pour respecter la normalisation $a_1^top W a_1=1$, on prend
  $a_1=(1,2)^top/sqrt(32)$, sans changer la valeur du critère.
]

*Combien d'axes peut-on obtenir ?* Avec plusieurs classes, les moyennes
centrées vérifient la relation

$ sum_(g=1)^K n_g (overline(x)_g-overline(x))=0. $

Ces $K$ vecteurs sont donc linéairement dépendants et engendrent un espace
de dimension au plus $K-1$. Puisque $W$ est définie positive, le nombre $r$
de valeurs propres généralisées strictement positives est

$ r=rang(B) <= min(p,K-1). $

Pour trois classes et quatre variables, il existe au plus deux axes
discriminants de valeur propre positive. Il peut n'y en avoir qu'un si
les trois moyennes sont alignées, ou aucun si elles coïncident. Multiplier
le nombre de variables ne permet donc pas de dépasser la limite de $K-1$
axes décrivant des différences de moyennes.

*Projeter et interpréter les observations.* Pour $1 <= q <= r$, réunissons
  les $q$ premières directions en une matrice $A=(a_1,dots,a_q)$ de taille
  $p times q$. Les coordonnées discriminantes centrées sont

  $ z_i=A^top (x_i-overline(x)) in RR^q, quad "avec" quad
    z_(i k)=a_k^top (x_i-overline(x)). $

Il s'agit d'une réduction de dimension supervisée, puisque les étiquettes
des classes interviennent dans le calcul de $A$. Le centrage global déplace
l'origine des scores sans changer les écarts
entre observations ni le critère. Les dispersions dans cet espace vérifient

$ A^top W A=I_q, quad "et" quad
  A^top B A=diag(lambda_1,dots,lambda_q). $

Les dispersions intra-groupes sont ainsi mises sur la même échelle, tandis
que les dispersions inter-groupes décroissent d'un axe au suivant. Les
produits croisés intra-groupes sont nuls après regroupement des classes.
Cela ne signifie cependant ni absence de corrélation dans chaque classe séparément,
ni indépendance des scores. On interprète un plan discriminant en examinant
les positions des moyennes projetées, le recouvrement des nuages et les
variables qui contribuent aux contrastes. Les coefficients bruts dépendent
des unités et des corrélations. Ainsi, leur valeur seule ne mesure pas l'importance
d'une variable.

Lorsque $r>0$, on peut résumer le poids relatif de l'axe $k$ par

$ lambda_k/(sum_(ell=1)^r lambda_ell). $

Par exemple, si $lambda_1=9$ et $lambda_2=1$, ces valeurs propres attribuent 90~% de leur poids au premier axe. Ce pourcentage n'est ni une proportion de variance totale expliquée au sens de l'ACP, ni un taux de bonne classification. Avec deux
classes de moyennes distinctes, l'unique axe représente toujours 100~% de
cette somme, même si les distributions projetées se recouvrent fortement.

#remark[
  Le critère de Fisher se définit sans hypothèse de normalité, mais privilégie les différences de moyennes. Si deux classes ont la même moyenne et des dispersions différentes, $B=0$ alors qu'une autre règle pourrait peut-être les distinguer. De plus, un axe est une règle de calcul de score, pas encore une règle d'affectation : un seuil, ou un classificateur utilisant les coordonnées projetées, reste à définir. Cette étape ne découle pas du seul critère de Fisher et n'impose pas de choisir un modèle LDA ou QDA.
]

*En pratique.* On calcule les moyennes, les matrices $W$ et $B$ sur l'entraînement, on résout le problème aux valeurs propres généralisées, puis on conserve les $q$ directions choisies. Pour une nouvelle observation, on réutilise la même moyenne globale et la même matrice $A$, sans avoir besoin de son étiquette. Si $q$ est choisi pour prédire, on le sélectionne par validation et on réestime la projection dans chaque pli d'entraînement.

L'écriture $W^(-1)B$ est surtout théorique : les logiciels peuvent résoudre
le problème généralisé sans former explicitement l'inverse. Si $W$ est
singulière, l'argument précédent ne s'applique plus et si elle est presque
singulière, les axes peuvent être instables. On peut alors supprimer des
redondances ou régulariser la dispersion intra-groupe.

*Séparation visuelle et prédiction.* Un beau plan discriminant construit avec
toutes les étiquettes ne prouve pas une bonne généralisation. La projection
doit être estimée dans chaque entraînement, et la qualité des décisions doit
être mesurée sur des observations laissées de côté. Enfin, les axes décrivent
des contrastes associés aux classes : ils ne démontrent ni une relation
causale ni l'existence de groupes sans recouvrement.

=== Classification dans l'espace de Fisher

Les axes de Fisher fournissent une représentation supervisée des observations.
Pour en faire un classificateur, il faut leur associer une règle d'affectation.
Une règle simple consiste à choisir la classe dont le centre projeté est
le plus proche de l'observation à classer. On compare donc une observation
aux moyennes des classes, et non à ses plus proches voisins individuels.

#definition[
  Soit $A=(a_1,dots,a_q)$ la matrice des axes retenus, normalisés de sorte que
  $A^top W A=I_q$. Pour une nouvelle observation $x$, on définit son score
  vectoriel et les centres projetés des classes par

  $ z(x)=A^top (x-overline(x)), quad
    m_g=A^top (overline(x)_g-overline(x)). $

  Le critère d'affectation au centre le plus proche est la distance
  euclidienne au carré dans l'espace discriminant :

  $ D_g (x)=norm(z(x)-m_g)^2
    =sum_(k=1)^q [a_k^top (x-overline(x)_g)]^2. $

  La règle de classification est

  $ hat(g)_F (x)=argmin_(g in {1,dots,K}) D_g (x). $
]

Ici, le $F$ rappelle que les distances sont calculées dans l'espace de
Fisher. En cas d'égalité, on fixe une règle de départage avant l'évaluation,
par exemple la première classe dans un ordre prédéfini. La règle du centre
projeté le plus proche est une manière de compléter la projection de
Fisher, et non une conséquence imposée par la maximisation de $J$.#footnote[
  Voir la règle d'affectation et son extension à plusieurs projections dans
  le cours de Richard D. Wilkinson,
  #link("https://rich-d-wilkinson.github.io/MATH3030/8.3-FLDA.html")[« Fisher's
  linear discriminant rule »].
]

*Pourquoi normaliser les axes ?* Le critère $J(a)$ ne fixe pas la longueur
de $a$, mais une distance utilisant plusieurs scores dépend de leurs
échelles relatives. Multiplier un seul axe par $10$ multiplierait sa
contribution à $D_g$ par $100$ et pourrait changer la classe prédite.
La convention $A^top W A=I_q$ met les axes sur une même échelle de dispersion
intra-groupe. On ne multiplie donc pas les distances par les valeurs propres.
Changer le signe d'un axe, ou appliquer une rotation orthogonale commune aux
scores et aux centres, ne change pas les distances ni les décisions.

*Deux classes et un seul axe.* Supposons les moyennes projetées ordonnées
$m_1<m_2$. Comparer $(z-m_1)^2$ et $(z-m_2)^2$ revient à couper l'axe au
milieu des deux centres :

$ "prédire la classe 2 si" quad z(x)>(m_1+m_2)/2. $

Pour le score non centré $s(x)=a_1^top x$, la même règle s'écrit

$ "prédire la classe 2 si" quad
  s(x)>1/2 a_1^top (overline(x)_1+overline(x)_2). $

Si l'on inverse le signe de l'axe, l'ordre des centres et le sens de
l'inégalité s'inversent ensemble. La décision, elle, reste inchangée.

#example[
  Reprenons les moyennes $(0,0)^top$ et $(2,1)^top$ de l'exemple précédent,
  et le score de Fisher $s(x)=x_1+2x_2$. Les centres projetés non centrés
  valent $0$ et $4$ : le seuil est donc $2$.

  Pour $x=(1,1)^top$, le score vaut $3$ et les distances au carré aux centres
  valent $9$ et $1$ : on prédit la classe $2$. Pour $x=(0.5,0.5)^top$, le
  score vaut $1.5$, avec des distances au carré $2.25$ et $6.25$ : on prédit
  la classe $1$. La frontière est la droite $x_1+2x_2=2$.

  Ici, il n'y a qu'un axe : le facteur commun $1/sqrt(32)$ qui le normalise
  multiplie toutes les distances au carré par $1/32$ et ne change donc pas
  la décision.
]

*Plusieurs classes.* Dans un plan discriminant, les centres découpent le plan
en régions de proximité. La frontière entre deux centres distincts $m_g$ et
$m_h$ vérifie

$ D_g (x)=D_h (x)
  quad <=> quad
  2(m_h-m_g)^top z(x)=norm(m_h)^2-norm(m_g)^2. $

Il s'agit d'une droite dans un plan discriminant, ou d'un hyperplan en
dimension supérieure. Seules les portions où aucune autre classe n'est
plus proche constituent les frontières effectives des régions de décision.

#remark[
  Cette règle est géométrique : elle ne suppose pas de lois normales et ne
  produit pas de probabilités a posteriori. Les effectifs interviennent
  dans l'estimation de $W$, de $B$ et des axes, mais la comparaison des
  distances n'ajoute aucun terme de priorité à une classe ni de coût d'erreur.
  Une petite distance au centre le plus proche n'est donc pas une probabilité
  de classification correcte. Si les classes sont multimodales ou de formes
  très différentes, les résumer par leurs centres peut être insuffisant.
]

Toutes les étapes sont apprises sur l'entraînement : centrage, axes et
centres projetés. L'étiquette d'une observation de test ne sert qu'à évaluer
la décision. Le nombre d'axes $q$ et le choix de la règle d'affectation font
partie de la méthode ; si on les compare, on utilise une validation interne
à l'entraînement, en réestimant les axes et les centres dans chaque pli.

=== Étude de cas : Palmer Penguins

On cherche à prédire l'espèce, `Adelie`, `Chinstrap` ou `Gentoo`, à partir
de quatre mesures : `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`
et `body_mass_g`. Le fichier `penguins.csv` contient $344$
manchots ; le retrait des deux observations incomplètes pour ces mesures
laisse $342$ individus. Ni `sex`, ni `island`, ni `year` ne sont utilisés.


#table(
  columns: (1.3fr, 1fr, 1fr, 1fr), align: center,
  table.header([*Espèce*], [*Total*], [*Entraînement*], [*Test*]),
  [Adelie], [151], [106], [45],
  [Chinstrap], [68], [48], [20],
  [Gentoo], [123], [86], [37],
  [*Total*], [*342*], [*240*], [*102*],
)

*Apprendre le plan discriminant.* Avec $K=3$ classes et $p=4$ variables,
on conserve les deux axes possibles, soit $q=2$, fixé avant l'évaluation.
Les matrices $W$ et $B$, la moyenne globale et les centres des espèces sont
calculés sur les $240$ observations d'entraînement seulement. On
résout le problème $B a=lambda W a$ et vérifie $A^top W A=I_2$.
Les mesures sont dans leurs unités d'origine et la normalisation des
axes tient compte de la dispersion intra-groupe et des corrélations.

Les deux valeurs propres sont environ $13.783$ et $2.749$, soit 83,37~%
et 16,63~% de leur somme. Le second axe porte donc un contraste que le
premier ne résume pas. Ces pourcentages décrivent le critère de Fisher,
pas l'exactitude de la classification.

Avec l'orientation des axes fixée, les centres projetés sont :

#table(
  columns: (1.4fr, 1fr, 1fr), align: center,
  table.header([*Espèce*], [*Axe 1*], [*Axe 2*]),
  [Adelie], [$0.20829$], [$-0.07633$],
  [Chinstrap], [$0.10755$], [$0.20857$],
  [Gentoo], [$-0.31676$], [$-0.02234$],
)

Le premier axe oppose surtout `Gentoo` aux deux autres espèces. Le second
sépare plus nettement les centres `Adelie` et `Chinstrap`. Les coordonnées
sont petites parce que la somme des dispersions intra-groupes vaut $1$
sur chaque axe. On pourrait afficher des scores multipliés par une même
constante sans modifier les décisions. Le signe des axes est également
conventionnel ; il ne change pas les distances aux centres.

#example[
  Considérons une nouvelle observation. Ses mesures, dans l'ordre retenu, sont

  $ x=(40.3,18,195,3250)^top. $

  On soustrait la moyenne de l'entraînement, puis on applique les deux axes
  appris. On obtient environ $z(x)=(0.18,0.017)^top$. Les distances
  euclidiennes au carré aux trois centres sont

  $ D_"Adelie" (x) approx 0.01, quad
    D_"Chinstrap" (x) approx 0.04, quad
    D_"Gentoo" (x) approx 0.25. $

  La plus petite distance est celle du centre `Adelie` : on prédit donc
  cette espèce. L'étiquette réelle, consultée seulement pour vérifier la
  prédiction, est bien `Adelie`. Les distances ont été calculées avec les
  coordonnées non arrondies.
]

#block(breakable: false)[
Les prédictions des $102$ observations de test donnent la matrice de confusion suivante :

#table(
  columns: (1.3fr, 1fr, 1fr, 1fr), align: center,
  table.header([*Espèce réelle*], [*Prédit Adelie*], [*Prédit Chinstrap*],
    [*Prédit Gentoo*]),
  [Adelie], [45], [0], [0],
  [Chinstrap], [2], [18], [0],
  [Gentoo], [0], [0], [37],
)
]

L'exactitude vaut $100/102 approx 98.04$~% et le taux d'erreur
$2/102 approx 1.96$~%. Les deux erreurs sont des `Chinstrap` classés
`Adelie` : la sensibilité de `Chinstrap` est $18/20=90$~%. Celui des deux autres espèces vaut 100~% sur ce test.

Ce résultat décrit un partage précis des données. Les deux axes et
la règle de proximité ont été fixés avant le test ; celui-ci n'a servi ni
à les choisir ni à les ajuster. Pour comparer un seul axe à deux axes, ou
une autre règle dans l'espace projeté, il faudrait une validation sur les
seules données d'entraînement.

== Analyse discriminante probabiliste : LDA et QDA <discriminante-probabiliste>

=== Principe : modéliser les classes pour prédire

L'analyse discriminante probabiliste part d'une autre démarche que celle de
Fisher : elle modélise la distribution des variables explicatives dans chaque
classe, puis en déduit la probabilité d'appartenance d'une observation à chaque
classe. Son objectif est de construire une règle de classification, et non
de maximiser directement un rapport de dispersions.

On dispose de $n$ couples d'entraînement $(x_i,y_i)$, avec $x_i in RR^p$ et
$y_i in {1,dots,K}$. On note $cal(I)_g={i:y_i=g}$ l'ensemble des indices de la
classe $g$ et $n_g=abs(cal(I)_g)$ son effectif. Les paramètres sont estimés
sur ces données étiquetées ; pour une nouvelle observation, seule la mesure
$x$ est disponible.

On note $f_g (x)$ la densité de $X$ conditionnellement à $Y=g$, et
$pi_g=prob(Y=g)$ la probabilité a priori de la classe $g$. La formule de Bayes
donne la probabilité *a posteriori*

$ eta_g (x) = prob(Y=g bar.v X=x)
  = (pi_g f_g (x)) / (sum_(h=1)^K pi_h f_h (x)). $

La probabilité a priori décrit la fréquence d'une classe *avant* d'observer
$x$. La densité $f_g (x)$ mesure à quel point ces mesures sont compatibles
avec la distribution de cette classe. La probabilité a posteriori combine
ces deux informations. Une densité n'est pas une probabilité ponctuelle :
pour une variable continue, $prob(X=x bar.v Y=g)=0$, même lorsque $f_g (x)>0$.

#example[
  À une valeur $x$ donnée, supposons $f_1 (x)=0.1$ et $f_2 (x)=0.4$.
  Avec des probabilités a priori égales, $eta_2 (x)=0.4/(0.1+0.4)=0.8$.

  Si la classe 2 ne représente que 10~% de la population visée, alors

  $ eta_2 (x)=(0.1 times 0.4)/(0.9 times 0.1+0.1 times 0.4)
    =4/13 approx 0.308. $

  Les mesures sont quatre fois plus compatibles avec la classe 2 qu'avec
  la classe 1, mais cela ne suffit pas à compenser sa rareté. Avec des coûts
  d'erreur égaux, on prédit la classe 1.
]

Sous la perte 0–1, on choisit la classe de plus grande probabilité a posteriori.
La LDA et la QDA utilisent toutes deux des densités normales multivariées,
mais diffèrent par leurs hypothèses sur les covariances : une covariance
commune pour la LDA, une covariance propre à chaque classe pour la QDA.
Elles peuvent s'appliquer directement aux variables explicatives ; une
projection préalable sur les axes de Fisher n'est pas nécessaire.

Pour une classe de moyenne $mu_g$ et de covariance définie positive $Sigma_g$,
la densité normale multivariée est

$ f_g (x)=1/((2 pi)^(p/2) det(Sigma_g)^(1/2))
  exp(-1/2 (x-mu_g)^top Sigma_g^(-1)(x-mu_g)). $

Le terme quadratique mesure l'éloignement à la moyenne dans la géométrie de
la classe ; le déterminant intervient dans la normalisation de la densité.
LDA et QDA sont ainsi des modèles *génératifs* : ils décrivent la loi jointe
par les probabilités des classes et les lois de $X$ dans chaque classe,
puis en déduisent la prédiction de $Y$.

=== Analyse discriminante linéaire (LDA)

#definition(title: [Modèle LDA])[
  L'analyse discriminante linéaire, ou *LDA* (_Linear Discriminant Analysis_),
  modélise les variables explicatives conditionnellement à la classe :

  $ X bar.v (Y=g) tilde.op cal(N)_p (mu_g, Sigma), quad prob(Y=g) = pi_g. $

  Chaque classe a sa propre moyenne $mu_g$, mais toutes partagent la même matrice
  de covariance $Sigma$, supposée définie positive. Les probabilités *a priori*
  $pi_g > 0$ somment à $1$ et décrivent les fréquences des classes avant
  d'observer les mesures. La normalité est supposée *dans chaque classe* : la
  distribution globale, mélange de ces classes, n'a pas à être normale.
  Les variables peuvent être corrélées à l'intérieur des classes : les
  covariances hors diagonale ne sont pas supposées nulles.
]

Le dénominateur de la formule de Bayes étant commun aux classes, maximiser
la probabilité a posteriori revient à maximiser
$log pi_g + log f_g (x)$. On développe la distance quadratique :

$ (x-mu_g)^top Sigma^(-1)(x-mu_g)
  = x^top Sigma^(-1)x-2x^top Sigma^(-1)mu_g+mu_g^top Sigma^(-1)mu_g. $

Avec une covariance commune, le terme quadratique
$-1/2 x^top Sigma^(-1) x$ est identique dans toutes les classes et s'élimine de
la comparaison. Il reste les *scores discriminants*#footnote[
  Les formulations probabilistes de la LDA et de la QDA sont présentées dans
  la #link("https://scikit-learn.org/stable/modules/lda_qda.html")[documentation
  de scikit-learn, _Linear and Quadratic Discriminant Analysis_].
] :

$ delta_g (x) = x^top Sigma^(-1) mu_g
  - 1/2 mu_g^top Sigma^(-1) mu_g + log pi_g. $

Chaque score est affine en $x$, d'où la règle

$ hat(g)(x) = argmax_(g in {1, dots, K}) hat(delta)_g (x). $

La frontière entre les classes $g$ et $h$ est définie par
$hat(delta)_g (x) = hat(delta)_h (x)$ : c'est une droite en dimension deux,
un plan en dimension trois, et plus généralement un hyperplan. Les probabilités
estimées se calculent à partir des mêmes scores :

$ hat(eta)_g (x) = exp(hat(delta)_g (x)) /
  (sum_(h=1)^K exp(hat(delta)_h (x))). $

Avec plus de deux classes, seules les portions où aucun autre score n'est
supérieur forment les frontières effectives de décision. Une région de classe
est une intersection de demi-espaces ; elle est donc convexe, éventuellement
vide. Dans un cas dégénéré, deux scores peuvent aussi être identiques partout
ou ne jamais être égaux.

Le score lui-même n'est pas une probabilité : il peut être négatif ou supérieur
à $1$. L'ajout d'une même quantité à tous les scores ne change ni leur ordre
ni les probabilités. Pour calculer ces dernières sans débordement numérique,
on soustrait le score maximal avant d'appliquer les exponentielles.

=== Estimation des paramètres sur l'entraînement

Les moyennes et les proportions empiriques sont

$ hat(mu)_g=overline(x)_g=1/n_g sum_(i in cal(I)_g)x_i,
  quad hat(pi)_g=n_g/n. $

Pour $n_g>1$, la covariance empirique de la classe $g$ est

$ S_g=1/(n_g-1) sum_(i in cal(I)_g)
  (x_i-overline(x)_g)(x_i-overline(x)_g)^top. $

En LDA, on regroupe les sommes de produits d'écarts pour estimer la covariance
commune :

$ hat(Sigma)=W/(n-K)
  =(sum_(g=1)^K (n_g-1) S_g)/(n-K). $

La matrice $W$ désigne la même somme de produits d'écarts intra-groupes que
dans la section sur Fisher. Réutiliser cette quantité ne revient pas à
appliquer son critère : elle sert ici à estimer une covariance du modèle.
La covariance commune regroupe les dispersions *à l'intérieur* des classes ;
elle ne doit pas être remplacée par la covariance totale, qui inclut leurs
différences de moyenne. Les proportions empiriques sont adaptées si
l'échantillon représente les fréquences visées. Si le plan d'échantillonnage
a surreprésenté certaines classes, les probabilités a priori doivent être
choisies en tenant compte de la population d'utilisation.

La covariance commune est donc une moyenne des covariances de classe pondérée
par leurs degrés de liberté, et non leur moyenne arithmétique lorsque les
effectifs diffèrent. En QDA, on conserve au contraire chaque estimation
$hat(Sigma)_g=S_g$.

Ces formules utilisent les estimateurs usuels non biaisés des covariances.
Les estimateurs du maximum de vraisemblance divisent les mêmes sommes par
$n$ en LDA et par $n_g$ en QDA. Les deux conventions doivent être distinguées :
elles peuvent modifier les probabilités, et parfois les décisions. Les
calculs R de cette section utilisent `method = "moment"`, correspondant aux
diviseurs $n-K$ et $n_g-1$.

#example[
  *Estimer une LDA à une variable.* Trois observations de classe 1 valent
  $-1,0,1$ ; trois observations de classe 2 valent $1,2,3$. On a
  $hat(mu)_1=0$, $hat(mu)_2=2$ et $hat(pi)_1=hat(pi)_2=1/2$.
  Les deux sommes des carrés intra-classes valent $2$, donc

  $ hat(sigma)^2=(2+2)/(6-2)=1. $

  La différence des scores estimés est alors
  $hat(delta)_2 (x)-hat(delta)_1 (x)=2x-2$. Pour $x=1.5$, elle vaut $1$ et
  $hat(eta)_2 (x)=1/(1+exp(-1)) approx 0.731$ : on prédit la classe 2.

  La variance globale des six observations vaut $2$, car elle inclut aussi
  l'écart entre les moyennes des classes. L'utiliser à la place de la variance
  intra-classe modifierait les probabilités et ne correspondrait pas au
  modèle ajusté ci-dessus.
]

Pour classer de nouvelles observations, on réutilise les mêmes moyennes,
covariances et probabilités a priori. Les mesures du test ne servent pas
à réestimer ces paramètres. En pratique, on résout des systèmes linéaires
et on utilise des factorisations matricielles plutôt que de former
explicitement les inverses indiquées dans les formules.

=== Règle de classification et seuil de décision

*La géométrie de la LDA.* Lorsque les probabilités a priori sont égales, la
règle choisit la moyenne de classe la plus proche au sens de la distance de
Mahalanobis :

$ d_g^2(x) = (x-mu_g)^top Sigma^(-1)(x-mu_g). $

Cette distance corrige les échelles et les corrélations. Il ne s'agit donc pas,
en général, de choisir la moyenne la plus proche pour la distance euclidienne
sur les variables brutes. Avec des probabilités a priori différentes, la règle
minimise $d_g^2(x) - 2 log pi_g$.

Pour deux classes, notons

$ a = Sigma^(-1)(mu_2-mu_1), quad z=a^top x. $

La différence des scores s'écrit

$ delta_2 (x)-delta_1 (x)
  = z - 1/2 a^top (mu_1+mu_2) + log(pi_2/pi_1). $

On prédit la classe $2$ lorsque

$ z > 1/2 a^top (mu_1+mu_2) - log(pi_2/pi_1). $

À probabilités a priori égales, le seuil est le milieu des deux moyennes
projetées. Si la classe $2$ est plus rare, le seuil augmente : il faut des
mesures plus favorables à cette classe pour la choisir.

Les probabilités et les scores sont reliés par les *log-cotes* :

$ log((eta_2 (x))/(eta_1 (x)))=delta_2 (x)-delta_1 (x), quad
  eta_2 (x)=1/(1+exp(-(delta_2 (x)-delta_1 (x)))). $

Une différence de scores nulle donne une probabilité de $1/2$ ; une différence
de $log(9)$ donne $eta_2 (x)=0.9$. Les log-cotes sont affines en $x$, comme en
régression logistique. Les procédures d'estimation diffèrent cependant :
la LDA estime les distributions de $X$ dans les classes, tandis que la
régression logistique modélise directement les probabilités conditionnelles
de classe sans imposer ces distributions normales.

#example(breakable: true)[
  *Déplacer le seuil en changeant les probabilités a priori.* Reprenons
  $mu_1=0$, $mu_2=2$ et $sigma^2=1$, désormais fixés, en faisant varier
  seulement les proportions de classes. Le seuil sur $x$ est

  $ t=1+1/2 log(pi_1/pi_2), quad "et l'on prédit 2 si" quad x>t. $

  #block(breakable: false)[
    #table(
      columns: (0.8fr, 0.8fr, 1fr, 1.4fr, 1fr), align: center,
      table.header([*$pi_1$*], [*$pi_2$*], [*Seuil $t$*],
        [*$eta_2 (1.5)$*], [*Classe*]),
      [0,50], [0,50], [1,000], [0,731], [Classe 2],
      [0,90], [0,10], [2,099], [0,232], [Classe 1],
      [0,10], [0,90], [−0,099], [0,961], [Classe 2],
    )
  ]

  Le même point peut donc changer de classe prédite sans que les moyennes
  ni les variances aient changé. Fixer des probabilités a priori égales est
  un choix de population ou de pondération ; ce n'est pas toujours une façon
  neutre de traiter un échantillon déséquilibré.
]

#remark(title: [Un lien avec Fisher, pas une identité de démarches])[
  Dans le cas de deux
  classes de moyennes empiriques distinctes, si l'on estime les moyennes par
  ces moyennes empiriques et la covariance commune par $W/(n-2)$ avec $W$
  inversible, la direction estimée
  de la LDA est proportionnelle à $W^(-1)(overline(x)_2-overline(x)_1)$ :
  on retrouve la direction de Fisher. Cette correspondance algébrique ne
  confond pas les méthodes. Fisher optimise un critère de projection ; la
  LDA part d'un modèle probabiliste qui fournit aussi les probabilités de
  classe et le seuil de décision, en tenant compte des probabilités a priori.
]

#example[
  Supposons $mu_1=(0,0)^top$, $mu_2=(2,1)^top$,
  $Sigma=diag(1,4)$ et $pi_1=pi_2=0.5$. Alors

  $ a=(2,0.25)^top, quad
    delta_2 (x)-delta_1 (x)=2x_1+0.25x_2-2.125. $

  La frontière est la droite $2x_1+0.25x_2=2.125$. Pour $x=(1,1)^top$,
  la différence vaut $0.125$ : on choisit la classe $2$, avec une probabilité
  $eta_2 (x)=1/(1+exp(-0.125)) approx 0.531$. La décision est donc peu tranchée.
  Pour $x=(1,0)^top$, la différence vaut $-0.125$ et l'on choisit la classe $1$.
]

*Tenir compte des coûts.* Dans une classification binaire, appelons la classe
$2$ « positive ». Notons $C_"FP"$ le coût d'un faux positif et $C_"FN"$ celui
d'un faux négatif, les décisions correctes ayant un coût nul. Les coûts
conditionnels des deux décisions sont

$ R("prédire 2" bar.v x) = C_"FP" (1-eta_2 (x)), quad
  R("prédire 1" bar.v x) = C_"FN" eta_2 (x). $

Pour des coûts strictement positifs, on prédit donc la classe $2$ si

$ eta_2 (x) > C_"FP"/(C_"FP"+C_"FN"). $

Si manquer un produit défectueux coûte quatre fois plus qu'une fausse alerte,
on prend $C_"FN"=4$ et $C_"FP"=1$, ce qui donne un seuil de $0.20$ au lieu de
$0.50$. On détecte alors davantage de défauts, au prix de davantage de fausses
alertes. Les probabilités a priori figurent déjà dans les probabilités
a posteriori : il ne faut pas les appliquer une seconde fois à ce seuil.

En LDA binaire, le seuil correspondant sur le score $z$ devient

$ z>1/2 a^top (mu_1+mu_2)-log(pi_2/pi_1)+log(C_"FP"/C_"FN"). $

Dans l'exemple précédent avec $pi_2=0.1$, ces coûts déplacent le seuil sur
$x$ de $2.099$ à $1+1/2 log(9/4) approx 1.405$. Le point $x=1.5$ est alors
classé positif, bien que $eta_2 (1.5) approx 0.232$ soit inférieur à $0.5$.
Les probabilités décrivent le modèle ; la décision dépend aussi des coûts.

Avec plusieurs classes, si $L(a,g)$ est le coût de prédire $a$ lorsque la
vraie classe est $g$, on choisit plus généralement

$ hat(g)(x)=argmin_(a in {1,dots,K}) sum_(g=1)^K L(a,g)hat(eta)_g (x). $

Sous la perte 0–1, ce coût conditionnel vaut $1-hat(eta)_a (x)$ et on retrouve
le choix de la classe la plus probable. Une règle de départage fixée complète
la définition lorsque plusieurs décisions ont le même coût.

=== Analyse discriminante quadratique (QDA)

#definition(title: [Modèle QDA])[
  La *QDA* (_Quadratic Discriminant Analysis_) autorise une covariance propre
  à chaque classe :

  $ X bar.v (Y=g) tilde.op cal(N)_p (mu_g, Sigma_g). $

  Chaque matrice $Sigma_g$ est supposée définie positive. Les probabilités
  a priori $pi_g>0$ somment à $1$, comme en LDA.
]

Les classes peuvent donc avoir des dispersions et des orientations différentes.
En supprimant seulement les termes communs à toutes les classes, on obtient

$ delta_g^"QDA" (x) = -1/2 log det(Sigma_g)
  -1/2 (x-mu_g)^top Sigma_g^(-1)(x-mu_g) + log pi_g. $

Les trois termes jouent des rôles distincts. La distance de Mahalanobis
favorise les points proches du centre dans la géométrie de la classe.
Le terme $-1/2 log det(Sigma_g)$ tient compte de l'étalement de la densité :
une classe très dispersée ne peut pas être avantagée uniquement parce que
ses distances standardisées sont petites. Enfin, $log pi_g$ tient compte
de sa fréquence dans la population visée.

Le terme en $x$ au carré ne s'annule généralement plus entre deux classes.
Les frontières peuvent être des courbes quadratiques en dimension deux, ou des
surfaces quadratiques en dimension supérieure. Si les covariances sont égales,
on retrouve la règle linéaire.

Plus précisément, en posant

$ b_g=-1/2 mu_g^top Sigma_g^(-1)mu_g
      -1/2 log det(Sigma_g)+log pi_g, $

la différence de deux scores vaut

$ delta_g^"QDA" (x)-delta_h^"QDA" (x)
  &= -1/2 x^top (Sigma_g^(-1)-Sigma_h^(-1))x \
  &quad +(Sigma_g^(-1)mu_g-Sigma_h^(-1)mu_h)^top x+b_g-b_h. $

Les produits $x_j x_ell$ issus des termes hors diagonale permettent notamment
des frontières inclinées ou courbes. Une région prédite peut être non convexe,
voire composée de plusieurs morceaux. Les probabilités a posteriori sont
obtenues par la même normalisation exponentielle qu'en LDA, en utilisant les
scores QDA estimés.

#example[
  *Des moyennes identiques, mais des dispersions différentes.* Avec une seule
  variable, supposons

  $ X bar.v (Y=1) tilde.op cal(N)(0,1), quad
    X bar.v (Y=2) tilde.op cal(N)(0,4), quad pi_1=pi_2=1/2. $

  Les variances sont $1$ et $4$ ; les deux moyennes valent zéro. La différence
  des scores est

  $ delta_2^"QDA" (x)-delta_1^"QDA" (x)=-log(2)+3/8 x^2. $

  On prédit donc la classe 2 lorsque

  $ abs(x)>sqrt(8 log(2)/3) approx 1.360. $

  La classe 1 est choisie près de zéro, où sa densité est plus concentrée ;
  la classe 2 est choisie dans les deux régions extérieures. En $x=0$,
  $eta_2 (0)=1/3$ ; en $x=2$, $eta_2 (2) approx 0.691$.

  Une LDA ayant ces mêmes moyennes et ces mêmes probabilités a priori
  attribuerait $1/2$ à chaque classe partout, quelle que soit la variance
  commune choisie. Les différences de moyennes ne suffisent donc pas toujours
  pour classer ; QDA peut exploiter ici une différence de dispersion.
]

#figure(
  image("../figures/qda_variances.svg", width: 100%,
    alt: "Deux densités normales centrées en zéro, de variances un et quatre. "
      + "QDA prédit la classe de variance un au centre et celle de variance "
      + "quatre au-delà des seuils moins 1,36 et plus 1,36. LDA attribue "
      + "une probabilité constante de 0,5 à chaque classe."),
  caption: [Des dispersions différentes suffisent à produire une frontière
    quadratique, même lorsque les moyennes coïncident. Les fonds colorés
    représentent les décisions QDA. Les courbes sont celles des modèles
    théoriques, avec des probabilités a priori égales.],
)

#figure(
  image("../figures/discriminante_lda_qda.svg", width: 100%,
    alt: "LDA et QDA ajustées aux mêmes deux classes simulées de covariances "
      + "différentes. La LDA produit une frontière droite ; la QDA produit "
      + "une frontière courbe. Les fonds colorés indiquent les classes prédites."),
  caption: [Deux modèles ajustés au même échantillon simulé. Les fonds colorés
    donnent les régions de décision. La flexibilité de la QDA permet de tenir
    compte des covariances distinctes ; ce graphique d'entraînement ne mesure
    pas sa performance sur de nouvelles observations.],
)

=== Choisir entre LDA et QDA

La flexibilité de QDA a un coût. Une covariance symétrique contient
$p(p+1)/2$ paramètres : la LDA en estime une seule, la QDA en estime $K$.
Pour $p=4$ et $K=3$, cela représente $10$ paramètres de covariance pour la LDA
contre $30$ pour la QDA, en plus des moyennes et des probabilités a priori.
Chaque covariance de QDA est calculée à partir de sa propre classe : les
petites classes peuvent donc poser problème même si l'effectif total est grand.
Le choix entre LDA et QDA repose sur une validation, pas uniquement sur
l'ajustement apparent aux données d'apprentissage.

Si les covariances sont proches, les regrouper peut améliorer leur estimation :
la LDA accepte davantage de biais de modélisation, mais peut avoir une variance
d'estimation plus faible. Si les covariances diffèrent substantiellement et
que chaque classe est suffisamment documentée, QDA peut décrire une structure
que la LDA ne peut pas représenter. Une frontière plus souple n'est donc pas
automatiquement une meilleure règle sur de nouvelles observations.

La comparaison utilise les mêmes plis de validation pour les deux modèles.
Dans chaque pli, on réestime les moyennes, les covariances et les probabilités
a priori sur sa seule partie d'entraînement. Une imputation, une sélection de
variables ou une transformation choisie à partir des données doit suivre le
même protocole. On agrège ensuite les prédictions des observations laissées
de côté. Le jeu de test reste réservé à l'évaluation finale de la procédure
retenue.

Le critère dépend de l'usage. Le taux d'erreur convient à une classification
où toutes les erreurs ont le même coût ; avec des classes rares, on examine
aussi les rappels par classe et les coûts pertinents. Pour évaluer les
probabilités elles-mêmes, on peut utiliser la *perte logarithmique* :

$ cal(L)_"log"=-1/m sum_(i=1)^m log(hat(eta)_(y_i) (x_i)), $

où les $m$ probabilités ont été prédites sans entraîner le modèle sur les
observations évaluées. Une petite valeur est préférable. Une erreur très
confiante est fortement pénalisée : attribuer une probabilité de $0.01$ à la
vraie classe coûte $-log(0.01) approx 4.605$, contre $0.105$ pour une probabilité
de $0.9$. Deux règles ayant la même exactitude peuvent ainsi fournir des
probabilités de qualité différente.

La métrique principale et la règle de départage doivent être fixées avant
la comparaison. Un résultat sur quelques plis ne prouve pas une supériorité
générale : si les différences sont faibles, on examine leur stabilité et
la complexité nécessaire à l'usage prévu.

=== Étude de cas : Palmer Penguins

Reprenons les quatre mesures utilisées dans le chapitre sur l'ACP, mais
utilisons cette fois `species` comme réponse. On cherche à distinguer `Adelie`,
`Chinstrap` et `Gentoo`. L'ACP utilisait ces espèces seulement pour commenter
les graphiques ; la LDA utilise leurs étiquettes pour estimer les moyennes,
la covariance intra-groupe et la règle de classification.

Le fichier local `assets/penguins.csv` contient $344$ observations. On retire
les deux lignes auxquelles il manque une des quatre mesures, ce qui laisse
$342$ manchots : $151$ `Adelie`, $68$ `Chinstrap` et $123$ `Gentoo`. Les valeurs
manquantes de `sex` n'interviennent pas, puisque cette variable n'est pas
utilisée. Cette analyse porte donc sur les individus dont les quatre mesures
sont disponibles ; elle ne fournit pas une méthode de traitement des mesures
manquantes lors d'une future prédiction.

Le script `codes/analyse_discriminante.R` reproduit l'exemple à partir des
données locales. On conserve le partage du cours : environ 30~% de chaque
espèce sont réservés au test, avec la graine $2200$. Les $240$ observations
d'entraînement servent à comparer LDA et QDA ; les $102$ autres restent à
l'écart de ce choix. Les quatre variables sont fixées et utilisées dans leurs
unités d'origine.

*Comparer sur l'entraînement.* On construit cinq plis stratifiés, avec la
graine $2201$, communs aux deux modèles. Chaque observation d'entraînement
est prédite une fois par un modèle ajusté sur les quatre autres plis. Les
probabilités a priori sont les proportions estimées dans ces quatre plis.
On choisit le plus petit nombre d'erreurs ; à égalité, on retient la LDA,
qui estime moins de paramètres de covariance.

#block(breakable: false)[
  #table(
    columns: (0.8fr, 1.2fr, 1.1fr, 1.2fr), align: center,
    table.header([*Modèle*], [*Erreurs sur 240*], [*Taux d'erreur*],
      [*Perte logarithmique*]),
    [*LDA*], [*3*], [*1,25~%*], [*0,03093*],
    [QDA], [3], [1,25~%], [0,03711],
  )
]

Les deux modèles commettent trois erreurs : la règle de départage conduit
à retenir LDA. La perte logarithmique, donnée comme diagnostic complémentaire,
est aussi plus faible pour LDA sur ces plis. Ces faibles écarts ne démontrent
pas que QDA serait moins performante dans toute autre population ou tout
autre partage.

*Réajuster et évaluer.* On ajuste ensuite la LDA sur les $240$ observations
d'entraînement, puis on prédit le test. Le code ci-dessous reproduit le partage
et cet ajustement final ; la boucle de validation croisée complète se trouve
dans le script.

#block(breakable: true)[
```r
penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[c("species", variables)]),
              c("species", variables)]
d$species <- factor(d$species)

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
indices <- split(seq_len(nrow(d)), d$species)
idx_train <- unlist(lapply(indices, function(i) {
  sample(i, size = round(0.70 * length(i)))
}), use.names = FALSE)
train <- d[idx_train, ]
test <- d[-idx_train, ]

modele <- MASS::lda(species ~ ., data = train, method = "moment")
prediction <- predict(modele, newdata = test)
table(Reelle = test$species, Predite = prediction$class)
mean(prediction$class == test$species)
```
]

La fonction `lda` du paquet `MASS` utilise ici les proportions de classes de
l'entraînement comme probabilités a priori :

$ hat(pi)=(106/240,48/240,86/240)^top
  approx (0.4417,0.2000,0.3583)^top. $

Les entrées `method` et `prior` permettent de préciser les conventions
d'estimation.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/lda.html")[documentation
  de `MASS::lda`], notamment l'argument `prior`.
]

#block(breakable: false)[
Les prédictions donnent la matrice de confusion suivante :

#table(
  columns: (1.3fr, 1fr, 1fr, 1fr), align: center,
  table.header([*Espèce réelle*], [*Prédit Adelie*], [*Prédit Chinstrap*],
    [*Prédit Gentoo*]),
  [Adelie], [45], [0], [0],
  [Chinstrap], [2], [18], [0],
  [Gentoo], [0], [0], [37],
)
]

Le modèle classe correctement $100$ manchots sur $102$, soit 98,04~%
d'exactitude. Les deux erreurs sont des `Chinstrap` prédits `Adelie` : le rappel
de `Chinstrap` vaut 90~%, contre 100~% pour les deux autres espèces dans ce test.
La règle qui prédit toujours `Adelie`, classe majoritaire de l'entraînement,
atteint seulement $45/102 approx 44.12$~% d'exactitude sur ce même test.

#example[
  *Lire une probabilité prédite.* Pour la première observation du test,
  les mesures, dans l'ordre retenu, sont

  $ x=(40.3,18,195,3250)^top. $

  Les probabilités LDA sont environ $0.99140$ pour `Adelie`, $0.00860$ pour
  `Chinstrap` et $2.67 times 10^(-13)$ pour `Gentoo`. On prédit donc `Adelie`.
  L'étiquette observée sert ensuite à vérifier cette prédiction ; elle n'entre
  pas dans le calcul des scores. La très petite probabilité de `Gentoo` n'est
  pas exactement nulle, même si un affichage arrondi donne $0$.
]

Ces résultats décrivent un partage précis d'un petit jeu de données. Ils ne
garantissent pas 98~% de réussite dans une autre population. Pour comparer
plusieurs sélections de variables ou des degrés de régularisation, on étendrait
la comparaison interne aux $240$ observations d'entraînement, en conservant
le test à l'écart. Une évaluation par année ou par site répondrait à une autre
question que ce partage aléatoire d'individus.

Le script vérifie aussi que les scores explicites du cours redonnent les
probabilités produites par `MASS::lda` et, dans chaque pli, par
`MASS::qda`.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/qda.html")[documentation
  de `MASS::qda`] pour les estimateurs et les conditions sur les covariances.
]
Cette vérification porte sur le calcul, pas sur la justesse des hypothèses
gaussiennes ni sur la calibration dans une autre population.

=== Régularisation, interprétation et limites

*Des covariances qui doivent être estimables.* La LDA usuelle exige une
covariance intra-groupe inversible. Comme $rang(W) <= n-K$, elle est
singulière si $p > n-K$, et peut l'être aussi à cause de dépendances exactes
entre variables. En QDA, la covariance de la classe $g$ a un rang au plus
$n_g-1$ : il faut notamment $n_g > p$ pour espérer l'inverser. Même lorsque
l'inverse existe, une estimation sur peu de données peut être très instable.

Une solution est de régulariser la covariance, par exemple

$ hat(Sigma)_alpha = (1-alpha) hat(Sigma) + alpha tau I_p,
  quad tau = tr(hat(Sigma))/p, quad 0 <= alpha <= 1. $

Si $tau>0$, un $alpha>0$ rend cette matrice définie positive. La régularisation
stabilise les petites valeurs propres en rapprochant la covariance d'une
matrice plus simple. Le choix de $alpha$ doit être fait sur les données
d'entraînement, par validation ; la cible $tau I_p$ dépend des unités, ce qui
rend le choix d'une standardisation pertinent pour cette procédure.

Pour QDA, on peut d'abord rapprocher les covariances de classe de la covariance
commune :

$ tilde(Sigma)_(g,rho)=(1-rho)S_g+rho hat(Sigma), quad 0 <= rho <= 1. $

Avec $rho=0$, on conserve les covariances QDA ; avec $rho=1$, elles deviennent
toutes égales à la covariance LDA. Si cette dernière est définie positive,
un $rho>0$ rend aussi les matrices obtenues définies positives. Une seconde
réduction vers une cible diagonale ou sphérique peut être utile lorsque la
covariance commune est elle-même instable. Les paramètres de régularisation
font partie des choix à valider à l'intérieur de l'entraînement.

*Échelles et corrélations.* La LDA et la QDA classiques à covariance pleine sont invariantes,
en arithmétique exacte, à une transformation affine inversible commune à toutes
les observations. Changer une variable de grammes en kilogrammes ne change
donc pas sa règle de décision lorsqu'on réestime tous les paramètres de façon
cohérente. La standardisation n'est pas une obligation théorique comme choix
de géométrie, mais elle peut faciliter le calcul et l'interprétation des
coefficients. Elle doit être apprise sur l'entraînement et réutilisée telle
quelle pour la validation et le test.

Des variables corrélées ne rendent pas automatiquement la LDA inadaptée :
la covariance sert précisément à tenir compte de ces corrélations. Ce sont
les dépendances exactes ou presque exactes qui rendent l'estimation difficile.
De plus, la taille d'un coefficient brut dépend des unités et des autres
variables ; elle ne constitue pas à elle seule une mesure d'importance.

*Hypothèses et observations atypiques.* Les moyennes et les covariances sont
sensibles aux valeurs extrêmes. Des classes très asymétriques, multimodales ou
de covariances différentes peuvent être mal décrites par la LDA gaussienne.
La QDA assouplit l'égalité des covariances, mais conserve une forme gaussienne
dans chaque classe. Les méthodes peuvent encore fournir une règle utile si
les hypothèses ne sont pas exactes ; leur performance et la calibration des
probabilités doivent alors être vérifiées empiriquement.

*Des probabilités conditionnelles au modèle.* Le calcul remplace les paramètres
inconnus par leurs estimations ; il ne résume pas automatiquement l'incertitude
sur ces paramètres. Une probabilité proche de $1$ n'est pas une garantie de
bonne classification. Elle peut aussi apparaître pour un point très éloigné
de toutes les classes : la normalisation compare leurs densités relatives,
même lorsqu'elles sont toutes très petites. Le modèle doit être réévalué
si la population, les proportions de classes ou le protocole de mesure changent.

*Une démarche pratique.* Définir les classes, les coûts et les mesures
disponibles ; vérifier les effectifs et la géométrie dans chaque classe ;
comparer les modèles sur l'entraînement ; puis évaluer une seule fois la
procédure retenue sur le test. Les probabilités, la matrice de confusion et
les rappels par classe complètent l'exactitude globale. Une différence entre
modèles doit être interprétée à la lumière de la taille et de la représentativité
des données évaluées.

== Arbres de classification et de régression <arbres-cart>

=== Principe

Un arbre prédit en posant une suite de questions sur les variables explicatives.
La famille *CART*, pour _Classification and Regression Trees_, utilise des
questions binaires : chaque réponse conduit vers l'un de deux descendants.
L'apprentissage consiste à choisir ces questions et le niveau de détail auquel
on arrête le découpage.

#definition(title: [Arbre de classification ou de régression])[
  Un arbre partitionne l'espace des variables explicatives en régions disjointes
  $R_1,dots,R_M$, associées à ses $M$ *feuilles*. Une nouvelle observation
  appartient à une seule de ces régions et reçoit la prédiction de cette feuille.

  Dans le cadre usuel sans pondération, une feuille prédit la classe la plus
  fréquente pour la classification à coûts égaux, ou la moyenne des réponses
  pour la régression avec perte quadratique.
]

La *racine* contient toutes les observations d'entraînement. Un *nœud interne*
pose une question ; une *feuille* termine le chemin. La *profondeur* d'un nœud
est son nombre d'arêtes depuis la racine, dont la profondeur est $0$. Un arbre
à deux feuilles ne pose ainsi qu'une question et a une profondeur maximale de $1$.

Pour une variable quantitative, une question prend la forme $x_j <= s$, où
$j$ désigne la variable et $s$ le seuil. L'autre branche correspond à $x_j>s$.
Une variable peut être interrogée plusieurs fois le long d'un chemin. Avec des
coupures de ce type, les régions sont des rectangles en deux dimensions et des
produits d'intervalles en dimension supérieure, éventuellement non bornés.

#example[
  *Lire une règle.* Considérons un arbre à trois feuilles :

  $ R_1=\{x:x_1<=2\}, quad
    R_2=\{x:x_1>2, x_2<=1\}, quad
    R_3=\{x:x_1>2, x_2>1\}. $

  Les feuilles $R_1$ et $R_3$ prédisent A, tandis que $R_2$ prédit B. Pour
  $x=(3,0.6)^top$, la réponse à la première question est « non », puis « oui »
  à la seconde : on prédit B. La variable $x_2$ intervient uniquement lorsque
  $x_1>2$. L'arbre représente donc une *interaction* entre les deux variables.
]

#figure(
  image("../figures/cart_partition.svg", width: 100%,
        alt: "Arbre à trois feuilles et partition correspondante : une coupure verticale en x1 égal à 2, puis une coupure horizontale en x2 égal à 1 dans la région de droite."),
  caption: [Deux représentations du même arbre fictif. La deuxième coupure ne
    s'applique qu'à la région issue de la branche « non » de la racine.
    Les couleurs indiquent les classes prédites ; cet arbre est fixé pour
    illustrer sa lecture.],
)

Les groupes d'un arbre supervisé sont construits en utilisant la réponse $y$.
Ils ne jouent donc pas le même rôle que les groupes d'une classification non
supervisée : on cherche ici à rendre les *réponses* homogènes, plutôt qu'à
rapprocher les observations selon l'ensemble des variables explicatives.

=== Prédire dans une feuille

Notons $cal(I)_t=\{i:x_i in R_t\}$ les indices des observations d'entraînement
dans une feuille $t$, et $n_t=|cal(I)_t|$ son effectif. En classification, pour
$g in \{1,dots,K\}$, la proportion de la classe $g$ et la décision sont

$ hat(p)_(t g)=1/n_t sum_(i in cal(I)_t) ind(y_i=g), quad
  hat(g)(x)=argmax_g hat(p)_(t g) quad "si" x in R_t. $

On fixe une règle de départage en cas d'égalité. Le terme « classe majoritaire »
désigne ici la classe la plus fréquente, même si sa proportion est inférieure
à $1/2$ dans un problème à plusieurs classes. Les proportions de la feuille
fournissent aussi les probabilités estimées $hat(eta)_g (x)=hat(p)_(t g)$.
Elles sont constantes sur toute la région $R_t$.

En régression avec perte quadratique, la meilleure constante dans la feuille est

$ overline(y)_t=1/n_t sum_(i in cal(I)_t) y_i
  =argmin_(c in RR) sum_(i in cal(I)_t) (y_i-c)^2. $

La fonction de prédiction s'écrit donc
$hat(f)(x)=sum_(t=1)^M overline(y)_t ind(x in R_t)$ : elle est *constante par
morceaux*. Cette valeur dépend de la perte retenue ; avec une perte absolue,
une médiane des réponses minimise la somme des écarts absolus.

#example[
  Une feuille contenant $7$ observations de classe A, $2$ de classe B et $1$
  de classe C prédit A, avec les probabilités $(0.7,0.2,0.1)$. Si une autre
  feuille ne contient que deux A, elle prédit une probabilité empirique de $1$
  pour A, mais cet effectif très faible ne permet pas de conclure à une certitude.

  En régression, une feuille contenant les réponses $8$, $9$ et $10$ prédit $9$
  pour toute nouvelle observation qui y arrive, quelle que soit sa position
  à l'intérieur de la région.
]

Les formules précédentes supposent des observations de même poids et, pour la
classe prédite, des coûts d'erreur égaux. Des poids, des probabilités a priori
imposées ou des coûts différents peuvent modifier les proportions utilisées,
la décision et les coupures apprises.

=== Algorithme CART

La construction suit une stratégie *gloutonne et récursive*. Au nœud $t$, une
coupure candidate $(j,s)$ sépare les observations en

$ cal(I)_L=\{i in cal(I)_t:x_(i j)<=s\}, quad
  cal(I)_R=\{i in cal(I)_t:x_(i j)>s\}. $

Les indices $L$ et $R$ désignent les descendants gauche et droit. Une coupure
est admissible si elle respecte notamment l'effectif minimal exigé dans
chacun des deux descendants.

1. Pour chaque variable quantitative, trier ses valeurs distinctes présentes
   au nœud. Des seuils situés entre deux valeurs consécutives suffisent pour
   examiner toutes les partitions possibles sur cette variable.
2. Calculer le gain d'homogénéité pour chaque coupure admissible.
3. Retenir la coupure de gain maximal, selon une règle fixée en cas d'égalité.
4. Appliquer la même procédure séparément aux deux descendants, jusqu'à ce
   qu'un critère d'arrêt soit atteint.

Avec les valeurs distinctes $1$, $2$, $4$ et $7$, on peut par exemple essayer
les seuils $1.5$, $3$ et $5.5$. Des observations ayant exactement la même valeur
ne peuvent pas être séparées par une coupure sur cette seule variable. Pour
une variable qualitative, une question peut prendre la forme « la modalité
appartient-elle à l'ensemble $A$ ? ». Le traitement de ces variables dépend du
logiciel ; leur attribuer arbitrairement les codes $1$, $2$, $3$ comme à une
variable quantitative impose un ordre qui peut être injustifié.

À chaque étape, CART choisit la meilleure coupure *immédiate*. Il n'examine pas
tous les arbres que les coupures suivantes pourraient produire. Une première
coupure légèrement moins bonne peut permettre, plus loin, un meilleur arbre :
la stratégie gloutonne ne garantit donc pas un optimum global.

=== Critères d'homogénéité

*Classification.* Au nœud $t$, on définit les proportions $hat(p)_(t g)$ comme
dans une feuille. Les trois critères usuels sont

$ I_"Gini" (t)=1-sum_(g=1)^K hat(p)_(t g)^2, $
$ I_"ent" (t)=-sum_(g=1)^K hat(p)_(t g) log(hat(p)_(t g)), quad
  I_"err" (t)=1-max_g hat(p)_(t g). $

On utilise la convention $0 log(0)=0$. Un nœud *pur* ne contient qu'une seule
classe : les trois critères y valent $0$. Gini et l'entropie sont maximaux
lorsque les $K$ classes sont également représentées, avec respectivement
$1-1/K$ et $log(K)$. L'indice de Gini est aussi la probabilité que deux tirages
indépendants de classes selon ces proportions donnent des classes différentes.

Pour un critère d'impureté $I$, le gain local est

$ Delta I(t;j,s)=I(t)-n_L/n_t I(L)-n_R/n_t I(R). $

Les pondérations $n_L/n_t$ et $n_R/n_t$ sont essentielles : une petite feuille
pure ne compense pas nécessairement une grande feuille qui reste très mélangée.
Pour comparer des gains intervenant à des nœuds différents, leur contribution
à l'impureté moyenne de l'arbre est $(n_t/n) Delta I(t;j,s)$.

#example[
  *Calculer un gain de Gini.* Dix observations, ordonnées selon une variable
  $x=1,dots,10$, ont pour classes

  $ ("A", "A", "A", "A", "B", "A", "B", "B", "A", "B"). $

  La racine contient six A et quatre B, donc
  $I(t)=1-(6/10)^2-(4/10)^2=0.48$. Pour la coupure $x<=4.5$ :

  - à gauche, les quatre observations sont A, donc $I(L)=0$ ;
  - à droite, il reste deux A et quatre B, donc
    $I(R)=1-(2/6)^2-(4/6)^2=4/9$.

  Le gain vaut

  $ Delta I=0.48-4/10 times 0-6/10 times 4/9 approx 0.2133. $

  Pour la coupure $x<=2.5$, le nœud gauche contient deux A et le nœud droit
  quatre A et quatre B : le gain est seulement
  $0.48-(2/10 times 0+8/10 times 0.5)=0.08$. La première coupure est donc
  meilleure que la seconde selon Gini.
]

L'erreur de classification est moins sensible aux changements de proportions.
Par exemple, un nœud contenant huit A et deux B commet deux erreurs en prédisant
A. Le diviser en un nœud de quatre A et un nœud de quatre A et deux B ne change
pas ce nombre d'erreurs, alors que Gini diminue de $0.32$ à
$(6/10)(4/9) approx 0.2667$. Gini ou l'entropie peuvent ainsi détecter une
amélioration utile avant que la classe prédite ne change.

*Régression.* Avec une perte quadratique, on utilise la somme des carrés
résiduels dans le nœud,

$ "SCE"(t)=sum_(i in cal(I)_t) (y_i-overline(y)_t)^2. $

La meilleure coupure minimise $"SCE"(L)+"SCE"(R)$, ou, de manière équivalente,
maximise le gain

$ Delta "SCE"="SCE"(t)-"SCE"(L)-"SCE"(R)
  =(n_L n_R)/n_t (overline(y)_L-overline(y)_R)^2. $

Cette identité résulte de la décomposition de la dispersion autour de la
moyenne. Une coupure est utile lorsque les deux moyennes diffèrent, en tenant
compte de leurs effectifs. Si l'on utilise la variance empirique avec diviseur
$n_t$ comme impureté, le gain pondéré est $Delta "SCE"/n_t$ : les deux critères
choisissent donc la même coupure dans un nœud donné.

#example[
  *Choisir une coupure en régression.* Pour $x=(1,2,3,4,5,6)$, les réponses sont
  $y=(1,2,3,8,9,10)$. Sans coupure, on prédit la moyenne $5.5$ et
  $"SCE"(t)=77.5$.

  Avec le seuil $s=3.5$, on prédit $2$ à gauche et $9$ à droite. Chaque
  feuille a une somme des carrés égale à $2$, d'où

  $ Delta "SCE"=77.5-(2+2)=73.5= (3 times 3)/6 (2-9)^2. $

  Le seuil $s=2.5$ donne les moyennes $1.5$ et $7.5$, avec une somme des carrés
  totale de $29.5$ : il est moins bon. Parmi les cinq seuils candidats, $3.5$
  minimise la somme des carrés, qui vaut $4$ après coupure.
]

#figure(
  image("../figures/cart_regression.svg", width: 100%,
        alt: "Six observations de régression et prédictions en deux paliers, 2 et 9. La somme des carrés résiduels est minimale au seuil 3,5, où elle vaut 4."),
  caption: [Une coupure en régression. À gauche, les segments verticaux
    représentent les résidus autour des deux moyennes. À droite, on compare
    toutes les coupures possibles entre les valeurs observées de $x$.],
)

=== Complexité et élagage

Multiplier les feuilles réduit généralement l'erreur d'entraînement, mais
augmente le risque d'ajuster le bruit. Un arbre trop petit peut, à l'inverse,
manquer une structure réelle. La profondeur et le nombre de feuilles sont
deux mesures liées, mais différentes : deux arbres de même profondeur peuvent
avoir des nombres de feuilles très différents.

Le *pré-élagage* limite la croissance : profondeur maximale, effectif minimal
d'un nœud avant de tenter une coupure, effectif minimal dans chaque feuille,
gain minimal ou nombre maximal de feuilles. Arrêter trop tôt peut empêcher une
coupure peu utile immédiatement de donner accès à de bonnes coupures suivantes.

Le *post-élagage* part d'un arbre suffisamment développé et remplace certains
sous-arbres par une feuille. Pour formaliser le compromis, notons $cal(F)(T)$
l'ensemble des feuilles d'un arbre $T$ et $M(T)=|cal(F)(T)|$. Un critère
coût-complexité est

$ C_alpha (T)=C(T)+alpha M(T), quad alpha>=0. $

Par exemple, on peut prendre comme erreur d'entraînement

$ C_"class" (T)=1/n sum_(t in cal(F)(T)) n_t (1-max_g hat(p)_(t g)), $
$ C_"reg" (T)=1/n sum_(t in cal(F)(T)) "SCE"(t). $

Le critère utilisé pour *élaguer* n'est pas nécessairement celui utilisé pour
*choisir les coupures*. On peut construire l'arbre avec Gini, puis élaguer
selon l'erreur de classification. Les conventions de normalisation déterminent
l'échelle de $alpha$ ; il faut les préciser avant d'en comparer les valeurs.

Pour un arbre développé fixé, l'élagage coût-complexité produit une suite de
sous-arbres emboîtés. Lorsque $alpha$ augmente, on privilégie moins de feuilles.
Ce sont les branches de l'arbre existant qui sont supprimées : l'élagage ne
recherche pas de nouvelles coupures pour remplacer une mauvaise décision à la
racine.

#example[
  *Comparer trois sous-arbres.* Supposons que trois sous-arbres emboîtés aient
  respectivement $1$, $3$ et $5$ feuilles, avec les erreurs d'entraînement
  $0.40$, $0.15$ et $0.10$. Pour $alpha=0.03$, leurs critères sont

  $ 0.40+0.03 times 1=0.43, quad
    0.15+0.03 times 3=0.24, quad
    0.10+0.03 times 5=0.25. $

  Le sous-arbre à trois feuilles est préféré parmi ces candidats. Passer de
  trois à cinq feuilles réduit l'erreur de $0.05$, mais augmente la pénalité
  de $2 times 0.03=0.06$. La réduction d'erreur ne suffit donc pas.
]

=== Choisir la taille par validation

La valeur de $alpha$ ne se choisit pas en minimisant l'erreur sur le test.
On réserve le test et on compare les degrés d'élagage par validation croisée
sur l'entraînement. Dans chaque pli, il faut *reconstruire l'arbre* sur les
observations disponibles : élaguer un arbre déjà ajusté sur toutes les données
ferait intervenir les réponses du pli de validation dans ses coupures.

#block(breakable: false)[
  Une première règle consiste à retenir la complexité de plus faible erreur
  moyenne de validation, puis à privilégier le modèle le plus simple en cas
  d'égalité. La *règle d'une erreur standard* préfère le plus petit arbre dont
  l'erreur ne dépasse pas le minimum augmenté de l'erreur standard estimée
  en ce minimum.
]

#example[
  *Un minimum peu marqué.* Voici des résultats fictifs de validation pour
  quatre tailles candidates ; les valeurs sont des proportions d'erreur.

  #table(
    columns: (0.7fr, 1fr, 1fr, 1fr), align: center,
    table.header([*Feuilles*], [*Entraînement*], [*Validation*], [*Erreur standard*]),
    [2], [0,25], [0,26], [0,03],
    [4], [0,14], [0,18], [0,03],
    [8], [0,08], [0,17], [0,03],
    [16], [0,02], [0,22], [0,04],
  )

  Le minimum de validation est $0.17$, pour huit feuilles. La règle d'une
  erreur standard fixe le seuil $0.17+0.03=0.20$ et retient quatre feuilles,
  le plus petit candidat sous ce seuil. Seize feuilles améliorent encore
  l'entraînement, tout en dégradant la validation : c'est un signe de surajustement.
]

L'erreur standard mesure l'incertitude estimée sur l'erreur de validation,
pas la dispersion des réponses. Par exemple, on utilise parfois l'écart-type
des erreurs des $V$ plis divisé par $sqrt(V)$. Les apprentissages des plis se
recouvrant, cette estimation et la règle associée restent des outils pratiques,
plutôt qu'un test formel d'égalité des performances.

Après la sélection, on réajuste la procédure sur tout l'entraînement et on
évalue une seule fois le modèle retenu sur le test. La mesure dépend du but :
exactitude et rappels par classe en classification, RMSE ou MAE en régression,
ou coût spécifique si certaines erreurs sont plus graves.

=== Pratique : deux tâches sur Palmer Penguins

On reprend les $342$ manchots disposant des quatre mesures quantitatives et de
`species`, avec le même partage que pour les k-NN et l'analyse discriminante :
$240$ observations d'entraînement et $102$ de test. Le script
`codes/arbres_cart.R` reproduit les calculs avec le paquet R `rpart`.

Deux tâches sont traitées séparément :

- *Classification* : prédire `species` avec `bill_length_mm`, `bill_depth_mm`,
  `flipper_length_mm` et `body_mass_g` ; les coupures utilisent Gini.
- *Régression* : prédire `body_mass_g` avec les trois autres mesures ;
  ni `body_mass_g` ni `species` ne figurent parmi les prédicteurs.

Les arbres sont développés avec au moins cinq observations par feuille,
au moins dix observations pour tenter une coupure et une profondeur maximale
de dix. On compare ensuite les valeurs de `cp`
$0$, $0.001$, $0.005$, $0.01$, $0.02$, $0.05$ et $0.10$ sur les cinq mêmes plis
stratifiés de l'entraînement. Ces contraintes et cette grille sont fixées
avant l'évaluation. Chaque pli donne lieu à un nouvel apprentissage.

Dans `rpart`, `cp` exprime la pénalité relativement au risque de l'arbre réduit
à sa racine. Pour une convention de risque identique, cela correspond à
$alpha="cp" times C(T_0)$, où $T_0$ est cet arbre sans coupure. La fonction
`prune` retire les branches selon cette pénalité.#footnote[Voir les documentations
de #link("https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.control.html")[`rpart.control`]
et de #link("https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/prune.rpart.html")[`prune.rpart`].
Le paramètre `cp` peut aussi limiter la croissance ; le script le fixe à zéro
à cette étape, puis élague les arbres obtenus. La
#link("https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf")[vignette de Therneau et Atkinson],
section 6.1, précise sa normalisation par le risque à la racine. Pénaliser le
nombre de coupures ou le nombre de feuilles conduit au même choix : ces nombres
diffèrent de un dans un arbre binaire.]

*Résultats de validation.* Pour la classification, on minimise le nombre total
d'erreurs sur les plis ; pour la régression, la moyenne de tous les carrés
d'erreurs de validation. En cas d'égalité, on retient le plus grand `cp`.
Il s'agit ici de la règle du minimum, et non de la règle d'une erreur standard.

#block(breakable: false)[
  #table(
    columns: (0.7fr, 1.5fr, 1.5fr), align: center,
    table.header([*`cp`*], [*Classification : erreurs sur 240*], [*Régression : RMSE (g)*]),
    [0], [14], [378,1],
    [0,001], [14], [*376,0*],
    [0,005], [14], [378,4],
    [0,01], [11], [400,1],
    [0,02], [*11*], [416,1],
    [0,05], [12], [446,0],
    [0,10], [12], [487,7],
  )
]

La classification retient `cp = 0.02` : les onze erreurs représentent
$11/240 approx 4.58$~%. L'arbre réajusté sur les $240$ observations possède
quatre feuilles. Voici ses règles, avec les effectifs d'entraînement :

1. Si `flipper_length_mm < 207.5` et `bill_length_mm < 44.65`, prédire Adelie
   ($104$ observations, dont $102$ Adelie).
2. Si `flipper_length_mm < 207.5` et `bill_length_mm >= 44.65`, prédire Chinstrap
   ($46$ observations, dont $42$ Chinstrap).
3. Si `flipper_length_mm >= 207.5` et `bill_depth_mm >= 17.65`, prédire Chinstrap
   ($5$ observations, dont $4$ Chinstrap).
4. Si `flipper_length_mm >= 207.5` et `bill_depth_mm < 17.65`, prédire Gentoo
   ($85$ observations, toutes Gentoo).

On conserve ici les inégalités affichées par `rpart`. La première observation
du test a notamment `flipper_length_mm = 195` et `bill_length_mm = 40.3` : elle
arrive dans la première feuille, qui prédit Adelie avec les proportions
$(102/104,2/104,0) approx (0.9808,0.0192,0)$. Le zéro pour Gentoo signifie qu'aucun
Gentoo n'est présent dans cette feuille d'entraînement, pas que cette espèce y
serait impossible dans la population.

#block(breakable: false)[
  La matrice de confusion sur le test est

  #table(
    columns: (1.1fr, 1fr, 1.2fr, 1fr), align: center,
    table.header([*Espèce réelle*], [*Prédit Adelie*], [*Prédit Chinstrap*], [*Prédit Gentoo*]),
    [Adelie], [44], [1], [0],
    [Chinstrap], [4], [16], [0],
    [Gentoo], [0], [1], [36],
  )
]

L'exactitude vaut $96/102 approx 94.12$~%. Le rappel de Chinstrap est de
$16/20=80$~%, ce que l'exactitude globale ne montre pas à elle seule.
La feuille de cinq observations est également un point à surveiller : sa
prédiction repose sur peu de données.

*Régression.* La validation retient `cp = 0.001`, avec une RMSE de validation
d'environ $376.0$~g. L'arbre final comporte $30$ feuilles et obtient sur le test
une RMSE de $363.7$~g et une MAE de $278.4$~g. Prédire systématiquement la masse
moyenne de l'entraînement donne une RMSE de $800.3$~g sur ce même test. Les
mesures apportent donc ici une amélioration par rapport à cette référence.
Trente feuilles rendent cependant l'arbre nettement moins facile à lire que
l'arbre de classification à quatre feuilles.

Le fragment suivant montre l'ajustement final des deux modèles, une fois les
valeurs de `cp` choisies par la boucle de validation du script :

```r
controle <- rpart::rpart.control(
  cp = 0, minsplit = 10, minbucket = 5,
  maxdepth = 10, xval = 0, maxsurrogate = 0
)
grand_class <- rpart::rpart(
  species ~ bill_length_mm + bill_depth_mm +
    flipper_length_mm + body_mass_g,
  data = train, method = "class",
  parms = list(split = "gini"), control = controle
)
arbre_class <- rpart::prune(grand_class, cp = 0.02)
predict(arbre_class, newdata = test, type = "class")
predict(arbre_class, newdata = test, type = "prob")

grand_reg <- rpart::rpart(
  body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
  data = train, method = "anova", control = controle
)
arbre_reg <- rpart::prune(grand_reg, cp = 0.001)
predict(arbre_reg, newdata = test)
```

La méthode `class` traite la classification, tandis que `anova` utilise les
carrés résiduels pour la régression.#footnote[Voir la
#link("https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.html")[documentation de `rpart`]
pour les méthodes, les probabilités a priori et les matrices de coûts.]
On ne standardise pas les mesures pour ces arbres : les coupures comparent les
valeurs d'une variable à un seuil dans ses propres unités. Les résultats restent
ceux d'un partage précis ; ils ne garantissent pas la même performance sur une
autre année ou une autre population de manchots.

=== Forces et limites

*Des règles locales faciles à examiner.* Un petit arbre fournit des conditions
explicites, peut utiliser des variables de types différents et représente des
interactions sans qu'on doive les spécifier à l'avance. Il n'impose ni une
relation linéaire ni des distributions gaussiennes. La lisibilité diminue
toutefois rapidement lorsque le nombre de feuilles augmente.

*Peu de dépendance aux unités, mais une dépendance aux axes.* Une transformation
strictement croissante d'une variable préserve l'ordre de ses valeurs et les
partitions candidates de l'échantillon. En particulier, changer des millimètres
en centimètres ne change pas les coupures correspondantes en arithmétique
exacte. Pour une transformation non linéaire, des seuils calculés comme milieux
peuvent néanmoins placer différemment de nouveaux points entre deux valeurs
observées. Une rotation des axes change, elle, les coupures accessibles : une
frontière oblique peut demander beaucoup de rectangles pour être approchée.

*Instabilité.* Deux coupures peuvent avoir des gains presque égaux. Une légère
modification des données peut inverser leur ordre, modifier la racine puis
toutes les branches suivantes. Une variable absente de l'arbre n'est donc pas
nécessairement inutile : une variable corrélée peut avoir été choisie à sa place.
Les importances fondées sur les gains d'impureté peuvent aussi favoriser les
variables offrant beaucoup de coupures candidates ; elles ne mesurent pas un
effet causal.

*Prédictions par paliers.* Deux points très proches de part et d'autre d'un seuil
peuvent recevoir des prédictions différentes. En régression avec des moyennes
de feuilles, les prédictions restent entre les réponses minimale et maximale
de l'entraînement : l'arbre ne prolonge pas une tendance au-delà des données.
Des réponses extrêmes peuvent néanmoins déplacer fortement une moyenne de
feuille et influencer les coupures.

*Effectifs, probabilités et données manquantes.* Une feuille pure sur quelques
observations ne garantit pas des probabilités fiables. Il faut examiner les
effectifs, les rappels des classes rares et, si les probabilités sont utilisées,
leur calibration. Les valeurs manquantes demandent aussi une stratégie explicite :
imputation apprise sur l'entraînement, branche dédiée ou coupures de remplacement
selon le logiciel. L'exemple précédent travaille uniquement sur les cas complets.

Ces limites motivent les méthodes ensemblistes : agréger plusieurs arbres peut
réduire leur instabilité et améliorer les prédictions, au prix d'une règle
globale moins directement lisible.

== Méthodes ensemblistes

=== Principe

Les méthodes ensemblistes combinent plusieurs modèles simples pour produire une
prédiction plus robuste. Elles améliorent souvent la performance au prix d'une
interprétation moins directe.

Trois grandes familles apparaissent dans le cours :

- le bagging;
- les forêts aléatoires;
- le boosting.

L'idée générale est qu'un ensemble de modèles imparfaits peut être meilleur
qu'un seul modèle, à condition que leurs erreurs ne soient pas toutes les mêmes.

=== Bagging

#definition(title: [Bagging])[
  Le bagging, ou *bootstrap aggregating*, construit plusieurs modèles sur des
  échantillons bootstrap des données d'entraînement. Pour la classification, on
  combine ensuite les prédictions par vote majoritaire ou par moyenne des
  probabilités.
]

Le bagging réduit la variance et stabilise les prédictions, en particulier pour
des modèles instables comme les arbres.

Si l'on ajuste beaucoup d'arbres profonds sur des échantillons bootstrap, chaque
arbre peut surajuster son propre échantillon, mais la moyenne ou le vote réduit
la variabilité globale.

=== Forêts aléatoires

#definition(title: [Forêt aléatoire])[
  Les forêts aléatoires ajoutent une source d'aléa au bagging. À chaque coupure
  d'un arbre, l'algorithme ne considère qu'un sous-ensemble aléatoire de variables.
  Cette contrainte décorrèle les arbres et améliore l'agrégation.
]

Un choix courant consiste à considérer environ $sqrt(p)$ variables candidates à
chaque coupure en classification, où $p$ est le nombre total de variables.

Les forêts aléatoires fournissent souvent de bonnes performances par défaut.
Elles permettent aussi de mesurer l'importance des variables, par exemple en
observant la perte de performance lorsque les valeurs d'une variable sont
permutées.

=== Boosting

#definition(title: [Boosting])[
  Le boosting construit les modèles de manière séquentielle. Chaque nouveau modèle
  se concentre davantage sur les erreurs des modèles précédents. L'objectif est de
  combiner plusieurs classificateurs faibles pour obtenir un modèle global très
  performant.
]

AdaBoost ajuste des poids sur les observations. Le gradient boosting formule
l'apprentissage comme une minimisation itérative d'une fonction de perte.

Le boosting peut être très précis, mais il demande un réglage soigné du nombre
d'itérations, de la profondeur des arbres, du taux d'apprentissage et parfois du
sous-échantillonnage.

Contrairement au bagging, qui réduit surtout la variance par moyenne, le
boosting peut réduire le biais en ajoutant progressivement des corrections. En
contrepartie, il peut surajuster si l'on ajoute trop d'itérations ou si les
arbres de base sont trop complexes.

=== Hyperparamètres et validation

Les méthodes supervisées comportent souvent des paramètres qui ne sont pas appris
directement par le modèle :

- profondeur maximale d'un arbre;
- nombre minimal d'observations dans une feuille;
- nombre d'arbres dans une forêt;
- nombre de variables candidates à chaque coupure;
- taux d'apprentissage en boosting;
- pénalité de complexité.

Ces hyperparamètres doivent être choisis à l'aide d'un protocole de validation
qui évite de réutiliser le jeu de test pour prendre des décisions.

=== Comparaison rapide

- Bagging : plusieurs modèles indépendants ajustés sur des échantillons bootstrap.
- Forêts aléatoires : bagging d'arbres avec sélection aléatoire de variables à
  chaque coupure.
- Boosting : modèles ajoutés séquentiellement pour corriger les erreurs
  précédentes.

En pratique, les méthodes ensemblistes sont souvent très performantes, mais leur
interprétation doit passer par des outils complémentaires : importance des
variables, profils de dépendance partielle, validation croisée et analyse des
erreurs.

== Méthodes supervisées modernes

=== Gradient boosting moderne

Les implémentations modernes du gradient boosting ont rendu les ensembles
d'arbres particulièrement importants pour les données tabulaires. XGBoost,
LightGBM et CatBoost reposent sur la même idée générale : construire des arbres
séquentiellement pour corriger les erreurs des arbres précédents, tout en
ajoutant des régularisations et des optimisations de calcul.

XGBoost insiste sur la régularisation, la gestion des données creuses et
l'efficacité du calcul. LightGBM utilise des histogrammes et des stratégies
d'échantillonnage pour accélérer l'apprentissage sur de grands tableaux.
CatBoost est conçu pour bien traiter les variables catégorielles et limiter les
fuites d'information liées à leur encodage.

Ces méthodes sont souvent de très bons points de comparaison. Elles exigent
toutefois un réglage attentif : nombre d'arbres, profondeur, taux d'apprentissage,
sous-échantillonnage, pénalités et arrêt précoce.

#remark[
  Pour des données tabulaires classiques, un gradient boosting bien validé est
  souvent un adversaire sérieux pour des modèles plus complexes. Il faut donc le
  considérer comme une référence pratique, pas comme une simple amélioration
  technique des arbres.
]

=== Incertitude et calibration

Une prédiction supervisée n'est pas seulement une valeur ou une classe. Dans de
nombreux contextes, on veut aussi savoir à quel point la prédiction est fiable.
Pour une classification, cela conduit à étudier la calibration des probabilités :
parmi les observations prédites avec une probabilité de 0.8, environ 80 pour cent
devraient appartenir à la classe prédite.

Pour une régression, on peut chercher un intervalle de prédiction plutôt qu'une
seule valeur. Les méthodes de prédiction conforme construisent des ensembles ou
des intervalles qui ont une garantie de couverture sous des hypothèses faibles,
notamment l'échangeabilité des observations.

NGBoost fournit une autre approche : au lieu de prédire seulement une moyenne, le
modèle prédit les paramètres d'une distribution conditionnelle. On obtient alors
une prédiction probabiliste, utile lorsque l'incertitude fait partie de la
décision.

#example[
  Pour prédire une demande hebdomadaire, annoncer 120 unités n'a pas le même
  sens qu'annoncer un intervalle plausible de 95 à 150 unités. Le second résultat
  permet de dimensionner un stock avec une tolérance au risque explicite.
]

=== Interprétabilité et AutoML

Les modèles modernes peuvent être performants sans être immédiatement lisibles.
Les outils d'interprétabilité aident à comprendre ce qui influence les
prédictions. SHAP attribue à chaque variable une contribution à une prédiction
donnée, puis agrège ces contributions pour produire une vision globale du modèle.

Ces outils ne remplacent pas l'analyse statistique. Ils doivent être utilisés
avec prudence lorsque les variables sont corrélées, lorsque le modèle extrapole
ou lorsque les données contiennent des biais de collecte. Une explication locale
décrit le comportement du modèle, pas nécessairement un mécanisme causal.

L'AutoML automatise une partie du travail : choix d'algorithmes, encodage de
variables, recherche d'hyperparamètres, empilement de modèles et validation.
Auto-sklearn et AutoGluon illustrent cette famille. Ils sont utiles pour établir
un point de comparaison robuste, mais ils ne dispensent pas de définir la bonne
mesure d'erreur, de contrôler les fuites d'information et d'interpréter les
résultats.

=== Prolongements

Les réseaux neuronaux pour données tabulaires, comme TabNet ou certains
transformers tabulaires, cherchent à adapter le deep learning aux tableaux de
données structurées. Ils peuvent être intéressants lorsque l'on dispose de très
grands volumes de données, de variables hétérogènes ou d'une étape
d'apprentissage auto-supervisé.

TabPFN représente une direction plus récente : un modèle pré-entraîné sur de
nombreux problèmes tabulaires synthétiques qui peut produire rapidement des
prédictions sur de petits jeux de données. C'est une ouverture importante, mais
pour un cours général d'analyse des données, ces modèles doivent surtout servir
à discuter des références, des hypothèses et des limites des méthodes
automatisées.

#exercises[

  1. Expliquez le rapport entre variabilité inter-groupe et intra-groupe dans
     l'analyse discriminante de Fisher.
  2. Pourquoi un arbre non élagué risque-t-il de surajuster ?
  3. Comparez bagging et boosting en une phrase.
  4. Proposez un protocole de validation pour choisir la profondeur maximale d'un
     arbre.
  5. Dans quel cas préféreriez-vous une forêt aléatoire à un arbre unique ?
  6. Pourquoi le choix de la mesure d'erreur dépend-il du problème étudié ?
  7. Pourquoi XGBoost, LightGBM et CatBoost sont-ils des références utiles pour
     les données tabulaires ?
  8. Que signifie une probabilité de classification bien calibrée ?
  9. Quelle différence y a-t-il entre prédire une valeur moyenne et prédire un
     intervalle de prédiction ?
  10. Pourquoi une explication SHAP ne suffit-elle pas à établir une relation
      causale ?
]
