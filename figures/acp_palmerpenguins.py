"""Generate the real-data PCA example used in the lecture notes.

Run from the repository root: python figures/acp_palmerpenguins.py
Requires NumPy, pandas and Matplotlib. No network access is needed.
Data: assets/penguins.csv from the official palmerpenguins repository.
See assets/penguins_README.md for provenance and the data license.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.ticker import FuncFormatter
import numpy as np
import pandas as pd


VARIABLES = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]
DATA_PATH = Path(__file__).resolve().parents[1] / "assets" / "penguins.csv"


def compute_pca():
    penguins = pd.read_csv(DATA_PATH)
    data = penguins.dropna(subset=VARIABLES)
    X = data[VARIABLES].to_numpy()
    Z = (X - X.mean(axis=0)) / X.std(axis=0, ddof=1)
    _, d, Vt = np.linalg.svd(Z, full_matrices=False)
    A = Vt.T.copy()
    # Fix the arbitrary signs by making each largest coefficient positive.
    for k in range(A.shape[1]):
        A[:, k] *= np.sign(A[np.argmax(np.abs(A[:, k])), k])
    scores = Z @ A
    eigenvalues = d**2 / (len(X) - 1)
    correlations = A * np.sqrt(eigenvalues)
    quality = np.sum(scores[:, :2]**2, axis=1) / np.sum(Z**2, axis=1)
    np.testing.assert_allclose(Z.mean(axis=0), 0, atol=1e-12)
    np.testing.assert_allclose(Z.std(axis=0, ddof=1), 1)
    np.testing.assert_allclose(np.cov(scores, rowvar=False),
                               np.diag(eigenvalues), atol=1e-12)
    return data, scores, eigenvalues, correlations, quality


def setup_axes(ax, xlabel, ylabel):
    ax.set_aspect("equal")
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", lw=0.6)
    ax.axhline(0, color="#acb9c0", lw=0.8, zorder=1)
    ax.axvline(0, color="#acb9c0", lw=0.8, zorder=1)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, labelsize=11, colors="#74838b")
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.set_xlabel(xlabel, color="#486976", labelpad=8)
    ax.set_ylabel(ylabel, color="#486976", labelpad=8)


def main():
    data, scores, eigenvalues, correlations, quality = compute_pca()
    percentages = 100 * eigenvalues / eigenvalues.sum()
    percent = lambda value: f"{value:.2f}".replace(".", ",")
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 12,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-palmerpenguins",
    })
    fig, axes = plt.subplots(1, 2, figsize=(9.2, 4.7),
                             gridspec_kw={"width_ratios": [1.2, 1]})
    fig.subplots_adjust(left=0.08, right=0.98, bottom=0.22, top=0.9, wspace=0.3)
    ax = axes[0]
    setup_axes(ax, f"Score sur $Y_1$ · {percent(percentages[0])} %",
               f"Score sur $Y_2$ · {percent(percentages[1])} %")
    ax.set_title("Individus", loc="left", color="#24313a", fontsize=13, pad=12)
    for species, color, marker in zip(["Adelie", "Chinstrap", "Gentoo"],
                                      ["#347663", "#b77244", "#6676a3"],
                                      ["o", "^", "s"]):
        selected = data["species"].to_numpy() == species
        ax.scatter(scores[selected, 0], scores[selected, 1], color=color,
                   marker=marker, s=24, alpha=0.85, edgecolors="white", lw=0.4,
                   label=species, zorder=3)
    ax.set_xlim(-3.1, 4.1)
    ax.set_ylim(-2.5, 2.9)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.21), ncol=3,
              frameon=False, fontsize=11, handletextpad=0.3, columnspacing=0.8)
    i = data.index.get_loc(326)  # Original data row 327 (one-based).
    ax.scatter(*scores[i, :2], s=75, facecolors="none", edgecolors="#24313a",
               lw=1.1, zorder=4)
    ax.annotate("n° 327", xy=scores[i, :2], xytext=(0.3, -1.75),
                color="#24313a", fontsize=11,
                bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
                arrowprops={"arrowstyle": "-", "color": "#24313a", "lw": 0.8},
                zorder=5)

    ax = axes[1]
    setup_axes(ax, "Corrélation avec $Y_1$", "Corrélation avec $Y_2$")
    ax.set_title("Variables", loc="left", color="#24313a", fontsize=13, pad=12)
    ax.set_xlim(-1.35, 1.45)
    ax.set_ylim(-1.2, 1.45)
    ax.set_xticks([-1, -0.5, 0, 0.5, 1])
    ax.set_yticks([-1, -0.5, 0, 0.5, 1])
    ax.add_patch(Circle((0, 0), 1, fill=False, edgecolor="#486976", lw=1.1))
    for point, label, position, color in zip(
        correlations[:, :2],
        VARIABLES,
        [(0.65, 1.15), (-0.6, 0.9), (0.4, -0.3), (0.4, -0.65)],
        ["#486976", "#486976", "#347663", "#347663"],
    ):
        ax.annotate("", xy=point, xytext=(0, 0),
                    arrowprops={"arrowstyle": "->", "color": color, "lw": 1.5},
                    zorder=3)
        ax.annotate(label, xy=point, xytext=position, ha="center", va="center",
                    color=color, fontsize=11,
                    bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
                    arrowprops={"arrowstyle": "-", "color": color, "lw": 0.6,
                                "shrinkA": 3, "shrinkB": 3}, zorder=4)
    fig.savefig(Path(__file__).with_suffix(".svg"), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)
    print("Valeurs propres :", eigenvalues.round(6))
    print("Variance expliquée (%) :", percentages.round(4))
    print("Corrélations variables-axes :\n", correlations[:, :2].round(4))
    print("Qualité des variables dans le plan (%) :",
          (100 * np.sum(correlations[:, :2]**2, axis=1)).round(4))
    print("Observations retenues :", len(data))
    print("Qualité de l'individu 327 dans le plan (%) :", round(100 * quality[i], 4))


if __name__ == "__main__":
    main()
