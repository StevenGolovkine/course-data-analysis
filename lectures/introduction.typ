#import "../styles/notes.typ": note, example

= Introduction

== Qu'est-ce que l'analyse de données ?

L'analyse de données regroupe les méthodes qui permettent d'extraire de
l'information d'un jeu de données. Elle est proche de ce que l'on appelle aussi
l'apprentissage statistique: on observe des variables, on cherche des structures
dans ces observations, puis on produit une interprétation, une visualisation,
une prédiction ou une décision.

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

== Exemple directeur

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

== Objectifs du cours

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

Le cours n'a pas vocation à être exhaustif. Il ne couvre pas toutes les méthodes
possibles et ne vise pas les derniers développements de l'apprentissage machine.
Il insiste plutôt sur les idées structurantes: comment représenter les données,
comment mesurer la proximité, comment valider un résultat et comment garder un
regard critique.

== Deux familles de problèmes

On distingue souvent les problèmes supervisés et non supervisés.

Dans un problème *supervisé*, une variable réponse est observée dans les données
d'apprentissage. On veut apprendre une relation entre des variables explicatives
et cette réponse. Si la réponse est quantitative, on parle de régression; si la
réponse est qualitative, on parle de classification.

Dans un problème *non supervisé*, il n'y a pas de variable réponse. On cherche
plutôt à découvrir une structure dans les observations: axes de variation,
groupes, proximités entre modalités ou représentations de plus faible dimension.

#example[
  Prédire si un courriel est indésirable à partir de son contenu est un problème
  supervisé: les exemples d'entraînement portent une étiquette. Regrouper des
  clients selon leurs comportements d'achat est un problème non supervisé:
  l'objectif est de découvrir des segments pertinents.
]

== Ce qu'il faut préciser avant de modéliser

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

== Une posture critique

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

== Questions rapides

1. Donnez un exemple de question descriptive, prédictive et exploratoire à partir
   d'un même jeu de données.
2. Pour un jeu de données de votre choix, identifiez l'unité statistique et trois
   variables importantes.
3. Expliquez pourquoi une corrélation observée dans des données ne suffit pas à
   conclure à une relation causale.
