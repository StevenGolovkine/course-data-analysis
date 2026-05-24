#import "../styles/notes.typ": note, example

= Apprentissage supervisé

== Principe général

En apprentissage supervisé, les données d'entraînement contiennent une variable
réponse. L'objectif est d'apprendre une règle qui associe les variables
explicatives à cette réponse, puis de généraliser cette règle à de nouvelles
observations.

Lorsque la réponse est numérique, on parle de régression. Lorsque la réponse est
une classe, on parle de classification. Ce chapitre met surtout l'accent sur la
classification.

#note[
  Une méthode supervisée doit toujours être évaluée sur des observations qui
  n'ont pas servi à l'ajustement. Sinon, on mesure surtout la capacité du modèle
  à mémoriser les données d'entraînement.
]

== Analyse discriminante

L'analyse discriminante vise à classer des individus dans plusieurs groupes à
partir de variables explicatives continues. Les groupes sont connus dans les
données d'apprentissage, et l'on cherche une règle de classification qui sépare
au mieux ces groupes.

L'idée de Fisher consiste à projeter les observations sur un score linéaire:

$ f(x) = a^T x + b $

Le vecteur $a$ est choisi pour rendre les groupes aussi séparés que possible sur
l'axe projeté, tout en gardant chaque groupe compact.

== Critère de Fisher

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

== Règle de classification

Une fois l'axe discriminant estimé, chaque observation reçoit un score. Pour
classer une nouvelle observation, on calcule son score puis on l'affecte au
groupe dont le score moyen est le plus proche.

#example[
  Dans une classification binaire, si le groupe 1 a un score moyen supérieur au
  groupe 2, une règle simple consiste à classer une nouvelle observation dans le
  groupe 1 lorsque son score dépasse le milieu des deux scores moyens.
]

L'analyse discriminante est interprétable et efficace lorsque la séparation est
essentiellement linéaire. Elle devient moins adaptée si les frontières entre
classes sont très non linéaires ou si les matrices de covariance sont mal
estimées.

== Arbres de classification et de régression

Les arbres CART partitionnent l'espace des variables explicatives en régions
simples. À chaque noeud, l'algorithme choisit une variable et un seuil qui
séparent les observations en deux sous-ensembles plus homogènes.

Pour une tâche de classification, chaque feuille prédit la classe majoritaire.
Pour une tâche de régression, chaque feuille prédit souvent la moyenne de la
réponse dans la feuille.

== Algorithme CART

La construction d'un arbre suit une stratégie gloutonne.

1. Pour chaque variable et chaque seuil possible, calculer le gain
   d'homogénéité.
2. Choisir la coupure qui améliore le plus le critère.
3. Séparer le noeud en deux sous-noeuds.
4. Répéter jusqu'à atteindre un critère d'arrêt.

Cette approche est efficace, mais elle ne garantit pas l'arbre globalement
optimal. Elle choisit à chaque étape la meilleure coupure locale.

== Critères d'homogénéité

Pour la classification, on utilise souvent:

- le taux d'erreur de classification, simple mais peu sensible pour construire
  l'arbre;
- l'indice de Gini, faible lorsque les feuilles sont pures;
- l'entropie croisée, issue de la théorie de l'information.

Le gain d'une coupure compare l'impureté du noeud avant la coupure à la moyenne
pondérée des impuretés après la coupure. La meilleure coupure est celle qui
réduit le plus l'impureté.

== Complexité et élagage

Un arbre trop profond surajuste les données: il crée des feuilles très
spécifiques et généralise mal. Un arbre trop petit sous-ajuste: il ne capture
pas assez de structure.

L'élagage consiste à faire croître un arbre puis à retirer les branches qui
apportent peu d'amélioration. On peut utiliser un critère coût-complexité:

$ L(T) = C(T) + alpha |T| $

où $|T|$ est le nombre de feuilles et $alpha$ pénalise la complexité. Le choix de
$alpha$ se fait souvent par validation croisée.

== Forces et limites des arbres

Les arbres sont faciles à interpréter, gèrent naturellement les interactions,
acceptent des variables de types variés et sont peu sensibles aux transformations
monotones des variables.

Ils sont aussi instables: une petite modification des données peut produire un
arbre très différent. Utilisés seuls, ils peuvent être moins performants que des
méthodes agrégées, surtout lorsque les données sont bruitées.

== Méthodes ensemblistes

Les méthodes ensemblistes combinent plusieurs modèles simples pour produire une
prédiction plus robuste. Elles améliorent souvent la performance au prix d'une
interprétation moins directe.

Trois grandes familles apparaissent dans le cours:

- le bagging;
- les forêts aléatoires;
- le boosting.

== Bagging

Le bagging, ou *bootstrap aggregating*, construit plusieurs modèles sur des
échantillons bootstrap des données d'entraînement. Pour la classification, on
combine ensuite les prédictions par vote majoritaire ou par moyenne des
probabilités.

Le bagging réduit la variance et stabilise les prédictions, en particulier pour
des modèles instables comme les arbres.

== Forêts aléatoires

Les forêts aléatoires ajoutent une source d'aléa au bagging. À chaque coupure
d'un arbre, l'algorithme ne considère qu'un sous-ensemble aléatoire de variables.
Cette contrainte décorrèle les arbres et améliore l'agrégation.

Un choix courant consiste à considérer environ $sqrt(p)$ variables candidates à
chaque coupure en classification, où $p$ est le nombre total de variables.

== Boosting

Le boosting construit les modèles de manière séquentielle. Chaque nouveau modèle
se concentre davantage sur les erreurs des modèles précédents. L'objectif est de
combiner plusieurs classificateurs faibles pour obtenir un modèle global très
performant.

AdaBoost ajuste des poids sur les observations. Le gradient boosting formule
l'apprentissage comme une minimisation itérative d'une fonction de perte.

Le boosting peut être très précis, mais il demande un réglage soigné du nombre
d'itérations, de la profondeur des arbres, du taux d'apprentissage et parfois du
sous-échantillonnage.

== Hyper-paramètres

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

== Exercices

1. Expliquez le rapport entre variabilité inter-groupe et intra-groupe dans
   l'analyse discriminante.
2. Pourquoi un arbre non élagué risque-t-il de surajuster ?
3. Comparez bagging et boosting en une phrase.
4. Proposez un protocole de validation pour choisir la profondeur maximale d'un
   arbre.
