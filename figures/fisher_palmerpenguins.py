"""Tracer le plan de Fisher et les régions de classification des manchots.

Exécution : python figures/fisher_palmerpenguins.py
Dépendances : NumPy, Matplotlib et Rscript (R de base).
Le script R du cours fournit les coordonnées et les centres, avec exactement
le même partage entraînement/test. Python produit seul le graphique SVG.
"""

import csv
import io
import subprocess
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter
import numpy as np


RACINE = Path(__file__).resolve().parents[1]
CLASSES = ("Adelie", "Chinstrap", "Gentoo")
COULEURS = ("#347663", "#b77244", "#536da5")
MARQUEURS = ("o", "^", "s")
ENCRE = "#486976"


def charger_projections():
    """Lire les résultats exacts du cours sur la sortie standard de R."""
    calcul = r'''
invisible(capture.output(source("codes/analyse_discriminante_fisher.R")))
observations <- data.frame(
  type = "test", classe = as.character(test$species),
  prediction = as.character(prediction$classe),
  f1 = prediction$scores[, 1], f2 = prediction$scores[, 2]
)
centres <- data.frame(
  type = "centre", classe = modele$classes, prediction = modele$classes,
  f1 = modele$centres[, 1], f2 = modele$centres[, 2]
)
write.csv(rbind(observations, centres), stdout(), row.names = FALSE)
'''
    resultat = subprocess.run(
        ["Rscript", "--vanilla", "-e", calcul], cwd=RACINE,
        check=True, capture_output=True, text=True,
    )
    lignes = list(csv.DictReader(io.StringIO(resultat.stdout)))
    tests = [ligne for ligne in lignes if ligne["type"] == "test"]
    centres = {
        ligne["classe"]: [float(ligne["f1"]), float(ligne["f2"])]
        for ligne in lignes if ligne["type"] == "centre"
    }
    points = np.array([[float(t["f1"]), float(t["f2"])] for t in tests])
    etiquettes = np.array([CLASSES.index(t["classe"]) for t in tests])
    predictions = np.array([CLASSES.index(t["prediction"]) for t in tests])
    moyennes = np.array([centres[classe] for classe in CLASSES])
    distances2 = ((points[:, None, :] - moyennes[None, :, :]) ** 2).sum(axis=2)
    np.testing.assert_array_equal(distances2.argmin(axis=1), predictions)
    assert len(points) == 102
    assert np.count_nonzero(etiquettes != predictions) == 2
    return points, etiquettes, predictions, moyennes


def tracer_plan():
    points, etiquettes, predictions, centres = charger_projections()
    limites_min = np.minimum(points.min(axis=0), centres.min(axis=0)) - 0.055
    limites_max = np.maximum(points.max(axis=0), centres.max(axis=0)) + 0.055
    xx, yy = np.meshgrid(
        np.linspace(limites_min[0], limites_max[0], 500),
        np.linspace(limites_min[1], limites_max[1], 350),
    )
    grille = np.column_stack([xx.ravel(), yy.ravel()])
    distances2 = ((grille[:, None, :] - centres[None, :, :]) ** 2).sum(axis=2)
    regions = distances2.argmin(axis=1).reshape(xx.shape)

    with plt.rc_context({
        "font.family": "DejaVu Sans", "font.size": 14,
        "svg.fonttype": "path", "svg.hashsalt": "fisher-palmerpenguins",
    }):
        fig, ax = plt.subplots(figsize=(8.8, 4.5))
        fig.subplots_adjust(left=0.08, right=0.73, top=0.97, bottom=0.16)
        ax.pcolormesh(
            xx, yy, regions, shading="nearest", vmin=0, vmax=2,
            cmap=ListedColormap(["#ecf4ef", "#faf0e5", "#eef1f8"]),
            rasterized=True, zorder=0,
        )
        # Tracer les seules portions des médiatrices qui bordent une région.
        for g in range(len(CLASSES)):
            ax.contour(
                xx, yy, (regions == g).astype(float), levels=[0.5],
                colors=ENCRE, linewidths=0.6, zorder=1,
            )
        for g, classe in enumerate(CLASSES):
            selection = etiquettes == g
            ax.scatter(
                *points[selection].T, marker=MARQUEURS[g], color=COULEURS[g],
                s=27, edgecolors="white", linewidths=0.4, zorder=3,
            )
            ax.scatter(
                *centres[g], marker="X", s=115, color=COULEURS[g],
                edgecolors="white", linewidths=1, zorder=5,
            )
        erreurs = etiquettes != predictions
        ax.scatter(
            *points[erreurs].T, marker="o", s=125, facecolors="none",
            edgecolors="#922e71", linewidths=1.5, zorder=4,
        )
        ax.set(
            xlim=(limites_min[0], limites_max[0]),
            ylim=(limites_min[1], limites_max[1]),
            xlabel="Axe de Fisher 1", ylabel="Axe de Fisher 2",
        )
        ax.set_aspect("equal")
        ax.tick_params(length=0, colors=ENCRE, labelsize=12)
        ax.xaxis.label.set_color(ENCRE)
        ax.yaxis.label.set_color(ENCRE)
        formatter = FuncFormatter(lambda valeur, _: f"{valeur:g}".replace(".", ","))
        ax.xaxis.set_major_formatter(formatter)
        ax.yaxis.set_major_formatter(formatter)
        for bord in ax.spines.values():
            bord.set_visible(False)
        symboles = [
            Line2D([], [], color=COULEURS[g], marker=MARQUEURS[g],
                   linestyle="none", label=classe, markersize=6)
            for g, classe in enumerate(CLASSES)
        ]
        symboles.extend([
            Line2D([], [], color=ENCRE, marker="X", linestyle="none",
                   label="Centre appris", markersize=8),
            Line2D([], [], color="#922e71", marker="o", markerfacecolor="none",
                   linestyle="none", label="Erreur de test", markersize=8),
        ])
        fig.legend(
            handles=symboles, loc="center left", bbox_to_anchor=(0.72, 0.54),
            ncol=1, frameon=False, fontsize=12, labelcolor=ENCRE,
            labelspacing=1.2, handletextpad=0.5,
        )
        fig.savefig(
            Path(__file__).with_suffix(".svg"), facecolor="white",
            metadata={"Date": None},
        )
        plt.close(fig)


if __name__ == "__main__":
    tracer_plan()
