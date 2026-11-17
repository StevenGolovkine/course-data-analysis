// STT-2200 : méthodes ensemblistes.
// Source : lectures/supervised.typ, section <methodes-ensemblistes>.
// Figures existantes : figures/methodes_ensemblistes.py.
// Exemples théoriques ou fictifs ; la grille Penguins n'est pas un résultat.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/methodes_ensemblistes.typ
#import "../styles/slides.typ": *
#import "../styles/math.typ": Var, Cov, ind, argmax
#let signe = math.op("signe")

#show: course-slides.with(
  title: [Méthodes ensemblistes],
  footer-title: [Méthodes ensemblistes],
)

#title-slide()

= Combiner plusieurs prédictions

== Deux démarches d'agrégation

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Bagging et forêts aléatoires], [
    Ajuster plusieurs modèles en faisant varier les données
    ou les variables candidates.
    #v(1em)
    Combiner leurs prédictions par une moyenne ou un vote.
    #v(1em)
    Les arbres peuvent être construits en parallèle.
  ], height: 2.8in),
  card([Boosting], [
    Partir d'un modèle initial.
    #v(1em)
    Ajouter des corrections qui dépendent des prédictions déjà obtenues.
    #v(1em)
    L'étape suivante utilise le modèle courant.
  ], fill: pale-blue, height: 2.8in),
)
#v(0.5em)
#takeaway([La diversité des erreurs compte. Répéter exactement le même arbre ne change pas sa prédiction.])

== Régression : moyenner les prédictions

#formula([
  $ hat(f)_"ens" (x)=1/B sum_(b=1)^B hat(f)_b (x) $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Notations], [
    $B$ modèles de base.
    #v(1em)
    $hat(f)_b (x)$ : prédiction au point $x$ du modèle $b$.
    #v(1em)
    $hat(f)_"ens" (x)$ : prédiction agrégée.
  ], height: 2.25in),
  card([Trois arbres], [
    Prédictions : 8, 10 et 12.
    #v(1em)
    La moyenne vaut $(8+10+12)/3=10$.
    #v(1em)
    L'agrégation porte sur les réponses prédites.
  ], fill: pale-blue, height: 2.25in),
)
#v(0.4em)
#takeaway([Chaque arbre peut avoir des coupures différentes. On ne moyenne pas leurs seuils.])

== Classification : vote ou probabilités

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Vote des classes], [
    $ hat(g)_"vote" (x)
      =argmax_g sum_(b=1)^B ind(hat(g)_b (x)=g) $
    #v(1em)
    Chaque modèle apporte une voix à sa classe prédite.
    #v(1em)
    La classe la plus fréquente l'emporte.
  ], height: 2.9in),
  card([Moyenne des probabilités], [
    $ hat(eta)_g (x)=1/B sum_(b=1)^B hat(eta)_(b g) (x) $

    $ hat(g)_"prob" (x)=argmax_g hat(eta)_g (x) $
    #v(1em)
    Les probabilités de chaque classe contribuent à la décision.
  ], fill: pale-blue, height: 2.9in),
)
#v(0.4em)
#takeaway([Fixer une règle d'égalité.
  En multiclasse, la classe gagnante peut recueillir moins de 50 % des voix.])

== Deux règles, deux décisions possibles

#small([Exemple binaire, à coûts égaux. Chaque arbre utilise le seuil $0.5$.])
#v(0.45em)
#course-table(
  columns: (1fr, 1fr, 1fr, 1fr),
  table.header([*Arbre*], [*1*], [*2*], [*3*]),
  [Probabilité de 1], [0,51], [0,51], [0,01],
  [Classe prédite], [1], [1], [0],
)
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Vote : classe 1], [
    Deux voix sur trois.
    #v(1em)
    Le vote conserve seulement les décisions individuelles.
  ], height: 1.75in),
  card([Probabilités : classe 0], [
    $ (0.51+0.51+0.01)/3 approx 0.343. $
    #v(1em)
    La moyenne reste sous le seuil $0.5$.
  ], fill: pale-blue, height: 1.75in),
)



= Bagging et évaluation OOB

== Définition : le bagging

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Bootstrap aggregating], [
    Construire $B$ modèles à partir de $B$ échantillons bootstrap
    du jeu d'entraînement.
    #v(1em)
    Agréger leurs prédictions avec la règle retenue.
  ], height: 2.55in),
  card([Un échantillon bootstrap], [
    Effectuer $n$ tirages *avec remise* parmi les $n$ couples $(x_i,y_i)$.
    #v(1em)
    Les répétitions comptent dans l'apprentissage.
    #v(1em)
    Certaines observations restent absentes.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.6em)
#takeaway([La variation des échantillons peut modifier les coupures d'un même algorithme.])

== Les étapes du bagging

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Tirer les indices], [
    Pour chaque modèle $b$, sélectionner $n$ indices avec remise.
  ], height: 1.6in),
  card([2. Ajuster le modèle], [
    Apprendre l'arbre sur ces lignes, en conservant les répétitions.
  ], fill: pale-blue, height: 1.6in),
  card([3. Répéter], [
    Construire les $B$ modèles avec le même protocole d'apprentissage.
  ], fill: pale-purple, height: 1.6in),
  card([4. Agréger], [
    Pour une nouvelle observation, moyenner les prédictions ou voter.
  ], fill: pale-orange, height: 1.6in),
)
#v(0.55em)
#takeaway([Chaque arbre s'ajuste sans utiliser les prédictions des autres arbres.])

== Six lignes, quatre observations distinctes

#formula([
  $ "Indices tirés" : quad (1,1,2,4,4,6) $
])
#v(0.55em)
#course-table(
  columns: (1.35fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  table.header([*Observation*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*]),
  [Occurrences], [2], [1], [0], [2], [0], [1],
)
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Utilisées pour cet arbre], [
    1, 2, 4 et 6.

    Les observations 1 et 4 apparaissent deux fois.
  ], height: 1.7in),
  card([Absentes pour cet arbre], [
    3 et 5 sont *out-of-bag* (OOB).

    Un autre arbre aura d'autres observations OOB.
  ], fill: pale-blue, height: 1.7in),
)


== La prédiction et l'erreur OOB

#small([$cal(B)_i$ contient les indices des modèles qui n'ont pas utilisé l'observation $i$.])
#v(0.5em)
#formula([
  $ hat(y)_i^"OOB"=1/abs(cal(B)_i)
    sum_(b in cal(B)_i) hat(f)_b (x_i), quad abs(cal(B)_i)>0 $
])
#v(0.5em)
#formula([
  $ hat(R)_"OOB"=1/n sum_(i=1)^n L(y_i,hat(y)_i^"OOB") $
])
#v(0.5em)
#takeaway([Chaque observation a son propre sous-ensemble de modèles OOB.])
#v(0.3em)
#small([La seconde formule suppose que chaque observation a au moins une prédiction OOB.
  En classification, voter ou moyenner les probabilités sur ces seuls modèles.])

== Un calcul OOB à la main

#course-table(
  columns: (1fr, 2fr),
  table.header([*Quantité*], [*Valeur*]),
  [Réponse observée], [$y_i=10$],
  [Prédictions des trois modèles OOB], [9, 11 et 12],
  [Prédiction agrégée], [$hat(y)_i^"OOB"=32/3 approx 10.67$],
  [Perte quadratique], [$(10-32/3)^2=4/9$],
)
#v(0.65em)
#takeaway([Les modèles ayant utilisé $i$ restent exclus de cette prédiction.])

== Les précautions de l'évaluation OOB

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un diagnostic interne], [
    Vérifier que chaque observation reçoit des prédictions OOB.
    #v(1em)
    Sinon, augmenter $B$ ou annoncer les observations effectivement évaluées.
    #v(1em)
    Des réglages nombreux sur l'OOB appellent une évaluation finale indépendante.
  ], height: 3.05in),
  card([Un apprentissage sans fuite], [
    Une sélection supervisée de variables peut réintroduire les réponses OOB.
    #v(1em)
    Les observations liées par individu, site ou date demandent
    un schéma de validation adapté.
  ], fill: pale-orange, height: 3.05in),
)

= Forêts aléatoires

== Définition : diversifier les variables candidates

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Au niveau de l'arbre], [
    Tirer un échantillon bootstrap.
    #v(1em)
    Apprendre l'arbre sur cet échantillon, avec ses répétitions.
  ], height: 2.55in),
  card([À chaque nœud], [
    Tirer sans remise $m$ variables parmi les $p$ disponibles.
    #v(1em)
    Chercher la meilleure coupure parmi ces variables.
    #v(1em)
    Renouveler le tirage au nœud suivant.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.6em)
#takeaway([Dans ce cadre, $m=p$ retrouve le bagging d'arbres, à autres réglages identiques.])

== Variables candidates et nombre d'arbres

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le rôle de $m$], [
    Un petit $m$ peut réduire la corrélation entre arbres.
    #v(1em)
    Il peut aussi écarter les variables les plus informatives d'un nœud.
    #v(1em)
    $m approx sqrt(p)$ constitue un point de départ courant en classification.
  ], height: 2.85in),
  card([Le rôle de $B$], [
    Davantage d'arbres stabilisent l'agrégation et l'estimation OOB.
    #v(1em)
    La profondeur de chaque arbre reste inchangée.
    #v(1em)
    Le calcul devient plus coûteux.
  ], fill: pale-blue, height: 2.85in),
)
#v(0.45em)
#takeaway([Le seuil reste optimisé parmi les variables candidates.
  Les performances à $B$ fini peuvent fluctuer.])


= Boosting et corrections successives

== Définition : un modèle additif par étapes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le modèle courant], [
    À l'étape $t$, ajuster un nouveau modèle de base en tenant compte
    des prédictions déjà obtenues.
    #v(1em)
    Ajouter sa contribution pour réduire une perte.
  ], height: 2.6in),
  card([Des corrections simples], [
    Une *souche* est un arbre à une seule coupure, donc à deux feuilles.
    #v(1em)
    Plusieurs corrections simples peuvent former une prédiction détaillée.
    #v(1em)
    Les étapes dépendent les unes des autres.
  ], fill: pale-blue, height: 2.6in),
)
#v(0.6em)
#takeaway([Les corrections peuvent être négatives et leurs coupures peuvent varier au fil des étapes.])

== Régression quadratique : la mise à jour

Perte $L(y,z)=(y-z)^2/2$. Le modèle initial est $F^((0))(x)=overline(y)$.
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Les résidus courants], [
    $ r_i^((t))=y_i-F^((t-1))(x_i) $
    #v(1em)
    Ajuster $h_t$ aux couples $(x_i,r_i^((t)))$.
    #v(1em)
    Chaque feuille prédit la moyenne de ses résidus.
  ], height: 2.55in),
  card([Une correction réduite], [
    $ F^((t))(x)=F^((t-1))(x)+nu h_t (x) $
    #v(1em)
    $nu$ est le taux d'apprentissage.
    #v(1em)
    Dans ce cadre, $0<nu<=1$.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.5em)
#formula([
  $ F^((T))(x)=overline(y)+nu sum_(t=1)^T h_t (x) $
])

== Première correction sur six observations

#formula([
  $ x=(1,2,3,4,5,6), quad y=(1,2,3,8,9,10), quad nu=0.5 $
])
#v(0.5em)
#course-table(
  columns: (1.2fr, 2.6fr),
  table.header([*Étape*], [*Calcul*]),
  [Initialisation], [$F^((0))=overline(y)=5.5$],
  [Résidus], [$(-4.5,-3.5,-2.5,2.5,3.5,4.5)$],
  [Souche $h_1$], [Seuil $3.5$ : $-3.5$ à gauche, $3.5$ à droite.],
  [Nouvelle prédiction], [$5.5+0.5(-3.5)=3.75$ à gauche, $7.25$ à droite.],
)
#v(0.55em)
#takeaway([L'arbre ajuste les résidus. Le modèle final ajoute seulement la moitié de cette correction.])

== Deuxième correction et erreur d'entraînement

Les nouveaux résidus sont $(-2.75,-1.75,-0.75,0.75,1.75,2.75)$.
#v(0.45em)
#course-table(
  columns: (1.2fr, 1fr, 1fr, 1.3fr),
  table.header([*Modèle*], [*$x<=3.5$*], [*$x>3.5$*], [*Somme des carrés*]),
  [$F^((0))$], [5,5], [5,5], [77,5],
  [$F^((1))$], [3,75], [7,25], [22,375],
  [$F^((2))$], [2,875], [8,125], [8,59375],
)
#v(0.55em)
#formula([
  $ h_2 (x)=cases(-1.75 & "si" x<=3.5, 1.75 & "sinon"),
    quad F^((2))(x)=F^((1))(x)+0.5 h_2 (x) $
])
#v(0.4em)
#small([La somme des carrés porte sur l'entraînement.
  Elle ne mesure pas la performance sur de nouvelles observations.])

== Les corrections et leur accumulation

#align(center)[
  #image("../figures/ensembles_boosting.svg",
    width: 100%, height: 3.8in, fit: "contain",
    alt: "La première souche ajuste les résidus avec moins 3,5 et plus 3,5. "
      + "Les prédictions évoluent de 5,5 partout à 3,75 et 7,25, "
      + "puis à 2,875 et 8,125.")
]
#v(0.4em)
#takeaway([Dans cet exemple, les deux premières souches ont le même seuil. Ce n'est pas une contrainte du boosting.])

== Gradient boosting : les pseudo-résidus

#formula([
  $ r_i^((t))=-(partial L(y_i,z))/(partial z)
    quad "évalué en" quad z=F^((t-1))(x_i) $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une direction de correction], [
    Ajuster l'arbre à l'opposé du gradient de la perte par rapport à la prédiction.
    #v(1em)
    L'arbre approche une direction de diminution de cette perte.
  ], height: 2.3in),
  card([Le cas quadratique], [
    $ -(partial L)/(partial z)=y-z $
    #v(1em)
    Les pseudo-résidus coïncident avec les résidus ordinaires.
  ], fill: pale-blue, height: 2.3in),
)


== Classification binaire : corriger un score

Ici, $y_i in \{0,1\}$. Le modèle $F$ fournit un score réel.
#v(0.45em)
#formula([
  $ p(x)=1/(1+exp(-F(x))), quad
    L(y,F)=log(1+exp(F))-y F $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Pseudo-résidu logistique], [
    $ r_i^((t))=y_i-p^((t-1))(x_i) $
    #v(1em)
    Une valeur positive pousse le score vers la classe 1.
  ], height: 2in),
  card([Prédiction finale], [
    Les arbres apportent des corrections numériques au score.
    #v(1em)
    La transformation logistique donne ensuite une probabilité.
  ], fill: pale-blue, height: 2in),
)

== Trois pseudo-résidus logistiques

#course-table(
  columns: (0.7fr, 1.1fr, 1.2fr, 2fr),
  table.header([*$y_i$*], [*Probabilité de 1*], [*$y_i-p_i$*], [*Sens de la correction*]),
  [1], [0,2], [0,8], [Augmenter le score.],
  [1], [0,9], [0,1], [Augmenter moins fortement.],
  [0], [0,9], [−0,9], [Diminuer le score.],
)
#v(0.65em)
#takeaway([Le signe indique une direction. L'arbre, la perte et le taux d'apprentissage déterminent la correction finale.])


= Réglages et validation

== Des hyperparamètres aux rôles distincts

#course-table(
  columns: (1fr, 1.3fr, 2.2fr),
  table.header([*Méthode*], [*Réglage*], [*Effet principal*]),
  [Toutes], [Profondeur et taille minimale des feuilles],
    [Finesse des règles et sensibilité aux petits effectifs.],
  [Forêt], [Nombre d'arbres $B$],
    [Stabilité de l'agrégation et coût du calcul.],
  [Forêt], [Variables candidates $m$],
    [Diversité et qualité individuelle des arbres.],
  [Boosting], [Étapes $T$ et taux $nu$],
    [Accumulation des corrections. Réglage conjoint.],
  [Boosting], [Fraction d'observations par étape],
    [Perturbation de l'apprentissage et régularisation possible.],
)

== Profondeur, taux d'apprentissage et interactions

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Nombre et amplitude des corrections], [
    Un petit $nu$ demande généralement davantage d'étapes pour
    obtenir un ajustement comparable.
    #v(1em)
    Le couple $(T,nu)$ contrôle le chemin d'apprentissage.
  ], height: 2.55in),
  card([Complexité des arbres], [
    Des arbres plus profonds permettent des interactions plus complexes.
    #v(1em)
    Une somme de souches reste additive dans les variables,
    sur l'échelle du score.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.6em)
#takeaway([Augmenter seulement le nombre de souches ne permet pas de représenter toutes les interactions.])


== Un protocole de comparaison commun

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Fixer le protocole], [
    Choisir la perte, la grille et les plis stratifiés de l'entraînement.
  ], height: 1.7in),
  card([2. Comparer dans les plis], [
    Reconstruire tous les arbres dans chaque pli.

    Utiliser les mêmes observations de validation.
  ], fill: pale-blue, height: 1.7in),
  card([3. Réajuster], [
    Sélectionner les réglages et apprendre le modèle sur les observations.
  ], fill: pale-purple, height: 1.7in),
  card([4. Évaluer sur le test réservé], [
    Matrice de confusion, sensibilité par classe et mesure globale choisie.
  ], fill: pale-orange, height: 1.7in),
)
#v(0.4em)
#small([Conserver graines, règles d'égalité et traitement des valeurs manquantes.
  Une petite différence observée ne prouve pas une supériorité générale.])


= Importance des variables

== Définition : un score relatif au modèle

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Contribution à la construction], [
    Attribuer à une variable les gains des coupures qui l'utilisent.
    #v(1em)
    L'importance par diminution d'impureté décrit les arbres appris.
  ], height: 2.5in),
  card([Contribution aux prédictions], [
    Perturber une variable et mesurer la dégradation des prédictions.
    #v(1em)
    L'importance par permutation étudie le comportement d'un modèle fixé.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.6em)
#takeaway([L'importance dépend du modèle, des autres variables, des observations et du critère de mesure.])

== Portée d'une importance globale

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un résumé sur des observations], [
    Le score résume le rôle d'une variable sur un ensemble de points.
    #v(1em)
    Une analyse locale peut faire ressortir d'autres variables
    pour une prédiction particulière.
  ], height: 2.55in),
  card([Une relation parfois complexe], [
    Une importance élevée peut venir d'un seuil, d'une relation
    non monotone ou d'une interaction.
    #v(1em)
    Elle ne donne pas le sens de l'effet d'une hausse de la variable.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.55em)
#takeaway([Une importance ne se réduit ni au signe d'un coefficient ni à une corrélation avec la réponse.])

== Importance par diminution d'impureté

#formula([
  $ A_j=1/B sum_(b=1)^B sum_(t in cal(T)_(b j))
    n_(b t)/n_b Delta I_b (t) $
])
#v(0.5em)
#course-table(
  columns: (1fr, 2.8fr),
  table.header([*Notation*], [*Interprétation*]),
  [$cal(T)_(b j)$], [Nœuds de l'arbre $b$ utilisant la variable $j$.],
  [$n_b$, $n_(b t)$], [Effectifs à la racine et au nœud $t$.],
  [$Delta I_b (t)$], [Gain local d'impureté de la coupure.],
)

== Importance par permutation : le protocole

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Évaluer la référence], [
    Calculer la perte du modèle sur les données non perturbées.
  ], height: 1.65in),
  card([2. Brouiller une colonne], [
    Permuter ses valeurs entre les lignes.

    Garder les réponses et les autres colonnes en place.
  ], fill: pale-blue, height: 1.65in),
  card([3. Recalculer les prédictions], [
    Utiliser le même modèle, sans réentraînement.
  ], fill: pale-purple, height: 1.65in),
  card([4. Mesurer et répéter], [
    Calculer l'augmentation de perte.

    Répéter $M$ fois pour chaque variable.
  ], fill: pale-orange, height: 1.65in),
)

== La perte avant et après permutation

#formula([
  $ hat(R)_0=1/n_"val" sum_(i=1)^(n_"val") L(y_i,hat(f)(x_i)) $
])
#v(0.45em)
#formula([
  $ hat(R)_j^((r))=1/n_"val" sum_(i=1)^(n_"val")
      L(y_i,hat(f)(x_i^((j,r)))) $
])
#v(0.45em)
#formula([
  $ P_j=1/M sum_(r=1)^M (hat(R)_j^((r))-hat(R)_0) $
])
#v(0.4em)
#small([$x_i^((j,r))$ : ligne après la permutation $r$ de la colonne $j$.
  Pour un score à maximiser, prendre le score initial moins le score perturbé.])

= Synthèse et limites

== Les limites des prédictions agrégées

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Classification], [
    Vérifier la calibration des probabilités.
    #v(1em)
    Examiner les classes rares et les coûts d'erreur.
    #v(1em)
    Une bonne exactitude globale peut masquer une classe mal prédite.
  ], height: 2.6in),
  card([Régression], [
    Les moyennes de valeurs de feuilles restent entre les réponses
    minimale et maximale de l'entraînement.
    #v(1em)
    Le boosting peut sortir de cet intervalle, sans garantie
    d'extrapolation pertinente.
  ], fill: pale-orange, height: 2.6in),
)
#v(0.5em)
#takeaway([Le classement des variables complète l'examen des erreurs
  et des prédictions individuelles.])

== Les méthodes en perspective

#course-table(
  columns: (1fr, 1.8fr, 1.8fr),
  table.header([*Méthode*], [*Construction*], [*Combinaison*]),
  [Bagging], [Échantillons bootstrap.], [Moyenne ou vote.],
  [Forêt aléatoire], [Bootstrap et variables candidates à chaque nœud.],
    [Moyenne ou vote, avec des arbres diversifiés.],
  [Boosting], [Corrections dépendant du modèle courant.],
    [Somme de contributions successives.],
)
#v(0.55em)
#takeaway([La validation doit porter sur la procédure complète, y compris les réglages et la sélection des variables.])
