# Classification hiérarchique de Palmer Penguins — STT-2200

# Si nécessaire : install.packages("cluster"), une seule fois.
#

# 0. FONCTIONS ------------------------------------------------------
matrice_numerique <- function(x) {
  # Un vecteur représente ici plusieurs observations d'une seule variable.
  x <- as.matrix(x)
  x
}

inertie_groupe <- function(x) {
  x <- matrice_numerique(x)
  sum(sweep(x, 2, colMeans(x), "-")^2)
}

inertie_partition <- function(x, groupes) {
  x <- matrice_numerique(x)
  indices <- split(seq_len(nrow(x)), groupes)
  sum(vapply(indices, function(i) {
    inertie_groupe(x[i, , drop = FALSE])
  }, numeric(1)))
}

cout_ward <- function(a, b) {
  a <- matrice_numerique(a)
  b <- matrice_numerique(b)
  n_a <- nrow(a)
  n_b <- nrow(b)
  n_a * n_b / (n_a + n_b) * sum((colMeans(a) - colMeans(b))^2)
}

verifier_ward <- function(x, arbre) {
  # Retrouver les membres depuis merge : négatif = feuille, positif = fusion.
  x <- matrice_numerique(x)
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
    gains[r] <- cout_ward(
      x[a, , drop = FALSE], x[b, , drop = FALSE]
    )
    groupes[[r]] <- c(a, b)
    effectifs[r] <- length(a) + length(b)
  }
  data.frame(
    gauche = arbre$merge[, 1], droite = arbre$merge[, 2],
    hauteur = arbre$height, gain = gains, effectif = effectifs
  )
}

meme_partition <- function(a, b) {
  # Comparer les paires, pas les numéros arbitraires des groupes.
  all(outer(a, a, "==") == outer(b, b, "=="))
}

rand_ajuste <- function(a, b) {
  tableau <- table(a, b)
  paires <- function(effectifs) sum(effectifs * (effectifs - 1) / 2)
  commun <- paires(tableau)
  total_a <- paires(rowSums(tableau))
  total_b <- paires(colSums(tableau))
  attendu <- total_a * total_b / choose(length(a), 2)
  maximum <- (total_a + total_b) / 2
  # Cas dégénérés : deux partitions en un groupe ou deux en singletons.
  if (abs(maximum - attendu) < 1e-12) {
    return(as.numeric(meme_partition(a, b)))
  }
  (commun - attendu) / (maximum - attendu)
}

silhouette_moyenne <- function(groupes, distances) {
  k <- length(unique(groupes))
  n <- length(groupes)
  # Une silhouette exige au moins deux groupes et moins de n groupes.
  if (k < 2L || k >= n) return(NA_real_)
  codes <- as.integer(factor(groupes))
  mean(cluster::silhouette(codes, distances)[, "sil_width"])
}

correlation_cophenetique <- function(distances, arbre) {
  # Aligner explicitement les mêmes paires, dans l'ordre initial.
  matrice <- as.matrix(distances)
  coph <- as.matrix(cophenetic(arbre))
  noms <- rownames(matrice)
  coph <- coph[noms, noms, drop = FALSE]
  paires <- lower.tri(matrice)
  initiales <- matrice[paires]
  communes <- coph[paires]
  if (length(initiales) < 2L) return(NA_real_)
  if (sd(initiales) == 0 || sd(communes) == 0) return(NA_real_)
  cor(initiales, communes)
}


# 1. PALMER PENGUINS : PRÉPARATION ET CHOIX D'UNE COUPE ----------------------

chemins <- c("assets/penguins.csv", "../assets/penguins.csv")
chemin_donnees <- chemins[file.exists(chemins)][1]
penguins <- read.csv(chemin_donnees, na.strings = "NA")
variables <- c(
  "bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"
)
cas_complets <- complete.cases(penguins[variables])
donnees <- penguins[cas_complets, , drop = FALSE]
x <- as.matrix(donnees[variables])
z <- scale(x)
n <- nrow(z)
p <- ncol(z)
distances <- dist(z)

# Avec ward.D2, fournir les distances euclidiennes, sans les mettre au carré.
# La hauteur h correspond à sqrt(2 Delta W) pour chaque fusion.
arbre <- hclust(distances, method = "ward.D2")
plot(arbre)

fusions <- verifier_ward(z, arbre)
inertie_totale <- inertie_groupe(z)
cat("Lignes exclues :", sum(!cas_complets), "; observations :", n, "\n")
cat("Inertie totale :", inertie_totale, "= (n - 1) p\n")

# L'analyse est descriptive : pas de réponse à prédire ni de test réservé.
# Les espèces ne servent ni à préparer les variables ni à sélectionner K.
# Les cas complets sont un choix explicite, pas un traitement universel des NA.

k_candidats <- 2:8
partitions <- lapply(k_candidats, function(k) cutree(arbre, k = k))
w <- vapply(partitions, function(groupes) {
  inertie_partition(z, groupes)
}, numeric(1))
silhouettes <- vapply(partitions, function(groupes) {
  silhouette_moyenne(groupes, distances)
}, numeric(1))
criteres <- data.frame(
  k = k_candidats, w = w, r2 = 1 - w / inertie_totale,
  silhouette = silhouettes
)
print(criteres, digits = 6, row.names = FALSE)
# which.max retient le premier maximum ; candidats en ordre croissant.
k_retenu <- k_candidats[which.max(silhouettes)]
groupes_bruts <- cutree(arbre, k = k_retenu)
cat("K retenu par silhouette moyenne :", k_retenu, "\n")
# La silhouette utilise distances = dist(z), PAS cophenetic(arbre).
# Elle vaut 0 pour un singleton ; elle n'est pas définie pour K = 1 ou n.

cat("\nDernières fusions :\n")
print(tail(fusions, 4), digits = 6, row.names = FALSE)
# Un saut n'est ni une probabilité ni un test de significativité.


# 2. PROFILS ET SENSIBILITÉ À LA LIAISON ------------------------------------

cat("\n2. Interpréter la partition après l'avoir choisie\n")
# Renuméroter par masse moyenne croissante ; aucune observation ne change
# de groupe. Les espèces ne jouent toujours aucun rôle dans ce classement.
ordre_groupes <- order(tapply(x[, "body_mass_g"], groupes_bruts, mean))
groupes <- match(groupes_bruts, ordre_groupes)
profils <- do.call(rbind, lapply(seq_len(k_retenu), function(g) {
  data.frame(
    groupe = g, n = sum(groupes == g),
    as.list(colMeans(x[groupes == g, , drop = FALSE]))
  )
}))
print(profils, digits = 6, row.names = FALSE)
table_especes <- table(groupe = groupes, espece = donnees$species)
print(table_especes)

liaisons <- c("single", "complete", "average", "ward.D2")
arbres_penguins <- setNames(lapply(liaisons, function(liaison) {
  hclust(distances, method = liaison)
}), liaisons)
comparaison <- do.call(rbind, lapply(liaisons, function(liaison) {
  modele <- arbres_penguins[[liaison]]
  groupes_l <- cutree(modele, k = 2)
  data.frame(
    liaison = liaison, n_min = min(table(groupes_l)),
    n_max = max(table(groupes_l)),
    silhouette = silhouette_moyenne(groupes_l, distances),
    correlation_cophenetique = correlation_cophenetique(distances, modele)
  )
}))
print(comparaison, digits = 5, row.names = FALSE)

# Sur ces données, les trois dernières coupes sont identiques, pas seulement
# leurs effectifs. Ce n'est pas une propriété générale des trois méthodes.


# 3. WARD ET K-MOYENNES : MÊME INERTIE, CONTRAINTES DIFFÉRENTES --------------

cat("\n3. Réaffecter les points peut améliorer une coupe de Ward\n")
set.seed(2200)
# Même succession d'ajustements que dans le chapitre sur les k-moyennes.
modeles_kmeans <- lapply(1:8, function(k) {
  kmeans(z, centers = k, nstart = 50, iter.max = 100,
         algorithm = "Hartigan-Wong")
})
groupes_ward_trois <- cutree(arbre, k = 3)
centres_ward <- do.call(rbind, lapply(seq_len(3L), function(g) {
  colMeans(z[groupes_ward_trois == g, , drop = FALSE])
}))
kmeans_depuis_ward <- kmeans(z, centers = centres_ward, iter.max = 100)
comparaison_inerties <- data.frame(
  methode = c("Coupe de Ward", "k-moyennes, 50 départs", "Départ Ward"),
  w = c(w[2], modeles_kmeans[[3]]$tot.withinss,
        kmeans_depuis_ward$tot.withinss)
)
print(comparaison_inerties, digits = 6, row.names = FALSE)

# Les groupes fins de Ward sont inclus dans les groupes grossiers.
emboitement <- table(coupe_3 = groupes_ward_trois, coupe_2 = groupes)
print(emboitement)
# Les k-moyennes ne garantissent ni cet emboîtement, ni un minimum global.

# 4. GÉOMÉTRIE ET LIMITES -------------------------------------------------

cat("\n4. Modifier les unités modifie une distance non standardisée\n")
x_kg <- x
x_kg[, "body_mass_g"] <- x_kg[, "body_mass_g"] / 1000
distance_brute <- dist(x)
distance_kg <- dist(x_kg)

print(data.frame(
  geometrie = c("Mesures brutes, masse en g", "Mesures brutes, masse en kg",
                "Mesures centrées et réduites"),
  ari_avec_reference = c(
    rand_ajuste(groupes, cutree(hclust(distance_brute, "ward.D2"), k = 2)),
    rand_ajuste(groupes, cutree(hclust(distance_kg, "ward.D2"), k = 2)),
    1
  )
))
# La standardisation n'enlève ni les valeurs extrêmes ni les corrélations.
# Dupliquer une variable compte deux fois sa contribution au carré.


# 6. GRAPHIQUES POUR LA DÉMONSTRATION EN CLASSE ----------------------------

dessiner_cours_cah <- function() {
  anciens_parametres <- par(no.readonly = TRUE)
  on.exit(par(anciens_parametres), add = TRUE)
  couleurs <- c("#007C78", "#D57535", "#5D6CB0")
  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4, 1), cex.main = 1.05)

  # A. Une seule hiérarchie, plusieurs coupes candidates.
  plot(arbre, labels = FALSE, hang = -1,
       main = "Palmer Penguins : Ward", xlab = "342 manchots",
       sub = "", ylab = "Hauteur")
  ordre_couleurs <- unique(groupes[arbre$order])
  rect.hclust(arbre, k = k_retenu, border = couleurs[ordre_couleurs])
  abline(h = mean(tail(arbre$height, 2)), lty = 2)
  plot(k_candidats, silhouettes, type = "b", pch = 19,
       col = couleurs[1], xlab = "Nombre de groupes K",
       ylab = "Silhouette moyenne", main = "Distance euclidienne initiale")
  abline(v = k_retenu, lty = 2, col = couleurs[2])

  # B. Silhouettes individuelles : la moyenne ne résume pas tout.
  par(mfrow = c(1, 1), mar = c(6, 4.5, 4, 8))
  plot(cluster::silhouette(groupes, distances),
       col = couleurs[1:2], border = NA, nmax.lab = 0,
       xlab = "Silhouette s(i)",
       sub = paste("Silhouette moyenne :", round(max(silhouettes), 3)),
       main = "Palmer Penguins : coupe en deux groupes")

  # C. Les profils restent lisibles dans leurs unités d'origine.
  par(mfrow = c(2, 2), mar = c(5, 5, 3.5, 1))
  titres <- c("Longueur du bec (mm)", "Profondeur du bec (mm)",
              "Longueur de la nageoire (mm)", "Masse (g)")
  for (j in seq_along(variables)) {
    boxplot(x[, j] ~ groupes, col = couleurs[1:2],
            xlab = "Groupe de Ward", ylab = titres[j], main = titres[j])
  }

  # D. La comparaison porte sur la même géométrie et le même K.
  par(mfrow = c(1, 1), mar = c(4.5, 4.5, 4, 1))
  w_kmeans <- vapply(modeles_kmeans[k_candidats], function(modele) {
    modele$tot.withinss
  }, numeric(1))
  matplot(k_candidats, cbind(w, w_kmeans), type = "b",
          lty = 1:2, pch = c(19, 17), col = couleurs[1:2],
          xlab = "Nombre de groupes K", ylab = "Inertie intra-groupe",
          main = "Ward et k-moyennes : contraintes différentes")
  legend("topright", legend = c("Coupe de Ward", "k-moyennes, 50 départs"),
         lty = 1:2, pch = c(19, 17), col = couleurs[1:2], bty = "n")

  layout(1)
  invisible(NULL)
}


dessiner_cours_cah()

