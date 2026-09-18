
# Analyse exploratoire — démonstrations R pour le cours STT-2200
#
options(width = 90, digits = 4)

graine_defaut <- 2200L
set.seed(graine_defaut)

pourcentage <- function(x, chiffres = 1L) {
  paste0(formatC(100 * x, format = "f", digits = chiffres), " %")
}


# 1. REPRÉSENTER ET INSPECTER LES DONNÉES -----------------------------------

# Chaque ligne devrait représenter un client. Cette petite base brute contient
# pourtant un doublon, plusieurs codes de valeurs manquantes et des modalités
# écrites de façons différentes.
clients_bruts <- data.frame(
  id_client = c(101, 102, 102, 103, 104, 105),
  age = c("34", "NA", "29", "45", "?", "38"),
  revenu = c("52 000", "48000", "48000", "N/A", "64000", "71000"),
  region = c("Québec", "Montréal", "Montréal", "Québec", "Estrie", "estrie"),
  achat = c("Oui", "non", "NON", "oui", "Oui", "?")
)

print(clients_bruts)
cat("Identifiants dupliqués : ",
  paste(
    unique(clients_bruts$id_client[duplicated(clients_bruts$id_client)]),
    collapse = ", "
  ), "\n", sep = ""
)

normaliser_manquants <- function(x) {
  x <- trimws(as.character(x))
  x[tolower(x) %in% c("", "na", "n/a", "?", "inconnu")] <- NA_character_
  x
}

clients <- clients_bruts
clients[] <- lapply(clients, normaliser_manquants)
clients$id_client <- as.integer(clients$id_client)
clients$age <- as.numeric(clients$age)
clients$revenu <- as.numeric(gsub(" ", "", clients$revenu, fixed = TRUE))
clients$region <- tools::toTitleCase(tolower(clients$region))
clients$achat <- factor(tolower(clients$achat), levels = c("non", "oui"))

# Le traitement d'un doublon dépend du sens de l'unité statistique. Ici, les
# deux lignes du client 102 décrivent la même unité et l'une est plus complète.
# Nous la conservons. Dans une analyse réelle, cette règle doit être documentée.
completude <- rowSums(!is.na(clients))
clients <- clients[order(clients$id_client, -completude), ]
clients <- clients[!duplicated(clients$id_client), ]
clients <- clients[order(clients$id_client), ]

print(clients)
str(clients)

cat("Valeurs manquantes par variable :\n")
print(colSums(is.na(clients)))

# Une modalité nominale ne doit pas être codée 1, 2, 3 comme si elle était
# ordonnée. model.matrix() produit un encodage binaire sans imposer cet ordre.
encodage_region <- model.matrix(~ region - 1, data = clients)
print(encodage_region)

# Que changerait-on si l'unité statistique était la transaction plutôt que le
# client ? Les doublons d'identifiants deviendraient-ils encore des doublons?


# 2. DISTANCES ET SIMILARITÉS ------------------------------------------------

distance_minkowski <- function(x, y, q = 2) {
  stopifnot(length(x) == length(y), q >= 1)
  sum(abs(x - y)^q)^(1 / q)
}

x <- c(taille_cm = 162.1, masse_kg = 66.8)
y <- c(taille_cm = 175.8, masse_kg = 81.6)

cat("Manhattan (q = 1) : ", distance_minkowski(x, y, q = 1))
cat("Euclidienne (q = 2) : ", distance_minkowski(x, y, q = 2))
cat("Similarité 1 / (1 + d2) : ", 1 / (1 + distance_minkowski(x, y, q = 2)))

# Dans cet exemple, le revenu exprimé en dollars domine la distance brute.
# La standardisation mesure plutôt les écarts en nombres d'écarts-types.
profils <- data.frame(
  age = c(23, 48, 46, 50, 25),
  revenu = c(42000, 42100, 65000, 68000, 50000),
  achats = c(3, 15, 14, 16, 4),
  row.names = c("A", "B", "C", "D", "E")
)

distances_brutes <- as.matrix(dist(profils, method = "euclidean"))
profils_standardises <- scale(profils)
distances_standardisees <- as.matrix(
  dist(profils_standardises, method = "euclidean")
)

cat("Depuis A, sans standardisation : ",
    names(which.min(distances_brutes["A", -1])), "\n", sep = "")
cat("Depuis A, après standardisation : ",
    names(which.min(distances_standardisees["A", -1])), "\n", sep = "")
cat("\nDistances depuis A, avant et après standardisation :\n")
print(data.frame(
  profil = rownames(profils)[-1],
  distance_brute = distances_brutes["A", -1],
  distance_standardisee = distances_standardisees["A", -1],
  row.names = NULL
))

distance_hamming <- function(x, y) {
  stopifnot(length(x) == length(y))
  sum(x != y)
}

x_qualitatif <- c("bleus", "bruns", "courts")
y_qualitatif <- c("bleus", "noirs", "longs")
cat("Nombre de désaccords : ",
    distance_hamming(x_qualitatif, y_qualitatif), " sur ",
    length(x_qualitatif), " variables\n", sep = "")

jaccard <- function(x, y) {
  stopifnot(length(x) == length(y), all(x %in% 0:1), all(y %in% 0:1))

  m11 <- sum(x == 1 & y == 1)
  m10 <- sum(x == 1 & y == 0)
  m01 <- sum(x == 0 & y == 1)
  m00 <- sum(x == 0 & y == 0)
  denominateur <- m11 + m10 + m01

  # Convention : deux vecteurs sans aucune présence ont une similarité de 1.
  similarite <- if (denominateur == 0) 1 else m11 / denominateur

  list(
    quantites = c(M11 = m11, M10 = m10, M01 = m01, M00 = m00),
    similarite = similarite,
    distance = 1 - similarite
  )
}

x_binaire <- c(1, 0, 1, 0, 0)
y_binaire <- c(1, 0, 0, 1, 0)
exemple_jaccard <- jaccard(x_binaire, y_binaire)

print(exemple_jaccard$quantites)
cat("Similarité de Jaccard : ", exemple_jaccard$similarite, "\n", sep = "")
cat("Distance de Jaccard : ", exemple_jaccard$distance, "\n", sep = "")
cat("Distance de Hamming : ", distance_hamming(x_binaire, y_binaire), "\n",
    sep = "")

# Hamming compte les doubles absences comme des accords. Jaccard les retire de
# son dénominateur, ce qui est utile pour des présences rares comme des achats.


# 3. ERREURS DE REGRESSION --------------------------------------------------
mse <- function(observe, predit) mean((observe - predit)^2)
mae <- function(observe, predit) mean(abs(observe - predit))

# Le modèle A est exact quatre fois, mais commet une très grande erreur. Le
# modèle B fait une erreur modérée sur chaque observation.
observe <- rep(10, 5)
predit_a <- c(10, 10, 10, 10, 0)
predit_b <- rep(7, 5)

comparaison_regression <- data.frame(
  modele = c("A : une erreur extrême", "B : erreurs régulières"),
  MSE = c(mse(observe, predit_a), mse(observe, predit_b)),
  MAE = c(mae(observe, predit_a), mae(observe, predit_b))
)

print(comparaison_regression)
cat(
  "La MAE préfère A, tandis que la MSE préfère B. Le critère exprime donc une",
  " préférence sur le coût des erreurs.\n", sep = ""
)


# 4. ERREUR DE CLASSIFICATION ET MATRICE DE CONFUSION -----------------------

division_sure <- function(numerateur, denominateur) {
  if (denominateur == 0) NA_real_ else numerateur / denominateur
}

mesures_binaires <- function(
  observe, predit, positif = "fraude", negatif = "legitime"
) {
  stopifnot(length(observe) == length(predit))

  observe <- as.character(observe)
  predit <- as.character(predit)

  vp <- sum(observe == positif & predit == positif)
  fn <- sum(observe == positif & predit == negatif)
  fp <- sum(observe == negatif & predit == positif)
  vn <- sum(observe == negatif & predit == negatif)

  matrice <- matrix(
    c(vp, fn, fp, vn),
    nrow = 2,
    byrow = TRUE,
    dimnames = list(
      observe = c(paste("Réel", positif), paste("Réel", negatif)),
      predit = c(paste("Prédit", positif), paste("Prédit", negatif))
    )
  )

  mesures <- c(
    taux_erreur = mean(observe != predit),
    exactitude = mean(observe == predit),
    sensibilite = division_sure(vp, vp + fn),
    specificite = division_sure(vn, vn + fp),
    precision = division_sure(vp, vp + fp)
  )

  list(
    matrice = matrice,
    effectifs = c(VP = vp, FN = fn, FP = fp, VN = vn),
    mesures = mesures
  )
}

# Exemple des notes : 20 fraudes parmi 1 000 transactions, dont 16 détectées;
# le modèle produit aussi 30 fausses alertes.
classe_observee <- c(rep("fraude", 20), rep("legitime", 980))
classe_predite <- c(
  rep("fraude", 16), rep("legitime", 4),
  rep("fraude", 30), rep("legitime", 950)
)

evaluation_fraude <- mesures_binaires(classe_observee, classe_predite)
print(evaluation_fraude$matrice)
print(data.frame(
  mesure = names(evaluation_fraude$mesures),
  valeur = unname(evaluation_fraude$mesures),
  pourcentage = vapply(evaluation_fraude$mesures, pourcentage, character(1)),
  row.names = NULL
))

# Un classifieur qui prédit toujours la classe majoritaire obtient seulement 2 %
# d'erreur, mais sa sensibilité est nulle : il ne détecte aucune fraude.
prediction_majoritaire <- rep("legitime", length(classe_observee))
evaluation_majoritaire <- mesures_binaires(
  classe_observee, prediction_majoritaire
)
print(rbind(
  modele = evaluation_fraude$mesures,
  toujours_legitime = evaluation_majoritaire$mesures
))

# Le coût permet de distinguer des erreurs dont les conséquences diffèrent.
# Les montants ci-dessous sont pédagogiques, pas des estimations réelles.
cout_fn <- 500
cout_fp <- 50
cout_classification <- function(evaluation) {
  evaluation$effectifs["FN"] * cout_fn +
    evaluation$effectifs["FP"] * cout_fp
}

comparaison_couts <- data.frame(
  strategie = c("Modèle", "Toujours légitime"),
  taux_erreur = c(
    evaluation_fraude$mesures["taux_erreur"],
    evaluation_majoritaire$mesures["taux_erreur"]
  ),
  cout = c(
    cout_classification(evaluation_fraude),
    cout_classification(evaluation_majoritaire)
  )
)
print(comparaison_couts)
cat("Le modèle fait davantage d'erreurs au total, mais réduit ici le coût des",
    " fraudes manquées.\n", sep = "")


# 5. COMPROMIS BIAIS-VARIANCE ----------------------------------------------

# Vérification numérique de l'exemple présenté dans les notes.
methodes <- data.frame(
  methode = c("A", "B", "C"),
  biais = c(-2, 0, -0.5),
  variance = c(0.25, 4, 0.5),
  variance_bruit = 1
)
methodes$erreur_attendue <- methodes$biais^2 + methodes$variance +
  methodes$variance_bruit
print(methodes)

# Simulation : on répète l'échantillonnage, on ajuste des polynômes de degrés
# différents et on observe la prédiction produite au même point x0.
fonction_reelle <- function(x) sin(pi * x)
sigma <- 0.30
x0 <- 0.35
degres <- 1:10
n_repetitions <- 200L
predictions_x0 <- matrix(
  NA_real_,
  nrow = n_repetitions,
  ncol = length(degres),
  dimnames = list(NULL, paste0("degre_", degres))
)

set.seed(graine_defaut + 1L)
for (b in seq_len(n_repetitions)) {
  donnees_b <- data.frame(x = runif(40, -1, 1))
  donnees_b$y <- fonction_reelle(donnees_b$x) + rnorm(40, sd = sigma)

  for (j in seq_along(degres)) {
    d <- degres[j]
    ajustement <- lm(y ~ poly(x, degree = d, raw = TRUE), data = donnees_b)
    predictions_x0[b, j] <- predict(ajustement, newdata = data.frame(x = x0))
  }
}

resume_biais_variance <- data.frame(
  degre = degres,
  biais_carre = (colMeans(predictions_x0) - fonction_reelle(x0))^2,
  variance = apply(predictions_x0, 2, var),
  bruit = sigma^2
)
resume_biais_variance$erreur_attendue <- with(
  resume_biais_variance,
  biais_carre + variance + bruit
)

print(resume_biais_variance)

# Sur un échantillon fixe, l'erreur d'entraînement tend à diminuer avec le
# degré, tandis que l'erreur sur de nouvelles données peut remonter.
set.seed(graine_defaut + 2L)
entrainement_poly <- data.frame(x = runif(45, -1, 1))
entrainement_poly$y <- fonction_reelle(entrainement_poly$x) +
  rnorm(nrow(entrainement_poly), sd = sigma)
test_poly <- data.frame(x = runif(2000, -1, 1))
test_poly$y <- fonction_reelle(test_poly$x) + rnorm(nrow(test_poly), sd = sigma)

erreurs_flexibilite <- do.call(rbind, lapply(degres, function(d) {
  ajustement <- lm(y ~ poly(x, degree = d, raw = TRUE),
                   data = entrainement_poly)
  data.frame(
    degre = d,
    MSE_entrainement = mse(
      entrainement_poly$y,
      predict(ajustement, newdata = entrainement_poly)
    ),
    MSE_test = mse(test_poly$y, predict(ajustement, newdata = test_poly))
  )
}))

print(erreurs_flexibilite)

matplot(
  resume_biais_variance$degre,
  resume_biais_variance[, c("biais_carre", "variance", "erreur_attendue")],
  type = "l", lwd = 2, lty = 1,
  col = c("#d95f02", "#1b9e77", "#24313a"),
  xlab = "Degré du polynôme", ylab = "Composante de l'erreur"
)
legend(
  "topleft",
  legend = c("Biais²", "Variance", "Erreur attendue"),
  col = c("#d95f02", "#1b9e77", "#24313a"),
  lwd = 2, bty = "n"
)

matplot(
  erreurs_flexibilite$degre,
  erreurs_flexibilite[, c("MSE_entrainement", "MSE_test")],
  type = "b", pch = c(16, 17), lty = 1, lwd = 2,
  col = c("#60747d", "#e67e22"),
  xlab = "Degré du polynôme", ylab = "MSE"
)
legend(
  "topleft", legend = c("Entraînement", "Nouvelles données"),
  col = c("#60747d", "#e67e22"), pch = c(16, 17), lwd = 2, bty = "n"
)



# 6. SÉPARER LES DONNÉES ET ÉVITER LES FUITES -------------------------------

separation_stratifiee <- function(
  y, proportion_entrainement = 0.60,
  proportion_validation = 0.20,
  graine = graine_defaut
) {
  stopifnot(proportion_entrainement > 0, proportion_validation > 0,
            proportion_entrainement + proportion_validation < 1)
  set.seed(graine)

  indices_par_classe <- split(seq_along(y), y)
  resultat <- list(entrainement = integer(), validation = integer(),
                   test = integer())

  for (indices in indices_par_classe) {
    indices <- sample(indices)
    n_classe <- length(indices)
    n_entrainement <- floor(proportion_entrainement * n_classe)
    n_validation <- floor(proportion_validation * n_classe)

    resultat$entrainement <- c(
      resultat$entrainement,
      indices[seq_len(n_entrainement)]
    )
    resultat$validation <- c(
      resultat$validation,
      indices[n_entrainement + seq_len(n_validation)]
    )
    debut_test <- n_entrainement + n_validation + 1L
    resultat$test <- c(resultat$test, indices[debut_test:n_classe])
  }

  lapply(resultat, sort)
}

ajuster_standardisation <- function(donnees, variables) {
  centres <- vapply(donnees[variables], mean, numeric(1), na.rm = TRUE)
  echelles <- vapply(donnees[variables], sd, numeric(1), na.rm = TRUE)
  if (any(echelles == 0)) stop("Une variable à standardiser est constante.")
  list(variables = variables, centres = centres, echelles = echelles)
}

appliquer_standardisation <- function(donnees, recette) {
  resultat <- donnees
  for (variable in recette$variables) {
    resultat[[variable]] <- (
      resultat[[variable]] - recette$centres[[variable]]
    ) / recette$echelles[[variable]]
  }
  resultat
}

# Données synthétiques de transactions. La réponse est déséquilibrée et les
# probabilités servent seulement à générer l'exemple; le modèle ne les
# observe pas.
set.seed(graine_defaut + 3L)
n_transactions <- 1500L
transactions <- data.frame(
  montant = rlnorm(n_transactions, meanlog = log(80), sdlog = 1),
  heure_nuit = rbinom(n_transactions, 1, 0.12),
  etranger = rbinom(n_transactions, 1, 0.10)
)
transactions$montant_log <- log1p(transactions$montant)
eta <- -3.7 +
  0.8 * (transactions$montant_log - log(80)) +
  1.2 * transactions$heure_nuit +
  1.0 * transactions$etranger
transactions$fraude <- factor(
  ifelse(rbinom(n_transactions, 1, plogis(eta)) == 1, "oui", "non"),
  levels = c("non", "oui")
)

indices <- separation_stratifiee(
  transactions$fraude, graine = graine_defaut + 4L
)
entrainement <- transactions[indices$entrainement, ]
validation <- transactions[indices$validation, ]
test <- transactions[indices$test, ]

print(data.frame(
  ensemble = c("Entraînement", "Validation", "Test"),
  n = c(nrow(entrainement), nrow(validation), nrow(test)),
  proportion_fraude = c(mean(entrainement$fraude == "oui"),
                        mean(validation$fraude == "oui"),
                        mean(test$fraude == "oui"))
))

# La moyenne et l'écart-type sont appris sur l'entraînement seulement. Ils sont
# ensuite réutilisés sans réajustement sur la validation et le test.
recette <- ajuster_standardisation(entrainement, "montant_log")
entrainement_std <- appliquer_standardisation(entrainement, recette)
validation_std <- appliquer_standardisation(validation, recette)
test_std <- appliquer_standardisation(test, recette)

cat("Moyenne standardisée dans l'entraînement : ",
    mean(entrainement_std$montant_log), "\n", sep = "")
cat("Moyenne standardisée dans le test : ",
    mean(test_std$montant_log),
    " (elle n'a aucune raison d'être exactement nulle)\n", sep = "")

modele_logistique <- glm(
  fraude ~ montant_log + heure_nuit + etranger,
  data = entrainement_std,
  family = binomial()
)

probabilite_validation <- predict(
  modele_logistique,
  newdata = validation_std,
  type = "response"
)

evaluer_seuil <- function(seuil, observe, probabilite,
                          cout_fn = 20, cout_fp = 1) {
  predit <- ifelse(probabilite >= seuil, "oui", "non")
  evaluation <- mesures_binaires(
    observe, predit, positif = "oui", negatif = "non"
  )
  data.frame(
    seuil = seuil,
    cout = cout_fn * evaluation$effectifs["FN"] +
      cout_fp * evaluation$effectifs["FP"],
    taux_erreur = evaluation$mesures["taux_erreur"],
    sensibilite = evaluation$mesures["sensibilite"],
    specificite = evaluation$mesures["specificite"],
    precision = evaluation$mesures["precision"],
    row.names = NULL
  )
}

seuils <- seq(0.02, 0.80, by = 0.01)
resultats_validation <- do.call(
  rbind,
  lapply(seuils, evaluer_seuil,
         observe = validation_std$fraude,
         probabilite = probabilite_validation)
)
meilleur_seuil <- resultats_validation$seuil[
  which.min(resultats_validation$cout)
]

print(resultats_validation[which.min(resultats_validation$cout), ])

# L'ensemble de test ne sert qu'après le choix du modèle et du seuil.
probabilite_test <- predict(modele_logistique, newdata = test_std,
                            type = "response")
test_seuil_choisi <- evaluer_seuil(
  meilleur_seuil, test_std$fraude, probabilite_test
)
test_seuil_05 <- evaluer_seuil(0.50, test_std$fraude, probabilite_test)
print(rbind(seuil_valide = test_seuil_choisi, seuil_0_5 = test_seuil_05))

matplot(
  resultats_validation$seuil,
  resultats_validation[, c("sensibilite", "specificite", "precision")],
  type = "l", lwd = 2, lty = 1,
  col = c("#00897b", "#60747d", "#8e44ad"),
  xlab = "Seuil de décision", ylab = "Mesure"
)
abline(v = meilleur_seuil, col = "#e67e22", lty = 2)
legend(
  "right", legend = c("Sensibilité", "Spécificité", "Précision"),
  col = c("#00897b", "#60747d", "#8e44ad"), lwd = 2, bty = "n"
)


# 7. VALIDATION CROISÉE À K PLIS --------------------------------------------
creer_plis <- function(n, k = 5L, graine = graine_defaut) {
  stopifnot(k >= 2, k <= n)
  set.seed(graine)
  sample(rep(seq_len(k), length.out = n))
}

validation_croisee_polynome <- function(donnees, degres, plis) {
  k <- max(plis)
  tailles_plis <- tabulate(plis, nbins = k)
  resultats <- vector("list", length(degres))

  for (j in seq_along(degres)) {
    d <- degres[j]
    erreurs_plis <- numeric(k)

    for (pli in seq_len(k)) {
      donnees_entrainement <- donnees[plis != pli, ]
      donnees_validation <- donnees[plis == pli, ]
      ajustement <- lm(
        y ~ poly(x, degree = d, raw = TRUE),
        data = donnees_entrainement
      )
      prediction <- predict(ajustement, newdata = donnees_validation)
      erreurs_plis[pli] <- mse(donnees_validation$y, prediction)
    }

    resultats[[j]] <- data.frame(
      degre = d,
      erreur_cv = weighted.mean(erreurs_plis, tailles_plis),
      ecart_type_plis = sd(erreurs_plis),
      erreur_min = min(erreurs_plis),
      erreur_max = max(erreurs_plis)
    )
  }

  do.call(rbind, resultats)
}

set.seed(graine_defaut + 6L)
donnees_cv <- data.frame(x = runif(120, -1, 1))
donnees_cv$y <- fonction_reelle(donnees_cv$x) +
  rnorm(nrow(donnees_cv), sd = sigma)

# Les mêmes plis servent à chaque degré. La comparaison dépend ainsi moins du
# hasard du découpage qu'avec de nouveaux plis pour chaque modèle.
plis <- creer_plis(nrow(donnees_cv), k = 5L, graine = graine_defaut + 7L)
resultats_cv <- validation_croisee_polynome(donnees_cv, 1:10, plis)
meilleur_degre <- resultats_cv$degre[which.min(resultats_cv$erreur_cv)]

print(resultats_cv)
cat("Degré choisi par validation croisée : ", meilleur_degre, "\n", sep = "")
cat("La dispersion entre les plis complète la moyenne; elle ne constitue pas",
    " automatiquement un intervalle de confiance.\n", sep = "")

plot(
  resultats_cv$degre, resultats_cv$erreur_cv,
  type = "b", pch = 16, lwd = 2, col = "#00897b",
  xlab = "Degré du polynôme", ylab = "MSE de validation croisée"
)
arrows(
  resultats_cv$degre,
  resultats_cv$erreur_cv - resultats_cv$ecart_type_plis,
  resultats_cv$degre,
  resultats_cv$erreur_cv + resultats_cv$ecart_type_plis,
  angle = 90, code = 3, length = 0.04, col = "#60747d"
)
abline(v = meilleur_degre, col = "#e67e22", lty = 2)
