// STT-2200 : analyse discriminante de Fisher.
// Source : lectures/supervised.typ, section <discriminante-fisher>.
// Calculs : codes/analyse_discriminante_fisher.R.
// Figures SVG créées en Python dans figures/.
// Depuis la racine du dépôt :
// typst compile --root . slides/analyse_discriminante_fisher.typ
// --root . autorise l'accès aux figures du dossier voisin.
#import "../styles/slides.typ": *

#show : course-slides.with(title: [Analyse discriminante de Fisher])

#title-slide()

= Une représentation supervisée

== Observations, classes et scores

#course-table(
  columns: (1.1fr, 4fr),
  [*Notation*], [*Signification*],
  [$n$], [Nombre d'observations d'entraînement],
  [$x_i in RR^p$], [Les $p$ variables de l'observation $i$],
  [$y_i in {1,dots,K}$], [Sa classe, connue pendant l'entraînement],
  [$C_g$, $n_g$], [Indices et effectif des observations de la classe $g$],
  [$a in RR^p$], [Coefficients d'une combinaison linéaire],
  [$z_i=a^top x_i$], [Score de l'observation sur la direction $a$],
)
#v(0.7em)
#takeaway([Les étiquettes interviennent dans le choix des axes.])

== ACP et Fisher : deux directions différentes

// Source : exemple théorique de lectures/supervised.typ.
// Générateur : figures/analyse_discriminante.py.
#align(center)[
  #image("../figures/discriminante_fisher.svg", width: 94%, height: 4.3in,
    fit: "contain", alt: "L'ACP suit la forte variation horizontale commune aux "
      + "classes. Fisher suit la direction verticale qui sépare leurs moyennes.")
]
#small([
  Exemple simulé. L'ACP centrée conserve la variance totale.
  Fisher recherche une séparation relative à la dispersion interne.
])

= Dispersions dans les classes et entre classes

== Les centres des classes et le centre global

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Moyenne de la classe $g$], [
    $ overline(x)_g=1/n_g sum_(i in C_g) x_i $

    Le centre de ses $n_g$ observations.
  ], height: 2.25in),
  card([Moyenne globale], [
    $ overline(x)=sum_(g=1)^K n_g/n overline(x)_g $

    Les effectifs pondèrent les centres des classes.
  ], fill: pale-blue, height: 2.25in),
)
#v(0.7em)
#takeaway([Une classe plus nombreuse pèse davantage dans la moyenne globale.])

== L'inertie intra-groupe

#formula([
  $ W=sum_(g=1)^K sum_(i in C_g)
    (x_i-overline(x)_g)(x_i-overline(x)_g)^top $
])
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Écart mesuré], [
    Chaque observation se compare au centre de *sa propre classe*.
    Les différences entre centres n'entrent pas dans $W$.
  ], height: 2.1in),
  card([Une matrice $p times p$], [
    La diagonale décrit les dispersions par variable.
    Les autres termes décrivent les variations conjointes internes.
  ], fill: pale-blue, height: 2.1in),
)


== L'inertie inter-groupe

#formula([
  $ B=sum_(g=1)^K n_g
    (overline(x)_g-overline(x))(overline(x)_g-overline(x))^top $
])
#v(0.75em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Écart mesuré], [
    Chaque centre de classe se compare à la moyenne globale.
    Les observations d'une classe contribuent par son centre.
  ], height: 2.1in),
  card([Pondération par $n_g$], [
    Un même écart de centre contribue davantage si la classe contient plus
    d'observations.
  ], fill: pale-orange, height: 2.1in),
)

== Deux dispersions dans le plan

// Source : illustration déterministe de lectures/supervised.typ.
// Générateur Python : figures/dispersion_intra_inter.py.
#align(center)[
  #image("../figures/discriminante_dispersions.svg", width: 92%, height: 4.3in,
    fit: "contain", alt: "Deux groupes de huit et six observations. Les traits "
      + "fins relient les points à leur centre. Les flèches épaisses relient "
      + "la moyenne globale aux deux centres.")
]
#small([Dans $B$, chaque écart de centre porte un poids égal à l'effectif du groupe.])

== Décomposition et dispersion des scores

#formula([
  $ T=W+B, quad
    T=sum_(i=1)^n (x_i-overline(x))(x_i-overline(x))^top $
])
#v(0.6em)
Pour $z_i=a^top x_i$, les dispersions deviennent des scalaires.
#v(0.4em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans les classes], [
    $ a^top W a = sum_g sum_(i in C_g) (z_i-overline(z)_g)^2 $
  ], height: 1.5in),
  card([Entre les classes], [
    $ a^top B a = sum_g n_g (overline(z)_g-overline(z))^2 $
  ], fill: pale-blue, height: 1.5in),
)
#v(0.55em)
#takeaway([La projection conserve la décomposition : $a^top T a=a^top W a+a^top B a$.])

= Construire les axes discriminants

== Le critère de Fisher

#formula([
  $ J(a)=(a^top B a)/(a^top W a), quad a^top W a>0 $
])
#v(0.75em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Numérateur], [
    Éloigner les moyennes des classes après projection.
  ], height: 1.65in),
  card([Dénominateur], [
    Mesurer cet éloignement relativement à la dispersion interne.
  ], fill: pale-blue, height: 1.65in),
)
#v(0.75em)
#takeaway([Une grande valeur de $J$ indique une forte séparation relative.])
#v(0.35em)
#small([$J$ peut dépasser 1. Sa valeur ne donne pas un taux de bonne classification.])

== La longueur et le signe d'un axe

#formula([$ J(c a)=J(a), quad c != 0 $])
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Changer la longueur], [
    Le numérateur et le dénominateur se multiplient par $c^2$.

    Le rapport reste identique.
  ], height: 2.25in),
  card([Changer le signe], [
    $a$ et $-a$ donnent la même séparation.

    Les scores changent de signe et l'axe change d'orientation.
  ], fill: pale-blue, height: 2.25in),
)

== Une maximisation sous contrainte

On suppose $W$ *définie positive*.
#v(0.4em)
#formula([
  $ max_a a^top B a quad "sous" quad a^top W a=1 $
])
#v(0.5em)
Le lagrangien et sa condition stationnaire sont
#formula([
  $ cal(L)(a,lambda)=a^top B a-lambda(a^top W a-1) $
  $ 2B a-2lambda W a=0 quad <=> quad B a=lambda W a $
])
#v(0.55em)
#small([La contrainte fixe la dispersion intra-groupe projetée à 1.])

== Les valeurs propres généralisées

#formula([
  $ B a_k=lambda_k W a_k, quad
    lambda_1 >= lambda_2 >= dots >= lambda_p >= 0 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Premier axe], [
    Le vecteur associé à la plus grande valeur propre maximise $J$.

    $ max_(a != 0) J(a)=lambda_1 $
  ], height: 2.05in),
  card([Sens de $lambda_k$], [
    Multiplier l'équation par $a_k^top$ donne

    $ J(a_k)=lambda_k. $
  ], fill: pale-blue, height: 2.05in),
)
#v(0.55em)
#small([
  Si $W$ est singulière : réduire la dimension ou régulariser avec
  $W+gamma I_p$, où $gamma>0$.
])

== Pourquoi le premier axe maximise le rapport

Posons $u=W^(1/2)a$ et $M=W^(-1/2)B W^(-1/2)$.
#v(0.4em)
#formula([$ J(a)=(u^top M u)/(u^top u) $])
#v(0.5em)
La matrice $M$ est symétrique semi-définie positive.
Dans sa base orthonormée de vecteurs propres, $u=sum_j c_j u_j$.
#v(0.4em)
#formula([
  $ J(a)=(sum_j lambda_j c_j^2)/(sum_j c_j^2) <= lambda_1 $
])
#v(0.5em)
L'égalité s'obtient avec $u=u_1$, donc $a_1=W^(-1/2)u_1$. #h(1fr) $square$

== Les axes suivants

#formula([
  $ a_k^top W a_k=1, quad a_k^top W a_ell=0 quad "si" quad k != ell $
])
#v(0.6em)
- Chaque nouvel axe maximise le critère sous les contraintes précédentes.
- Les directions sont orthogonales pour la métrique de $W$.
- Elles peuvent former un angle différent de 90° dans le repère initial.
#v(0.55em)
#takeaway([
  Avec $A=(a_1,dots,a_q)$ :
  $A^top W A=I_q$ et $A^top B A=op("diag")(lambda_1,dots,lambda_q)$.
])
#v(0.35em)
#small([Des valeurs propres égales permettent plusieurs bases du même sous-espace.])

== Au plus $K-1$ axes discriminants

#formula([
  $ sum_(g=1)^K n_g (overline(x)_g-overline(x))=0 $
  $ r=op("rang")(B) <= min(p,K-1) $
])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Deux classes], [
    Au plus un axe de valeur propre strictement positive.
  ], height: 1.65in),
  card([Trois classes, quatre variables], [
    Au plus deux axes. Des centres alignés peuvent réduire ce nombre à un.
  ], fill: pale-blue, height: 1.65in),
)
#v(0.55em)
#small([Si tous les centres coïncident, $B=0$ et le critère ne distingue aucun axe.])

== La solution pour deux classes

Notons $d=overline(x)_2-overline(x)_1$, avec $d != 0$ et $W$ définie positive.
#v(0.4em)
#formula([
  $ B=(n_1 n_2)/n d d^top, quad a_1 prop W^(-1)d $
  $ lambda_1=(n_1 n_2)/n d^top W^(-1)d $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([La différence $d$], [
    Elle décrit le contraste entre les moyennes.
  ], height: 1.4in),
  card([La correction par $W$], [
    Elle tient compte des dispersions internes et des corrélations.
  ], fill: pale-blue, height: 1.4in),
)

== Le poids relatif des axes

#formula([$ "Poids de l'axe" k = lambda_k/(sum_(ell=1)^r lambda_ell) $])
#v(0.6em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Exemple : $lambda_1=9$, $lambda_2=1$], [
    Le premier axe représente 90 % de la somme des valeurs propres.

    Ce résumé porte sur le critère de séparation.
  ], height: 2.3in),
  card([Cas de deux classes], [
    L'unique axe positif représente 100 % de cette somme.

    Les distributions projetées peuvent pourtant se recouvrir.
  ], fill: pale-orange, height: 2.3in),
)

= Classer dans l'espace de Fisher

== Les nouvelles coordonnées

#formula([$ A=(a_1,dots,a_q), quad A^top W A=I_q $])
#v(0.7em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une observation], [
    $ z(x)=A^top (x-overline(x)) $

    Soustraire la moyenne de l'entraînement, puis appliquer les axes appris.
  ], height: 2.3in),
  card([Le centre de la classe $g$], [
    $ m_g=A^top (overline(x)_g-overline(x)) $

    Projeter la moyenne de classe avec la même transformation.
  ], fill: pale-blue, height: 2.3in),
)
#v(0.55em)
#small([La projection d'une nouvelle observation utilise uniquement ses mesures.])

== La règle du centre le plus proche

#formula([
  $ D_g (x)=norm(z(x)-m_g)^2
    =sum_(k=1)^q [a_k^top (x-overline(x)_g)]^2 $
  $ hat(g)_F (x)=op("argmin", limits: #true)_(g in {1,dots,K}) D_g (x) $
])
#v(0.6em)
- Calculer les coordonnées de la nouvelle observation.
- Mesurer sa distance au carré à chacun des $K$ centres.
- Retenir le centre le plus proche, avec un départage fixé en cas d'égalité.
#v(0.55em)
#takeaway([Cette règle complète la projection de Fisher par une décision de classe.])


== Deux classes : un seuil entre les centres

#formula([
  $ m_1<m_2 quad : quad
    "prédire 2 si" quad z(x)>(m_1+m_2)/2 $
])
#v(0.6em)

== Plusieurs classes : des régions de proximité

Les centres projetés découpent l'espace en régions de décision.
#v(0.5em)
#formula([
  $ D_g (x)=D_h (x) $
  $ 2(m_h-m_g)^top z(x)=norm(m_h)^2-norm(m_g)^2 $
])
#v(0.65em)
#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Dans un plan discriminant], [
    Les médiatrices des centres définissent les frontières possibles.
  ], height: 1.5in),
  card([Frontière effective], [
    Une troisième classe peut avoir un centre encore plus proche.
  ], fill: pale-blue, height: 1.5in),
)

== Ce que fournit la règle de proximité

#grid(
  columns: (1fr, 1fr), gutter: 0.8em,
  card([Une décision géométrique], [
    Une classe et des distances aux centres.

    Aucune hypothèse de normalité.

    Aucune probabilité a posteriori.
  ], height: 2.6in),
  card([Des choix à évaluer], [
    Le nombre d'axes et la règle d'affectation.

    Les centres peuvent mal résumer des classes multimodales.

    Les coûts d'erreur demandent un traitement supplémentaire.
  ], fill: pale-orange, height: 2.6in),
)
#v(0.7em)
#takeaway([Les effectifs interviennent dans $W$ et $B$, sans terme de priorité ajouté aux distances.])
