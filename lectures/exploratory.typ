#import "../styles/notes.typ": definition-box, example, note, property-box, proof, remark, set-qed-symbol

#set-qed-symbol[$square$]

= Analyse exploratoire

== Introduction

Un projet d'analyse de données suit généralement cinq étapes :

1. Définir les objectifs.
2. Collecter, préparer et documenter les données.
3. Élaborer puis valider les modèles.
4. Mettre la solution en oeuvre.
5. Suivre la performance et améliorer le modèle.

Ces étapes n'ont pas le même poids. La préparation des données prend souvent la majeure partie du temps. En effet, il faut résoudre les problèmes de formats hétérogènes, de valeurs manquantes, de doublons d'observations, d'erreurs de saisie, d'accents, d'unités incohérentes et de modalités rares. À l'inverse, la partie visible du modèle peut parfois représenter peu de lignes de code, même si elle porte une décision importante.

#note[
  Un objectif vague comme "analyser les données clients" n'est pas opérationnel.
  Une meilleure formulation précise la décision visée: "peut-on prédire quels
  clients sont susceptibles d'acheter un nouveau produit d'épargne ?"
]

=== Définir une bonne question

Une analyse de données commence par une question bien formulée. Ainsi, une question utile doit préciser la population, l'unité statistique, la variable ou la décision d'intérêt et le type de résultat attendu. On peut viser:

- une description: résumer la distribution d'une variable;
- une comparaison: caractériser les différences entre groupes;
- une prédiction: estimer une réponse pour une nouvelle observation;
- une segmentation: regrouper des observations similaires;
- une validation: mesurer si un modèle généralise à de nouvelles données.

Une formulation claire évite les explorations sans direction et limite le risque
de construire une méthode élégante qui ne répond pas au problème initial.

#example[
  Une équipe sportive ne demande pas seulement d'« analyser les adversaires ».
  Elle peut chercher à caractériser leurs styles de jeu afin d'identifier des
  faiblesses exploitables. De même, une étude pharmaceutique doit annoncer si
  elle vise une description, une prédiction ou un test d'efficacité, car ces
  objectifs conduisent à des protocoles différents.
]

=== Les quatre objets d'une méthode

Une fois la question fixée, une méthode d'analyse peut être décrite par quatre objets complémentaires:

1. un *espace d'observation* qui représente les données;
2. une *distance* (ou une similarité) qui formalise la  dissimilitude (ou ressemblance) entre observations;
3. un *modèle* ou un algorithme qui extrait une structure;
4. une *fonction de coût* (ou de perte) qui mesure la qualité de la solution.

Changer un seul de ces objets peut modifier le résultat. Deux algorithmes
identiques appliqués à deux représentations ou avec deux distances différentes ne répondent pas exactement à la même question et ne donneront pas la même réponse.

=== De la question à la méthode

La question détermine les objets à définir: l'unité statistique, les variables, l'espace d'observation, la distance éventuelle, le modèle, la mesure d'erreur et le protocole de validation. Ces choix doivent être faits avant de comparer des méthodes, car ils déterminent ce qu'une méthode peut apprendre et comment son résultat sera jugé.

Une analyse exploratoire n'est donc pas seulement un ensemble de graphiques.
Elle sert à comprendre les données, à formuler des hypothèses, à repérer les
problèmes de qualité de données et à préparer une modélisation défendable.

=== Une posture critique

Les données reflètent un processus de collecte. Elles peuvent contenir des
omissions, des biais, des définitions ambiguës et des contraintes
institutionnelles. Avant de modéliser, il faut donc demander ce que les données
mesurent réellement et ce qu'elles ne mesurent pas.

#example[
  Dans une base client, une absence d'achat peut signifier un manque d'intérêt,
  une rupture de stock, un problème d'accès au service ou simplement une
  observation incomplète. Le même zéro apparent peut avoir plusieurs sens.
]

=== Mise en oeuvre et suivi

Une analyse ne se termine pas lorsque le modèle est choisi. Pour qu'une méthode
soit utilisée, il faut automatiser la collecte, le nettoyage, la transformation
et la production des résultats. Cette chaîne de calcul, souvent appelée
_pipeline_, relève en partie de l'ingénierie des données. Elle doit être testée,
documentée et reproductible.

Après le déploiement, on doit surveiller à la fois la qualité des données d'entrée et la performance du modèle. La distribution des variables peut évoluer avec le temps: on parle de dérive des données (_data drift_). La relation entre les variables explicatives et la réponse peut elle aussi changer. Il faut alors réévaluer les hypothèses, réentraîner le modèle ou revoir la question initiale.

#remark[
  Un bon modèle n'est pas seulement performant au moment de sa validation. Il
  doit demeurer pertinent, observable et révisable dans son contexte d'usage.
]

== Les données

=== Qualité des données

Les données sont le coeur de l'analyse. Même un modèle très sophistiqué ne peut
pas corriger un échantillon non représentatif, une variable mal définie ou des
erreurs systématiques de collecte.

Ainsi, lors de la première inspection, on doit notamment vérifier :

- la représentativité de la population cible;
- les valeurs manquantes et leur encodage;
- les doublons et les incohérences dans les observations;
- les unités et les changements d'échelle;
- les valeurs extrêmes;
- les modalités rares ou trop nombreuses;
- le déséquilibre éventuel des classes;
- les corrélations fortes entre variables.

#pagebreak(weak: true)
#block(breakable: false)[
  #example[
    Dans une base client, les codes "NA", "N/A", "?" et "Inconnu"
    peuvent tous représenter une absence d'information. Les traiter comme quatre
    modalités différentes créerait une structure artificielle.
  ]
]

=== Sources et provenance

Les données peuvent provenir de systèmes internes, d'enquêtes, de capteurs,
d'expériences ou de dépôts publics. Quelques points de départ utiles sont
#link("https://datasetsearch.research.google.com/")[Google Dataset Search],
#link("https://archive.ics.uci.edu/")[UCI Machine Learning Repository],
#link("https://www.kaggle.com/datasets")[Kaggle] et
#link("https://physionet.org/")[PhysioNet]. Pour des données officielles, on peut notamment regarder #link("https://www.statcan.gc.ca/fr/debut")[Statistique Canada] pour les données canadiennes, #link("https://www.data.gouv.fr/")[data.gouv.fr] pour les données françaises et #link("https://data.gov/")[Data.gov] pour les données américaines.

Cependant, trouver des données ne suffit pas. Il faut documenter

- la source, la licence et la date d'accès;
- la population visée et l'éventuelle méthode d'échantillonnage;
- la période et le territoire couverts;
- la définition des variables et leurs unités;
- les filtres, exclusions et transformations déjà appliqués;
- les changements de méthode de collecte au cours du temps.

#note[
  La provenance permet de distinguer une valeur réellement observée d'une
  valeur calculée, imputée ou issue d'une autre base. Sans cette information,
  une analyse peut être impossible à reproduire ou à interpréter.
]

=== Constitution de la base

Les données peuvent arriver sous des formats variés. En R, le package `readr` lit les fichiers texte, le package `readxl` les classeurs Excel, `haven` les fichiers SAS et SPSS, et `jsonlite` les objets JSON. En Python, les libraries `pandas` et `polars` couvrent la plupart des formats tabulaires usuels.

#align(center)[
  #table(
    columns: (1.1fr, 1.2fr, 1.4fr),
    inset: 6pt,
    stroke: 0.5pt + rgb("#cfd8dc"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
    [*Format*], [*Extensions*], [*Outils R*],
    [Texte], [`.txt`, `.csv`], [`readr`],
    [Excel], [`.xlsx`], [`readxl`],
    [SAS et SPSS], [`.sas7bdat`, `.sav`], [`haven`],
    [JSON], [`.json`], [`jsonlite`],
  )
]

Lors de l'importation, on fixe explicitement les types, l'encodage des
caractères (par exemple, `encoding = "UTF-8"` pour des données contentant des accents), les séparateurs décimaux (par exemple, `decimal = ","` pour des données avec une virgule comme séparateur décimal) et les symboles de valeurs manquantes (par exemple, `na = c("", "NA")`). Il est important de conserver les données brutes en lecture seule et de produire une table nettoyée par une suite de transformations versionnées.

=== Données tidy

#definition-box(supplement: "Définition")[
  Un tableau est dit _tidy_ lorsque chaque variable est une colonne, chaque
  observation est une ligne et chaque cellule contient une seule valeur.
]

Cette organisation facilite l'exploration, la visualisation, la modélisation et
la reproductibilité. La suite de package `tidyverse` en R et `pandas` en Python fournit des outils pour manipuler les données dans ce format. La plupart des méthodes d'analyse reposent sur cette structure (_data frame_), mais certaines méthodes plus anciennes ou spécialisées peuvent exiger un format différent.

Le format _tidy_ n'est pas toujours le format de collecte. Il faut parfois pivoter un tableau, séparer une colonne composite, uniformiser des catégories, ou ramener plusieurs fichiers à une même unité statistique.

=== Unité statistique

#definition-box(supplement: "Définition")[
  L'*unité statistique* est l'élément de base sur lequel porte une observation.
  Elle est le porteur de l'information et fixe le niveau d'agrégation de
  l'analyse.
]

L'unité statistique peut être un individu, une transaction, une entreprise, un pays, une image, un pixel ou un document. L'unité statistique n'est donc pas imposée par le fichier : elle résulte de la question posée.

#example[
  Dans une base d'images médicales, on peut prendre l'image comme unité pour
  classer ou prédire un diagnostic. On peut aussi prendre le pixel comme unité pour une tâche de segmentation. Les variables et les méthodes changent alors complètement.
]

#remark[
  Une même base peut être analysée à plusieurs niveaux, mais les observations
  d'un niveau ne sont pas nécessairement indépendantes. Les transactions d'un
  même client ou les pixels d'une même image partagent une structure commune.
]

=== Types de variables

Le type d'une variable détermine l'espace mathématique, les distances possibles
et les modèles pertinents.

- Une variable numérique (ou quantitative) mesure une quantité: âge, revenu, température, masse.
- Une variable nominale symétrique (ou qualitative) possède des modalités sans ordre et de statut comparable: nationalité, programme d'étude.
- Une variable nominale asymétrique possède une modalité de référence ou de défaut: présence ou absence d'un symptôme, transaction frauduleuse ou non.
- Une variable ordinale possède des modalités ordonnées sans écart mesurable: faible, moyen, élevé ou jamais, parfois, souvent.

Une variable textuelle, une courbe, une image ou un réseau demande une
représentation plus riche. Le choix de représentation est alors une partie
centrale de l'analyse.

#note[
  Une variable ordinale peut être codée par des nombres pour conserver son
  ordre, mais ce codage ne rend pas nécessairement les écarts comparables. Le
  passage de « faible » à « moyen » n'a aucune raison d'être équivalent au
  passage de « moyen » à « élevé ».
]

=== Espaces d'observation

Une fois les variables définies, on choisit l'espace dans lequel vivent les observations. Une variable numérique peut être représentée dans les réels $RR$, ou dans un intervalle si des contraintes physiques existent. Une variable nominale vit dans un ensemble fini de modalités. Plusieurs variables conduisent à un produit d'espaces. Si la variable $j$ prend ses valeurs dans $cal(X)_j$, alors l'espace d'observation complet est

$ cal(X) = cal(X)_1 times cal(X)_2 times dots times cal(X)_p. $

Lorsque les $p$ variables sont numériques, on obtient généralement $cal(X) = RR^p$. Une courbe peut plutôt être vue comme un élément d'un espace de fonctions continues $cal(C)([a,b])$, tandis qu'un texte peut être représenté par une séquence de symboles, un sac de mots (_bag of words_) ou un vecteur numérique construit à partir du corpus.

#example[
  *Variables numériques et mixtes.* Si une personne est décrite par son âge,
  son revenu annuel et sa taille, une représentation naturelle est
  $cal(X)=RR_+^3$. Si l'on ajoute une région appartenant à un ensemble fini
  $cal(R)$ et un niveau de satisfaction ordinal dans
  $cal(S)={"faible", "moyen", "élevé"}$, alors

  $ cal(X)=RR_+^3 times cal(R) times cal(S). $

  L'observation n'est plus un simple vecteur numérique: elle combine plusieurs
  types d'espaces.
]

#example[
  *Images.* Pour un pixel couleur dont les intensités sont ramenées entre $0$ et $1$, l'espace d'observation est $[0,1]^3$. Si l'unité statistique est plutôt une image couleur de hauteur $h$ et de largeur $w$, l'espace devient $[0,1]^(h times w times 3)$. Le même fichier conduit donc à deux espaces différents selon la question étudiée.
]

#example[
  *Courbes et signaux.* Une trajectoire de température observée en continu pendant une journée peut être modélisée dans $cal(C)([0,24])$. Mesurée à $T$ instants seulement, elle est plutôt représentée dans $RR^T$.
]

#note[
  Le choix de l'espace n'est pas neutre. En effet, encoder les couleurs rouge, vert et bleu par 1, 2 et 3 impose un ordre qui n'existe pas. Il vaut mieux utiliser une représentation adaptée, par exemple un encodage binaire des modalités.
]

== La distance

=== Distances et similarités

Une grande partie des méthodes d'analys de données reposent sur une comparaison entre observations. Une distance mesure une dissemblance : plus elle est grande, plus les observations sont considérés comme éloignés.

#definition-box(supplement: "Définition")[
  Une fonction $d: cal(X) times cal(X) arrow.r RR$ est une *distance* si, pour
  tout $x,y,z in cal(X)$,

  1. Non-négativité : $d(x,y) >= 0$;
  2. Séparation : $d(x,y) = 0 <=> x = y$;
  3. Symétrie : $d(x,y) = d(y,x)$;
  4. Inégalité triangulaire : $d(x,y) <= d(x,z) + d(z,y)$.
]

Pour deux vecteurs numériques $x$ et $y$, la *distance euclidienne* s'écrit:

$ d(x, y) = sqrt(sum_(j=1)^p (x_j - y_j)^2) $

Plus généralement, la *distance de Minkowski* d'ordre $q >= 1$ est:

$ d_q (x, y) = (sum_(j=1)^p |x_j - y_j|^q)^(1 / q) $

La *distance de Manhattan* correspond à $q = 1$ et la distance euclidienne à
$q = 2$. Lorsque $0 < q < 1$, la formule définit encore une dissemblance, mais
elle ne vérifie généralement pas l'inégalité triangulaire.

#example[
  Pour $x=(162.1,66.8)^top$ et $y=(175.8,81.6)^top$, décrivant une taille en centimètres et une masse en kilogrammes, on obtient $d_2(x,y)=20.16$ et $d_1(x,y)=28.5$. Ces nombres dépendent des unités choisies.
]

Une *similarité* augmente au contraire lorsque les observations se ressemblent.
On utilise souvent une fonction symétrique $s$ à valeurs dans $[0,1]$ telle que
$s(x,x)=1$. Toute distance peut, par exemple, produire la similarité

$ s(x,y) = 1 / (1 + d(x,y)). $

La quantité $1-s(x,y)$ est une dissemblance, mais pas nécessairement une
distance : l'inégalité triangulaire doit toujours être vérifiée séparément.

=== Effet de l'échelle

Les distances numériques sont sensibles aux unités. Une variable mesurée en
dollars peut dominer une variable mesurée entre 0 et 1, même si elle n'est pas
plus importante. On standardise donc souvent les variables numériques avant de
calculer une distance:

- centrer: retirer la moyenne;
- réduire: diviser par l'écart-type.

Pour la variable $j$, on pose $z_j (x)= frac((x_j-mu_j), sigma_j, style: "horizontal")$. La distance euclidienne entre observations standardisées devient

$ d_z (x,y) = sqrt(sum_(j=1)^p ((x_j-y_j)/sigma_j)^2). $

Le centrage disparaît dans la différence, tandis que la réduction pondère
chaque écart par la variabilité de sa variable.

#property-box(supplement: "Propriété")[
  La distance euclidienne calculée après standardisation est invariante à un
  changement d'origine et d'échelle effectué séparément sur chaque variable.
]

#proof(title: "Preuve")[
  Transformons la variable $j$ par $x'_j=a_j+b_j x_j$, où $b_j != 0$. Son
  écart-type devient $sigma'_j=|b_j| sigma_j$. Par conséquent,

  $ ((x'_j-y'_j)/sigma'_j)^2
    = ((|b_j| (x_j-y_j))/(|b_j|sigma_j))^2
    = ((x_j-y_j)/sigma_j)^2. $

  Chaque terme de la somme est inchangé; la distance l'est donc aussi.
]

Cette invariance ne signifie pas que la standardisation est toujours souhaitable.
Une variable peu dispersée peut devenir artificiellement influente et une
différence d'un écart-type n'a pas la même signification dans tous les domaines.

=== Variables qualitatives

Pour des variables qualitatives, les distances numériques habituelles n'ont pas toujours de sens. On peut utiliser un encodage un-parmi-$K$ (_one-hot encoding_) pour représenter une variable à $K$ modalités par un vecteur binaire. Cela évite d'introduire un ordre artificiel.

#example[
  Pour $cal(X)={"rouge", "vert", "bleu"}$, l'encodage un-parmi-$K$ associe le vecteur $(1,0,0)^top$ au rouge, le vecteur $(0,1,0)^top$ au vert et le vecteur $(0,0,1)^top$ au bleu. Toutes les modalités restent alors à la même distance les unes des autres.
]

#definition-box(supplement: "Définition")[
  Pour deux vecteurs qualitatifs $x,y in cal(X)^p$, la *distance de Hamming* est

  $ d_H (x,y) = sum_(j=1)^p 1(x_j != y_j). $

  Elle compte le nombre de désaccords. La proportion d'accords
  $s(x,y)=p^(-1) sum_j 1(x_j=y_j)$ fournit une similarité comprise entre
  $0$ et $1$.
]

#example[
  Si Alice et Bob diffèrent par la couleur et les cheveux, mais partagent la
  même couleur des yeux, alors $d_H ("Alice","Bob")=2$ sur trois variables et
  leur proportion d'accords vaut $1/3$.
]

Pour des variables binaires rares ou asymétriques, les doubles absences sont
souvent peu informatives. On définit $M_11$ comme le nombre de présences
communes, $M_10$ et $M_01$ comme les désaccords, et $M_00$ comme le nombre de
doubles absences. L'*indice de Jaccard* se concentre sur les présences :

$ J = M_11 / (M_11 + M_10 + M_01) $

La distance associée est $d_J=1-J$. Pour deux vecteurs binaires $x=(1,0,1,0,0)^top$ et $y=(1,0,0,1,0)^top$, on a $M_11=1$, $M_10=M_01=1$ et $M_00=2$, donc $J=1/3$ et $d_J=2/3$.

=== Choisir une distance

Choisir une distance revient à choisir ce que signifie "se ressembler". Deux
observations peuvent être proches selon leurs valeurs numériques, leurs
catégories, leurs trajectoires temporelles ou leurs voisins dans un graphe. La
distance doit donc être reliée à la question d'analyse.

#example[
  *Profils de clients.* Supposons que les variables soient l'âge, le revenu annuel et le nombre d'achats. Avec la distance euclidienne, les écarts de revenu, exprimés en dollars, dominent presque entièrement le calcul. Si les trois dimensions doivent avoir une importance comparable, une distance euclidienne sur les variables standardisées est plus cohérente. Si le revenu est réellement prioritaire pour la décision, on peut au contraire conserver ou expliciter une pondération plus forte.
]

#example[
  *Paniers d'achat.* Deux personnes qui n'ont acheté aucun
  des mêmes milliers de produits obtiennent beaucoup de doubles absences. Une
  distance de Hamming normalisée peut alors les déclarer artificiellement
  proches. La distance de Jaccard est préférable lorsque les présences communes
  et les désaccords sont informatifs, mais que les absences communes le sont peu.
]

#example[
  *Données mixtes.* Pour comparer des logements à partir de leur superficie,
  leur quartier et leur type de chauffage, une distance euclidienne unique n'a
  pas de sens. On peut combiner une distance numérique standardisée avec une
  distance de désaccord sur les variables qualitatives, puis choisir les poids
  selon l'objectif: estimation du prix, recherche de biens comparables ou
  segmentation du parc immobilier.
]

#note[
  Une distance n'est jamais un détail technique. Elle peut changer les groupes
  obtenus, les voisins les plus proches, les axes de réduction de dimension et
  l'interprétation des résultats. Son choix doit être justifié par le sens des
  variables, leur échelle et le coût réel des différences.
]

== Le calcul de l'erreur

#remark[
  Les termes *erreur*, *coût* et *perte* sont employés comme synonymes. Ils désignent une quantité numérique qui évalue l'écart entre le résultat obtenu et le résultat souhaité: plus cette quantité est faible, meilleure est la prédiction ou la décision. On parlera donc indifféremment de fonction d'erreur, de fonction de coût ou de fonction de perte.
]

=== Modèle prédictif

Une écriture générale pour les modèles prédictifs est:

$ Y = f(X) + epsilon $

La fonction $f$ représente l'information systématique que les variables explicatives apportent sur la réponse $Y$. Le terme $epsilon$ représente la part non expliquée, liée au bruit, aux variables absentes et à la variabilité naturelle. Dans le cadre de la régression, on suppose généralement

$ EE(epsilon)=0, quad "Var"(epsilon)=sigma^2, quad epsilon " indépendant de " X. $

L'objectif est d'estimer $f$ à partir d'un échantillon. La question centrale
devient alors: comment savoir si l'estimateur est bon ?

#example[
  En régression linéaire simple, on impose $hat(f)(x)=a x+b$. Estimer la fonction $hat(f)$ revient alors à estimer $a$ et $b$. Une méthode plus flexible autorise un plus grand ensemble de fonctions possibles.
]

#remark[
  Exactitude et interprétabilité peuvent entrer en tension. Une règle simple est facile à expliquer, mais peut manquer une relation complexe. À l'inverse, une méthode très flexible peut mieux prédire tout en étant plus difficile à justifier. Il n'existe pas de méthode universellement optimale: le modèle doit être adapté à la question, aux données et au coût des erreurs.
]

=== Mesures d'erreur en régression

#definition-box(supplement: "Définition")[
  Pour une réponse quantitative, l'*erreur quadratique moyenne* (_mean squared error_) est

  $ "MSE" = 1 / n sum_(i=1)^n (y_i - hat(y)_i)^2, $

  où $hat(y)_i=hat(f)(x_i)$ est la prédiction pour l'observation $i$.
]

On peut aussi utiliser l'erreur absolue moyenne (_mean absolute error_), moins sensible aux valeurs extrêmes :

$ "MAE" = 1 / n sum_(i=1)^n |y_i - hat(y)_i| $

Le choix entre MSE et MAE dépend du problème. La MSE pénalise fortement les erreurs importantes, ce qui peut être souhaitable si elles sont coûteuses. La MAE est plus robuste aux valeurs aberrantes et peut mieux refléter l'erreur typique.

=== Mesures d'erreur en classification

#definition-box(supplement: "Définition")[
  Pour une réponse qualitative, le *taux d'erreur* (_error rate_) est

  $ "ER" = 1 / n sum_(i=1)^n 1(y_i != hat(y)_i). $

  Il mesure la proportion de mauvaises classifications.
]

Lorsque les classes sont déséquilibrées, le taux d'erreur global peut être
trompeur. En classification binaire, on désigne d'abord une classe comme
positive, puis on répartit les prédictions dans une matrice de confusion.

#definition-box(supplement: "Définition")[
  La *matrice de confusion* croise la classe observée et la classe prédite:

  #align(center)[
    #table(
      columns: (1.35fr, 1fr, 1fr),
      inset: 5pt,
      stroke: 0.5pt + rgb("#cfd8dc"),
      fill: (x, y) => if y == 0 or x == 0 { rgb("#eef3f1") },
      [], [*Prédit positif*], [*Prédit négatif*],
      [*Réel positif*], [Vrai positif (VP)], [Faux négatif (FN)],
      [*Réel négatif*], [Faux positif (FP)], [Vrai négatif (VN)],
    )
  ]

  Les vrais positifs et les vrais négatifs sont les décisions correctes. Les
  faux négatifs sont des cas positifs manqués et les faux positifs sont des cas
  négatifs déclarés positifs à tort.
]

#definition-box(supplement: "Définition")[
  La *sensibilité* (_sensitivity_ ou _recall_) est la proportion des cas réellement positifs qui sont détectés:

  $ "Sensibilité" = "VP" / ("VP" + "FN"). $

  La *spécificité* (_specificity_) est la proportion des cas réellement négatifs qui sont correctement écartés:

  $ "Spécificité" = "VN" / ("VN" + "FP"). $
]

#definition-box(supplement: "Définition")[
  La *précision* (_precision_) est la proportion des prédictions positives qui correspondent effectivement à des cas positifs:

  $ "Précision" = "VP" / ("VP" + "FP"). $
]

La sensibilité et le rappel répondent à la question « parmi les cas positifs,
combien sont détectés? », tandis que la précision répond à la question « parmi
les cas déclarés positifs, combien le sont réellement? ». La spécificité porte
de la même façon sur les cas négatifs. Abaisser le seuil de décision augmente
généralement la sensibilité, mais produit davantage de faux positifs et réduit
donc la spécificité.

#example[
  *Détection de fraude.* Parmi 1 000 transactions, 20 sont frauduleuses. Un
  modèle détecte 16 de ces fraudes et en manque 4. Il signale aussi à tort 30
  transactions légitimes. On a donc $"VP"=16$, $"FN"=4$, $"FP"=30$ et
  $"VN"=950$. Ainsi,

  $ "Sensibilité"  = 16 / 20 = 80%, $
  $ "Spécificité" = 950 / 980 approx 96,9%, $
  $ "Précision" = 16 / 46 approx 34,8%. $

  Le modèle détecte une grande partie des fraudes et écarte correctement la
  plupart des transactions légitimes. Cependant, seulement environ un tiers de
  ses alertes correspondent à une fraude. Le déséquilibre des classes explique
  qu'une bonne spécificité puisse coexister avec une précision modeste.
]

#remark[
  La précision dépend de la fréquence de la classe positive dans la population.
  Il faut donc être prudent lorsqu'on la compare entre deux jeux de données dont
  les prévalences diffèrent. Pour un problème à plusieurs classes, on peut
  considérer chaque classe tour à tour comme positive, puis calculer une moyenne
  macro ou micro des mesures obtenues.
]

=== Coût des erreurs

Une mesure d'erreur doit refléter la décision visée. Une erreur de 10 dollars,
une erreur de diagnostic et une erreur d'affectation dans un groupe n'ont pas le
même sens. Il faut donc choisir une erreur compatible avec les conséquences
pratiques de l'analyse.

Dans certains problèmes, les erreurs sont asymétriques: un faux positif et un
faux négatif n'ont pas le même coût. Dans ce cas, le seuil de décision et la
mesure de performance doivent être discutés explicitement.

#example[
  *Dépistage médical.* Un faux négatif laisse repartir une personne malade sans
  suivi, tandis qu'un faux positif entraîne généralement un examen
  complémentaire. Si la première conséquence est beaucoup plus grave, on donne
  un coût supérieur aux faux négatifs et on choisit un seuil favorisant la
  sensibilité. Ce choix augmente souvent le nombre de faux positifs. Il s'agit cependant d'un compromis explicite, pas d'une erreur de calcul.
]

#example[
  *Détection de fraude.* Bloquer à tort une transaction légitime peut frustrer un client, mais laisser passer une fraude de 100 000 dollars peut coûter bien davantage. Une simple proportion d'erreurs attribue pourtant le même poids à ces deux situations. Une fonction de coût peut, par exemple, intégrer le montant de la transaction, le coût d'une vérification manuelle et la probabilité de perdre le client.
]

#example[
  *Gestion des stocks.* Sous-estimer la demande peut provoquer une rupture de
  stock et des ventes perdues. La surestimer occasionne des frais de stockage et
  parfois du gaspillage. Lorsque ces coûts sont différents, la meilleure
  prévision n'est pas nécessairement la moyenne conditionnelle. La perte doit
  pénaliser différemment les prévisions trop basses et trop élevées.
]

#example[
  *Prévision d'un temps de livraison.* Avec la MSE, une erreur exceptionnelle de deux heures compte beaucoup plus que plusieurs erreurs de quelques minutes. Cette propriété est souhaitable si les retards extrêmes ont de lourdes conséquences. Si l'on veut plutôt mesurer l'écart typique habituel, la MAE peut être plus pertinente.
]

=== Le compromis biais-variance

L'estimateur $hat(f)$ dépend de l'échantillon d'entraînement et est donc
aléatoire. Si l'on répétait la collecte des données, puis l'ajustement de la même
méthode, on obtiendrait généralement une prédiction différente au point $x_0$.
Le compromis biais-variance décrit ces variations et permet de comprendre
pourquoi la méthode qui ajuste le mieux les données d'entraînement n'est pas
toujours celle qui prédit le mieux de nouvelles observations.

Pour une nouvelle observation dont les covariables sont fixées à $x_0$, on
écrit $Y_0=f(x_0)+epsilon_0$. Les espérances et les variances ci-dessous portent
sur les échantillons d'entraînement possibles et sur le bruit de la nouvelle
observation.

#definition-box(supplement: "Définition")[
  La *prédiction moyenne* d'une méthode au point $x_0$ est

  $ m(x_0) = EE(hat(f)(x_0)). $

  Son *biais* mesure l'écart systématique entre cette prédiction moyenne et la
  vraie fonction:

  $ "Biais"(hat(f)(x_0)) = m(x_0) - f(x_0). $

  Sa *variance* mesure la dispersion des prédictions obtenues à partir de
  différents échantillons d'entraînement:

  $ "Var"(hat(f)(x_0)) = EE((hat(f)(x_0) - m(x_0))^2). $
]

Le biais peut être positif ou négatif, mais c'est son carré qui intervient dans
l'erreur quadratique. Une méthode peu biaisée n'est donc pas nécessairement une
bonne méthode: ses prédictions peuvent être centrées sur la bonne valeur tout en
étant extrêmement instables d'un échantillon à l'autre.

#property-box(supplement: "Propriété")[
  Sous les hypothèses $EE(epsilon_0)=0$, $"Var"(epsilon_0)=sigma^2$ et
  d'indépendance entre le bruit futur et l'échantillon d'entraînement,

  $ EE((Y_0-hat(f)(x_0))^2)
    = "Biais"(hat(f)(x_0))^2
    + "Var"(hat(f)(x_0))
    + sigma^2, $

  où
  $"Biais"(hat(f)(x_0))=EE(hat(f)(x_0))-f(x_0)$.
]

#proof(title: "Preuve")[
  Posons $m(x_0)=EE(hat(f)(x_0))$. En ajoutant et retranchant $m(x_0)$,

  $ Y_0-hat(f)(x_0)
    = (f(x_0)-m(x_0))
    + (m(x_0)-hat(f)(x_0))
    + epsilon_0. $

  Après élévation au carré et prise d'espérance, les termes croisés sont nuls:
  le deuxième terme est centré, $EE(epsilon_0)=0$, et le bruit futur est
  indépendant de l'estimateur. Il reste

  $ (f(x_0)-m(x_0))^2
    + EE((hat(f)(x_0)-m(x_0))^2)
    + EE(epsilon_0^2), $

  soit respectivement le biais au carré, la variance et $sigma^2$.
]

Cette identité est ponctuelle: le biais et la variance peuvent changer selon
$x_0$. En prenant ensuite la moyenne sur la distribution des nouvelles
covariables $X_0$, on obtient la même décomposition pour l'erreur quadratique
moyenne de généralisation.

Cette décomposition distingue trois sources d'erreur:

- le *biais au carré* traduit une erreur systématique d'approximation: la méthode
  est en moyenne éloignée de la relation réelle;
- la *variance* traduit une sensibilité à l'échantillon d'entraînement: de
  petites modifications des données produisent de grandes modifications de la
  prédiction;
- la *variance du bruit* $sigma^2$ est l'erreur irréductible avec les variables
  disponibles. Elle provient notamment de la variabilité naturelle, des erreurs
  de mesure et des variables explicatives absentes.

Le biais et la variance constituent la partie sur laquelle le choix de la
méthode peut agir. Leur combinaison permet de caractériser les situations
classiques suivantes:

#align(center)[
  #set text(size: 10.5pt)
  #set par(justify: false)
  #table(
    columns: (1.25fr, 0.8fr, 0.8fr, 1.8fr),
    align: (x, y) => if y == 0 or x < 3 { center } else { left },
    inset: 5pt,
    stroke: 0.5pt + rgb("#cfd8dc"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
    [*Situation*], [*Biais*], [*Variance*], [*Comportement*],
    [Sous-ajustement], [Élevé], [Faible], [Structure réelle non captée],
    [Compromis utile], [Modéré], [Modérée], [Bonne généralisation possible],
    [Sur-ajustement], [Faible], [Élevée], [Fluctuations de l'échantillon],
  )
]

#example[
  *Comparaison de trois méthodes.* Supposons qu'en un point $x_0$, la vraie
  valeur soit $f(x_0)=10$ et que $sigma^2=1$. Trois méthodes ont les
  caractéristiques suivantes:

  - méthode A: biais $=-2$ et variance $=0.25$;
  - méthode B: biais $=0$ et variance $=4$;
  - méthode C: biais $=-0.5$ et variance $=0.5$.

  Leurs erreurs quadratiques attendues valent respectivement
  $(-2)^2+0.25+1=5.25$, $0^2+4+1=5$ et $(-0.5)^2+0.5+1=1.75$. La méthode C est
  préférable même si son biais n'est pas nul. En effet, elle réalise un meilleur
  compromis entre biais et variance.
]

La flexibilité d'une méthode désigne la capacité d'une méthode à représenter des relations complexes. Lorsqu'elle augmente, le biais tend à diminuer, car la méthode peut mieux suivre la structure des données, tandis que la variance tend à augmenter, car elle peut aussi suivre leurs fluctuations accidentelles. Par exemple, une droite risque de manquer une relation fortement courbée; un polynôme de très grand degré peut au contraire épouser presque chaque observation, y compris le bruit.

L'erreur d'entraînement diminue généralement lorsque la flexibilité augmente.
L'erreur sur de nouvelles données suit plutôt une courbe en U. Elle diminue
d'abord grâce à la réduction du biais, atteint un minimum, puis augmente lorsque
la variance domine. Le niveau de flexibilité optimal minimise donc l'erreur de
généralisation, et non l'erreur d'entraînement.

#remark[
  Le biais statistique défini ici ne désigne ni un biais dans la collecte des
  données ni un biais social ou discriminatoire. Il s'agit précisément de
  l'écart entre la prédiction moyenne d'une méthode et la fonction réelle.
  Biais et variance sont des propriétés de la procédure d'apprentissage, pas
  seulement d'un modèle ajusté une seule fois.
]

En pratique, la fonction $f$ est inconnue. On ne peut donc pas calculer directement son biais et sa variance. La validation sur des observations qui n'ont pas servi à l'ajustement, notamment la validation croisée, permet d'estimer l'erreur de généralisation et de choisir indirectement un compromis raisonnable.

== La validation

=== Séparation des données

Évaluer un modèle sur les données qui ont servi à l'entraîner donne une vision trop optimiste. En effet, le modèle a déjà utilisé ces observations pour réduire son erreur. Pour estimer sa capacité de généralisation, il faut l'évaluer sur des observations qui n'ont participé ni à son ajustement ni aux décisions ayant conduit à sa sélection.

#definition-box(supplement: "Définition")[
  Une séparation classique produit trois ensembles disjoints:

  - l'ensemble d'*entraînement* (_training set_) sert à estimer les paramètres du modèle et les transformations nécessaires;
  - l'ensemble de *validation* (_validation set_) sert à comparer les méthodes, à choisir les hyper-paramètres et, le cas échéant, à régler un seuil de décision;
  - l'ensemble de *test* (_test set_) sert uniquement à estimer la performance finale de la procédure retenue.
]

La distinction entre paramètres et hyper-paramètres est importante. Les
coefficients d'une régression sont estimés automatiquement sur l'ensemble
d'entraînement. En revanche, le degré d'un polynôme, la profondeur maximale
d'un arbre ou la valeur d'un paramètre de régularisation sont des
hyper-paramètres choisis à l'aide de la validation.

Un protocole rigoureux suit généralement l'ordre suivant:

1. mettre de côté l'ensemble de test avant l'exploration guidant le modèle;
2. ajuster plusieurs procédures sur l'ensemble d'entraînement;
3. les comparer sur l'ensemble de validation ou par validation croisée;
4. réajuster la procédure choisie sur toutes les données autres que le test;
5. l'évaluer une seule fois sur l'ensemble de test.

Si le résultat obtenu sur le test conduit à modifier le modèle, ce jeu de
données a de fait servi à la validation. Il faut alors disposer de nouvelles
observations pour obtenir une évaluation finale honnête.

==== Choisir la règle de séparation

Une séparation aléatoire observation par observation convient lorsque les
observations sont indépendantes, issues de la même population et destinées à
représenter la même situation future. D'autres structures exigent une règle
adaptée:

- en classification déséquilibrée, une séparation stratifiée conserve
  approximativement la proportion de chaque classe dans les ensembles;
- lorsque plusieurs lignes décrivent une même personne, un même ménage ou un
  même appareil, toutes les lignes du groupe doivent rester dans le même
  ensemble;
- pour des données temporelles, l'entraînement doit précéder chronologiquement
  la validation et le test.

#example[
  *Dossiers médicaux répétés.* Une base contient plusieurs consultations par
  patient. Une séparation ligne par ligne peut placer les premières visites
  d'une personne dans l'entraînement et ses visites suivantes dans le test. Le
  modèle reconnaît alors indirectement le patient et la performance paraît trop
  bonne. Une séparation par patient mesure mieux la capacité à généraliser à de
  nouvelles personnes.
]

#example[
  *Prévision de la demande.* Pour prévoir les ventes de 2026, une séparation
  aléatoire pourrait utiliser des observations de 2026 pour entraîner un modèle
  évalué sur 2025. Cette information ne serait pas disponible au moment réel de
  la prévision. On entraîne plutôt sur les périodes anciennes, on valide sur une
  période plus récente et on réserve la dernière période pour le test.
]

==== Taille des ensembles

Des découpages comme 60 %--20 %--20 % ou 70 %--15 %--15 % constituent des points de départ, pas des règles universelles. Avec beaucoup de données, une petite proportion peut déjà fournir un test très précis. Avec peu de données, on conserve souvent 70 % ou 80 % des observations pour l'apprentissage et on remplace l'ensemble de validation unique par une validation croisée.

Le choix doit porter sur les effectifs réellement informatifs plutôt que sur les seuls pourcentages. Un test contenant 20% des observations peut rester inutilisable s'il ne contient que deux cas positifs ou un seul groupe. Il faut aussi conserver les indices de la séparation et fixer la graine aléatoire afin de rendre l'analyse reproductible.

Une séparation unique présente deux limites. D'abord, la performance mesurée
dépend des observations tirées pour la validation ou le test. Ensuite, réserver
des données réduit la taille de l'échantillon disponible pour l'apprentissage.
La validation croisée atténue la première difficulté et exploite plus
efficacement les données d'entraînement.

==== Prévenir les fuites de données

Les transformations apprises à partir des données font partie du modèle. La
standardisation, l'imputation, la sélection de variables, la réduction de
dimension et le suréchantillonnage doivent donc être ajustés sur l'entraînement
seulement, puis appliqués sans réajustement à la validation et au test. En
validation croisée, ces opérations doivent être réestimées à l'intérieur de
chaque pli.

#example[
  *Standardisation.* Pour centrer une variable, on calcule sa moyenne dans
  l'ensemble d'entraînement. Utiliser la moyenne de toute la base transmet au
  modèle une information sur la distribution du jeu de test, même si les
  valeurs de la réponse n'ont pas été utilisées.
]

#remark[
  On parle de *fuite de données* dès qu'une information indisponible au moment
  de la prédiction influence l'apprentissage ou le choix du modèle. La fuite
  peut venir du test, d'une date future, d'une observation du même individu ou
  d'une variable construite après l'événement à prédire. Le jeu de test ne doit
  être consulté qu'une fois tous les choix méthodologiques arrêtés.
]

=== Validation croisée

Une séparation unique entre entraînement et validation peut donner un résultat
très dépendant du hasard du découpage. La validation croisée réutilise les
données de développement plusieurs fois afin que chaque observation serve à la
validation, tout en étant prédite par un modèle qui ne l'a pas utilisée pour son
ajustement.

#definition-box(supplement: "Définition")[
  Dans une *validation croisée à $K$ plis*, les indices des observations sont
  répartis en $K$ ensembles disjoints $I_1, dots, I_K$. Pour le pli $k$, on
  ajuste un modèle $hat(f)^(-k)$ sur toutes les observations sauf celles de
  $I_k$, puis on calcule son erreur sur $I_k$.

  Si $n_k$ est la taille du pli et $L$ la fonction d'erreur, de coût ou de
  perte, l'erreur du pli est

  $ "Err"_k = 1 / n_k sum_(i in I_k) L(y_i, hat(f)^(-k)(x_i)). $

  L'estimation globale pondère chaque pli par son effectif:

  $ hat("Err")_("CV") = sum_(k=1)^K n_k / n "Err"_k. $

  Lorsque les plis ont la même taille, cette expression devient simplement
  $hat("Err")_("CV")=1/K sum_(k=1)^K "Err"_k$.
]

Le calcul suit quatre étapes:

1. construire les $K$ plis selon une règle compatible avec les données;
2. pour chaque pli, ajuster toute la procédure sur les $K-1$ autres plis;
3. prédire les observations du pli laissé de côté et calculer leur erreur;
4. regrouper les prédictions hors échantillon ou moyenner les erreurs des plis.

Les prédictions ainsi obtenues sont dites *hors pli* (_out-of-fold_). Chaque
observation possède une prédiction issue d'un modèle qui ne l'a pas vue pendant
l'entraînement. Elles permettent de calculer une mesure globale comme la MSE,
la MAE, le taux d'erreur ou l'aire sous une courbe ROC.

#example[
  *Validation à cinq plis.* Les taux d'erreur observés sur cinq plis sont 18 %,
  22 %, 20 %, 16 % et 24 %. Comme les plis ont la même taille, l'erreur de
  validation croisée vaut

  $ hat("Err")_("CV") = (18% + 22% + 20% + 16% + 24%) / 5 = 20%. $

  La variation de 16 % à 24 % indique aussi que l'évaluation dépend encore de la
  composition des plis. Rapporter seulement la moyenne masquerait cette
  instabilité.
]

==== Choisir le nombre de plis

Le nombre $K$ règle un compromis entre la quantité de données utilisée pour
chaque ajustement, la variabilité de l'estimation et le coût de calcul.

#align(center)[
  #set text(size: 10.5pt)
  #set par(justify: false)
  #table(
    columns: (0.8fr, 1.5fr, 2fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    inset: 5pt,
    stroke: 0.5pt + rgb("#cfd8dc"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
    [*$K$*], [*Avantage principal*], [*Limite principale*],
    [5], [Calcul relativement rapide], [Entraînement sur 80 % des données],
    [10], [Bon compromis général], [Deux fois plus d'ajustements qu'à cinq plis],
    [$n$], [Entraînement sur $n-1$ observations], [Calcul coûteux et erreurs fortement corrélées],
  )
]

Les choix $K=5$ et $K=10$ sont courants, mais ne sont pas universels. Le cas
$K=n$, appelé validation *leave-one-out*, entraîne un modèle pour chaque
observation. Son biais d'évaluation est souvent faible puisque presque toutes
les données servent à chaque ajustement, mais son coût est élevé et sa variance
peut l'être aussi, car les ensembles d'entraînement se ressemblent fortement.

La *validation croisée répétée* recommence un découpage à cinq ou dix plis avec
plusieurs graines aléatoires, puis moyenne les résultats. Elle réduit la
dépendance envers une seule partition au prix d'un nombre plus élevé
d'ajustements. Par exemple, une validation à cinq plis répétée dix fois exige 50
ajustements pour chaque configuration du modèle.

==== Comparer et régler les modèles

Pour choisir un hyper-paramètre, on applique exactement les mêmes plis à chaque
valeur candidate. On compare alors des erreurs obtenues sur les mêmes
observations, ce qui rend la comparaison moins sensible au hasard du découpage.

#example[
  *Degré d'un polynôme.* On compare les degrés de 1 à 10 avec les mêmes cinq
  plis. Pour chaque degré, cinq modèles sont ajustés et leurs erreurs sont
  moyennées. On choisit le degré dont l'erreur moyenne est la plus faible, ou un
  degré plus simple dont l'erreur reste très proche du minimum. La procédure
  choisie est ensuite réajustée sur toutes les données de développement.
]

La standardisation, l'imputation, la sélection de variables et toute autre
transformation apprise doivent être répétées dans chaque boucle: elles sont
ajustées sur les $K-1$ plis d'entraînement, puis appliquées au pli de validation.
Effectuer ces transformations une seule fois avant la validation croisée crée
une fuite de données.

==== Adapter les plis aux observations

Les plis doivent reproduire la situation dans laquelle le modèle sera utilisé:

- des plis *stratifiés* préservent la proportion des classes;
- des plis *groupés* gardent ensemble toutes les observations d'une même unité;
- des plis *temporels* utilisent uniquement le passé pour prédire une période
  ultérieure;
- des plis par site ou par région mesurent la capacité de transfert à une
  nouvelle source de données.

Une validation croisée aléatoire ordinaire suppose implicitement que les
observations sont échangeables. Elle n'est donc pas adaptée telle quelle aux
séries temporelles, aux données spatiales autocorrélées ou aux mesures répétées
sur les mêmes individus.

#remark[
  Utiliser la même validation croisée pour choisir un modèle et annoncer sa
  performance finale produit une estimation optimiste. La *validation croisée
  imbriquée* emploie une boucle intérieure pour régler les hyper-paramètres et
  une boucle extérieure pour évaluer toute la procédure de sélection. Lorsqu'un
  jeu de test indépendant a été réservé dès le départ, celui-ci joue plutôt le
  rôle d'évaluation finale et ne doit être consulté qu'après la sélection.
]

Il est utile de rapporter la moyenne des erreurs, leur dispersion entre les
plis et les effectifs concernés. Toutefois, les erreurs des plis ne sont pas
indépendantes puisque leurs ensembles d'entraînement se chevauchent. Leur
écart-type décrit la stabilité observée, mais ne constitue pas automatiquement
un intervalle de confiance valide pour la performance future.

=== Interpréter la validation

Une bonne performance de validation ne suffit pas. Il faut aussi vérifier que le
protocole correspond à la situation future: mêmes sources de données, même
période, mêmes règles de collecte et mêmes contraintes opérationnelles.

Une validation temporelle, par groupe ou par source peut être nécessaire lorsque
les observations ne sont pas échangeables. Par exemple, entraîner sur des données
futures pour prédire le passé rendrait l'évaluation artificiellement optimiste.

- Pour des séries temporelles, on respecte l'ordre chronologique.
- Pour plusieurs mesures d'une même personne, on place toutes ses mesures dans
  le même pli.
- Pour des données provenant de sites différents, on peut valider par site afin
  d'évaluer le transport du modèle.
- Pour une classification déséquilibrée, on stratifie si possible les plis afin
  de préserver les proportions de classes.
