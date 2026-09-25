# k plus proches voisins — exemple Palmer Penguins du cours.
# Depuis la racine du dépôt : Rscript codes/k_plus_proches_voisins.R
# R de base uniquement ; les données locales sont dans assets/penguins.csv.
# Les choix de distance, de candidats et de départage sont fixés avant le test.

# Vote uniforme. En cas d'égalité de distances : ordre des lignes de train.
# En cas d'égalité de voix : classe du plus proche voisin parmi les ex aequo.
predire_knn <- function(train, test, classes, k) {
  train <- as.matrix(train)
  test <- as.matrix(test)
  niveaux <- levels(classes)
  predictions <- apply(test, 1, function(x) {
    distances2 <- rowSums(sweep(train, 2, x, "-")^2)
    voisins <- order(distances2, seq_along(distances2))[seq_len(k)]
    etiquettes <- as.character(classes[voisins])
    votes <- table(factor(etiquettes, levels = niveaux))
    gagnants <- names(votes)[votes == max(votes)]
    etiquettes[which(etiquettes %in% gagnants)[1]]
  })
  factor(predictions, levels = niveaux)
}

# Estimer le centrage et la réduction sur la seule partie d'entraînement.
standardiser <- function(train, nouveau) {
  train_z <- scale(as.matrix(train))
  stopifnot(all(attr(train_z, "scaled:scale") > 0))
  nouveau_z <- scale(as.matrix(nouveau),
                     center = attr(train_z, "scaled:center"),
                     scale = attr(train_z, "scaled:scale"))
  list(train = train_z, nouveau = nouveau_z)
}

penguins <- read.csv("../assets/penguins.csv")
variables <- c(
  "bill_length_mm", "bill_depth_mm",
  "flipper_length_mm", "body_mass_g"
)
d <- penguins[complete.cases(penguins[c("species", variables)]),
              c("species", variables)]
d$species <- factor(d$species)

set.seed(2200)
indices <- split(seq_len(nrow(d)), d$species)
idx_train <- unlist(lapply(indices, function(i) {
  sample(i, size = round(0.70 * length(i)))
}), use.names = FALSE)
train <- d[idx_train, ]
test <- d[-idx_train, ]

# Cinq plis stratifiés, communs à tous les candidats.
set.seed(2201)
V <- 5L
plis <- integer(nrow(train))
for (g in levels(train$species)) {
  i <- which(train$species == g)
  plis[i] <- sample(rep(seq_len(V), length.out = length(i)))
}
k_candidats <- c(1L, 3L, 5L, 7L, 9L, 15L, 21L, 31L)
nb_erreurs <- matrix(0L, nrow = V, ncol = length(k_candidats))
for (v in seq_len(V)) {
  apprentissage <- train[plis != v, ]
  validation <- train[plis == v, ]
  z <- standardiser(apprentissage[variables], validation[variables])
  for (j in seq_along(k_candidats)) {
    prediction <- predire_knn(z$train, z$nouveau,
                              apprentissage$species, k_candidats[j])
    nb_erreurs[v, j] <- sum(prediction != validation$species)
  }
}
erreurs_cv <- colSums(nb_erreurs)
# En cas d'égalité de l'erreur de validation, choisir le plus grand k.
k_retenu <- max(k_candidats[erreurs_cv == min(erreurs_cv)])
cat("Validation croisée sur les seules observations d'entraînement :\n")
print(data.frame(k = k_candidats, erreurs = erreurs_cv,
                 taux_pourcent = round(100 * erreurs_cv / nrow(train), 2)))
cat("k retenu :", k_retenu, "\n")

# Préparation finale sur tout l'entraînement, puis une évaluation du test.
z_final <- standardiser(train[variables], test[variables])
prediction_test <- predire_knn(z_final$train, z_final$nouveau,
                               train$species, k_retenu)
confusion <- table(Reelle = test$species, Predite = prediction_test)
cat("\nEffectifs entraînement / test :", nrow(train), "/", nrow(test), "\n")
cat("Matrice de confusion du test :\n")
print(confusion)
cat(sprintf("Exactitude du test : %.2f %%\n",
            100 * mean(prediction_test == test$species)))
cat("Sensibilité par espèce (%) :\n")
print(round(100 * diag(confusion) / rowSums(confusion), 2))


plot(test$bill_depth_mm, test$bill_length_mm, col=as.factor(prediction_test))
plot(test$bill_depth_mm, test$bill_length_mm, col=as.factor(test$species))

plot(test$body_mass_g, test$flipper_length_mm, col=as.factor(prediction_test))


