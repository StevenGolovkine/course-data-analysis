# ACM d'une enquête fictive sur les habitudes d'étude.
# Depuis la racine du dépôt : Rscript codes/analyse_correspondances_multiples.R
# Avec FactoMineR installé, les résultats sont aussi comparés à MCA().
# Un argument facultatif indique où exporter les données pour les figures.

profils <- data.frame(
  profil = LETTERS[1:8],
  rythme = factor(c(rep("Régulier", 4), rep("Ponctuel", 4)),
                  levels = c("Régulier", "Ponctuel")),
  support = factor(c("Livres", "Livres", "Mixte", "Mixte",
                      "Vidéos", "Vidéos", "Mixte", "Mixte"),
                   levels = c("Livres", "Mixte", "Vidéos")),
  travail = factor(rep(c("Seul", "Groupe"), 4), levels = c("Seul", "Groupe")),
  effectif = c(3, 1, 1, 2, 2, 1, 1, 1)
)
indices <- rep(seq_len(nrow(profils)), profils$effectif)
donnees <- profils[indices, c("rythme", "support", "travail")]
rownames(donnees) <- seq_len(nrow(donnees))
n <- nrow(donnees)
p <- ncol(donnees)

# Une colonne par modalité, y compris toutes les modalités de chaque variable.
Z <- do.call(cbind, lapply(names(donnees), function(v) {
  bloc <- sapply(levels(donnees[[v]]), function(m) as.numeric(donnees[[v]] == m))
  colnames(bloc) <- paste(v, levels(donnees[[v]]), sep = "_")
  bloc
}))
J <- ncol(Z)
f <- colMeans(Z)
r <- rep(1 / n, n)
c <- f / p
P <- Z / (n * p)
S <- (P - outer(r, c)) / sqrt(outer(r, c))
decomposition <- svd(S)
rang <- sum(decomposition$d > 1e-10)
sigma <- decomposition$d[seq_len(rang)]
U <- decomposition$u[, seq_len(rang), drop = FALSE]
V <- decomposition$v[, seq_len(rang), drop = FALSE]
lambda <- sigma^2
F <- sweep(U, 2, sigma, "*") / sqrt(r)
G <- sweep(V, 2, sigma, "*") / sqrt(c)
rownames(G) <- colnames(Z)

# Orientation déterministe : Vidéos à droite et Groupe en haut.
for (k in seq_len(rang)) {
  ancre <- if (k == 1L) match("support_Vidéos", rownames(G)) else if (k == 2L) {
    match("travail_Groupe", rownames(G))
  } else which.max(abs(G[, k]))
  signe <- sign(G[ancre, k])
  F[, k] <- signe * F[, k]
  G[, k] <- signe * G[, k]
}
colnames(F) <- colnames(G) <- paste0("axe", seq_len(rang))
contributions <- sweep(c * G^2, 2, lambda, "/")
cos2 <- G^2 / (1 / f - 1)
barycentres <- sweep(crossprod(Z, F), 1, colSums(Z), "/")
eta2 <- sapply(names(donnees), function(v) {
  j <- startsWith(colnames(Z), paste0(v, "_"))
  colSums(f[j] * barycentres[j, , drop = FALSE]^2) / lambda
})
eta2 <- t(eta2)
inerties_corrigees <- (p / (p - 1) * pmax(lambda - 1 / p, 0))^2
Burt <- crossprod(Z)
PB <- Burt / sum(Burt)
SB <- (PB - outer(c, c)) / sqrt(outer(c, c))

# Vérifications des identités du cours et des distances dans l'espace complet.
distance_individus <- as.matrix(dist(sweep(Z, 2, sqrt(p * f), "/")))^2
stopifnot(
  all(rowSums(Z) == p), all(f > 0),
  rang <= min(n - 1, J - p),
  abs(sum(lambda) - (J - p) / p) < 1e-10,
  max(abs(crossprod(S) - SB)) < 1e-10,
  max(abs(as.matrix(dist(F))^2 - distance_individus)) < 1e-10,
  max(abs(crossprod(F, r * F) - diag(lambda))) < 1e-10,
  max(abs(crossprod(G, c * G) - diag(lambda))) < 1e-10,
  max(abs(colSums(contributions) - 1)) < 1e-10,
  max(abs(rowSums(cos2) - 1)) < 1e-10,
  max(abs(F - sweep(Z %*% G / p, 2, sigma, "/"))) < 1e-10,
  max(abs(barycentres - sweep(G, 2, sigma, "*"))) < 1e-10,
  max(abs(colMeans(eta2) - lambda)) < 1e-10
)

if (requireNamespace("FactoMineR", quietly = TRUE)) {
  resultat <- FactoMineR::MCA(donnees, ncp = rang, method = "Indicator", graph = FALSE)
  stopifnot(max(abs(resultat$eig[, 1] - lambda)) < 1e-10)
  # Les signes des axes renvoyés par le logiciel sont arbitraires.
  signes <- sign(colSums(F * resultat$ind$coord))
  stopifnot(max(abs(sweep(resultat$ind$coord, 2, signes, "*") - F)) < 1e-10)
  stopifnot(max(abs(resultat$var$contrib / 100 - contributions)) < 1e-10)
  stopifnot(max(abs(resultat$var$cos2 - cos2)) < 1e-10)
  cat("Comparaison avec FactoMineR : coordonnées, inerties et diagnostics concordants.\n")
}

inerties <- data.frame(axe = seq_len(rang), lambda,
                       pourcentage = 100 * lambda / sum(lambda),
                       cumul = 100 * cumsum(lambda) / sum(lambda),
                       corrigee = inerties_corrigees)
modalites <- data.frame(modalite = colnames(Z), frequence = f, masse = c, G,
                        ctr1 = contributions[, 1], ctr2 = contributions[, 2],
                        cos2_plan = rowSums(cos2[, 1:2]), row.names = NULL)
coord_profils <- F[match(seq_len(nrow(profils)), indices), , drop = FALSE]
individus <- data.frame(profils, coord_profils, row.names = NULL)
cat("\nProfils fictifs :\n"); print(profils, row.names = FALSE)
cat("\nInerties :\n"); print(inerties, digits = 6, row.names = FALSE)
cat("\nModalités :\n"); print(modalites, digits = 6, row.names = FALSE)
cat("\nRapports de corrélation (variables x axes) :\n"); print(eta2, digits = 6)
cat("\nTableau de Burt :\n"); print(Burt)

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) > 0L) {
  dossier_sortie <- arguments[1]
  dir.create(dossier_sortie, recursive = TRUE, showWarnings = FALSE)
  write.csv(individus, file.path(dossier_sortie, "profils.csv"), row.names = FALSE)
  write.csv(modalites, file.path(dossier_sortie, "modalites.csv"), row.names = FALSE)
  write.csv(inerties, file.path(dossier_sortie, "inerties.csv"), row.names = FALSE)
  write.csv(data.frame(profil = profils$profil, Z[match(seq_len(nrow(profils)), indices), ]),
            file.path(dossier_sortie, "disjonctif.csv"), row.names = FALSE)
}
