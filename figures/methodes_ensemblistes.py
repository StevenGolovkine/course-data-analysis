"""Figures et vérifications numériques pour les méthodes ensemblistes.

Depuis la racine : python figures/methodes_ensemblistes.py
Dépendances : NumPy et Matplotlib. Tous les exemples sont théoriques ou fictifs.
"""

from fractions import Fraction
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter, NullLocator
import numpy as np


OUT = Path(__file__).resolve().parent
GREEN, ORANGE, INK, PURPLE = "#347663", "#b77244", "#486976", "#67518a"


def style(ax):
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", lw=0.7)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=9)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)


def save(fig, name):
    fig.savefig(OUT / name, facecolor="white", metadata={"Date": None})
    plt.close(fig)


def variance():
    counts = np.geomspace(1, 500, 500)
    fig, ax = plt.subplots(figsize=(7.4, 3.6))
    fig.subplots_adjust(left=0.10, right=0.98, bottom=0.20, top=0.86)
    ax.set_xscale("log")
    style(ax)
    for rho, color in [(0, GREEN), (0.1, INK), (0.5, ORANGE), (0.8, PURPLE)]:
        relative = rho + (1 - rho) / counts
        label = f"$\\rho={rho:g}$".replace(".", "{,}")
        ax.plot(counts, relative, color=color, lw=1.8, label=label)
        ax.axhline(rho, color=color, ls=":", lw=1, alpha=0.6)
    ax.set(xlim=(1, 500), ylim=(-0.02, 1.04),
           xticks=[1, 2, 5, 10, 50, 100, 500], yticks=[0, 0.1, 0.25, 0.5, 0.8, 1])
    ax.xaxis.set_minor_locator(NullLocator())
    ax.set_xlabel("Nombre de modèles $B$ (échelle logarithmique)", color=INK)
    ax.set_ylabel("Variance relative de la moyenne", color=INK)
    ax.legend(loc="lower center", bbox_to_anchor=(0.5, 1.01), ncol=4,
              frameon=False, fontsize=10)
    for rho, color, offset in [(0.1, INK, 0.09), (0.8, PURPLE, 0.09)]:
        value = rho + (1-rho)/100
        ax.scatter([100], [value], color=color, s=25, zorder=4)
        ax.text(118, value+offset, f"{value:.3f}".replace(".", ","),
                color=color, fontsize=9)
    save(fig, "ensembles_variance.svg")


def fit_stump(x, target):
    """Énumérer les seuils d'une souche de régression unidimensionnelle."""
    unique = np.unique(x)
    thresholds = (unique[:-1] + unique[1:]) / 2
    candidates = []
    for threshold in thresholds:
        left, right = target[x <= threshold], target[x > threshold]
        means = (left.mean(), right.mean())
        predicted = np.where(x <= threshold, *means)
        candidates.append((np.sum((target-predicted)**2), threshold, means, predicted))
    return min(candidates, key=lambda candidate: candidate[0])


def boosting():
    x = np.arange(1, 7)
    y = np.array([1, 2, 3, 8, 9, 10], dtype=float)
    rate = 0.5
    predictions = [np.full(len(y), y.mean())]
    stumps = []
    for _ in range(2):
        residual = y - predictions[-1]
        _, threshold, means, fitted = fit_stump(x, residual)
        stumps.append((threshold, means))
        predictions.append(predictions[-1] + rate * fitted)
    np.testing.assert_allclose([stump[0] for stump in stumps], [3.5, 3.5])
    np.testing.assert_allclose(stumps[0][1], [-3.5, 3.5])
    np.testing.assert_allclose(stumps[1][1], [-1.75, 1.75])
    np.testing.assert_allclose(predictions[1], [3.75]*3+[7.25]*3)
    np.testing.assert_allclose(predictions[2], [2.875]*3+[8.125]*3)
    sce = [np.sum((y-prediction)**2) for prediction in predictions]
    np.testing.assert_allclose(sce, [77.5, 22.375, 8.59375])

    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.65))
    fig.subplots_adjust(left=0.08, right=0.98, bottom=0.18, top=0.87, wspace=0.30)
    for ax in axes:
        style(ax)
        ax.set(xlim=(0.5, 6.5), xticks=x)
        ax.set_xlabel("Variable $x$", color=INK)
    ax = axes[0]
    ax.set(ylim=(-5.5, 6), yticks=[-4, -2, 0, 2, 4])
    ax.axhline(0, color=INK, lw=0.8, ls=":")
    ax.scatter(x, y-predictions[0], s=28, color=ORANGE, zorder=4,
               label="Résidus du modèle initial")
    threshold, means = stumps[0]
    ax.plot([0.5, threshold, threshold, 6.5],
            [means[0], means[0], means[1], means[1]],
            color=GREEN, lw=1.8, label="Correction $h_1$")
    ax.set_title("1. Ajuster les résidus", color=INK, fontsize=11, pad=10)
    ax.set_ylabel("Résidu à corriger", color=INK)
    ax.legend(loc="upper left", frameon=False, fontsize=8)

    ax = axes[1]
    ax.set(ylim=(0, 13), yticks=[0, 2, 4, 6, 8, 10, 12])
    ax.scatter(x, y, s=28, color=INK, zorder=4, label="Observations")
    grid = np.array([0.5, 3.5, 3.5, 6.5])
    for prediction, label, color, ls in zip(
        predictions, ["$F^{(0)}$", "$F^{(1)}$", "$F^{(2)}$"],
        [INK, ORANGE, GREEN], [":", "--", "-"]
    ):
        ax.plot(grid, prediction[[0, 0, -1, -1]], color=color, lw=1.6,
                ls=ls, label=label)
    ax.set_title("2. Ajouter des corrections réduites", color=INK, fontsize=10.5, pad=10)
    ax.set_ylabel("Réponse et prédiction", color=INK)
    ax.legend(loc="upper left", frameon=False, fontsize=8)
    save(fig, "ensembles_boosting.svg")
    print(f"Sommes des carrés après 0, 1 et 2 étapes : {sce}")


def check_examples():
    F = Fraction
    assert 100*(F(4,5)+F(1,5)/100) == F("80.2")
    assert 100*(F(1,10)+F(9,10)/100) == F("10.9")
    assert sum([F(".51"), F(".51"), F(".01")])/3 < F(1,2)
    assert (10-F(32,3))**2 == F(4,9)
    assert F(2,10)*2 + F(8,10)/2 == F(4,5)
    assert (F(1,10)*2)/F(4,5) == F(1,4)
    assert (F(1,10)/2)/F(4,5) == F(1,16)
    assert F(12,100)-F(5,100) == F(7,100)
    np.testing.assert_allclose(0.5*np.log(4), np.log(2))
    np.testing.assert_allclose(np.exp(np.log(2)), 2)


def main():
    plt.rcParams.update({
        "font.family": "DejaVu Sans", "font.size": 10,
        "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
        "svg.hashsalt": "methodes-ensemblistes",
    })
    check_examples()
    variance()
    boosting()
    print("Deux figures générées ; exemples numériques vérifiés.")


if __name__ == "__main__":
    main()
