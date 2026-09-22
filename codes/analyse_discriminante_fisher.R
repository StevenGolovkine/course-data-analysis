# Analyse discriminante de Fisher et classification au centre le plus proche.
# Depuis la racine : Rscript codes/analyse_discriminante_fisher.R
# R de base uniquement. Données locales dans assets/penguins.csv.
# Aucun modèle probabiliste LDA/QDA ni calcul de probabilité a posteriori.

ajuster_fisher <- function(x, classes, q) {
  x <- as.matrix(x)
  classes <- droplevels(factor(classes))
  niveaux <- levels(classes)
  nb_classes <- length(niveaux)
  p <- ncol(x)
  stopifnot(
    nrow(x) == length(classes), all(is.finite(x)), !anyNA(classes),
    nb_classes >= 2L, q >= 1L, q == as.integer(q),
    q <= min(p, nb_classes - 1L)
  )

  effectifs <- as.numeric(table(classes))
  centres <- t(vapply(niveaux, function(g) {
    colMeans(x[classes == g, , drop = FALSE])
  }, numeric(p)))
  moyenne <- colMeans(x)
  residus <- x - centres[as.character(classes), , drop = FALSE]
  dispersion_intra <- crossprod(residus)
  ecarts_centres <- sweep(centres, 2, moyenne, "-")
  dispersion_inter <- crossprod(ecarts_centres * sqrt(effectifs))
  dispersion_totale <- crossprod(sweep(x, 2, moyenne, "-"))

  # W = R^T R : résoudre le problème symétrique R^(-T) B R^(-1).
  # chol() échoue si W n'est pas définie positive : pas de régularisation
  # implicite ni d'inversion d'une matrice singulière dans cet exemple.
  facteur <- chol(dispersion_intra)
  inverse_facteur <- backsolve(facteur, diag(p))
  matrice_symetrique <- crossprod(
    inverse_facteur, dispersion_inter %*% inverse_facteur
  )
  decomposition <- eigen(
    (matrice_symetrique + t(matrice_symetrique)) / 2, symmetric = TRUE
  )
  valeurs <- decomposition$values
  tolerance <- 1e-10 * max(1, max(abs(valeurs)))
  stopifnot(sum(valeurs > tolerance) >= q)
  axes <- inverse_facteur %*%
    decomposition$vectors[, seq_len(q), drop = FALSE]

  # Fixer seulement le signe : le coefficient de plus grande valeur absolue
  # est positif. Les distances ne dépendent pas de ce choix d'orientation.
  signes <- apply(axes, 2, function(a) sign(a[which.max(abs(a))]))
  axes <- sweep(axes, 2, signes, "*")
  colnames(axes) <- paste0("F", seq_len(q))
  rownames(axes) <- colnames(x)
  centres_projetes <- ecarts_centres %*% axes
  valeurs_diagonales <- diag(valeurs[seq_len(q)], nrow = q, ncol = q)

  stopifnot(
    max(abs(dispersion_totale - dispersion_intra - dispersion_inter)) < 1e-6,
    max(abs(crossprod(axes, dispersion_intra %*% axes) - diag(q))) < 1e-8,
    max(abs(crossprod(axes, dispersion_inter %*% axes) -
              valeurs_diagonales)) < 1e-8
  )

  list(
    moyenne = moyenne, axes = axes, centres = centres_projetes,
    classes = niveaux, valeurs = valeurs[seq_len(q)],
    dispersion_intra = dispersion_intra, dispersion_inter = dispersion_inter
  )
}

predire_fisher <- function(modele, nouveau) {
  nouveau <- as.matrix(nouveau)
  stopifnot(
    nrow(nouveau) >= 1L, ncol(nouveau) == length(modele$moyenne),
    all(is.finite(nouveau))
  )
  # Garder le même ordre de variables qu'à l'entraînement.
  if (!is.null(colnames(nouveau))) {
    stopifnot(identical(colnames(nouveau), names(modele$moyenne)))
  }
  scores <- sweep(nouveau, 2, modele$moyenne, "-") %*% modele$axes
  distances2 <- vapply(seq_along(modele$classes), function(g) {
    rowSums(sweep(scores, 2, modele$centres[g, ], "-")^2)
  }, numeric(nrow(scores)))
  distances2 <- matrix(
    distances2, nrow = nrow(scores),
    dimnames = list(rownames(nouveau), modele$classes)
  )
  # Minimum exact ; en cas d'égalité, première classe dans l'ordre des niveaux.
  indices <- apply(distances2, 1, which.min)
  list(
    classe = factor(modele$classes[indices], levels = modele$classes),
    scores = scores, distances2 = distances2
  )
}

penguins <- read.csv("assets/penguins.csv")
variables <- c(
  "bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"
)
d <- penguins[complete.cases(penguins[c("species", variables)]),
              c("species", variables)]
d$species <- factor(d$species)

# Même partage stratifié que les exemples k-NN et LDA du cours.
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
indices <- split(seq_len(nrow(d)), d$species)
idx_train <- unlist(lapply(indices, function(i) {
  sample(i, size = round(0.70 * length(i)))
}), use.names = FALSE)
idx_test <- setdiff(seq_len(nrow(d)), idx_train)
train <- d[idx_train, ]
test <- d[idx_test, ]

# Deux axes fixés avant le test : conserver tous les contrastes des 3 espèces.
# W et B sont calculées uniquement sur les 240 observations d'entraînement.
modele <- ajuster_fisher(train[variables], train$species, q = 2L)
prediction <- predire_fisher(modele, test[variables])
confusion <- table(Reelle = test$species, Predite = prediction$classe)
exactitude <- mean(prediction$classe == test$species)
rappels <- diag(confusion) / rowSums(confusion)

cat("Effectifs par espèce :\n")
print(rbind(
  Total = table(d$species), Entrainement = table(train$species),
  Test = table(test$species)
))
cat("\nValeurs propres et poids relatifs des deux axes :\n")
print(data.frame(
  axe = colnames(modele$axes), valeur = modele$valeurs,
  pourcentage = 100 * modele$valeurs / sum(modele$valeurs)
), digits = 6)
cat("\nCoefficients des axes (A^T W A = I) :\n")
print(modele$axes, digits = 7)
cat("\nMoyenne globale de l'entraînement :\n")
print(modele$moyenne, digits = 7)
cat("\nCentres projetés des espèces :\n")
print(modele$centres, digits = 6)
cat("\nPremière observation de test, ligne originale du CSV :\n")
print(test[1, , drop = FALSE])
cat("Coordonnées de Fisher :\n")
print(prediction$scores[1, , drop = FALSE], digits = 6)
cat("Distances au carré aux centres :\n")
print(prediction$distances2[1, , drop = FALSE], digits = 6)
cat("Classe prédite :", as.character(prediction$classe[1]), "\n")
cat("\nMatrice de confusion du test (lignes : classes réelles) :\n")
print(confusion)
cat(sprintf("\nExactitude : %.2f %%\n", 100 * exactitude))
cat(sprintf("Taux d'erreur : %.2f %%\n", 100 * (1 - exactitude)))
cat("Rappel par espèce (%) :\n")
print(round(100 * rappels, 2))

# Tests : absence de recouvrement entraînement/test, prédiction d'une seule
# observation, invariance au signe des axes et à une rotation orthogonale.
stopifnot(
  length(intersect(idx_train, idx_test)) == 0L,
  nrow(train) + nrow(test) == nrow(d),
  as.character(predire_fisher(modele, test[1, variables])$classe) ==
    as.character(prediction$classe[1])
)
rotation <- matrix(c(0, 1, -1, 0), nrow = 2)
modele_tourne <- modele
modele_tourne$axes <- modele$axes %*% rotation
modele_tourne$centres <- modele$centres %*% rotation
prediction_tournee <- predire_fisher(modele_tourne, test[variables])
stopifnot(
  max(abs(prediction_tournee$distances2 - prediction$distances2)) < 1e-10,
  identical(prediction_tournee$classe, prediction$classe)
)

# Exemple numérique du cours : z = x1 + 2 x2 ; seuil non centré égal à 2.
modele_exemple <- list(
  moyenne = c(0, 0), axes = matrix(c(1, 2), ncol = 1),
  centres = matrix(c(0, 4), ncol = 1), classes = c("1", "2")
)
points_exemple <- rbind(c(1, 1), c(0.5, 0.5), c(2, 0))
stopifnot(identical(
  as.character(predire_fisher(modele_exemple, points_exemple)$classe),
  c("2", "1", "1")
))
