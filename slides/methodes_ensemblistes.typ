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

    Combiner leurs prédictions par une moyenne ou un vote.

    Les arbres peuvent être construits en parallèle.
  ], height: 2.8in),
  card([Boosting], [
    Partir d'un modèle initial.

    Ajouter des corrections qui dépendent des prédictions déjà obtenues.

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

    $hat(f)_b (x)$ : prédiction au point $x$ du modèle $b$.

    $hat(f)_"ens" (x)$ : prédiction agrégée.
  ], height: 2.25in),
  card([Trois arbres], [
    Prédictions : 8, 10 et 12.

    La moyenne vaut $(8+10+12)/3=10$.

    L'agrégation porte sur les réponses prédites.
  ], fill: pale-blue, height: 2.25in),
)
#v(0.4em)
#small([Chaque arbre peut avoir des coupures différentes. On ne moyenne pas leurs seuils.])

== Classification : vote ou probabilités

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Vote des classes], [
    $ hat(g)_"vote" (x)
      =argmax_g sum_(b=1)^B ind(hat(g)_b (x)=g) $

    Chaque modèle apporte une voix à sa classe prédite.

    La classe la plus fréquente l'emporte.
  ], height: 2.9in),
  card([Moyenne des probabilités], [
    $ hat(eta)_g (x)=1/B sum_(b=1)^B hat(eta)_(b g) (x) $

    $ hat(g)_"prob" (x)=argmax_g hat(eta)_g (x) $

    Les probabilités de chaque classe contribuent à la décision.
  ], fill: pale-blue, height: 2.9in),
)
#v(0.4em)
#small([$g in \{1,dots,K\}$. Fixer une règle d'égalité.
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

    Le vote conserve seulement les décisions individuelles.
  ], height: 1.75in),
  card([Probabilités : classe 0], [
    $(0.51+0.51+0.01)/3 approx 0.343$.

    La moyenne reste sous le seuil $0.5$.
  ], fill: pale-blue, height: 1.75in),
)
#v(0.3em)
#small([La règle dépend de la méthode et du logiciel. Aucune des deux ne garantit la calibration.])

== Variance d'une moyenne de prédictions

#small([À un point $x$ fixé, l'aléa vient de l'échantillon d'entraînement
  et des tirages de l'algorithme.])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Hypothèse de variance commune], [
    $ Var(hat(f)_b (x))=sigma^2 $

    Les modèles ont la même variabilité individuelle.
  ], height: 1.8in),
  card([Hypothèse de corrélation commune], [
    $ Cov(hat(f)_b (x),hat(f)_c (x))=rho sigma^2 $

    Pour deux modèles distincts, $b!=c$.
  ], fill: pale-blue, height: 1.8in),
)
#v(0.55em)
#formula([
  $ Var(hat(f)_"ens" (x))=sigma^2 (rho+(1-rho)/B) $
])
#v(0.35em)
#small([Modèle simplifié pour comprendre l'agrégation, avec $0<=rho<=1$.])

== Propriété : la réduction dépend de la corrélation

*Preuve.* La variance d'une somme comprend les variances et les covariances :
#v(0.3em)
#formula([
  $ Var(hat(f)_"ens" (x))
    = (B sigma^2+B(B-1)rho sigma^2)/B^2
    = sigma^2 (rho+(1-rho)/B). $
])
#align(right)[$square$]
#course-table(
  columns: (1fr, 2.6fr),
  table.header([*Corrélation*], [*Effet de la moyenne*]),
  [$rho=0$], [Variance $sigma^2/B$.],
  [$rho=1$], [Variance inchangée : $sigma^2$.],
  [$0<rho<1$], [Limite $rho sigma^2$ lorsque $B$ augmente.],
)

== Le nombre d'arbres et leur dépendance

#align(center)[
  #image("../figures/ensembles_variance.svg",
    width: 100%, height: 3.8in, fit: "contain",
    alt: "La variance relative décroît vers rho. Les courbes correspondent "
      + "aux corrélations 0, 0,1, 0,5 et 0,8. L'abscisse est logarithmique.")
]
#v(0.4em)
#takeaway([Ajouter des arbres réduit surtout la part de variance qui n'est pas commune.])

== Cent modèles ne suffisent pas à effacer les erreurs communes

#small([Exemple théorique : $sigma^2=100$ et $B=100$.])
#v(0.45em)
#course-table(
  columns: (1fr, 1.5fr, 1.5fr),
  table.header([*$rho$*], [*Variance agrégée*], [*Limite quand $B$ augmente*]),
  [0,8], [$100(0.8+0.2/100)=80.2$], [80],
  [0,1], [$100(0.1+0.9/100)=10.9$], [10],
)
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Des données initiales communes], [
    Des tirages bootstrap indépendants conditionnellement au tableau
    n'effacent pas l'aléa du tableau initial.
  ], height: 1.8in),
  card([Variance et erreur totale], [
    À espérance commune, la moyenne conserve le biais.

    Le bruit de la réponse demeure.
  ], fill: pale-orange, height: 1.8in),
)

= Bagging et évaluation OOB

== Définition : le bagging

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Bootstrap aggregating], [
    Construire $B$ modèles à partir de $B$ échantillons bootstrap
    du jeu d'entraînement.

    Agréger leurs prédictions avec la règle retenue.
  ], height: 2.55in),
  card([Un échantillon bootstrap], [
    Effectuer $n$ tirages *avec remise* parmi les $n$ couples $(x_i,y_i)$.

    Les répétitions comptent dans l'apprentissage.

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

== La probabilité d'être hors bootstrap

#formula([
  $ q_n=(1-1/n)^n approx exp(-1) approx 0.368 $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Absence d'une observation], [
    Un tirage l'évite avec probabilité $1-1/n$.

    Les $n$ tirages l'évitent avec probabilité $q_n$.
  ], height: 2.15in),
  card([Nombre moyen de points distincts], [
    $ n(1-q_n) approx 0.632 n $

    Environ 63,2 % des observations apparaissent au moins une fois.
  ], fill: pale-blue, height: 2.15in),
)
#v(0.5em)
#takeaway([Le bootstrap contient toujours $n$ lignes. Les approximations supposent $n$ assez grand.])

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
#v(0.35em)
#small([Avec 500 arbres et $n$ assez grand, chaque observation reçoit
  en moyenne environ $500 times 0.368=184$ prédictions OOB.])

== Les précautions de l'évaluation OOB

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un diagnostic interne], [
    Vérifier que chaque observation reçoit des prédictions OOB.

    Sinon, augmenter $B$ ou annoncer les observations effectivement évaluées.

    Des réglages nombreux sur l'OOB appellent une évaluation finale indépendante.
  ], height: 3.05in),
  card([Un apprentissage sans fuite], [
    Une sélection supervisée de variables peut réintroduire les réponses OOB.

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

    Apprendre l'arbre sur cet échantillon, avec ses répétitions.
  ], height: 2.55in),
  card([À chaque nœud], [
    Tirer sans remise $m$ variables parmi les $p$ disponibles.

    Chercher la meilleure coupure parmi ces variables.

    Renouveler le tirage au nœud suivant.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.6em)
#takeaway([Dans ce cadre, $m=p$ retrouve le bagging d'arbres, à autres réglages identiques.])

== Deux variables candidates parmi quatre

#small([Illustration : prédire `species` à partir des quatre mesures de Palmer Penguins.])
#v(0.45em)
#formula([
  $ p=4, quad m=2, quad binom(4,2)=6, quad m/p=1/2 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un premier nœud], [
    Longueur du bec et profondeur du bec.

    La meilleure coupure vient de ces deux variables.
  ], height: 2in),
  card([Un autre nœud], [
    Longueur de la nageoire et masse corporelle.

    Le sous-ensemble candidat peut changer.
  ], fill: pale-blue, height: 2in),
)
#v(0.4em)
#small([Six paires possibles. Sous tirage uniforme, chaque variable est candidate
  avec probabilité $1/2$, sans être nécessairement choisie.])

== Variables candidates et nombre d'arbres

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le rôle de $m$], [
    Un petit $m$ peut réduire la corrélation entre arbres.

    Il peut aussi écarter les variables les plus informatives d'un nœud.

    $m approx sqrt(p)$ constitue un point de départ courant en classification.
  ], height: 2.85in),
  card([Le rôle de $B$], [
    Davantage d'arbres stabilisent l'agrégation et l'estimation OOB.

    La profondeur de chaque arbre reste inchangée.

    Le calcul devient plus coûteux.
  ], fill: pale-blue, height: 2.85in),
)
#v(0.45em)
#small([Le seuil reste optimisé parmi les variables candidates.
  Les performances à $B$ fini peuvent fluctuer.])


= Boosting et corrections successives

== Définition : un modèle additif par étapes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le modèle courant], [
    À l'étape $t$, ajuster un nouveau modèle de base en tenant compte
    des prédictions déjà obtenues.

    Ajouter sa contribution pour réduire une perte.
  ], height: 2.6in),
  card([Des corrections simples], [
    Une *souche* est un arbre à une seule coupure, donc à deux feuilles.

    Plusieurs corrections simples peuvent former une prédiction détaillée.

    Les étapes dépendent les unes des autres.
  ], fill: pale-blue, height: 2.6in),
)
#v(0.6em)
#takeaway([Les corrections peuvent être négatives et leurs coupures peuvent varier au fil des étapes.])

== Régression quadratique : la mise à jour

#small([Perte $L(y,z)=(y-z)^2/2$. Le modèle initial est $F^((0))(x)=overline(y)$.])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Les résidus courants], [
    $ r_i^((t))=y_i-F^((t-1))(x_i) $

    Ajuster $h_t$ aux couples $(x_i,r_i^((t)))$.

    Chaque feuille prédit la moyenne de ses résidus.
  ], height: 2.25in),
  card([Une correction réduite], [
    $ F^((t))(x)=F^((t-1))(x)+nu h_t (x) $

    $nu$ est le taux d'apprentissage.

    Dans ce cadre, $0<nu<=1$.
  ], fill: pale-blue, height: 2.25in),
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

#small([Les nouveaux résidus sont $(-2.75,-1.75,-0.75,0.75,1.75,2.75)$.])
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

    L'arbre approche une direction de diminution de cette perte.
  ], height: 2.3in),
  card([Le cas quadratique], [
    $ -(partial L)/(partial z)=y-z $

    Les pseudo-résidus coïncident avec les résidus ordinaires.
  ], fill: pale-blue, height: 2.3in),
)
#v(0.4em)
#small([Selon l'algorithme, les valeurs des feuilles et l'amplitude du pas
  peuvent être réoptimisées pour la perte choisie.])

== Classification binaire : corriger un score

#small([Ici, $y_i in \{0,1\}$. Le modèle $F$ fournit un score réel.])
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

    Une valeur positive pousse le score vers la classe 1.
  ], height: 2in),
  card([Prédiction finale], [
    Les arbres apportent des corrections numériques au score.

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
#v(0.4em)
#small([En multiclasse, plusieurs scores donnent des probabilités de somme 1.
  Une étape peut construire plusieurs arbres.])

= AdaBoost et repondération

== L'erreur pondérée du classificateur courant

#small([Convention binaire : $y_i in \{-1,+1\}$ et $h_t (x) in \{-1,+1\}$.
  Au départ, $w_i^((1))=1/n$.])
#v(0.5em)
#formula([
  $ epsilon_t=sum_(i=1)^n w_i^((t)) ind(h_t (x_i)!=y_i), quad
    sum_(i=1)^n w_i^((t))=1 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Apprentissage pondéré], [
    Ajuster $h_t$ avec les poids courants.

    Une erreur sur une observation de poids élevé compte davantage.
  ], height: 2in),
  card([Poids du classificateur], [
    $ alpha_t=1/2 log((1-epsilon_t)/epsilon_t) $

    Formule utilisée si $0<epsilon_t<1/2$.
  ], fill: pale-blue, height: 2in),
)

== La mise à jour des poids

#formula([
  $ w_i^((t+1))=
    (w_i^((t)) exp(-alpha_t y_i h_t (x_i)))/Z_t $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Observation mal classée], [
    $y_i h_t (x_i)=-1$.

    Son poids est multiplié par $exp(alpha_t)$ avant normalisation.
  ], height: 1.65in),
  card([Observation bien classée], [
    $y_i h_t (x_i)=1$.

    Son poids est multiplié par $exp(-alpha_t)$ avant normalisation.
  ], fill: pale-blue, height: 1.65in),
)
#v(0.5em)
#formula([
  $ hat(g)(x)=signe(sum_(t=1)^T alpha_t h_t (x)) $
])
#v(0.25em)
#small([$Z_t$ normalise les poids. Fixer une décision quand le score final est nul.])

== Deux erreurs sur dix observations

#formula([
  $ epsilon_1=0.2, quad alpha_1=1/2 log(4)=log(2) approx 0.693 $
])
#v(0.5em)
#course-table(
  columns: (1.5fr, 0.8fr, 1fr, 1.2fr, 1.2fr),
  table.header([*Prédiction*], [*Effectif*], [*Poids initial*],
    [*Avant normalisation*], [*Poids final*]),
  [Incorrecte], [2], [0,1], [0,2], [0,25],
  [Correcte], [8], [0,1], [0,05], [0,0625],
)
#v(0.55em)
#formula([
  $ Z_1=2 times 0.2+8 times 0.05=0.8 $
])
#v(0.5em)
#takeaway([Les deux erreurs représentent désormais la moitié du poids total.])

== Les limites de la repondération

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Cas particuliers], [
    Un classificateur parfait donne $epsilon_t=0$.

    Une erreur pondérée d'au moins $1/2$ ne satisfait pas la condition annoncée.

    Prévoir un arrêt, un rejet ou une adaptation de l'étape.
  ], height: 2.7in),
  card([Observations mal étiquetées], [
    Elles peuvent recevoir des poids importants au fil des étapes.

    Le contrôle du bruit et de la complexité reste nécessaire.

    Le réajustement porte sur les observations repondérées.
  ], fill: pale-orange, height: 2.7in),
)

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

    Le couple $(T,nu)$ contrôle le chemin d'apprentissage.
  ], height: 2.55in),
  card([Complexité des arbres], [
    Des arbres plus profonds permettent des interactions plus complexes.

    Une somme de souches reste additive dans les variables,
    sur l'échelle du score.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.6em)
#takeaway([Augmenter seulement le nombre de souches ne permet pas de représenter toutes les interactions.])

== L'arrêt précoce

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Suivi pendant l'apprentissage], [
    Calculer une perte sur des données de validation à plusieurs étapes.

    Retenir une étape avant sa dégradation.

    Préciser la tolérance et le nombre d'étapes d'attente éventuels.
  ], height: 2.7in),
  card([Rôle des données], [
    La validation participe au choix du modèle.

    L'erreur d'entraînement peut encore diminuer.

    Le test final reste réservé à l'évaluation après sélection.
  ], fill: pale-orange, height: 2.7in),
)

== Palmer Penguins : une grille illustrative

#small([Réponse : `species`. Quatre mesures quantitatives.
  Partage de CART : 240 observations d'entraînement et 102 de test.])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Forêt aléatoire], [
    $B=500$ arbres.

    $m in \{1,2,4\}$.

    Taille minimale des feuilles dans $\{1,5\}$.

    *6 configurations.*
  ], height: 2.45in),
  card([Gradient boosting], [
    $T in \{50,100,200\}$.

    $nu in \{0.03,0.1\}$.

    Profondeur maximale dans $\{1,2,3\}$.

    *18 configurations.*
  ], fill: pale-blue, height: 2.45in),
)
#v(0.5em)
#takeaway([Cette grille illustre les réglages. Elle ne constitue pas un résultat de performance.])

== Un protocole de comparaison commun

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Fixer le protocole], [
    Choisir la perte, la grille et les cinq plis stratifiés de l'entraînement.
  ], height: 1.7in),
  card([2. Comparer dans les plis], [
    Reconstruire tous les arbres dans chaque pli.

    Utiliser les mêmes observations de validation.
  ], fill: pale-blue, height: 1.7in),
  card([3. Réajuster], [
    Sélectionner les réglages et apprendre le modèle sur les 240 observations.
  ], fill: pale-purple, height: 1.7in),
  card([4. Évaluer sur le test réservé], [
    Matrice de confusion, sensibilité par espèce et mesure globale choisie.
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

    L'importance par diminution d'impureté décrit les arbres appris.
  ], height: 2.5in),
  card([Contribution aux prédictions], [
    Perturber une variable et mesurer la dégradation des prédictions.

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

    Une analyse locale peut faire ressortir d'autres variables
    pour une prédiction particulière.
  ], height: 2.55in),
  card([Une relation parfois complexe], [
    Une importance élevée peut venir d'un seuil, d'une relation
    non monotone ou d'une interaction.

    Elle ne donne pas le sens de l'effet d'une hausse de la variable.
  ], fill: pale-blue, height: 2.55in),
)
#v(0.55em)
#small([Une importance ne se réduit ni au signe d'un coefficient ni à une corrélation avec la réponse.])

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
#v(0.45em)
#small([MDI : _mean decrease in impurity_. Avec Gini : importance de Gini.
  Compter les répétitions bootstrap. Avec des poids, utiliser les sommes de poids.])

== Exemple : le gain à la racine

#small([Un arbre fictif sur 100 observations : 50 A et 50 B.
  La racine a une impureté de Gini égale à $0.5$.])
#v(0.5em)
#course-table(
  columns: (1.4fr, 1fr, 1fr, 1fr),
  table.header([*Après la coupure sur $X_1$*], [*A*], [*B*], [*Gini*]),
  [Nœud gauche], [40], [10], [0,32],
  [Nœud droit], [10], [40], [0,32],
)
#v(0.55em)
#formula([
  $ A_1=0.5-(50/100)0.32-(50/100)0.32=0.18 $
])
#v(0.5em)
#takeaway([Les gains des coupures tiennent compte des effectifs concernés.])

== Exemple : les gains des deux nœuds suivants

#small([Supposons que $X_2$ sépare parfaitement les classes dans chacun
  des deux nœuds de 50 observations.])
#v(0.5em)
#formula([
  $ A_2=(50/100)0.32+(50/100)0.32=0.32 $
])
#v(0.5em)
#course-table(
  columns: (1fr, 1.2fr, 1.6fr),
  table.header([*Variable*], [*Gain attribué*], [*Part du gain total*]),
  [$X_1$], [0,18], [36 %],
  [$X_2$], [0,32], [64 %],
  [Total], [0,50], [100 %],
)
#v(0.55em)
#takeaway([La variable utilisée à la racine n'est pas nécessairement la plus importante au total.])

== Normalisation et limites de l'importance MDI

#formula([
  $ a_j=A_j/(sum_(ell=1)^p A_ell), quad sum_(j=1)^p a_j=1 $
])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une part des gains attribués], [
    Si $a_j=0.30$, la variable reçoit 30 % du gain total selon cette convention.

    Ce nombre n'est pas une proportion de variance expliquée
    ou de bonnes prédictions.
  ], height: 2.55in),
  card([Des occasions de gains fortuits], [
    Beaucoup de seuils ou de modalités peuvent favoriser une variable.

    Un identifiant presque unique peut recevoir un score élevé
    dans des arbres surajustés.
  ], fill: pale-orange, height: 2.55in),
)
#v(0.35em)
#small([Normaliser seulement si le gain total est positif.
  Les conventions de normalisation peuvent varier selon le logiciel.])

== Importance par permutation : le protocole

#small([Conserver le modèle appris et utiliser de préférence des observations d'évaluation.])
#v(0.4em)
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

== Exemple : une importance en points d'erreur

#small([Classificateur fictif : 5 erreurs sur 100 observations d'évaluation.
  Cinq permutations par variable.])
#v(0.45em)
#course-table(
  columns: (0.7fr, 2.2fr, 1.1fr, 1.2fr),
  table.header([*Variable*], [*Erreurs après permutation*],
    [*Taux moyen*], [*Importance*]),
  [$X_1$], [11, 12, 13, 12, 12], [12 %], [+7 points],
  [$X_2$], [5, 6, 7, 6, 6], [6 %], [+1 point],
  [$X_3$], [4, 5, 5, 4, 6], [4,8 %], [−0,2 point],
)
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Pour $X_1$], [
    $P_1=0.12-0.05=0.07$.

    Brouiller la variable coûte sept points d'erreur à ce modèle.
  ], height: 1.65in),
  card([Pour $X_3$], [
    Légère amélioration après permutation.

    Fluctuations ou usage nuisible sont possibles.
  ], fill: pale-orange, height: 1.65in),
)

== Unités et interprétation d'une permutation

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une unité liée à la perte], [
    Points de taux d'erreur pour la classification.

    Unités au carré pour une erreur quadratique.

    Les importances ne somment généralement pas à 1.
  ], height: 2.65in),
  card([Un diagnostic à contextualiser], [
    Le classement peut changer avec la perte, les probabilités
    ou le poids d'une classe rare.

    Une petite importance négative ne suffit pas à justifier une suppression.
  ], fill: pale-orange, height: 2.65in),
)
#v(0.5em)
#takeaway([Supprimer une variable puis réentraîner mesure la capacité d'un nouvel apprentissage à s'en passer.])

== Une variable informative mais inutilisée

#formula([
  $ X_2=X_1 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le modèle a choisi $X_1$], [
    Aucune coupure n'utilise $X_2$.

    Son importance MDI est nulle.

    Permuter $X_2$ ne change aucune prédiction.
  ], height: 2.25in),
  card([L'information reste disponible], [
    $X_2$ contient exactement la même information que $X_1$.

    Après retrait de $X_1$ et réentraînement, un autre arbre pourrait
    utiliser $X_2$.
  ], fill: pale-blue, height: 2.25in),
)
#v(0.5em)
#takeaway([Le score nul décrit l'usage de la variable par le modèle fixé.])

== Variables liées et permutation groupée

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Permutation d'une seule variable], [
    Elle peut créer des combinaisons de valeurs peu plausibles
    lorsque les variables sont liées.

    L'information redondante complique les scores individuels.
  ], height: 2.65in),
  card([Permutation d'un groupe], [
    Permuter plusieurs colonnes avec le même ordre de lignes.

    Leurs relations internes restent intactes.

    Leurs liens avec le reste des données sont rompus.
  ], fill: pale-blue, height: 2.65in),
)
#v(0.55em)
#small([L'importance obtenue appartient au groupe.
  Elle ne se répartit pas automatiquement entre ses variables.])

== Stabilité des importances

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Répéter les permutations], [
    Rapporter leur moyenne et leur dispersion.

    Cette dispersion décrit l'aléa des permutations pour un modèle
    et un échantillon fixés.
  ], height: 2.5in),
  card([Répéter les ajustements], [
    Changer les partitions ou les rééchantillonnages adaptés.

    Examiner si le classement des variables demeure semblable.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.6em)
#takeaway([La dispersion des permutations seule ne constitue pas un intervalle de confiance. Une importance n'est pas une valeur-$p$.])

== Palmer Penguins : une démarche d'interprétation

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([Qualité des prédictions], [
    Vérifier d'abord la prédiction de `species`, y compris les erreurs par espèce.
  ], height: 1.75in),
  card([Permutations dans les plis], [
    Pour chaque pli, utiliser le modèle appris sans ses observations.
  ], fill: pale-blue, height: 1.75in),
  card([Comparaison des classements], [
    Examiner les quatre mesures, leurs dépendances et la perte choisie.
  ], fill: pale-purple, height: 1.75in),
  card([Sélection éventuelle], [
    Si l'importance sert à choisir les variables, intégrer ce choix au réglage.
  ], fill: pale-orange, height: 1.75in),
)
#v(0.4em)
#small([Le test final reste réservé au modèle retenu.
  Une permutation OOB utilise les seuls arbres OOB de chaque observation.])

= Synthèse et limites

== Importance prédictive et causalité

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Le comportement du modèle], [
    Une variable peut servir de marqueur d'une autre caractéristique
    ou d'un biais de collecte.

    Une forte importance décrit un usage prédictif.
  ], height: 2.45in),
  card([Exemple : la masse d'un manchot], [
    `body_mass_g` peut aider à prédire `species`.

    Cela ne signifie pas qu'une modification de la masse ferait changer l'espèce.
  ], fill: pale-orange, height: 2.45in),
)
#v(0.6em)
#takeaway([Les importances ne démontrent pas d'effets causaux.])

== Les limites des prédictions agrégées

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Classification], [
    Vérifier la calibration des probabilités.

    Examiner les classes rares et les coûts d'erreur.

    Une bonne exactitude globale peut masquer une classe mal prédite.
  ], height: 2.6in),
  card([Régression], [
    Les moyennes de valeurs de feuilles restent entre les réponses
    minimale et maximale de l'entraînement.

    Le boosting peut sortir de cet intervalle, sans garantie
    d'extrapolation pertinente.
  ], fill: pale-orange, height: 2.6in),
)
#v(0.5em)
#small([Le classement des variables complète l'examen des erreurs
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
  [AdaBoost binaire], [Classificateurs ajustés sur des poids actualisés.],
    [Vote pondéré par les $alpha_t$.],
)
#v(0.55em)
#takeaway([La validation doit porter sur la procédure complète, y compris les réglages et la sélection des variables.])
#v(0.3em)
#small([Support : chapitre « Apprentissage supervisé », section « Méthodes ensemblistes ».])
