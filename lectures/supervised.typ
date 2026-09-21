#import "../styles/notes.typ": note, example

#show figure.caption: set align(left)

= Apprentissage supervisé

== Introduction

En apprentissage supervisé, on dispose d'exemples pour lesquels les variables explicatives et la réponse à prédire ou à expliquer sont connues. On utilise ces exemples pour construire une règle de prédiction, puis on applique cette règle à de nouvelles observations dont la réponse est encore inconnue. Le mot *supervisé* désigne ainsi la présence de cette réponse dans les données d'apprentissage : elle fournit une référence pour apprendre et pour mesurer les erreurs.

Il faut distinguer la tâche de prédiction et celle de l'explication des données. Un classificateur (_classifier_) cherche les caractéristiques qui permettent de prévoir une étiquette ou un nombre donnés. Une variable très dispersée n'est ainsi pas nécessairement utile pour prédire, alors qu'une variable peu dispersée peut devenir essentielle si elle distingue bien les classes.

=== Données, modèle et prédiction

On note l'échantillon d'apprentissage

$ cal(D) = {(x_i, y_i)}_(i=1)^n, quad
  x_i = (x_(i 1), dots, x_(i p))^top. $

Le vecteur $x_i$ contient les $p$ variables explicatives, qualitatives ou quantitatives, de l'observation $i$, et $y_i$ est sa réponse, qui peut aussi être qualitative ou quantitative. Les lettres majuscules $X$ et $Y$ désignent les variables aléatoires correspondantes. À partir de $cal(D)$, on cherche à construire une fonction $hat(f)$. La prédiction pour une nouvelle observation $x$ est $hat(y) = hat(f)(x)$. Le chapeau rappelle que la règle est estimée à partir d'un échantillon et changerait si l'on changeait les données.

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

En *régression*, la réponse est quantitative : une masse, une durée ou une quantité produite par exemple. Le modèle renvoie une valeur numérique. En *classification*, la réponse est qualitative : une espèce, un type de produit ou une catégorie de défaut par exemple. On note les classes $1, dots, K$. Ces nombres sont des étiquettes et ne leur donnent pas un ordre ni des distances numériques.

Un classificateur peut produire deux sortes de résultats :

- des probabilités estimées $hat(eta)_g (x) approx P(Y=g bar.v X=x)$ pour chaque classe $g in \{1, dots, K\}$, de somme $1$ ;
- une décision $hat(g)(x)$, obtenue en choisissant une classe à partir de ces
  probabilités et d'une règle de décision.

Par exemple, des probabilités $(0.55, 0.40, 0.05)$ conduisent à choisir la première classe si l'on retient la plus probable. Cette décision est moins tranchée qu'avec $(0.98, 0.01, 0.01)$, alors que l'étiquette prédite est la même. Une probabilité annoncée par un modèle n'est toutefois fiable que si le modèle est convenablement calibré.

=== Quatre familles de méthodes

Ce chapitre présente quatre méthodes, qui partagent le même besoin
d'évaluation mais construisent leurs prédictions de façons différentes.

- Les *$k$ plus proches voisins* prédisent la réponse à partir des observations
  d'entraînement les plus semblables à l'observation à classer ou à prédire.
- L'*analyse discriminante* décrit les distributions des variables dans les
  classes, ou construit des projections qui séparent leurs moyennes en tenant
  compte de leur dispersion. Elle relie géométrie et probabilités de classe.
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

En faisant l'hypothèse que chaque voisin apporte une voix (donc qu'ils ont le même poids), la proportion locale de la classe $g$ et la décision correspondante sont

$ hat(eta)_g (x) = 1/k sum_(i in cal(N)_k (x)) bold(1)\{y_i=g\}, quad "et" quad
  hat(g)(x) = op("argmax")_(g in {1, dots, K}) hat(eta)_g (x). $

L'indicatrice $bold(1)\{y_i=g\}$ vaut $1$ si le voisin $i$ appartient à la classe
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
    inset: 6pt, stroke: 0.4pt + luma(210),
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

Lorsque la réponse est quantitative, on remplace le vote par la moyenne des
réponses du voisinage :

$ hat(f)_k (x) = 1/k sum_(i in cal(N)_k (x)) y_i. $

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

#note[
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

=== Exemple pratique : Palmer Penguins

On cherche à prédire `species` à partir de `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm` et `body_mass_g`. On conserve les $342$ observations complètes pour ces quatre mesures. Le partage stratifié donne $240$ observations d'entraînement et $102$ de test. Les noms des espèces sont les réponses à prédire ; ils n'entrent donc pas dans le calcul des distances.

On peut utiliser la distance euclidienne sur les variables centrées et réduites, un vote uniforme et cinq plis stratifiés dans l'entraînement. Les mêmes plis servent pour toutes les valeurs de $k$ candidates. La standardisation est réestimée dans chaque pli. Voici les nombres d'erreurs obtenus en regroupant les prédictions de validation des $240$ observations :

#table(
  columns: (0.8fr, 1.3fr, 1.3fr), align: center,
  inset: 4pt, stroke: 0.4pt + luma(210),
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
  inset: 6pt, stroke: 0.4pt + luma(210),
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

== Analyse discriminante

=== Principe

L'analyse discriminante étudie des groupes *déjà connus* à partir de variables
explicatives quantitatives. Elle poursuit deux objectifs liés : construire une
représentation qui met en évidence la séparation entre groupes et affecter une
nouvelle observation à l'un de ces groupes. Elle ne découvre donc pas des classes
sans étiquettes, comme le ferait une méthode de regroupement.

L'idée de Fisher est de construire un score linéaire

$ z = a^top x, quad a in RR^p, $

où la direction $a$ rend les moyennes des groupes éloignées après projection,
tout en limitant la dispersion à l'intérieur des groupes. Ajouter une constante
au score déplacerait tous les points de la même quantité, sans modifier cette
séparation. Le seuil utilisé pour classer sera déterminé dans un second temps.

Contrairement à l'ACP, le choix de l'axe utilise les classes. L'ACP recherche
une forte variance totale ; Fisher recherche un contraste entre groupes
relativement à leur variabilité interne.

#example[
  Considérons deux classes équiprobables de moyennes $(0,-1)^top$ et
  $(0,1)^top$, avec la même covariance $op("diag")(9, 0.25)$. Dans chaque
  classe, $X_1$ varie beaucoup, mais sa distribution est la même pour les deux
  classes. $X_2$ varie moins à l'intérieur de chaque classe et sépare leurs
  moyennes.

  La covariance totale est $op("diag")(9, 1.25)$ : l'ACP sur les variables
  centrées, sans réduction, retient d'abord la direction $X_1$. La direction de
  Fisher est $X_2$. Une direction qui conserve beaucoup de variance n'est donc
  pas nécessairement celle qui permet de distinguer les classes.
]

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

=== Variabilités intra-groupe et inter-groupe

Notons $C_g = {i : y_i=g}$ l'ensemble des indices de la classe $g$, d'effectif
$n_g$, pour $g = 1, dots, K$. Les moyennes de classe et la moyenne globale sont

$ overline(x)_g = 1/n_g sum_(i in C_g) x_i, quad
  overline(x) = 1/n sum_(i=1)^n x_i = sum_(g=1)^K n_g/n overline(x)_g. $

On définit les matrices de dispersion *intra-groupe* et *inter-groupe* :

$
  W = sum_(g=1)^K sum_(i in C_g)
      (x_i-overline(x)_g)(x_i-overline(x)_g)^top,
$
$
  B = sum_(g=1)^K n_g (overline(x)_g-overline(x))(overline(x)_g-overline(x))^top.
$

$W$ mesure les écarts de chaque observation à la moyenne de sa classe ; $B$
mesure les écarts des moyennes de classe à la moyenne globale, pondérés par les
effectifs. Ce sont ici des *sommes* de produits d'écarts, sans division par des
degrés de liberté. La dispersion totale se décompose exactement en

$ T = sum_(i=1)^n (x_i-overline(x))(x_i-overline(x))^top = W+B. $

Les termes croisés disparaissent parce que les écarts à la moyenne somment à
zéro dans chaque classe. Pour les scores $z_i=a^top x_i$, les dispersions
intra-groupe et inter-groupe deviennent respectivement $a^top W a$ et
$a^top B a$.

=== Critère de Fisher et axes discriminants

Le critère de Fisher maximise le rapport

$ J(a) = (a^top B a) / (a^top W a), quad a != 0. $

Une grande valeur indique que les moyennes projetées sont éloignées par rapport
à la dispersion des observations autour de ces moyennes. Multiplier $a$ par
une constante non nulle ne change pas $J(a)$ : on cherche une direction, et non
une longueur particulière.

Si $W$ est définie positive, on peut imposer $a^top W a = 1$ et maximiser
$a^top B a$. La condition obtenue par un multiplicateur de Lagrange est

$ B a = lambda W a. $

La première direction correspond à la plus grande valeur propre généralisée.
Les suivantes sont choisies avec $a_k^top W a_ell = 0$ pour $k != ell$.
Elles sont donc orthogonales pour la métrique définie par $W$, sans être
nécessairement orthogonales pour le produit scalaire usuel.

*Deux classes.* En posant $d = overline(x)_2-overline(x)_1$, on obtient
$B = ((n_1 n_2)/n) d d^top$. Lorsque $d != 0$, la direction optimale vérifie

$ a prop W^(-1) d. $

La différence des moyennes donne le contraste recherché, tandis que l'inverse
de $W$ tient compte des dispersions et des corrélations internes. Une variable
dont les moyennes diffèrent beaucoup peut être peu discriminante si elle varie
encore davantage à l'intérieur des classes.

*Plusieurs classes.* Les $K$ moyennes centrées engendrent un espace de dimension
au plus $K-1$. Comme $op("rang")(B) <= min(p,K-1)$, il existe au plus
$min(p,K-1)$ axes discriminants de valeur propre strictement positive.
Pour trois classes et quatre variables, on obtient donc au plus deux axes.
On note $k$ le rang d'un axe et $q$ le nombre d'axes retenus.

Ces axes constituent une réduction de dimension *supervisée*. Les valeurs
propres quantifient la séparation inter-groupe relativement à la dispersion
intra-groupe. Leurs pourcentages relatifs ne sont ni des pourcentages de variance
totale expliquée au sens de l'ACP, ni des taux de bonne classification.
Choisir $q$ pour prédire demande une validation sur des observations distinctes.

#note[
  Le critère de Fisher se définit sans hypothèse de normalité. Il privilégie
  toutefois une séparation des moyennes : si deux classes ont la même moyenne
  mais des dispersions différentes, $B$ peut être nulle alors qu'une règle
  fondée sur les dispersions permet de les distinguer.
]

=== Analyse discriminante linéaire : modèle probabiliste

L'analyse discriminante linéaire, ou *LDA* (_Linear Discriminant Analysis_),
modélise les variables explicatives conditionnellement à la classe :

$ X bar.v (Y=g) tilde.op cal(N)_p (mu_g, Sigma), quad P(Y=g) = pi_g. $

Chaque classe a sa propre moyenne $mu_g$, mais toutes partagent la même matrice
de covariance $Sigma$, supposée définie positive. Les probabilités *a priori*
$pi_g > 0$ somment à $1$ et décrivent les fréquences des classes avant
d'observer les mesures. La normalité est supposée *dans chaque classe* : la
distribution globale, mélange de ces classes, n'a pas à être normale.

Si $f_g (x)$ est la densité normale de la classe $g$, la formule de Bayes donne
la probabilité *a posteriori*

$ eta_g (x) = P(Y=g bar.v X=x)
  = (pi_g f_g (x)) / (sum_(h=1)^K pi_h f_h (x)). $

Sous la perte 0–1, on choisit la classe de plus grande probabilité. Le
dénominateur étant commun, cela revient à maximiser
$log pi_g + log f_g (x)$. Avec une covariance commune, le terme quadratique
$-1/2 x^top Sigma^(-1) x$ est identique dans toutes les classes et s'élimine de
la comparaison. Il reste les *scores discriminants*#footnote[
  Les formulations probabilistes de la LDA et de la QDA sont présentées dans
  la #link("https://scikit-learn.org/stable/modules/lda_qda.html")[documentation
  de scikit-learn, _Linear and Quadratic Discriminant Analysis_].
] :

$ delta_g (x) = x^top Sigma^(-1) mu_g
  - 1/2 mu_g^top Sigma^(-1) mu_g + log pi_g. $

Chaque score est affine en $x$, d'où la règle

$ hat(g)(x) = op("argmax")_(g in {1, dots, K}) hat(delta)_g (x). $

La frontière entre les classes $g$ et $h$ est définie par
$hat(delta)_g (x) = hat(delta)_h (x)$ : c'est une droite en dimension deux,
un plan en dimension trois, et plus généralement un hyperplan. Les probabilités
estimées se calculent à partir des mêmes scores :

$ hat(eta)_g (x) = exp(hat(delta)_g (x)) /
  (sum_(h=1)^K exp(hat(delta)_h (x))). $

*Estimer le modèle.* À partir du seul ensemble d'entraînement, on utilise
habituellement

$ hat(mu)_g = overline(x)_g, quad
  hat(Sigma) = W/(n-K), quad hat(pi)_g = n_g/n. $

La covariance commune regroupe les dispersions *à l'intérieur* des classes ;
elle ne doit pas être remplacée par la covariance totale, qui inclut leurs
différences de moyenne. Les proportions empiriques sont adaptées si
l'échantillon représente les fréquences visées. Si le plan d'échantillonnage
a surreprésenté certaines classes, les probabilités a priori doivent être
choisies en tenant compte de la population d'utilisation.

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
mesures plus favorables à cette classe pour la choisir. La direction $a$ est
proportionnelle à celle de Fisher lorsque la covariance est estimée par
$W/(n-K)$. Le lien entre projection et classification est donc précis, mais
la direction seule ne détermine pas le seuil.

#example[
  Supposons $mu_1=(0,0)^top$, $mu_2=(2,1)^top$,
  $Sigma=op("diag")(1,4)$ et $pi_1=pi_2=0.5$. Alors

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

=== Analyse discriminante quadratique

La *QDA* (_Quadratic Discriminant Analysis_) autorise une covariance propre
à chaque classe :

$ X bar.v (Y=g) tilde.op cal(N)_p (mu_g, Sigma_g). $

Les classes peuvent donc avoir des dispersions et des orientations différentes.
En supprimant seulement les termes communs à toutes les classes, on obtient

$ delta_g^"QDA" (x) = -1/2 log det(Sigma_g)
  -1/2 (x-mu_g)^top Sigma_g^(-1)(x-mu_g) + log pi_g. $

Le terme en $x$ au carré ne s'annule généralement plus entre deux classes.
Les frontières peuvent être des courbes quadratiques en dimension deux, ou des
surfaces quadratiques en dimension supérieure. Si les covariances sont égales,
on retrouve la règle linéaire.

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

Cette flexibilité a un coût. Une covariance symétrique contient
$p(p+1)/2$ paramètres : la LDA en estime une seule, la QDA en estime $K$.
Pour $p=4$ et $K=3$, cela représente $10$ paramètres de covariance pour la LDA
contre $30$ pour la QDA, en plus des moyennes et des probabilités a priori.
Chaque covariance de QDA est calculée à partir de sa propre classe : les
petites classes peuvent donc poser problème même si l'effectif total est grand.
Le choix entre LDA et QDA repose sur une validation, pas uniquement sur
l'ajustement apparent aux données d'apprentissage.

=== Exemple pratique : Palmer Penguins

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
données locales. On réserve environ 30~% de chaque espèce pour le test, avec
une graine fixée avant d'observer les résultats. Les $240$ observations
d'entraînement servent à ajuster une LDA ; les $102$ autres servent uniquement
à l'évaluer. Le modèle et les quatre variables sont fixés pour cet exemple,
sans recherche d'hyper-paramètres.

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

modele <- MASS::lda(species ~ ., data = train)
prediction <- predict(modele, newdata = test)
table(Reelle = test$species, Predite = prediction$class)
mean(prediction$class == test$species)
```
]

La fonction `lda` du paquet `MASS` utilise ici les proportions de classes de
l'entraînement comme probabilités a priori.#footnote[
  Voir la #link("https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/lda.html")[documentation
  de `MASS::lda`], notamment l'argument `prior`.
] Les prédictions donnent la matrice de confusion suivante :

#table(
  columns: (1.3fr, 1fr, 1fr, 1fr), align: center,
  inset: 6pt, stroke: 0.4pt + luma(210),
  table.header([*Espèce réelle*], [*Prédit Adelie*], [*Prédit Chinstrap*],
    [*Prédit Gentoo*]),
  [Adelie], [45], [0], [0],
  [Chinstrap], [2], [18], [0],
  [Gentoo], [0], [0], [37],
)

Le modèle classe correctement $100$ manchots sur $102$, soit 98,04~%
d'exactitude. Les deux erreurs sont des `Chinstrap` prédits `Adelie` : le rappel
de `Chinstrap` vaut 90~%, contre 100~% pour les deux autres espèces dans ce test.
La règle qui prédit toujours `Adelie`, classe majoritaire de l'entraînement,
atteint seulement $45/102 approx 44.12$~% d'exactitude sur ce même test.

Ces résultats décrivent un partage précis d'un petit jeu de données. Ils ne
garantissent pas 98~% de réussite dans une autre population. Pour comparer
plusieurs sélections de variables, une LDA régularisée et une QDA, on ajouterait
une validation croisée sur les $240$ observations d'entraînement, en conservant
le test à l'écart. Une évaluation par année ou par site répondrait également
à une autre question que ce partage aléatoire d'individus.

=== Régularisation, interprétation et limites

*Des covariances qui doivent être estimables.* La LDA usuelle exige une
covariance intra-groupe inversible. Comme $op("rang")(W) <= n-K$, elle est
singulière si $p > n-K$, et peut l'être aussi à cause de dépendances exactes
entre variables. En QDA, la covariance de la classe $g$ a un rang au plus
$n_g-1$ : il faut notamment $n_g > p$ pour espérer l'inverser. Même lorsque
l'inverse existe, une estimation sur peu de données peut être très instable.

Une solution est de régulariser la covariance, par exemple

$ hat(Sigma)_alpha = (1-alpha) hat(Sigma) + alpha tau I_p,
  quad tau = (op("tr")(hat(Sigma)))/p, quad 0 <= alpha <= 1. $

Si $tau>0$, un $alpha>0$ rend cette matrice définie positive. La régularisation
stabilise les petites valeurs propres en rapprochant la covariance d'une
matrice plus simple. Le choix de $alpha$ doit être fait sur les données
d'entraînement, par validation ; la cible $tau I_p$ dépend des unités, ce qui
rend le choix d'une standardisation pertinent pour cette procédure.

*Échelles et corrélations.* La LDA classique à covariance pleine est invariante,
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

*Séparation visuelle et prédiction.* Un beau plan discriminant construit avec
toutes les étiquettes ne prouve pas une bonne généralisation. La projection
doit être estimée dans chaque entraînement, et la qualité des décisions doit
être mesurée sur des observations laissées de côté. Enfin, les axes décrivent
des contrastes associés aux classes : ils ne démontrent ni une relation
causale ni l'existence de groupes sans recouvrement.


== Arbres de classification et de régression

=== Principe

Les arbres CART partitionnent l'espace des variables explicatives en régions
simples. À chaque noeud, l'algorithme choisit une variable et un seuil qui
séparent les observations en deux sous-ensembles plus homogènes.

Pour une tâche de classification, chaque feuille prédit la classe majoritaire.
Pour une tâche de régression, chaque feuille prédit souvent la moyenne de la
réponse dans la feuille.

Un arbre peut être lu comme une suite de questions. Cette forme le rend très
accessible: chaque chemin depuis la racine jusqu'à une feuille décrit une règle
de décision.

=== Algorithme CART

La construction d'un arbre suit une stratégie gloutonne.

1. Pour chaque variable et chaque seuil possible, calculer le gain
   d'homogénéité.
2. Choisir la coupure qui améliore le plus le critère.
3. Séparer le noeud en deux sous-noeuds.
4. Répéter jusqu'à atteindre un critère d'arrêt.

Cette approche est efficace, mais elle ne garantit pas l'arbre globalement
optimal. Elle choisit à chaque étape la meilleure coupure locale.

=== Critères d'homogénéité

Pour la classification, on utilise souvent:

- le taux d'erreur de classification, simple mais peu sensible pour construire
  l'arbre;
- l'indice de Gini, faible lorsque les feuilles sont pures;
- l'entropie croisée, issue de la théorie de l'information.

Le gain d'une coupure compare l'impureté du noeud avant la coupure à la moyenne
pondérée des impuretés après la coupure. La meilleure coupure est celle qui
réduit le plus l'impureté.

Pour la régression, l'homogénéité est souvent mesurée par la somme des carrés
des écarts à la moyenne dans chaque feuille. Une bonne coupure crée des feuilles
où les valeurs de la réponse sont peu dispersées.

=== Complexité et élagage

Un arbre trop profond surajuste les données: il crée des feuilles très
spécifiques et généralise mal. Un arbre trop petit sous-ajuste: il ne capture
pas assez de structure.

L'élagage consiste à faire croître un arbre puis à retirer les branches qui
apportent peu d'amélioration. On peut utiliser un critère coût-complexité:

$ L(T) = C(T) + alpha |T| $

où $|T|$ est le nombre de feuilles et $alpha$ pénalise la complexité. Le choix de
$alpha$ se fait souvent par validation croisée.

On peut aussi contrôler la complexité par des critères d'arrêt: profondeur
maximale, nombre minimal d'observations dans une feuille, gain minimal exigé pour
une coupure ou nombre maximal de feuilles.

=== Forces et limites

Les arbres sont faciles à interpréter, gèrent naturellement les interactions,
acceptent des variables de types variés et sont peu sensibles aux transformations
monotones des variables.

Ils sont aussi instables: une petite modification des données peut produire un
arbre très différent. Utilisés seuls, ils peuvent être moins performants que des
méthodes agrégées, surtout lorsque les données sont bruitées.

#example[
  Dans un problème de crédit, un arbre peut d'abord séparer les dossiers selon
  le revenu, puis selon l'historique de remboursement. Cette règle est lisible,
  mais une petite variation des données peut changer l'ordre des coupures.
]

== Méthodes ensemblistes

=== Principe

Les méthodes ensemblistes combinent plusieurs modèles simples pour produire une
prédiction plus robuste. Elles améliorent souvent la performance au prix d'une
interprétation moins directe.

Trois grandes familles apparaissent dans le cours:

- le bagging;
- les forêts aléatoires;
- le boosting.

L'idée générale est qu'un ensemble de modèles imparfaits peut être meilleur
qu'un seul modèle, à condition que leurs erreurs ne soient pas toutes les mêmes.

=== Bagging

Le bagging, ou *bootstrap aggregating*, construit plusieurs modèles sur des
échantillons bootstrap des données d'entraînement. Pour la classification, on
combine ensuite les prédictions par vote majoritaire ou par moyenne des
probabilités.

Le bagging réduit la variance et stabilise les prédictions, en particulier pour
des modèles instables comme les arbres.

Si l'on ajuste beaucoup d'arbres profonds sur des échantillons bootstrap, chaque
arbre peut surajuster son propre échantillon, mais la moyenne ou le vote réduit
la variabilité globale.

=== Forêts aléatoires

Les forêts aléatoires ajoutent une source d'aléa au bagging. À chaque coupure
d'un arbre, l'algorithme ne considère qu'un sous-ensemble aléatoire de variables.
Cette contrainte décorrèle les arbres et améliore l'agrégation.

Un choix courant consiste à considérer environ $sqrt(p)$ variables candidates à
chaque coupure en classification, où $p$ est le nombre total de variables.

Les forêts aléatoires fournissent souvent de bonnes performances par défaut.
Elles permettent aussi de mesurer l'importance des variables, par exemple en
observant la perte de performance lorsque les valeurs d'une variable sont
permutées.

=== Boosting

Le boosting construit les modèles de manière séquentielle. Chaque nouveau modèle
se concentre davantage sur les erreurs des modèles précédents. L'objectif est de
combiner plusieurs classificateurs faibles pour obtenir un modèle global très
performant.

AdaBoost ajuste des poids sur les observations. Le gradient boosting formule
l'apprentissage comme une minimisation itérative d'une fonction de perte.

Le boosting peut être très précis, mais il demande un réglage soigné du nombre
d'itérations, de la profondeur des arbres, du taux d'apprentissage et parfois du
sous-échantillonnage.

Contrairement au bagging, qui réduit surtout la variance par moyenne, le
boosting peut réduire le biais en ajoutant progressivement des corrections. En
contrepartie, il peut surajuster si l'on ajoute trop d'itérations ou si les
arbres de base sont trop complexes.

=== Hyper-paramètres et validation

Les méthodes supervisées comportent souvent des paramètres qui ne sont pas appris
directement par le modèle:

- profondeur maximale d'un arbre;
- nombre minimal d'observations dans une feuille;
- nombre d'arbres dans une forêt;
- nombre de variables candidates à chaque coupure;
- taux d'apprentissage en boosting;
- pénalité de complexité.

Ces hyper-paramètres doivent être choisis à l'aide d'un protocole de validation
qui évite de réutiliser le jeu de test pour prendre des décisions.

=== Comparaison rapide

- Bagging: plusieurs modèles indépendants ajustés sur des échantillons bootstrap.
- Forêts aléatoires: bagging d'arbres avec sélection aléatoire de variables à
  chaque coupure.
- Boosting: modèles ajoutés séquentiellement pour corriger les erreurs
  précédentes.

En pratique, les méthodes ensemblistes sont souvent très performantes, mais leur
interprétation doit passer par des outils complémentaires: importance des
variables, profils de dépendance partielle, validation croisée et analyse des
erreurs.

== Méthodes supervisées modernes

=== Gradient boosting moderne

Les implémentations modernes du gradient boosting ont rendu les ensembles
d'arbres particulièrement importants pour les données tabulaires. XGBoost,
LightGBM et CatBoost reposent sur la même idée générale: construire des arbres
séquentiellement pour corriger les erreurs des arbres précédents, tout en
ajoutant des régularisations et des optimisations de calcul.

XGBoost insiste sur la régularisation, la gestion des données creuses et
l'efficacité du calcul. LightGBM utilise des histogrammes et des stratégies
d'échantillonnage pour accélérer l'apprentissage sur de grands tableaux.
CatBoost est conçu pour bien traiter les variables catégorielles et limiter les
fuites d'information liées à leur encodage.

Ces méthodes sont souvent de très bons points de comparaison. Elles exigent
toutefois un réglage attentif: nombre d'arbres, profondeur, taux d'apprentissage,
sous-échantillonnage, pénalités et arrêt précoce.

#note[
  Pour des données tabulaires classiques, un gradient boosting bien validé est
  souvent un adversaire sérieux pour des modèles plus complexes. Il faut donc le
  considérer comme une référence pratique, pas comme une simple amélioration
  technique des arbres.
]

=== Incertitude et calibration

Une prédiction supervisée n'est pas seulement une valeur ou une classe. Dans de
nombreux contextes, on veut aussi savoir à quel point la prédiction est fiable.
Pour une classification, cela conduit à étudier la calibration des probabilités:
parmi les observations prédites avec une probabilité de 0.8, environ 80 pour cent
devraient appartenir à la classe prédite.

Pour une régression, on peut chercher un intervalle de prédiction plutôt qu'une
seule valeur. Les méthodes de prédiction conforme construisent des ensembles ou
des intervalles qui ont une garantie de couverture sous des hypothèses faibles,
notamment l'échangeabilité des observations.

NGBoost fournit une autre approche: au lieu de prédire seulement une moyenne, le
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

L'AutoML automatise une partie du travail: choix d'algorithmes, encodage de
variables, recherche d'hyper-paramètres, empilement de modèles et validation.
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

TabPFN représente une direction plus récente: un modèle pré-entraîné sur de
nombreux problèmes tabulaires synthétiques qui peut produire rapidement des
prédictions sur de petits jeux de données. C'est une ouverture importante, mais
pour un cours général d'analyse des données, ces modèles doivent surtout servir
à discuter des références, des hypothèses et des limites des méthodes
automatisées.

#heading(level: 2, outlined: false)[Exercices]

1. Expliquez le rapport entre variabilité inter-groupe et intra-groupe dans
   l'analyse discriminante.
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
