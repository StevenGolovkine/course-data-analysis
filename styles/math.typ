// Conventions communes aux chapitres. Voir styles/README.md.
// Les opérateurs restent droits et conservent leur espacement mathématique.
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Corr = math.op("Corr")
#let expect = math.bb("E")
#let prob = math.bb("P")
#let ind = math.bold("1")
#let argmin = math.op("argmin", limits: true)
#let argmax = math.op("argmax", limits: true)
#let diag = math.op("diag")
#let tr = math.op("tr")
#let rang = math.op("rang")
#let ctr = math.op("ctr")
#let CH = math.op("CH")
#let MSE = math.op("MSE")
#let MAE = math.op("MAE")
#let ER = math.op("ER")
#let Err = math.op("Err")
#let Biais = math.op("Biais")

// Seules les matrices de données sont mises en gras pour les distinguer
// des variables aléatoires X, Y et des colonnes X_j, Z_j.
#let Xmat = math.bold("X")
#let Zmat = math.bold("Z")

// Ne pas confondre l'inertie totale avec I (nombre de lignes en AFC).
#let inertia = $I_"tot"$
