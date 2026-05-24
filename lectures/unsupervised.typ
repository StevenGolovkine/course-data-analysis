#import "../styles/notes.typ": note, example

= Apprentissage non supervisé

== Objectif

En apprentissage non supervisé, aucune variable réponse n'est fournie. On
cherche une structure dans les observations: groupes, proximités, hiérarchie,
axes de variation ou sous-populations.

Pour la classification non supervisée, aussi appelée regroupement ou
*clustering*, on dispose de $n$ observations et l'on veut les répartir en $K$
groupes de sorte que les observations d'un même groupe soient similaires et que
les groupes soient distincts.

#note[
  Une partition n'est pas une vérité observée. C'est une représentation utile si
  elle est stable, interprétable et adaptée à la distance choisie.
]

== Fonction de coût

Une partition peut être vue comme une fonction qui associe chaque observation à
un groupe. Sa qualité se mesure souvent par une fonction de coût intra-groupe:

$ W(C) = sum_(k=1)^K sum_(i in C_k) d(X_i, G_k)^2 $

où $G_k$ est un représentant du groupe $k$, par exemple son centroïde.

Minimiser exactement ce type de coût est généralement impossible pour des jeux
de données réalistes. On utilise donc des algorithmes itératifs qui trouvent une
bonne solution locale.

== Algorithme des k-moyennes

L'algorithme des $k$-moyennes regroupe des observations numériques autour de
$K$ centroïdes.

1. Choisir le nombre de groupes $K$.
2. Initialiser les centroïdes ou une partition.
3. Affecter chaque observation au centroïde le plus proche.
4. Recalculer chaque centroïde comme la moyenne de son groupe.
5. Répéter jusqu'à stabilisation.

La méthode converge en un nombre fini d'itérations car chaque étape réduit
l'inertie intra-groupe. Elle peut toutefois converger vers un minimum local.

== Limites des k-moyennes

Les $k$-moyennes supposent implicitement des groupes plutôt compacts, de forme
sphérique et comparables en taille. La méthode est sensible à l'initialisation,
aux valeurs extrêmes et à l'échelle des variables. Il faut généralement
standardiser les variables numériques.

Le nombre $K$ doit être choisi à l'avance. On peut s'aider d'une visualisation,
de la méthode du coude, de la silhouette moyenne ou de critères issus de modèles
probabilistes.

== k-médoïdes

Les $k$-médoïdes remplacent le centroïde par une observation réelle du groupe:
le médoïde est l'observation qui minimise la somme des distances aux autres
observations du groupe.

Cette méthode est plus robuste aux valeurs extrêmes et peut utiliser des
distances non euclidiennes. Elle est cependant plus coûteuse en calcul que les
$k$-moyennes.

== Classification hiérarchique

La classification hiérarchique produit une suite de partitions imbriquées. Elle
peut être représentée par un dendrogramme.

Deux familles existent:

- les méthodes ascendantes, qui commencent avec une observation par groupe et
  fusionnent progressivement les groupes les plus proches;
- les méthodes descendantes, qui commencent avec toutes les observations dans un
  seul groupe et divisent progressivement les groupes.

Les méthodes ascendantes sont les plus utilisées en pratique.

== Distances entre groupes

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

== Choisir une partition

Un dendrogramme ne fournit pas automatiquement le nombre de groupes. On peut
choisir une coupe à partir:

- d'une connaissance métier ou d'une contrainte opérationnelle;
- d'une rupture visible dans les hauteurs de fusion;
- d'un critère d'inertie;
- d'un indice de silhouette;
- de la stabilité des groupes sous rééchantillonnage.

Les critères statistiques aident à formuler une décision, mais ils ne remplacent
pas l'interprétation.

== Critères de qualité

L'inertie totale se décompose en inertie intra-groupe et inter-groupe. Une bonne
partition cherche des groupes compacts et bien séparés. Le pseudo-$R^2$ mesure
la proportion d'inertie expliquée par la partition. La statistique de
Calinski-Harabasz normalise cette idée par le nombre de groupes.

L'indice de Dunn compare la distance minimale entre groupes à la dispersion
maximale dans un groupe. La silhouette d'une observation compare sa distance
moyenne à son propre groupe à sa distance moyenne au groupe voisin le plus
proche.

== Mélanges de gaussiennes

Les mélanges de gaussiennes proposent une approche probabiliste du regroupement.
On suppose que les données proviennent de $K$ sous-populations, chacune décrite
par une loi normale multivariée avec sa moyenne, sa covariance et son poids.

Chaque observation a alors des probabilités d'appartenance aux groupes, plutôt
qu'une affectation strictement déterministe.

== Algorithme EM

Les étiquettes de groupe étant inconnues, on maximise la vraisemblance marginale
à l'aide de l'algorithme EM.

- Étape E: estimer les probabilités d'appartenance de chaque observation à
  chaque groupe.
- Étape M: mettre à jour les poids, les moyennes et les matrices de covariance.

La forme des matrices de covariance détermine la géométrie des groupes:
sphères de même taille, sphères de tailles différentes, ellipsoïdes alignées
avec les axes ou ellipsoïdes libres.

== Choisir le nombre de groupes

Dans les mélanges gaussiens, on ajuste souvent plusieurs modèles pour différentes
valeurs de $K$ et différentes contraintes de covariance. On compare ensuite les
modèles à l'aide de critères pénalisés comme AIC ou BIC. Le BIC favorise
généralement des modèles plus parcimonieux.

== Bonnes pratiques

- Standardiser les variables lorsque la distance dépend de l'échelle.
- Essayer plusieurs initialisations pour les méthodes sensibles au départ.
- Comparer plusieurs distances ou liaisons si le choix est incertain.
- Visualiser les groupes lorsque c'est possible.
- Décrire les groupes par leurs variables principales après la partition.
- Vérifier que la partition est utile pour la question initiale.

== Exercices

1. Expliquez pourquoi les $k$-moyennes sont sensibles aux valeurs extrêmes.
2. Comparez la liaison simple et la liaison complète.
3. Que signifie une silhouette moyenne proche de zéro ?
4. Dans un mélange gaussien, pourquoi contraindre les matrices de covariance
   peut-il améliorer la généralisation ?
