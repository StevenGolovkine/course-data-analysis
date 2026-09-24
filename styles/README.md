# Conventions des notes de cours

Chaque chapitre de `lectures/` et chaque annexe de `appendices/` importe les mêmes outils :

```typst
#import "../styles/notes.typ": *
```

`main.typ` applique une seule fois `apply_notes_style`. Les chapitres ne doivent
pas redéfinir localement les couleurs, les légendes, la numérotation ou le symbole
de fin de preuve.

## Blocs pédagogiques

```typst
#definition(title: [Variance empirique])[
  Pour $n >= 2$, $Var(X_j)=1/(n-1) sum_(i=1)^n (x_(i j)-overline(x)_j)^2$.
]

#property(title: [Titre facultatif])[
  Énoncé et hypothèses.
]

#proof[
  Justification de la propriété.
]

#example(title: [Titre facultatif])[
  Situation concrète, calcul et interprétation.
]

#remark[
  Limite, précaution ou complément.
]
```

- `definition`, `property`, `theorem`, `example` et `remark` partagent un
  compteur par chapitre (par exemple, Définition 3.1, Exemple 3.2).
- Le titre est facultatif ; utiliser `title: [...]` plutôt qu'un titre en gras
  au début du contenu. Les étiquettes françaises sont définies dans `notes.typ`.
- Les petits encadrés restent d'un seul tenant. Pour un exemple dépassant une
  page, préciser `breakable: true` et contrôler ses coupures après compilation.
- Une preuve suit l'énoncé et se termine automatiquement par un carré blanc.
- Utiliser « Remarque », et non « Note ».
- Les études de cas développées occupent une sous-section « Étude de cas : … » ;
  leurs illustrations ponctuelles peuvent utiliser des blocs `example`.
- Les exercices de fin de chapitre utilisent `#exercises[...]` avec une liste
  numérotée à l'intérieur.
- Les tableaux héritent de leurs marges, bordures et couleurs communes ; ne
  préciser localement que les largeurs, alignements et exceptions nécessaires.
  Utiliser `table.header(...)` pour leurs en-têtes.

Les chapitres et les annexes utilisent les formes ci-dessus, sans variantes
locales ni appels aux anciennes fonctions `definition-box` et `property-box`.

## Typographie et organisation des concepts

- En français, laisser une espace avant et après les deux-points : `Principe :
  explication`. Un retour à la ligne après les deux-points joue le rôle d'une
  espace dans le texte composé. Cette règle ne modifie ni les URL, ni les
  exemples de code, ni les arguments nommés de Typst (`title:`, `width:`, etc.).
- Donner à chaque notion une définition de référence, avec une étiquette
  Typst, puis utiliser un renvoi (`@def-unite-statistique`, par exemple) au
  lieu de recopier la définition dans un autre chapitre.
- L'introduction fixe le vocabulaire ; le chapitre exploratoire développe
  les mesures d'erreur et la validation ; les annexes regroupent les rappels
  mathématiques et la reproductibilité. Les chapitres de méthodes conservent
  leurs applications, exemples et précautions spécifiques.
- Un rappel bref peut aider à lire une application, mais éviter de redémontrer
  le même résultat ou de répéter une liste déjà présentée ailleurs.

## Notations mathématiques

`notes.typ` réexporte les raccourcis définis avec `let` dans `math.typ`.

| Source Typst | Convention |
| --- | --- |
| `n`, `p` ; `i`, `j` | Nombre d'observations et de variables ; indices correspondants |
| `K`, `g` | Nombre de classes ou de groupes ; indice de classe ou de groupe |
| `k`, `q` | Nombre de voisins ou indice d'axe ; nombre d'axes retenus |
| `V`, `v` | Nombre de plis de validation croisée ; indice de pli |
| `Xmat`, `Zmat` | Matrices de données en gras, brutes et préparées |
| `X`, `Y` ; `x_i`, `y_i` | Variables aléatoires ; valeurs observées |
| `X_j`, `Z_j` | Colonnes des matrices de données dans les calculs empiriques |
| `overline(x)_j`, `s_j` | Moyenne et écart-type empiriques de la variable `j` |
| `Var`, `Cov`, `Corr` | Opérateurs droits de variance, covariance et corrélation |
| `expect`, `prob`, `ind(A)` | Espérance, probabilité et indicatrice d'une condition |
| `A^top` | Transposée, avec `top` (laisser une espace avant un facteur entre parenthèses) |
| `argmin`, `argmax`, `diag`, `tr`, `rang` | Opérateurs d'optimisation et d'algèbre linéaire |
| `inertia`, `ctr` | Inertie totale notée `I_"tot"` ; contribution à un axe |
| `MSE`, `MAE`, `ER`, `Err`, `Biais`, `CH` | Noms droits des critères et du biais |

Les vecteurs sont des vecteurs colonnes. Les variances et covariances empiriques
utilisent le diviseur `n-1`, sauf indication explicite. Les normalisations de
l'inertie restent propres à la méthode : ACP avec `n-1`, regroupement sans
division, AFC avec les masses des profils. Les matrices de dispersion de Fisher
et les inerties scalaires du regroupement sont reliées par la trace, mais ne
sont pas des objets de même type.

Un exposant d'itération s'écrit `^((t))` pour afficher les parenthèses ;
une puissance s'écrit `^(t)`. Le modèle excluant le pli `v` s'écrit
`hat(f)^((-v))`. Ne pas appliquer de remplacements mathématiques à l'intérieur
des blocs de code R ou Python.

## Vérification

Depuis la racine du dépôt :

```sh
typst compile --root . main.typ
git diff --check
```

Contrôler également le rendu des nouveaux encadrés, des formules longues et
des tableaux, en particulier lorsqu'ils se trouvent près d'une fin de page.
