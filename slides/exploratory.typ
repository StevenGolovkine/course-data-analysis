#import "../styles/slides.typ": *

#show : course-slides.with(title: [Analyse exploratoire])

#title-slide()

== Plan du cours

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([1 · Question], [
    Objectif, population, unité et décision.
  ], height: 1.5in),
  card([2 · Données], [
    Qualité, provenance et représentation.
  ], fill: pale-blue, height: 1.5in),
  card([3 · Distance], [
    Traduire ce que signifie « se ressembler ».
  ], fill: pale-purple, height: 1.5in),
)

#v(0.65em)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.65em,
  card([4 · Erreur], [
    Mesurer et refléter la qualité et le coût des décisions.
  ], fill: pale-orange, height: 1.5in),
  card([5 · Validation], [
    Estimer la performance sur de nouvelles observations.
  ], fill: pale-red, height: 1.5in),
)


= De la question à la méthode

== L'exploration prépare une décision

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 0.28em,
  align: horizon,
  card([1 · Définir l'objectif], [], height: 0.95in, title-size: 17pt),
  text(size: 19pt, fill: accent)[→],
  card([2 · Collecter et préparer], [], fill: pale-blue, height: 0.95in, title-size: 17pt),
  text(size: 19pt, fill: accent)[→],
  card([3 · Élaborer et valider], [], fill: pale-purple, height: 0.95in, title-size: 17pt),
  text(size: 19pt, fill: accent)[→],
  card([4 · Mettre en œuvre], [], fill: pale-orange, height: 0.95in, title-size: 17pt),
  text(size: 19pt, fill: accent)[→],
  card([5 · Suivre et améliorer], [], fill: pale-red, height: 0.95in, title-size: 17pt),
)

#v(0.85em)
#grid(
  columns: (1fr, 1.35fr),
  gutter: 0.8em,
  card([La partie visible], [
    Le modèle peut parfois tenir en quelques lignes de code.
  ], height: 1.5in),
  card([Mais le travail déterminant], [
    Formats, unités, valeurs manquantes, doublons, catégories et documentation.
  ], fill: pale-orange, height: 1.5in),
)

== Une bonne question contraint l'analyse

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.9em,
  card([Quatre éléments à préciser], [
    - *Population* — à qui la conclusion s'applique-t-elle?
    - *Unité* — que représente une ligne?
    - *Cible* — quelle variable ou décision?
    - *Résultat* — description, comparaison, prédiction ou segmentation?
  ], height: 3in),
  [
    #card([Trop vague], [
      « Analyser les données clients. »
    ], fill: pale-red, height: 1.2in)
    #v(0.55em)
    #card([Opérationnelle], [
      « Peut-on prédire quels clients achèteront le nouveau produit d'épargne ? »
    ], fill: pale, height: 1.4in)
  ],
)

#v(0.7em)
#small[
  Une question précise limite les explorations sans direction et détermine le
  protocole d'évaluation.
]

== Quatre choix structurent une méthode

#grid(
  columns: (1fr, 1fr),
  gutter: 0.72em,
  card([Espace d'observation], [
    Comment représenter chaque unité statistique ?
  ], height: 1.4in),
  card([Distance ou similarité], [
    Quelles différences doivent compter ?
  ], fill: pale-blue, height: 1.4in),
  card([Modèle ou algorithme], [
    Quelle structure veut-on extraire ?
  ], fill: pale-purple, height: 1.4in),
  card([Erreur, coût ou perte], [
    Comment reconnaître une bonne solution ?
  ], fill: pale-orange, height: 1.4in),
)

#v(0.65em)
#takeaway([
  Changer un seul objet peut changer le résultat et son interprétation.
])

== Les données ne parlent jamais seules

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Avant de modéliser], [
    - Que mesure réellement chaque variable ?
    - Qui manque dans l'échantillon ?
    - Que signifie une absence ou un zéro ?
    - Quelles contraintes y a-t-il ?
  ], height: 2.5in),
  card([Après le déploiement du modèle], [
    - Surveiller les entrées.
    - Détecter la dérive des données.
    - Réévaluer les hypothèses.
    - Réentraîner ou revoir la question.
  ], fill: pale-blue, height: 2.5in),
)

#v(0.7em)
#card([Exemple], [
  Une absence d'achat peut traduire un manque d'intérêt, une rupture de stock,
  un problème d'accès ou une observation incomplète.
], fill: pale-orange, height: 1.5in)

= Représenter les données

== Il est plus important d'avoir des données de qualité qu'un modèle sophistiqué

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Population et structure], [
    - représentativité;
    - unité statistique;
    - dépendance entre observations;
    - déséquilibre des classes.
  ], height: 2in),
  card([Valeurs et formats], [
    - valeurs manquantes;
    - doublons et incohérences;
    - unités et échelles;
    - valeurs extrêmes et modalités rares.
  ], fill: pale-blue, height: 2in),
)

#v(0.7em)
#card([Un piège courant], [
  Les codes `NA`, `N/A`, `?` et `Inconnu` peuvent représenter la même
  absence. Les conserver comme quatre catégories distinctes crée une structure artificielle.
], fill: pale-red, height: 1.5in)

== La provenance des données leur donne du sens

#grid(
  columns: (0.9fr, 1.3fr),
  gutter: 0.9em,
  card([D'où viennent-elles?], [
    - systèmes internes;
    - enquêtes;
    - capteurs;
    - expériences;
    - dépôts publics;
    - etc.
  ], height: 2.5in),
  card([Que faut-il documenter?], [
    - source, licence et date d'accès;
    - population et échantillonnage;
    - période et territoire;
    - définition et unité des variables;
    - filtres, exclusions et transformations;
    - changements de collecte.
  ], fill: pale-purple, height: 2.5in),
)

#v(0.7em)
#card([Une recommandation importante], [
  Conserver les données brutes et produire la base analysée par transformations versionnées.
], fill: pale-red, height: 1.5in)

== Une ligne = une unité et une colonne = une variable

#grid(
  columns: (1fr, 1.08fr),
  gutter: 0.9em,
  [
    #card([Données _tidy_], [
      - une variable par colonne;
      - une observation par ligne;
      - une seule valeur par cellule.
    ], height: 1.6in)
    #v(0.6em)
    #card([Le format de collecte], [
      Il faut parfois pivoter le tableau de données, séparer une colonne en deux ou réunir plusieurs fichiers.
    ], fill: pale-blue, height: 1.7in)
  ],
  card([L'unité statistique], [
    L'objet élémentaire sur lequel porte l'observation.

    Elle fixe le niveau d'agrégation et dépend de la question, pas seulement du fichier.

    Par exemple : individu, transaction, pays, image, pixel, document…
  ], fill: pale-orange, height: 3.8in),
)

== Le type d'une variable limite les opérations

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 0.5em,
  card([Numérique], [
    Ex : Revenu.
  ], height: 1.18in),
  card([Nominale], [
    Ex : Région.
  ], fill: pale-blue,
    height: 1.18in,
  ),
  card([Binaire], [
    Ex : Fraude.
  ], fill: pale-purple, height: 1.18in),
  card([Ordinale], [
    Ex : Satisfaction.
  ], fill: pale-orange, height: 1.18in),
)

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Coder n'est pas mesurer], [
    Associer 1, 2 et 3 à des modalités conserve parfois un ordre, mais ne rend
    pas les écarts comparables.
  ], height: 1.8in),
  card([Objets plus complexes], [
    Texte, courbe, image et réseau demandent une représentation adaptée avant
    toute distance ou modélisation.
  ], fill: pale-red, height: 1.8in),
)

== L'espace d'observation formalise les données

#formula([
  $cal(X) = cal(X)_1 times cal(X)_2 times dots times cal(X)_p$
], height: 0.9in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Variables numériques], [
    Ex : $cal(X)=RR^p$
  ], height: 1.5in),
  card([Données mixtes], [
    Ex : $RR_+^3 times cal(R) times cal(S)$
  ], fill: pale-blue, height: 1.5in),
  card([Objets structurés], [
    Ex : Courbe dans $cal(C)([a,b])$
  ], fill: pale-purple, height: 1.5in),
)

#v(0.7em)
#takeaway([
  La représentation choisie détermine les distances et les modèles possibles.
])

= Pause code

= Mesurer les ressemblances

== Une distance formalise la notion de « proche »

#grid(
  columns: (1.05fr, 1fr),
  gutter: 0.9em,
  card([Quatre propriétés], [
    Pour tous $x,y,z in cal(X)$ :

    1. $d(x,y) >= 0$
    2. $d(x,y)=0 <=> x=y$
    3. $d(x,y)=d(y,x)$
    4. $d(x,y) <= d(x,z)+d(z,y)$
  ], height: 3in),
  [
    #card([Distance], [
      Plus elle augmente, plus les observations sont dissemblables.
    ], fill: pale-blue, height: 2in)
    #v(0.55em)
    #card([Similarité], [
      Plus elle augmente, plus les observations se ressemblent.

      #align(center)[$s(x,y)=1/(1+d(x,y))$]
    ], fill: pale-purple, height: 2in)
  ],
)

== Les unités changent la géométrie

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Minkowski], [
    #align(center)[$d_q (x,y)=(sum_(j=1)^p |x_j-y_j|^q)^(1/q)$]

    $q=1$ : Distance de Manhattan

    $q=2$ : Distance euclidienne
  ], height: 2.2in),
  card([Standardisation], [
    #align(center)[$z_j (x)=(x_j-mu_j)/sigma_j$]

    Chaque différence est mesurée en nombre d'écarts-types.
  ], fill: pale-blue, height: 2.2in),
)

#v(0.7em)
#card([Exemple], [
  Dans une observation « âge, revenu, achats », le revenu exprimé en dollars domine souvent la distance brute. Standardiser change les voisins jugés les plus proches.
], fill: pale-orange, height: 1.5in)

== Distance de Hamming

#card([Hamming], [
  #align(center)[$d_H (x,y)=sum_(j=1)^p 1(x_j != y_j)$]

  Compte tous les désaccords entre variables qualitatives.
], height: 1.65in)

#v(0.6em)

#card([Exemple], [
  #align(center)[
    #course-table(
      columns: (1.35fr, 0.7fr, 0.7fr, 0.7fr, 0.7fr, 0.7fr),
      align: center + horizon,
      fill: (x, y) => {
        if y == 0 or x == 0 {
          pale
        } else if y == 3 and (x == 3 or x == 4) {
          pale-orange
        }
      },
      [*$x_j$*], [1], [0], [1], [0], [0],
      [*$y_j$*], [1], [0], [0], [1], [0],
      [*$1(x_j != y_j)$*], [0], [0], [1], [1], [0],
    )

    #v(0.45em)
    $d_H (x,y)=0+0+1+1+0=2$
  ]
], fill: pale-purple, height: 2.35in, body-size: 16pt)

== Indice de Jaccard

#grid(
  columns: (1.1fr, 1fr),
  gutter: 0.85em,
  [
    #align(center)[
      #course-table(
        columns: (0.6fr, 1fr, 1fr),
        align: center + horizon,
        fill: (x, y) => {
          if y == 0 or x == 0 {
            pale
          } else if x == 1 and y == 1 {
            pale
          } else if x == 2 and y == 2 {
            pale-gray
          } else {
            pale-orange
          }
        },
        [], [*$y_j=1$*], [*$y_j=0$*],
        [*$x_j=1$*], [*$M_11$* #linebreak() Présence commune], [*$M_10$* #linebreak() Présent dans $x$ seulement],
        [*$x_j=0$*], [*$M_01$* #linebreak() Présent dans $y$ seulement], [*$M_00$* #linebreak() Absence commune],
      )
    ]

    #v(0.55em)
    #small[
      $M_(a b)$ compte les positions où $x_j=a$ et $y_j=b$.
    ]
  ],
  [
    #formula([
      $J = M_11/(M_11+M_10+M_01) quad "et" quad d_J=1-J$
    ], height: 0.88in)

    #v(0.55em)
    #card([Exemple], [
      #align(center)[
        $x=(1,0,1,0,0)^top, quad y=(1,0,0,1,0)^top$
        #v(0.45em)
        $M_11=1, quad M_10=1, quad M_01=1, quad M_00=2$
        #v(0.45em)
        $J=1/3 quad "et" quad d_J=2/3$
      ]
    ], fill: pale-purple, height: 2.02in, body-size: 16pt)
  ],
)


== Choisir une distance, c'est choisir une manière de comparer

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Quantitative], [
    Euclidienne standardisée si les dimensions doivent peser de façon comparable.
  ], height: 1.62in, body-size: 16pt),
  card([Qualitative], [
    Jaccard si les achats communs comptent davantage que les absences communes.
  ], fill: pale-purple, height: 1.62in, body-size: 16pt),
  card([Données mixtes], [
    Combiner distances numériques, qualitatives ou autres avec des poids justifiés.
  ], fill: pale-blue, height: 1.62in, body-size: 16pt),
)

#v(0.8em)
#card([Question à se poser], [
  Deux observations proches doivent-elles partager des valeurs, des catégories,
  une trajectoire, des voisins ou une conséquence pratique?
], fill: pale-red, height: 1.25in)

= Pause code

= Mesurer l'erreur

== Erreur, coût et perte désignent la même idée

#formula([
  $Y = f(X) + epsilon$
], height: 0.9in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Information systématique], [
    $f(X)$ représente ce que les variables explicatives apportent sur la réponse.
  ], height: 1.35in),
  card([Part non expliquée], [
    $epsilon$ regroupe bruit, variables absentes et variabilité naturelle.
  ], fill: pale-blue, height: 1.35in),
)

#v(0.65em)
#takeaway([
  Une fonction d'erreur, de coût ou de perte quantifie la qualité d'une décision.
], fill: pale-orange)

== MSE et MAE ne pénalisent pas les mêmes erreurs

#grid(
  columns: (1fr, 1fr),
  gutter: 0.85em,
  card([Erreur quadratique moyenne], [
    $ "MSE" = 1/n sum_(i=1)^n (y_i-hat(y)_i)^2 $

    Les grandes erreurs pèsent fortement.
  ], height: 2.5in),
  card([Erreur absolue moyenne], [
    $ "MAE" = 1/n sum_(i=1)^n |y_i-hat(y)_i| $

    L'erreur typique est plus robuste aux valeurs extrêmes.
  ], fill: pale-blue, height: 2.5in),
)

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Choisir la MSE], [
    Quand les erreurs extrêmes ont des conséquences disproportionnées.
  ], fill: pale-orange, height: 1.8in),
  card([Choisir la MAE], [
    Quand l'écart absolu habituel correspond mieux à l'usage.
  ], fill: pale-purple, height: 1.8in),
)

== Taux d'erreur en classification

#formula([
  $ "ER" = 1/n sum_(i=1)^n 1(y_i != hat(y)_i) $
], height: 1in)

#v(0.7em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  card([Compter les erreurs], [
    L'indicatrice vaut 1 lorsque la classe prédite diffère de la classe observée,
    et 0 sinon. La somme compte les erreurs.
  ], height: 2.15in),
  card([Exemple], [
    Avec 3 erreurs sur 20 observations,
    #align(center)[$"ER" = 3/20 = 15%$.]
    L'exactitude vaut alors $1 - "ER" = 85%$.
  ], fill: pale-blue, height: 2.15in),
)

#v(0.7em)
#takeaway([
  Attention, le taux global ne distingue pas les faux positifs des faux négatifs et peut donc masquer la qualité d'une décision sur une classe rare.
], fill: pale-orange)

== La matrice de confusion compte quatre décisions

#align(center)[
  #course-table(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    fill: (x, y) => if y == 0 or x == 0 { pale },
    [], [*Prédit positif*], [*Prédit négatif*],
    [*Réel positif*], [Vrai positif (VP)], [Faux négatif (FN)],
    [*Réel négatif*], [Faux positif (FP)], [Vrai négatif (VN)],
  )
]

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Cas manqués], [
    Les faux négatifs sont positifs en réalité, mais non détectés.
  ], fill: pale-red, height: 1.5in),
  card([Fausses alertes], [
    Les faux positifs sont négatifs en réalité, mais signalés à tort.
  ], fill: pale-orange, height: 1.5in),
)

== Quatre mesures répondent à quatre questions

#grid(
  columns: (1fr, 1fr),
  gutter: 0.62em,
  metric([Sensibilité], [$ "VP"/("VP"+"FN") $], [Parmi les positifs, combien sont détectés?]),
  metric([Spécificité], [$ "VN"/("VN"+"FP") $], [Parmi les négatifs, combien sont écartés?], fill: pale-blue),
  metric([Précision], [$ "VP"/("VP"+"FP") $], [Parmi les alertes, combien sont réellement positives?], fill: pale-purple),
  card([], [Abaisser le seuil augmente généralement la sensibilité mais réduit la spécificité. La précision dépend aussi de la fréquence de la classe positive.], fill: pale-orange, height: 2.2in)
)


== Une exactitude élevée peut masquer l'échec

#grid(
  columns: (0.82fr, 1.3fr),
  gutter: 0.9em,
  card([1 000 transactions], [
    - 20 fraudes;
    - 16 détectées;
    - 4 manquées;
    - 30 fausses alertes.
  ], height: 2.05in),
  [
    #formula([
      $"Sensibilité" = 16/20 = 80%$
    ], height: 0.72in)
    #v(0.42em)
    #formula([
      $"Spécificité" = 950/980 approx 96,9%$
    ], fill: pale-blue, height: 0.72in)
    #v(0.42em)
    #formula([
      $"Précision" = 16/46 approx 34,8%$
    ], fill: pale-purple, height: 0.72in)
  ],
)

#v(0.65em)
#takeaway([
  Une bonne spécificité peut coexister avec beaucoup de fausses alertes.
])

== Le coût réel doit guider le critère

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.62em,
  card([Dépistage], [
    Manquer une maladie peut coûter davantage qu'un examen complémentaire.
  ], height: 1.55in, body-size: 16pt),
  card([Fraude], [
    Le coût dépend du montant, de la vérification et de la relation client.
  ], fill: pale-red, height: 1.55in, body-size: 16pt),
  card([Stocks], [
    Rupture, stockage et gaspillage rendent les erreurs asymétriques.
  ], fill: pale-orange, height: 1.55in, body-size: 16pt),
)

#v(0.8em)
#card([Conséquence], [
  Le seuil de décision et la mesure de performance doivent refléter les
  conséquences pratiques, pas seulement le nombre d'erreurs.
], fill: pale-blue, height: 1.4in)

= Pause code

== Biais, variance et bruit décomposent l'erreur

#formula([
  $ EE((Y_0-hat(f)(x_0))^2)
    = "Biais"(hat(f)(x_0))^2
    + "Var"(hat(f)(x_0))
    + sigma^2 $
], height: 1.05in)

#v(0.65em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.62em,
  card([Biais²], [
    Écart systématique entre la prédiction et la relation réelle.
  ], height: 1.7in, body-size: 16pt),
  card([Variance], [
    Sensibilité de la prédiction au choix du jeu d'entraînement.
  ], fill: pale-blue, height: 1.7in, body-size: 16pt),
  card([Bruit $sigma^2$], [
    Variabilité irréductible avec les variables disponibles.
  ], fill: pale-purple, height: 1.7in, body-size: 16pt),
)

#v(0.65em)
#small[
  Le biais statistique n'est ni un biais de collecte ni un biais social.
]

== La flexibilité crée un compromis

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  gutter: 0.45em,
  align: horizon,
  card([Sous-ajustement], [
    Biais élevé

    Variance faible
  ], height: 1.52in),
  text(size: 22pt, fill: accent)[→],
  card([Compromis utile], [
    Structure captée

    Stabilité suffisante
  ], fill: pale-blue, height: 1.52in),
  text(size: 22pt, fill: accent)[←],
  card([Sur-ajustement], [
    Biais faible

    Variance élevée
  ], fill: pale-red, height: 1.52in),
)

#v(0.8em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Entraînement], [
    L'erreur diminue généralement avec la flexibilité.
  ], height: 1.8in),
  card([Nouvelles données], [
    L'erreur diminue, atteint un minimum, puis remonte souvent.
  ], fill: pale-orange, height: 1.8in),
)

= Pause code

= Valider pour généraliser

== Trois ensembles, trois rôles

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.65em,
  card([Entraînement], [
    Estimer les paramètres et les transformations.
  ], height: 1.8in),
  card([Validation], [
    Comparer les méthodes, régler les hyperparamètres et le seuil.
  ], fill: pale-blue, height: 1.8in),
  card([Test], [
    Estimer une seule fois la performance finale.
  ], fill: pale-purple, height: 1.8in),
)

#v(0.75em)
#takeaway([
  Si le résultat du test modifie le modèle, le test est devenu une validation.
], fill: pale-red)

== La séparation doit imiter l'usage futur

#grid(
  columns: (1fr, 1fr),
  gutter: 0.68em,
  card([Aléatoire], [
    Observations indépendantes issues de la même population.
  ], height: 1.5in),
  card([Stratifiée], [
    Proportions des classes préservées dans chaque ensemble.
  ], fill: pale-blue, height: 1.5in),
  card([Par groupe], [
    Toutes les visites d'un patient restent ensemble.
  ], fill: pale-purple, height: 1.5in),
  card([Temporelle], [
    Le passé entraîne et une période ultérieure valide et teste.
  ], fill: pale-orange, height: 1.5in),
)

#v(0.62em)
#small[
  Les proportions 60-20-20 ou 70-15-15 sont des points de départ. Les effectifs
  utiles, la rareté des classes et le nombre de groupes comptent davantage.
]

== Une fuite rend l'évaluation trop optimiste

#grid(
  columns: (1fr, 1fr),
  gutter: 0.55em,
  align: horizon,
  card([Procédure incorrecte], [
    Imputer, standardiser ou sélectionner sur toute la base.
  ], fill: pale-red, height: 1.5in),
  card([Procédure correcte], [
    Ajuster la transformation sur l'entraînement, puis l'appliquer sur les autres ensembles.
  ], fill: pale, height: 1.5in),
)

#v(0.75em)
#card([Autres fuites], [
  Une date future, une observation du même individu ou une variable construite
  après l'événement à prédire peuvent transmettre de l'information interdite.
], fill: pale-orange, height: 1.5in)

#v(0.65em)
#takeaway([Toute transformation apprise fait partie du modèle.])

= Pause code

== La validation croisée réduit la dépendance à un seul découpage

#align(center)[
  #course-table(
    columns: (0.75fr, 0.72fr, 0.72fr, 0.72fr, 0.72fr, 0.72fr),
    align: center + horizon,
    fill: (x, y) => if y == 0 { pale },
    [*Tour*], [*Pli 1*], [*Pli 2*], [*Pli 3*], [*Pli 4*], [*Pli 5*],
    [1], [#tag([V], fill: rgb("#b45309"))], [E], [E], [E], [E],
    [2], [E], [#tag([V], fill: rgb("#b45309"))], [E], [E], [E],
    [3], [E], [E], [#tag([V], fill: rgb("#b45309"))], [E], [E],
    [4], [E], [E], [E], [#tag([V], fill: rgb("#b45309"))], [E],
    [5], [E], [E], [E], [E], [#tag([V], fill: rgb("#b45309"))],
  )
]

#v(0.65em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([E · Entraînement], [
    Ajuster toute la procédure sur quatre plis.
  ], height: 1.3in),
  card([V · Validation], [
    Prédire sur le pli restant, et calculer son erreur.
  ], fill: pale-orange, height: 1.3in),
)

#v(0.55em)
#small[
  Les prédictions hors pli proviennent toujours d'un modèle qui n'a pas vu
  l'observation correspondante.
]

== L'erreur globale pondère les plis

#formula([
  $ "Err"_k = 1/n_k sum_(i in I_k) L(y_i, hat(f)^(-k)(x_i)) $
], height: 0.85in)

#v(0.5em)
#formula([
  $ hat("Err")_("CV") = sum_(k=1)^K n_k/n "Err"_k $
], fill: pale-blue, height: 0.85in)

#v(0.65em)
#card([Exemple à cinq plis égaux], [
  Erreurs : 18 %, 22 %, 20 %, 16 % et 24 %.

  Moyenne : $frac((18%+22%+20%+16%+24%), 5, style: "horizontal")=20%$.

  L'étendue de 16 % à 24 % révèle aussi une sensibilité au découpage.
], fill: pale-purple, height: 2in)

== Le choix du nombre de plis $K$ est un compromis

#align(center)[
  #course-table(
    columns: (0.65fr, 1.25fr, 1.8fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    fill: (x, y) => if y == 0 { pale },
    [*$K$*], [*Atout*], [*Limite*],
    [5], [Calcul plus rapide], [Chaque modèle utilise 80 % des données],
    [10], [Bon compromis général], [Deux fois plus d'ajustements],
    [$n$], [Entraînement sur $n-1$ cas], [Coûteux; erreurs très corrélées],
  )
]

#v(0.75em)
#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Choix courant], [
    $K=5$ ou $K=10$ convient à de nombreux problèmes indépendants.
  ], height: 1.5in),
  card([Répéter], [
    Plusieurs partitions réduisent la dépendance à une seule graine aléatoire.
  ], fill: pale-blue, height: 1.5in),
)


== Une bonne moyenne ne suffit pas

#grid(
  columns: (1fr, 1fr),
  gutter: 0.75em,
  card([Rapporter], [
    - moyenne des erreurs;
    - dispersion entre les plis;
    - effectifs et classes;
    - règle de séparation.
  ], height: 2in),
  card([Vérifier], [
    - même contexte futur;
    - ordre temporel respecté;
    - groupes non séparés;
    - transformations sans fuite.
  ], fill: pale-blue, height: 2in),
)

#v(0.7em)
#card([Interprétation], [
  Les erreurs des plis ne sont pas indépendantes puisque leurs entraînements se
  chevauchent. Leur dispersion décrit une stabilité observée, pas automatiquement
  un intervalle de confiance valide.
], fill: pale-red, height: 2in)

= Pause code

== Une analyse défendable relie tous les choix

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  gutter: 0.32em,
  align: horizon,
  card([Question], [Population et usage.], height: 1.1in, body-size: 16pt),
  text(size: 19pt, fill: accent)[→],
  card([Données], [Unité et qualité.], fill: pale-blue, height: 1.1in, body-size: 16pt),
  text(size: 19pt, fill: accent)[→],
  card([Méthode], [Espace et distance.], fill: pale-purple, height: 1.1in, body-size: 16pt),
  text(size: 19pt, fill: accent)[→],
  card([Décision], [Erreur et validation.], fill: pale-orange, height: 1.1in, body-size: 16pt),
)

#v(0.65em)
#takeaway([
  Une performance n'a de sens qu'à l'intérieur d'un protocole explicite.
])
