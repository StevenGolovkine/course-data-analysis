#import "../styles/notes.typ": note, example

#show figure.caption: set align(left)

= Apprentissage supervisé

== Introduction

En apprentissage supervisé, on dispose d'exemples pour lesquels les variables
explicatives et la réponse à prédire sont connues. On utilise ces exemples pour
construire une règle de prédiction, puis on applique cette règle à de nouvelles
observations dont la réponse est encore inconnue. Le mot *supervisé* désigne la
présence de cette réponse dans les données d'apprentissage : elle fournit une
référence pour apprendre et pour mesurer les erreurs.

Il faut distinguer la tâche de prédiction de la description des données. Une
ACP résume la variabilité d'un ensemble de mesures sans utiliser de réponse.
Un classificateur cherche au contraire les caractéristiques qui permettent
de prévoir une étiquette donnée. Une variable très dispersée n'est donc pas
nécessairement utile pour prédire, et une variable peu dispersée peut devenir
essentielle si elle distingue bien les classes.

=== Données, modèle et prédiction

On note l'échantillon d'apprentissage

$ cal(D) = {(x_i, y_i)}_(i=1)^n, quad
  x_i = (x_(i 1), dots, x_(i p))^top in RR^p. $

Le vecteur $x_i$ contient les $p$ variables explicatives de l'observation $i$,
et $y_i$ est sa réponse. Les lettres majuscules $X$ et $Y$ désignent les
variables aléatoires correspondantes. À partir de $cal(D)$, l'algorithme
construit une fonction $hat(f)$ ; la prédiction pour une nouvelle observation
$x$ est $hat(y) = hat(f)(x)$. Le chapeau rappelle que la règle est estimée à
partir d'un échantillon et changerait si l'on changeait les données.

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

Avant de choisir une méthode, il faut définir l'unité observée, la population
visée et les informations disponibles au moment de la prédiction. Une variable
mesurée seulement après la réponse peut être très prédictive dans un fichier
historique tout en étant inutilisable dans la situation réelle.

=== Régression et classification

En *régression*, la réponse est quantitative : une masse, une durée ou une
quantité produite. Le modèle renvoie une valeur numérique. En *classification*,
la réponse est qualitative : une espèce, un type de produit ou une catégorie
de défaut. On note les classes $1, dots, K$ ; ces nombres sont des étiquettes
et ne leur donnent pas un ordre ni des distances numériques.

Un classificateur peut produire deux sortes de résultats :

- des probabilités estimées $hat(eta)_g (x) approx P(Y=g mid X=x)$ pour chaque
  classe $g$, de somme $1$ ;
- une décision $hat(g)(x)$, obtenue en choisissant une classe à partir de ces
  probabilités et d'une règle de décision.

Par exemple, des probabilités $(0.55, 0.40, 0.05)$ conduisent à choisir la
première classe si l'on retient la plus probable. Cette décision est moins
tranchée qu'avec $(0.98, 0.01, 0.01)$, alors que l'étiquette prédite est la même.
Une probabilité annoncée par un modèle n'est toutefois fiable que si le modèle
est convenablement calibré, question reprise plus loin dans le chapitre.

*Définir ce qu'est une erreur.* Une fonction de perte $L(y, hat(y))$ attribue un
coût à l'écart entre la réponse réelle et la prédiction. Deux pertes usuelles
en régression sont

$ L_2(y, hat(y)) = (y-hat(y))^2, quad
  L_1(y, hat(y)) = abs(y-hat(y)). $

La perte quadratique pénalise particulièrement les grandes erreurs ; la perte
absolue croît proportionnellement à leur taille. Au niveau de la population,
la prédiction qui minimise l'erreur quadratique moyenne est
$f^*(x) = E(Y mid X=x)$ ; pour l'erreur absolue moyenne, c'est une médiane de
la loi conditionnelle de $Y$ sachant $X=x$. Le choix de la perte définit donc
aussi la quantité que l'on cherche à prédire.

En classification, la *perte 0–1* vaut $0$ si la classe prédite est correcte et
$1$ sinon. Elle conduit à choisir la classe de probabilité conditionnelle
maximale. Si certaines erreurs sont plus coûteuses que d'autres, la décision
optimale peut être différente : les probabilités prédites et les coûts doivent
alors être combinés explicitement.

=== Évaluer les prédictions

L'objectif est de réduire le *risque de prédiction*

$ R(f) = E[L(Y, f(X))], $

où l'espérance porte sur une nouvelle observation de la population visée.
Ce risque est inconnu. Pour un modèle fixé, on l'estime sur $m$ observations
de test qui n'ont pas servi à le construire ou à le sélectionner :

$ hat(R)_"test" (hat(f)) = 1/m sum_(i=1)^m
  L(y_i^"test", hat(f)(x_i^"test")). $

En régression, on peut rapporter l'erreur absolue moyenne (MAE), l'erreur
quadratique moyenne (MSE), ou sa racine carrée (RMSE). La MAE et la RMSE ont
les mêmes unités que la réponse, ce qui facilite leur interprétation.

En classification, le taux d'erreur est la proportion de mauvaises décisions.
L'*exactitude* (_accuracy_) est la proportion complémentaire de bonnes
décisions. La *matrice de confusion* détaille quelles classes sont confondues
et permet de dépasser un seul pourcentage global.

#example[
  Un contrôle de qualité cherche à détecter les produits défectueux, qui
  constituent la classe positive. Sur un jeu de test de $100$ produits,
  on observe les résultats suivants ; les lignes donnent la réalité et les
  colonnes la prédiction.

  #table(
    columns: (1.5fr, 1fr, 1fr), align: center,
    inset: 6pt, stroke: 0.4pt + luma(210),
    table.header([*Classe réelle*], [*Prédit défectueux*], [*Prédit conforme*]),
    [Défectueux], [18], [12],
    [Conforme], [7], [63],
  )

  L'exactitude vaut $(18+63)/100 = 0.81$, soit 81~%. Pourtant, le modèle ne
  détecte que $18/30 = 60$~% des produits défectueux : c'est la *sensibilité*,
  aussi appelée *rappel* de la classe positive. La *spécificité* vaut
  $63/70 = 90$~% : elle mesure la proportion des produits conformes reconnus
  comme tels. Enfin, parmi les produits signalés comme défectueux,
  $18/25 = 72$~% le sont réellement : c'est la *précision* de la classe positive.
]

Une bonne exactitude peut masquer l'échec sur une classe rare. Si 95~% des
produits sont conformes, prédire systématiquement « conforme » donne 95~%
d'exactitude et un rappel nul pour les défauts. Il faut donc comparer le modèle
à une règle de référence simple, examiner les résultats par classe et choisir
les métriques selon la décision visée. Pour une réponse binaire, les courbes
ROC et précision-rappel permettent aussi d'examiner plusieurs seuils ; elles
ne remplacent pas le choix d'un seuil adapté à l'utilisation.

=== Généralisation et surajustement

La performance sur les données d'apprentissage est généralement optimiste,
puisque la règle a été choisie à partir de ces données. Un modèle peut obtenir
une erreur d'entraînement nulle en mémorisant les exemples sans savoir prédire
de nouvelles observations. Cette capacité à réussir sur de nouvelles données
s'appelle la *généralisation*.

Le compromis biais-variance aide à comprendre la difficulté. Un modèle trop
contraint peut *sous-ajuster* : il ignore une structure importante et commet
déjà beaucoup d'erreurs à l'entraînement. Un modèle très flexible peut
*surajuster* : ses prédictions deviennent sensibles aux particularités de
l'échantillon, et son erreur de validation reste élevée malgré une faible
erreur d'entraînement. Une partie de l'incertitude peut aussi être irréductible
avec les variables disponibles, par exemple lorsque deux espèces présentent
des mesures similaires.

Les *paramètres* sont estimés pendant l'ajustement, comme les moyennes des
classes en analyse discriminante. Les *hyper-paramètres* contrôlent la manière
d'apprendre, comme la profondeur maximale d'un arbre ou l'intensité d'une
régularisation. Leur choix fait partie de la construction du modèle et doit
être évalué sans consulter le jeu de test final.

=== Entraînement, validation et test

Les trois ensembles ont des rôles distincts :

1. L'*entraînement* sert à estimer les paramètres de chaque modèle candidat.
2. La *validation* sert à comparer les méthodes et les hyper-paramètres, et à
   choisir éventuellement un seuil de décision.
3. Le *test* sert à évaluer la procédure retenue, une fois ces choix arrêtés.

Par exemple, on pourrait répartir $1 000$ observations indépendantes en $600$
pour l'entraînement, $200$ pour la validation et $200$ pour le test. Ces
proportions ne sont pas une règle universelle : chaque ensemble doit contenir
assez d'observations et représenter la situation d'utilisation.

La *validation croisée* réutilise plus efficacement les données disponibles
pour le choix du modèle. Après avoir réservé le test, on partage les autres
observations en $V$ plis. Pour chaque configuration, on ajuste $V$ modèles,
chacun sur $V-1$ plis, puis on l'évalue sur le pli laissé de côté. On compare
les erreurs moyennes, on retient une configuration et on la réajuste sur toutes
les données hors test avant l'évaluation finale.

#example[
  Pour choisir la profondeur d'un arbre, on réserve $200$ observations de test
  et on répartit les $800$ autres en cinq plis de $160$. Chaque ajustement
  utilise $640$ observations et chaque validation en utilise $160$. Après
  comparaison des profondeurs, l'arbre retenu est réajusté sur les $800$
  observations. Les $200$ observations de test ne servent qu'à l'évaluation
  finale. Si l'on change ensuite le modèle à la lumière de ce résultat,
  ce jeu ne joue plus le rôle d'un test indépendant des choix effectués.
]

*Éviter les fuites d'information.* Toute opération qui apprend des paramètres
à partir des données doit être incluse dans ce protocole : imputation,
centrage-réduction, sélection de variables, ACP ou projection discriminante.
Dans chaque pli, elle est ajustée sur la partie d'entraînement puis appliquée
à la partie de validation avec les mêmes paramètres. Calculer une projection
discriminante sur toutes les observations avant de les séparer transmettrait
aux axes l'information sur les classes à prédire.

Le découpage doit aussi respecter la structure des observations. Une séparation
stratifiée conserve approximativement les proportions de classes. Des mesures
répétées d'un même individu doivent rester dans un même ensemble si l'objectif
est de généraliser à de nouveaux individus. Pour prévoir le futur, on entraîne
sur le passé et on valide sur des périodes ultérieures. Enfin, une bonne
performance sur un test issu de la même population ne garantit pas la même
performance après un changement de population ou de protocole de mesure.

=== Trois familles de méthodes

Ce chapitre présente trois familles classiques, qui partagent le même besoin
d'évaluation mais construisent leurs prédictions de façons différentes.

- L'*analyse discriminante* décrit les distributions des variables dans les
  classes, ou construit des projections qui séparent leurs moyennes en tenant
  compte de leur dispersion. Elle relie géométrie et probabilités de classe.
- Les *arbres de classification et de régression* découpent l'espace des
  variables par une suite de conditions simples et prédisent dans chaque région.
- Les *méthodes ensemblistes* combinent plusieurs modèles, notamment des arbres,
  pour stabiliser ou améliorer les prédictions.

Ces méthodes seront comparées selon leurs hypothèses, la forme de leurs
frontières, leur sensibilité aux données et leur performance sur des
observations non utilisées pour les choisir.

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

$ bar(x)_g = 1/n_g sum_(i in C_g) x_i, quad
  bar(x) = 1/n sum_(i=1)^n x_i = sum_(g=1)^K n_g/n bar(x)_g. $

On définit les matrices de dispersion *intra-groupe* et *inter-groupe* :

$
  W = sum_(g=1)^K sum_(i in C_g)
      (x_i-bar(x)_g)(x_i-bar(x)_g)^top,
$
$
  B = sum_(g=1)^K n_g (bar(x)_g-bar(x))(bar(x)_g-bar(x))^top.
$

$W$ mesure les écarts de chaque observation à la moyenne de sa classe ; $B$
mesure les écarts des moyennes de classe à la moyenne globale, pondérés par les
effectifs. Ce sont ici des *sommes* de produits d'écarts, sans division par des
degrés de liberté. La dispersion totale se décompose exactement en

$ T = sum_(i=1)^n (x_i-bar(x))(x_i-bar(x))^top = W+B. $

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

*Deux classes.* En posant $d = bar(x)_2-bar(x)_1$, on obtient
$B = (n_1 n_2/n) d d^top$. Lorsque $d != 0$, la direction optimale vérifie

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

$ X mid (Y=g) ~ cal(N)_p(mu_g, Sigma), quad P(Y=g) = pi_g. $

Chaque classe a sa propre moyenne $mu_g$, mais toutes partagent la même matrice
de covariance $Sigma$, supposée définie positive. Les probabilités *a priori*
$pi_g > 0$ somment à $1$ et décrivent les fréquences des classes avant
d'observer les mesures. La normalité est supposée *dans chaque classe* : la
distribution globale, mélange de ces classes, n'a pas à être normale.

Si $f_g(x)$ est la densité normale de la classe $g$, la formule de Bayes donne
la probabilité *a posteriori*

$ eta_g (x) = P(Y=g mid X=x)
  = (pi_g f_g(x)) / (sum_(h=1)^K pi_h f_h(x)). $

Sous la perte 0–1, on choisit la classe de plus grande probabilité. Le
dénominateur étant commun, cela revient à maximiser
$log pi_g + log f_g(x)$. Avec une covariance commune, le terme quadratique
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

$ hat(mu)_g = bar(x)_g, quad
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

$ R("prédire 2" mid x) = C_"FP" (1-eta_2 (x)), quad
  R("prédire 1" mid x) = C_"FN" eta_2 (x). $

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

$ X mid (Y=g) ~ cal(N)_p(mu_g, Sigma_g). $

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
  quad tau = op("tr")(hat(Sigma))/p, quad 0 <= alpha <= 1. $

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
