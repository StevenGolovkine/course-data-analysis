# Classification ascendante hiérarchique — exemples du cours.
# Depuis la racine : Rscript codes/classification_hierarchique.R
# Dépendance : cluster (paquet recommandé de R), pour la silhouette.
# Un argument facultatif indique où exporter les tableaux pour les figures :
#   Rscript codes/classification_hierarchique.R /tmp/course-cah

# Vérifier la convention des hauteurs ward.D2 avec les inerties explicites.
verifier_ward <- function(x, arbre) {
  x <- as.matrix(x)
  n <- nrow(x)
  groupes <- vector("list", n - 1L)
  gains <- numeric(n - 1L)
  effectifs <- integer(n - 1L)
  membres <- function(indice) {
    if (indice < 0L) -indice else groupes[[indice]]
  }
  for (r in seq_len(n - 1L)) {
    a <- membres(arbre$merge[r, 1])
    b <- membres(arbre$merge[r, 2])
    na <- length(a)
    nb <- length(b)
    mu_a <- colMeans(x[a, , drop = FALSE])
    mu_b <- colMeans(x[b, , drop = FALSE])
    gains[r] <- na * nb / (na + nb) * sum((mu_a - mu_b)^2)
    groupes[[r]] <- c(a, b)
    effectifs[r] <- na + nb
  }
  total <- sum(scale(x, center = TRUE, scale = FALSE)^2)
  stopifnot(max(abs(arbre$height^2 / 2 - gains)) < 1e-8,
            abs(sum(gains) - total) < 1e-8,
            all(diff(arbre$height) >= -1e-12))
  data.frame(gauche = arbre$merge[, 1], droite = arbre$merge[, 2],
             hauteur = arbre$height, gain = gains, effectif = effectifs)
}

petit_x <- matrix(c(0, 1, 2, 8, 9, 10), ncol = 1,
                  dimnames = list(LETTERS[1:6], "x"))
petit_arbre <- hclust(dist(petit_x), method = "ward.D2")
petites_fusions <- verifier_ward(petit_x, petit_arbre)
stopifnot(max(abs(petites_fusions$gain - c(0.5, 0.5, 1.5, 1.5, 96))) < 1e-10)
cat("Exemple à six observations :\n")
print(petites_fusions, digits = 7, row.names = FALSE)
cat("Partitions par nombre de groupes :\n")
print(cutree(petit_arbre, k = c(2, 3, 4)))
stopifnot(identical(unname(cutree(petit_arbre, h = 2.5)),
                    unname(cutree(petit_arbre, k = 2))))

# Quatre variables quantitatives ; species ne sert qu'à décrire les groupes
# après le choix de K, jamais à définir la distance ou à choisir la méthode.
penguins <- read.csv("assets/penguins.csv")
variables <- c("bill_length_mm", "bill_depth_mm",
               "flipper_length_mm", "body_mass_g")
d <- penguins[complete.cases(penguins[variables]), ]
x <- as.matrix(d[variables])
z <- scale(x)
distances <- dist(z)
arbre <- hclust(distances, method = "ward.D2")
fusions <- verifier_ward(z, arbre)
n <- nrow(z)
inertie_totale <- sum(z^2)

inertie <- function(groupes) {
  sum(vapply(split(seq_len(n), groupes), function(i) {
    sum(scale(z[i, , drop = FALSE], center = TRUE, scale = FALSE)^2)
  }, numeric(1)))
}
K_candidats <- 2:8
partitions <- lapply(K_candidats, function(K) cutree(arbre, k = K))
W <- vapply(partitions, inertie, numeric(1))
silhouettes <- vapply(partitions, function(groupes) {
  mean(cluster::silhouette(groupes, distances)[, "sil_width"])
}, numeric(1))
criteres <- data.frame(K = K_candidats, W = W,
                       R2 = 1 - W / inertie_totale, silhouette = silhouettes)
# À égalité exacte, retenir le plus petit K (ordre croissant des candidats).
K_retenu <- K_candidats[which.max(silhouettes)]
groupes_bruts <- cutree(arbre, k = K_retenu)
ordre <- order(tapply(x[, "body_mass_g"], groupes_bruts, mean))
groupes <- match(groupes_bruts, ordre)
profils <- do.call(rbind, lapply(seq_len(K_retenu), function(g) {
  data.frame(groupe = g, n = sum(groupes == g),
             as.list(colMeans(x[groupes == g, , drop = FALSE])))
}))

cat("\nPalmer Penguins : effectif et inertie totale :", n, inertie_totale, "\n")
print(criteres, digits = 7, row.names = FALSE)
cat("K retenu par silhouette moyenne :", K_retenu, "\n")
cat("\nProfils moyens en unités originales :\n")
print(profils, digits = 7, row.names = FALSE)
cat("\nTableau descriptif a posteriori :\n")
print(table(Groupe = groupes, Species = d$species))
cat("\nDernières fusions :\n")
print(tail(fusions, 4), digits = 7, row.names = FALSE)

# La somme des gains des n-K fusions redonne l'inertie de la coupe en K groupes.
stopifnot(max(abs(W - cumsum(fusions$gain)[n - K_candidats])) < 1e-8)

# Sensibilité à la liaison à K fixé, sans utiliser les espèces.
liaisons <- c("single", "complete", "average", "ward.D2")
comparaison <- do.call(rbind, lapply(liaisons, function(liaison) {
  groupes_l <- cutree(hclust(distances, method = liaison), k = 2)
  data.frame(liaison = liaison, n_min = min(table(groupes_l)),
             n_max = max(table(groupes_l)),
             silhouette = mean(cluster::silhouette(groupes_l, distances)[, "sil_width"]))
}))
cat("\nSensibilité à la liaison, coupe à K = 2 :\n")
print(comparaison, digits = 7, row.names = FALSE)

# Export des seules données nécessaires aux deux figures, si demandé.
args <- commandArgs(trailingOnly = TRUE)
if (length(args)) {
  sortie <- args[1]
  dir.create(sortie, recursive = TRUE, showWarnings = FALSE)
  ecrire <- function(objet, nom) {
    write.csv(objet, file.path(sortie, nom), row.names = FALSE)
  }
  ecrire(petites_fusions, "exemple_fusions.csv")
  ecrire(data.frame(nom = rownames(petit_x), x = petit_x[, 1]),
         "exemple_points.csv")
  ecrire(fusions, "penguins_fusions.csv")
  ecrire(data.frame(groupe = groupes), "penguins_groupes.csv")
  ecrire(criteres, "criteres.csv")
}
