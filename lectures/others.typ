#import "../styles/notes.typ": note, example

= Autres méthodes

== Révisions

Les méthodes du cours reposent sur quelques outils d'algèbre linéaire, de
probabilités, de statistiques et de programmation. Cette section rassemble les
idées à garder actives pendant la lecture des chapitres précédents.

Ces révisions ne sont pas séparées des méthodes. Elles expliquent pourquoi les
algorithmes fonctionnent, ce qu'ils optimisent et dans quelles conditions leurs
résultats sont interprétables.

=== Algèbre linéaire

Les données multivariées sont souvent représentées par une matrice: les lignes
sont les observations et les colonnes sont les variables. Les transformations
linéaires, les produits matriciels, les distances et les projections deviennent
alors le langage naturel de nombreuses méthodes.

À retenir:

- une matrice symétrique possède des valeurs propres réelles;
- une matrice définie positive possède des valeurs propres strictement positives;
- une matrice orthogonale représente une rotation ou une réflexion et conserve
  les distances euclidiennes;
- la trace d'une matrice carrée est la somme de ses éléments diagonaux;
- la trace est aussi la somme des valeurs propres;
- le déterminant est le produit des valeurs propres.

Ces résultats expliquent pourquoi l'ACP diagonalise une matrice de covariance et
pourquoi les valeurs propres mesurent des parts de variance.

=== Valeurs propres et projection

Une valeur propre $λ$ et un vecteur propre $u$ d'une matrice $A$ vérifient:

$ A u = λ u $

La matrice agit sur $u$ comme une simple mise à l'échelle. Dans une méthode de
réduction de dimension, les vecteurs propres donnent souvent les axes de
projection et les valeurs propres donnent l'importance de ces axes.

#note[
  L'idée "trouver une direction qui maximise une quantité sous contrainte" mène
  très souvent à un problème aux valeurs propres. C'est le cas de l'ACP, de
  l'analyse discriminante et de plusieurs méthodes factorielles.
]

=== Distances et géométrie

Une distance encode une idée de similarité. Changer la distance peut changer
complètement les voisins, les groupes, les projections ou les arbres obtenus.
Pour des variables numériques standardisées, la distance euclidienne est souvent
un point de départ. Pour des données binaires, textuelles ou mixtes, elle peut
être inadaptée.

La géométrie choisie doit correspondre à la question. Deux clients peuvent être
proches par leurs montants d'achat, par leurs fréquences d'achat, par leurs
catégories préférées ou par une combinaison pondérée de ces éléments. Il n'y a
pas de distance neutre.

=== Probabilités et statistiques

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

=== Estimation empirique

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

=== Programmation reproductible

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

=== Synthèse méthodologique

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

== Aspects éthiques

Les données ne sont pas neutres. Elles reflètent un contexte social,
institutionnel et technique. Une analyse peut améliorer une décision, mais elle
peut aussi reproduire des inégalités, amplifier un biais historique ou porter
atteinte à la vie privée.

Une vigilance éthique est nécessaire dès la formulation de la question:

- qui est représenté dans les données ?
- qui ne l'est pas ?
- quelle décision sera prise à partir du modèle ?
- quelles erreurs sont les plus coûteuses ?
- quelles personnes peuvent être affectées par ces erreurs ?

=== Finalité et proportionnalité

Une analyse doit avoir une finalité claire. Collecter ou utiliser des données
parce qu'elles sont disponibles ne suffit pas. Il faut relier les données à une
question légitime, puis vérifier que le niveau de détail collecté est
proportionné à cette question.

La proportionnalité concerne aussi les modèles. Un modèle très intrusif ou très
opaque peut être difficile à justifier si une règle plus simple produit une
décision comparable avec moins de risques.

=== Confidentialité

L'anonymisation ne consiste pas seulement à retirer les noms. Des identifiants
indirects, comme une date de naissance, un code postal ou une combinaison rare de
caractéristiques, peuvent permettre une ré-identification.

Pour réduire les risques, on peut:

- supprimer ou transformer les identifiants directs;
- réduire la granularité, par exemple regrouper les âges;
- regrouper les modalités rares;
- limiter les variables diffusées;
- ajouter du bruit à certains résultats;
- utiliser des méthodes de confidentialité différentielle lorsque le contexte le
  justifie.

Le niveau de protection doit être adapté aux risques et à l'utilité attendue de
l'analyse.

=== Biais et implications sociales

Un modèle peut être biaisé pour plusieurs raisons:

- l'échantillon ne représente pas la population cible;
- la variable réponse contient des décisions historiques biaisées;
- certaines classes sont trop peu représentées;
- la performance varie fortement selon les groupes;
- des variables apparemment neutres servent de proxys à des variables sensibles.

#example[
  Retirer la variable "genre" d'un modèle ne garantit pas l'absence de biais. Le
  modèle peut l'inférer indirectement à partir d'autres variables corrélées,
  comme certains parcours scolaires, emplois ou habitudes de consommation.
]

=== Équité et performance

L'équité ne se réduit pas à une seule métrique. On peut comparer les taux
d'erreur, les faux positifs, les faux négatifs, la calibration ou l'accès à une
décision favorable selon les groupes. Ces critères peuvent entrer en tension:
améliorer l'un peut dégrader l'autre.

Il faut donc expliciter le choix retenu et le relier au contexte. Dans un modèle
de dépistage, un faux négatif peut être plus grave qu'un faux positif. Dans un
modèle d'accès à un service, refuser à tort une personne peut avoir des
conséquences sociales importantes.

=== Réduire les biais

Les interventions peuvent se faire à plusieurs moments.

- En amont: améliorer la collecte, rééquilibrer l'échantillon, documenter les
  limites et corriger les erreurs connues.
- Pendant l'apprentissage: modifier la fonction de perte ou imposer des
  contraintes de performance selon les groupes.
- En aval: recalibrer les probabilités, ajuster les seuils ou surveiller les
  performances après déploiement.

Aucune correction automatique ne remplace la compréhension du contexte et la
discussion des conséquences.

=== Transparence et responsabilité

Un résultat d'analyse doit être accompagné de ses conditions de validité: quelles
données ont été utilisées, quelles hypothèses ont été faites, quelles variables
ont été exclues, quelles erreurs restent probables et quelle décision sera prise
à partir du résultat.

La responsabilité ne disparaît pas parce qu'une méthode est automatique. Les
personnes qui conçoivent, déploient ou utilisent un modèle doivent pouvoir
expliquer son objectif, ses limites et les recours possibles pour les personnes
affectées.

#note[
  L'analyse de données est à la fois une science et une pratique. Elle demande
  des méthodes, mais aussi du jugement, de la documentation et une attention aux
  effets concrets des décisions prises à partir des résultats.
]

#heading(level: 2, outlined: false)[Exercices]

1. Expliquez pourquoi les valeurs propres interviennent dans l'ACP.
2. Donnez un exemple où une corrélation nulle ne signifie pas indépendance.
3. Citez deux risques de ré-identification dans un jeu de données anonymisé.
4. Formulez une question éthique à poser avant de déployer un modèle prédictif.
5. Pourquoi le choix d'une distance est-il déjà un choix méthodologique ?
6. Donnez un exemple de compromis possible entre performance globale et équité.
