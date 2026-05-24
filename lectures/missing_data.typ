#import "../styles/notes.typ": note, example

= Données manquantes

== Pourquoi en parler ?

Les modules du cours rappellent que la préparation des données occupe souvent la
plus grande partie d'un projet. Les données manquantes en sont une cause
majeure: elles peuvent biaiser les estimations, réduire la puissance d'une
analyse, empêcher certains algorithmes de fonctionner et révéler un problème de
collecte.

Une valeur manquante n'est pas seulement une case vide. Elle porte parfois une
information sur le processus qui a produit les données.

#example[
  Dans un questionnaire de santé, l'absence de réponse à une question sensible
  peut être liée à la variable étudiée. La traiter comme un oubli aléatoire peut
  conduire à une conclusion trop optimiste.
]

== Identifier le codage du manque

La première étape est un audit. Dans un même fichier, le manque peut être codé
par une chaîne vide, `NA`, `N/A`, `NULL`, `?`, `NaN`, `-999`, `Inconnu` ou une
modalité métier particulière. Ces valeurs doivent être uniformisées avant les
résumés statistiques.

Il faut aussi distinguer:

- les données vraiment absentes;
- les zéros réels;
- les valeurs non applicables;
- les valeurs censurées ou tronquées;
- les refus de réponse;
- les erreurs de saisie transformées en manque.

#note[
  Une valeur non applicable ne doit pas toujours être imputée. Si une variable
  "date de fin" est vide parce qu'un contrat est encore actif, l'absence est
  structurée et doit être représentée explicitement.
]

== Décrire les profils de manque

Avant de corriger, on mesure.

- Combien de valeurs manquent par variable ?
- Combien de variables manquent par observation ?
- Le manque est-il concentré dans certaines lignes, dates, sources ou groupes ?
- Deux variables sont-elles manquantes simultanément ?
- Le manque est-il lié à la variable réponse ?

Ces diagnostics orientent la stratégie. Une variable manquante à 2 pour cent ne
demande pas la même réponse qu'une variable manquante à 60 pour cent.

== Trois mécanismes classiques

On distingue souvent trois mécanismes.

- MCAR: le manque est complètement aléatoire. La probabilité de manquer ne
  dépend ni des valeurs observées ni des valeurs manquantes.
- MAR: le manque dépend de variables observées. Par exemple, un revenu manquant
  peut être plus fréquent dans une tranche d'âge observée.
- MNAR: le manque dépend de la valeur manquante elle-même. Par exemple, les
  revenus très élevés peuvent être moins souvent déclarés.

Ces mécanismes ne sont pas toujours identifiables à partir des données seules.
Ils sont des hypothèses de travail à discuter avec le contexte de collecte.

== Suppression de lignes ou de variables

La stratégie la plus simple consiste à supprimer les observations incomplètes.
Elle est acceptable si le manque est rare et plausiblement aléatoire. Elle peut
toutefois réduire fortement l'échantillon et biaiser l'analyse si les
observations supprimées ont un profil particulier.

Supprimer une variable peut être raisonnable lorsqu'elle est presque toujours
manquante, mal définie ou impossible à utiliser au moment de la prédiction.
Cette décision doit être documentée.

== Imputation simple

L'imputation remplace les valeurs manquantes par des valeurs plausibles.

- Pour une variable numérique, on peut utiliser la moyenne, la médiane ou une
  valeur conditionnelle par groupe.
- Pour une variable qualitative, on peut utiliser la modalité majoritaire ou une
  modalité explicite "manquant".
- Pour des séries temporelles, on peut parfois utiliser une interpolation ou une
  dernière valeur observée, si cela a un sens métier.

L'imputation simple est facile à mettre en oeuvre, mais elle sous-estime souvent
l'incertitude et peut réduire artificiellement la variabilité.

== Indicateurs de manque

Dans certains problèmes prédictifs, le fait qu'une valeur soit manquante est
lui-même informatif. On peut alors ajouter une variable binaire indiquant si la
valeur initiale était absente, puis imputer la valeur nécessaire au modèle.

#example[
  Pour une demande de crédit, l'absence d'une information peut refléter un
  parcours administratif particulier. Un indicateur de manque permet au modèle
  d'utiliser ce signal sans confondre absence et valeur numérique.
]

Cette approche doit être utilisée avec prudence: si le manque est lié à des
groupes sensibles ou à des différences d'accès au système de collecte, le modèle
peut reproduire un biais.

== Imputation par modèle

On peut prédire les valeurs manquantes à partir des autres variables: régression,
arbre, plus proches voisins, modèles probabilistes ou imputation multiple.

L'imputation multiple produit plusieurs jeux de données imputés, analyse chacun
d'eux, puis combine les résultats. Elle permet de refléter une partie de
l'incertitude sur les valeurs manquantes.

Pour une tâche prédictive, l'imputation doit être intégrée au protocole de
validation. Les paramètres d'imputation sont appris sur l'ensemble
d'entraînement, puis appliqués à l'ensemble de validation.

== Fuites de données

Une erreur fréquente consiste à imputer avant de séparer les données en
entraînement et validation. Cela fait entrer de l'information du jeu de
validation dans le prétraitement, ce qui rend l'évaluation trop optimiste.

La règle pratique est simple: toute transformation apprise à partir des données
doit être ajustée sur l'entraînement seulement.

== Algorithmes et valeurs manquantes

Certains algorithmes exigent un tableau complet. D'autres gèrent partiellement
les valeurs manquantes, par exemple à l'aide de divisions de substitution dans
certains arbres. Même lorsque l'algorithme accepte le manque, il faut comprendre
comment il le traite, car cela influence l'interprétation.

En analyse exploratoire, il est souvent utile de produire des tableaux et des
graphes qui incluent explicitement les valeurs manquantes plutôt que de les
masquer.

== Rapport d'analyse

Une analyse rigoureuse indique:

- le taux de manque par variable;
- le codage initial des valeurs manquantes;
- les hypothèses faites sur le mécanisme de manque;
- les observations ou variables supprimées;
- la méthode d'imputation utilisée;
- l'impact possible sur les conclusions.

#note[
  Les données manquantes ne sont pas un détail technique. Elles font partie du
  phénomène mesuré et peuvent changer la portée d'un résultat.
]

== Exercices

1. Donnez trois codages possibles d'une valeur manquante dans un fichier CSV.
2. Expliquez la différence entre une valeur manquante et une valeur non
   applicable.
3. Pourquoi faut-il imputer après la séparation entraînement-validation ?
4. Proposez une stratégie pour une variable numérique manquante à 15 pour cent.
