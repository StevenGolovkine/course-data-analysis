# Analyse en composantes principales — STT-2200
options(width = 80, digits = 4)
graine_defaut <- 2200L
set.seed(graine_defaut)

# FONCTIONS ---------------------------------------

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

# PALMER PENGUINS --------------------------------

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