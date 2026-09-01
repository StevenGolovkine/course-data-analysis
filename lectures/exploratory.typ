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

Pour des variables qualitatives, les distances numériques habituelles n'ont pas
toujours de sens. On peut utiliser un encodage un-parmi-$K$ pour représenter une
variable à $K$ modalités par un vecteur binaire. Cela évite d'introduire un
ordre artificiel.

#example[
  Pour $cal(X)={"rouge", "vert", "bleu"}$, l'encodage un-parmi-$K$ associe
  $(1,0,0)$ au rouge, $(0,1,0)$ au vert et $(0,0,1)$ au bleu. Toutes les
  modalités restent alors à la même distance les unes des autres.
]

#definition-box(supplement: "Définition")[
  Pour deux vecteurs qualitatifs $x,y in cal(X)^p$, la *distance de Hamming* est

  $ d_H(x,y) = sum_(j=1)^p 1_(x_j != y_j). $

  Elle compte le nombre de désaccords. La proportion d'accords
  $s(x,y)=p^(-1) sum_j 1_(x_j=y_j)$ fournit une similarité comprise entre
  $0$ et $1$.
]

#example[
  Si Alice et Bob diffèrent par la couleur et les cheveux, mais partagent la
  même couleur des yeux, alors $d_H("Alice","Bob")=2$ sur trois variables et
  leur proportion d'accords vaut $1/3$.
]

Pour des variables binaires rares ou asymétriques, les doubles absences sont
souvent peu informatives. On définit $M_11$ comme le nombre de présences
communes, $M_10$ et $M_01$ comme les désaccords, et $M_00$ comme le nombre de
doubles absences. L'indice de Jaccard se concentre sur les présences:

$ J = M_11 / (M_11 + M_10 + M_01) $

La distance associée est $d_J=1-J$. Pour deux questionnaires binaires
$x=(1,0,1,0,0)$ et $y=(1,0,0,1,0)$, on a $M_11=1$, $M_10=M_01=1$ et
$M_00=2$, donc $J=1/3$ et $d_J=2/3$.

=== Choisir une distance

Choisir une distance revient à choisir ce que signifie "se ressembler". Deux
observations peuvent être proches selon leurs valeurs numériques, leurs
catégories, leurs trajectoires temporelles ou leurs voisins dans un graphe. La
distance doit donc être reliée à la question d'analyse.

#note[
  Une distance n'est jamais un détail technique. Elle peut changer les groupes
  obtenus, les voisins les plus proches, les axes de réduction de dimension et
  l'interprétation des résultats. Son choix doit être justifié par le sens des
  variables, leur échelle et le coût réel des différences.
]

== Le calcul de l'erreur

=== Modèle prédictif

Une écriture générale pour les modèles prédictifs est:

$ Y = f(X) + epsilon $

La fonction $f$ représente l'information systématique que les variables
explicatives apportent sur la réponse. Le terme $epsilon$ représente la part non
expliquée, liée au bruit, aux variables absentes et à la variabilité naturelle.
Dans le cadre de la régression, on suppose généralement

$ EE(epsilon)=0, quad "Var"(epsilon)=sigma^2, quad epsilon " indépendant de " X. $

L'objectif est d'estimer $f$ à partir d'un échantillon. La question centrale
devient alors: comment savoir si l'estimateur est bon ?

#example[
  En régression linéaire simple, on impose $f(x)=a x+b$. Estimer la fonction
  revient alors à estimer $a$ et $b$. Une méthode plus flexible autorise un plus
  grand ensemble de fonctions possibles.
]

#remark[
  Exactitude et interprétabilité peuvent entrer en tension. Une règle simple est
  facile à expliquer, mais peut manquer une relation complexe; une méthode très
  flexible peut mieux prédire tout en étant plus difficile à justifier. Il
  n'existe pas de méthode universellement optimale: le modèle doit être adapté à
  la question, aux données et au coût des erreurs.
]

=== Mesures d'erreur en régression

#definition-box(supplement: "Définition")[
  Pour une réponse quantitative, l'*erreur quadratique moyenne* est

  $ "MSE" = (1 / n) sum_(i=1)^n (y_i - hat(y)_i)^2, $

  où $hat(y)_i=hat(f)(x_i)$ est la prédiction pour l'observation $i$.
]

On peut aussi utiliser l'erreur absolue moyenne, plus robuste aux grandes erreurs:

$ "MAE" = (1 / n) sum_(i=1)^n |y_i - hat(y)_i| $

Le choix entre MSE et MAE dépend du problème. La MSE pénalise fortement les
grosses erreurs; la MAE mesure une erreur typique plus directement lisible.

=== Mesures d'erreur en classification

#definition-box(supplement: "Définition")[
  Pour une réponse qualitative, le *taux d'erreur* est

  $ "ER" = (1 / n) sum_(i=1)^n 1_(y_i != hat(y)_i). $

  Il mesure la proportion de mauvaises classifications.
]

Lorsque les classes sont déséquilibrées, le taux d'erreur global peut être
trompeur. Il faut alors regarder la matrice de confusion, la sensibilité, la
spécificité, la précision, le rappel ou d'autres mesures adaptées au coût des
erreurs.

#example[
  Si 98 pour cent des transactions ne sont pas frauduleuses, un modèle qui prédit
  toujours "non frauduleux" a 98 pour cent d'exactitude, mais il ne détecte
  aucune fraude.
]

=== Coût des erreurs

Une mesure d'erreur doit refléter la décision visée. Une erreur de 10 dollars,
une erreur de diagnostic et une erreur d'affectation dans un groupe n'ont pas le
même sens. Il faut donc choisir une perte compatible avec les conséquences
pratiques de l'analyse.

Dans certains problèmes, les erreurs sont asymétriques: un faux positif et un
faux négatif n'ont pas le même coût. Dans ce cas, le seuil de décision et la
mesure de performance doivent être discutés explicitement.

=== Le compromis biais-variance

L'estimateur $hat(f)$ dépend de l'échantillon d'entraînement et est donc
aléatoire. Pour une nouvelle observation de covariable fixée $x_0$, on écrit
$Y_0=f(x_0)+epsilon_0$. L'erreur quadratique attendue ne dépend pas seulement de
l'ajustement observé sur un échantillon particulier.

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

La variance du bruit $sigma^2$ est *irréductible* avec les variables disponibles.
Le biais et la variance constituent la partie sur laquelle le choix de la
méthode peut agir:

- un modèle rigide varie peu entre les échantillons, mais peut avoir un biais
  élevé;
- un modèle flexible peut réduire le biais, mais réagir fortement aux
  fluctuations de l'échantillon;
- l'erreur de prédiction suit souvent une courbe en U en fonction de la
  flexibilité.

#note[
  Un modèle qui interpole toutes les observations peut avoir une erreur
  d'entraînement nulle sans bien prédire. À l'opposé, prédire toujours la même
  constante produit peu de variance, mais généralement beaucoup de biais.
]

== La validation

=== Sur-ajustement et sous-ajustement

Un modèle très simple peut sous-ajuster les données: il a un biais élevé et ne
capture pas la structure réelle. Un modèle très flexible peut surajuster les
données d'apprentissage: il a une variance élevée et réagit fortement aux
fluctuations de l'échantillon.

#remark[
  Le sous-ajustement apparaît souvent dans les erreurs d'entraînement et de
  validation. Le sur-ajustement se reconnaît plutôt à un écart croissant entre
  une faible erreur d'entraînement et une erreur de validation plus élevée.
]

=== Séparation des données

Évaluer un modèle sur les données qui ont servi à l'entraîner donne une vision
trop optimiste. On sépare donc les données en ensembles d'entraînement, de
validation et de test.

- L'ensemble d'entraînement sert à ajuster les modèles.
- L'ensemble de validation sert à choisir les hyper-paramètres ou à comparer des
  variantes.
- L'ensemble de test sert à estimer la performance finale.

Avec beaucoup d'observations, une division équilibrée peut suffire. Avec un
échantillon plus petit, on conserve souvent 70 % ou 80 % des observations pour
l'entraînement. Ces proportions sont des points de départ: la dépendance entre
observations, la rareté de certaines classes et la précision recherchée comptent
davantage qu'une règle fixe.

Une unique séparation présente deux limites. D'abord, le résultat dépend du
tirage aléatoire des observations de validation. Ensuite, réserver des données
réduit la taille de l'échantillon utilisé pour ajuster le modèle.

Les transformations apprises à partir des données, comme la standardisation,
l'imputation ou la sélection de variables, doivent être ajustées sur
l'entraînement seulement, puis appliquées aux autres ensembles.

#note[
  On parle de *fuite de données* lorsqu'une information du jeu de validation ou
  de test influence l'apprentissage. Choisir les variables, imputer, réduire ou
  régler les hyper-paramètres avant la séparation rend l'évaluation trop
  optimiste. Le jeu de test final ne devrait être consulté qu'après tous les
  choix méthodologiques.
]

=== Validation croisée

Dans une validation croisée à $K$ plis, les observations sont divisées en $K$
sous-ensembles. On entraîne le modèle sur $K - 1$ plis et on l'évalue sur le pli
restant. On répète l'opération pour chaque pli puis on moyenne les erreurs.

Si $"Err"_k$ désigne l'erreur sur le pli $k$, l'estimation par validation
croisée est

$ hat("Err")_("CV") = (1/K) sum_(k=1)^K "Err"_k. $

En pratique, $K = 5$ ou $K = 10$ est un compromis courant entre stabilité et coût
de calcul. Chaque modèle est alors ajusté $K$ fois. Le cas $K = n$ correspond à
la validation *leave-one-out*: son biais est faible puisque l'entraînement
utilise $n-1$ observations, mais les ensembles d'entraînement se ressemblent
beaucoup et les erreurs obtenues peuvent être fortement corrélées. Cela peut
augmenter la variance de l'estimation tout en coûtant cher.

#remark[
  La validation croisée sert à comparer les modèles et à régler leurs
  hyper-paramètres. Après avoir choisi la méthode, on la réajuste généralement
  sur toutes les données d'entraînement disponibles avant l'évaluation finale
  sur le jeu de test.
]

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

=== À retenir

- Une analyse commence par une question précise.
- Les choix d'unité statistique, de type de variables et de distance structurent
  toute la suite.
- Les données doivent être inspectées avant la modélisation.
- Une mesure d'erreur doit refléter la décision visée.
- Le compromis biais-variance explique pourquoi la meilleure erreur
  d'entraînement n'est pas nécessairement la meilleure erreur future.
- Un modèle doit être évalué sur des données non utilisées pour l'ajustement.
- Toutes les transformations apprises doivent être incluses dans le protocole de
  validation pour éviter les fuites de données.
- L'interprétation dépend autant du contexte que de la performance numérique.
- Après le déploiement, les données et la performance doivent être surveillées.

#heading(level: 2, outlined: false)[Ressources]

Ce chapitre reprend et développe le module
#link("https://stt2200.netlify.app/contents/03-generalities")[Généralités] et ses
pages consacrées au
#link("https://stt2200.netlify.app/contents/generalities/01-stat")[projet
d'analyse de données], aux
#link("https://stt2200.netlify.app/contents/generalities/02-spaces")[espaces
d'observation], aux
#link("https://stt2200.netlify.app/contents/generalities/03-distance")[distances],
au #link("https://stt2200.netlify.app/contents/generalities/04-bias-variance")[compromis
biais-variance] et à
#link("https://stt2200.netlify.app/contents/generalities/05-model-evaluation")[l'évaluation
des modèles].

#heading(level: 2, outlined: false)[Exercices]

1. Choisissez un jeu de données et identifiez l'unité statistique, cinq
   variables et leur type.
2. Donnez deux exemples où la distance euclidienne brute serait trompeuse.
3. Expliquez la différence entre sur-ajustement et sous-ajustement.
4. Décrivez une stratégie de validation pour choisir entre trois modèles.
5. Pourquoi le taux d'erreur peut-il être trompeur avec des classes
   déséquilibrées ?
6. Donnez un exemple où la validation croisée ordinaire ne serait pas adaptée.
7. Calculez les distances de Hamming et de Jaccard entre
   $x=(1,0,1,1,0)$ et $y=(1,1,0,1,0)$.
8. Montrez sur un exemple numérique qu'un codage rouge $=1$, vert $=2$ et bleu
   $=3$ impose une géométrie artificielle.
9. Pour un modèle très rigide puis un modèle très flexible, décrivez
   qualitativement l'évolution du biais et de la variance.
10. Donnez trois exemples de fuite de données et expliquez comment les éviter
    dans une validation croisée.
