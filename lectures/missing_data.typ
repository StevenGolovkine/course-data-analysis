#import "../styles/notes.typ": note, example

= Données manquantes

== Introduction

Les modules du cours rappellent que la préparation des données occupe souvent la
plus grande partie d'un projet. Les données manquantes en sont une cause
majeure: elles peuvent biaiser les estimations, réduire la puissance d'une
analyse, empêcher certains algorithmes de fonctionner et révéler un problème de
collecte.

Une valeur manquante n'est pas seulement une case vide. Elle porte parfois une
information sur le processus qui a produit les données. Avant de choisir une
méthode, il faut donc comprendre ce qui manque, où cela manque et pourquoi cela
manque.

#example[
  Dans un questionnaire de santé, l'absence de réponse à une question sensible
  peut être liée à la variable étudiée. La traiter comme un oubli aléatoire peut
  conduire à une conclusion trop optimiste.
]

=== Identifier le codage du manque

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

=== Mesurer le manque

Avant de corriger, on mesure.

- Combien de valeurs manquent par variable ?
- Combien de variables manquent par observation ?
- Le manque est-il concentré dans certaines lignes, dates, sources ou groupes ?
- Deux variables sont-elles manquantes simultanément ?
- Le manque est-il lié à la variable réponse ?

Ces diagnostics orientent la stratégie. Une variable manquante à 2 pour cent ne
demande pas la même réponse qu'une variable manquante à 60 pour cent. Une
observation avec une seule valeur absente ne pose pas le même problème qu'une
observation presque vide.

=== Visualiser les profils

Les profils de manque peuvent être représentés par des tableaux de taux, des
cartes de chaleur, des matrices d'indicateurs ou des graphiques par groupe. Ces
outils permettent de voir si le manque est diffus, concentré dans certaines
variables ou organisé par blocs.

En analyse exploratoire, il est souvent utile de produire des tableaux et des
graphes qui incluent explicitement les valeurs manquantes plutôt que de les
masquer. Le manque fait partie des données observées, même si la valeur
substantielle n'est pas disponible.

== Les mécanismes

=== Trois mécanismes classiques

On distingue souvent trois mécanismes.

- MCAR: le manque est complètement aléatoire. La probabilité de manquer ne
  dépend ni des valeurs observées ni des valeurs manquantes.
- MAR: le manque dépend de variables observées. Par exemple, un revenu manquant
  peut être plus fréquent dans une tranche d'âge observée.
- MNAR: le manque dépend de la valeur manquante elle-même. Par exemple, les
  revenus très élevés peuvent être moins souvent déclarés.

Ces mécanismes ne sont pas toujours identifiables à partir des données seules.
Ils sont des hypothèses de travail à discuter avec le contexte de collecte.

=== MCAR

Le mécanisme MCAR est le plus favorable. Si les valeurs manquantes sont vraiment
complètement aléatoires, les observations incomplètes ressemblent aux
observations complètes. Supprimer quelques lignes peut alors réduire la taille de
l'échantillon sans introduire de biais important.

Cette hypothèse est forte. En pratique, elle peut être plausible lorsqu'une
erreur technique touche des observations au hasard, par exemple une panne
temporaire d'un capteur sans lien avec le phénomène mesuré.

=== MAR

Le mécanisme MAR signifie que le manque peut être expliqué par des variables
observées. Par exemple, la probabilité qu'un revenu soit manquant peut dépendre
de l'âge, du type d'emploi ou de la région, si ces variables sont connues.

Dans ce cas, les méthodes d'imputation peuvent utiliser les variables observées
pour réduire le biais. L'hypothèse MAR ne dit pas que le manque est anodin: elle
dit que les informations nécessaires pour modéliser le manque sont présentes
dans les données observées.

=== MNAR

Le mécanisme MNAR est le plus délicat. Le manque dépend de la valeur absente
elle-même ou d'une variable non observée. Par exemple, les personnes ayant un
revenu très élevé peuvent refuser de le déclarer précisément parce que ce revenu
est élevé.

Dans ce cas, aucune méthode automatique ne peut résoudre entièrement le problème
sans hypothèses supplémentaires. Il faut s'appuyer sur le contexte, comparer des
scénarios et documenter la sensibilité des conclusions.

#note[
  MCAR, MAR et MNAR ne sont pas des propriétés que l'on lit directement dans un
  tableau. Ce sont des modèles du processus de collecte. Les données aident à les
  discuter, mais le contexte est indispensable.
]

=== Conséquences analytiques

Le mécanisme de manque influence les conclusions.

- Sous MCAR, la suppression de lignes peut surtout réduire la précision.
- Sous MAR, une imputation conditionnelle peut corriger une partie du biais.
- Sous MNAR, les résultats peuvent dépendre fortement d'hypothèses non
  vérifiables.

Il est donc utile de comparer plusieurs stratégies: analyse sur cas complets,
imputation simple, imputation par modèle et analyse de sensibilité lorsque le
manque est potentiellement informatif.

== Les méthodes

=== Suppression de lignes ou de variables

La stratégie la plus simple consiste à supprimer les observations incomplètes.
Elle est acceptable si le manque est rare et plausiblement aléatoire. Elle peut
toutefois réduire fortement l'échantillon et biaiser l'analyse si les
observations supprimées ont un profil particulier.

Supprimer une variable peut être raisonnable lorsqu'elle est presque toujours
manquante, mal définie ou impossible à utiliser au moment de la prédiction.
Cette décision doit être documentée, avec le taux de manque et la justification.

=== Imputation simple

L'imputation remplace les valeurs manquantes par des valeurs plausibles.

- Pour une variable numérique, on peut utiliser la moyenne, la médiane ou une
  valeur conditionnelle par groupe.
- Pour une variable qualitative, on peut utiliser la modalité majoritaire ou une
  modalité explicite "manquant".
- Pour des séries temporelles, on peut parfois utiliser une interpolation ou une
  dernière valeur observée, si cela a un sens métier.

L'imputation simple est facile à mettre en oeuvre, mais elle sous-estime souvent
l'incertitude et peut réduire artificiellement la variabilité. Elle est surtout
utile comme solution de base, comme étape de prétraitement ou lorsque le manque
est rare.

=== Indicateurs de manque

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

=== Imputation par modèle

On peut prédire les valeurs manquantes à partir des autres variables: régression,
arbre, plus proches voisins, modèles probabilistes ou chaînes d'imputations
conditionnelles. L'idée est d'utiliser les relations observées entre variables
pour produire des valeurs plus cohérentes qu'une moyenne globale.

Les plus proches voisins imputent une valeur à partir d'observations semblables.
Les arbres peuvent capturer des interactions et des effets non linéaires. Les
modèles de régression sont plus simples à interpréter, mais demandent des
hypothèses plus explicites.

=== Imputation multiple

L'imputation multiple produit plusieurs jeux de données imputés, analyse chacun
d'eux, puis combine les résultats. Elle permet de refléter une partie de
l'incertitude sur les valeurs manquantes.

Cette approche est particulièrement utile pour l'inférence statistique, lorsque
l'on veut produire des estimations, des intervalles de confiance ou des tests. Au
lieu de prétendre connaître la valeur manquante, on propage plusieurs valeurs
plausibles dans l'analyse.

=== Protocole prédictif et fuites de données

Pour une tâche prédictive, l'imputation doit être intégrée au protocole de
validation. Les paramètres d'imputation sont appris sur l'ensemble
d'entraînement, puis appliqués à l'ensemble de validation.

Une erreur fréquente consiste à imputer avant de séparer les données en
entraînement et validation. Cela fait entrer de l'information du jeu de
validation dans le prétraitement, ce qui rend l'évaluation trop optimiste.

La règle pratique est simple: toute transformation apprise à partir des données
doit être ajustée sur l'entraînement seulement.

=== Algorithmes et valeurs manquantes

Certains algorithmes exigent un tableau complet. D'autres gèrent partiellement
les valeurs manquantes, par exemple à l'aide de divisions de substitution dans
certains arbres ou par une direction par défaut dans certains algorithmes de
boosting.

Même lorsque l'algorithme accepte le manque, il faut comprendre comment il le
traite, car cela influence l'interprétation. Une méthode qui exploite le manque
comme signal peut être performante, mais elle peut aussi apprendre des biais de
collecte.

=== Rapport d'analyse

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

#heading(level: 2, outlined: false)[Exercices]

1. Donnez trois codages possibles d'une valeur manquante dans un fichier CSV.
2. Expliquez la différence entre une valeur manquante et une valeur non
   applicable.
3. Pourquoi faut-il imputer après la séparation entraînement-validation ?
4. Proposez une stratégie pour une variable numérique manquante à 15 pour cent.
5. Donnez un exemple de mécanisme MAR et un exemple de mécanisme MNAR.
6. Pourquoi l'imputation multiple est-elle plus informative qu'une imputation
   unique pour une analyse statistique ?
