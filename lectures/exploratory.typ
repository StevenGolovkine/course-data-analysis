#import "../styles/notes.typ": note, example

= Analyse exploratoire

== Le projet d'analyse de données

Un projet d'analyse de données suit généralement cinq étapes.

1. Définir les objectifs.
2. Collecter, préparer et documenter les données.
3. Élaborer puis valider les modèles.
4. Mettre la solution en oeuvre.
5. Suivre la performance et améliorer le système.

Ces étapes n'ont pas le même poids. La préparation des données prend souvent la
majeure partie du temps: formats hétérogènes, valeurs manquantes, doublons,
erreurs de saisie, accents, unités incohérentes et modalités rares. À l'inverse,
la partie visible du modèle peut parfois représenter peu de lignes de code, même
si elle porte une décision importante.

#note[
  Un objectif vague comme "analyser les données clients" n'est pas opérationnel.
  Une meilleure formulation précise la décision visée: "peut-on prédire quels
  clients sont susceptibles d'acheter un nouveau produit d'épargne ?"
]

== Définir une bonne question

Une question utile doit préciser la population, l'unité statistique, la variable
ou la décision d'intérêt et le type de résultat attendu. On peut viser:

- une description: résumer la distribution d'une variable;
- une comparaison: caractériser les différences entre groupes;
- une prédiction: estimer une réponse pour une nouvelle observation;
- une segmentation: regrouper des observations similaires;
- une validation: mesurer si un modèle généralise à de nouvelles données.

Une formulation claire évite les explorations sans direction et limite le risque
de construire une méthode élégante qui ne répond pas au problème initial.

== Qualité des données

Les données sont le coeur de l'analyse. Même un modèle très sophistiqué ne peut
pas corriger un échantillon non représentatif, une variable mal définie ou des
erreurs systématiques de collecte.

Lors de la première inspection, on vérifie notamment:

- la représentativité de la population cible;
- les valeurs manquantes et leur codage;
- les doublons et les incohérences;
- les unités et les changements d'échelle;
- les valeurs extrêmes;
- les modalités rares ou trop nombreuses;
- le déséquilibre éventuel des classes;
- les corrélations fortes entre variables.

#example[
  Dans une base client, les codes "NA", "N/A", "?", chaîne vide et "Inconnu"
  peuvent tous représenter une absence d'information. Les traiter comme cinq
  modalités différentes créerait une structure artificielle.
]

== Données tidy

Un tableau est dit *tidy* lorsque chaque variable est une colonne, chaque
observation est une ligne et chaque cellule contient une seule valeur. Cette
organisation facilite l'exploration, la visualisation, la modélisation et la
reproductibilité.

Le format tidy n'est pas toujours le format de collecte. Il faut parfois pivoter
un tableau, séparer une colonne composite, uniformiser des catégories, ou
ramener plusieurs fichiers à une même unité statistique.

== Unité statistique

L'unité statistique est l'élément de base sur lequel porte une observation. Elle
peut être un individu, une transaction, une entreprise, un pays, une image, un
pixel ou un document. Ce choix fixe le niveau d'agrégation de l'analyse.

#example[
  Dans une base d'images médicales, on peut prendre l'image comme unité pour
  classer un diagnostic. On peut aussi prendre le pixel comme unité pour une
  tâche de segmentation. Les variables et les méthodes changent alors
  complètement.
]

== Types de variables

Le type d'une variable détermine l'espace mathématique, les distances possibles
et les modèles pertinents.

- Une variable numérique mesure une quantité: âge, revenu, température, masse.
- Une variable ordinale possède des modalités ordonnées sans écart mesurable:
  faible, moyen, élevé.
- Une variable nominale symétrique possède des modalités sans ordre et de statut
  comparable: nationalité, programme d'étude.
- Une variable nominale asymétrique possède une modalité de référence ou de
  défaut: présence ou absence d'un symptôme, transaction frauduleuse ou non.

Une variable textuelle, une courbe, une image ou un réseau demande une
représentation plus riche. Le choix de représentation est alors une partie
centrale de l'analyse.

== Espaces d'observation

Une fois les variables définies, on choisit l'espace dans lequel vivent les
observations. Une variable numérique peut être représentée dans les réels, ou
dans un intervalle si des contraintes physiques existent. Une variable nominale
vit dans un ensemble fini de modalités. Plusieurs variables conduisent à un
produit d'espaces: une observation est alors un vecteur de caractéristiques.

#note[
  Le choix de l'espace n'est pas neutre. Encoder les couleurs rouge, vert et
  bleu par 1, 2 et 3 impose un ordre qui n'existe pas. Il vaut mieux utiliser une
  représentation adaptée, par exemple un encodage binaire des modalités.
]

== Distances et similarités

La plupart des méthodes du cours reposent sur une comparaison entre
observations. Une distance mesure une dissemblance. Elle doit être non négative,
symétrique, nulle seulement entre deux objets identiques et respecter
l'inégalité triangulaire.

Pour deux vecteurs numériques $x$ et $y$, la distance euclidienne s'écrit:

$ d(x, y) = sqrt(sum_(j=1)^p (x_j - y_j)^2) $

Plus généralement, la distance de Minkowski d'ordre $q$ est:

$ d_q(x, y) = (sum_(j=1)^p |x_j - y_j|^q)^(1 / q) $

La distance de Manhattan correspond à $q = 1$ et la distance euclidienne à
$q = 2$.

== Effet de l'échelle

Les distances numériques sont sensibles aux unités. Une variable mesurée en
dollars peut dominer une variable mesurée entre 0 et 1, même si elle n'est pas
plus importante. On standardise donc souvent les variables numériques avant de
calculer une distance:

- centrer: retirer la moyenne;
- réduire: diviser par l'écart-type.

Cette étape permet de comparer des variations relatives plutôt que des unités
brutes.

== Variables qualitatives

Pour des variables qualitatives, les distances numériques habituelles n'ont pas
toujours de sens. On peut utiliser un encodage un-parmi-$K$ pour représenter une
variable à $K$ modalités par un vecteur binaire. Cela évite d'introduire un
ordre artificiel.

La distance de Hamming compte le nombre de désaccords entre deux observations.
Pour des variables binaires rares, l'indice de Jaccard se concentre sur les
présences communes:

$ J = M_11 / (M_11 + M_10 + M_01) $

La distance associée est $1 - J$. Elle ignore les doubles absences, qui sont
souvent moins informatives.

== Modèle prédictif

Une écriture générale pour les modèles prédictifs est:

$ Y = f(X) + epsilon $

La fonction $f$ représente l'information systématique que les variables
explicatives apportent sur la réponse. Le terme $epsilon$ représente la part non
expliquée, liée au bruit, aux variables absentes et à la variabilité naturelle.

L'objectif est d'estimer $f$ à partir d'un échantillon. La question centrale
devient alors: comment savoir si l'estimateur est bon ?

== Mesures d'erreur

Pour une réponse quantitative, on utilise souvent l'erreur quadratique moyenne:

$ "MSE" = (1 / n) sum_(i=1)^n (y_i - y_i^*)^2 $

où $y_i^*$ est la prédiction pour l'observation $i$.

Pour une réponse qualitative, on peut utiliser le taux d'erreur:

$ "ER" = (1 / n) sum_(i=1)^n 1_(y_i != y_i^*) $

Il mesure la proportion de mauvaises classifications.

== Compromis biais-variance

Un modèle très simple peut sous-ajuster les données: il a un biais élevé et ne
capture pas la structure réelle. Un modèle très flexible peut surajuster les
données d'apprentissage: il a une variance élevée et réagit fortement aux
fluctuations de l'échantillon.

#note[
  L'erreur de prédiction se décompose conceptuellement en trois éléments:
  biais, variance et erreur irréductible. Réduire l'un peut augmenter l'autre.
  Le bon modèle est rarement le plus simple ou le plus flexible; c'est celui qui
  généralise le mieux.
]

== Validation et sur-ajustement

Évaluer un modèle sur les données qui ont servi à l'entraîner donne une vision
trop optimiste. On sépare donc les données en ensembles d'entraînement et de
validation, ou on utilise la validation croisée.

Dans une validation croisée à $K$ plis, les observations sont divisées en $K$
sous-ensembles. On entraîne le modèle sur $K - 1$ plis et on l'évalue sur le pli
restant. On répète l'opération pour chaque pli puis on moyenne les erreurs.

En pratique, $K = 5$ ou $K = 10$ est un compromis courant entre stabilité et coût
de calcul. Le cas $K = n$ correspond à la validation leave-one-out.

== À retenir

- Une analyse commence par une question précise.
- Les choix d'unité statistique, de type de variables et de distance structurent
  toute la suite.
- Les données doivent être inspectées avant la modélisation.
- Un modèle doit être évalué sur des données non utilisées pour l'ajustement.
- L'interprétation dépend autant du contexte que de la performance numérique.

== Exercices

1. Choisissez un jeu de données et identifiez l'unité statistique, cinq
   variables et leur type.
2. Donnez deux exemples où la distance euclidienne brute serait trompeuse.
3. Expliquez la différence entre sur-ajustement et sous-ajustement.
4. Décrivez une stratégie de validation pour choisir entre trois modèles.
