// STT-2200 : classification hiérarchique.
// Source : lectures/unsupervised.typ, section <classification-hierarchique>.
// Calculs : codes/classification_hierarchique.R.
// Figures Python existantes : classification_hierarchique.py,
// cah_liaisons.py et cah_distances.py dans figures/.
// Compilation depuis la racine du dépôt :
// typst compile --root . slides/classification_hierarchique.typ
#import "../styles/slides.typ": *
#import "../styles/math.typ": ind, Corr

#show: course-slides.with(
  title: [Classification hiérarchique],
  footer-title: [Classification hiérarchique],
)

#title-slide()

= Des partitions emboîtées

== Une description à plusieurs niveaux

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une hiérarchie de groupes], [
    Chaque groupe d'une partition fine appartient entièrement à un groupe
    d'une partition plus grossière.

    Les niveaux donnent des descriptions plus ou moins détaillées
    des mêmes observations.
  ], height: 2.6in),
  card([Le dendrogramme], [
    Les feuilles représentent les observations.

    Les nœuds internes représentent les regroupements.

    La hauteur d'une fusion indique la valeur du critère utilisé.
  ], fill: pale-blue, height: 2.6in),
)
#v(0.65em)
#takeaway([Deux observations réunies dans une classification ascendante hiérarchique (CAH) ne seront plus séparées.])

== Démarches ascendante et descendante

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ascendante : la CAH], [
    Partir de $n$ groupes d'une observation.

    Réunir deux groupes à chaque étape.

    Après $r$ fusions, il reste #box[$n-r$] groupes.
  ], height: 2.5in),
  card([Descendante], [
    Partir d'un groupe contenant toutes les observations.

    Le subdiviser progressivement.

    La procédure exige un critère de division.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.65em)
#takeaway([On étudie ici la CAH. Une méthode descendante n'inverse généralement pas ses fusions.])

== Dendrogramme et arbre CART

#course-table(
  columns: (1.15fr, 1.6fr, 1.6fr),
  table.header([*Élément*], [*Dendrogramme*], [*Arbre CART*]),
  [Objectif], [Organiser les observations], [Prédire une réponse],
  [Feuilles], [Observations analysées], [Régions de prédiction],
  [Nœuds internes], [Fusions de groupes], [Questions sur les variables],
  [Réponse $y$], [Absente du regroupement], [Utilisée pour apprendre],
)
#v(0.65em)
#takeaway([Une branche du dendrogramme décrit un ensemble d'observations.])

== Variables, dissimilarité et liaison

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Entre observations], [
    $d_(i ell)=d(x_i,x_ell)$ mesure leur dissimilarité.

    Pour des mesures quantitatives, on peut utiliser la distance euclidienne.

    Centrer et réduire modifie le poids des variables.
  ], height: 2.8in),
  card([Entre groupes], [
    $D(A,B)$ compare deux groupes non vides et disjoints.

    Une même matrice de dissimilarités peut conduire à plusieurs hiérarchies.

    Le critère de liaison détermine les fusions.
  ], fill: pale-blue, height: 2.8in),
)
#v(0.4em)
#small([Variables, transformations et liaison définissent ensemble ce que signifie « être proche ».])

== L'algorithme de la CAH

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Initialiser], [
    Chaque observation forme un singleton.

    Calculer les liaisons initiales.
  ], height: 1.6in),
  card([2. Choisir et fusionner], [
    Retenir la paire qui minimise $D(A,B)$.

    Enregistrer sa réunion et sa hauteur.
  ], fill: pale-blue, height: 1.6in),
  card([3. Actualiser], [
    Recalculer les liaisons entre le groupe $A union B$ et les groupes restants.
  ], fill: pale-purple, height: 1.6in),
  card([4. Répéter], [
    Continuer jusqu'à un seul groupe.

    L'arbre contient $n-1$ fusions.
  ], fill: pale-orange, height: 1.6in),
)
#v(0.55em)
#takeaway([Les groupes changent après chaque fusion : leurs liaisons doivent être actualisées.])

== Une recherche gloutonne et irréversible

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([La meilleure fusion immédiate], [
    La CAH conserve chaque décision précédente.

    Elle n'examine pas toutes les hiérarchies possibles.

    Une erreur précoce affecte les coupes suivantes.
  ], height: 2.5in),
  card([Les égalités du critère], [
    Une règle de départage est nécessaire.

    L'ordre des observations ou le logiciel peut modifier certaines branches.

    Les fusions presque ex æquo peuvent être fragiles.
  ], fill: pale-orange, height: 2.5in),
)
#v(0.65em)
#takeaway([Un résultat déterministe sur un tableau fixé ne garantit pas sa stabilité sur un autre échantillon.])

= Les distances entre groupes

== Liaisons simple et complète

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Simple : la paire la plus proche], [
    $ D_"simple" (A,B)=min_(i in A, ell in B) d_(i ell) $

    Un seul contact peut rapprocher deux groupes.

    La liaison peut suivre des formes allongées, avec un risque d'effet de chaîne.
  ], height: 3in),
  card([Complète : la paire la plus éloignée], [
    $ D_"complète" (A,B)=max_(i in A, ell in B) d_(i ell) $

    Les paires les plus éloignées interviennent.

    Les groupes ont tendance à avoir un faible diamètre, sensible aux valeurs extrêmes.
  ], fill: pale-blue, height: 3in),
)
#v(0.35em)
#small([$n_A=abs(A)$ et $n_B=abs(B)$ désignent les effectifs des groupes.])

== Deux paires différentes sur les mêmes groupes

#align(center)[
  #image("../figures/cah_distances_extremes.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "La liaison simple utilise la paire la plus proche, à distance "
      + "1,55. La liaison complète utilise la plus éloignée, à distance 4,97.")
]
#v(0.35em)
#takeaway([La liaison simple vaut environ 1,55 et la liaison complète 4,97.])

== Liaison moyenne et liaison par centroïdes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Moyenne des distances], [
    $ D_"moy" (A,B)
      =1/(n_A n_B) sum_(i in A) sum_(ell in B) d_(i ell) $

    Toutes les paires entre groupes ont le même poids.

    On résume $n_A n_B$ distances.
  ], height: 3in),
  card([Distance entre les moyennes], [
    $ D_"centr" (A,B)
      =norm(overline(x)_A-overline(x)_B) $

    Les centroïdes résument les groupes.

    Des groupes étendus peuvent avoir des moyennes proches.
  ], fill: pale-blue, height: 3in),
)
#v(0.35em)
#small([La liaison par centroïdes suppose un espace euclidien. Sa convention logicielle doit être vérifiée.])

== Moyenne des distances et distance entre moyennes

#align(center)[
  #image("../figures/cah_distances_moyennes.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "Douze segments relient les groupes de trois et quatre points. "
      + "Leur longueur moyenne vaut 3,61. Les deux centroïdes sont distants de 3,40.")
]
#v(0.35em)
#takeaway([La moyenne de 12 longueurs vaut ici 3,61, contre 3,40 entre les centroïdes.])

== Actualiser la liaison moyenne

#formula([
  $ D_"moy" (A union B,C)
    =n_A/(n_A+n_B) D_"moy" (A,C)
    +n_B/(n_A+n_B) D_"moy" (B,C) $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Poids des observations], [
    Les $n_A n_C$ paires issues de $A$ et les $n_B n_C$ paires issues de $B$
    composent la nouvelle moyenne.
  ], height: 2.1in),
  card([Poids des anciens groupes], [
    Les coefficients valent $n_A/(n_A+n_B)$ et $n_B/(n_A+n_B)$.

    Ils valent chacun $1/2$ seulement si les effectifs sont égaux.
  ], fill: pale-blue, height: 2.1in),
)
#v(0.45em)
#small([Une moyenne non pondérée des deux anciennes liaisons définirait une autre méthode.])

== Quatre résumés d'un même exemple

$ A={0,2}, quad B={3,5}, quad d(x_i,x_ell)=abs(x_i-x_ell). $
#v(0.45em)
#course-table(
  columns: (1.2fr, 2.2fr, 0.65fr),
  table.header([*Liaison*], [*Calcul*], [*Valeur*]),
  [Simple], [$min(3,5,1,3)$], [1],
  [Complète], [$max(3,5,1,3)$], [5],
  [Moyenne], [$(3+5+1+3)/4$], [3],
  [Centroïdes], [$abs(1-4)$], [3],
)
#v(0.65em)
#takeaway([La moyenne des distances et la distance entre centroïdes coïncident ici, mais pas en général.])

= Ward et l'inertie

== Le coût d'une fusion

#formula([
  $ W(A)=sum_(i in A) norm(x_i-overline(x)_A)^2 $
  $ Delta W(A,B)=W(A union B)-W(A)-W(B) $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une perte d'homogénéité], [
    Après fusion, tous les points partagent un seul centroïde.

    Les autres groupes restent inchangés.
  ], height: 1.8in),
  card([Le choix de Ward], [
    Fusionner la paire qui augmente le moins l'inertie intra-groupe totale.

    Les observations ont ici le même poids.
  ], fill: pale-blue, height: 1.8in),
)

== Propriété : la formule de Ward

#formula([
  $ Delta W(A,B)
    = (n_A n_B)/(n_A+n_B) norm(overline(x)_A-overline(x)_B)^2 $
])
#v(0.55em)
*Preuve.* Posons $m=overline(x)_(A union B)$.
La décomposition autour des anciens centroïdes donne

$ Delta W=n_A norm(overline(x)_A-m)^2+n_B norm(overline(x)_B-m)^2. $

Les termes croisés s'annulent. En remplaçant
$m=(n_A overline(x)_A+n_B overline(x)_B)/(n_A+n_B)$,
on obtient la formule. #h(1fr) $square$
#v(0.55em)
#takeaway([Le coût dépend des effectifs et de l'écart entre les moyennes.])

== Avant et après la fusion

#align(center)[
  #image("../figures/cah_ward_inertie.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "Les écarts aux deux centroïdes donnent une inertie de 8,76. "
      + "Les écarts au centroïde commun donnent 28,58, soit un coût de 19,82.")
]
#v(0.35em)
#takeaway([$Delta W approx 28.58-8.76=19.82$ : on additionne des longueurs au carré.])

== Coût de Ward et hauteur affichée

#formula([
  $ h(A,B)=sqrt(2 Delta W(A,B)),
    quad Delta W(A,B)=h(A,B)^2/2 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Convention de R], [
    Avec `hclust` et `method = "ward.D2"`, cette formule relie
    hauteur et augmentation d'inertie.

    Fournir les distances euclidiennes ordinaires.
  ], height: 2.35in),
  card([Une géométrie précise], [
    La lecture en somme des carrés suppose un espace euclidien.

    Une dissimilarité quelconque n'a pas nécessairement cette interprétation.
  ], fill: pale-orange, height: 2.35in),
)
#v(0.4em)
#small([L'inertie et la hauteur ont des échelles différentes. `ward.D` et `ward.D2` ne sont pas interchangeables.])

== Six observations sur une droite

$ A=0, quad B=1, quad C=2, quad D=8, quad E=9, quad F=10. $
#v(0.45em)
#course-table(
  columns: (0.6fr, 1.5fr, 0.9fr, 1fr, 0.6fr),
  table.header([*Étape*], [*Fusion*], [*$Delta W$*], [*Hauteur $h$*], [*$K$*]),
  [1], [$A$ et $B$], [0,5], [1], [5],
  [2], [$D$ et $E$], [0,5], [1], [4],
  [3], [$"AB"$ et $C$], [1,5], [1,732], [3],
  [4], [$"DE"$ et $F$], [1,5], [1,732], [2],
  [5], [$"ABC"$ et $"DEF"$], [96], [13,856], [1],
)
#v(0.45em)
#small([L'ordre affiché départage les fusions ex æquo. « AB » désigne le groupe formé par A et B.])

== Les calculs de trois fusions

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux singletons], [
    $A=0$ et $B=1$.

    $ Delta W= (1 times 1)/(1+1) (0-1)^2=0.5 $
  ], height: 1.85in),
  card([Un groupe et un singleton], [
    $"AB"$ a deux points et une moyenne de $0.5$.

    $ Delta W= (2 times 1)/(2+1) (0.5-2)^2=1.5 $
  ], fill: pale-blue, height: 1.85in),
)
#v(0.6em)
#formula([
  $ Delta W("ABC","DEF")=(3 times 3)/(3+3) (1-9)^2=96 $
])
#v(0.35em)
#small([Les deux derniers groupes ont trois points chacun et des moyennes de 1 et 9.])

== Deux coupes du même dendrogramme

#align(center)[
  #image("../figures/cah_exemple.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "Dendrogramme de Ward des valeurs 0, 1, 2, 8, 9 et 10. "
      + "La coupe à 2,5 donne deux groupes, celle à 1,3 en donne quatre.")
]
#v(0.35em)
#small([Les couleurs repèrent les deux grandes branches, y compris dans le zoom à quatre groupes.])

== L'inertie d'une coupe est une somme de coûts

#formula([
  $ W(cal(C)_K)=sum_(r=1)^(n-K) Delta W_r
    =1/2 sum_(r=1)^(n-K) h_r^2 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux groupes], [
    $W_2=0.5+0.5+1.5+1.5=4$.

    Les groupes sont ${0,1,2}$ et ${8,9,10}$.
  ], height: 1.95in),
  card([Un seul groupe], [
    La dernière fusion ajoute $96$.

    $W_1=4+96=100=T$, l'inertie totale.
  ], fill: pale-blue, height: 1.95in),
)
#v(0.45em)
#small([Les singletons ont une inertie nulle. La somme télescope à chaque réunion de deux groupes.])

= Lire et comparer les hiérarchies

== Ce qui se lit sur un dendrogramme

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Structure et hauteur], [
    Remonter deux branches jusqu'à leur premier nœud commun.

    Sa hauteur indique quand les deux observations se rejoignent.

    Elle dépend du critère de liaison.
  ], height: 2.65in),
  card([Position horizontale], [
    Permuter les branches issues d'un nœud conserve la même hiérarchie.

    Deux feuilles voisines sur le dessin ne sont pas forcément proches
    dans les données.
  ], fill: pale-orange, height: 2.65in),
)
#v(0.5em)
#takeaway([Une coupe horizontale traverse autant de branches qu'il reste de groupes, hors des nœuds et sans inversion.])

== Couper par hauteur ou par nombre de groupes

#course-table(
  columns: (1.2fr, 2.7fr, 0.6fr),
  table.header([*Coupe*], [*Groupes des six observations*], [*$K$*]),
  [$h=1.3$], [$"AB", C, "DE", F$], [4],
  [Trois premières fusions], [$"ABC", "DE", F$], [3],
  [$h=2.5$], [$"ABC", "DEF"$], [2],
)
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux hauteurs identiques], [
    Les étapes 3 et 4 ont la hauteur $sqrt(3)$.

    Une droite hors des nœuds ne donne pas exactement trois groupes.
  ], height: 1.85in),
  card([Un ordre enregistré], [
    `cutree(arbre, k = 3)` conserve les trois premières fusions.

    Un autre départage peut donner une autre coupe en trois groupes.
  ], fill: pale-blue, height: 1.85in),
)

== Une inversion avec les centroïdes

#formula([
  $ A=(-1,0)^top, quad B=(1,0)^top, quad C=(0,1.8)^top $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Première fusion], [
    $A$ et $B$ sont les plus proches.

    Leur distance vaut $2$.

    Leur centroïde est $(0,0)^top$.
  ], height: 2.2in),
  card([Fusion suivante], [
    La distance du centroïde de $"AB"$ à $C$ vaut $1.8$.

    La hauteur redescend : c'est une *inversion*.

    Une coupe horizontale devient difficile à interpréter.
  ], fill: pale-orange, height: 2.2in),
)
#v(0.4em)
#small([L'emboîtement reste valide. Les liaisons simple, complète, moyenne et Ward euclidien évitent ces inversions.])

== Même distance initiale, autre liaison

$ A=0, quad B=1, quad C=3.2, quad D=5.8. $

Toutes les méthodes commencent par réunir $A$ et $B$ à hauteur $1$.
#v(0.4em)
#course-table(
  columns: (1fr, 1fr, 1fr, 0.9fr, 1.3fr),
  table.header([*Liaison*], [*$D("AB",C)$*], [*$D("AB",D)$*],
    [*$D(C,D)$*], [*Fusion suivante*]),
  [Simple], [2,2], [4,8], [2,6], [$"AB"$ et $C$],
  [Complète], [3,2], [5,8], [2,6], [$C$ et $D$],
  [Moyenne], [2,7], [5,3], [2,6], [$C$ et $D$],
)
#v(0.65em)
#takeaway([Avec $K=2$, la liaison simple donne « ABC / D », les deux autres « AB / CD ».])

== Trois dendrogrammes des quatre observations

#align(center)[
  #image("../figures/cah_liaisons.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "Les liaisons simple, complète et moyenne donnent des hauteurs "
      + "finales de 2,6, 5,8 et 4. Les coupes en deux groupes diffèrent.")
]
#v(0.35em)
#small([Les pointillés donnent deux groupes dans chaque arbre. Les hauteurs résument des critères différents.])

== Effet de chaîne et diamètre des groupes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Liaison simple], [
    À hauteur $h$, relier les paires telles que $d_(i ell)<=h$.

    Les groupes sont les composantes connexes.

    À $h=2.4$, les liens A–B et B–C réunissent A, B et C,
    même si $d(A,C)=3.2$.
  ], height: 3in),
  card([Liaison complète], [
    Les groupes d'une coupe à hauteur $h$ ont un diamètre au plus égal à $h$.

    Toutes leurs paires respectent cette borne.

    La liaison moyenne contrôle une moyenne lors des fusions,
    sans cette garantie sur chaque paire.
  ], fill: pale-blue, height: 3in),
)

== Les dissimilarités cophénétiques

#small([$u_(i ell)$ est la hauteur du premier nœud commun à $i$ et $ell$.
  On pose $u_(i i)=0$.])
#v(0.5em)
#course-table(
  columns: (1fr, 1.6fr, 1.6fr),
  table.header([*Paire*], [*Distance initiale $d$*], [*Hauteur commune $u$*]),
  [A, B], [1], [1],
  [B, C], [2,2], [2,2],
  [A, C], [3,2], [2,2],
  [A, D], [5,8], [2,6],
)
#v(0.55em)
#takeaway([Avec la liaison simple, C rejoint tout le groupe AB à une même hauteur.])
#v(0.35em)
#small([Exemple des valeurs 0, 1, 3,2 et 5,8. L'arbre ne conserve pas toutes les distances initiales.])

== Propriété : la contrainte ultramétrique

#formula([
  $ u_(i ell)<=max(u_(i j),u_(j ell)) $
])
#v(0.55em)
*Preuve.* Posons $h=max(u_(i j),u_(j ell))$ et incluons les fusions de hauteur $h$.

- $i$ et $j$ appartiennent au même groupe.
- $j$ et $ell$ appartiennent au même groupe.
- Les trois observations appartiennent donc au même groupe, d'où $u_(i ell)<=h$.
  #h(1fr) $square$

#v(0.45em)
#small([On suppose les hauteurs non négatives et non décroissantes.
  Le terme « ultramétrique » exige aussi $u_(i ell)>0$ pour $i!=ell$.
  Des observations distinctes fusionnant à hauteur nulle perdent cette séparation.])

== La corrélation cophénétique

#formula([
  $ r_"coph"=Corr((d_(i ell))_(i<ell),(u_(i ell))_(i<ell)) $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un diagnostic de l'arbre entier], [
    Mesurer la concordance linéaire entre distances initiales et
    hauteurs communes.

    Une forte corrélation n'impose pas l'égalité des distances.
  ], height: 2.2in),
  card([Une portée limitée], [
    Le diagnostic ne choisit pas $K$.

    Il ne garantit pas la pertinence d'une coupe.

    La liaison et la convention des hauteurs influencent sa lecture.
  ], fill: pale-orange, height: 2.2in),
)
#v(0.4em)
#small([En R : `cophenetic(arbre)`. La corrélation exige deux séries de variance non nulle.])

= Choisir une coupe et évaluer sa stabilité

== Plusieurs critères pour choisir le niveau

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([Sauts de fusion], [
    Repérer une forte hausse du coût.

    Pour les six points, la dernière fusion coûte 96, contre 1,5 précédemment.
  ], height: 1.85in),
  card([Qualité des partitions], [
    Comparer les silhouettes dans la distance initialement choisie.

    L'inertie seule favorise toujours davantage de groupes.
  ], fill: pale-blue, height: 1.85in),
  card([Effectifs et profils], [
    Examiner la signification des groupes.

    Un singleton peut signaler une observation isolée.
  ], fill: pale-purple, height: 1.85in),
  card([Stabilité et usage], [
    Perturber les données et comparer les regroupements.

    Le niveau utile dépend aussi de la question étudiée.
  ], fill: pale-orange, height: 1.85in),
)

== Stabilité par sous-échantillonnage

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Fixer une référence], [
    Ajuster la CAH sur toutes les observations.

    Conserver la coupe en $K$ groupes.
  ], height: 1.85in),
  card([2. Retirer une partie des données], [
    Tirer sans remise, par exemple, 80 % des observations.

    Réajuster la procédure et couper au même $K$.
  ], fill: pale-blue, height: 1.85in),
  card([3. Comparer les partitions], [
    Restreindre la référence aux points présents.

    Calculer l'ARI dans le même ordre d'observations.
  ], fill: pale-purple, height: 1.85in),
  card([4. Examiner la distribution], [
    Répéter, par exemple, 100 fois.

    Étudier la médiane, la dispersion et les faibles valeurs d'ARI.
  ], fill: pale-orange, height: 1.85in),
)
#v(0.25em)
#small([Pour étudier toute la procédure, réestimer la standardisation sur chaque sous-échantillon.])

== Les fréquences de regroupement des paires

#small([$cal(B)_(i ell)$ contient les répétitions où les deux observations sont présentes.
  On suppose $abs(cal(B)_(i ell))>0$ ; $g_i^((b))$ est le groupe de $i$ à la répétition $b$.])
#v(0.35em)
#formula([
  $ hat(pi)_(i ell)=1/abs(cal(B)_(i ell))
    sum_(b in cal(B)_(i ell)) ind(g_i^((b))=g_ell^((b))) $
])
#v(0.5em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Un noyau plus stable], [
    La paire apparaît ensemble 8 fois et reste réunie 7 fois.

    $hat(pi)_(i j)=7/8=0.875$.
  ], height: 1.6in),
  card([Une frontière plus fragile], [
    La paire apparaît ensemble 6 fois et reste réunie 3 fois.

    $hat(pi)_(i ell)=3/6=0.5$.
  ], fill: pale-orange, height: 1.6in),
)
#v(0.35em)
#small([Exemple fictif. Le dénominateur compte les apparitions communes, pas toutes les répétitions.])

== Ce qu'une stabilité élevée permet de conclure

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Résistance à une perturbation], [
    Un ARI élevé indique des regroupements peu sensibles au protocole choisi.

    L'ARI ne dépend pas des numéros attribués aux groupes.

    Un petit groupe absent d'un sous-échantillon mérite d'être signalé.
  ], height: 2.85in),
  card([Précautions d'interprétation], [
    Les fréquences de regroupement ne sont pas des probabilités de « vraies » classes.

    Une fréquence de 1 sur une seule apparition commune renseigne peu.

    La coupe en un seul groupe est toujours stable.
  ], fill: pale-orange, height: 2.85in),
)

= Étude de cas : Palmer Penguins

== Les données et la géométrie retenue

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([342 manchots complets], [
    Longueur et profondeur du bec.

    Longueur de la nageoire et masse corporelle.

    L'analyse descriptive utilise les 342 observations.
  ], height: 2.45in),
  card([Quatre mesures standardisées], [
    Centrer et réduire avec les écarts-types de diviseur $n-1$.

    Utiliser la distance euclidienne et Ward.

    L'inertie totale vaut $T=(n-1)p=1364$.
  ], fill: pale-blue, height: 2.45in),
)
#v(0.65em)
#takeaway([`species` n'intervient ni dans les distances, ni dans les fusions, ni dans le choix de $K$.])

== Comparaison des coupes de deux à huit groupes

#course-table(
  columns: (0.6fr, 1.2fr, 1.2fr, 1.5fr),
  table.header([*$K$*], [*Inertie $W_K$*], [*$1-W_K/T$*], [*Silhouette moyenne*]),
  [*2*], [*564,05*], [*58,65 %*], [*0,532*],
  [3], [391,72], [71,28 %], [0,454],
  [4], [315,67], [76,86 %], [0,418],
  [5], [240,92], [82,34 %], [0,363],
  [6], [220,19], [83,86 %], [0,335],
  [7], [199,63], [85,36 %], [0,305],
  [8], [181,36], [86,70 %], [0,259],
)
#v(0.5em)
#takeaway([La silhouette moyenne retient $K=2$ parmi ces candidats.])
#v(0.3em)
#small([Elle utilise les distances entre mesures réduites. À égalité exacte, retenir le plus petit $K$.])

== Le dendrogramme et les silhouettes

#align(center)[
  #image("../figures/cah_palmerpenguins.svg",
    width: 100%, height: 3.9in, fit: "contain",
    alt: "Dendrogramme de Ward des 342 manchots avec une coupe en deux "
      + "groupes de 219 et 123 individus. La silhouette moyenne est maximale à K égal à 2.")
]
#v(0.35em)
#small([Une seule hiérarchie fournit les sept coupes candidates. Les étiquettes individuelles sont masquées.])

== La dernière fusion et les profils retenus

#formula([
  $ h_"dernier" approx 40.00, quad
    Delta W_"dernier" approx 40.00^2/2 approx 800 $
])
#v(0.45em)
#course-table(
  columns: (0.8fr, 1fr, 1.6fr),
  table.header([*Groupe*], [*Effectif*], [*Masse moyenne*]),
  [1], [219], [3710,73 g],
  [2], [123], [5076,02 g],
)
#v(0.55em)
#takeaway([Le groupe 2 a aussi un bec et des nageoires plus longs, mais un bec moins profond.])
#v(0.35em)
#small([Numérotation par masse moyenne croissante. L'avant-dernière hauteur vaut 18,57.
  On retrouve $T-W_2=799.95$ à l'arrondi près.])

== Interprétation par les espèces après l'ajustement

#course-table(
  columns: (1fr, 1fr, 1fr, 1fr),
  table.header([*Groupe*], [*Adelie*], [*Chinstrap*], [*Gentoo*]),
  [1], [151], [68], [0],
  [2], [0], [0], [123],
)
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux profils morphologiques], [
    Le groupe 1 réunit Adelie et Chinstrap.

    Le groupe 2 contient les Gentoo.
  ], height: 1.85in),
  card([Une description a posteriori], [
    Cette coupe ne sépare pas les trois espèces.

    Les espèces aident à interpréter une partition déjà choisie.
  ], fill: pale-blue, height: 1.85in),
)
#v(0.4em)
#small([Cette partition en deux groupes coïncide avec celle des $k$-moyennes présentée dans le cours.])

== L'effet de la liaison à deux groupes

#course-table(
  columns: (1.1fr, 1.1fr, 1.1fr, 1.5fr),
  table.header([*Liaison*], [*Petit groupe*], [*Grand groupe*], [*Silhouette moyenne*]),
  [Simple], [1], [341], [0,253],
  [Complète], [123], [219], [0,532],
  [Moyenne], [123], [219], [0,532],
  [Ward], [123], [219], [0,532],
)
#v(0.65em)
#takeaway([La liaison simple réunit presque tous les manchots et laisse un singleton.])
#v(0.4em)
#small([Ce résultat décrit ces données et cette coupe. Il ne disqualifie pas la liaison simple pour d'autres formes de groupes.])

== Ward et les k-moyennes

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ward : conserver l'emboîtement], [
    Choisir des fusions successives.

    La coupe à #box[$K=3$] subdivise celle à #box[$K=2$].

    Sur Penguins, $W_3 approx 391.72$.
  ], height: 2.4in),
  card([$k$-moyennes : réaffecter les points], [
    Ajuster les centres et les affectations pour un $K$ fixé.

    Des ajustements indépendants ne sont pas forcément emboîtés.

    La solution du cours donne $W_3 approx 378.28$.
  ], fill: pale-blue, height: 2.4in),
)
#v(0.65em)
#takeaway([Une coupe de Ward ne minimise pas nécessairement l'inertie parmi toutes les partitions en $K$ groupes.])

= Mise en pratique et limites

== Les opérations essentielles dans R

#grid(
  columns: (1.15fr, 1fr), gutter: 0.8em,
  card([Une hiérarchie, plusieurs coupes], [
    ```r
    z <- scale(x)
    distances <- dist(z)
    arbre <- hclust(
      distances, method = "ward.D2"
    )
    groupes <- cutree(arbre, k = 2)
    u <- cophenetic(arbre)
    ```
  ], height: 3.1in),
  card([Les objets à interpréter], [
    `x` contient seulement les mesures choisies.

    `arbre$merge` enregistre les fusions.

    `arbre$height` contient leurs hauteurs.

    `cutree(arbre, h = ...)` demande une coupe par hauteur.
  ], fill: pale-blue, height: 3.1in),
)
#v(0.35em)
#small([La silhouette se calcule avec `distances`, pas avec `u`.])

== Le coût en mémoire

#formula([
  $ "Nombre de distances"=n(n-1)/2 $
])
#v(0.55em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Exemple : 10 000 observations], [
    $49 thin 995 thin 000$ distances.

    À huit octets chacune, près de *400 Mo* avant les autres structures de calcul.
  ], height: 2.15in),
  card([Des limites de calcul], [
    Le stockage complet croît comme $n^2$.

    Le temps dépend de l'algorithme et de la liaison.

    Pré-regrouper ou approximer modifie la hiérarchie recherchée.
  ], fill: pale-orange, height: 2.15in),
)

== Géométrie, valeurs extrêmes et nouvelles observations

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une proximité construite], [
    Les variables corrélées peuvent donner plusieurs fois du poids
    à une même caractéristique.

    Une valeur extrême peut former une petite branche ou modifier les fusions.
  ], height: 2.8in),
  card([Une affectation à définir], [
    Ajouter une observation et reconstruire l'arbre peut changer les groupes existants.

    L'affecter au centroïde le plus proche est une règle supplémentaire.

    Cette règle ne reproduit pas forcément la nouvelle CAH.
  ], fill: pale-orange, height: 2.8in),
)
#v(0.45em)
#takeaway([Une CAH construit aussi un arbre lorsque les données n'ont pas de groupes nettement séparés.])

== L'essentiel à retenir

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([Une structure à plusieurs niveaux], [
    Les partitions sont emboîtées et les fusions irréversibles.
  ], height: 1.7in),
  card([Une liaison à interpréter], [
    Simple, complète, moyenne et Ward traduisent des notions différentes
    de proximité entre groupes.
  ], fill: pale-blue, height: 1.7in),
  card([Une hauteur à lire correctement], [
    L'axe horizontal ne mesure pas une distance.

    Avec `ward.D2` dans R, $h^2/2=Delta W$.
  ], fill: pale-purple, height: 1.7in),
  card([Une coupe à justifier], [
    Silhouettes, profils et stabilité complètent la lecture du dendrogramme.
  ], fill: pale-orange, height: 1.7in),
)
#v(0.45em)
#small([Séance R : `codes/classification_hierarchique.R`.
  Support : chapitre « Apprentissage non supervisé », section « Classification hiérarchique ».])
