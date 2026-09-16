# Analyse en composantes principales — STT-2200
# Supports : lectures/dimension_reduction.typ et slides/dimension_reduction.typ.
# Exécuter section par section dans RStudio ou, depuis la racine du dépôt :
# Dans R : source("codes/dimension_reduction.R", encoding = "UTF-8").
#   Rscript codes/dimension_reduction.R
# Dépendances : R de base, sans téléchargement ni paquet supplémentaire.
# RStudio affiche les graphiques dans Plots. Rscript utilise Rplots.pdf.
# Les données locales et leur provenance figurent dans assets/.
# Convention : les variances empiriques ont pour diviseur n - 1.

options(width = 80, digits = 4)
graine_defaut <- 2200L
set.seed(graine_defaut)


# 1. DEUX EXAMENS : CONSTRUIRE L'EXEMPLE DU COURS ----------------------------

# Le fond du nuage est simulé. Ses points diffèrent de ceux des figures, mais
# les 45 observations ont exactement les variances 1 et la corrélation 0,8.
# Les profils A = (1, 1), B = (1, -1) et C = (0, 0) sont inclus dans le nuage.
n_etudiants <- 45L
axes_reference <- matrix(c(1, 1, 1, -1), nrow = 2) / sqrt(2)
colnames(axes_reference) <- c("cp1", "cp2")

aleas <- scale(matrix(rnorm(80), ncol = 2), scale = FALSE)
base_orthogonale <- qr.Q(qr(aleas))
# A, B et leurs opposés apportent 4 à chaque somme de scores au carré.
scores_fond <- sweep(
  base_orthogonale, 2,
  sqrt((n_etudiants - 1) * c(1.8, 0.2) - 4), "*"
)
profils <- rbind(
  A = c(1, 1), B = c(1, -1),
  oppose_a = c(-1, -1), oppose_b = c(-1, 1), C = c(0, 0)
)
z_reference <- rbind(tcrossprod(scores_fond, axes_reference), profils)
rownames(z_reference) <- c(paste0("etudiant_", 1:40), rownames(profils))
colnames(z_reference) <- c("intermediaire", "final")

# Revenir à des notes sur 20 : moyennes 12 et 11, écarts-types 2 et 3.
notes <- sweep(sweep(z_reference, 2, c(2, 3), "*"), 2, c(12, 11), "+")
cat("\nNotes originales des profils A, B et C :\n")
print(notes[c("A", "B", "C"), ])


# 2. CENTRER, RÉDUIRE ET CHOISIR LA GÉOMÉTRIE -------------------------------

notes_centrees <- scale(notes, center = TRUE, scale = FALSE)
z_examens <- scale(notes, center = TRUE, scale = TRUE)
moyennes_examens <- attr(z_examens, "scaled:center")
ecarts_types_examens <- attr(z_examens, "scaled:scale")

cat("\nMoyennes et écarts-types avant/après préparation :\n")
print(rbind(
  moyenne_originale = colMeans(notes),
  ecart_type_original = apply(notes, 2, sd),
  moyenne_centree = colMeans(notes_centrees),
  moyenne_reduite = colMeans(z_examens),
  ecart_type_reduit = apply(z_examens, 2, sd)
))
cat("Covariance des notes centrées :\n")
print(cov(notes_centrees))
cat("Covariance après réduction = corrélation des notes originales :\n")
print(cov(z_examens))
stopifnot(isTRUE(all.equal(cov(z_examens), cor(notes))))

# Une note de 14 à l'intermédiaire donne (14 - 12) / 2 = 1.
# La réduction est un choix : elle accorde la même variance aux deux examens.
# Retirer les colonnes constantes avant scale(..., scale = TRUE).


# 3. CALCUL MANUEL : COVARIANCE, VALEURS PROPRES ET SCORES ------------------

covariance <- crossprod(z_examens) / (n_etudiants - 1)
decomposition <- eigen(covariance, symmetric = TRUE)
valeurs_examens <- decomposition$values
axes_examens <- decomposition$vectors

# Le signe des vecteurs propres est arbitraire. Pour retrouver le cours,
# orienter CP1 comme (1, 1) et CP2 comme (1, -1).
signes <- sign(colSums(axes_examens * axes_reference))
axes_examens <- sweep(axes_examens, 2, signes, "*")
dimnames(axes_examens) <- list(colnames(z_examens), c("cp1", "cp2"))
scores_examens <- z_examens %*% axes_examens

cat("\nValeurs propres : 1,8 et 0,2\n")
print(valeurs_examens)
cat("Directions : coefficients des variables, communs aux étudiants\n")
print(axes_examens)
cat("Scores : coordonnées propres à chaque étudiant\n")
print(scores_examens[c("A", "B", "C"), ])
cat("Covariance des scores : diagonale des valeurs propres\n")
print(cov(scores_examens))

stopifnot(
  max(abs(covariance - matrix(c(1, 0.8, 0.8, 1), 2))) < 1e-10,
  max(abs(valeurs_examens - c(1.8, 0.2))) < 1e-10,
  max(abs(crossprod(axes_examens) - diag(2))) < 1e-10,
  max(abs(cov(scores_examens) - diag(valeurs_examens))) < 1e-10
)

# Parcourir les directions unitaires : la variance culmine à pi / 4.
angles <- seq(0, pi, length.out = 361)
directions <- rbind(cos(angles), sin(angles))
variances_projection <- colSums(directions * (covariance %*% directions))
plot(
  angles * 180 / pi, variances_projection, type = "l", lwd = 2,
  col = "#00897b", xlab = "Angle de la direction (degrés)",
  ylab = "Variance des projections", main = "La direction de variance maximale"
)
abline(v = 45, h = valeurs_examens[1], lty = 2, col = "#d95f02")
points(45, valeurs_examens[1], pch = 19, col = "#d95f02")


# 4. LA MÊME ACP AVEC SVD() ET PRCOMP() -------------------------------------

decomposition_svd <- svd(z_examens)
valeurs_svd <- decomposition_svd$d^2 / (n_etudiants - 1)
axes_svd <- decomposition_svd$v
signes_svd <- sign(colSums(axes_svd * axes_examens))
axes_svd <- sweep(axes_svd, 2, signes_svd, "*")
scores_svd <- z_examens %*% axes_svd

# prcomp() réalise une SVD sans former explicitement la covariance.
acp_examens <- prcomp(notes, center = TRUE, scale. = TRUE)
signes_prcomp <- sign(colSums(acp_examens$rotation * axes_examens))
acp_examens$rotation <- sweep(acp_examens$rotation, 2, signes_prcomp, "*")
acp_examens$x <- sweep(acp_examens$x, 2, signes_prcomp, "*")

cat("\nTrois façons de calculer les mêmes variances :\n")
print(cbind(
  eigen = valeurs_examens, svd = valeurs_svd,
  prcomp = acp_examens$sdev^2
))
stopifnot(
  max(abs(scores_examens - scores_svd)) < 1e-10,
  max(abs(scores_examens - acp_examens$x)) < 1e-10
)
# Correspondances : rotation = A, x = T = ZA, sdev^2 = valeurs propres.
# Une inversion de signe modifie les coordonnées, mais pas les distances.


# 5. PROJECTION, INERTIE ET RECONSTRUCTION ----------------------------------

q_examens <- 1L
reconstruction_z <- tcrossprod(
  scores_examens[, seq_len(q_examens), drop = FALSE],
  axes_examens[, seq_len(q_examens), drop = FALSE]
)
erreur_individuelle <- rowSums((z_examens - reconstruction_z)^2)
inertie_totale <- sum(z_examens^2) / (n_etudiants - 1)
inertie_perdue <- sum(erreur_individuelle) / (n_etudiants - 1)
part_conservee <- sum(valeurs_examens[seq_len(q_examens)]) / inertie_totale

cat("\nInertie totale, fraction conservée, inertie perdue :\n")
print(c(total = inertie_totale, conservee = part_conservee,
        perdue = inertie_perdue))
cat("Reconstructions et erreurs individuelles :\n")
print(cbind(
  reconstruction_z[c("A", "B", "C"), ],
  erreur_carree = erreur_individuelle[c("A", "B", "C")]
))

# Retrouver les unités d'origine : multiplier par les écarts-types,
# puis ajouter les moyennes. B devient ici l'étudiant moyen C.
reconstruction_notes <- sweep(
  sweep(reconstruction_z, 2, ecarts_types_examens, "*"),
  2, moyennes_examens, "+"
)
print(reconstruction_notes[c("A", "B", "C"), ])
stopifnot(
  abs(inertie_totale - sum(valeurs_examens)) < 1e-10,
  abs(inertie_perdue - valeurs_examens[2]) < 1e-10,
  abs(part_conservee - 0.9) < 1e-10,
  abs(erreur_individuelle["B"] - 2) < 1e-10
)

tracer_examens <- function() {
  ancien_par <- par(mfrow = c(1, 3), mar = c(4, 4, 3, 1), pty = "s")
  on.exit(par(ancien_par))
  limite <- ceiling(max(abs(c(z_examens, scores_examens))))
  selection <- match(c("A", "B", "C"), rownames(z_examens))
  couleurs <- c("#00897b", "#d95f02", "#24313a")

  plot(
    z_examens, asp = 1, xlim = c(-limite, limite),
    ylim = c(-limite, limite), pch = 16, col = "#60747d",
    xlab = "Intermédiaire standardisé", ylab = "Final standardisé",
    main = "Repère original"
  )
  abline(a = 0, b = 1, col = couleurs[1], lwd = 2)
  abline(a = 0, b = -1, col = couleurs[2], lwd = 2)
  text(z_examens[selection, ], labels = c("A", "B", "C"), pos = 3)

  plot(
    scores_examens, asp = 1, xlim = c(-limite, limite),
    ylim = c(-limite, limite), pch = 16, col = "#60747d",
    xlab = "CP1 : 90 %", ylab = "CP2 : 10 %", main = "Repère principal"
  )
  abline(h = 0, v = 0, col = "#c4d2d6")
  text(scores_examens[selection, ], labels = c("A", "B", "C"), pos = 3)

  plot(
    z_examens, asp = 1, xlim = c(-limite, limite),
    ylim = c(-limite, limite), pch = 16, col = "#60747d",
    xlab = "Intermédiaire standardisé", ylab = "Final standardisé",
    main = "Projection sur CP1"
  )
  segments(
    z_examens[, 1], z_examens[, 2],
    reconstruction_z[, 1], reconstruction_z[, 2],
    col = "#00897b80", lty = 2
  )
  points(reconstruction_z, pch = 1, col = couleurs[1])
  points(z_examens[selection, ], pch = 19, col = couleurs)
  text(z_examens[selection, ], labels = c("A", "B", "C"), pos = 3)
}
tracer_examens()

# Discussion : B et C se confondent sur CP1. Les 90 % sont une qualité globale,
# pas une garantie pour chacun des étudiants. Garder CP2 révèle leur contraste.


# 6. CHOISIR LE NOMBRE DE COMPOSANTES ---------------------------------------

choisir_q <- function(valeurs, seuil = 0.95) {
  stopifnot(
    is.numeric(valeurs), length(valeurs) > 0L,
    all(is.finite(valeurs)), all(valeurs >= 0), sum(valeurs) > 0,
    all(diff(valeurs) <= 0),
    length(seuil) == 1L, is.finite(seuil), seuil > 0, seuil <= 1
  )
  cumul <- cumsum(valeurs) / sum(valeurs)
  # Tolérance pour les arrondis, notamment quand le cumul devrait valoir 1.
  which(cumul >= seuil - 10 * .Machine$double.eps)[1]
}

tracer_variance <- function(valeurs, titre) {
  ancien_par <- par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  on.exit(par(ancien_par))
  rangs <- seq_along(valeurs)
  cumul <- cumsum(valeurs) / sum(valeurs)
  plot(
    rangs, valeurs, type = "b", pch = 19, col = "#00897b", lwd = 2,
    xlab = "Rang de la composante", ylab = "Valeur propre", main = titre,
    xaxt = "n"
  )
  axis(1, at = rangs)
  abline(h = c(1, 0.7), col = c("#d95f02", "#7570b3"), lty = c(2, 3))
  legend(
    "topright", c("Kaiser : 1", "Jolliffe : 0,7"),
    col = c("#d95f02", "#7570b3"), lty = c(2, 3), bty = "n"
  )
  plot(
    rangs, 100 * cumul, type = "b", pch = 19, lwd = 2, col = "#00897b",
    ylim = c(0, 100), xlab = "Nombre de composantes retenues",
    ylab = "Variance cumulée (%)", main = "Variance conservée", xaxt = "n"
  )
  axis(1, at = rangs)
  abline(h = c(80, 90, 95), lty = 2, col = "#aab7bb")
}

# Exemple à six variables standardisées : la somme des valeurs propres vaut 6.
valeurs_six <- c(3, 1.5, 0.9, 0.3, 0.2, 0.1)
cat("\nExemple à six variables :\n")
print(data.frame(
  rang = seq_along(valeurs_six), valeur_propre = valeurs_six,
  pourcentage = 100 * valeurs_six / sum(valeurs_six),
  cumul = 100 * cumsum(valeurs_six) / sum(valeurs_six)
))
print(data.frame(
  regle = c("Seuil 80 %", "Seuil 90 %", "Seuil 95 %", "Kaiser", "Jolliffe"),
  q = c(vapply(c(0.8, 0.9, 0.95), function(s) {
    choisir_q(valeurs_six, s)
  }, integer(1)), sum(valeurs_six > 1), sum(valeurs_six > 0.7))
))
tracer_variance(valeurs_six, "Six variables standardisées")
# Le coude illustratif du cours est au rang 4; il reste un jugement visuel.
# Les seuils de Kaiser et Jolliffe concernent seulement une ACP normée.
# Avec six valeurs propres égales à 1, deux axes ne conservent que 33,3 %.


# 7. CONTRIBUTIONS, COSINUS CARRÉS ET CERCLE DES CORRÉLATIONS ----------------

diagnostics_acp_normee <- function(z, acp) {
  # z contient les données centrées réduites qui ont servi à calculer acp.
  stopifnot(
    nrow(z) == nrow(acp$x), ncol(z) == nrow(acp$rotation),
    max(abs(colMeans(z))) < 1e-8,
    max(abs(apply(z, 2, sd) - 1)) < 1e-8
  )
  valeurs <- acp$sdev[seq_len(ncol(acp$x))]^2
  axes_actifs <- valeurs > max(valeurs) * 1e-12
  scores2 <- acp$x^2
  distance2 <- rowSums(z^2)
  # Le seuil distingue le centre des petits résidus d'arrondi numérique.
  hors_centre <- distance2 > max(distance2) * 1e-12

  ctr_ind <- matrix(
    NA_real_, nrow(z), ncol(scores2), dimnames = dimnames(acp$x)
  )
  ctr_ind[, axes_actifs] <- sweep(
    scores2[, axes_actifs, drop = FALSE],
    2, (nrow(z) - 1) * valeurs[axes_actifs], "/"
  )
  cos2_ind <- matrix(
    NA_real_, nrow(z), ncol(scores2), dimnames = dimnames(acp$x)
  )
  cos2_ind[hors_centre, ] <- sweep(
    scores2[hors_centre, , drop = FALSE], 1, distance2[hors_centre], "/"
  )
  correlations <- sweep(acp$rotation, 2, sqrt(valeurs), "*")
  correlations[, !axes_actifs] <- NA_real_
  ctr_var <- acp$rotation^2
  ctr_var[, !axes_actifs] <- NA_real_

  list(
    valeurs = valeurs, correlations = correlations,
    ctr_ind = ctr_ind, cos2_ind = cos2_ind,
    ctr_var = ctr_var, cos2_var = correlations^2
  )
}

diag_examens <- diagnostics_acp_normee(z_examens, acp_examens)
cat("\nContributions (%) des profils A, B et C :\n")
print(100 * diag_examens$ctr_ind[c("A", "B", "C"), ])
cat("Cosinus carrés (%) de ces profils :\n")
print(100 * diag_examens$cos2_ind[c("A", "B", "C"), ])
cat("Contributions des variables (%) : 50 % sur chacun des axes\n")
print(100 * diag_examens$ctr_var)
cat("Qualité des variables (%) : 90 % sur CP1, 10 % sur CP2\n")
print(100 * diag_examens$cos2_var)
# C est au centre : ses cosinus carrés sont NA (0 / 0), pas égaux à zéro.
# Sur un axe, les contributions somment à 1. Pour un individu hors du centre,
# les cosinus carrés somment à 1 sur tous les axes.
# Ceux d'un plan s'additionnent.
stopifnot(
  max(abs(colSums(diag_examens$ctr_ind) - 1)) < 1e-10,
  max(abs(colSums(diag_examens$ctr_var) - 1)) < 1e-10,
  all(is.na(diag_examens$cos2_ind["C", ]))
)

tracer_cercle <- function(rho, etiquettes, positions, titre) {
  theta <- seq(0, 2 * pi, length.out = 361)
  plot(
    cos(theta), sin(theta), type = "l", asp = 1, col = "#60747d",
    xlim = c(-1.4, 1.4), ylim = c(-1.2, 1.2),
    xlab = "Corrélation avec CP1", ylab = "Corrélation avec CP2", main = titre
  )
  abline(h = 0, v = 0, col = "#c4d2d6")
  arrows(0, 0, rho[, 1], rho[, 2], length = 0.09, col = "#00897b", lwd = 2)
  segments(rho[, 1], rho[, 2], positions[, 1], positions[, 2], col = "#aab7bb")
  text(positions, labels = etiquettes, cex = 0.9)
}
tracer_cercle(
  diag_examens$correlations, colnames(notes),
  rbind(c(0.7, 0.6), c(0.7, -0.6)), "Cercle des corrélations : deux examens"
)
# Les flèches atteignent le cercle : le plan restitue les deux variables.
# Leur angle a pour cosinus 0,8. Cette lecture des angles devient approximative
# dans un plan incomplet et peu fiable pour des flèches courtes.


# 8. PALMER PENGUINS : DONNÉES ET PRÉPARATION --------------------------------

# Chemins pris en charge : exécution depuis la racine ou depuis codes/.
chemins <- c("assets/penguins.csv", "../assets/penguins.csv")
chemin_donnees <- chemins[file.exists(chemins)][1]
if (is.na(chemin_donnees)) {
  stop("Fichier absent : lancer le script depuis la racine du dépôt.")
}
penguins <- read.csv(chemin_donnees, na.strings = "NA")
penguins$ligne_originale <- seq_len(nrow(penguins))
variables <- c(
  "bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"
)
complets <- complete.cases(penguins[variables])
donnees <- penguins[complets, ]
x_penguins <- as.matrix(donnees[variables])
rownames(x_penguins) <- donnees$ligne_originale

cat("\nLignes exclues, uniquement sur les quatre mesures :\n")
print(penguins$ligne_originale[!complets])
cat("Effectifs conservés par espèce :\n")
print(table(donnees$species))
cat("Sexes manquants conservés :", sum(is.na(donnees$sex)), "\n")
stopifnot(
  nrow(x_penguins) == 342L,
  identical(which(!complets), c(4L, 272L)),
  all(is.finite(x_penguins)), all(apply(x_penguins, 2, sd) > 0)
)

# species colore les points; elle ne participe jamais au calcul des axes.
# year, sex, island et l'identifiant restent aussi hors de la matrice active.
# On ne centre pas séparément chaque espèce : cela effacerait leurs écarts.
acp_penguins <- prcomp(x_penguins, center = TRUE, scale. = TRUE)
# Convention des figures : coefficient de plus grande amplitude positif.
signes_penguins <- apply(acp_penguins$rotation, 2, function(v) {
  sign(v[which.max(abs(v))])
})
acp_penguins$rotation <- sweep(
  acp_penguins$rotation, 2, signes_penguins, "*"
)
acp_penguins$x <- sweep(acp_penguins$x, 2, signes_penguins, "*")
z_penguins <- scale(
  x_penguins, center = acp_penguins$center, scale = acp_penguins$scale
)
diag_penguins <- diagnostics_acp_normee(z_penguins, acp_penguins)
valeurs_penguins <- acp_penguins$sdev^2
q_penguins <- choisir_q(valeurs_penguins, seuil = 0.95)

cat("\nValeurs propres et variance expliquée des manchots :\n")
print(data.frame(
  axe = seq_along(valeurs_penguins), valeur_propre = valeurs_penguins,
  pourcentage = 100 * valeurs_penguins / sum(valeurs_penguins),
  cumul = 100 * cumsum(valeurs_penguins) / sum(valeurs_penguins)
))
cat("Nombre retenu pour 95 % de variance :", q_penguins, "\n")
tracer_variance(valeurs_penguins, "Palmer Penguins : ACP normée")


# 9. INTERPRÉTER LES VARIABLES ET LES INDIVIDUS -----------------------------

cat("\nCorrélations variables-axes et qualités dans le premier plan :\n")
print(cbind(
  diag_penguins$correlations[, 1:2],
  qualite_plan_pct = 100 * rowSums(diag_penguins$cos2_var[, 1:2])
))
cat("Contributions des variables aux deux premiers axes (%) :\n")
print(100 * diag_penguins$ctr_var[, 1:2])
# CP1 associe nageoires longues, masse élevée, bec long et profondeur moindre.
# CP2 décrit surtout les deux mesures du bec. Leurs contributions ont toujours
# un signe positif : revenir aux corrélations pour connaître les oppositions.

tracer_cercle(
  diag_penguins$correlations[, 1:2],
  c("Longueur du bec", "Profondeur du bec", "Nageoire", "Masse"),
  rbind(c(0.65, 0.7), c(-0.7, 0.9), c(0.6, -0.2), c(0.6, -0.5)),
  "Palmer Penguins : variables"
)

couleurs_especes <- c(
  Adelie = "#00897b", Chinstrap = "#d95f02", Gentoo = "#7570b3"
)
symboles_especes <- c(Adelie = 16, Chinstrap = 17, Gentoo = 15)
i_327 <- match(327L, donnees$ligne_originale)
qualite_plan <- rowSums(diag_penguins$cos2_ind[, 1:2])

tracer_individus <- function(axes = c(1L, 2L)) {
  parts <- 100 * valeurs_penguins / sum(valeurs_penguins)
  scores <- acp_penguins$x[, axes, drop = FALSE]
  plot(
    scores, asp = 1, pch = symboles_especes[donnees$species],
    col = couleurs_especes[donnees$species],
    xlab = sprintf("CP%d : %.2f %%", axes[1], parts[axes[1]]),
    ylab = sprintf("CP%d : %.2f %%", axes[2], parts[axes[2]]),
    main = sprintf("Palmer Penguins : plan CP%d-CP%d", axes[1], axes[2])
  )
  abline(h = 0, v = 0, col = "#c4d2d6")
  points(scores[i_327, 1], scores[i_327, 2], pch = 1, cex = 2, lwd = 2)
  text(scores[i_327, 1], scores[i_327, 2], "327", pos = 4)
  legend(
    "topright", names(couleurs_especes), col = couleurs_especes,
    pch = symboles_especes, bty = "n", cex = 0.85
  )
}
tracer_individus(c(1L, 2L))
tracer_individus(c(1L, 3L))

cat("\nLigne originale 327 : mesures, scores et qualité\n")
print(x_penguins[i_327, ])
print(acp_penguins$x[i_327, ])
print(c(
  qualite_cp1_cp2_pct = 100 * unname(qualite_plan[i_327]),
  qualite_cp1_cp3_pct = 100 * sum(diag_penguins$cos2_ind[i_327, c(1, 3)])
))
# Le premier plan conserve 88,16 % de variance, mais seulement 1,81 % de
# l'écart de cet individu au centre. Le troisième axe révèle son profil.
cat("Contributions individuelles moyennes :", 100 / nrow(donnees), "%\n")
cat("Cinq individus les plus contributifs à CP1 :\n")
plus_contributifs <- head(
  order(diag_penguins$ctr_ind[, 1], decreasing = TRUE), 5L
)
print(data.frame(
  ligne_originale = donnees$ligne_originale[plus_contributifs],
  espece = donnees$species[plus_contributifs],
  contribution_cp1_pct = 100 * diag_penguins$ctr_ind[plus_contributifs, 1],
  qualite_plan_pct = 100 * qualite_plan[plus_contributifs]
))


# 10. RECONSTRUCTION ET EFFET DES UNITÉS ------------------------------------

reconstruire <- function(acp, q, scores = acp$x) {
  stopifnot(length(q) == 1L, is.finite(q), q == as.integer(q),
            q >= 1, q <= ncol(acp$rotation))
  z_reconstruit <- tcrossprod(
    scores[, seq_len(q), drop = FALSE],
    acp$rotation[, seq_len(q), drop = FALSE]
  )
  if (!isFALSE(acp$scale)) {
    z_reconstruit <- sweep(z_reconstruit, 2, acp$scale, "*")
  }
  sweep(z_reconstruit, 2, acp$center, "+")
}

x_reconstruit <- reconstruire(acp_penguins, q_penguins)
z_reconstruit <- scale(
  x_reconstruit, center = acp_penguins$center, scale = acp_penguins$scale
)
perte_penguins <- sum((z_penguins - z_reconstruit)^2) / (nrow(donnees) - 1)
cat("\nInertie perdue avec trois composantes :", perte_penguins, "\n")
cat("Dernière valeur propre :", valeurs_penguins[4], "\n")
stopifnot(
  abs(perte_penguins - valeurs_penguins[4]) < 1e-10,
  max(abs(reconstruire(acp_penguins, 4L) - x_penguins)) < 1e-8
)

# Changer seulement l'unité de masse : grammes puis kilogrammes.
x_kilogrammes <- x_penguins
x_kilogrammes[, "body_mass_g"] <- x_penguins[, "body_mass_g"] / 1000
acp_centree_g <- prcomp(x_penguins, center = TRUE, scale. = FALSE)
acp_centree_kg <- prcomp(x_kilogrammes, center = TRUE, scale. = FALSE)
acp_normee_kg <- prcomp(x_kilogrammes, center = TRUE, scale. = TRUE)
part_premier_axe <- function(acp) acp$sdev[1]^2 / sum(acp$sdev^2)

cat("\nPart de variance conservée par CP1 selon la préparation (%) :\n")
print(100 * c(
  centree_grammes = part_premier_axe(acp_centree_g),
  centree_kilogrammes = part_premier_axe(acp_centree_kg),
  normee_grammes = part_premier_axe(acp_penguins),
  normee_kilogrammes = part_premier_axe(acp_normee_kg)
))
cat("Part de la masse dans l'inertie brute (%) :",
    100 * var(x_penguins[, 4]) / sum(apply(x_penguins, 2, var)), "\n")
stopifnot(max(abs(acp_normee_kg$sdev^2 - valeurs_penguins)) < 1e-10)
# Le changement d'unité n'affecte pas l'ACP normée. Le nom body_mass_g est
# conservé dans la copie pour suivre la même colonne, désormais exprimée en kg.


# 11. NOUVELLES OBSERVATIONS : PRÉPARATION APPRISE SANS LE TEST --------------

# L'analyse précédente était descriptive. Démonstration séparée : réserver
# maintenant des observations pour illustrer une projection hors échantillon.
# Ici q = 2 est fixé avant l'évaluation; on ne le choisit pas sur le test.
set.seed(graine_defaut + 1L)
indices_train <- sample.int(nrow(x_penguins), floor(0.75 * nrow(x_penguins)))
x_train <- x_penguins[indices_train, , drop = FALSE]
x_test <- x_penguins[-indices_train, , drop = FALSE]
q_projection <- 2L
acp_train <- prcomp(x_train, center = TRUE, scale. = TRUE)

# predict() réutilise les moyennes, les écarts-types et les axes appris.
scores_test <- predict(acp_train, newdata = x_test)
z_test <- scale(x_test, center = acp_train$center, scale = acp_train$scale)
stopifnot(max(abs(scores_test - z_test %*% acp_train$rotation)) < 1e-10)

x_test_reconstruit <- reconstruire(acp_train, q_projection, scores_test)
residus_test <- sweep(x_test - x_test_reconstruit, 2, acp_train$scale, "/")
erreur_test <- rowSums(residus_test^2)
cat("\nErreur quadratique moyenne de reconstruction standardisée du test :",
    mean(erreur_test), "\n")
# Pour choisir q pour une prédiction, comparer la procédure complète par
# validation croisée : préparation, ACP et modèle dans chaque pli. La seule
# erreur de reconstruction décroît avec q et favorise toujours plus d'axes.


# 12. LIMITES : LINÉARITÉ, INDÉPENDANCE ET OBSERVATIONS EXTRÊMES --------------

# Un seul angle décrit un cercle, mais une droite ne permet pas
# de le reconstruire.
theta <- 2 * pi * (0:359) / 360
cercle <- cbind(horizontal = cos(theta), vertical = sin(theta))
acp_cercle <- prcomp(cercle, center = TRUE, scale. = FALSE)
cat("\nCercle : parts de variance des deux axes (%)\n")
print(100 * acp_cercle$sdev^2 / sum(acp_cercle$sdev^2))
plot(
  cercle, asp = 1, pch = 16, cex = 0.5, col = "#00897b",
  main = "Un paramètre, mais deux composantes pour reconstruire",
  xlab = "cos(theta)", ylab = "sin(theta)"
)
cat("Corrélation des coordonnées du cercle :", cor(cercle)[1, 2], "\n")
# Les coordonnées sont non corrélées, mais pas indépendantes : connaître
# cos(theta)^2 détermine sin(theta)^2 = 1 - cos(theta)^2.

# Ajouter une observation loin du centre modifie la covariance et les axes.
z_avec_point <- rbind(z_examens, c(0, 6))
acp_avec_point <- prcomp(z_avec_point, center = TRUE, scale. = FALSE)
produit_axes <- sum(axes_examens[, 1] * acp_avec_point$rotation[, 1])
rotation_degres <- acos(min(1, abs(produit_axes))) * 180 / pi
cat("Rotation du premier axe après ajout du point (degrés) :",
    rotation_degres, "\n")
# La valeur absolue ignore les simples inversions de signe. Une observation
# influente peut être réelle : son influence ne suffit pas à la supprimer.
# L'ACP maximise la variance, pas une performance prédictive ni une causalité.

cat("\nFin des démonstrations d'ACP.\n")
