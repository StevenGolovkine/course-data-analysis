#import "../styles/notes.typ": note, example

= Autres méthodes

== Révisions utiles

Les méthodes du cours reposent sur quelques outils d'algèbre linéaire, de
probabilités et de programmation. Cette section rassemble les idées à garder
actives pendant la lecture des chapitres précédents.

== Algèbre linéaire

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

== Valeurs propres et projection

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

En pratique, les moyennes, variances et covariances sont inconnues. On les estime
à partir d'un échantillon. La moyenne empirique résume la position centrale. La
matrice de covariance empirique alimente directement plusieurs méthodes du
cours, notamment l'ACP.

Il faut garder en tête que ces objets sont eux-mêmes estimés. Si l'échantillon
est petit ou non représentatif, les axes, distances et modèles obtenus peuvent
être instables.

== Programmation

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

== Confidentialité

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

== Biais et implications sociales

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

== Réduire les biais

Les interventions peuvent se faire à plusieurs moments.

- En amont: améliorer la collecte, rééquilibrer l'échantillon, documenter les
  limites et corriger les erreurs connues.
- Pendant l'apprentissage: modifier la fonction de perte ou imposer des
  contraintes de performance selon les groupes.
- En aval: recalibrer les probabilités, ajuster les seuils ou surveiller les
  performances après déploiement.

Aucune correction automatique ne remplace la compréhension du contexte et la
discussion des conséquences.

== Conclusion du cours

Il n'existe pas d'algorithme universellement meilleur. Chaque jeu de données,
chaque objectif et chaque contexte demandent un choix argumenté. Le principe de
*no free lunch* rappelle qu'une méthode performante dans un cadre peut échouer
dans un autre.

Une démarche rigoureuse commence par une exploration descriptive, s'appuie sur
l'expertise du domaine, compare plusieurs approches, valide les résultats et
documente les limites.

== Questions laissées ouvertes

Plusieurs thèmes restent centraux en pratique:

- définir de bonnes variables explicatives, ou *feature engineering*;
- détecter et traiter les valeurs aberrantes;
- gérer les données manquantes;
- construire un protocole entraînement-validation-test;
- mesurer la représentativité des données;
- surveiller un modèle après son déploiement;
- communiquer l'incertitude à des non spécialistes.

#note[
  L'analyse de données est à la fois une science et une pratique. Elle demande
  des méthodes, mais aussi du jugement, de la documentation et une attention aux
  effets concrets des décisions prises à partir des résultats.
]

== Exercices

1. Expliquez pourquoi les valeurs propres interviennent dans l'ACP.
2. Donnez un exemple où une corrélation nulle ne signifie pas indépendance.
3. Citez deux risques de ré-identification dans un jeu de données anonymisé.
4. Formulez une question éthique à poser avant de déployer un modèle prédictif.
