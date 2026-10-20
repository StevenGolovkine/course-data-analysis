# Arbres de classification et de régression (CART) — STT-2200
# Supports : lectures/supervised.typ, section CART, et slides/arbres_cart.typ.
#
# Exécution depuis la racine du dépôt :
# Dans R : source("codes/arbres_cart.R")
#   Rscript codes/arbres_cart.R
# Le script fonctionne aussi depuis codes/ ; aucune donnée n'est téléchargée.
# Dépendance : rpart, paquet recommandé de R.
# Si nécessaire, installer une seule fois avec install.packages("rpart").
#
# Parcours pour le cours :
# 1–3 : prédictions, coûts et calcul des coupures ;
# 4–6 : construction, interaction XOR et élagage ;
# 7–10 : validation et application à Palmer Penguins ;
# 11–13 : limites, graphiques et questions corrigées.
#
# Dans RStudio, les graphiques apparaissent dans Plots en fin d'exécution.
# En mode Rscript, seuls les résultats numériques sont affichés.
# Pour désactiver les graphiques : options(cart_afficher_graphiques = FALSE).
# Pour les revoir ensuite : dessiner_cours_cart().
# Aucun graphique SVG n'est créé : leurs sources restent en Python.
#
# Notations : effectif du nœud n_t, proportions p_tg, impureté I(t),
# somme des carrés SCE(t), nombre de feuilles M(T), pénalité alpha.
# Les calculs manuels utilisent x <= seuil ; rpart affiche ses propres
# inégalités. Les seuils sont entre valeurs distinctes d'entraînement.


# 0. OUTILS DE CALCUL ------------------------------------------------------

if (!requireNamespace("rpart", quietly = TRUE)) {
  stop("Installer le paquet rpart avant d'exécuter ce script.")
}

verifier_proche <- function(obtenu, attendu, tolerance = 1e-10) {
  stopifnot(
    length(obtenu) == length(attendu),
    all(is.finite(obtenu)), all(is.finite(attendu)),
    all(abs(obtenu - attendu) < tolerance)
  )
}

proportions_classes <- function(y) {
  stopifnot(length(y) > 0L, !anyNA(y))
  # table() conserve les niveaux inutilisés d'un facteur : proportion nulle.
  prop.table(table(y))
}

predire_classe <- function(y) {
  proportions <- proportions_classes(y)
  # À égalité, premier niveau du facteur (ordre de table() sinon).
  names(proportions)[which.max(proportions)]
}

gini <- function(y) {
  1 - sum(proportions_classes(y)^2)
}

entropie <- function(y) {
  proportions <- proportions_classes(y)
  positives <- proportions[proportions > 0]
  # Logarithme naturel ; on n'évalue pas log(0).
  -sum(positives * log(positives))
}

erreur_classe <- function(y) {
  1 - max(proportions_classes(y))
}

sce <- function(y) {
  stopifnot(is.numeric(y), length(y) > 0L, all(is.finite(y)))
  sum((y - mean(y))^2)
}

seuils_candidats <- function(x) {
  stopifnot(is.numeric(x), length(x) > 0L, all(is.finite(x)))
  valeurs <- sort(unique(x))
  if (length(valeurs) < 2L) return(numeric())
  head(valeurs, -1L) / 2 + tail(valeurs, -1L) / 2
}

enumerer_coupures <- function(
  x, y, min_feuille = 1L,
  critere = c("gini", "entropie", "erreur", "variance")
) {
  critere <- match.arg(critere)
  stopifnot(
    length(x) == length(y), !anyNA(y),
    length(min_feuille) == 1L, is.finite(min_feuille),
    min_feuille >= 1L, min_feuille == as.integer(min_feuille)
  )
  seuils <- seuils_candidats(x)
  impurite <- switch(
    critere,
    gini = gini, entropie = entropie, erreur = erreur_classe,
    variance = function(y) sce(y) / length(y)
  )
  avant <- impurite(y)
  resultats <- data.frame(
    seuil = numeric(), n_gauche = integer(), n_droite = integer(),
    impurite_gauche = numeric(), impurite_droite = numeric(),
    impurite_avant = numeric(), impurite_apres = numeric(), gain = numeric()
  )
  for (seuil in seuils) {
    gauche <- x <= seuil
    n_gauche <- sum(gauche)
    n_droite <- sum(!gauche)
    if (min(n_gauche, n_droite) < min_feuille) next
    impurite_gauche <- impurite(y[gauche])
    impurite_droite <- impurite(y[!gauche])
    apres <- (
      n_gauche * impurite_gauche + n_droite * impurite_droite
    ) / length(y)
    resultats[nrow(resultats) + 1L, ] <- c(
      seuil, n_gauche, n_droite, impurite_gauche, impurite_droite,
      avant, apres, avant - apres
    )
  }
  resultats
}

choisir_coupure <- function(coupures, tolerance = 1e-12) {
  # Gain strictement positif ; à égalité numérique, plus petit seuil.
  if (nrow(coupures) == 0L) return(NULL)
  meilleur_gain <- max(coupures$gain)
  if (meilleur_gain <= tolerance) return(NULL)
  admissibles <- coupures[coupures$gain >= meilleur_gain - tolerance, ]
  admissibles[which.min(admissibles$seuil), , drop = FALSE]
}

compter_feuilles <- function(arbre) {
  sum(arbre$frame$var == "<leaf>")
}

profondeur_arbre <- function(arbre) {
  # Les identifiants rpart sont 1 à la racine, puis 2i et 2i + 1.
  max(floor(log2(as.numeric(rownames(arbre$frame)))))
}


# 1. PRÉDIRE DANS UNE FEUILLE ---------------------------------------------

cat("\n1. Une règle, puis une prédiction constante par feuille\n")
predire_regle <- function(x_1, x_2) {
  ifelse(x_1 <= 2, "A", ifelse(x_2 <= 1, "B", "A"))
}
points_nouveaux <- data.frame(x_1 = c(1, 3, 3), x_2 = c(2, 0.6, 2))
points_nouveaux$prediction <- with(
  points_nouveaux, predire_regle(x_1, x_2)
)
print(points_nouveaux)

classes_feuille <- factor(rep(c("A", "B", "C"), c(7, 2, 1)))
print(proportions_classes(classes_feuille))
cat("Classe prédite :", predire_classe(classes_feuille), "\n")
verifier_proche(as.numeric(proportions_classes(classes_feuille)),
                c(0.7, 0.2, 0.1))
stopifnot(predire_regle(3, 0.6) == "B")

reponses_feuille <- c(8, 9, 10)
cat("Prédiction quadratique :", mean(reponses_feuille), "\n")
# Avec 8, 9, 30, moyenne et médiane diffèrent : la perte importe.
reponses_extremes <- c(8, 9, 30)
constantes <- c(mean(reponses_extremes), median(reponses_extremes))
comparaison_pertes <- data.frame(
  constante = constantes,
  perte_quadratique = vapply(
    constantes, function(a) sum((reponses_extremes - a)^2), numeric(1)
  ),
  perte_absolue = vapply(
    constantes, function(a) sum(abs(reponses_extremes - a)), numeric(1)
  )
)
print(comparaison_pertes)
stopifnot(
  comparaison_pertes$perte_quadratique[1] <
    comparaison_pertes$perte_quadratique[2],
  comparaison_pertes$perte_absolue[2] < comparaison_pertes$perte_absolue[1]
)

cat("\nCoûts asymétriques : neuf 0, trois 1\n")
p_positif <- 3 / 12
cout_fn <- 5
cout_fp <- 1
seuil_decision <- cout_fp / (cout_fp + cout_fn)
cout_predire_zero <- cout_fn * p_positif
cout_predire_un <- cout_fp * (1 - p_positif)
print(data.frame(
  p_positif, seuil_decision, cout_predire_zero, cout_predire_un,
  prediction = as.integer(p_positif > seuil_decision)
))
# Ici, on change la décision d'un arbre fixé, pas ses coupures.
verifier_proche(c(cout_predire_zero, cout_predire_un), c(1.25, 0.75))


# 2. CLASSIFICATION : COMPARER LES COUPURES -------------------------------

cat("\n2. Seuils candidats et gains de Gini\n")
print(seuils_candidats(c(1, 2, 4, 7)))
verifier_proche(seuils_candidats(c(1, 2, 4, 7)), c(1.5, 3, 5.5))
x_class <- seq_len(10L)
y_class <- c("A", "A", "A", "A", "B", "A", "B", "B", "A", "B")
coupures_class <- enumerer_coupures(x_class, y_class)
print(coupures_class, digits = 4, row.names = FALSE)
cat("Meilleure coupure :\n")
print(choisir_coupure(coupures_class))
verifier_proche(gini(y_class), 0.48)
verifier_proche(coupures_class$gain[coupures_class$seuil == 4.5], 16 / 75)
verifier_proche(coupures_class$gain[coupures_class$seuil == 2.5], 0.08)

# Comparer les critères à nœuds identiques, pas leurs échelles numériques.
noeuds <- list(
  pur = factor(rep("A", 10), levels = c("A", "B")),
  equilibre = rep(c("A", "B"), each = 5),
  melange = y_class
)
criteres_noeuds <- data.frame(
  noeud = names(noeuds),
  gini = vapply(noeuds, gini, numeric(1)),
  entropie = vapply(noeuds, entropie, numeric(1)),
  erreur = vapply(noeuds, erreur_classe, numeric(1))
)
print(criteres_noeuds, row.names = FALSE)
verifier_proche(as.numeric(criteres_noeuds[1, -1]), rep(0, 3))

# Gini baisse, mais le nombre d'erreurs reste égal à deux.
y_avant <- c(rep("A", 8), rep("B", 2))
gauche <- seq_along(y_avant) <= 4L
gini_apres <- mean(gauche) * gini(y_avant[gauche]) +
  mean(!gauche) * gini(y_avant[!gauche])
erreurs_apres <- sum(y_avant[gauche] != predire_classe(y_avant[gauche])) +
  sum(y_avant[!gauche] != predire_classe(y_avant[!gauche]))
print(data.frame(
  etape = c("Avant", "Après"),
  gini = c(gini(y_avant), gini_apres),
  nb_erreurs = c(sum(y_avant != predire_classe(y_avant)), erreurs_apres)
))
verifier_proche(gini_apres, 4 / 15)
stopifnot(erreurs_apres == 2L)

# Une variable qualitative pose une question d'appartenance à un ensemble.
# Avec les codes 1 = rouge, 2 = vert, 3 = bleu, un seuil unique ne peut pas
# regrouper rouge et bleu. Un facteur n'impose pas cet ordre artificiel.
modalites <- factor(rep(c("rouge", "vert", "bleu"), each = 2),
                    levels = c("rouge", "vert", "bleu"))
classes_modalites <- rep(c("A", "B", "A"), each = 2)
branche_a <- modalites %in% c("rouge", "bleu")
print(table(modalite = modalites, classe = classes_modalites))
gain_qualitatif <- gini(classes_modalites) -
  mean(branche_a) * gini(classes_modalites[branche_a]) -
  mean(!branche_a) * gini(classes_modalites[!branche_a])
gain_codage <- max(enumerer_coupures(
  as.integer(modalites), classes_modalites
)$gain)
print(data.frame(
  traitement = c("Sous-ensemble de modalités", "Codes numériques"),
  meilleur_gain_en_une_coupure = c(gain_qualitatif, gain_codage)
))
stopifnot(gain_qualitatif > gain_codage)


# 3. RÉGRESSION : DEUX PALIERS --------------------------------------------

cat("\n3. Minimiser la somme des carrés après coupure\n")
x_reg <- seq_len(6L)
y_reg <- c(1, 2, 3, 8, 9, 10)
coupures_reg <- enumerer_coupures(x_reg, y_reg, critere = "variance")
# Notre variance utilise n_t, contrairement à var(), qui utilise n_t - 1.
coupures_reg$sce_apres <- length(y_reg) * coupures_reg$impurite_apres
coupures_reg$gain_sce <- length(y_reg) * coupures_reg$gain
print(coupures_reg[, c("seuil", "sce_apres", "gain_sce")], row.names = FALSE)
seuil_reg <- choisir_coupure(coupures_reg)$seuil
moyenne_gauche <- mean(y_reg[x_reg <= seuil_reg])
moyenne_droite <- mean(y_reg[x_reg > seuil_reg])
predire_palier <- function(x) {
  ifelse(x <= seuil_reg, moyenne_gauche, moyenne_droite)
}
verifier_proche(sce(y_reg), 77.5)
verifier_proche(coupures_reg$sce_apres, c(53.2, 29.5, 4, 29.5, 53.2))
verifier_proche(c(seuil_reg, moyenne_gauche, moyenne_droite), c(3.5, 2, 9))
verifier_proche(
  sce(y_reg) - sum((y_reg - predire_palier(x_reg))^2),
  3 * 3 / 6 * (moyenne_gauche - moyenne_droite)^2
)
# Changer l'unité de x ne change pas les partitions candidates.
verifier_proche(
  enumerer_coupures(x_reg / 10, y_reg, critere = "variance")$gain,
  coupures_reg$gain
)


# 4. CONSTRUIRE L'ARBRE À DOUZE OBSERVATIONS ------------------------------

cat("\n4. Construction pas à pas : A A A A B B B B A A A A\n")
douze <- data.frame(
  x = seq_len(12L), classe = factor(rep(c("A", "B", "A"), each = 4))
)
coupures_racine <- enumerer_coupures(
  douze$x, douze$classe, min_feuille = 2L
)
print(coupures_racine[, c("seuil", "gain")], digits = 6, row.names = FALSE)
racine <- choisir_coupure(coupures_racine)
seuil_racine <- racine$seuil
a_droite <- douze$x > seuil_racine
coupures_droite <- enumerer_coupures(
  douze$x[a_droite], douze$classe[a_droite], min_feuille = 2L
)
branche_droite <- choisir_coupure(coupures_droite)
seuil_droite <- branche_droite$seuil
predire_douze <- function(x) {
  ifelse(x <= seuil_racine, "A", ifelse(x <= seuil_droite, "B", "A"))
}
print(data.frame(
  etape = c("Racine seule", "Coupure en 4,5", "Puis coupure en 8,5"),
  feuilles = c(1L, 2L, 3L),
  gini_moyen = c(gini(douze$classe), racine$impurite_apres, 0),
  nb_erreurs = c(4L, 4L, sum(predire_douze(douze$x) != douze$classe))
))
verifier_proche(c(seuil_racine, seuil_droite), c(4.5, 8.5))
verifier_proche(racine$gain, 1 / 9)
verifier_proche(mean(a_droite) * branche_droite$gain, 1 / 3)
stopifnot(identical(predire_douze(c(7.2, 10.5)), c("B", "A")))

# Même exemple avec rpart : l'ordre des branches et les départages sont
# ceux du logiciel. Comparer les prédictions, pas seulement le dessin.
controle_petit <- rpart::rpart.control(
  cp = 0, minsplit = 4, minbucket = 2, maxdepth = 5,
  xval = 0, maxsurrogate = 0
)
arbre_douze <- rpart::rpart(
  classe ~ x, data = douze, method = "class",
  parms = list(split = "gini"), control = controle_petit
)
print(arbre_douze)
stopifnot(
  compter_feuilles(arbre_douze) == 3L,
  profondeur_arbre(arbre_douze) == 2L,
  all(predict(arbre_douze, douze, type = "class") == douze$classe)
)


# 5. XOR : LES LIMITES D'UN GAIN IMMÉDIAT ----------------------------------

cat("\n5. XOR : chaque première coupure a un gain nul\n")
donnees_xor <- data.frame(
  x_1 = c(0, 0, 1, 1), x_2 = c(0, 1, 0, 1),
  classe = c("A", "B", "B", "A")
)
xor_axe_1 <- enumerer_coupures(donnees_xor$x_1, donnees_xor$classe)
xor_axe_2 <- enumerer_coupures(donnees_xor$x_2, donnees_xor$classe)
print(data.frame(
  variable = c("x_1", "x_2"),
  gain = c(xor_axe_1$gain, xor_axe_2$gain)
))
stopifnot(
  is.null(choisir_coupure(xor_axe_1)),
  is.null(choisir_coupure(xor_axe_2))
)
# Une coupure forcée sur x_1, suivie de x_2 dans chaque branche,
# donne pourtant quatre feuilles pures. Ce n'est pas un optimum glouton
# accessible si l'on impose un gain strictement positif à chaque étape.
prediction_xor <- with(
  donnees_xor, ifelse((x_1 <= 0.5) == (x_2 <= 0.5), "A", "B")
)
stopifnot(all(prediction_xor == donnees_xor$classe))


# 6. ÉLAGAGE COÛT-COMPLEXITÉ ----------------------------------------------

cat("\n6. Pénaliser le nombre de feuilles\n")
sous_arbres <- data.frame(
  nb_feuilles = c(1L, 3L, 5L), erreur = c(0.40, 0.15, 0.10)
)
alpha <- 0.03
sous_arbres$penalite <- alpha * sous_arbres$nb_feuilles
sous_arbres$cout_complexite <- sous_arbres$erreur + sous_arbres$penalite
print(sous_arbres)
stopifnot(sous_arbres$nb_feuilles[
  which.min(sous_arbres$cout_complexite)
] == 3L)

# Pour l'arbre à douze observations, C(T) est le taux d'erreur.
# Garder le diviseur GLOBAL n = 12, même pour le sous-arbre droit.
elagages <- data.frame(
  branche = c("Droite", "Racine"),
  hausse_erreur = c(4 / 12, 4 / 12),
  feuilles_supprimees = c(1L, 2L)
)
elagages$alpha_seuil <- elagages$hausse_erreur /
  elagages$feuilles_supprimees
print(elagages)
verifier_proche(elagages$alpha_seuil, c(1 / 3, 1 / 6))
# La racine est le maillon faible : passage direct de trois feuilles à une.
# Avec deux feuilles, C_alpha = 1/3 + 2 alpha, dominé par la racine
# dès alpha > 0. À alpha = 1/6, retenir le plus petit arbre.

risque_racine <- erreur_classe(douze$classe)
cp_seuil <- (1 / 6) / risque_racine
# cp est relatif au risque de la racine : alpha = cp * C(T_0).
# Éviter l'égalité exacte au seuil en arithmétique à virgule flottante.
cp_exemple <- c(0, cp_seuil - 0.01, cp_seuil + 0.01)
chemin_douze <- data.frame(
  cp = cp_exemple,
  nb_feuilles = vapply(cp_exemple, function(cp) {
    compter_feuilles(rpart::prune(arbre_douze, cp = cp))
  }, integer(1))
)
print(chemin_douze)
stopifnot(identical(chemin_douze$nb_feuilles, c(3L, 3L, 1L)))


# 7. MINIMUM DE VALIDATION OU RÈGLE D'UNE ERREUR STANDARD ------------------

cat("\n7. Exemple fictif de validation, distinct des données Penguins\n")
validation_fictive <- data.frame(
  nb_feuilles = c(2L, 4L, 8L, 16L),
  entrainement = c(0.25, 0.14, 0.08, 0.02),
  validation = c(0.26, 0.18, 0.17, 0.22),
  erreur_standard = c(0.03, 0.03, 0.03, 0.04)
)
indice_minimum <- which.min(validation_fictive$validation)
seuil_un_se <- with(
  validation_fictive, validation[indice_minimum] +
    erreur_standard[indice_minimum]
)
taille_minimum <- validation_fictive$nb_feuilles[indice_minimum]
taille_un_se <- min(validation_fictive$nb_feuilles[
  validation_fictive$validation <= seuil_un_se
])
print(validation_fictive)
cat("Minimum :", taille_minimum, "feuilles ; règle 1-SE :",
    taille_un_se, "feuilles\n")
stopifnot(taille_minimum == 8L, taille_un_se == 4L)
# L'erreur standard porte sur la perte estimée, pas sur les réponses.
# Les apprentissages des plis se recouvrent : la règle 1-SE reste
# une convention pratique, pas un test formel d'égalité des modèles.


# 8. PALMER PENGUINS : DONNÉES ET PARTAGE REPRODUCTIBLE --------------------

trouver_penguins <- function() {
  # Accepter Rscript et source(), même depuis un autre répertoire.
  arguments <- commandArgs(trailingOnly = FALSE)
  scripts <- sub("^--file=", "", arguments[grepl("^--file=", arguments)])
  sources <- vapply(sys.frames(), function(cadre) {
    if (is.null(cadre$ofile)) "" else cadre$ofile
  }, character(1))
  origines <- c(scripts, sources[nzchar(sources)])
  candidats <- c(
    file.path(dirname(origines), "..", "assets", "penguins.csv"),
    "assets/penguins.csv", "../assets/penguins.csv"
  )
  existants <- candidats[file.exists(candidats)]
  if (!length(existants)) {
    stop("Fichier assets/penguins.csv introuvable ; vérifier le dépôt.")
  }
  normalizePath(existants[1], mustWork = TRUE)
}

cat("\n8. Palmer Penguins : préparation sans téléchargement\n")
penguins <- read.csv(trouver_penguins())
variables <- c(
  "bill_length_mm", "bill_depth_mm",
  "flipper_length_mm", "body_mass_g"
)
colonnes <- c("species", variables)
cas_complets <- complete.cases(penguins[colonnes])
donnees <- penguins[cas_complets, colonnes]
donnees$species <- factor(donnees$species)
cat("Lignes exclues pour valeur manquante :", sum(!cas_complets), "\n")
# Choix explicite des cas complets ; pas une solution universelle.
# Si l'on impute, apprendre l'imputation dans chaque pli d'entraînement.

# Même partage et mêmes plis que les supports du cours.
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
indices_par_espece <- split(seq_len(nrow(donnees)), donnees$species)
indices_train <- unlist(lapply(indices_par_espece, function(indices) {
  sample(indices, size = round(0.70 * length(indices)))
}), use.names = FALSE)
train <- donnees[indices_train, ]
test <- donnees[-indices_train, ]
set.seed(2201)
nb_plis <- 5L
plis <- integer(nrow(train))
for (espece in levels(train$species)) {
  indices <- which(train$species == espece)
  plis[indices] <- sample(rep(seq_len(nb_plis), length.out = length(indices)))
}
print(rbind(entrainement = table(train$species), test = table(test$species)))
cat("Plis de validation, uniquement dans l'entraînement :\n")
print(table(espece = train$species, pli = plis))
stopifnot(
  nrow(donnees) == 342L, nrow(train) == 240L, nrow(test) == 102L,
  !any(rownames(train) %in% rownames(test)),
  all(plis %in% seq_len(nb_plis))
)


# 9. RECONSTRUIRE L'ARBRE DANS CHAQUE PLI ----------------------------------

cp_candidats <- c(0, 0.001, 0.005, 0.01, 0.02, 0.05, 0.10)
controle <- rpart::rpart.control(
  cp = 0, minsplit = 10, minbucket = 5, maxdepth = 10,
  xval = 0, maxsurrogate = 0
)
# cp = 0 : développer l'arbre sous les contraintes de taille.
# xval = 0 : désactiver la CV interne, puisque nos plis sont explicites.
# maxsurrogate = 0 : pas de coupures de remplacement, cas complets ici.
# On ne standardise pas les variables ; CART compare des seuils.

ajuster_cart <- function(donnees, tache = c("classification", "regression")) {
  tache <- match.arg(tache)
  if (tache == "classification") {
    rpart::rpart(
      species ~ bill_length_mm + bill_depth_mm +
        flipper_length_mm + body_mass_g,
      data = donnees, method = "class",
      parms = list(split = "gini"), control = controle
    )
  } else {
    # Ni la réponse body_mass_g ni species ne sont des prédicteurs.
    rpart::rpart(
      body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
      data = donnees, method = "anova", control = controle
    )
  }
}

valider_cart <- function(
  donnees, plis, cp_candidats,
  tache = c("classification", "regression")
) {
  tache <- match.arg(tache)
  niveaux_plis <- sort(unique(plis))
  stopifnot(
    length(plis) == nrow(donnees), !anyNA(plis),
    length(niveaux_plis) >= 2L, length(cp_candidats) > 0L,
    all(is.finite(cp_candidats)), all(cp_candidats >= 0)
  )
  pertes <- matrix(
    0, nrow = length(niveaux_plis), ncol = length(cp_candidats),
    dimnames = list(niveaux_plis, cp_candidats)
  )
  type <- if (tache == "classification") "class" else "vector"
  for (v in seq_along(niveaux_plis)) {
    est_validation <- plis == niveaux_plis[v]
    apprentissage <- donnees[!est_validation, ]
    validation <- donnees[est_validation, ]
    # Étape essentielle : réapprendre les coupures sans le pli de validation.
    grand_arbre <- ajuster_cart(apprentissage, tache)
    for (j in seq_along(cp_candidats)) {
      arbre <- rpart::prune(grand_arbre, cp = cp_candidats[j])
      prediction <- predict(arbre, newdata = validation, type = type)
      pertes[v, j] <- if (tache == "classification") {
        sum(prediction != validation$species)
      } else {
        sum((prediction - validation$body_mass_g)^2)
      }
    }
  }
  # Pondérer par les effectifs : total des pertes / nombre d'observations.
  # Pour la régression, racine de la MSE globale, pas moyenne des RMSE.
  risque_cv <- colSums(pertes) / nrow(donnees)
  cp_retenu <- max(cp_candidats[risque_cv == min(risque_cv)])
  list(
    cp = cp_retenu, risque_cv = risque_cv, pertes = pertes,
    effectifs_plis = as.integer(table(factor(plis, niveaux_plis)))
  )
}

cat("\n9. Choisir cp sans consulter les performances du test\n")
cv_class <- valider_cart(train, plis, cp_candidats, "classification")
cv_reg <- valider_cart(train, plis, cp_candidats, "regression")
table_validation <- data.frame(
  cp = cp_candidats,
  erreurs_classification = colSums(cv_class$pertes),
  taux_erreur = cv_class$risque_cv,
  rmse_g = sqrt(cv_reg$risque_cv)
)
print(table_validation, digits = 6, row.names = FALSE)
cat("cp classification :", cv_class$cp, "; cp régression :", cv_reg$cp, "\n")
# Même règle que le cours : minimum, puis plus grand cp à égalité.
# Ne pas utiliser la règle 1-SE de la section 7 pour ce résultat.
verifier_proche(
  table_validation$erreurs_classification, c(14, 14, 14, 11, 11, 12, 12)
)
verifier_proche(c(cv_class$cp, cv_reg$cp), c(0.02, 0.001))


# 10. RÉAJUSTER, PUIS ÉVALUER UNE FOIS SUR LE TEST -------------------------

cat("\n10. Modèles finaux et performances sur le test réservé\n")
resultats <- list()
validations <- list(classification = cv_class, regression = cv_reg)
for (tache in names(validations)) {
  selection <- validations[[tache]]
  grand_arbre <- ajuster_cart(train, tache)
  arbre <- rpart::prune(grand_arbre, cp = selection$cp)
  type <- if (tache == "classification") "class" else "vector"
  prediction <- predict(arbre, newdata = test, type = type)
  resultats[[tache]] <- list(
    arbre = arbre, grand_arbre = grand_arbre,
    cp = selection$cp, risque_cv = selection$risque_cv,
    prediction = prediction
  )
  cat(tache, ":", compter_feuilles(arbre), "feuilles ; profondeur",
      profondeur_arbre(arbre), "\n")
}
arbre_class <- resultats$classification$arbre
arbre_reg <- resultats$regression$arbre
prediction_class <- resultats$classification$prediction
prediction_reg <- resultats$regression$prediction

cat("\nClassification : règles et effectifs d'entraînement\n")
print(arbre_class, digits = 6)
confusion <- table(reelle = test$species, predite = prediction_class)
print(confusion)
rappels <- diag(confusion) / rowSums(confusion)
exactitude <- mean(prediction_class == test$species)
cat(sprintf("Exactitude : %.2f %%\n", 100 * exactitude))
cat("Rappel par espèce (%) :\n")
print(round(100 * rappels, 2))
probabilites <- predict(arbre_class, newdata = test, type = "prob")
cat("Première observation du test et proportions de sa feuille :\n")
print(test[1, ])
print(probabilites[1, ])
# Une proportion nulle n'est pas la preuve d'une impossibilité.
verifier_proche(rowSums(probabilites), rep(1, nrow(test)))
verifier_proche(probabilites[1, ], c(102 / 104, 2 / 104, 0))
confusion_attendue <- matrix(
  c(44, 1, 0, 4, 16, 0, 0, 1, 36), nrow = 3, byrow = TRUE
)
verifier_proche(as.numeric(confusion), as.numeric(confusion_attendue))
verifier_proche(rappels["Chinstrap"], 0.80)

cat("\nRégression : comparaison à la moyenne d'entraînement\n")
mesurer_regression <- function(observe, predit) {
  stopifnot(
    length(observe) == length(predit), length(observe) > 0L,
    all(is.finite(observe)), all(is.finite(predit))
  )
  c(rmse_g = sqrt(mean((observe - predit)^2)),
    mae_g = mean(abs(observe - predit)))
}
reference_reg <- rep(mean(train$body_mass_g), nrow(test))
mesures_reg <- rbind(
  arbre = mesurer_regression(test$body_mass_g, prediction_reg),
  moyenne_entrainement = mesurer_regression(test$body_mass_g, reference_reg)
)
print(round(mesures_reg, 2))
stopifnot(
  compter_feuilles(arbre_class) == 4L,
  compter_feuilles(arbre_reg) == 30L,
  all(prediction_reg >= min(train$body_mass_g)),
  all(prediction_reg <= max(train$body_mass_g))
)
verifier_proche(
  round(c(mesures_reg[1, ], mesures_reg[2, "rmse_g"]), 1),
  c(363.7, 278.4, 800.3)
)
# Ces vérifications reproduisent le jeu local et les graines du cours.
# Si les données ou rpart changent, vérifier les écarts, pas réutiliser le test
# pour chercher d'autres réglages.


# 11. LIMITES : EXTRAPOLATION, ÉCHELLES ET PETITES FEUILLES ----------------

cat("\n11. Limites à discuter\n")
# Une seule étiquette modifiée départage autrement les deux meilleures
# coupures de l'exemple à douze points. Aucune donnée de test n'intervient.
classes_modifiees <- douze$classe
classes_modifiees[1] <- "B"
racine_modifiee <- choisir_coupure(enumerer_coupures(
  douze$x, classes_modifiees, min_feuille = 2L
))
print(data.frame(
  donnees = c("Initiales", "Une étiquette modifiée"),
  seuil_racine = c(seuil_racine, racine_modifiee$seuil)
))
stopifnot(racine_modifiee$seuil != seuil_racine)

hors_domaine <- c(-10, 3.49, 3.51, 20)
print(data.frame(x = hors_domaine, prediction = predire_palier(hors_domaine)))
# Même loin des observations, les deux paliers restent 2 et 9 :
# pas d'extrapolation d'une tendance, et discontinuité autour du seuil.

# Une transformation croissante préserve les partitions d'entraînement,
# mais un milieu transformé peut classer autrement un NOUVEAU point.
valeurs <- c(1, 4)
nouveau <- 2.2
seuil_initial <- mean(valeurs)
seuil_log <- mean(log(valeurs))
print(data.frame(
  espace = c("Original", "Logarithmique"),
  seuil_dans_unites_originales = c(seuil_initial, exp(seuil_log)),
  nouveau_a_gauche = c(nouveau <= seuil_initial, log(nouveau) <= seuil_log)
))
stopifnot(
  all((valeurs <= seuil_initial) == (log(valeurs) <= seuil_log)),
  (nouveau <= seuil_initial) != (log(nouveau) <= seuil_log)
)

cat("Deux A dans une feuille : proportion empirique pour A =",
    as.numeric(proportions_classes(c("A", "A"))), "\n")
cat("Importance calculée sur l'entraînement (sans portée causale) :\n")
print(sort(arbre_class$variable.importance, decreasing = TRUE))
# Importance nulle : une variable corrélée a pu être choisie à sa place.
# Beaucoup de seuils candidats peuvent avantager une variable.
# Les ensembles d'arbres peuvent réduire l'instabilité ; hors périmètre ici.


# 12. GRAPHIQUES POUR LA DÉMONSTRATION EN CLASSE ---------------------------

dessiner_cours_cart <- function() {
  anciens_parametres <- par(no.readonly = TRUE)
  on.exit(par(anciens_parametres), add = TRUE)
  couleurs <- c("#007C78", "#D57535", "#5D6CB0")
  par(mfrow = c(1, 1), mar = c(4.5, 4.5, 4.2, 1), cex.main = 1.1)

  # A. La partition 2D de la première règle.
  plot(NA, xlim = c(0, 4), ylim = c(0, 3),
       xlab = "x1", ylab = "x2", main = "Une suite de questions locales")
  rect(0, 0, 2, 3, col = "#E5F3F1", border = NA)
  rect(2, 0, 4, 1, col = "#FFF0DE", border = NA)
  rect(2, 1, 4, 3, col = "#E5F3F1", border = NA)
  segments(2, 0, 2, 3, lwd = 2)
  segments(2, 1, 4, 1, lwd = 2)
  text(c(1, 3, 3), c(1.5, 0.3, 2), c("A", "B", "A"), cex = 1.5)
  points(3, 0.6, pch = 19, col = couleurs[2])
  text(3, 0.6, "Nouveau point", pos = 3)

  # B. Les critères ne sont pas sur la même échelle.
  p <- seq(0.001, 0.999, length.out = 300)
  courbes <- cbind(
    2 * p * (1 - p), -p * log(p) - (1 - p) * log(1 - p), pmin(p, 1 - p)
  )
  matplot(p, courbes, type = "l", lty = 1:3, lwd = 2, col = couleurs,
          xlab = "Proportion p de la classe B", ylab = "Impureté",
          main = "Impuretés pour deux classes (logarithme naturel)")
  legend("topright", c("Gini", "Entropie", "Erreur"),
         col = couleurs, lty = 1:3, lwd = 2, bty = "n")

  # C. Comparer toutes les coupures, pas seulement celles du support.
  plot(coupures_class$seuil, coupures_class$gain, type = "b",
       pch = 19, col = couleurs[1], xlab = "Seuil candidat",
       ylab = "Gain de Gini", main = "Choisir la meilleure coupure immédiate")
  abline(v = choisir_coupure(coupures_class)$seuil, lty = 2)

  # D. Régression et somme des carrés.
  par(mfrow = c(1, 2))
  plot(x_reg, y_reg, pch = 19, col = couleurs[2],
       xlab = "x", ylab = "Réponse", main = "Deux prédictions constantes")
  abline(h = mean(y_reg), lty = 2, col = "grey50")
  segments(c(1, seuil_reg), c(2, 9), c(seuil_reg, 6), c(2, 9),
           lwd = 2, col = couleurs[1])
  segments(x_reg, y_reg, x_reg, predire_palier(x_reg), col = couleurs[2])
  plot(coupures_reg$seuil, coupures_reg$sce_apres, type = "b", pch = 19,
       xlab = "Seuil candidat", ylab = "SCE après coupure",
       main = "Minimum au seuil 3,5", col = couleurs[1])

  # E. Arbre appris et régions, sur les douze observations.
  par(mar = c(2, 1, 4.2, 1))
  plot(arbre_douze, uniform = TRUE, margin = 0.15)
  text(arbre_douze, use.n = TRUE, pretty = 0, cex = 0.85)
  title("Trois feuilles, profondeur deux")
  mtext("Effectifs par feuille : A / B", side = 1, line = 0.5, cex = 0.8)
  par(mar = c(4.5, 4.5, 4.2, 1))
  plot(douze$x, as.integer(douze$classe), pch = 19,
       col = couleurs[as.integer(douze$classe)], yaxt = "n",
       ylim = c(0.7, 2.3), xlab = "x", ylab = "Classe",
       main = "Une relation non monotone")
  axis(2, at = c(1, 2), labels = levels(douze$classe))
  abline(v = c(seuil_racine, seuil_droite), lty = 2)

  # F. Coût-complexité et tailles sautées.
  par(mfrow = c(1, 1), mar = c(4.5, 4.5, 4.2, 1))
  grille_alpha <- seq(0, 0.3, length.out = 301)
  couts <- cbind(1 / 3 + grille_alpha, 1 / 3 + 2 * grille_alpha,
                 3 * grille_alpha)
  matplot(grille_alpha, couts, type = "l", col = couleurs, lty = 1:3,
          lwd = 2, xlab = expression(alpha), ylab = "Erreur + alpha M",
          main = "L'élagage passe directement de trois feuilles à une")
  abline(v = 1 / 6, lty = 3)
  legend("topleft", c("1 feuille", "2 feuilles", "3 feuilles"),
         col = couleurs, lty = 1:3, lwd = 2, bty = "n")

  # G. Un exemple fictif pour la règle 1-SE.
  with(validation_fictive, {
    plot(nb_feuilles, validation, type = "b", pch = 19,
         ylim = c(0, 0.32), xlab = "Nombre de feuilles", ylab = "Erreur",
         main = "Exemple fictif : entraînement et validation",
         col = couleurs[1])
    arrows(nb_feuilles, validation - erreur_standard,
           nb_feuilles, validation + erreur_standard,
           angle = 90, code = 3, length = 0.05, col = couleurs[1])
    lines(nb_feuilles, entrainement, type = "b", col = couleurs[2], pch = 17)
  })
  abline(h = seuil_un_se, lty = 2)
  legend("topright", c("Validation ± 1 SE", "Entraînement", "Seuil 1-SE"),
         col = c(couleurs[1:2], "black"), lty = c(1, 1, 2), bty = "n")

  # H. Les cp sont traités comme des candidats discrets sur l'abscisse.
  par(mfrow = c(1, 2))
  for (tache in names(validations)) {
    validation <- validations[[tache]]
    pertes <- if (tache == "classification") {
      100 * validation$risque_cv
    } else {
      sqrt(validation$risque_cv)
    }
    ylab <- if (tache == "classification") "Erreur (%)" else "RMSE (g)"
    titre <- if (tache == "classification") "classification" else "régression"
    plot(seq_along(cp_candidats), pertes, type = "b", pch = 19,
         xaxt = "n", xlab = "cp (candidats)", ylab = ylab,
         main = paste("Validation :", titre), col = couleurs[1])
    axis(1, at = seq_along(cp_candidats), labels = cp_candidats, cex.axis = 0.8)
    retenu <- match(validation$cp, cp_candidats)
    points(retenu, pertes[retenu], pch = 19, cex = 1.6, col = couleurs[2])
  }

  # I. Le petit arbre de classification ; pas de dessin illisible à 30 feuilles.
  par(mfrow = c(1, 1), mar = c(2, 1, 4.2, 1))
  plot(arbre_class, uniform = TRUE, margin = 0.15)
  text(arbre_class, use.n = TRUE, pretty = 0, cex = 0.8)
  title("Palmer Penguins : arbre de classification retenu")
  mtext("Effectifs par feuille : Adelie / Chinstrap / Gentoo",
        side = 1, line = 0.5, cex = 0.8)

  # J. Diagnostic final de régression, sans nouveau réglage sur le test.
  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4.2, 1))
  limites <- range(c(test$body_mass_g, prediction_reg))
  plot(test$body_mass_g, prediction_reg, pch = 19, col = couleurs[1],
       xlim = limites, ylim = limites, xlab = "Masse observée (g)",
       ylab = "Masse prédite (g)", main = "Test réservé : observé et prédit")
  abline(0, 1, lty = 2)
  plot(prediction_reg, test$body_mass_g - prediction_reg,
       pch = 19, col = couleurs[2], xlab = "Masse prédite (g)",
       ylab = "Résidu (g)", main = "Test réservé : résidus")
  abline(h = 0, lty = 2)
  invisible(NULL)
}

if (isTRUE(getOption("cart_afficher_graphiques", interactive()))) {
  dessiner_cours_cart()
}


# 13. QUESTIONS À POSER EN CLASSE — CORRIGÉS EXÉCUTABLES -------------------

# Question 1 : imposer quatre observations par feuille change-t-il le seuil
# de l'exemple de régression à six observations ?
# Corrigé : aucune coupure n'est admissible, car 4 + 4 > 6.
sans_coupure <- enumerer_coupures(
  x_reg, y_reg, min_feuille = 4L, critere = "variance"
)
stopifnot(nrow(sans_coupure) == 0L, is.null(choisir_coupure(sans_coupure)))

# Question 2 : une feuille prédit-elle toujours une classe à plus de 50 % ?
# Corrigé : non, A est la plus fréquente avec seulement 40 % ici.
multiclasse <- rep(c("A", "B", "C"), c(4, 3, 3))
stopifnot(predire_classe(multiclasse) == "A")
verifier_proche(max(proportions_classes(multiclasse)), 0.4)

# Question 3 : des probabilités égales à 1 sont-elles toutes aussi fiables ?
# Corrigé : non. Les proportions sont identiques, les effectifs diffèrent.
print(data.frame(
  effectif = c(2L, 100L),
  probabilite_a = c(
    proportions_classes(rep("A", 2)),
    proportions_classes(rep("A", 100))
  )
))

# Question 4 : pourquoi ne pas élaguer un unique arbre avant de faire la CV ?
# Corrigé : ses coupures auraient déjà utilisé les réponses de validation.
# Dans valider_cart(), ajuster_cart() est donc À L'INTÉRIEUR de la boucle.

# Question 5 : augmenter cp supprime-t-il exactement une feuille à la fois ?
# Corrigé : non ; chemin_douze passe de trois feuilles à une.

# Cas limites des fonctions de calcul : variable constante, nœud pur,
# répétitions d'une valeur et un seul élément en régression.
stopifnot(
  length(seuils_candidats(rep(2, 4))) == 0L,
  is.null(choisir_coupure(enumerer_coupures(rep(2, 4), rep("A", 4)))),
  is.null(choisir_coupure(enumerer_coupures(1:4, rep("A", 4))))
)
verifier_proche(seuils_candidats(c(1, 1, 2, 2)), 1.5)
verifier_proche(sce(8), 0)

cat("\nTous les calculs de contrôle du cours sont vérifiés.\n")
cat("Version de R :", as.character(getRversion()),
    "; rpart :", as.character(utils::packageVersion("rpart")), "\n")

# Ressources officielles complémentaires :
# https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.html
# https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.control.html
# https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/prune.rpart.html
# https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf
