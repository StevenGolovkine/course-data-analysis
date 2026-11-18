# Méthodes ensemblistes sur Palmer Penguins — STT-2200
# Le chapitre se trouve dans lectures/supervised.typ,
# et les diapositives dans slides/methodes_ensemblistes.typ.
#
# Depuis la racine : Rscript codes/methodes_ensemblistes.R
# Dans R : source("codes/methodes_ensemblistes.R")
# Fonctionne aussi depuis codes/ ou avec le chemin absolu du script.
# Dépendances à installer une seule fois si nécessaire :
# Commande : install.packages(c("rpart", "randomForest", "gbm")).
# Aucune installation ni aucun téléchargement automatique.
#
# Parcours : bootstrap et OOB, bagging et forêts, corrections du boosting,
# validation, test réservé, importances et complément sur AdaBoost.
# Toutes les analyses utilisent les données locales Palmer Penguins.
# Les trois espèces, la masse et Adelie/non-Adelie sont des tâches distinctes.
#
# Graphiques en session interactive, sans créer de fichier par défaut.
# Pour les revoir : dessiner_ensembles().
# Pour les désactiver : options(ensembles_afficher_graphiques = FALSE).
# Les SVG des supports restent produits par les scripts Python.
#
# Conventions : B = nombre d'arbres, m = variables candidates à chaque nœud,
# T = étapes de boosting, nu = taux d'apprentissage, M = permutations.
# Les noms R suivent snake_case ; les arguments des paquets restent inchangés.


# 0. FONCTIONS ET DÉPENDANCES ----------------------------------------------

paquets <- c("rpart", "randomForest", "gbm")
manquants <- paquets[!vapply(paquets, requireNamespace, logical(1),
                             quietly = TRUE)]
if (length(manquants)) {
  stop("Installer les paquets suivants : ", paste(manquants, collapse = ", "))
}

trouver_penguins <- function() {
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
  if (!length(existants)) stop("Fichier assets/penguins.csv introuvable.")
  normalizePath(existants[1], mustWork = TRUE)
}

classe_max <- function(scores) {
  # Premier niveau à égalité, y compris en présence de trois classes.
  factor(colnames(scores)[max.col(scores, ties.method = "first")],
         levels = colnames(scores))
}

predire_foret <- function(modele, x) {
  if (modele$type == "classification") {
    # Ici type = "prob" renvoie des fractions de votes de classes,
    # et non une moyenne des probabilités estimées dans les feuilles.
    classe_max(predict(modele, x, type = "prob"))
  } else {
    as.numeric(predict(modele, x))
  }
}

perte_logistique <- function(y, probabilite) {
  # Protection numérique seulement, sans modifier la règle de décision.
  probabilite <- pmin(pmax(probabilite, 1e-15), 1 - 1e-15)
  -y * log(probabilite) - (1 - y) * log1p(-probabilite)
}

ajuster_foret <- function(x, y, m, taille, graine, b = 500L) {
  set.seed(graine)
  randomForest::randomForest(
    x = x, y = y, ntree = b, mtry = m, nodesize = taille,
    replace = TRUE, sampsize = nrow(x), keep.inbag = TRUE,
    importance = FALSE
  )
}

valider_forets <- function(x, y, plis, grille) {
  pertes <- matrix(NA_real_, nrow(x), nrow(grille))
  for (v in sort(unique(plis))) {
    validation <- plis == v
    for (j in seq_len(nrow(grille))) {
      modele <- ajuster_foret(
        x[!validation, ], y[!validation], grille$m[j], grille$taille[j],
        graine = 2300L + v
      )
      prediction <- predire_foret(modele, x[validation, ])
      pertes[validation, j] <- if (is.factor(y)) {
        as.numeric(prediction != y[validation])
      } else {
        (prediction - y[validation])^2
      }
    }
  }
  grille$perte_cv <- colMeans(pertes)
  grille$famille <- ifelse(grille$m == ncol(x), "bagging", "foret")
  grille
}

choisir_foret <- function(validation, famille) {
  candidats <- which(validation$famille == famille)
  # À égalité : première ligne de la grille, annoncée avant les calculs.
  validation[candidats[which.min(validation$perte_cv[candidats])], ]
}

reconstruire_oob <- function(modele, x, y) {
  # Chaque colonne décrit un arbre ; inbag == 0 signifie « absent ».
  individuelles <- predict(modele, x, predict.all = TRUE)$individual
  oob <- modele$inbag == 0
  n <- nrow(x)
  votes <- matrix(0, n, nlevels(y), dimnames = list(NULL, levels(y)))
  nb_oob <- integer(n)
  erreur <- couverture <- numeric(ncol(oob))
  for (b in seq_len(ncol(oob))) {
    indices <- which(oob[, b])
    colonnes <- match(individuelles[indices, b], levels(y))
    positions <- cbind(indices, colonnes)
    votes[positions] <- votes[positions] + 1
    nb_oob[indices] <- nb_oob[indices] + 1L
    disponibles <- nb_oob > 0L
    couverture[b] <- mean(disponibles)
    erreur[b] <- if (any(disponibles)) {
      mean(classe_max(votes[disponibles, , drop = FALSE]) != y[disponibles])
    } else {
      NA_real_
    }
  }
  proportions <- votes / ifelse(nb_oob > 0L, nb_oob, NA_real_)
  list(votes = proportions, nb_oob = nb_oob, erreur = erreur,
       couverture = couverture)
}

ajuster_boosting <- function(x, y, distribution, nu, profondeur, graine,
                             etapes = 200L) {
  set.seed(graine)
  gbm::gbm(
    reponse ~ ., data = data.frame(reponse = y, x),
    distribution = distribution, n.trees = etapes,
    interaction.depth = profondeur, shrinkage = nu, n.minobsinnode = 5,
    bag.fraction = 1, train.fraction = 1, cv.folds = 0,
    n.cores = 1, verbose = FALSE
  )
}

valider_boosting <- function(x, y, plis, distribution) {
  # Six chemins de 200 étapes, évalués aux étapes 50, 100 et 200.
  # bag.fraction = 1 : toutes les lignes du pli servent à chaque correction.
  chemins <- expand.grid(nu = c(0.03, 0.1), profondeur = 1:3)
  etapes <- c(50L, 100L, 200L)
  courbes <- matrix(0, max(etapes), nrow(chemins))
  for (v in sort(unique(plis))) {
    validation <- plis == v
    for (j in seq_len(nrow(chemins))) {
      modele <- ajuster_boosting(
        x[!validation, ], y[!validation], distribution,
        chemins$nu[j], chemins$profondeur[j], 2400L + v
      )
      prediction <- predict(
        modele, x[validation, ], n.trees = seq_len(max(etapes)),
        type = "response"
      )
      pertes <- if (distribution == "gaussian") {
        (prediction - y[validation])^2
      } else {
        perte_logistique(y[validation], prediction)
      }
      courbes[, j] <- courbes[, j] + colSums(pertes) / nrow(x)
    }
  }
  grille <- do.call(rbind, lapply(seq_len(nrow(chemins)), function(j) {
    data.frame(nu = chemins$nu[j], profondeur = chemins$profondeur[j],
               etapes = etapes, perte_cv = courbes[etapes, j], chemin = j)
  }))
  choix <- grille[which.min(grille$perte_cv), ]
  modele <- ajuster_boosting(
    x, y, distribution, choix$nu, choix$profondeur, 2500L
  )
  list(grille = grille, choix = choix, courbes = courbes, modele = modele)
}


# 1. PALMER PENGUINS : TROIS TÂCHES, UN PARTAGE -----------------------------

cat("\n1. Préparer les observations et réserver le test\n")
penguins <- read.csv(trouver_penguins())
variables <- c(
  "bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"
)
colonnes <- c("species", variables)
complets <- complete.cases(penguins[colonnes])
donnees <- penguins[complets, colonnes]
donnees$species <- factor(donnees$species)
cat("Observations exclues pour valeur manquante :", sum(!complets), "\n")
# Cas complets pour ce cours. Une imputation apprise doit rester dans les plis.
# Pas de standardisation nécessaire pour les arbres sur ces quatre mesures.

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2200)
par_espece <- split(seq_len(nrow(donnees)), donnees$species)
indices_train <- unlist(lapply(par_espece, function(indices) {
  sample(indices, round(0.70 * length(indices)))
}), use.names = FALSE)
train <- donnees[indices_train, ]
test <- donnees[-indices_train, ]
set.seed(2201)
plis <- integer(nrow(train))
for (espece in levels(train$species)) {
  indices <- which(train$species == espece)
  plis[indices] <- sample(rep(1:5, length.out = length(indices)))
}
print(rbind(entrainement = table(train$species), test = table(test$species)))
stopifnot(nrow(train) == 240L, nrow(test) == 102L)
x_class <- train[variables]
y_class <- train$species
variables_reg <- setdiff(variables, "body_mass_g")
x_reg <- train[variables_reg]
y_reg <- train$body_mass_g
y_binaire <- as.integer(train$species == "Adelie")
# La régression utilise trois mesures : ni species ni la masse à prédire.
# La tâche binaire utilise les quatre mesures, avec Adelie comme classe 1.
# Ce partage suppose des observations indépendantes. Des mesures répétées
# ou un objectif de transfert à un autre site demandent un partage adapté.


# 2. DU BOOTSTRAP À L'ÉVALUATION OOB ---------------------------------------

cat("\n2. Un bootstrap des observations d'entraînement\n")
set.seed(2210)
indices_bootstrap <- sample.int(nrow(train), nrow(train), replace = TRUE)
occurrences <- tabulate(indices_bootstrap, nbins = nrow(train))
print(data.frame(
  lignes_tirees = sum(occurrences), distinctes = sum(occurrences > 0),
  absentes = sum(occurrences == 0),
  proportion_oob_theorique = (1 - 1 / nrow(train))^nrow(train)
))
print(head(data.frame(ligne = seq_len(nrow(train)), occurrences), 10))
# Répéter une ligne compte dans l'apprentissage. Le test n'est jamais tiré.

bagging_demo <- ajuster_foret(x_class, y_class, m = 4, taille = 1,
                              graine = 2211L)
oob_bagging <- reconstruire_oob(bagging_demo, x_class, y_class)
stopifnot(all(oob_bagging$nb_oob > 0L))
stopifnot(isTRUE(all.equal(as.numeric(oob_bagging$votes),
                           as.numeric(bagging_demo$votes), tolerance = 1e-12)))
print(summary(oob_bagging$nb_oob))
cat("Erreur OOB du bagging illustratif :",
    tail(oob_bagging$erreur, 1), "\n")
print(head(data.frame(
  espece = y_class, nb_arbres_oob = oob_bagging$nb_oob,
  classe_oob = classe_max(oob_bagging$votes)
)))
# predict(modele, x_class) utilise tous les arbres : ce n'est PAS l'OOB.
# Avant couverture complète, la courbe ne porte que sur les lignes évaluées.
# Les tirages indépendants ne rendent pas les erreurs des arbres indépendantes.


# 3. BAGGING ET FORÊTS : VALIDATION SUR LES MÊMES PLIS ----------------------

cat("\n3. Régler m et la taille des feuilles, avec B = 500\n")
# Premier départage : taille 5 avant 1, puis m croissant dans chaque bloc.
grille_class <- expand.grid(m = c(1L, 2L, 4L), taille = c(5L, 1L))
grille_reg <- expand.grid(m = 1:3, taille = c(5L, 1L))
cv_class <- valider_forets(x_class, y_class, plis, grille_class)
cv_reg <- valider_forets(x_reg, y_reg, plis, grille_reg)
print(cv_class, row.names = FALSE)
print(transform(cv_reg, rmse_cv_g = sqrt(perte_cv)), row.names = FALSE)
# m = p définit le bagging. Les candidats de la famille forêt ont ici m < p.
# Même logiciel et mêmes autres réglages pour rendre cette comparaison lisible.

modeles_class <- modeles_reg <- list()
for (famille in c("bagging", "foret")) {
  choix <- choisir_foret(cv_class, famille)
  modeles_class[[famille]] <- ajuster_foret(
    x_class, y_class, choix$m, choix$taille, graine = 2600L
  )
  choix <- choisir_foret(cv_reg, famille)
  modeles_reg[[famille]] <- ajuster_foret(
    x_reg, y_reg, choix$m, choix$taille, graine = 2601L
  )
}
oob_foret <- reconstruire_oob(modeles_class$foret, x_class, y_class)
cat("Couverture OOB de la forêt retenue :",
    tail(oob_foret$couverture, 1), "\n")
# B stabilise l'agrégation, il ne fixe pas la profondeur de chaque arbre.
# Une erreur OOB utilisée pour régler le modèle n'est pas un test final.


# 4. BOOSTING : DEUX CORRECTIONS EXPLICITES SUR LA MASSE --------------------

cat("\n4. Les arbres apprennent les résidus, pas la masse initiale\n")
nu_demo <- 0.5
prediction_courante <- rep(mean(y_reg), length(y_reg))
chemin_manuel <- data.frame(
  etape = 0L, mse = mean((y_reg - prediction_courante)^2)
)
corrections <- list()
for (t in 1:2) {
  residus <- y_reg - prediction_courante
  souche <- rpart::rpart(
    residu ~ ., data = data.frame(residu = residus, x_reg), method = "anova",
    control = rpart::rpart.control(
      cp = 0, maxdepth = 1, minsplit = 10, minbucket = 5, xval = 0
    )
  )
  correction <- as.numeric(predict(souche, x_reg))
  prediction_courante <- prediction_courante + nu_demo * correction
  corrections[[t]] <- souche
  cat("\nSouche", t, ":\n")
  print(souche)
  print(head(data.frame(residu = residus, correction,
                        prediction = prediction_courante)))
  chemin_manuel <- rbind(chemin_manuel, data.frame(
    etape = t, mse = mean((y_reg - prediction_courante)^2)
  ))
}
print(chemin_manuel)
stopifnot(all(diff(chemin_manuel$mse) <= 1e-8))
# Cette baisse est une baisse de l'erreur d'entraînement seulement.

score_initial <- qlogis(mean(y_binaire))
print(head(data.frame(
  adelie = y_binaire, probabilite_initiale = plogis(score_initial),
  pseudo_residu = y_binaire - plogis(score_initial)
)))
# En logistique : pseudo-résidu y - p, mais correction du SCORE F.
# La probabilité finale est plogis(F), pas une somme de probabilités.


# 5. BOOSTING : CHOISIR T, NU ET LA COMPLEXITÉ PAR VALIDATION ----------------

cat("\n5. Validation du boosting : masse et Adelie/non-Adelie\n")
boost_reg <- valider_boosting(x_reg, y_reg, plis, "gaussian")
boost_bin <- valider_boosting(x_class, y_binaire, plis, "bernoulli")
print(transform(boost_reg$grille, rmse_cv_g = sqrt(perte_cv)),
      row.names = FALSE)
print(boost_bin$grille, row.names = FALSE)
cat("Réglages retenus en régression :\n")
print(boost_reg$choix)
cat("Réglages retenus en classification binaire :\n")
print(boost_bin$choix)
# Perte de réglage : MSE en régression, perte logistique en binaire.
# On choisit T dans la grille, sans inspecter le test. La courbe complète
# permet de discuter l'arrêt précoce, sans nouveau réglage après coup.
# La perte CV minimale a servi à sélectionner : elle n'est pas une estimation
# indépendante de performance. Le test réservé remplit ce rôle.


# 6. ÉVALUATION FINALE : DES TÂCHES À NE PAS CONFONDRE -----------------------

cat("\n6. Test réservé : aucun nouveau réglage après ces résultats\n")
predictions_class <- lapply(modeles_class, predire_foret,
                            x = test[variables])
classe_reference <- names(which.max(table(y_class)))
predictions_class$reference <- factor(
  rep(classe_reference, nrow(test)), levels = levels(y_class)
)
resultats_class <- data.frame(
  methode = names(predictions_class),
  taux_erreur = vapply(predictions_class, function(prediction) {
    mean(prediction != test$species)
  }, numeric(1))
)
print(resultats_class, row.names = FALSE)
for (nom in names(modeles_class)) {
  cat("\nMatrice de confusion :", nom, "\n")
  confusion <- table(reelle = test$species, predite = predictions_class[[nom]])
  print(confusion)
  cat("Rappel par espèce :\n")
  print(diag(confusion) / rowSums(confusion))
}

predictions_reg <- lapply(modeles_reg, predire_foret, x = test[variables_reg])
predictions_reg$boosting <- as.numeric(predict(
  boost_reg$modele, test[variables_reg], n.trees = boost_reg$choix$etapes,
  type = "response"
))
predictions_reg$reference <- rep(mean(y_reg), nrow(test))
resultats_reg <- data.frame(
  methode = names(predictions_reg),
  rmse_g = vapply(predictions_reg, function(prediction) {
    sqrt(mean((prediction - test$body_mass_g)^2))
  }, numeric(1)),
  mae_g = vapply(predictions_reg, function(prediction) {
    mean(abs(prediction - test$body_mass_g))
  }, numeric(1))
)
print(resultats_reg, row.names = FALSE)
# Vérifier concrètement la moyenne des prédictions des arbres en régression.
arbres_reg <- predict(modeles_reg$foret, test[variables_reg],
                      predict.all = TRUE)$individual
stopifnot(isTRUE(all.equal(as.numeric(rowMeans(arbres_reg)),
                           predictions_reg$foret, tolerance = 1e-10)))
stopifnot(all(predictions_reg$foret >= min(y_reg)),
          all(predictions_reg$foret <= max(y_reg)))
print(head(data.frame(
  arbre_1 = arbres_reg[, 1], arbre_2 = arbres_reg[, 2],
  arbre_3 = arbres_reg[, 3], moyenne_des_500 = rowMeans(arbres_reg)
)))

probabilites_bin <- as.numeric(predict(
  boost_bin$modele, test[variables], n.trees = boost_bin$choix$etapes,
  type = "response"
))
reponse_bin <- as.integer(test$species == "Adelie")
decision_bin <- as.integer(probabilites_bin >= 0.5)
cat("\nTâche binaire distincte : Adelie = 1, autres espèces = 0\n")
print(table(reelle = factor(reponse_bin, levels = 0:1),
            predite = factor(decision_bin, levels = 0:1)))
print(data.frame(
  methode = c("boosting_logistique", "proportion_entrainement"),
  perte_logistique = c(
    mean(perte_logistique(reponse_bin, probabilites_bin)),
    mean(perte_logistique(reponse_bin, mean(y_binaire)))
  ),
  taux_erreur = c(
    mean(decision_bin != reponse_bin),
    mean(as.integer(mean(y_binaire) >= 0.5) != reponse_bin)
  )
))
# Les fractions de votes et les probabilités logistiques ne sont pas
# automatiquement calibrées. Un faible écart ne prouve pas une supériorité.


# 7. IMPORTANCES : IMPURETÉ ET PERMUTATIONS HORS ENTRAÎNEMENT ----------------

cat("\n7. Importance des quatre mesures pour prédire les espèces\n")
mdi <- randomForest::importance(modeles_class$foret, type = 2)[, 1]
importance_mdi <- data.frame(variable = names(mdi), gain_brut = mdi,
                             part_gain = mdi / sum(mdi))
print(importance_mdi, row.names = FALSE)
# Convention du paquet : diminution d'impureté moyenne sur les arbres.
# La part normalisée n'est ni une variance expliquée ni une part d'exactitude.

# Modèles de chaque pli, sans les observations dont on permute les colonnes.
# Les réglages ont déjà été sélectionnés sur ces plis : diagnostic descriptif,
# pas évaluation indépendante de la procédure de sélection. Pas de sélection
# de variables ici, et aucun retour aux réglages après l'examen du test.
choix <- choisir_foret(cv_class, "foret")
groupes_variables <- setNames(as.list(variables), variables)
groupes_variables$taille_et_masse <- c("flipper_length_mm", "body_mass_g")
m_permutations <- 30L
permutations <- matrix(0, m_permutations, length(groupes_variables),
                       dimnames = list(NULL, names(groupes_variables)))
for (v in 1:5) {
  validation <- plis == v
  modele <- ajuster_foret(
    x_class[!validation, ], y_class[!validation], choix$m, choix$taille,
    graine = 2700L + v
  )
  x_val <- x_class[validation, ]
  y_val <- y_class[validation]
  erreur_reference <- sum(predire_foret(modele, x_val) != y_val)
  set.seed(2800L + v)
  for (r in seq_len(m_permutations)) {
    ordre <- sample.int(nrow(x_val))
    for (j in seq_along(groupes_variables)) {
      colonnes <- groupes_variables[[j]]
      perturbe <- x_val
      perturbe[colonnes] <- x_val[ordre, colonnes, drop = FALSE]
      nb_erreurs <- sum(predire_foret(modele, perturbe) != y_val)
      permutations[r, j] <- permutations[r, j] +
        (nb_erreurs - erreur_reference) / nrow(train)
    }
  }
}
importance_permutation <- data.frame(
  variable = colnames(permutations),
  hausse_erreur_points = 100 * colMeans(permutations),
  ecart_type_points = 100 * apply(permutations, 2, sd)
)
print(importance_permutation, row.names = FALSE)
# Même permutation pour les deux colonnes du groupe : relations internes
# conservées. Le score groupé ne s'attribue pas séparément à ses deux membres.
# Cette dispersion décrit les permutations, pas un intervalle de confiance.
# Variables liées, biais MDI, valeurs négatives et causalité : voir le chapitre.


# 8. COMPLÉMENT : ADABOOST BINAIRE, REPONDÉRER LES ERREURS -------------------

cat("\n8. AdaBoost pédagogique sur Adelie/non-Adelie, entraînement seul\n")
# 50 étapes fixées pour montrer le mécanisme, sans revendication de performance.
# Les valeurs des poids sont celles de l'ajustement, pas du tirage bootstrap.
signes <- ifelse(y_binaire == 1L, 1, -1)
poids <- rep(1 / nrow(train), nrow(train))
score_ada <- numeric(nrow(train))
arbres_ada <- list()
coefficients_ada <- numeric()
journal_ada <- data.frame()
for (t in 1:50) {
  donnees_ada <- data.frame(classe = factor(signes), x_class)
  souche <- rpart::rpart(
    classe ~ ., data = donnees_ada, weights = poids, method = "class",
    control = rpart::rpart.control(
      cp = 0, maxdepth = 1, minsplit = 2, minbucket = 1, xval = 0
    )
  )
  prediction <- as.numeric(as.character(predict(souche, x_class,
                                                type = "class")))
  erreur <- sum(poids[prediction != signes])
  if (erreur >= 0.5 - 1e-12) break
  parfait <- erreur <= 1e-12
  # Si la souche est parfaite, elle domine le vote précédent et on s'arrête.
  alpha <- if (parfait) {
    1 + sum(abs(coefficients_ada))
  } else {
    0.5 * log((1 - erreur) / erreur)
  }
  arbres_ada[[t]] <- souche
  coefficients_ada[t] <- alpha
  score_ada <- score_ada + alpha * prediction
  anciens_poids <- poids
  if (!parfait) {
    poids <- poids * exp(-alpha * signes * prediction)
    poids <- poids / sum(poids)
  }
  journal_ada <- rbind(journal_ada, data.frame(
    etape = t, erreur_ponderee = erreur, alpha = alpha,
    erreur_ensemble = mean(ifelse(score_ada >= 0, 1, -1) != signes),
    poids_maximal = max(poids)
  ))
  if (t == 1L) {
    exemples <- c(head(which(prediction == signes), 3),
                  head(which(prediction != signes), 3))
    print(data.frame(
      signe = signes, prediction, poids_avant = anciens_poids,
      poids_apres = poids
    )[exemples, ])
    cat("Poids total des erreurs avant et après :", erreur,
        sum(poids[prediction != signes]), "\n")
  }
  if (parfait) break
}
print(head(journal_ada, 10))
# Décision finale : signe de la somme alpha_t h_t(x), +1 si le score est nul.
# Le poids maximal aide à repérer la concentration sur des cas difficiles.
# Les erreurs d'étiquetage peuvent aussi recevoir de très grands poids.
# Ce complément n'est pas le gradient boosting à perte exponentielle de gbm.


# 9. GRAPHIQUES POUR LE COURS ----------------------------------------------

dessiner_ensembles <- function() {
  anciens_parametres <- par(no.readonly = TRUE)
  on.exit(par(anciens_parametres), add = TRUE)
  couleurs <- c("#007C78", "#D57535", "#5D6CB0")
  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1))
  matplot(100 * cbind(oob_bagging$erreur, oob_foret$erreur), type = "l",
          col = couleurs[1:2], lty = 1:2, xlab = "Nombre d'arbres B",
          ylab = "Erreur OOB (%)", main = "Stabilisation de l'agrégation")
  legend("topright", c("Bagging illustratif", "Forêt retenue"),
         col = couleurs[1:2], lty = 1:2, bty = "n")
  matplot(cbind(oob_bagging$couverture, oob_foret$couverture), type = "l",
          col = couleurs[1:2], lty = 1:2, xlab = "Nombre d'arbres B",
          ylab = "Proportion d'observations évaluées", main = "Couverture OOB")

  for (analyse in list(boost_reg, boost_bin)) {
    choix <- analyse$choix
    courbes <- cbind(analyse$modele$train.error,
                     analyse$courbes[, choix$chemin])
    regression <- analyse$modele$distribution$name == "gaussian"
    # gbm stocke la déviance de Bernoulli = deux fois la perte logistique.
    if (!regression) courbes[, 1] <- courbes[, 1] / 2
    if (regression) courbes <- sqrt(courbes)
    titre <- if (regression) "Boosting : masse" else "Boosting : Adelie"
    unite <- if (regression) "RMSE (g)" else "Perte logistique"
    matplot(courbes, type = "l", lty = 1:2, col = couleurs[1:2],
            xlab = "Étapes T", ylab = unite, main = titre)
    abline(v = choix$etapes, lty = 3)
    legend("topright", c("Entraînement complet", "Validation croisée"),
           col = couleurs[1:2], lty = 1:2, bty = "n")
  }

  par(mfrow = c(1, 2), mar = c(5.5, 4.5, 3.5, 1))
  noms <- c("Bec\nlongueur", "Bec\nprofondeur", "Nageoire", "Masse")
  barplot(100 * importance_mdi$part_gain, names.arg = noms, las = 1,
          cex.names = 0.85,
          col = couleurs[1], ylab = "Part du gain total (%)", main = "MDI")
  boxplot(100 * permutations, names = c(noms, "Nageoire\n+ masse"), las = 1,
          cex.axis = 0.85,
          col = couleurs[2], ylab = "Hausse du taux d'erreur (points)",
          main = "Permutation sur les plis")
  abline(h = 0, lty = 2)

  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1))
  limites <- range(test$body_mass_g, predictions_reg$boosting)
  plot(test$body_mass_g, predictions_reg$boosting, pch = 19,
       col = couleurs[1], xlim = limites, ylim = limites,
       xlab = "Masse observée (g)", ylab = "Masse prédite (g)",
       main = "Boosting : test réservé")
  abline(0, 1, lty = 2)
  plot(journal_ada$etape, journal_ada$erreur_ensemble, type = "l",
       col = couleurs[2], xlab = "Étapes AdaBoost",
       ylab = "Erreur d'entraînement", main = "Vote pondéré des souches")
  invisible(NULL)
}

if (isTRUE(getOption("ensembles_afficher_graphiques", interactive()))) {
  dessiner_ensembles()
}
cat("\nVersions utilisées : R", as.character(getRversion()), "\n")
print(vapply(paquets, function(paquet) {
  as.character(utils::packageVersion(paquet))
}, character(1)))

# Ressources officielles sur les arguments et conventions des logiciels :
# https://cran.r-project.org/web/packages/randomForest/randomForest.pdf
# https://cran.r-project.org/web/packages/gbm/gbm.pdf
# https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.html
