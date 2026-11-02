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
    #v(1em)
    Les niveaux donnent des descriptions plus ou moins détaillées
    des mêmes observations.
  ], height: 2.6in),
  card([Le dendrogramme], [
    Les feuilles représentent les observations.
    #v(1em)
    Les nœuds internes représentent les regroupements.
    #v(1em)
    La hauteur d'une fusion indique la valeur du critère utilisé.
  ], fill: pale-blue, height: 2.6in),
)


== Démarches ascendante et descendante

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Ascendante : la CAH], [
    Partir de $n$ groupes d'une observation.
    #v(1em)
    Réunir deux groupes à chaque étape.
    #v(1em)
    Après $r$ fusions, il reste #box[$n-r$] groupes.
  ], height: 2.5in),
  card([Descendante], [
    Partir d'un groupe contenant toutes les observations.
    #v(1em)
    Le subdiviser progressivement.
    #v(1em)
    La procédure exige un critère de division.
  ], fill: pale-blue, height: 2.5in),
)
#v(0.65em)
#takeaway([On étudie ici la CAH. Une méthode descendante n'inverse généralement pas ses fusions.])

== Dendrogramme et arbre CART

#course-table(
  columns: (1.15fr, 1.6fr, 1.6fr),
  table.header([*Élément*], [*Dendrogramme*], [*Arbre CART*]),
  [Objectif], [Grouper les observations], [Prédire une réponse],
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
    #v(1em)
    Pour des mesures quantitatives, on peut utiliser la distance euclidienne.
    #v(1em)
    Centrer et réduire modifie le poids des variables.
  ], height: 2.8in),
  card([Entre groupes], [
    $D(A,B)$ compare deux groupes non vides et disjoints.
    #v(1em)
    Une même matrice de dissimilarités peut conduire à plusieurs hiérarchies.
    #v(1em)
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
    #v(1em)
    Calculer les liaisons initiales.
  ], height: 1.6in),
  card([2. Choisir et fusionner], [
    Retenir la paire qui minimise $D(A,B)$.
    #v(1em)
    Enregistrer sa réunion et sa hauteur.
  ], fill: pale-blue, height: 1.6in),
  card([3. Actualiser], [
    Recalculer les liaisons entre le groupe $A union B$ et les groupes restants.
  ], fill: pale-purple, height: 1.6in),
  card([4. Répéter], [
    Continuer jusqu'à un seul groupe.
    #v(1em)
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
    #v(1em)
    Elle n'examine pas toutes les hiérarchies possibles.
    #v(1em)
    Une erreur précoce affecte les coupes suivantes.
  ], height: 2.5in),
  card([Les égalités du critère], [
    Une règle de départage est nécessaire.
    #v(1em)
    L'ordre des observations ou le logiciel peut modifier certaines branches.
    #v(1em)
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
    #v(1em)
    Un seul contact peut rapprocher deux groupes.
    #v(1em)
    La liaison peut suivre des formes allongées, avec un risque d'effet de chaîne.
  ], height: 3in),
  card([Complète : la paire la plus éloignée], [
    $ D_"complète" (A,B)=max_(i in A, ell in B) d_(i ell) $
    #v(1em)
    Les paires les plus éloignées interviennent.
    #v(1em)
    Les groupes ont tendance à avoir un faible diamètre, sensible aux valeurs extrêmes.
  ], fill: pale-blue, height: 3in),
)
#v(0.35em)
$n_A=abs(A)$ et $n_B=abs(B)$ désignent les effectifs des groupes.

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
    #v(1em)
    Toutes les paires entre groupes ont le même poids.
    #v(1em)
    On résume $n_A n_B$ distances.
  ], height: 3in),
  card([Distance entre les moyennes], [
    $ D_"centr" (A,B)
      =norm(overline(x)_A-overline(x)_B) $
    #v(1em)
    Les centroïdes résument les groupes.
    #v(1em)
    Des groupes étendus peuvent avoir des moyennes proches.
  ], fill: pale-blue, height: 3in),
)

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
  ], height: 1.5in),
  card([Poids des anciens groupes], [
    Les coefficients valent $n_A/(n_A+n_B)$ et $n_B/(n_A+n_B)$.

    Ils valent chacun $1/2$ seulement si les effectifs sont égaux.
  ], fill: pale-blue, height: 1.5in),
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
    #v(1em)
    Les autres groupes restent inchangés.
  ], height: 1.8in),
  card([Le choix de Ward], [
    Fusionner la paire qui augmente le moins l'inertie intra-groupe totale.
    #v(1em)
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


== Six observations sur une droite

$ A=0, quad B=1, quad C=2, quad D=8, quad E=9, quad F=10. $
#v(0.45em)
#course-table(
  columns: (0.6fr, 1.5fr, 0.9fr, 0.6fr),
  table.header([*Étape*], [*Fusion*], [*$Delta W$*], [*$K$*]),
  [1], [$A$ et $B$], [0,5], [5],
  [2], [$D$ et $E$], [0,5], [4],
  [3], [$"AB"$ et $C$], [1,5], [3],
  [4], [$"DE"$ et $F$], [1,5], [2],
  [5], [$"ABC"$ et $"DEF"$], [96], [1],
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



= Lire et comparer les hiérarchies

== Ce qui se lit sur un dendrogramme

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Structure et hauteur], [
    Remonter deux branches jusqu'à leur premier nœud commun.
    #v(1em)
    Sa hauteur indique quand les deux observations se rejoignent.
    #v(1em)
    Elle dépend du critère de liaison.
  ], height: 2.65in),
  card([Position horizontale], [
    Permuter les branches issues d'un nœud conserve la même hiérarchie.
    #v(1em)
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




= Choisir une coupe et évaluer sa stabilité

== Plusieurs critères pour choisir le niveau

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([Sauts de fusion], [
    Repérer une forte hausse du coût.
    #v(1em)
    Pour les six points, la dernière fusion coûte 96, contre 1,5 précédemment.
  ], height: 2in),
  card([Qualité des partitions], [
    Comparer les silhouettes dans la distance initialement choisie.
    #v(1em)
    L'inertie seule favorise toujours davantage de groupes.
  ], fill: pale-blue, height: 2in),
  card([Effectifs et profils], [
    Examiner la signification des groupes.
    #v(1em)
    Un singleton peut signaler une observation isolée.
  ], fill: pale-purple, height: 2in),
  card([Stabilité et usage], [
    Perturber les données et comparer les regroupements.
    #v(1em)
    Le niveau utile dépend aussi de la question étudiée.
  ], fill: pale-orange, height: 2in),
)

== Stabilité par sous-échantillonnage

#grid(
  columns: (1fr, 1fr), gutter: 0.65em,
  card([1. Fixer une référence], [
    Ajuster la CAH sur toutes les observations.
    #v(1em)
    Conserver la coupe en $K$ groupes.
  ], height: 1.85in),
  card([2. Retirer une partie des données], [
    Tirer sans remise, par exemple, 80 % des observations.
    #v(1em)
    Réajuster la procédure et couper au même $K$.
  ], fill: pale-blue, height: 1.85in),
  card([3. Comparer les partitions], [
    Restreindre la référence aux points présents.
    #v(1em)
    Calculer l'ARI dans le même ordre d'observations.
  ], fill: pale-purple, height: 1.85in),
  card([4. Examiner la distribution], [
    Répéter, par exemple, 100 fois.
    #v(1em)
    Étudier la médiane, la dispersion et les faibles valeurs d'ARI.
  ], fill: pale-orange, height: 1.85in),
)
#v(0.25em)
Pour étudier toute la procédure, réestimer la standardisation sur chaque sous-échantillon.

== Les fréquences de regroupement des paires

$cal(B)_(i ell)$ contient les répétitions où les deux observations sont présentes. On suppose $abs(cal(B)_(i ell))>0$ ; $g_i^((b))$ est le groupe de $i$ à la répétition $b$.
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
