# Analyses discriminantes LDA et QDA — exemple Palmer Penguins du cours.
# Depuis la racine du dépôt : Rscript codes/analyse_discriminante.R
# Dépendance : MASS (paquet recommandé de R). Données locales dans assets/.

penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[c("species", variables)]),
              c("species", variables)]
d$species <- factor(d$species)

# Réserver environ 30 % de chaque espèce pour le test.
# Aucun choix de modèle ou de variable n'est effectué sur ce jeu de test.
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
indices <- split(seq_len(nrow(d)), d$species)
idx_train <- unlist(lapply(indices, function(i) {
  sample(i, size = round(0.70 * length(i)))
}), use.names = FALSE)
train <- d[idx_train, ]
test <- d[-idx_train, ]

# Comparer les deux modèles sur cinq plis stratifiés de l'entraînement.
# Règle fixée : minimiser les erreurs ; à égalité, retenir la LDA, plus simple.
# Toutes les moyennes, covariances et proportions sont réestimées dans chaque pli.
set.seed(2201)
V <- 5L
plis <- integer(nrow(train))
classes <- levels(train$species)
for (g in classes) {
  i <- which(train$species == g)
  plis[i] <- sample(rep(seq_len(V), length.out = length(i)))
}
ajuster <- list(LDA = MASS::lda, QDA = MASS::qda)

softmax <- function(scores) {
  poids <- exp(scores - apply(scores, 1, max))
  poids / rowSums(poids)
}

# Recalculer les scores QDA sans utiliser les transformations internes de MASS.
posterior_qda <- function(apprentissage, nouvelles, prior) {
  x <- as.matrix(nouvelles[variables])
  scores <- vapply(classes, function(g) {
    xg <- as.matrix(apprentissage[apprentissage$species == g, variables])
    mu <- colMeans(xg)
    sigma_g <- cov(xg)
    ecarts <- sweep(x, 2, mu, "-")
    quadratique <- rowSums(ecarts * t(solve(sigma_g, t(ecarts))))
    logdet <- as.numeric(determinant(sigma_g, logarithm = TRUE)$modulus)
    -0.5 * (logdet + quadratique) + log(prior[g])
  }, numeric(nrow(x)))
  softmax(scores)
}

posterieurs_cv <- lapply(names(ajuster), function(nom) {
  post <- matrix(NA_real_, nrow(train), length(classes), dimnames = list(NULL, classes))
  for (v in seq_len(V)) {
    apprentissage <- train[plis != v, ]
    validation <- train[plis == v, ]
    fit <- ajuster[[nom]](species ~ ., data = apprentissage, method = "moment")
    post[plis == v, ] <- predict(fit, newdata = validation)$posterior
    if (nom == "QDA") {
      explicite <- posterior_qda(apprentissage, validation, fit$prior)
      stopifnot(max(abs(explicite - post[plis == v, ])) < 1e-10)
    }
  }
  stopifnot(all(is.finite(post)), max(abs(rowSums(post) - 1)) < 1e-12)
  post
})
names(posterieurs_cv) <- names(ajuster)
erreurs_cv <- vapply(posterieurs_cv, function(post) {
  sum(classes[max.col(post, ties.method = "first")] != as.character(train$species))
}, integer(1))
logloss_cv <- vapply(posterieurs_cv, function(post) {
  # Les probabilités des classes observées sont strictement positives ici.
  proba_vraie <- post[cbind(seq_len(nrow(train)), as.integer(train$species))]
  stopifnot(all(proba_vraie > 0))
  -mean(log(proba_vraie))
}, numeric(1))
resultats_cv <- data.frame(modele = names(ajuster), erreurs = erreurs_cv,
                           taux_erreur = erreurs_cv / nrow(train),
                           logloss = logloss_cv, row.names = NULL)
nom_retenu <- names(ajuster)[which.min(erreurs_cv)]
cat("Comparaison sur l'entraînement (validation croisée stratifiée à cinq plis) :\n")
print(resultats_cv, digits = 6, row.names = FALSE)
cat("Modèle retenu avant l'évaluation du test :", nom_retenu, "\n")

# La LDA usuelle à covariance pleine tient compte des unités et corrélations.
# Les proportions a priori sont ici celles du seul échantillon d'entraînement.
stopifnot(nom_retenu == "LDA")
modele <- ajuster[[nom_retenu]](species ~ ., data = train, method = "moment")
prediction <- predict(modele, newdata = test)
confusion <- table(Reelle = test$species, Predite = prediction$class)
exactitude <- sum(diag(confusion)) / sum(confusion)
rappels <- diag(confusion) / rowSums(confusion)
classe_majoritaire <- names(which.max(table(train$species)))
reference <- mean(test$species == classe_majoritaire)

cat("Effectifs par espèce :\n")
print(rbind(Total = table(d$species),
            Entrainement = table(train$species), Test = table(test$species)))
cat("\nProbabilités a priori estimées sur l'entraînement :\n")
print(modele$prior)
cat("\nMatrice de confusion du test (lignes : classes réelles) :\n")
print(confusion)
cat(sprintf("\nExactitude : %.2f %%\n", 100 * exactitude))
cat("Rappel par espèce :\n")
print(round(100 * rappels, 2))
cat(sprintf("Référence majoritaire (%s) : %.2f %%\n",
            classe_majoritaire, 100 * reference))
cat("\nProbabilités prédites pour les premières observations de test :\n")
print(head(round(prediction$posterior, 4)))

# Vérifier le calcul avec les scores LDA explicites du cours.
x_train <- as.matrix(train[variables])
x_test <- as.matrix(test[variables])
centres <- modele$means
residus <- x_train - centres[as.character(train$species), ]
sigma <- crossprod(residus) / (nrow(train) - length(classes))
coefficients <- solve(sigma, t(centres))
constantes <- -0.5 * colSums(t(centres) * coefficients) + log(modele$prior)
scores <- sweep(x_test %*% coefficients, 2, constantes, "+")
probabilites <- softmax(scores)
stopifnot(
  length(intersect(idx_train, setdiff(seq_len(nrow(d)), idx_train))) == 0L,
  max(abs(probabilites - prediction$posterior)) < 1e-10,
  all(classes[max.col(scores)] == as.character(prediction$class))
)
