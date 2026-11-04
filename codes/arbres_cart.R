# Arbres CART sur Palmer Penguins — STT-2200
# Classification de l'espèce et régression de la masse corporelle.

# 0. FONCTIONS ------------------------------------------------------

compter_feuilles <- function(arbre) {
  sum(arbre$frame$var == "<leaf>")
}

profondeur_arbre <- function(arbre) {
  # Les identifiants rpart sont 1 à la racine, puis 2i et 2i + 1.
  max(floor(log2(as.numeric(rownames(arbre$frame)))))
}


# 1. PALMER PENGUINS : DONNÉES ET PARTAGE REPRODUCTIBLE --------------------

chemins <- c("assets/penguins.csv", "../assets/penguins.csv")
chemin_donnees <- chemins[file.exists(chemins)][1]
penguins <- read.csv(chemin_donnees, na.strings = "NA")
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

# On créé les différents plis.
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


# 2. RECONSTRUIRE L'ARBRE DANS CHAQUE PLI ----------------------------------

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

cat("\n2. Choisir cp sans consulter les performances du test\n")
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


# 3. RÉAJUSTER, PUIS ÉVALUER UNE FOIS SUR LE TEST -------------------------

cat("\n3. Modèles finaux et performances sur le test réservé\n")
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
plot(arbre_class, uniform = TRUE, margin = 0.15)
text(arbre_class, use.n = TRUE, pretty = 0, cex = 0.8)

arbre_reg <- resultats$regression$arbre
plot(arbre_reg, uniform = TRUE, margin = 0.15)
text(arbre_reg, use.n = TRUE, pretty = 0, cex = 0.8)

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


# 4. IMPORTANCE DES VARIABLES --------------------------------------------

cat("\n4. Importance des variables pour prédire l'espèce\n")
cat("Importance calculée sur l'entraînement (sans portée causale) :\n")
print(sort(arbre_class$variable.importance, decreasing = TRUE))
# Importance nulle : une variable corrélée a pu être choisie à sa place.
# Beaucoup de seuils candidats peuvent avantager une variable.
# Les ensembles d'arbres peuvent réduire l'instabilité ; hors périmètre ici.


# 5. GRAPHIQUES POUR LA DÉMONSTRATION EN CLASSE ---------------------------

dessiner_cours_cart <- function() {
  anciens_parametres <- par(no.readonly = TRUE)
  on.exit(par(anciens_parametres), add = TRUE)
  couleurs <- c("#007C78", "#D57535", "#5D6CB0")
  par(mfrow = c(1, 1), mar = c(4.5, 4.5, 4.2, 1), cex.main = 1.1)

  # A. Les cp sont traités comme des candidats discrets sur l'abscisse.
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

  # B. Le petit arbre de classification ; pas de dessin illisible à 30 feuilles.
  par(mfrow = c(1, 1), mar = c(2, 1, 4.2, 1))
  plot(arbre_class, uniform = TRUE, margin = 0.15)
  text(arbre_class, use.n = TRUE, pretty = 0, cex = 0.8)
  title("Palmer Penguins : arbre de classification retenu")
  mtext("Effectifs par feuille : Adelie / Chinstrap / Gentoo",
        side = 1, line = 0.5, cex = 0.8)

  # C. Diagnostic final de régression, sans nouveau réglage sur le test.
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
