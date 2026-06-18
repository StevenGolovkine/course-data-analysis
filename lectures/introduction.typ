#import "../styles/notes.typ": note, example

= Introduction

== Qu'est-ce que l'analyse de données ?

L'analyse de données regroupe les méthodes qui permettent d'extraire de
l'information d'un jeu de données. Elle est proche de ce que l'on appelle aussi
l'apprentissage statistique: on observe des variables, on cherche des structures
dans ces observations, puis on produit une interprétation, une visualisation, une
prédiction ou une décision.

Le point de départ n'est donc pas un algorithme, mais une question. Un même
tableau peut servir à décrire une population, à comparer des groupes, à prévoir
une quantité future, à détecter des observations atypiques ou à construire une
typologie. La méthode pertinente dépend de cette question, du type des variables
et de la qualité des données.

#note[
  Une analyse de données est une démarche itérative: formuler une question,
  comprendre les données, choisir une représentation, ajuster ou appliquer une
  méthode, évaluer le résultat, puis revenir aux étapes précédentes si les
  diagnostics l'exigent.
]

=== Exemple directeur

#example[
  On souhaite étudier l'espérance de vie dans les pays membres de l'ONU. Pour
  chaque pays, on dispose de l'espérance de vie, du PIB par habitant, des
  dépenses de santé, du taux de fertilité, du taux d'urbanisation et du niveau
  d'éducation. Une analyse peut chercher à visualiser les relations entre ces
  variables, à comprendre quels facteurs sont associés à l'espérance de vie, ou
  à prédire l'espérance de vie à partir des autres variables.
]

Cet exemple illustre plusieurs difficultés typiques. Les variables n'ont pas la
même échelle, elles ne jouent pas toutes le même rôle, certaines peuvent être
fortement corrélées, et l'interprétation causale demande beaucoup plus qu'un bon
ajustement numérique.

=== Objectifs du cours

Le cours introduit des méthodes utiles pour étudier des données de dimension
modérée ou élevée, c'est-à-dire des données que l'on ne peut pas comprendre avec
un simple graphique à deux ou trois axes. Les méthodes étudiées serviront
principalement à:

- visualiser des jeux de données multivariés;
- réduire la dimension tout en conservant l'information importante;
- identifier des liens entre variables ou entre modalités;
- construire des groupes d'observations similaires;
- prédire une classe ou une réponse à partir de variables explicatives;
- évaluer la qualité d'un modèle et ses limites.

Le cours n'a pas vocation à être exhaustif. Il insiste plutôt sur les idées
structurantes: comment représenter les données, comment mesurer la proximité,
comment valider un résultat et comment garder un regard critique.

=== Questions descriptives, prédictives et exploratoires

Une analyse peut viser plusieurs types de résultats.

- Une question descriptive cherche à résumer ce qui est observé.
- Une question prédictive cherche à estimer une réponse pour de nouvelles
  observations.
- Une question exploratoire cherche à découvrir une structure, une relation ou
  une typologie.

Ces objectifs peuvent coexister, mais il faut savoir lequel guide la méthode.
Décrire une association, prédire une valeur et expliquer un mécanisme causal ne
demandent pas les mêmes hypothèses.

== L'apprentissage supervisé

=== Principe

Dans un problème supervisé, une variable réponse est observée dans les données
d'apprentissage. On veut apprendre une relation entre des variables explicatives
et cette réponse. Si la réponse est quantitative, on parle de régression; si la
réponse est qualitative, on parle de classification.

On peut écrire l'objectif de manière générale:

$ Y = f(X) + epsilon $

La fonction $f$ représente la relation systématique entre les variables
explicatives $X$ et la réponse $Y$. Le terme $epsilon$ représente le bruit, les
variables absentes et la variabilité qui n'est pas expliquée par le modèle.

=== Régression et classification

En régression, la réponse est numérique: prix, température, durée, revenu ou
score. La qualité du modèle se mesure souvent par une erreur de prédiction, comme
l'erreur quadratique moyenne ou l'erreur absolue moyenne.

En classification, la réponse est une classe: fraude ou non, réussite ou échec,
type de document, diagnostic ou catégorie de risque. La qualité du modèle dépend
de la proportion d'erreurs, mais aussi du type d'erreur commise.

#example[
  Prédire si un courriel est indésirable à partir de son contenu est un problème
  supervisé: les exemples d'entraînement portent une étiquette. Prédire le prix
  d'un logement à partir de ses caractéristiques est aussi supervisé, mais la
  réponse est quantitative.
]

=== Généraliser

Un modèle supervisé n'est pas jugé sur sa capacité à mémoriser les données
d'apprentissage. Il doit généraliser à de nouvelles observations. C'est pourquoi
on sépare les données en ensembles d'entraînement, de validation et de test, ou
on utilise la validation croisée.

Le risque principal est le sur-ajustement: un modèle trop flexible peut apprendre
les particularités de l'échantillon au lieu d'apprendre une relation stable.

== L'apprentissage non-supervisé

=== Principe

Dans un problème non supervisé, il n'y a pas de variable réponse. On cherche
plutôt à découvrir une structure dans les observations: axes de variation,
groupes, proximités entre modalités ou représentations de plus faible dimension.

Les méthodes non supervisées servent souvent à explorer les données avant une
modélisation plus ciblée. Elles peuvent révéler des groupes, des observations
atypiques, des variables redondantes ou des relations inattendues.

=== Réduction de dimension

La réduction de dimension remplace un grand nombre de variables par quelques
axes ou représentations synthétiques. L'objectif est de visualiser, résumer ou
préparer les données pour une autre méthode.

L'ACP, l'AFC et l'ACM sont des exemples de méthodes factorielles. Elles ne
répondent pas à une question prédictive directe; elles aident plutôt à comprendre
la structure des données.

=== Regroupement

Le regroupement, ou *clustering*, cherche à construire des groupes
d'observations similaires. Les k-means, la classification hiérarchique et les
mélanges de gaussiennes illustrent différentes manières de définir un groupe:
proximité à un centre, hiérarchie de distances ou appartenance probabiliste.

#example[
  Regrouper des clients selon leurs comportements d'achat est un problème non
  supervisé: l'objectif est de découvrir des segments pertinents, pas de prédire
  une étiquette connue à l'avance.
]

=== Interpréter sans réponse observée

L'absence de variable réponse rend l'évaluation plus délicate. On peut mesurer la
compacité des groupes, la part d'inertie expliquée ou la stabilité d'une
projection, mais ces critères ne remplacent pas l'interprétation.

Une méthode non supervisée produit une représentation. Cette représentation doit
être reliée à la question initiale, aux variables observées et au contexte de
collecte.

== La modélisation

=== Ce qu'il faut préciser

Avant toute méthode, on doit expliciter plusieurs choix.

- Quelle est l'unité statistique: individu, pays, transaction, image, texte,
  pixel, événement ?
- Quelles variables décrivent chaque unité ?
- Les variables sont-elles numériques, ordinales, nominales ou binaires ?
- L'espace de représentation est-il pertinent pour le problème ?
- Quelle distance ou similarité entre deux observations a du sens ?
- Quelle mesure d'erreur permettra d'évaluer le résultat ?
- Les données sont-elles représentatives de la population visée ?

Ces questions peuvent sembler préliminaires, mais elles déterminent souvent la
qualité de l'analyse davantage que le choix final de l'algorithme.

=== Représentation, méthode et validation

Modéliser consiste à relier trois éléments: une représentation des données, une
méthode et un critère d'évaluation. Changer l'un de ces éléments peut changer le
résultat.

Par exemple, une standardisation peut modifier une distance, une distance peut
modifier un regroupement, et une mesure d'erreur peut favoriser un modèle plutôt
qu'un autre. Un bon protocole documente donc les choix de représentation et pas
seulement le nom de l'algorithme.

=== Interprétation et limites

L'analyse de données ne consiste pas à appliquer mécaniquement une recette. Les
données reflètent un contexte de collecte, des choix de mesure, des omissions et
des biais possibles. Un résultat convaincant doit donc être accompagné de ses
conditions de validité: quelles hypothèses ont été faites, quelles données ont
été exclues, quelle incertitude demeure, et quelle décision sera prise à partir
du résultat.

#note[
  Il n'existe pas de méthode universellement meilleure. Une méthode excellente
  sur un problème peut être mauvaise sur un autre. La compétence centrale est de
  relier la question, les données, la méthode et l'interprétation.
]

#heading(level: 2, outlined: false)[Questions rapides]

1. Donnez un exemple de question descriptive, prédictive et exploratoire à partir
   d'un même jeu de données.
2. Pour un jeu de données de votre choix, identifiez l'unité statistique et trois
   variables importantes.
3. Expliquez pourquoi une corrélation observée dans des données ne suffit pas à
   conclure à une relation causale.
4. Pourquoi l'apprentissage non supervisé est-il plus difficile à évaluer qu'une
   classification supervisée ?
5. Donnez un exemple de choix de représentation qui peut changer le résultat
   d'une analyse.
