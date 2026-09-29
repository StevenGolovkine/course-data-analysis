# Analyse factorielle des correspondances (AFC) — STT-2200
# Sources : lectures/dimension_reduction.typ, section AFC, et
# Support des diapositives : slides/analyse_factorielle_correspondances.typ.
#
# Depuis la racine du dépôt :
# Dans R : source("codes/analyse_factorielle_correspondances.R")
#   Rscript codes/analyse_factorielle_correspondances.R
# Le script fonctionne aussi depuis codes/ et ne télécharge aucune donnée.
# R de base suffit. FactoMineR, si installé, sert de contre-vérification.
#
# Dans RStudio, les graphiques apparaissent à la fin dans l'onglet Plots.
# En mode Rscript, seuls les résultats numériques sont affichés.
#
# Correspondance avec les notations du cours :
# N = effectifs, P = frequences, r/c = masses_lignes/masses_colonnes,
# S = residus_standardises, sigma = valeurs_singulieres,
# lambda = valeurs_propres, F/G = coord_lignes/coord_colonnes,
# Coordonnées standard : Phi/Gamma = standard_lignes/standard_colonnes.


# 0. FONCTIONS DE CALCUL ----------------------------------------------------

calculer_afc <- function(effectifs, tolerance = 1e-12) {
  effectifs <- as.matrix(effectifs)
  if (!is.numeric(effectifs) || any(!is.finite(effectifs)) ||
        any(effectifs < 0) || any(dim(effectifs) < 2L)) {
    stop("Fournir un tableau numérique fini, non négatif, au moins 2 x 2.")
  }
  stopifnot(length(tolerance) == 1L, is.finite(tolerance), tolerance > 0)
  totaux_lignes <- rowSums(effectifs)
  totaux_colonnes <- colSums(effectifs)
  if (any(totaux_lignes == 0) || any(totaux_colonnes == 0)) {
    stop("Retirer les lignes ou colonnes de marge nulle avant l'AFC.")
  }
  if (is.null(rownames(effectifs))) {
    rownames(effectifs) <- paste0("ligne_", seq_len(nrow(effectifs)))
  }
  if (is.null(colnames(effectifs))) {
    colnames(effectifs) <- paste0("colonne_", seq_len(ncol(effectifs)))
  }

  n <- sum(effectifs)
  frequences <- effectifs / n
  masses_lignes <- rowSums(frequences)
  masses_colonnes <- colSums(frequences)
  profils_lignes <- sweep(frequences, 1, masses_lignes, "/")
  # Les profils-colonnes restent rangés en colonnes : chacune somme à 1.
  profils_colonnes <- sweep(frequences, 2, masses_colonnes, "/")
  independance <- outer(masses_lignes, masses_colonnes)
  attendus <- n * independance
  residus_standardises <- (frequences - independance) / sqrt(independance)
  inertie_totale <- sum(residus_standardises^2)
  chi_deux <- sum((effectifs - attendus)^2 / attendus)

  # S = U D V^t. Les valeurs singulières numériquement nulles sont exclues.
  decomposition <- svd(residus_standardises)
  axes <- which(decomposition$d > tolerance)
  valeurs_singulieres <- decomposition$d[axes]
  valeurs_propres <- valeurs_singulieres^2
  vecteurs_lignes <- decomposition$u[, axes, drop = FALSE]
  vecteurs_colonnes <- decomposition$v[, axes, drop = FALSE]
  # Même orientation que les figures du chapitre : plus grand |U_ik| positif.
  # Le signe est arbitraire, mais doit changer dans les deux nuages ensemble.
  for (k in seq_along(axes)) {
    ancre <- which.max(abs(vecteurs_lignes[, k]))
    signe <- sign(vecteurs_lignes[ancre, k])
    vecteurs_lignes[, k] <- signe * vecteurs_lignes[, k]
    vecteurs_colonnes[, k] <- signe * vecteurs_colonnes[, k]
  }
  standard_lignes <- sweep(vecteurs_lignes, 1, sqrt(masses_lignes), "/")
  standard_colonnes <- sweep(
    vecteurs_colonnes, 1, sqrt(masses_colonnes), "/"
  )
  noms_axes <- if (length(axes)) {
    paste0("axe_", seq_along(axes))
  } else {
    character()
  }
  dimnames(standard_lignes) <- list(rownames(effectifs), noms_axes)
  dimnames(standard_colonnes) <- list(colnames(effectifs), noms_axes)
  coord_lignes <- sweep(standard_lignes, 2, valeurs_singulieres, "*")
  coord_colonnes <- sweep(standard_colonnes, 2, valeurs_singulieres, "*")

  # Distances au carré au profil moyen, calculées avant toute projection.
  ecarts_lignes <- sweep(profils_lignes, 2, masses_colonnes, "-")
  ecarts_colonnes <- sweep(profils_colonnes, 1, masses_lignes, "-")
  distance2_lignes <- rowSums(
    sweep(ecarts_lignes^2, 2, masses_colonnes, "/")
  )
  distance2_colonnes <- colSums(
    sweep(ecarts_colonnes^2, 1, masses_lignes, "/")
  )
  # ctr_ik = r_i F_ik^2 / lambda_k = r_i Phi_ik^2.
  contributions_lignes <- sweep(standard_lignes^2, 1, masses_lignes, "*")
  contributions_colonnes <- sweep(
    standard_colonnes^2, 1, masses_colonnes, "*"
  )
  qualite <- function(coordonnees, distance2) {
    resultat <- matrix(
      NA_real_, nrow(coordonnees), ncol(coordonnees),
      dimnames = dimnames(coordonnees)
    )
    hors_centre <- distance2 > tolerance^2
    resultat[hors_centre, ] <- sweep(
      coordonnees[hors_centre, , drop = FALSE]^2,
      1, distance2[hors_centre], "/"
    )
    # Au centre, cos² = 0/0 : conserver NA, plutôt que simuler une qualité.
    resultat
  }

  list(
    effectifs = effectifs, n = n, frequences = frequences,
    masses_lignes = masses_lignes, masses_colonnes = masses_colonnes,
    profils_lignes = profils_lignes, profils_colonnes = profils_colonnes,
    independance = independance, attendus = attendus,
    residus_standardises = residus_standardises,
    inertie_totale = inertie_totale, chi_deux = chi_deux,
    rang = length(axes), valeurs_singulieres = valeurs_singulieres,
    valeurs_propres = valeurs_propres,
    coord_lignes = coord_lignes, coord_colonnes = coord_colonnes,
    standard_lignes = standard_lignes, standard_colonnes = standard_colonnes,
    distance2_lignes = distance2_lignes,
    distance2_colonnes = distance2_colonnes,
    contributions_lignes = contributions_lignes,
    contributions_colonnes = contributions_colonnes,
    cos2_lignes = qualite(coord_lignes, distance2_lignes),
    cos2_colonnes = qualite(coord_colonnes, distance2_colonnes)
  )
}

choisir_axes_afc <- function(afc, seuil = 0.80) {
  stopifnot(length(seuil) == 1L, is.finite(seuil), seuil > 0, seuil <= 1)
  if (afc$rang == 0L) return(0L)
  cumul <- cumsum(afc$valeurs_propres) / sum(afc$valeurs_propres)
  which(cumul >= seuil - 10 * .Machine$double.eps)[1]
}

projeter_profils_afc <- function(afc, profils) {
  if (is.null(dim(profils))) profils <- rbind(supplementaire = profils)
  profils <- as.matrix(profils)
  categories <- colnames(afc$effectifs)
  if (!is.numeric(profils) || any(!is.finite(profils)) || any(profils < 0)) {
    stop("Les profils doivent être numériques, finis et non négatifs.")
  }
  if (is.null(colnames(profils)) || anyDuplicated(colnames(profils)) ||
        !setequal(colnames(profils), categories)) {
    stop("Nommer les colonnes avec exactement les catégories du tableau.")
  }
  if (any(abs(rowSums(profils) - 1) > 1e-10)) {
    stop("Chaque profil supplémentaire doit sommer à 1.")
  }
  # Aligner par noms, même si l'utilisateur a fourni un ordre différent.
  profils[, categories, drop = FALSE] %*% afc$standard_colonnes
}

proches <- function(x, y, tolerance = 1e-9) {
  identical(dim(x), dim(y)) && length(x) == length(y) &&
    all(abs(x - y) < tolerance)
}


# 1. TABLEAU DE CONTINGENCE ET PROFILS -------------------------------------

effectifs <- matrix(
  c(60, 25, 15, 10, 35, 15, 10, 10, 20), nrow = 3, byrow = TRUE,
  dimnames = list(
    programme = c("Sciences", "Lettres", "Gestion"),
    admission = c("Directe", "Passerelle", "Reprise d'études")
  )
)
afc <- calculer_afc(effectifs)
cat("\n1. Exemple fictif : programme et type d'admission\n")
print(addmargins(effectifs))
cat("Profils-lignes (%) : répartition des admissions dans un programme\n")
print(round(100 * afc$profils_lignes, 2))
cat("Profils-colonnes (%) : programmes pour un type d'admission\n")
print(round(100 * afc$profils_colonnes, 2))
cat("Masses des programmes, puis des admissions :\n")
print(afc$masses_lignes)
print(afc$masses_colonnes)

# Les centres sont des moyennes pondérées, pas des moyennes simples.
profil_moyen_lignes <- drop(
  afc$masses_lignes %*% afc$profils_lignes
)
profil_moyen_colonnes <- drop(
  afc$profils_colonnes %*% afc$masses_colonnes
)


# 2. INDÉPENDANCE ET ASSOCIATIONS ------------------------------------------

cat("\n2. Effectifs attendus sous l'indépendance\n")
print(afc$attendus)
rapports <- effectifs / afc$attendus
cat("Rapports observé / attendu : > 1 surreprésenté, < 1 sous-représenté\n")
print(round(rapports, 3))
# Sciences / Directe : 60 / 40 = 1,5.
# Sciences / Reprise d'études : 15 / 25 = 0,6.
# Gestion / Reprise d'études : 20 / 10 = 2.
# Une association se mesure par rapport aux marges, pas par un effectif seul.


# 3. DISTANCE DU CHI-DEUX ET INERTIE ----------------------------------------

# dist() est euclidienne : diviser d'abord chaque composante du profil par
# la racine de sa masse permet d'obtenir la distance du chi-deux.
distance2_lignes <- as.matrix(dist(sweep(
  afc$profils_lignes, 2, sqrt(afc$masses_colonnes), "/"
)))^2
distance2_colonnes <- as.matrix(dist(t(sweep(
  afc$profils_colonnes, 1, sqrt(afc$masses_lignes), "/"
))))^2
cat("\n3. Distances du chi-deux au carré entre programmes\n")
print(round(distance2_lignes, 5))
cat("Même écart de proportion, poids différents :\n")
print(c(directe = 0.10^2 / 0.40, reprise = 0.10^2 / 0.25))

inertie_lignes <- sum(afc$masses_lignes * afc$distance2_lignes)
inertie_colonnes <- sum(afc$masses_colonnes * afc$distance2_colonnes)
print(c(
  chi_deux = afc$chi_deux, chi_deux_sur_n = afc$chi_deux / afc$n,
  inertie_lignes = inertie_lignes, inertie_colonnes = inertie_colonnes
))

# Les deux nuages décrivent la même inertie. Ne pas les additionner.
# L'AFC est descriptive : aucune valeur p n'est interprétée ici.


# 4. MATRICE STANDARDISÉE ET CHOIX DES AXES ---------------------------------

cat("\n4. Matrice S des écarts standardisés à l'indépendance\n")
print(round(afc$residus_standardises, 5))
inerties <- data.frame(
  axe = seq_len(afc$rang), valeur_propre = afc$valeurs_propres,
  pourcentage = 100 * afc$valeurs_propres / afc$inertie_totale,
  cumul = 100 * cumsum(afc$valeurs_propres) / afc$inertie_totale
)
print(inerties, row.names = FALSE, digits = 6)
q_80 <- choisir_axes_afc(afc, seuil = 0.80)
cat("Nombre d'axes pour au moins 80 % de l'inertie :", q_80, "\n")

# Un tableau 3 x 3 possède au plus deux axes non triviaux.
# Le plan restitue ici 100 % de l'inertie, pas une association parfaite.
# La règle de Kaiser (valeur propre > 1) de l'ACP normée ne s'applique pas.
# Ne pas appeler scale(effectifs) avant l'AFC : les masses font la pondération.


# 5. COORDONNÉES ET GÉOMÉTRIE ----------------------------------------------

cat("\n5. Coordonnées principales F (programmes) et G (admissions)\n")
print(round(afc$coord_lignes, 5))
print(round(afc$coord_colonnes, 5))
cat("Coordonnées standard Gamma des admissions :\n")
print(round(afc$standard_colonnes, 5))
stopifnot(
  proches(as.matrix(dist(afc$coord_lignes))^2, distance2_lignes),
  proches(as.matrix(dist(afc$coord_colonnes))^2, distance2_colonnes),
  proches(
    crossprod(afc$coord_lignes, afc$masses_lignes * afc$coord_lignes),
    diag(afc$valeurs_propres)
  ),
  proches(
    crossprod(afc$coord_colonnes, afc$masses_colonnes * afc$coord_colonnes),
    diag(afc$valeurs_propres)
  )
)

# Les transitions sont des barycentres entre coordonnées principales d'un
# nuage et coordonnées standard de l'autre, pas entre F et G directement.
barycentres_lignes <- afc$profils_lignes %*% afc$standard_colonnes
barycentres_colonnes <- t(afc$profils_colonnes) %*% afc$standard_lignes

cat("Barycentre de Sciences sur l'axe 1 :\n")
print(sum(
  afc$profils_lignes["Sciences", ] * afc$standard_colonnes[, 1]
))

# Avec tous les axes, somme_k F_ik G_jk / sigma_k = p_ij / (r_i c_j) - 1.
association_reconstruite <- tcrossprod(
  afc$coord_lignes, afc$standard_colonnes
)
# La distance entre un programme et une admission ne mesure pas leur
# association, même sur ce plan complet. Revenir aux rapports observé/attendu.


# 6. CONTRIBUTIONS ET COSINUS CARRÉS ---------------------------------------

diagnostics_lignes <- data.frame(
  programme = rownames(effectifs), masse = afc$masses_lignes,
  contribution_axe_1 = 100 * afc$contributions_lignes[, 1],
  contribution_axe_2 = 100 * afc$contributions_lignes[, 2],
  qualite_axe_1 = 100 * afc$cos2_lignes[, 1],
  qualite_axe_2 = 100 * afc$cos2_lignes[, 2],
  qualite_plan = 100 * rowSums(afc$cos2_lignes), row.names = NULL
)
cat("\n6. Diagnostics des programmes (contributions et qualités en %)\n")
print(diagnostics_lignes, digits = 4, row.names = FALSE)
cat("Contributions des admissions (%) :\n")
print(round(100 * afc$contributions_colonnes, 1))
cat("Qualités des admissions (%) :\n")
print(round(100 * afc$cos2_colonnes, 1))
# Contribution : qui construit l'axe ? Qualité : que voit-on de ce point ?
# Les contributions somment à 100 % par axe, séparément pour chaque nuage.
# Les cos² somment à 100 % par modalité quand on conserve tous les axes.
# Bien que l'axe 1 porte 71,29 % de l'inertie, il ne restitue que 30,3 % de
# la distance au carré de Gestion à son profil moyen.


# 7. PROFILS SUPPLÉMENTAIRES -----------------------------------------------

profils_supplementaires <- rbind(
  Moyen = c(0.40, 0.35, 0.25), Nouveau = c(0.20, 0.20, 0.60)
)
colnames(profils_supplementaires) <- colnames(effectifs)
coord_supplementaires <- projeter_profils_afc(afc, profils_supplementaires)
cat("\n7. Projections supplémentaires, sans recalculer les axes\n")
print(round(coord_supplementaires, 5))
# Le profil moyen se projette à l'origine. Nouveau est riche en reprises.
# Ces programmes ne participent ni aux axes ni à l'inertie active.
# Pour les rendre actifs, il faudrait ajouter leurs effectifs et refaire l'AFC.





# 9. COMPARAISON FACULTATIVE AVEC FACTOMINER --------------------------------

afc_logiciel <- FactoMineR::CA(effectifs, ncp = afc$rang, graph = FALSE)


# 10. GRAPHIQUES POUR LE COURS ---------------------------------------------

tracer_profils_afc <- function(afc) {
  ancien_par <- par(mar = c(4, 7, 4, 1))
  on.exit(par(ancien_par))
  profils <- rbind(afc$profils_lignes, Ensemble = afc$masses_colonnes)
  profils <- profils[rev(seq_len(nrow(profils))), , drop = FALSE]
  couleurs <- c("#486976", "#347663", "#b77244")
  milieux <- barplot(
    t(100 * profils), horiz = TRUE, las = 1, xlim = c(0, 100),
    col = couleurs, border = NA, xlab = "Part du groupe (%)",
    main = "Profils-lignes et profil moyen"
  )
  for (i in seq_len(nrow(profils))) {
    positions <- 100 * (cumsum(profils[i, ]) - profils[i, ] / 2)
    text(
      positions, rep(milieux[i], ncol(profils)),
      labels = sprintf("%.1f %%", 100 * profils[i, ]), col = "white", cex = 0.9
    )
  }
  legend(
    "top", legend = colnames(profils), fill = couleurs, horiz = TRUE,
    inset = c(0, -0.025), xpd = NA, bty = "n", cex = 0.9
  )
}

tracer_inertie_afc <- function(afc) {
  if (afc$rang == 0L) stop("Aucune inertie à représenter.")
  ancien_par <- par(mfrow = c(1, 2), mar = c(4, 4, 4, 1))
  on.exit(par(ancien_par))
  axes <- seq_len(afc$rang)
  plot(
    axes, afc$valeurs_propres, type = "b", pch = 19, col = "#00897b",
    xaxt = "n", xlab = "Axe", ylab = "Valeur propre", main = "Éboulis"
  )
  axis(1, at = axes)
  plot(
    axes, 100 * cumsum(afc$valeurs_propres) / afc$inertie_totale,
    type = "b", pch = 19, col = "#00897b", xaxt = "n", ylim = c(0, 100),
    xlab = "Nombre d'axes", ylab = "Inertie cumulée (%)",
    main = "Inertie conservée"
  )
  axis(1, at = axes)
  abline(h = 80, lty = 2, col = "#d95f02")
}

tracer_plan_afc <- function(afc, asymetrique = FALSE, profils_sup = NULL) {
  if (afc$rang < 2L) stop("Il faut au moins deux axes pour tracer un plan.")
  ancien_par <- par(mar = c(5, 4, 4, 1))
  on.exit(par(ancien_par))
  lignes <- afc$coord_lignes[, 1:2, drop = FALSE]
  colonnes <- if (asymetrique) afc$standard_colonnes else afc$coord_colonnes
  colonnes <- colonnes[, 1:2, drop = FALSE]
  supplement <- if (is.null(profils_sup)) {
    NULL
  } else {
    projeter_profils_afc(afc, profils_sup)[, 1:2, drop = FALSE]
  }
  ensemble <- rbind(lignes, colonnes, supplement)
  marge <- 0.4 * max(apply(ensemble, 2, function(x) diff(range(x))))
  parts <- 100 * afc$valeurs_propres / afc$inertie_totale
  titre <- if (asymetrique) {
    "Plan asymétrique : F et Gamma"
  } else {
    "Plan symétrique : F et G"
  }
  plot(
    ensemble, type = "n", asp = 1,
    xlim = range(ensemble[, 1]) + c(-marge, marge),
    ylim = range(ensemble[, 2]) + c(-marge, marge),
    xlab = sprintf("Axe 1 : %.2f %% de l'inertie", parts[1]),
    ylab = sprintf("Axe 2 : %.2f %% de l'inertie", parts[2]), main = titre
  )
  abline(h = 0, v = 0, col = "#c4d2d6")
  points(lignes, pch = 19, col = "#347663", cex = 1.2)
  points(colonnes, pch = 17, col = "#b77244", cex = 1.2)
  text(lignes, labels = rownames(lignes), pos = 2, col = "#347663")
  text(colonnes, labels = rownames(colonnes), pos = 4, col = "#b77244")
  legend(
    "topright", c("Programmes", "Admissions"), pch = c(19, 17),
    col = c("#347663", "#b77244"), bty = "n", cex = 0.9
  )
  if (!is.null(supplement)) {
    points(supplement, pch = 8, col = "#7570b3", cex = 1.3)
    text(
      supplement, labels = rownames(supplement), pos = 3,
      col = "#7570b3", cex = 0.9
    )
  }
  legende <- if (asymetrique) {
    "F : barycentres des Gamma, avec les poids des profils-lignes."
  } else {
    "Distances interprétables au sein d'un même nuage."
  }
  mtext(legende, side = 1, line = 4, cex = 0.8)
}

tracer_diagnostics_afc <- function(afc) {
  if (afc$rang < 2L) stop("Ce graphique du cours compare deux axes.")
  ancien_par <- par(mfrow = c(1, 2), mar = c(5, 4, 4, 1))
  on.exit(par(ancien_par))
  couleurs <- c("#00897b", "#b77244")
  barplot(
    t(100 * afc$contributions_lignes[, 1:2]), beside = TRUE,
    col = couleurs, border = NA, ylim = c(0, 110), ylab = "Contribution (%)",
    main = "Qui construit les axes ?", las = 1
  )
  abline(h = 100 / nrow(afc$effectifs), lty = 2, col = "#60747d")
  legend("top", c("Axe 1", "Axe 2"), fill = couleurs, bty = "n", horiz = TRUE)
  barplot(
    t(100 * afc$cos2_lignes[, 1:2]), beside = TRUE,
    col = couleurs, border = NA, ylim = c(0, 110), ylab = "Cosinus carré (%)",
    main = "Qualité des programmes", las = 1
  )
  legend("top", c("Axe 1", "Axe 2"), fill = couleurs, bty = "n", horiz = TRUE)
}

tracer_cours_afc <- function(afc) {
  tracer_profils_afc(afc)
  tracer_inertie_afc(afc)
  tracer_plan_afc(afc)
  tracer_plan_afc(afc, asymetrique = TRUE)
  tracer_diagnostics_afc(afc)
}

tracer_cours_afc(afc)

