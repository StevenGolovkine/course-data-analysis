#import "../styles/notes.typ": note, example

= Apprentissage non supervisé

== Introduction

En apprentissage non supervisé, aucune variable réponse n'est fournie. On
cherche une structure dans les observations: groupes, proximités, hiérarchie,
axes de variation ou sous-populations.

Pour la classification non supervisée, aussi appelée regroupement ou
*clustering*, on dispose de $n$ observations et l'on veut les répartir en groupes
de sorte que les observations d'un même groupe soient similaires et que les
groupes soient distincts.

#note[
  Une partition n'est pas une vérité observée. C'est une représentation utile si
  elle est stable, interprétable et adaptée à la distance choisie.
]

=== Distance et représentation

Le résultat d'une méthode de regroupement dépend fortement de l'espace dans
lequel les observations sont représentées. Pour des variables numériques, on
utilise souvent la distance euclidienne. Pour des variables qualitatives,
binaires, textuelles ou mixtes, d'autres distances peuvent être plus pertinentes.

Lorsque les variables numériques n'ont pas la même unité ou le même ordre de
grandeur, il faut généralement les standardiser. Sinon, une variable très
dispersée peut dominer la distance et donc imposer la structure des groupes.

=== Fonction de coût

Une partition peut être vue comme une fonction qui associe chaque observation à
un groupe. Sa qualité se mesure souvent par une fonction de coût intra-groupe:

$ W(C) = sum_(k=1)^K sum_(i in C_k) d(X_i, G_k)^2 $

où $G_k$ est un représentant du groupe $k$, par exemple son centroïde.

Minimiser exactement ce type de coût est généralement impossible pour des jeux
de données réalistes. On utilise donc des algorithmes itératifs qui trouvent une
bonne solution locale.

=== Critères de qualité

L'inertie totale se décompose en inertie intra-groupe et inter-groupe. Une bonne
partition cherche des groupes compacts et bien séparés. Le pseudo-$R^2$ mesure
la proportion d'inertie expliquée par la partition. La statistique de
Calinski-Harabasz normalise cette idée par le nombre de groupes.

L'indice de Dunn compare la distance minimale entre groupes à la dispersion
maximale dans un groupe. La silhouette d'une observation compare sa distance
moyenne à son propre groupe à sa distance moyenne au groupe voisin le plus
proche.

=== Bonnes pratiques

- Standardiser les variables lorsque la distance dépend de l'échelle.
- Essayer plusieurs initialisations pour les méthodes sensibles au départ.
- Comparer plusieurs distances ou liaisons si le choix est incertain.
- Visualiser les groupes lorsque c'est possible.
- Décrire les groupes par leurs variables principales après la partition.
- Vérifier que la partition est utile pour la question initiale.

== Les k-means

=== Principe

L'algorithme des k-means, ou $k$-moyennes, regroupe des observations numériques
autour de $K$ centroïdes. Chaque centroïde représente le centre moyen d'un
groupe. Une observation est affectée au groupe dont le centroïde est le plus
proche.

La méthode cherche à minimiser l'inertie intra-groupe:

$ W(C) = sum_(k=1)^K sum_(i in C_k) ||X_i - bar(X)_k||^2 $

où $bar(X)_k$ est la moyenne des observations du groupe $k$. Les groupes obtenus
sont donc définis par une proximité à des moyennes.

=== Algorithme

L'algorithme suit une procédure itérative simple.

1. Choisir le nombre de groupes $K$.
2. Initialiser les centroïdes ou une partition.
3. Affecter chaque observation au centroïde le plus proche.
4. Recalculer chaque centroïde comme la moyenne de son groupe.
5. Répéter jusqu'à stabilisation.

La méthode converge en un nombre fini d'itérations car chaque étape réduit
l'inertie intra-groupe. Elle peut toutefois converger vers un minimum local.

#example[
  Pour segmenter des clients selon leur fréquence d'achat et leur montant moyen,
  les k-means peuvent produire des groupes comme "clients occasionnels",
  "clients fréquents à petits montants" et "clients réguliers à forts montants".
  Ces étiquettes ne sont attribuées qu'après l'analyse, en décrivant les groupes.
]

=== Choisir le nombre de groupes

Le nombre $K$ doit être choisi à l'avance. On peut s'aider d'une visualisation,
de la méthode du coude, de la silhouette moyenne ou d'une contrainte
opérationnelle. Le bon nombre de groupes n'est pas seulement celui qui optimise
un critère: c'est aussi celui qui produit une description utilisable.

La méthode du coude consiste à tracer l'inertie intra-groupe en fonction de $K$.
Lorsque l'ajout d'un groupe supplémentaire améliore beaucoup moins le critère, on
peut retenir cette valeur comme compromis.

=== Limites et variantes

Les k-means supposent implicitement des groupes plutôt compacts, de forme
sphérique et comparables en taille. La méthode est sensible à l'initialisation,
aux valeurs extrêmes et à l'échelle des variables.

Les $k$-médoïdes remplacent le centroïde par une observation réelle du groupe:
le médoïde est l'observation qui minimise la somme des distances aux autres
observations du groupe. Cette méthode est plus robuste aux valeurs extrêmes et
peut utiliser des distances non euclidiennes. Elle est cependant plus coûteuse en
calcul.

#note[
  Les k-means produisent toujours une partition, même si les données ne
  contiennent pas de groupes naturels. Il faut donc vérifier la stabilité et
  l'interprétabilité des groupes obtenus.
]

== La classification hiérarchique

=== Principe

La classification hiérarchique produit une suite de partitions imbriquées. Elle
peut être représentée par un dendrogramme, c'est-à-dire un arbre qui montre dans
quel ordre les observations ou les groupes sont fusionnés.

Deux familles existent:

- les méthodes ascendantes, qui commencent avec une observation par groupe et
  fusionnent progressivement les groupes les plus proches;
- les méthodes descendantes, qui commencent avec toutes les observations dans un
  seul groupe et divisent progressivement les groupes.

Les méthodes ascendantes sont les plus utilisées en pratique.

=== Distances entre groupes

Pour fusionner des groupes, il faut définir une distance entre ensembles
d'observations.

- Plus proche voisin: distance minimale entre deux observations des groupes.
  Cette méthode accepte des formes irrégulières mais peut créer des chaînes.
- Plus distant voisin: distance maximale entre deux observations des groupes.
  Elle produit des groupes compacts mais est sensible aux valeurs extrêmes.
- Moyenne: moyenne de toutes les distances entre paires d'observations.
- Centroïde: distance entre les moyennes des groupes.
- Ward: fusion qui minimise l'augmentation d'inertie intra-groupe.

Le choix de liaison influence fortement le dendrogramme. Il doit être cohérent
avec la nature des groupes attendus et la distance entre observations.

=== Lire un dendrogramme

Un dendrogramme ne fournit pas automatiquement le nombre de groupes. On peut
choisir une coupe à partir:

- d'une connaissance métier ou d'une contrainte opérationnelle;
- d'une rupture visible dans les hauteurs de fusion;
- d'un critère d'inertie;
- d'un indice de silhouette;
- de la stabilité des groupes sous rééchantillonnage.

Une grande hauteur de fusion indique que deux groupes étaient assez éloignés
avant d'être réunis. Une coupe horizontale du dendrogramme transforme la
hiérarchie en partition.

=== Forces et limites

La classification hiérarchique est utile lorsque l'on veut comprendre plusieurs
niveaux de regroupement. Elle ne demande pas de choisir immédiatement le nombre
de groupes et produit une visualisation interprétable.

Elle devient plus coûteuse lorsque le nombre d'observations est grand. Elle est
aussi sensible au choix de distance et de liaison. Une fusion réalisée tôt ne
peut pas être corrigée plus tard dans les méthodes ascendantes classiques.

== Le mélange de gaussiennes

=== Modèle probabiliste

Les mélanges de gaussiennes proposent une approche probabiliste du regroupement.
On suppose que les données proviennent de $K$ sous-populations, chacune décrite
par une loi normale multivariée avec sa moyenne, sa covariance et son poids.

La densité du modèle peut s'écrire:

$ f(x) = sum_(k=1)^K pi_k phi(x; mu_k, Sigma_k) $

où $pi_k$ est le poids du groupe $k$, $mu_k$ sa moyenne, $Sigma_k$ sa matrice de
covariance et $phi$ la densité normale multivariée.

Chaque observation a alors des probabilités d'appartenance aux groupes, plutôt
qu'une affectation strictement déterministe. On parle de classification souple.

=== Algorithme EM

Les étiquettes de groupe étant inconnues, on maximise la vraisemblance marginale
à l'aide de l'algorithme EM.

- Étape E: estimer les probabilités d'appartenance de chaque observation à
  chaque groupe.
- Étape M: mettre à jour les poids, les moyennes et les matrices de covariance.

Ces deux étapes sont répétées jusqu'à stabilisation de la vraisemblance. Comme
pour les k-means, l'algorithme peut converger vers une solution locale; plusieurs
initialisations sont donc utiles.

=== Géométrie des groupes

La forme des matrices de covariance détermine la géométrie des groupes:
sphères de même taille, sphères de tailles différentes, ellipsoïdes alignées
avec les axes ou ellipsoïdes libres.

Cette flexibilité rend les mélanges gaussiens plus riches que les k-means. Ils
peuvent représenter des groupes elliptiques, de tailles différentes et avec des
incertitudes variables. En contrepartie, ils demandent plus de paramètres et sont
plus sensibles aux petits effectifs.

=== Choisir le modèle

Dans les mélanges gaussiens, on ajuste souvent plusieurs modèles pour différentes
valeurs de $K$ et différentes contraintes de covariance. On compare ensuite les
modèles à l'aide de critères pénalisés comme AIC ou BIC. Le BIC favorise
généralement des modèles plus parcimonieux.

Il faut aussi vérifier que les groupes trouvés ont un sens substantiel. Un
modèle probabiliste peut séparer des observations pour améliorer la
vraisemblance sans produire des groupes utiles pour l'analyse.

=== Comparaison avec les k-means

Les k-means peuvent être vus comme une version très contrainte d'un mélange
gaussien: les groupes sont associés à des centres et la frontière dépend de la
distance au centroïde. Les mélanges gaussiens ajoutent des poids, des covariances
et des probabilités d'appartenance.

En pratique, les k-means sont simples et rapides; les mélanges gaussiens sont
plus expressifs et fournissent une mesure d'incertitude sur l'appartenance aux
groupes.

== Méthodes non supervisées modernes

=== Clustering par densité

Les méthodes par densité cherchent des régions où les observations sont plus
concentrées que dans le reste de l'espace. Elles sont utiles lorsque les groupes
ne sont pas sphériques, lorsque leur taille varie ou lorsque certaines
observations doivent être considérées comme du bruit.

DBSCAN est la méthode classique de cette famille. Elle regroupe les observations
qui appartiennent à des zones suffisamment denses et marque comme atypiques les
points isolés. Son principal défaut est le choix délicat d'un rayon de voisinage
unique lorsque les densités varient selon les régions.

HDBSCAN prolonge cette idée en construisant une hiérarchie de groupes fondée sur
la densité. Il permet d'extraire les groupes les plus stables et de laisser
certaines observations non affectées. C'est un bon complément aux k-means, car il
n'impose ni centres, ni formes sphériques, ni affectation obligatoire de tous les
points.

#note[
  Les méthodes par densité restent dépendantes du choix de la distance. En grande
  dimension, il est souvent préférable de travailler après une réduction de
  dimension ou dans un espace de représentation adapté.
]

=== Clustering sur graphes

Une autre approche consiste à transformer les observations en graphe. Les noeuds
représentent les observations, et les arêtes relient des observations proches ou
similaires. Le regroupement devient alors un problème de détection de
communautés.

Cette formulation est naturelle pour les réseaux sociaux, les graphes de
relations, les données biologiques ou les graphes de plus proches voisins
construits à partir de données tabulaires. Elle permet de détecter des groupes
qui ne sont pas bien décrits par un centroïde ou par une loi gaussienne.

L'algorithme de Leiden améliore l'algorithme de Louvain pour la détection de
communautés. Il cherche des partitions de bonne qualité tout en évitant certains
groupes mal connectés. En pratique, il est très utilisé lorsque l'on construit un
graphe de voisins, par exemple après une étape de réduction de dimension ou de
calcul d'embeddings.

=== Représentations apprises et embeddings

Les méthodes modernes séparent souvent deux problèmes: apprendre une bonne
représentation des observations, puis regrouper les observations dans cet espace.
Cette stratégie est particulièrement utile pour les images, les textes, les sons
ou les données très hautement dimensionnelles.

Un autoencodeur peut apprendre une représentation latente en reconstruisant ses
entrées. Deep Embedded Clustering, ou DEC, combine cette idée avec un objectif de
clustering: le réseau apprend simultanément un espace latent et des affectations
de groupes.

Pour des données textuelles, on peut produire des embeddings avec un modèle de
langage, réduire la dimension si nécessaire, puis appliquer HDBSCAN ou k-means.
BERTopic suit cette logique: il regroupe des documents représentés par des
embeddings, puis décrit chaque groupe par des mots caractéristiques.

#example[
  Pour analyser des réponses libres à un questionnaire, on peut transformer les
  textes en embeddings, regrouper les réponses proches, puis décrire chaque
  groupe par quelques phrases représentatives. Le regroupement sert alors à
  organiser la lecture qualitative.
]

=== Prolongements

Plusieurs directions récentes prolongent ces idées.

- DeepCluster utilise des affectations de clustering comme pseudo-étiquettes
  pour apprendre des représentations visuelles.
- SwAV apprend des représentations en imposant une cohérence entre les
  affectations de différentes vues augmentées d'une même observation.
- Les autoencodeurs masqués apprennent à reconstruire une partie cachée des
  données, ce qui fournit une représentation utile sans étiquettes.
- scVI utilise un modèle génératif profond pour apprendre une représentation
  latente de données de transcriptomique unicellulaire.

Ces méthodes sont puissantes, mais elles déplacent une partie du problème vers
le choix de l'architecture, des augmentations, de la fonction de perte et des
paramètres d'entraînement. Dans un cours d'analyse des données, elles sont donc
à présenter comme des prolongements: elles enrichissent les outils classiques,
mais ne remplacent pas la validation, l'interprétation et le retour aux données
initiales.

#heading(level: 2, outlined: false)[Exercices]

1. Expliquez pourquoi les k-means sont sensibles aux valeurs extrêmes.
2. Comparez la liaison simple et la liaison complète.
3. Que signifie une silhouette moyenne proche de zéro ?
4. Dans un mélange gaussien, pourquoi contraindre les matrices de covariance
   peut-il améliorer la généralisation ?
5. Pourquoi faut-il standardiser les variables avant d'utiliser une distance
   euclidienne ?
6. Donnez un exemple où une classification hiérarchique serait plus informative
   qu'une partition directe.
7. Pourquoi HDBSCAN peut-il être plus adapté que les k-means pour des groupes de
   forme irrégulière ?
8. Comment peut-on utiliser un graphe de plus proches voisins pour faire du
   clustering ?
9. Pourquoi les embeddings sont-ils utiles avant de regrouper des textes ou des
   images ?
