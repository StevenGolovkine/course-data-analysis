#import "../styles/notes.typ": note, example

= Réduction de dimension

== Introduction

Un grand nombre de variables complique la visualisation, augmente le coût de
calcul, favorise les corrélations redondantes et peut rendre les modèles
instables. La réduction de dimension cherche à remplacer les variables initiales
par un plus petit nombre de variables synthétiques qui conservent l'information
utile.

Réduire la dimension ne signifie pas seulement supprimer des colonnes. Une
méthode plus riche consiste à construire de nouveaux axes, souvent comme des
combinaisons des variables initiales, puis à travailler dans cet espace réduit.
On passe alors d'une représentation où chaque variable a son propre rôle à une
représentation où quelques dimensions résument les principales structures.

#note[
  La réduction de dimension est une étape exploratoire. Elle aide à voir une
  structure, à compresser l'information ou à préparer une méthode prédictive,
  mais elle ne remplace pas l'interprétation statistique.
]

=== Deux idées différentes

Il faut distinguer deux familles d'approches.

- La sélection de variables garde certaines colonnes originales et en élimine
  d'autres.
- L'extraction de dimensions construit de nouvelles variables synthétiques,
  appelées axes, composantes ou facteurs.

Les méthodes factorielles étudiées dans ce chapitre appartiennent surtout à la
seconde famille. Elles ne disent pas seulement quelles variables sont utiles:
elles proposent une géométrie des données.

=== Choisir une méthode

Le choix dépend d'abord du type de variables.

- L'ACP s'applique à un tableau de variables numériques.
- L'AFC s'applique à un tableau de contingence croisant deux variables
  qualitatives.
- L'ACM s'applique à plusieurs variables qualitatives, souvent issues d'un
  questionnaire.
- t-SNE et UMAP s'utilisent surtout pour visualiser des voisinages dans des
  données nombreuses ou complexes.
- Les autoencodeurs apprennent une représentation latente par un modèle
  prédictif, souvent non linéaire.

Dans tous les cas, l'objectif est de construire une carte de faible dimension.
Cette carte doit être lue avec prudence: une projection simplifie les données,
donc elle conserve certaines oppositions et en efface d'autres.

== L'ACP

=== Principe

L'analyse en composantes principales, ou ACP, s'applique à des variables
numériques. Elle cherche des directions orthogonales de variation maximale. La
première composante explique le plus de variance possible, la seconde explique
le plus de variance restante sous contrainte d'être orthogonale à la première,
et ainsi de suite.

Soit $X$ un vecteur centré de $p$ variables et $Σ$ sa matrice de covariance.
Une composante principale est une combinaison linéaire:

$ Y_k = alpha_k^T X $

La première direction $alpha_1$ maximise la variance de $Y_1$ sous la contrainte
que $alpha_1$ soit de norme 1. La solution est donnée par l'équation aux valeurs
propres:

$ Σ alpha_1 = λ_1 alpha_1 $

La première composante principale est associée à la plus grande valeur propre.
Les composantes suivantes correspondent aux valeurs propres suivantes, ordonnées
de la plus grande à la plus petite.

=== Inertie et variance expliquée

Chaque valeur propre mesure la variance expliquée par une composante. La
proportion de variance expliquée par la composante $k$ est:

$ λ_k / sum_(j=1)^p λ_j $

Les premières composantes donnent donc une représentation de faible dimension
qui conserve une grande part de la variance totale.

On appelle souvent inertie totale la variance totale du nuage de points. Dans
une ACP centrée, cette inertie est répartie entre les composantes principales.
Un bon résumé en deux dimensions est possible lorsque les deux premières
composantes concentrent une part importante de cette inertie.

#example[
  Si les deux premières composantes expliquent 82 pour cent de la variance d'un
  jeu de données à dix variables, un graphique dans le plan principal donne une
  image raisonnable de la structure globale. Il peut montrer des groupes, des
  observations atypiques ou des variables fortement associées.
]

=== Lecture des cartes factorielles

Une ACP produit généralement deux types de représentations.

- La carte des individus place les observations dans le plan formé par deux
  composantes principales.
- Le cercle des corrélations représente les variables et aide à comprendre le
  sens des axes.

Sur la carte des individus, deux observations proches ont des profils numériques
semblables selon les variables qui contribuent aux axes affichés. Sur le cercle
des corrélations, deux variables proches sont corrélées positivement, deux
variables opposées sont corrélées négativement, et une variable proche de
l'origine est mal représentée dans le plan choisi.

#note[
  Le signe d'un axe d'ACP est arbitraire. Inverser un axe ne change pas
  l'analyse: seules les directions, les oppositions et les contributions sont
  importantes.
]

=== Pratique de l'ACP

En pratique, la matrice de covariance est inconnue et doit être estimée à partir
des données. On centre les variables, on calcule la matrice de covariance ou de
corrélation, puis on diagonalise cette matrice.

Il faut standardiser les variables lorsque leurs unités ou leurs ordres de
grandeur diffèrent. Sinon, une variable très dispersée peut dominer les axes
principaux même si elle n'est pas plus informative.

Pour choisir le nombre de composantes, on peut utiliser:

- la proportion de variance expliquée, par exemple atteindre 80 pour cent;
- la règle de Kaiser, pour une ACP sur corrélations, qui garde les valeurs
  propres supérieures à 1;
- la règle de Joliffe, qui utilise parfois un seuil de 0.7;
- le graphique des valeurs propres, aussi appelé règle du coude;
- l'interprétabilité des axes et l'objectif de l'analyse.

Il est aussi utile de regarder les contributions et les qualités de
représentation. Une variable très contributive aide à définir un axe. Une
observation bien représentée dans un plan peut être interprétée dans ce plan;
une observation mal représentée demande de consulter d'autres axes.

=== Limites

L'ACP est linéaire: elle cherche des axes qui sont des combinaisons linéaires
des variables. Elle conserve la variance, pas nécessairement l'information utile
pour une tâche supervisée. Elle est sensible aux variables mal standardisées, aux
valeurs extrêmes et aux relations non linéaires.

Lorsque les composantes sont utilisées comme variables prédictives, il faut les
calculer uniquement à partir des données d'entraînement puis appliquer la même
transformation aux données de validation ou de test.

== L'AFC

=== Tableau de contingence et profils

L'analyse factorielle des correspondances, ou AFC, s'applique à un tableau de
contingence croisant deux variables qualitatives. Elle représente simultanément
les modalités de ligne et de colonne dans un espace de faible dimension.

L'AFC part des fréquences relatives du tableau. Elle compare les profils-lignes
et les profils-colonnes plutôt que les effectifs bruts. Un profil-ligne décrit,
pour une modalité de la première variable, la distribution conditionnelle des
modalités de la seconde variable. Un profil-colonne décrit l'information
symétrique.

#example[
  Si l'on croise le programme d'étude et le type d'admission des étudiants, une
  ligne du tableau décrit la répartition des types d'admission pour un programme
  donné. Deux programmes proches dans la représentation AFC ont des profils
  d'admission semblables.
]

=== Indépendance et distance du chi-deux

Si les deux variables qualitatives sont indépendantes, les fréquences conjointes
sont proches du produit des fréquences marginales. L'AFC étudie les écarts à
cette situation d'indépendance.

La distance utilisée est la distance du chi-deux. Elle pondère les écarts par
les fréquences marginales, ce qui évite qu'une modalité très fréquente impose à
elle seule la structure géométrique. L'inertie totale est liée à la statistique
du test du chi-deux d'indépendance.

Autrement dit, l'AFC met en évidence les associations qui s'écartent le plus de
ce que l'on observerait si les deux variables étaient indépendantes.

=== Représentation barycentrique

Une propriété utile de l'AFC est la double représentation barycentrique. Les
modalités de ligne peuvent être vues comme des barycentres pondérés des
modalités de colonne, et inversement. Cela rend les cartes factorielles
interprétables: une proximité entre modalités suggère une association dans le
tableau, à condition de vérifier la qualité de représentation.

#note[
  Sur une carte d'AFC, il faut interpréter les directions, les oppositions et
  les contributions. Deux points proches du centre peuvent être mal représentés
  ou peu contributifs; leur proximité brute n'est pas toujours informative.
]

=== Lecture pratique

Pour interpréter une AFC, on regarde:

- les modalités qui contribuent fortement aux axes;
- les oppositions entre modalités de ligne;
- les oppositions entre modalités de colonne;
- les modalités éloignées de l'origine, souvent plus spécifiques;
- la qualité de représentation des points dans le plan affiché.

Une carte d'AFC n'est pas seulement un graphique décoratif. Elle doit être reliée
au tableau de contingence: les associations visibles doivent correspondre à des
écarts concrets entre profils.

== L'ACM

=== Plusieurs variables qualitatives

L'analyse des correspondances multiples, ou ACM, généralise l'AFC à plusieurs
variables qualitatives. Elle est particulièrement utile pour les questionnaires
ou les enquêtes comportant plusieurs questions à choix multiples.

Chaque variable est transformée en modalités binaires par codage disjonctif
complet. Si une question possède trois modalités, elle devient trois colonnes
binaires. Un individu reçoit un 1 pour la modalité choisie et 0 pour les autres.

Le tableau de Burt, obtenu comme produit du tableau disjonctif transposé par le
tableau disjonctif, croise toutes les modalités entre elles. L'ACM peut être vue
comme une AFC appliquée au tableau disjonctif complet ou au tableau de Burt.

=== Individus et modalités

L'ACM représente à la fois les individus et les modalités. Deux individus proches
ont tendance à partager des modalités semblables. Deux modalités proches sont
souvent choisies par des individus aux profils semblables.

Les axes d'une ACM opposent donc des profils de réponses. Par exemple, dans une
enquête sur les habitudes d'étude, un premier axe peut opposer des étudiants
très organisés à des étudiants qui déclarent travailler de manière irrégulière.
Un second axe peut distinguer les habitudes individuelles des habitudes
collectives.

=== Encodage et regroupement des modalités

Le choix des modalités est crucial. Pour une variable continue que l'on souhaite
inclure dans une ACM, il faut d'abord la discrétiser en classes. Ce découpage
fait perdre de l'information et doit être guidé par le contexte, les
distributions observées et l'objectif de l'analyse.

Pour les variables qualitatives, certaines modalités peuvent être trop rares.
Il est préférable de les regrouper de manière interprétable plutôt que de les
répartir arbitrairement dans d'autres catégories.

On peut aussi déclarer certaines variables ou modalités comme supplémentaires.
Elles sont alors projetées sur la carte sans contribuer à la construction des
axes. Cette pratique est utile pour interpréter les dimensions sans laisser une
variable illustrative dominer la géométrie.

=== Interprétation et limites

L'ACM est très utile pour résumer des données qualitatives nombreuses, mais son
inertie est souvent plus difficile à lire que celle de l'ACP. Le codage
disjonctif complet augmente le nombre de colonnes et dilue mécaniquement les
pourcentages d'inertie. Une faible proportion d'inertie expliquée n'implique
donc pas nécessairement que la carte soit inutile.

Comme pour l'AFC, l'interprétation doit s'appuyer sur les contributions, les
qualités de représentation et le retour aux données initiales. Une modalité rare
peut attirer un axe à elle seule; elle doit alors être examinée avant de conclure
qu'elle révèle une structure générale.

#example[
  Dans un questionnaire étudiant, les modalités "jamais", "parfois", "souvent"
  et "toujours" ne doivent pas être regroupées mécaniquement. Leur ordre et leur
  sens substantiel doivent guider la construction des catégories utilisées dans
  l'ACM.
]

== t-SNE

=== Idée générale

t-SNE, pour *t-distributed stochastic neighbor embedding*, est une méthode non
linéaire principalement utilisée pour produire des cartes en deux ou trois
dimensions. Elle transforme les proximités entre observations en probabilités:
deux observations proches dans l'espace initial doivent avoir une forte
probabilité d'être voisines dans la représentation réduite.

L'algorithme cherche ensuite une carte de faible dimension dont les probabilités
de voisinage ressemblent à celles de l'espace initial. La comparaison se fait
par une divergence de Kullback-Leibler. La loi de Student utilisée dans l'espace
réduit aide à éviter que tous les points soient tassés au centre de la carte.

=== Interprétation

t-SNE est très efficace pour faire apparaître des groupes locaux, surtout dans
des données de grande dimension comme des images, des textes vectorisés ou des
données biologiques. En revanche, les distances entre groupes, la taille des
groupes et leur densité apparente peuvent être trompeuses.

#note[
  Une carte t-SNE ne doit pas être lue comme une carte géographique. Deux points
  voisins sont souvent réellement semblables, mais deux groupes éloignés ne sont
  pas nécessairement très différents au sens statistique.
]

=== Paramètres importants

Le paramètre le plus connu est la perplexité. Il contrôle approximativement le
nombre de voisins pris en compte autour de chaque observation. Une petite
perplexité met en avant des structures très locales; une grande perplexité donne
une vision plus lissée.

En pratique, il faut aussi surveiller l'initialisation, le taux d'apprentissage,
le nombre d'itérations et la graine aléatoire. Une bonne habitude consiste à
comparer plusieurs cartes et à vérifier que les structures observées existent
aussi dans les données initiales ou dans une ACP préalable.

== UMAP

=== Principe

UMAP, pour *uniform manifold approximation and projection*, est une méthode non
linéaire fondée sur un graphe de plus proches voisins. Elle construit d'abord
une représentation des voisinages dans l'espace initial, puis cherche une carte
de faible dimension qui conserve autant que possible cette structure de graphe.

Comme t-SNE, UMAP est surtout utilisé pour la visualisation exploratoire. Il est
souvent plus rapide sur de grands jeux de données et conserve parfois mieux une
part de structure globale, même si cette structure doit toujours être validée.

=== Paramètres importants

Le paramètre `n_neighbors` contrôle l'équilibre entre structure locale et
structure plus globale. Une petite valeur accentue les voisinages immédiats; une
grande valeur donne une carte plus continue. Le paramètre `min_dist` contrôle le
degré de compacité des groupes dans l'espace projeté.

La métrique utilisée est aussi importante. Pour des données numériques
standardisées, la distance euclidienne est fréquente. Pour des textes, des
vecteurs creux ou des données binaires, d'autres similarités peuvent être plus
pertinentes.

=== Usages

UMAP est utile pour explorer des données complexes avant une analyse plus
formelle. On l'utilise souvent après une étape de prétraitement: standardisation,
filtrage de variables, ACP préalable ou choix d'une distance adaptée.

Certaines implémentations permettent aussi de projeter de nouvelles observations
dans une carte apprise. Cela rend UMAP plus pratique que t-SNE dans des flux de
données ou dans un protocole où l'on souhaite comparer entraînement et
validation.

== Autoencodeurs

=== Représentation latente

Un autoencodeur est un réseau de neurones entraîné à reconstruire ses entrées.
Il est composé de deux parties: un encodeur qui transforme l'observation initiale
en représentation latente de plus faible dimension, puis un décodeur qui tente de
reconstruire l'observation à partir de cette représentation.

Si la dimension latente est petite, le modèle doit apprendre un résumé utile des
données. Contrairement à l'ACP, ce résumé peut être non linéaire. Cela permet de
capturer des structures complexes, au prix d'une interprétation souvent plus
difficile.

=== Fonction de perte

L'entraînement repose sur une erreur de reconstruction. Pour des données
numériques, on utilise souvent une erreur quadratique. Pour des données binaires
ou des comptages, on choisit une fonction de perte adaptée à la nature des
données.

La réduction de dimension correspond alors à la sortie de l'encodeur. On peut
utiliser cette représentation latente pour visualiser les observations, alimenter
un modèle prédictif ou comparer des profils.

=== Autoencodeurs variationnels

Les autoencodeurs variationnels, ou VAE, ajoutent une structure probabiliste à
l'espace latent. L'encodeur ne produit pas seulement un point, mais une
distribution latente. Le modèle combine une erreur de reconstruction et une
pénalité qui rapproche l'espace latent d'une distribution de référence.

Les VAE sont particulièrement utiles lorsque l'on veut générer de nouvelles
observations, lisser des données bruitées ou construire une représentation
latente régulière. Ils demandent cependant plus de données, plus de réglages et
une validation plus soigneuse que les méthodes factorielles classiques.

== Autres

=== Prolongements

Les méthodes suivantes peuvent être présentées comme prolongements, selon le
temps disponible et le type de données étudié.

- TriMap construit la carte à partir de triplets: une observation doit rester
  plus proche d'une deuxième observation que d'une troisième. Cette idée est
  utile pour discuter de la préservation de la structure globale.
- PaCMAP utilise des paires proches, moyennement proches et éloignées afin de
  mieux équilibrer la structure locale et la structure globale.
- PHATE s'appuie sur une géométrie de diffusion. Il est particulièrement adapté
  aux trajectoires, aux transitions continues et aux données biologiques comme
  les données de cellules individuelles.
- UMAP paramétrique remplace une partie de l'optimisation UMAP par un réseau de
  neurones. Il apprend une fonction de projection, ce qui facilite l'ajout de
  nouvelles observations.

=== Message à retenir

Ces méthodes modernes produisent des visualisations puissantes, mais elles ne
suppriment pas le besoin d'interprétation statistique. Elles dépendent du choix
de la distance, du graphe de voisins, des paramètres et parfois de
l'initialisation.

Une bonne pratique consiste à comparer plusieurs méthodes, à revenir aux
variables initiales et à vérifier les conclusions par des mesures simples:
profils moyens, distances, contributions, stabilité des groupes ou performance
sur un jeu de validation.

#heading(level: 2, outlined: false)[Questions rapides]

1. Expliquez pourquoi une ACP sur des variables non standardisées peut être
   trompeuse.
2. Dans une ACP, que signifie une valeur propre élevée ?
3. Donnez un exemple de tableau de contingence adapté à une AFC.
4. Décrivez comment construire un tableau disjonctif complet pour trois
   questions à choix multiples.
5. Pourquoi faut-il être prudent avec les modalités rares en ACM ?
6. Pourquoi une carte t-SNE ne suffit-elle pas à prouver l'existence de groupes
   statistiques ?
7. Quel paramètre d'UMAP contrôle l'équilibre entre structure locale et globale ?
8. Dans un autoencodeur, quelle partie du modèle fournit la représentation
   réduite ?
