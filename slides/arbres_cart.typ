// STT-2200 : arbres de classification et de régression.
// Source : lectures/supervised.typ, section <arbres-cart> uniquement.
// Exemples et figures : codes/arbres_cart.R et figures/arbres_cart.py.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/arbres_cart.typ
#import "../styles/slides.typ": *
#import "../styles/math.typ": ind, argmin, argmax
#let sce = math.op("SCE")

#show: course-slides.with(
  title: [Arbres de classification et de régression],
  footer-title: [CART],
)

#title-slide()

= Prédire par une suite de questions

== Le principe de CART

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Des questions binaires], [
    Chaque nœud pose une question sur une variable explicative.
    #v(1em)
    La réponse détermine l'un des deux descendants, jusqu'à une feuille.
  ], height: 2.4in),
  card([Une prédiction locale], [
    *Classification* : une classe.

    *Régression* : une valeur numérique.
    #v(1em)
    La prédiction reste la même dans chaque feuille.
  ], fill: pale-blue, height: 2.4in),
)
#v(0.65em)
#takeaway([L'apprentissage choisit les questions en utilisant la réponse $y$.])
#v(0.35em)
#small([CART : _Classification and Regression Trees_. Les groupes ont ici un objectif supervisé.])

== Racine, nœuds et feuilles

#course-table(
  columns: (1fr, 3fr),
  table.header([*Terme*], [*Rôle dans l'arbre*]),
  [Racine], [Contient toutes les observations d'entraînement.],
  [Nœud interne], [Pose une question et sépare les observations en deux.],
  [Feuille], [Termine le chemin et fournit la prédiction.],
  [Profondeur], [Nombre d'arêtes entre la racine et le nœud.],
  [$M$ feuilles], [Définissent les régions disjointes $R_1, dots, R_M$.],
)
#v(0.65em)
#takeaway([La racine est à profondeur 0. Un arbre à deux feuilles pose une seule question.])

== Un arbre et sa partition de l'espace

#align(center)[
  #image("../figures/cart_partition.svg", width: 100%, height: 3.8in,
    fit: "contain",
    alt: "Une coupure x1 inférieur ou égal à 2 prédit A à gauche. À droite, "
      + "une coupure x2 inférieur ou égal à 1 prédit B en bas et A en haut.")
]
#v(0.35em)
#takeaway([La seconde question s'applique seulement à la branche où $x_1 > 2$.])

== Le chemin d'une nouvelle observation

#formula([
  $ R_1 = \{x : x_1 <= 2\}, quad
    R_2 = \{x : x_1 > 2, x_2 <= 1\}, quad
    R_3 = \{x : x_1 > 2, x_2 > 1\} $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Exemple : $x = (3, 0.6)^top$], [
    Première question : $3 <= 2$ ? Non.

    Seconde question : $0.6 <= 1$ ? Oui.
    #v(1em)
    On arrive dans $R_2$ : prédiction *B*.
  ], height: 2.45in),
  card([Une interaction], [
    La variable $x_2$ intervient seulement lorsque $x_1 > 2$.

    #v(1em)
    Une même variable peut aussi revenir plusieurs fois le long du chemin.
  ], fill: pale-blue, height: 2.45in),
)

== Les questions dépendent du type de variable

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Variable quantitative], [
    Question : $x_j <= s$ ?

    #v(1em)
    L'autre branche correspond à $x_j > s$.

    #v(1em)
    Les régions sont des produits d'intervalles, éventuellement non bornés.
  ], height: 2.8in),
  card([Variable qualitative], [
    Question : $x_j in S$ ?

    #v(1em)
    $S$ est un sous-ensemble des modalités.

    #v(1em)
    Un codage arbitraire 1, 2, 3 peut imposer un ordre injustifié.
  ], fill: pale-blue, height: 2.8in),
)

= Prédire dans une feuille

== Classification : proportions et classe prédite

$cal(I)_t = \{i : x_i in R_t\}$, $n_t = abs(cal(I)_t)$ et $K$ classes.
#v(0.45em)
#formula([
  $ hat(p)_(t g) = 1/n_t sum_(i in cal(I)_t) ind(y_i = g), quad text("et")quad
    hat(g)(x) = argmax_g hat(p)_(t g) quad "si" x in R_t. $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une feuille de dix observations], [
    Soit une feuille avec 7 A, 2 B et 1 C.
    #v(1em)
    Probabilités estimées : $(0.7, 0.2, 0.1)$.
    #v(1em)
    Classe prédite : A.
  ], height: 2.1in),
  card([Une décision à préciser], [
    Retenir la classe la plus fréquente et fixer une règle d'égalité.
    #v(1em)
    Avec plusieurs classes, elle peut avoir moins de 50~% des voix.
  ], fill: pale-blue, height: 2.1in),
)

== Régression : la meilleure constante dépend de la perte

$cal(I)_t = \{i : x_i in R_t\}$ et $n_t = abs(cal(I)_t)$.

#formula([
  $ overline(y)_t = 1/n_t sum_(i in cal(I)_t) y_i
    = argmin_(c in RR) sum_(i in cal(I)_t) (y_i - c)^2. $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Perte quadratique], [
    La feuille prédit la *moyenne*.
  ], height: 1in),
  card([Perte absolue], [
    La feuille prédit la *médiane*.
  ], fill: pale-blue, height: 1in),
)
#v(0.55em)
$hat(f)(x) = sum_(t=1)^M overline(y)_t ind(x in R_t)$ : une fonction constante par morceaux.

== Des coûts différents modifient la décision

Soit $c_"FP"$ le coût d'un faux positif et $c_"FN"$ le coût d'un faux négatif.

#formula([
  $ "Prédire 1 si" quad c_"FP" (1-p) < c_"FN" p
    quad <=> quad p > c_"FP" / (c_"FP" + c_"FN"). $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Neuf 0 et trois 1], [
    La feuille estime $p = 3/12 = 0.25$.
    #v(1em)
    À coûts égaux, le seuil vaut $0.5$ : on prédit 0.
  ], height: 2in),
  card([Faux négatif plus coûteux], [
    $c_"FN" = 5$, $c_"FP" = 1$ : seuil $1/6$.
    #v(1em)
    Prédire 1 coûte $0.75$, mais $1.25$ pour prédire 0.
  ], fill: pale-orange, height: 2in),
)
#v(0.45em)
Ici, l'arbre est fixé. Introduire des coûts dès l'apprentissage peut aussi modifier les coupures.

= Apprendre les coupures

== Les seuils candidats dans un nœud

#formula([
  $ cal(I)_L = \{i in cal(I)_t : x_(i j) <= s\}, quad
    cal(I)_R = \{i in cal(I)_t : x_(i j) > s\} $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Trier les valeurs distinctes], [
    Valeurs présentes : 1, 2, 4, 7.

    Seuils possibles : $1.5$, $3$ et $5.5$.

    #v(1em)
    Un milieu entre valeurs consécutives suffit pour chaque partition.
  ], height: 2in),
  card([Vérifier l'admissibilité], [
    Chaque descendant doit respecter l'effectif minimal demandé.
    #v(1em)
    Deux observations de même valeur restent ensemble sur cette variable.
  ], fill: pale-blue, height: 2in),
)

== Une construction gloutonne et récursive

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Énumérer], [
    Examiner les coupures admissibles de chaque variable au nœud courant.
  ], height: 1.2in),
  card([2. Évaluer], [
    Calculer le gain d'homogénéité de chaque coupure.
  ], fill: pale-blue, height: 1.2in),
  card([3. Choisir], [
    Garder le gain maximal, avec une règle d'égalité fixée.
  ], fill: pale-purple, height: 1.2in),
  card([4. Recommencer], [
    Traiter les deux descendants jusqu'au critère d'arrêt.
  ], fill: pale-orange, height: 1.2in),
)
#v(0.55em)
#takeaway([La meilleure coupure immédiate ne garantit pas le meilleur arbre final.])

== Trois mesures d'impureté en classification

#course-table(
  columns: (1.1fr, 2.4fr, 1.2fr),
  table.header([*Critère*], [*Formule au nœud $t$*], [*Maximum*]),
  [Gini], [$1 - sum_(g=1)^K hat(p)_(t g)^2$], [$1 - 1/K$],
  [Entropie], [$-sum_(g=1)^K hat(p)_(t g) log(hat(p)_(t g))$], [$log(K)$],
  [Erreur de classification], [$1 - max_g hat(p)_(t g)$], [$1 - 1/K$],
)
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Nœud pur], [
    Une seule classe : les trois critères valent 0.
  ], height: 1in),
  card([Classes également représentées], [
    Les impuretés sont maximales.
  ], fill: pale-blue, height: 1in),
)

Convention : $0 log(0) = 0$.

== Un gain d'homogénéité pondéré par les effectifs

#formula([
  $ Delta I(t; j, s) = I(t) - n_L/n_t I(L) - n_R/n_t I(R) $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Gain local], [
    Comparer le parent à la moyenne pondérée des impuretés des descendants.
    #v(1em)
    Une petite feuille pure peut laisser une grande feuille très mélangée.
  ], height: 2.5in),
  card([Contribution à l'arbre entier], [
    $ n_t/n Delta I(t; j, s) $
    #v(1em)
    Le poids du nœud intervient lorsqu'on compare des gains à des endroits différents.
  ], fill: pale-blue, height: 2.5in),
)

== Exemple : comparer deux coupures avec l'indice de Gini

$x = 1, dots, 10$ et classes $("A", "A", "A", "A", "B", "A", "B", "B", "A", "B")$.
#v(0.4em)
#formula([$ I(t) = 1 - (6/10)^2 - (4/10)^2 = 0.48 $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Seuil 4,5], [
    Gauche : 4 A. Droite : 2 A et 4 B.

    $ Delta I = 0.48 - 4/10 times 0 - 6/10 times 4/9 $
  #v(1em)
    Gain : *0,2133*.
  ], height: 2.45in),
  card([Seuil 2,5], [
    Gauche : 2 A. Droite : 4 A et 4 B.

    $ Delta I = 0.48 - 2/10 times 0 - 8/10 times 0.5 $
    #v(1em)
    Gain : *0,08*.
  ], fill: pale-blue, height: 2.45in),
)

== Une impureté peut baisser sans réduire les erreurs

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Avant la coupure], [
    Un nœud contient 8 A et 2 B.

    Prédire A commet *2 erreurs*.
  #v(1em)
    Gini : $1 - 0.8^2 - 0.2^2 = 0.32$.
  ], height: 2in),
  card([Après la coupure], [
    Deux nœuds : 4 A, puis 4 A et 2 B.

    Prédire A partout commet encore *2 erreurs*.
    #v(1em)
    Gini pondéré : $6/10 times 4/9 approx 0.2667$.
  ], fill: pale-blue, height: 2in),
)
#v(0.65em)
#takeaway([L'ndice de Gini et l'entropie détectent des changements de proportions avant un changement de classe prédite.])

== Régression : réduire les carrés résiduels

#formula([
  $ sce(t) = sum_(i in cal(I)_t) (y_i - overline(y)_t)^2 $
  $ Delta sce = sce(t) - sce(L) - sce(R)
    = (n_L n_R)/n_t (overline(y)_L - overline(y)_R)^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ce que la coupure cherche], [
    Des moyennes de réponses différentes dans les descendants, en tenant compte de leurs effectifs.
  ], height: 1.65in),
  card([Lien avec la variance], [
    Avec le diviseur $n_t$, le gain d'impureté vaut $ (Delta sce) / n_t. $
  ], fill: pale-blue, height: 1.65in),
)

== Exemple : une réponse en deux paliers

$x = (1, 2, 3, 4, 5, 6)$ et $y = (1, 2, 3, 8, 9, 10)$.
#align(center)[
  #image("../figures/cart_regression.svg", width: 100%, height: 3.65in,
    fit: "contain",
    alt: "Le seuil 3,5 sépare deux feuilles prédisant 2 et 9. La somme des "
      + "carrés résiduels après coupure est minimale et vaut 4.")
]
#takeaway([$sce(t) = 77.5$ et $Delta sce = 77.5 - (2 + 2) = 73.5$.])

= Construire un arbre pas à pas

== Douze observations à classer

#course-table(
  columns: (1.2fr, 1fr, 1fr, 1fr),
  table.header([*Valeurs de $x$*], [1 à 4], [5 à 8], [9 à 12]),
  [Classe observée], [A], [B], [A],
  [Effectif], [4], [4], [4],
)
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Racine], [
    8 A et 4 B.
    $ I(t) = 1 - (8/12)^2 - (4/12)^2 = 4/9 $
  ], height: 2in),
  card([Règles de construction], [
    Au moins 2 observations par feuille.
    #v(1em)
    À gain égal, choisir le plus petit seuil.
  ], fill: pale-blue, height: 2in),
)

== Première coupure : deux seuils ex æquo

#course-table(
  columns: (1fr, 1fr, 1fr),
  table.header([*Seuil $s$*], [*Gain exact*], [*Gain approché*]),
  [2,5], [$2/45$], [0,0444],
  [*4,5*], [*$1/9$*], [*0,1111*],
  [6,5], [0], [0],
  [8,5], [$1/9$], [0,1111],
  [10,5], [$2/45$], [0,0444],
)
#v(0.65em)
#takeaway([Le maximum est atteint en 4,5 et 8,5. La règle d'égalité retient 4,5.])

== Deuxième coupure dans la branche droite

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([À gauche], [
    Les quatre premières observations sont A.
    #v(1em)
    Le nœud est pur : on conserve cette feuille.
  ], height: 2.6in),
  card([À droite : seuil 8,5], [
    Séparer les 4 B des 4 A donne deux feuilles pures.
    #v(1em)
    Gain local : $1/2$.
    #v(1em)
    Gain pour l'arbre : $8/12 times 1/2 = 1/3$.
  ], fill: pale-blue, height: 2.6in),
)
#v(0.65em)
#takeaway([Une même variable peut servir à plusieurs coupures et décrire une relation non monotone.])

== L'arbre obtenu et ses régions

#align(center)[
  #image("../figures/cart_construction.svg", width: 100%, height: 3.9in,
    fit: "contain",
    alt: "L'arbre à trois feuilles prédit A si x est inférieur ou égal à 4,5, "
      + "B entre 4,5 et 8,5, et A au-delà. Chaque feuille contient quatre observations.")
]
#v(0.3em)
#takeaway([Trois feuilles, profondeur maximale 2. Pour $x = 7.2$, prédire B. Pour $x = 10.5$, prédire A.])

== L'impureté et l'erreur évoluent différemment

#course-table(
  columns: (1.5fr, 0.8fr, 1.2fr, 1.3fr),
  table.header([*Étape*], [*Feuilles*], [*Gini moyen*], [*Erreurs sur 12*]),
  [Racine seule], [1], [$4/9$], [4],
  [Coupure en 4,5], [2], [$1/3$], [4],
  [Puis coupure en 8,5], [3], [0], [0],
)
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une amélioration préparatoire], [
    La première coupure améliore l'indice de Gini avant de réduire le nombre d'erreurs.
  ], height: 1.65in),
  card([Une erreur d'entraînement], [
    Zéro erreur sur ces douze observations ne garantit pas zéro erreur sur de nouvelles données.
  ], fill: pale-orange, height: 1.65in),
)


= Complexité et élagage

== La taille de l'arbre et le surajustement

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Arbre trop petit], [
    Peu de régions et une structure simple.
    #v(1em)
    Risque de manquer des différences importantes entre les réponses.
  ], height: 2in),
  card([Arbre très développé], [
    Plus de détails et une faible erreur d'entraînement.
    #v(1em)
    Risque d'ajuster le bruit et de créer de petites feuilles instables.
  ], fill: pale-orange, height: 2in),
)

== Pré-élagage et post-élagage

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Limiter la croissance], [
    Profondeur maximale, effectifs minimaux, gain minimal ou nombre maximal de feuilles.
    #v(1em)
    Un arrêt précoce peut empêcher des coupures utiles plus loin.
  ], height: 2in),
  card([Réduire un arbre développé], [
    Remplacer certains sous-arbres par une feuille.
    #v(1em)
    L'élagage supprime des branches existantes. Il ne remplace pas une mauvaise coupure à la racine.
  ], fill: pale-blue, height: 2in),
)

== Le critère coût-complexité

#formula([$ C_(alpha)(T) = C(T) + alpha M(T), quad alpha >= 0 $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Erreur ou impureté $C(T)$], [
    Mesurer l'ajustement sur l'entraînement.
    #v(1em)
    Par exemple : taux d'erreur de classification ou somme des carrés divisée par $n$.
  ], height: 2in),
  card([Pénalité $alpha M(T)$], [
    $M(T)$ est le nombre de feuilles.
    #v(1em)
    Une valeur de $alpha$ plus élevée favorise un arbre plus petit.
  ], fill: pale-blue, height: 2in),
)
#v(0.45em)
Le critère d'élagage peut différer du critère de coupure. La normalisation fixe l'échelle de $alpha$.

== Exemple : comparer trois sous-arbres

#course-table(
  columns: (1fr, 1.3fr, 1.3fr, 1.3fr),
  table.header([*Feuilles*], [*$C(T)$*], [*Pénalité*], [*$C_(0.03)(T)$*]),
  [1], [0,40], [0,03], [0,43],
  [*3*], [*0,15*], [*0,09*], [*0,24*],
  [5], [0,10], [0,15], [0,25],
)
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Passer de 3 à 5 feuilles], [
    Réduction d'erreur : $0.15 - 0.10 = 0.05$.
  ], height: 1in),
  card([Pénalité supplémentaire], [
    $2 times 0.03 = 0.06$ : elle dépasse le gain.
  ], fill: pale-blue, height: 1in),
)

== Le seuil d'élagage d'une branche

#formula([
  $ alpha_t = (r(t) - r(T_t)) / (m_t - 1) $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Augmentation d'erreur], [
    $r(t)$ : contribution si le nœud devient une feuille.
    #v(1em)
    $r(T_t)$ : contribution actuelle de son sous-arbre.
  ], height: 2in),
  card([Feuilles supprimées], [
    Le sous-arbre a $m_t$ feuilles.
    #v(1em)
    L'élagage supprime #box[$m_t - 1$] feuilles.
  ], fill: pale-blue, height: 2in),
)

Élaguer devient avantageux dès $alpha >= alpha_t$.

== L'élagage peut sauter une taille intermédiaire

$x = 1, dots, 12$ et classes $("A", "A", "A", "A", "B", "B", "B", "B", "A", "A", "A", "A")$. On utilise le *taux d'erreur de classification*.

#v(0.4em)
#course-table(
  columns: (1.7fr, 1fr, 1fr, 1fr),
  table.header([*Sous-arbre supprimé*], [*Hausse d'erreur*], [*Feuilles en moins*], [*$alpha_t$*]),
  [Branche droite], [$1/3$], [1], [$1/3$],
  [*Arbre entier*], [*$1/3$*], [*2*], [*$1/6$*],
)
#v(0.65em)
#formula([
  $ C_(alpha)(T_3) = 3 alpha, quad C_(alpha)(T_1) = 1/3 + alpha $
])
#v(0.55em)
#takeaway([Le chemin passe de 3 feuilles à 1. Au seuil $alpha = 1/6$, les deux candidats sont équivalents.])

= Choisir $alpha$ par validation

== Une sélection sans utiliser le test

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Réserver le test], [
    Fixer les seuils candidats et les contraintes sur le jeu d'entraînement.
  ], height: 1.55in),
  card([2. Reconstruire dans chaque pli], [
    Apprendre les coupures sans les réponses du pli de validation.
  ], fill: pale-blue, height: 1.55in),
  card([3. Choisir la complexité], [
    Comparer les pertes de validation des arbres élagués.
  ], fill: pale-purple, height: 1.55in),
  card([4. Réajuster et évaluer], [
    Apprendre sur tout l'entraînement, puis évaluer une fois sur le test.
  ], fill: pale-orange, height: 1.55in),
)
#v(0.55em)
#takeaway([Élaguer dans les plis un arbre appris sur toutes les données provoquerait une fuite d'information.])

== Minimum de validation ou règle d'une erreur standard

#course-table(
  columns: (0.8fr, 1.3fr, 1.3fr, 1.3fr),
  table.header([*Feuilles*], [*Entraînement*], [*Validation*], [*Erreur standard*]),
  [2], [0,25], [0,26], [0,03],
  [4], [0,14], [0,18], [0,03],
  [8], [0,08], [0,17], [0,03],
  [16], [0,02], [0,22], [0,04],
)
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Règle du minimum], [
    Erreur minimale : $0.17$.
    #v(1em)
    Retenir *8 feuilles*.
  ], height: 1.6in),
  card([Règle d'une erreur standard], [
    Seuil : $0.17 + 0.03 = 0.20$.
    #v(1em)
    Le plus petit candidat admissible a *4 feuilles*.
  ], fill: pale-blue, height: 1.6in),
)


= Interprétation et limites


== Instabilité et importance des variables

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Des coupures presque ex æquo], [
    Une petite modification des données peut changer la racine et toutes les branches suivantes.
    #v(1em)
    Une variable corrélée peut remplacer une autre dans l'arbre.
  ], height: 2.8in),
  card([Des importances à contextualiser], [
    Une variable absente n'est pas nécessairement inutile.
    #v(1em)
    Les gains peuvent favoriser les variables offrant beaucoup de coupures candidates.
  ], fill: pale-orange, height: 2.8in),
)
#v(0.65em)
#takeaway([Les règles et les importances décrivent le modèle appris, sans mesurer un effet causal.])

== Prédictions par paliers et probabilités fragiles

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Régression], [
    Deux points proches de part et d'autre d'un seuil peuvent recevoir des prédictions différentes.
    #v(1em)
    Les moyennes des feuilles restent entre les réponses extrêmes d'entraînement.
  ], height: 2.85in),
  card([Classification], [
    Deux A sur deux observations donnent une proportion empirique de 1.
    #v(1em)
    Ce faible effectif ne permet pas de conclure à une certitude. Examiner la calibration si nécessaire.
  ], fill: pale-orange, height: 2.85in),
)
#v(0.6em)
#takeaway([Un arbre de régression à moyennes de feuilles ne prolonge pas une tendance au-delà des données.])


== L'essentiel à retenir

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([Une partition supervisée], [
    Les coupures cherchent des réponses homogènes et donnent une prédiction par feuille.
  ], height: 1.6in),
  card([Une recherche locale], [
    CART choisit le meilleur gain immédiat, sans garantir l'optimum global.
  ], fill: pale-blue, height: 1.6in),
  card([Une complexité à sélectionner], [
    Croissance, élagage et validation croisée règlent le niveau de détail.
  ], fill: pale-purple, height: 1.6in),
  card([Une interprétation prudente], [
    Vérifier les effectifs, la stabilité et les erreurs sur de nouvelles observations.
  ], fill: pale-orange, height: 1.6in),
)
