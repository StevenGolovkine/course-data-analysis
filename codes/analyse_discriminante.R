# Analyse discriminante linéaire — exemple Palmer Penguins du cours.
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

# La LDA usuelle à covariance pleine tient compte des unités et corrélations.
# Les proportions a priori sont ici celles du seul échantillon d'entraînement.
modele <- MASS::lda(species ~ ., data = train)
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
classes <- levels(train$species)
centres <- modele$means
residus <- x_train - centres[as.character(train$species), ]
sigma <- crossprod(residus) / (nrow(train) - length(classes))
coefficients <- solve(sigma, t(centres))
constantes <- -0.5 * colSums(t(centres) * coefficients) + log(modele$prior)
scores <- sweep(x_test %*% coefficients, 2, constantes, "+")
poids <- exp(scores - apply(scores, 1, max))
probabilites <- poids / rowSums(poids)
stopifnot(
  length(intersect(idx_train, setdiff(seq_len(nrow(d)), idx_train))) == 0L,
  max(abs(probabilites - prediction$posterior)) < 1e-10,
  all(classes[max.col(scores)] == as.character(prediction$class))
)
