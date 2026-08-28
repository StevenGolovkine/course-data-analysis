#import "../styles/notes.typ": definition-box, example, remark

= Introduction

== Qu'est-ce que l'analyse de données ?

L'analyse de données regroupe les méthodes qui permettent d'extraire de l'information d'un jeu de données. Elle est proche de ce que l'on appelle apprentissage statistique ou apprentissage automatique (_machine learning_): on observe des variables, on cherche des structures dans ces observations, puis on produit une interprétation, une visualisation, une prédiction ou une décision.

Le point de départ n'est donc pas un algorithme, mais une question. Un même jeu de données peut servir à décrire une population, à comparer des groupes, à prévoir une quantité future, à détecter des observations atypiques ou à construire une typologie. La méthode pertinente dépend de cette question, du type des variables et de la qualité des données.

#remark[
  Une analyse de données est une démarche itérative: formuler une question,
  comprendre les données, choisir une représentation, ajuster ou appliquer une
  méthode, évaluer le résultat, puis revenir aux étapes précédentes si les
  diagnostics l'exigent.
]


#definition-box(supplement: "Définition")[
  L'*unité statistique* est l'objet élémentaire étudié. Cela peut être, par exemple, une personne, un pays, une transaction, une image ou encore une journée. Une *observation* rassemble les valeurs mesurées sur une unité statistique, tandis qu'une *variable* décrit une caractéristique commune à toutes les unités.
]

Lorsque $n$ unités sont décrites par $p$ variables, les données numériques
peuvent être rassemblées dans une matrice

$ X = (x_(i j))_(1 <= i <= n, 1 <= j <= p) in RR^(n times p). $

La ligne $i$ représente l'observation $x_i$ et la colonne $j$, la variable
$X_j$. Cette convention n'est pas qu'une notation. En effet, elle détermine ce que
mesurent une moyenne, une covariance ou une distance. Une mauvaise définition
de l'unité statistique peut ainsi produire une analyse mathématiquement correcte
mais scientifiquement dépourvue de sens.

Les variables peuvent être quantitatives, ordinales, nominales ou binaires.
Leur nature guide les résumés, les graphiques et les méthodes admissibles. Par
exemple, calculer une moyenne sur des codes postaux ou une distance euclidienne
entre des catégories arbitrairement numérotées n'a généralement pas de sens.

#example[
  On souhaite étudier l'espérance de vie dans les pays membres de l'ONU. Pour
  chaque pays, on dispose de l'espérance de vie, du PIB par habitant, des
  dépenses de santé, du taux de fertilité, du taux d'urbanisation et du niveau
  d'éducation. Une analyse peut chercher à visualiser les relations entre ces
  variables, à comprendre quels facteurs sont associés à l'espérance de vie, ou
  encore à prédire l'espérance de vie à partir des autres variables.
]

Cet exemple illustre plusieurs difficultés typiques. Les variables n'ont pas la
même échelle, elles ne jouent pas toutes le même rôle, certaines peuvent être
fortement corrélées, et l'interprétation causale demande beaucoup plus qu'un bon
ajustement numérique.

À partir du même jeu de données, on peut donc poser des questions très différentes:

- quelle est la distribution de l'espérance de vie entre les pays?
- quels pays présentent des profils socioéconomiques similaires?
- peut-on résumer les indicateurs par quelques dimensions synthétiques?
- quelle espérance de vie prévoit-on pour un pays dont les indicateurs sont
  connus?
- une augmentation des dépenses de santé causerait-elle une hausse de
  l'espérance de vie?

Les quatre premières questions relèvent de la description, de l'exploration ou
de la prédiction. La dernière est causale: des données observationnelles et un
bon modèle prédictif ne suffisent généralement pas à y répondre.

Ainsi, une analyse peut viser plusieurs types de résultats.

- Une question descriptive cherche à résumer ce qui est observé.
- Une question exploratoire cherche à découvrir une structure, une relation ou
  une typologie.
- Une question prédictive cherche à estimer une réponse pour de nouvelles
  observations.
- Une question causale cherche à prévoir ce qui changerait à la suite d'une
  intervention.

Ces objectifs peuvent coexister, mais il faut savoir lequel guide la méthode. Décrire une association, prédire une valeur et expliquer un mécanisme causal ne demandent pas les mêmes hypothèses. En particulier, une variable peut améliorer une prédiction sans être la cause de la réponse, et inversement une cause réelle peut être un mauvais prédicteur lorsqu'elle varie peu dans les données observées.

Aussi, une méthode peut être récente, sophistiquée et numériquement performante sans répondre à la question posée. La qualité d'une analyse dépend de la cohérence entre la question, les données, la méthode et le critère d'évaluation.



== L'apprentissage supervisé

=== Principe

Dans un problème supervisé, une variable réponse est observée dans les données d'apprentissage. On veut apprendre une relation entre des variables explicatives et cette variable réponse.

#definition-box(supplement: "Définition")[
  Un problème d'*apprentissage supervisé* est décrit par un échantillon
  d'apprentissage composé de couples $(x_i, y_i)$, pour $i = 1, dots, n$.
  Le vecteur $x_i in RR^p$ contient les variables explicatives de l'observation
  $i$, et $y_i$ sa réponse. L'objectif est de construire une règle $hat(f)$ qui
  prédit la réponse d'une nouvelle observation $x$.
]

On peut écrire l'objectif de manière générale:

$ Y = f(X) + epsilon $

La fonction $f$ représente la relation systématique entre les variables explicatives $X$ et la réponse $Y$. Le terme $epsilon$ représente le bruit, les variables absentes et la variabilité qui n'est pas expliquée par le modèle. À partir d'un échantillon fini, on ne connaît pas $f$. On cherche donc à estimer une fonction $hat(f)$ dont il faudra mesurer les performances sur des données nouvelles.

=== Régression et classification

En régression, la réponse est numérique: prix, température, durée, revenu ou encore score. La qualité du modèle se mesure souvent par une erreur de prédiction, comme l'erreur quadratique moyenne ou l'erreur absolue moyenne.

En classification, la réponse est une classe: fraude ou non, réussite ou échec,
type de document, diagnostic ou catégorie de risque. La qualité du modèle dépend
de la proportion d'erreurs, mais aussi du type d'erreur commise.

Le choix du critère d'adéquation du modèle dépend donc de l'usage du modèle. En régression, l'erreur quadratique moyenne pénalise fortement les grandes erreurs, tandis que l'erreur absolue moyenne y est moins sensible. En classification, l'exactitude globale peut être trompeuse lorsque les classes sont déséquilibrées. La sensibilité, la spécificité, la précision ou le rappel peuvent alors être plus informatifs.

#example[
  Prédire si un courriel est indésirable à partir de son contenu est un problème supervisé de classification : les exemples d'entraînement portent une étiquette (indésirable ou non). Prédire le prix d'un logement à partir de ses caractéristiques est aussi supervisé, mais de régression car la réponse est quantitative.
]

=== Généraliser

Un modèle supervisé n'est pas jugé sur sa capacité à mémoriser les données d'apprentissage. Il doit en effet être capable de généraliser à de nouvelles observations. C'est pourquoi on doit séparer les données en ensembles d'entraînement, de validation et de test, ou alors utiliser la validation croisée.

Les rôles de ces ensembles de données doivent rester distincts:

- l'ensemble d'entraînement (_training set_) sert à estimer les paramètres du modèle;
- l'ensemble de validation (_validation set_) ou la validation croisée (_cross-validation_) sert à choisir la méthode, ses hyperparamètres et les transformations;
- l'ensemble de test (_test set_) sert une seule fois à estimer la performance finale.

Un *sous-ajustement* survient lorsqu'un modèle trop rigide ne capture pas une structure importante. À l'inverse, un *sur-ajustement* survient lorsqu'un modèle trop flexible apprend les particularités de l'échantillon d'entraînement au lieu d'une relation stable. La meilleure performance d'entraînement n'est donc généralement pas un bon critère de sélection.

#remark[
  Toutes les opérations qui apprennent quelque chose des données —
  standardisation, sélection de variables, imputation ou réduction de dimension
  — doivent être ajustées uniquement sur les données d'entraînement. Les
  effectuer avant la séparation crée une *fuite d'information* (_data leakage_) et donne une évaluation trop optimiste.
]

== L'apprentissage non-supervisé

=== Principe

Dans un problème non supervisé, il n'y a pas de variable réponse. On cherche
plutôt à découvrir une structure dans les observations: axes de variation,
groupes, proximités entre modalités ou représentations de plus faible dimension.

#definition-box(supplement: "Définition")[
  Un problème d'*apprentissage non supervisé* est décrit par des observations
  $x_1, dots, x_n$, sans réponse $y_i$ désignée. L'objectif est de construire une
  représentation qui révèle certaines régularités du jeu de données.
]

Les méthodes non supervisées servent souvent à explorer les données avant une
modélisation plus ciblée. Elles peuvent révéler des groupes, des observations
atypiques, des variables redondantes ou des relations inattendues.

=== Réduction de dimension

La réduction de dimension a pour but de remplacer un grand nombre de variables par une représentation synthétique. L'objectif est de visualiser, résumer ou préparer les données pour une autre méthode. Les méthodes factorielles sont un exemple de réduction de dimension.

L'analyse en composantes principales (ACP), l'analyse factorielle des correspondances (AFC) et l'analyse des correspondances multiples (ACM) sont des exemples de méthodes factorielles. Elles ne répondent pas à une question prédictive directe. Elles aident plutôt à comprendre la structure des données. La propriété préservée dépend de la méthode: l'ACP privilégie la variabilité des variables quantitatives, l'AFC étudie les profils d'un tableau de contingence et l'ACM décrit les associations entre variables qualitatives.

Une représentation en deux dimensions reste une approximation. Il faut examiner la quantité d'information conservée et éviter d'interpréter une proximité ou une séparation qui serait mal représentée sur les axes affichés.

=== Regroupement

Le regroupement (_clustering_) cherche à construire des groupes
d'observations similaires. Les $k$-means, la classification hiérarchique et les
mélanges de gaussiennes illustrent différentes manières de définir un groupe:
proximité à un centre, hiérarchie de distances ou appartenance probabiliste.

Le résultat dépend de la représentation, de l'échelle des variables, de la
mesure de dissimilarité et, souvent, du nombre de groupes demandé. Une variable
mesurée en milliers peut dominer une variable comprise entre zéro et un si les
données ne sont pas standardisées. Le prétraitement fait donc partie intégrante
de la méthode de regroupement.

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

On peut combiner trois formes de validation:

- un critère *interne*, calculé à partir de la géométrie des données;
- un critère *externe*, fondé sur une information qui n'a pas servi à construire
  la représentation;
- une analyse de *stabilité*, qui vérifie si le résultat persiste lorsque
  l'échantillon, les paramètres ou les variables changent légèrement.

#remark[
  En apprentissage non supervisé, plusieurs solutions peuvent être défendables.
  L'objectif n'est pas de découvrir une partition nécessairement « vraie », mais
  de produire une représentation utile, stable et interprétable pour la question
  étudiée.
]

=== Comparer les deux cadres

#table(
  columns: (1.15fr, 1.4fr, 1.4fr),
  inset: 6pt,
  align: left,
  table.header(
    [*Élément*],
    [*Supervisé*],
    [*Non supervisé*],
  ),
  [Données], [Couples $(x_i, y_i)$], [Observations $x_i$],
  [But], [Prédire une réponse], [Décrire une structure],
  [Exemples], [Régression, classification], [ACP, regroupement],
  [Validation], [Erreur sur des données nouvelles],
    [Inertie, séparation, stabilité, interprétation],
)

La frontière n'est pas toujours absolue. Une réduction de dimension peut servir
de prétraitement à une classification, et une étiquette externe peut aider à
interpréter des groupes sans avoir servi à les construire. Il faut néanmoins
identifier clairement quelle information a été utilisée à chaque étape.

== La modélisation

=== Une démarche complète

Une analyse ne commence pas par l'ajustement d'un modèle et ne se termine pas
par l'obtention d'un score. Une démarche complète comporte généralement les
étapes suivantes:

1. *Formuler la question.* Définir la population, l'unité statistique, le
   résultat attendu et l'usage qui en sera fait.
2. *Comprendre la collecte.* Documenter la provenance des données, la méthode
   d'échantillonnage, les dates, les unités et les biais possibles.
3. *Préparer et explorer.* Corriger les incohérences de manière reproductible,
   étudier les valeurs manquantes et visualiser les distributions.
4. *Choisir une représentation.* Sélectionner, transformer ou standardiser les
   variables selon la géométrie pertinente pour le problème.
5. *Ajuster une ou plusieurs méthodes.* Estimer leurs paramètres et choisir
   leurs hyperparamètres sans consulter les données de test.
6. *Valider.* Mesurer la performance, la stabilité et la sensibilité aux choix
   effectués; comparer à une méthode de référence simple.
7. *Interpréter et communiquer.* Relier le résultat à la question, quantifier
   l'incertitude, expliciter les limites et rendre l'analyse reproductible.

Ces étapes forment une boucle. Un diagnostic peut conduire à reformuler la
question, à revoir une variable ou à collecter de nouvelles données. Cette
itération est normale à condition que les décisions soient documentées et que
l'évaluation finale demeure honnête.

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

Un *paramètre* est estimé à partir des données d'entraînement, comme un
coefficient de régression ou le centre d'un groupe. Un *hyperparamètre* contrôle
la méthode avant cet ajustement, comme le nombre de groupes ou la force d'une
régularisation. Cette distinction explique pourquoi les hyperparamètres doivent
être choisis par validation plutôt qu'en regardant la performance de test.

=== Interprétation et limites

L'analyse de données ne consiste pas à appliquer mécaniquement une recette. Les
données reflètent un contexte de collecte, des choix de mesure, des omissions et
des biais possibles. Un résultat convaincant doit donc être accompagné de ses
conditions de validité: quelles hypothèses ont été faites, quelles données ont
été exclues, quelle incertitude demeure, et quelle décision sera prise à partir
du résultat.

Dans #link("https://doi.org/10.1201/9780429029608")[*Statistical Rethinking*],
Richard McElreath met en garde contre les conseils statistiques trop généraux:
une recette fondée sur quelques caractéristiques superficielles du problème ne
peut pas remplacer la connaissance scientifique du contexte. Autrement dit, la
personne qui analyse les données doit justifier ses choix au lieu d'invoquer une
méthode comme une autorité automatique.

Le dessin #link("https://xkcd.com/1838/")[« Machine Learning » de xkcd] illustre
avec humour le même danger: une procédure complexe peut sembler mystérieuse si
l'on ne comprend ni ses entrées, ni son mécanisme, ni la manière dont son résultat
a été évalué.

#remark[
  Il n'existe pas de méthode universellement meilleure. Une méthode excellente
  sur un problème peut être mauvaise sur un autre. La compétence centrale est de
  relier la question, les données, la méthode et l'interprétation.
]

=== Une analyse responsable

La performance moyenne ne résume pas toutes les conséquences d'un modèle. Avant
un déploiement, il faut aussi examiner:

- qui est représenté dans les données et qui ne l'est pas;
- si les erreurs touchent certains groupes plus souvent ou plus gravement;
- si les variables utilisées constituent des mesures valides du phénomène;
- si la décision peut être expliquée, contestée ou corrigée;
- si la collecte, le partage et la conservation respectent la confidentialité;
- si les conditions futures ressemblent suffisamment aux données
  d'apprentissage.

Une association découverte dans un échantillon peut résulter d'un biais de
sélection, d'une variable confondante ou d'une mesure imparfaite. La prudence ne
consiste pas à refuser toute conclusion, mais à formuler une conclusion dont la
force correspond réellement à l'information disponible.

#heading(level: 2, outlined: false)[Questions rapides]

1. Donnez, à partir d'un même jeu de données, un exemple de question descriptive,
   exploratoire, prédictive et causale.
2. Pour un jeu de données de votre choix, identifiez l'unité statistique, le
   nombre $n$ d'observations et le nombre $p$ de variables.
3. Expliquez pourquoi une corrélation observée ne suffit pas à conclure à une
   relation causale.
4. Classez les problèmes suivants comme régression, classification ou
   apprentissage non supervisé: prédire un revenu, détecter une fraude et
   construire des profils de consommation.
5. Pourquoi la performance sur les données d'entraînement ne permet-elle pas de
   juger la généralisation d'un modèle?
6. Donnez un exemple de fuite d'information entre les données d'entraînement et
   de test.
7. Pourquoi l'apprentissage non supervisé est-il plus difficile à évaluer qu'une
   classification supervisée?
8. Donnez un exemple de transformation ou de mesure de distance qui pourrait
   changer le résultat d'une analyse.
9. Une analyse sans modèle probabiliste explicite est-elle pour autant sans
   hypothèses? Justifiez.
10. Citez deux limites qui devraient accompagner la communication d'un résultat
    prédictif.
