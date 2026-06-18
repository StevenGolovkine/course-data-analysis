#import "../styles/notes.typ": note, example

= Apprentissage supervisé

== Introduction

En apprentissage supervisé, les données d'entraînement contiennent une variable
réponse. L'objectif est d'apprendre une règle qui associe les variables
explicatives à cette réponse, puis de généraliser cette règle à de nouvelles
observations.

Lorsque la réponse est numérique, on parle de régression. Lorsque la réponse est
une classe, on parle de classification. Ce chapitre met surtout l'accent sur la
classification.

On note souvent les variables explicatives $X$ et la réponse $Y$. À partir d'un
échantillon d'apprentissage, on cherche une fonction $hat(f)$ telle que
$hat(Y) = hat(f)(X)$ soit proche de la vraie réponse. Le modèle n'est pas évalué
sur sa capacité à reproduire parfaitement les données déjà vues, mais sur sa
capacité à prédire correctement de nouvelles observations.

#note[
  Une méthode supervisée doit toujours être évaluée sur des observations qui
  n'ont pas servi à l'ajustement. Sinon, on mesure surtout la capacité du modèle
  à mémoriser les données d'entraînement.
]

=== Régression et classification

En régression, la réponse est quantitative. On peut mesurer l'erreur avec une
erreur quadratique, une erreur absolue ou une autre perte adaptée au contexte.
En classification, la réponse est qualitative. On peut utiliser le taux d'erreur,
la matrice de confusion, la sensibilité, la spécificité ou l'aire sous la courbe
ROC.

Le choix de la mesure d'erreur dépend de la décision visée. Dans un problème de
diagnostic, une fausse alerte et un cas manqué n'ont pas forcément le même coût.
Dans un problème de prix ou de demande, une erreur très grande peut être plus
grave que plusieurs petites erreurs.

=== Généralisation

La difficulté centrale est le compromis biais-variance. Un modèle trop simple
risque de sous-ajuster: il ignore une partie de la structure réelle. Un modèle
trop flexible risque de surajuster: il apprend les particularités de l'échantillon
d'entraînement plutôt que la structure générale.

Pour contrôler ce risque, on sépare les données en ensembles d'entraînement, de
validation et de test, ou on utilise la validation croisée. Les hyper-paramètres
doivent être choisis sans consulter le jeu de test final.

#example[
  Pour choisir la profondeur maximale d'un arbre, on peut essayer plusieurs
  valeurs par validation croisée sur l'ensemble d'entraînement. Le jeu de test
  n'est utilisé qu'à la fin pour estimer la performance finale.
]

=== Trois familles de méthodes

Ce chapitre présente trois familles classiques.

- L'analyse discriminante construit une règle de classification à partir de la
  séparation entre groupes.
- Les arbres de classification et de régression découpent l'espace des variables
  explicatives en régions simples.
- Les méthodes ensemblistes combinent plusieurs modèles afin de stabiliser ou
  d'améliorer les prédictions.

Ces méthodes illustrent trois manières complémentaires de penser
l'apprentissage supervisé: projeter, partitionner et agréger.

== Analyse discriminante

=== Principe

L'analyse discriminante vise à classer des individus dans plusieurs groupes à
partir de variables explicatives continues. Les groupes sont connus dans les
données d'apprentissage, et l'on cherche une règle de classification qui sépare
au mieux ces groupes.

L'idée de Fisher consiste à projeter les observations sur un score linéaire:

$ f(x) = a^T x + b $

Le vecteur $a$ est choisi pour rendre les groupes aussi séparés que possible sur
l'axe projeté, tout en gardant chaque groupe compact.

=== Critère de Fisher

On décompose la variabilité totale en deux parties:

- la variabilité intra-groupe, qui mesure la dispersion des observations autour
  de leur moyenne de groupe;
- la variabilité inter-groupe, qui mesure la dispersion des moyennes de groupe
  autour de la moyenne globale.

Le critère de Fisher maximise un rapport du type:

$ J(a) = (a^T B a) / (a^T W a) $

où $B$ représente la variabilité inter-groupe et $W$ la variabilité intra-groupe.
On cherche donc un axe où les groupes sont éloignés entre eux et resserrés à
l'intérieur.

Dans le cas de deux groupes, cette idée produit un seul axe discriminant. Avec
plus de deux groupes, plusieurs axes peuvent être nécessaires. Le nombre maximal
d'axes discriminants est limité par le nombre de classes moins un et par le
nombre de variables explicatives.

=== Analyse discriminante linéaire

L'analyse discriminante linéaire, ou LDA, suppose que les classes peuvent être
décrites par des distributions normales ayant des matrices de covariance
communes. Sous ces hypothèses, les frontières de décision sont linéaires.

La LDA estime les moyennes de classe, une covariance commune et les probabilités
initiales des classes. Une nouvelle observation est affectée à la classe dont le
score discriminant est le plus élevé.

=== Règle de classification

Une fois l'axe discriminant estimé, chaque observation reçoit un score. Pour
classer une nouvelle observation, on calcule son score puis on l'affecte au
groupe dont le score moyen est le plus proche.

#example[
  Dans une classification binaire, si le groupe 1 a un score moyen supérieur au
  groupe 2, une règle simple consiste à classer une nouvelle observation dans le
  groupe 1 lorsque son score dépasse le milieu des deux scores moyens.
]

Lorsque les probabilités initiales des classes sont différentes, la règle peut
être déplacée vers la classe la plus fréquente. Lorsque les coûts d'erreur sont
asymétriques, on peut aussi ajuster le seuil de décision pour privilégier une
classe.

=== Extensions et limites

L'analyse discriminante quadratique, ou QDA, autorise une matrice de covariance
différente pour chaque classe. Les frontières peuvent alors être courbes, mais
l'estimation demande plus de données.

L'analyse discriminante est interprétable et efficace lorsque la séparation est
essentiellement linéaire et que les classes sont suffisamment bien représentées.
Elle devient moins adaptée si les frontières sont très non linéaires, si les
variables sont très corrélées, si les matrices de covariance sont mal estimées ou
si le nombre de variables est grand devant le nombre d'observations.

#note[
  Avant d'utiliser une analyse discriminante, il faut examiner la standardisation
  des variables, l'équilibre des classes et les observations atypiques. Ces
  éléments peuvent déplacer fortement la règle de classification.
]

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
