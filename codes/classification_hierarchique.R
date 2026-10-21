# Classification ascendante hiérarchique (CAH) — STT-2200
# Supports : lectures/unsupervised.typ, section « Classification hiérarchique »,
# et slides/classification_hierarchique.typ.
#
# Dans R : source("codes/classification_hierarchique.R")
# Depuis un terminal : Rscript codes/classification_hierarchique.R
# Fonctionne depuis la racine, codes/ ou via un chemin absolu.
# Données locales ; aucun téléchargement et aucune installation automatique.
# Dépendance : cluster, paquet recommandé de R, pour les silhouettes.
# Si nécessaire : install.packages("cluster"), une seule fois.
#
# Parcours pour le cours :
# 1–3 : liaisons, algorithme pas à pas, inertie et hauteurs de Ward ;
# 4–6 : coupes, ex æquo, inversions et dissimilarités cophénétiques ;
# 7–9 : Palmer Penguins, choix de K, profils et comparaison aux k-moyennes ;
# 10–11 : stabilité, géométrie et limites ;
# 12–13 : graphiques et questions corrigées.
#
# Les graphiques sont affichés en fin d'exécution dans une session interactive.
# Pour les désactiver : options(cah_afficher_graphiques = FALSE).
# Pour les revoir ensuite : dessiner_cours_cah().
# En mode Rscript, aucun fichier ni graphique n'est créé par défaut.
# Pour sauvegarder les graphiques, après source() :
# Ouvrir un fichier : pdf("cah_cours.pdf", width = 11, height = 7).
# Dessiner les graphiques : dessiner_cours_cah().
# Fermer le fichier : dev.off().
# Aucun SVG n'est créé en R : les sources SVG du cours restent en Python.
#
# Compatibilité : l'argument facultatif conserve les cinq exports CSV utilisés
# par figures/classification_hierarchique.py (mêmes noms et colonnes).
#   Rscript codes/classification_hierarchique.R /tmp/course-cah
# Le dossier peut être créé ; les cinq CSV homonymes sont remplacés.
#
# Notations : n observations, p variables, K groupes ; W = inertie intra-groupe
# non normalisée, T = inertie totale, Delta W = coût d'une fusion de Ward.
# Dans les noms R, k, w et r2 suivent la convention snake_case.


# 0. OUTILS DE CALCUL ------------------------------------------------------

if (!requireNamespace("cluster", quietly = TRUE)) {
  stop("Installer le paquet cluster avant d'exécuter ce script.")
}

verifier_proche <- function(obtenu, attendu, tolerance = 1e-8) {
  stopifnot(
    length(obtenu) == length(attendu),
    all(is.finite(obtenu)), all(is.finite(attendu)),
    all(abs(obtenu - attendu) < tolerance)
  )
}

matrice_numerique <- function(x) {
  # Un vecteur représente ici plusieurs observations d'une seule variable.
  x <- as.matrix(x)
  stopifnot(
    is.numeric(x), nrow(x) >= 1L, ncol(x) >= 1L, all(is.finite(x))
  )
  x
}

inertie_groupe <- function(x) {
  x <- matrice_numerique(x)
  sum(sweep(x, 2, colMeans(x), "-")^2)
}

inertie_partition <- function(x, groupes) {
  x <- matrice_numerique(x)
  stopifnot(length(groupes) == nrow(x), !anyNA(groupes))
  indices <- split(seq_len(nrow(x)), groupes)
  sum(vapply(indices, function(i) {
    inertie_groupe(x[i, , drop = FALSE])
  }, numeric(1)))
}

cout_ward <- function(a, b) {
  a <- matrice_numerique(a)
  b <- matrice_numerique(b)
  stopifnot(ncol(a) == ncol(b))
  n_a <- nrow(a)
  n_b <- nrow(b)
  n_a * n_b / (n_a + n_b) * sum((colMeans(a) - colMeans(b))^2)
}

liaison_groupes <- function(
  a, b, methode = c("single", "complete", "average", "centroid", "ward.D2")
) {
  methode <- match.arg(methode)
  a <- matrice_numerique(a)
  b <- matrice_numerique(b)
  stopifnot(ncol(a) == ncol(b))
  distances <- as.matrix(dist(rbind(a, b)))
  entre <- distances[
    seq_len(nrow(a)), nrow(a) + seq_len(nrow(b)), drop = FALSE
  ]
  switch(
    methode,
    single = min(entre),
    complete = max(entre),
    average = mean(entre),
    centroid = sqrt(sum((colMeans(a) - colMeans(b))^2)),
    # Même choix que minimiser Delta W ; convention d'affichage de R.
    ward.D2 = sqrt(2 * cout_ward(a, b))
  )
}

cah_pas_a_pas <- function(x, methode = "ward.D2") {
  # Version volontairement naïve pour petits exemples, pas pour grands n.
  # Toutes les liaisons sont recalculées après chaque fusion.
  x <- matrice_numerique(x)
  n <- nrow(x)
  stopifnot(n >= 2L)
  noms <- rownames(x)
  if (is.null(noms)) noms <- as.character(seq_len(n))
  groupes <- lapply(seq_len(n), function(i) i)
  journal <- vector("list", n - 1L)
  for (etape in seq_len(n - 1L)) {
    paires <- combn(seq_along(groupes), 2)
    valeurs <- apply(paires, 2, function(paire) {
      liaison_groupes(
        x[groupes[[paire[1]]], , drop = FALSE],
        x[groupes[[paire[2]]], , drop = FALSE], methode
      )
    })
    # À égalité exacte, première paire dans l'ordre courant des groupes.
    choix <- which.min(valeurs)
    paire <- paires[, choix]
    a <- groupes[[paire[1]]]
    b <- groupes[[paire[2]]]
    journal[[etape]] <- data.frame(
      etape = etape, gauche = paste(noms[a], collapse = ""),
      droite = paste(noms[b], collapse = ""), hauteur = valeurs[choix],
      cout_ward = if (methode == "ward.D2") {
        cout_ward(x[a, , drop = FALSE], x[b, , drop = FALSE])
      } else {
        NA_real_
      },
      k = n - etape
    )
    groupes <- c(groupes[-paire], list(c(a, b)))
  }
  do.call(rbind, journal)
}

verifier_ward <- function(x, arbre) {
  # Retrouver les membres depuis merge : négatif = feuille, positif = fusion.
  x <- matrice_numerique(x)
  n <- nrow(x)
  stopifnot(arbre$method == "ward.D2", nrow(arbre$merge) == n - 1L)
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
  verifier_proche(arbre$height^2 / 2, gains)
  verifier_proche(sum(gains), inertie_groupe(x))
  stopifnot(all(diff(arbre$height) >= -1e-12))
  data.frame(
    gauche = arbre$merge[, 1], droite = arbre$merge[, 2],
    hauteur = arbre$height, gain = gains, effectif = effectifs
  )
}

meme_partition <- function(a, b) {
  # Comparer les paires, pas les numéros arbitraires des groupes.
  stopifnot(length(a) == length(b), !anyNA(a), !anyNA(b))
  all(outer(a, a, "==") == outer(b, b, "=="))
}

rand_ajuste <- function(a, b) {
  stopifnot(length(a) == length(b), length(a) >= 2L, !anyNA(a), !anyNA(b))
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


# 1. LES DISTANCES ENTRE GROUPES -------------------------------------------

cat("\n1. Même distance entre points, plusieurs liaisons entre groupes\n")
a <- matrix(c(0, 2), ncol = 1)
b <- matrix(c(3, 5), ncol = 1)
methodes <- c("single", "complete", "average", "centroid")
distances_groupes <- vapply(methodes, function(methode) {
  liaison_groupes(a, b, methode)
}, numeric(1))
print(distances_groupes)
verifier_proche(distances_groupes, c(1, 5, 3, 3))

# Actualisation de la moyenne : pondérer par les effectifs, pas par 1/2.
groupe_c <- matrix(8, ncol = 1)
a_reduit <- a[1, , drop = FALSE]
moyenne_directe <- liaison_groupes(rbind(a_reduit, b), groupe_c, "average")
moyenne_ponderee <- (
  nrow(a_reduit) * liaison_groupes(a_reduit, groupe_c, "average") +
    nrow(b) * liaison_groupes(b, groupe_c, "average")
) / (nrow(a_reduit) + nrow(b))
moyenne_non_ponderee <- mean(c(
  liaison_groupes(a_reduit, groupe_c, "average"),
  liaison_groupes(b, groupe_c, "average")
))
print(c(directe = moyenne_directe, ponderee = moyenne_ponderee,
        non_ponderee = moyenne_non_ponderee))
verifier_proche(moyenne_directe, moyenne_ponderee)
stopifnot(abs(moyenne_directe - moyenne_non_ponderee) > 0.1)

# Les nuages 2D des figures du chapitre.
nuage_a <- rbind(c(0.5, 0.7), c(0.8, 2.6), c(2, 1.2))
nuage_b <- rbind(c(3.5, 0.8), c(4, 2.7), c(5.2, 0.5), c(5.3, 2))
liaisons_2d <- vapply(methodes, function(methode) {
  liaison_groupes(nuage_a, nuage_b, methode)
}, numeric(1))
print(round(liaisons_2d, 2))
verifier_proche(round(liaisons_2d, 2), c(1.55, 4.97, 3.61, 3.40))


# 2. CONSTRUIRE UNE CAH PAS À PAS ------------------------------------------

cat("\n2. Six observations : une hiérarchie de Ward\n")
petit_x <- matrix(
  c(0, 1, 2, 8, 9, 10), ncol = 1,
  dimnames = list(LETTERS[1:6], "x")
)
journal_ward <- cah_pas_a_pas(petit_x)
print(journal_ward, digits = 6, row.names = FALSE)
petit_arbre <- hclust(dist(petit_x), method = "ward.D2")
petites_fusions <- verifier_ward(petit_x, petit_arbre)
verifier_proche(journal_ward$hauteur, petit_arbre$height)
verifier_proche(petites_fusions$gain, c(0.5, 0.5, 1.5, 1.5, 96))
print(petites_fusions, digits = 6, row.names = FALSE)
cat("merge : indice négatif = observation ; positif = fusion précédente.\n")
# Notre règle de départage et celle du logiciel ne sont pas universelles.
# Les groupes formés peuvent différer en cas d'ex æquo sur d'autres données.

cat("\nQuatre observations : changer la liaison change les fusions\n")
quatre_x <- matrix(
  c(0, 1, 3.2, 5.8), ncol = 1,
  dimnames = list(LETTERS[1:4], "x")
)
liaisons <- c("single", "complete", "average", "ward.D2")
arbres_quatre <- setNames(lapply(liaisons[1:3], function(methode) {
  hclust(dist(quatre_x), method = methode)
}), liaisons[1:3])
for (methode in names(arbres_quatre)) {
  cat("\nLiaison :", methode, "\n")
  journal <- cah_pas_a_pas(quatre_x, methode)
  print(journal[, c("etape", "gauche", "droite", "hauteur", "k")],
        row.names = FALSE)
  verifier_proche(journal$hauteur, arbres_quatre[[methode]]$height)
  print(cutree(arbres_quatre[[methode]], k = 2))
}
verifier_proche(
  vapply(arbres_quatre, function(arbre) tail(arbre$height, 1), numeric(1)),
  c(2.6, 5.8, 4)
)


# 3. WARD : COÛT D'UNE FUSION ET HAUTEUR -----------------------------------

cat("\n3. Ward : Delta W n'est pas la hauteur affichée par ward.D2\n")
inertie_avant <- inertie_groupe(nuage_a) + inertie_groupe(nuage_b)
inertie_apres <- inertie_groupe(rbind(nuage_a, nuage_b))
gain_2d <- cout_ward(nuage_a, nuage_b)
print(c(avant = inertie_avant, apres = inertie_apres,
        delta_w = gain_2d, hauteur_r = sqrt(2 * gain_2d)))
verifier_proche(inertie_apres - inertie_avant, gain_2d)
verifier_proche(round(c(inertie_avant, inertie_apres, gain_2d), 2),
                c(8.76, 28.58, 19.82))
verifier_proche(cout_ward(a, b), 9)
verifier_proche(cout_ward(matrix(0), matrix(1)), 0.5)
# Avec ward.D2, fournir dist(x), PAS dist(x)^2 : R élève déjà au carré.
# ward.D ne met pas en œuvre le même critère de Ward.
# Une dissimilarité arbitraire ne justifie pas l'interprétation par l'inertie.

petites_coupes <- cutree(petit_arbre, k = 1:6)
petites_inerties <- apply(petites_coupes, 2, function(groupes) {
  inertie_partition(petit_x, groupes)
})
# Ajouter 0 pour la partition initiale en n singletons.
inerties_cumulees <- c(0, cumsum(petites_fusions$gain))
verifier_proche(petites_inerties, inerties_cumulees[6 - (1:6) + 1])
print(data.frame(k = 1:6, w = petites_inerties), row.names = FALSE)
verifier_proche(petites_inerties[1:2], c(100, 4))


# 4. LIRE LES COUPES ET LES EX ÆQUO ----------------------------------------

cat("\n4. Couper par hauteur ou par nombre de groupes\n")
coupes_six <- data.frame(
  observation = rownames(petit_x), valeur = petit_x[, 1],
  hauteur_1_3 = cutree(petit_arbre, h = 1.3),
  trois_groupes = cutree(petit_arbre, k = 3),
  hauteur_2_5 = cutree(petit_arbre, h = 2.5)
)
print(coupes_six, row.names = FALSE)
stopifnot(
  meme_partition(coupes_six$hauteur_1_3, c(1, 1, 2, 3, 3, 4)),
  meme_partition(coupes_six$hauteur_2_5, c(1, 1, 1, 2, 2, 2))
)
# Hauteurs exactes et milieux des intervalles : aucun niveau ne donne K = 3.
hauteurs_distinctes <- unique(petit_arbre$height)
hauteurs_test <- sort(c(
  0, hauteurs_distinctes, max(hauteurs_distinctes) + 1,
  (head(hauteurs_distinctes, -1) + tail(hauteurs_distinctes, -1)) / 2
))
nb_groupes_hauteur <- vapply(hauteurs_test, function(h) {
  length(unique(cutree(petit_arbre, h = h)))
}, integer(1))
print(data.frame(h = hauteurs_test, k = nb_groupes_hauteur))
stopifnot(!any(nb_groupes_hauteur == 3L))
# cutree(k = 3) conserve n - 3 fusions, même si deux hauteurs sont égales.

# Tourner un arbre change le dessin, pas les proximités cophénétiques.
dendrogramme <- as.dendrogram(petit_arbre)
dendrogramme_retourne <- rev(dendrogramme)
ordre_noms <- rownames(petit_x)
verifier_proche(
  as.matrix(cophenetic(dendrogramme))[ordre_noms, ordre_noms],
  as.matrix(cophenetic(dendrogramme_retourne))[ordre_noms, ordre_noms]
)
cat("L'axe horizontal n'est pas un axe de distance.\n")


# 5. EFFET DE CHAÎNE ET INVERSIONS -----------------------------------------

cat("\n5. Une chaîne de proximités n'impose pas un petit diamètre\n")
distance_quatre <- as.matrix(dist(quatre_x))
hauteur_chaine <- 2.4
adjacence <- distance_quatre <= hauteur_chaine
print(adjacence)
groupes_chaine <- cutree(arbres_quatre$single, h = hauteur_chaine)
groupes_complets <- cutree(arbres_quatre$complete, h = hauteur_chaine)
stopifnot(
  meme_partition(groupes_chaine, c(1, 1, 1, 2)),
  distance_quatre["A", "C"] > hauteur_chaine
)
diametres_complets <- vapply(
  split(seq_len(nrow(quatre_x)), groupes_complets),
  function(i) max(distance_quatre[i, i, drop = FALSE]), numeric(1)
)
stopifnot(all(diametres_complets <= hauteur_chaine))
print(diametres_complets)

points_inversion <- rbind(
  a = c(-1, 0), b = c(1, 0), c = c(0, 1.8)
)
# Pour reproduire la distance entre centroïdes avec hclust : distances
# euclidiennes AU CARRÉ en entrée, puis racine des hauteurs pour l'affichage.
# Cette convention est distincte de celle de ward.D2 !
arbre_centroides_carre <- hclust(
  dist(points_inversion)^2, method = "centroid"
)
arbre_centroides <- arbre_centroides_carre
arbre_centroides$height <- sqrt(arbre_centroides_carre$height)
verifier_proche(arbre_centroides$height, c(2, 1.8))
print(data.frame(
  etape = 1:2, hauteur_carree = arbre_centroides_carre$height,
  distance_centroides = arbre_centroides$height
))
stopifnot(any(diff(arbre_centroides$height) < 0))
# Une coupe par K reste possible. Une coupe par h est refusée par R.
print(cutree(arbre_centroides, k = 2))
erreur_inversion <- tryCatch(
  cutree(arbre_centroides, h = 1.9), error = function(e) e
)
stopifnot(inherits(erreur_inversion, "error"))
cat("Coupe horizontale refusée :", conditionMessage(erreur_inversion), "\n")


# 6. DISSIMILARITÉS ET CORRÉLATION COPHÉNÉTIQUES ----------------------------

cat("\n6. Proximités initiales et proximités dans le dendrogramme\n")
coph_quatre <- as.matrix(cophenetic(arbres_quatre$single))
print(coph_quatre)
verifier_proche(
  c(coph_quatre["A", "B"], coph_quatre["B", "C"],
    coph_quatre["A", "C"], coph_quatre["A", "D"]),
  c(1, 2.2, 2.2, 2.6)
)
# Vérification exhaustive de l'inégalité ultramétrique sur quatre points.
# Ne pas faire cette triple boucle sur de grands jeux de données.
for (i in seq_len(4L)) {
  for (j in seq_len(4L)) {
    for (ell in seq_len(4L)) {
      stopifnot(coph_quatre[i, ell] <=
                  max(coph_quatre[i, j], coph_quatre[j, ell]) + 1e-12)
    }
  }
}
stopifnot(
  distance_quatre["A", "C"] >
    max(distance_quatre["A", "B"], distance_quatre["B", "C"])
)
# Des doublons peuvent fusionner à hauteur nulle : absence de séparation.
arbre_doublons <- hclust(dist(c(0, 0, 2)), method = "single")
verifier_proche(as.matrix(cophenetic(arbre_doublons))[1, 2], 0)

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
correlations_quatre <- vapply(arbres_quatre, function(arbre) {
  correlation_cophenetique(dist(quatre_x), arbre)
}, numeric(1))
print(correlations_quatre)
cat("Ce diagnostic concerne l'arbre entier : il ne choisit pas K.\n")
# Une corrélation de 1 ne signifie pas l'égalité des distances.
verifier_proche(
  cor(as.numeric(dist(quatre_x)), 10 * as.numeric(dist(quatre_x))), 1
)


# 7. PALMER PENGUINS : PRÉPARATION ET CHOIX D'UNE COUPE ----------------------

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
  if (!length(existants)) {
    stop("Fichier assets/penguins.csv introuvable ; vérifier le dépôt.")
  }
  normalizePath(existants[1], mustWork = TRUE)
}

cat("\n7. Palmer Penguins : quatre variables, sans les espèces\n")
penguins <- read.csv(trouver_penguins())
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
arbre <- hclust(distances, method = "ward.D2")
fusions <- verifier_ward(z, arbre)
inertie_totale <- inertie_groupe(z)
cat("Lignes exclues :", sum(!cas_complets), "; observations :", n, "\n")
cat("Inertie totale :", inertie_totale, "= (n - 1) p\n")
verifier_proche(inertie_totale, (n - 1) * p)
stopifnot(n == 342L, p == 4L)
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
stopifnot(k_retenu == 2L, all(diff(w) <= 0))
verifier_proche(w, cumsum(fusions$gain)[n - k_candidats])
verifier_proche(round(w, 2),
                c(564.05, 391.72, 315.67, 240.92, 220.19, 199.63, 181.36))
verifier_proche(round(silhouettes, 3),
                c(0.532, 0.454, 0.418, 0.363, 0.335, 0.305, 0.259))
# La silhouette utilise distances = dist(z), PAS cophenetic(arbre).
# Elle vaut 0 pour un singleton ; elle n'est pas définie pour K = 1 ou n.

cat("\nDernières fusions :\n")
print(tail(fusions, 4), digits = 6, row.names = FALSE)
verifier_proche(tail(fusions$gain, 1), inertie_totale - w[1])
# Un saut n'est ni une probabilité ni un test de significativité.


# 8. PROFILS ET SENSIBILITÉ À LA LIAISON ------------------------------------

cat("\n8. Interpréter la partition après l'avoir choisie\n")
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
stopifnot(
  meme_partition(groupes_bruts, groupes),
  all(profils$n == c(219, 123)),
  all(unname(table_especes) == rbind(c(151, 68, 0), c(0, 0, 123)))
)
verifier_proche(round(profils$body_mass_g, 2), c(3710.73, 5076.02))

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
verifier_proche(comparaison$n_min, c(1, 123, 123, 123))
verifier_proche(comparaison$n_max, c(341, 219, 219, 219))
# Sur ces données, les trois dernières coupes sont identiques, pas seulement
# leurs effectifs. Ce n'est pas une propriété générale des trois méthodes.
for (liaison in liaisons[-1]) {
  stopifnot(meme_partition(cutree(arbres_penguins[[liaison]], k = 2), groupes))
}


# 9. WARD ET K-MOYENNES : MÊME INERTIE, CONTRAINTES DIFFÉRENTES --------------

cat("\n9. Réaffecter les points peut améliorer une coupe de Ward\n")
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
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
verifier_proche(round(modeles_kmeans[[3]]$tot.withinss, 2), 378.28)
stopifnot(
  meme_partition(modeles_kmeans[[2]]$cluster, groupes),
  kmeans_depuis_ward$tot.withinss <= w[2] + 1e-8
)
# Les groupes fins de Ward sont inclus dans les groupes grossiers.
emboitement <- table(coupe_3 = groupes_ward_trois, coupe_2 = groupes)
print(emboitement)
stopifnot(all(rowSums(emboitement > 0) == 1L))
# Les k-moyennes ne garantissent ni cet emboîtement, ni un minimum global.


# 10. STABILITÉ PAR SOUS-ÉCHANTILLONNAGE ------------------------------------

stabilite_cah <- function(
  x, k, nb_repetitions = 100L, proportion = 0.8,
  graine = 2200L, restandardiser = TRUE, liaison = "ward.D2"
) {
  x <- matrice_numerique(x)
  n <- nrow(x)
  stopifnot(
    length(k) == 1L, k >= 1L, k < n, k == as.integer(k),
    length(nb_repetitions) == 1L, is.finite(nb_repetitions),
    nb_repetitions >= 1L, nb_repetitions == as.integer(nb_repetitions),
    length(proportion) == 1L, proportion > 0, proportion <= 1,
    length(restandardiser) == 1L, !is.na(restandardiser),
    liaison %in% c("single", "complete", "average", "ward.D2")
  )
  taille <- floor(proportion * n)
  stopifnot(taille >= max(2L, k), all(apply(x, 2, sd) > 0))
  z_reference <- scale(x)
  reference <- cutree(hclust(dist(z_reference), method = liaison), k = k)
  nb_presences <- matrix(0L, n, n)
  nb_reunions <- matrix(0L, n, n)
  scores <- data.frame(
    repetition = seq_len(nb_repetitions), ari = numeric(nb_repetitions),
    groupes_reference_presents = integer(nb_repetitions)
  )
  set.seed(graine)
  for (b in seq_len(nb_repetitions)) {
    # Sans remise ; ordre conservé identiquement dans les deux partitions.
    indices <- sort(sample.int(n, size = taille, replace = FALSE))
    if (restandardiser) {
      sous_x <- x[indices, , drop = FALSE]
      if (any(apply(sous_x, 2, sd) == 0)) {
        stop("Variable constante dans un sous-échantillon : revoir l'analyse.")
      }
      sous_z <- scale(sous_x)
    } else {
      # Variante conditionnelle aux échelles estimées sur le tableau complet.
      sous_z <- z_reference[indices, , drop = FALSE]
    }
    sous_arbre <- hclust(dist(sous_z), method = liaison)
    nouveaux_groupes <- cutree(sous_arbre, k = k)
    scores$ari[b] <- rand_ajuste(reference[indices], nouveaux_groupes)
    scores$groupes_reference_presents[b] <- length(unique(reference[indices]))
    nb_presences[indices, indices] <- nb_presences[indices, indices] + 1L
    nb_reunions[indices, indices] <- nb_reunions[indices, indices] +
      outer(nouveaux_groupes, nouveaux_groupes, "==")
  }
  frequences <- matrix(NA_real_, n, n)
  observes <- nb_presences > 0L
  frequences[observes] <- nb_reunions[observes] / nb_presences[observes]
  list(
    scores = scores, frequences = frequences, nb_presences = nb_presences,
    nb_reunions = nb_reunions, reference = reference,
    k = k, proportion = proportion, restandardiser = restandardiser
  )
}

cat("\n10. Stabilité : 80 % sans remise, standardisation réestimée\n")
nb_repetitions <- getOption("cah_repetitions", 100L)
# Même graine : mêmes sous-échantillons pour K = 2 et K = 3.
stabilites <- setNames(lapply(2:3, function(k) {
  stabilite_cah(x, k = k, nb_repetitions = nb_repetitions)
}), c("k_2", "k_3"))
resume_stabilite <- do.call(rbind, lapply(stabilites, function(resultat) {
  scores <- resultat$scores
  data.frame(
    k = resultat$k, repetitions = nrow(scores),
    minimum_ari = min(scores$ari), mediane_ari = median(scores$ari),
    moyenne_ari = mean(scores$ari),
    q10_ari = unname(quantile(scores$ari, 0.1)),
    q90_ari = unname(quantile(scores$ari, 0.9)),
    groupes_absents = sum(scores$groupes_reference_presents < resultat$k)
  )
}))
print(resume_stabilite, digits = 5, row.names = FALSE)
# Le dénominateur est le nombre de présences communes, pas B.
for (resultat in stabilites) {
  observes <- resultat$nb_presences > 0
  stopifnot(
    all(resultat$nb_reunions <= resultat$nb_presences),
    all(resultat$frequences[observes] >= 0),
    all(resultat$frequences[observes] <= 1),
    isSymmetric(resultat$frequences),
    all(resultat$scores$ari >= -1 & resultat$scores$ari <= 1 + 1e-12)
  )
}
observes_3 <- stabilites$k_3$nb_presences > 0 &
  lower.tri(stabilites$k_3$nb_presences)
cat("Nombre de présences communes par paire, K = 3 :\n")
print(summary(stabilites$k_3$nb_presences[observes_3]))
# Ces fréquences ne sont pas des probabilités d'une « vraie » classe.
# Une stabilité élevée dépend du protocole ; elle ne prouve pas l'existence
# de groupes naturels. Une partition en un seul groupe est toujours stable.


# 11. GÉOMÉTRIE ET LIMITES -------------------------------------------------

cat("\n11. Modifier les unités modifie une distance non standardisée\n")
x_kg <- x
x_kg[, "body_mass_g"] <- x_kg[, "body_mass_g"] / 1000
distance_brute <- dist(x)
distance_kg <- dist(x_kg)
verifier_proche(as.numeric(dist(scale(x_kg))), as.numeric(distances))
stopifnot(max(abs(as.numeric(distance_brute) -
                    as.numeric(distance_kg))) > 1)
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
paires_1 <- as.numeric(dist(z[, 1, drop = FALSE]))^2
verifier_proche(
  as.numeric(dist(cbind(z, z[, 1])))^2,
  as.numeric(dist(z))^2 + paires_1
)

tailles <- c(100L, 1000L, 10000L)
memoire <- data.frame(
  n = tailles, nb_distances = tailles * (tailles - 1) / 2,
  mo = 8 * tailles * (tailles - 1) / 2 / 1e6
)
print(memoire, row.names = FALSE)
# Mo = 10^6 octets, pas Mio = 2^20 octets. Aucun gros tableau n'est alloué.
# Nos matrices de stabilité coûtent elles aussi une mémoire d'ordre n^2.

# Contre-exemple calculé : une règle au centroïde n'est pas une nouvelle CAH.
anciens <- matrix(c(0, 4, 10), ncol = 1)
ancien_arbre <- hclust(dist(anciens), method = "single")
anciens_groupes <- cutree(ancien_arbre, k = 2)
nouveau <- 6.5
anciens_centres <- tapply(anciens[, 1], anciens_groupes, mean)
groupe_par_centre <- which.min(abs(anciens_centres - nouveau))
arbre_augmente <- hclust(dist(rbind(anciens, nouveau)), method = "single")
groupes_augmente <- cutree(arbre_augmente, k = 2)
cat("Nouveau point :", nouveau, "; ancien groupe par centroïde :",
    groupe_par_centre, "\n")
print(data.frame(
  x = c(anciens[, 1], nouveau),
  regle_centroides = c(anciens_groupes, groupe_par_centre),
  cah_reconstruite = groupes_augmente
))
stopifnot(!meme_partition(
  c(anciens_groupes, groupe_par_centre), groupes_augmente
))
# Ajouter un point et reconstruire peut aussi modifier les anciens groupes.
# Une CAH produit toujours un arbre, même sans groupes nettement séparés.


# 12. GRAPHIQUES POUR LA DÉMONSTRATION EN CLASSE ----------------------------

dessiner_cours_cah <- function() {
  anciens_parametres <- par(no.readonly = TRUE)
  on.exit(par(anciens_parametres), add = TRUE)
  couleurs <- c("#007C78", "#D57535", "#5D6CB0")
  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4, 1), cex.main = 1.05)
  nuages <- rbind(nuage_a, nuage_b)
  couleurs_nuages <- couleurs[c(rep(1, 3), rep(2, 4))]
  distances_ab <- as.matrix(dist(nuages))[1:3, 4:7]

  # A. Moyenne des distances et distance entre les moyennes.
  plot(nuages, pch = 19, col = couleurs_nuages, asp = 1,
       xlim = c(0, 6), ylim = c(0, 3.3), xlab = "x1", ylab = "x2",
       main = "Douze distances entre les groupes")
  for (i in seq_len(nrow(nuage_a))) {
    for (j in seq_len(nrow(nuage_b))) {
      segments(nuage_a[i, 1], nuage_a[i, 2],
               nuage_b[j, 1], nuage_b[j, 2], col = "grey75")
    }
  }
  paire_min <- which(distances_ab == min(distances_ab), arr.ind = TRUE)[1, ]
  paire_max <- which(distances_ab == max(distances_ab), arr.ind = TRUE)[1, ]
  for (paire in list(paire_min, paire_max)) {
    segments(nuage_a[paire[1], 1], nuage_a[paire[1], 2],
             nuage_b[paire[2], 1], nuage_b[paire[2], 2], lwd = 2)
  }
  points(nuages, pch = 19, col = couleurs_nuages)
  mtext("Simple : 1,55 ; complète : 4,97 ; moyenne : 3,61",
        side = 3, line = 0.2, cex = 0.75)
  plot(nuages, pch = 19, col = couleurs_nuages, asp = 1,
       xlim = c(0, 6), ylim = c(0, 3.3), xlab = "x1", ylab = "x2",
       main = "Deux centroïdes")
  centre_a <- colMeans(nuage_a)
  centre_b <- colMeans(nuage_b)
  segments(centre_a[1], centre_a[2], centre_b[1], centre_b[2], lwd = 2)
  points(rbind(centre_a, centre_b), pch = 8, cex = 2, col = couleurs[1:2])
  mtext("Distance entre les moyennes : 3,40", side = 3, line = 0.2, cex = 0.8)

  # B. Ward : segments vers le centroïde avant et après la fusion.
  for (fusion in c(FALSE, TRUE)) {
    titre <- if (fusion) "Après fusion : W = 28,58" else "Avant : W = 8,76"
    plot(nuages, pch = 19, col = couleurs_nuages, asp = 1,
         xlim = c(0, 6), ylim = c(0, 3.3), xlab = "x1", ylab = "x2",
         main = titre)
    centres <- if (fusion) {
      matrix(colMeans(nuages), nrow = 7, ncol = 2, byrow = TRUE)
    } else {
      rbind(centre_a, centre_a, centre_a,
            centre_b, centre_b, centre_b, centre_b)
    }
    segments(nuages[, 1], nuages[, 2], centres[, 1], centres[, 2],
             col = couleurs_nuages)
    points(unique(centres), pch = 8, cex = 2)
    mtext("Inertie = somme des carrés des longueurs", side = 3,
          line = 0.2, cex = 0.8)
  }

  # C. Même arbre, deux hauteurs de coupe.
  plot(petit_arbre, hang = -1, main = "Six points : Ward",
       xlab = "", sub = "", ylab = "Hauteur = racine(2 Delta W)")
  abline(h = 2.5, col = couleurs[2], lty = 2)
  rect.hclust(petit_arbre, k = 2, border = couleurs[1:2])
  # plot.hclust ne règle pas la fenêtre avec ylim ; utiliser le dendrogramme.
  plot(as.dendrogram(petit_arbre), ylim = c(0, 2.1),
       main = "Zoom : quatre groupes", xlab = "", ylab = "Hauteur")
  abline(h = 1.3, col = couleurs[2], lty = 2)

  # D. Une même distance initiale, trois hiérarchies.
  par(mfrow = c(1, 3), mar = c(4.5, 4.5, 4.5, 1), cex = 0.9)
  for (methode in names(arbres_quatre)) {
    modele <- arbres_quatre[[methode]]
    plot(as.dendrogram(modele), ylim = c(0, 6.2), main = methode,
         xlab = "", ylab = "Hauteur")
    groupes_modele <- cutree(modele, k = 2)
    ordre_couleurs <- unique(groupes_modele[modele$order])
    rect.hclust(modele, k = 2, border = couleurs[ordre_couleurs])
  }

  # E. La fusion suivante peut être plus basse avec les centroïdes.
  par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4, 1))
  plot(points_inversion, pch = 19, asp = 1, col = couleurs[1],
       xlim = c(-1.5, 1.5), ylim = c(-0.4, 2.4),
       xlab = "x1", ylab = "x2", main = "Une inversion")
  text(points_inversion, labels = c("A", "B", "C"), pos = 3)
  points(0, 0, pch = 8, cex = 2, col = couleurs[2])
  segments(-1, 0, 1, 0, lty = 2)
  segments(0, 0, 0, 1.8, col = couleurs[2])
  plot(as.dendrogram(arbre_centroides), ylim = c(0, 2.2),
       main = "Hauteurs : 2 puis 1,8", xlab = "",
       ylab = "Distance entre centroïdes")

  # F. Les distances du dendrogramme ne sont pas les distances initiales.
  par(mfrow = c(1, 1))
  paires <- which(lower.tri(distance_quatre), arr.ind = TRUE)
  noms_paires <- paste(
    rownames(distance_quatre)[paires[, 1]],
    colnames(distance_quatre)[paires[, 2]], sep = "-"
  )
  plot(distance_quatre[paires], coph_quatre[paires],
       xlim = c(0, 6.3), ylim = c(0, 6.3), pch = 19, col = couleurs[1],
       xlab = "Distance initiale", ylab = "Dissimilarité cophénétique",
       main = "Quatre points : liaison simple")
  text(distance_quatre[paires], coph_quatre[paires],
       labels = noms_paires, pos = 3, cex = 0.85)
  abline(0, 1, lty = 2, col = "grey50")

  # G. Une seule hiérarchie, plusieurs coupes candidates.
  par(mfrow = c(1, 2))
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

  # H. Silhouettes individuelles : la moyenne ne résume pas tout.
  par(mfrow = c(1, 1), mar = c(6, 4.5, 4, 8))
  plot(cluster::silhouette(groupes, distances),
       col = couleurs[1:2], border = NA, nmax.lab = 0,
       xlab = "Silhouette s(i)",
       sub = paste("Silhouette moyenne :", round(max(silhouettes), 3)),
       main = "Palmer Penguins : coupe en deux groupes")

  # I. Les profils restent lisibles dans leurs unités d'origine.
  par(mfrow = c(2, 2), mar = c(5, 5, 3.5, 1))
  titres <- c("Longueur du bec (mm)", "Profondeur du bec (mm)",
              "Longueur de la nageoire (mm)", "Masse (g)")
  for (j in seq_along(variables)) {
    boxplot(x[, j] ~ groupes, col = couleurs[1:2],
            xlab = "Groupe de Ward", ylab = titres[j], main = titres[j])
  }

  # J. La comparaison porte sur la même géométrie et le même K.
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

  # K. K = 2 et K = 3 : mêmes sous-échantillons, pas même stabilité.
  scores_ari <- lapply(stabilites, function(resultat) resultat$scores$ari)
  boxplot(scores_ari, names = c("K = 2", "K = 3"), col = couleurs[1:2],
          ylim = c(min(unlist(scores_ari)) - 0.05, 1.05),
          ylab = "Indice de Rand ajusté",
          main = "Stabilité après retrait de 20 % des observations")
  mtext(paste(nb_repetitions, "répétitions ; standardisation réestimée"),
        side = 3, line = 0.3, cex = 0.8)

  # L. Carte des regroupements, ordonnée par l'arbre de référence.
  # Une valeur NA (paire jamais observée) reste vide, et non égale à zéro.
  layout(matrix(1:2, nrow = 1), widths = c(5, 1))
  par(mar = c(4, 4, 4, 1), pty = "s")
  ordre <- arbre$order
  palette_cah <- colorRampPalette(c("#FFFFFF", "#A5D8D4", "#007C78"))(100)
  image(seq_len(n), seq_len(n), stabilites$k_3$frequences[ordre, ordre],
        col = palette_cah, zlim = c(0, 1), asp = 1, xaxs = "i", yaxs = "i",
        xlab = "Observations, ordre du dendrogramme",
        ylab = "Même ordre", main = "Fréquences de regroupement : K = 3")
  limites <- head(cumsum(rle(groupes_ward_trois[ordre])$lengths), -1) + 0.5
  abline(v = limites, h = limites, lty = 2, col = couleurs[2])
  par(mar = c(4, 1, 4, 4), pty = "m")
  niveaux <- seq(0, 1, length.out = 100)
  image(1, niveaux, matrix(niveaux, nrow = 1), col = palette_cah,
        zlim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
  axis(4, at = seq(0, 1, by = 0.25), las = 1)
  mtext("Fréquence", side = 4, line = 2.8)
  layout(1)
  invisible(NULL)
}

if (isTRUE(getOption("cah_afficher_graphiques", interactive()))) {
  dessiner_cours_cah()
}


# 13. QUESTIONS À POSER EN CLASSE — CORRIGÉS EXÉCUTABLES ---------------------

# Question 1 : deux groupes de taille 2, distants de 3 par leurs centroïdes.
# Leur coût de Ward vaut-il 3 ? Non : Delta W = 9 et h = racine(18).
verifier_proche(cout_ward(a, b), 9)
verifier_proche(liaison_groupes(a, b, "ward.D2"), sqrt(18))

# Question 2 : peut-on obtenir trois groupes en coupant l'arbre des six points
# par une hauteur ? Non : les fusions aux hauteurs 1 et racine(3) sont doubles.
stopifnot(length(unique(cutree(petit_arbre, k = 3))) == 3L)
stopifnot(!any(nb_groupes_hauteur == 3L))

# Question 3 : changer les numéros des groupes change-t-il l'ARI ? Non.
verifier_proche(rand_ajuste(c(1, 1, 2, 2), c(8, 8, 4, 4)), 1)
verifier_proche(rand_ajuste(c(1, 1, 2, 2), c(1, 2, 1, 2)), -0.5)
# Cas dégénérés : accord parfait en un groupe ou en singletons, sinon 0.
verifier_proche(rand_ajuste(rep(1, 4), rep(2, 4)), 1)
verifier_proche(rand_ajuste(1:4, 4:1), 1)
verifier_proche(rand_ajuste(rep(1, 4), 1:4), 0)

# Question 4 : sept réunions sur dix répétitions donnent-elles 0,7 ?
# Non si la paire n'apparaît ensemble que huit fois : 7/8 = 0,875.
frequence_paire <- function(g_i, g_j) {
  stopifnot(length(g_i) == length(g_j))
  presents <- !is.na(g_i) & !is.na(g_j)
  if (!any(presents)) return(NA_real_)
  mean(g_i[presents] == g_j[presents])
}
fictif_i <- rep(1, 10)
fictif_j <- c(rep(1, 7), 2, NA, NA)
fictif_ell <- c(rep(1, 3), rep(2, 3), rep(NA, 4))
verifier_proche(frequence_paire(fictif_i, fictif_j), 0.875)
verifier_proche(frequence_paire(fictif_i, fictif_ell), 0.5)
stopifnot(is.na(frequence_paire(c(1, NA), c(NA, 2))))

# Question 5 : K = 1 est-il une solution particulièrement stable ? Oui,
# de façon triviale ; cela ne suffit pas à justifier une partition utile.
stabilite_triviale <- stabilite_cah(matrix(1:10), k = 1, nb_repetitions = 3)
verifier_proche(stabilite_triviale$scores$ari, rep(1, 3))
verifier_proche(inertie_groupe(matrix(8)), 0)
stopifnot(
  is.na(silhouette_moyenne(rep(1, 6), dist(petit_x))),
  is.na(silhouette_moyenne(1:6, dist(petit_x)))
)

# Question 6 : l'inertie minimale sélectionne-t-elle K ? Non : K = n
# donne W = 0 ; la silhouette, les profils et l'usage doivent intervenir.
verifier_proche(inertie_partition(petit_x, 1:6), 0)

# Question 7 : une corrélation cophénétique élevée garantit-elle une coupe ?
# Non : elle ne dépend même pas de K. Les coupes de K = 2 à 8 ci-dessus
# partagent le même arbre, donc la même corrélation cophénétique.

cat("\nTous les calculs de contrôle du cours sont vérifiés.\n")
cat("Version de R :", as.character(getRversion()),
    "; cluster :", as.character(utils::packageVersion("cluster")), "\n")


# 14. EXPORT FACULTATIF POUR LES FIGURES PYTHON -----------------------------

exporter_tableaux_cah <- function(sortie) {
  stopifnot(is.character(sortie), length(sortie) == 1L, nzchar(sortie))
  if (!dir.exists(sortie)) {
    dir.create(sortie, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(sortie)) stop("Impossible de créer le dossier d'export.")
  ecrire <- function(objet, nom) {
    write.csv(objet, file.path(sortie, nom), row.names = FALSE)
  }
  # Conserver l'interface historique avec le générateur Python.
  criteres_export <- criteres
  names(criteres_export) <- c("K", "W", "R2", "silhouette")
  ecrire(petites_fusions, "exemple_fusions.csv")
  ecrire(data.frame(nom = rownames(petit_x), x = petit_x[, 1]),
         "exemple_points.csv")
  ecrire(fusions, "penguins_fusions.csv")
  ecrire(data.frame(groupe = groupes), "penguins_groupes.csv")
  ecrire(criteres_export, "criteres.csv")
  invisible(sortie)
}

# Ne pas interpréter les arguments du programme appelant lors de source().
if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  if (length(arguments) > 1L) {
    stop("Usage : Rscript codes/classification_hierarchique.R [dossier_export]")
  }
  if (length(arguments) == 1L) exporter_tableaux_cah(arguments[1])
}

# Documentation officielle des conventions logicielles utilisées :
# https://stat.ethz.ch/R-manual/R-devel/library/stats/html/hclust.html
# https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cutree.html
# https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cophenetic.html
# https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/silhouette.html
