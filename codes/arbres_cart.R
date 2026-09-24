# Arbres CART — classification et régression sur Palmer Penguins.
# Depuis la racine du dépôt : Rscript codes/arbres_cart.R
# Dépendance : rpart (paquet recommandé de R). Données locales dans assets/.

penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[c("species", variables)]),
              c("species", variables)]
d$species <- factor(d$species)

# Même partage et mêmes plis que les exemples k-NN et LDA/QDA du cours.
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
indices <- split(seq_len(nrow(d)), d$species)
idx_train <- unlist(lapply(indices, function(i) {
  sample(i, size = round(0.70 * length(i)))
}), use.names = FALSE)
train <- d[idx_train, ]
test <- d[-idx_train, ]
set.seed(2201)
V <- 5L
plis <- integer(nrow(train))
for (g in levels(train$species)) {
  i <- which(train$species == g)
  plis[i] <- sample(rep(seq_len(V), length.out = length(i)))
}

# Grille et contraintes fixées avant la validation, sans utiliser le test.
# cp est relatif au risque de la racine, recalculé dans chaque apprentissage.
cp_candidats <- c(0, 0.001, 0.005, 0.01, 0.02, 0.05, 0.10)
controle <- rpart::rpart.control(cp = 0, minsplit = 10, minbucket = 5,
                               maxdepth = 10, xval = 0, maxsurrogate = 0)
ajuster <- function(donnees, tache) {
  if (tache == "classification") {
    rpart::rpart(species ~ bill_length_mm + bill_depth_mm +
                   flipper_length_mm + body_mass_g,
                 data = donnees, method = "class",
                 parms = list(split = "gini"), control = controle)
  } else {
    # La réponse body_mass_g est exclue des prédicteurs, ainsi que species.
    rpart::rpart(body_mass_g ~ bill_length_mm + bill_depth_mm +
                   flipper_length_mm,
                 data = donnees, method = "anova", control = controle)
  }
}

resultats <- list()
for (tache in c("classification", "regression")) {
  pertes <- matrix(0, nrow = V, ncol = length(cp_candidats))
  type <- if (tache == "classification") "class" else "vector"
  for (v in seq_len(V)) {
    apprentissage <- train[plis != v, ]
    validation <- train[plis == v, ]
    grand <- ajuster(apprentissage, tache)
    for (j in seq_along(cp_candidats)) {
      arbre <- rpart::prune(grand, cp = cp_candidats[j])
      pred <- predict(arbre, newdata = validation, type = type)
      pertes[v, j] <- if (tache == "classification") {
        sum(pred != validation$species)
      } else {
        sum((pred - validation$body_mass_g)^2)
      }
    }
  }
  risque_cv <- colSums(pertes) / nrow(train)
  # À égalité, choisir le plus grand cp (élagage le plus fort).
  cp_retenu <- max(cp_candidats[risque_cv == min(risque_cv)])
  grand <- ajuster(train, tache)
  arbre <- rpart::prune(grand, cp = cp_retenu)
  nb_feuilles <- sum(arbre$frame$var == "<leaf>")
  pred <- predict(arbre, newdata = test, type = type)

  cat("\nTâche :", tache, "\n")
  print(data.frame(cp = cp_candidats, risque_cv = risque_cv),
        digits = 7, row.names = FALSE)
  cat("cp retenu :", cp_retenu, "; feuilles :", nb_feuilles, "\n")
  print(arbre, digits = 6)
  if (tache == "classification") {
    confusion <- table(Reelle = test$species, Predite = pred)
    print(confusion)
    cat(sprintf("Exactitude du test : %.2f %%\n", 100 * mean(pred == test$species)))
    cat("Rappels par espèce :\n")
    print(diag(confusion) / rowSums(confusion))
    proba <- predict(arbre, newdata = test, type = "prob")
    stopifnot(max(abs(rowSums(proba) - 1)) < 1e-12)
    cat("Première observation du test :\n")
    print(test[1, ])
    print(proba[1, ])
  } else {
    rmse <- sqrt(mean((pred - test$body_mass_g)^2))
    mae <- mean(abs(pred - test$body_mass_g))
    reference <- sqrt(mean((mean(train$body_mass_g) - test$body_mass_g)^2))
    cat(sprintf("RMSE du test : %.4f g ; MAE : %.4f g\n", rmse, mae))
    cat(sprintf("RMSE de la moyenne d'entraînement : %.4f g\n", reference))
    cat("Première prédiction du test :", pred[1], "g\n")
    stopifnot(all(pred >= min(train$body_mass_g)),
              all(pred <= max(train$body_mass_g)))
  }
  resultats[[tache]] <- list(arbre = arbre, cp = cp_retenu,
                             risque_cv = risque_cv)
}

# Vérifications des calculs pédagogiques, indépendantes du logiciel d'arbre.
gini <- function(y) 1 - sum(prop.table(table(y))^2)
y_class <- c("A", "A", "A", "A", "B", "A", "B", "B", "A", "B")
gain_gini <- gini(y_class) - 4/10 * gini(y_class[1:4]) -
  6/10 * gini(y_class[5:10])
y_reg <- c(1, 2, 3, 8, 9, 10)
sce <- function(y) sum((y - mean(y))^2)
sce_apres <- sce(y_reg[1:3]) + sce(y_reg[4:6])
stopifnot(abs(gain_gini - 16/75) < 1e-12,
          abs(sce(y_reg) - 77.5) < 1e-12,
          abs(sce_apres - 4) < 1e-12,
          abs(sce(y_reg) - sce_apres - 3*3/6 * (2-9)^2) < 1e-12)
