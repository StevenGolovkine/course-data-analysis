# k-means — exemple Palmer Penguins du cours.
# Depuis la racine du dépôt : Rscript codes/k_means.R
# Dépendance : cluster (paquet recommandé de R), pour la silhouette.
# Option : un dossier de sortie pour exporter les tableaux utilisés par la figure.
#   Rscript codes/k_means.R /tmp/course-kmeans

penguins <- read.csv("../assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[variables]), ]
x <- as.matrix(d[variables])
z <- scale(x)
distances <- dist(z)
n <- nrow(z)
inertie_totale <- sum(scale(z, center = TRUE, scale = FALSE)^2)

# Exploration descriptive sur les quatre mesures : aucune étiquette species
# n'intervient dans les ajustements ni dans la sélection du nombre de groupes.
set.seed(2200)
K_candidats <- 1:8
modeles <- lapply(K_candidats, function(K) {
  kmeans(z, centers = K, nstart = 50, iter.max = 100,
         algorithm = "Hartigan-Wong")
})
W <- vapply(modeles, function(m) m$tot.withinss, numeric(1))
silhouettes <- vapply(seq_along(modeles), function(j) {
  if (K_candidats[j] == 1L) return(NA_real_)
  mean(cluster::silhouette(modeles[[j]]$cluster, distances)[, "sil_width"])
}, numeric(1))
criteres <- data.frame(K = K_candidats, W = W,
                       R2 = pmax(0, 1 - W / inertie_totale),
                       silhouette = silhouettes)
criteres$CH <- NA_real_
j <- K_candidats > 1L
criteres$CH[j] <- ((inertie_totale - W[j]) / (K_candidats[j] - 1)) /
                  (W[j] / (n - K_candidats[j]))
K_retenu <- K_candidats[which.max(replace(silhouettes, is.na(silhouettes), -Inf))]
modele <- modeles[[K_retenu]]

# Numéroter les groupes par body_mass_g moyen croissant, pour présenter
# les résultats dans un ordre stable. Cela ne change pas la partition.
ordre <- order(modele$centers[, "body_mass_g"])
groupes <- match(modele$cluster, ordre)
centres_z <- modele$centers[ordre, , drop = FALSE]
centres <- sweep(sweep(centres_z, 2, attr(z, "scaled:scale"), "*"),
                  2, attr(z, "scaled:center"), "+")
profils <- data.frame(groupe = seq_len(K_retenu),
                      n = tabulate(groupes, nbins = K_retenu), centres,
                      row.names = NULL, check.names = FALSE)

cat("Effectif et inertie totale :", n, "et", inertie_totale, "\n")
cat("Critères pour chaque nombre de groupes :\n")
print(criteres, digits = 6, row.names = FALSE)
cat("Nombre de groupes retenu par silhouette moyenne :", K_retenu, "\n")
cat("\nProfils moyens dans les unités originales :\n")
print(profils, digits = 6, row.names = FALSE)
cat("\nComparaison descriptive après ajustement (species non utilisée) :\n")
print(table(Groupe = groupes, Species = d$species))

# Vérifier la décomposition d'inertie et les affectations au plus proche centre.
W_direct <- sum((z - centres_z[groupes, , drop = FALSE])^2)
ecarts_centres <- sweep(centres_z, 2, colMeans(z), "-")
B_direct <- sum(profils$n * rowSums(ecarts_centres^2))
distances_centres <- vapply(seq_len(K_retenu), function(g) {
  rowSums(sweep(z, 2, centres_z[g, ], "-")^2)
}, numeric(n))


