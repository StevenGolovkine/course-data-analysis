"""Illustrate correspondence analysis of a fictional admissions table.

Run from the repository root: python figures/afc_exemple.py
Requires NumPy and Matplotlib. Generates afc_profils.svg and afc_plan.svg.
The data and their order match the worked example in dimension_reduction.typ.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import numpy as np


COUNTS = np.array([[60, 25, 15], [10, 35, 15], [10, 10, 20]], dtype=float)
PROGRAMMES = ["Sciences", "Lettres", "Gestion"]
ADMISSIONS = ["Directe", "Passerelle", "Reprise d'études"]
INK, GREEN, ORANGE = "#486976", "#347663", "#b77244"


def compute_ca():
    P = COUNTS / COUNTS.sum()
    r, c = P.sum(axis=1), P.sum(axis=0)
    row_profiles, col_profiles = P / r[:, None], P / c
    S = (P - np.outer(r, c)) / np.sqrt(np.outer(r, c))
    U, sigma, Vt = np.linalg.svd(S, full_matrices=False)
    rank = np.count_nonzero(sigma > 1e-12)
    U, sigma, V = U[:, :rank], sigma[:rank], Vt.T[:, :rank]
    for k in range(rank):
        sign = np.sign(U[np.argmax(np.abs(U[:, k])), k])
        U[:, k] *= sign
        V[:, k] *= sign
    F = U * sigma / np.sqrt(r[:, None])
    G = V * sigma / np.sqrt(c[:, None])
    eigenvalues = sigma**2
    # Check both transition formulas and the exact reconstruction of P.
    np.testing.assert_allclose(F, row_profiles @ (G / sigma), atol=1e-12)
    np.testing.assert_allclose(G, col_profiles.T @ (F / sigma), atol=1e-12)
    np.testing.assert_allclose(P, np.outer(r, c) * (1 + (F / sigma) @ G.T))
    np.testing.assert_allclose(eigenvalues.sum(), np.sum(S**2))
    np.testing.assert_allclose(F.T @ (r[:, None] * F), np.diag(eigenvalues), atol=1e-12)
    return P, r, c, row_profiles, F, G, eigenvalues


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), facecolor="white", metadata={"Date": None})
    plt.close(fig)


def plot_profiles(c, row_profiles):
    fig, ax = plt.subplots(figsize=(7.4, 3.6))
    fig.subplots_adjust(left=0.2, right=0.94, bottom=0.2, top=0.98)
    profiles = np.vstack([row_profiles, c])
    y = np.arange(3, -1, -1)
    left = np.zeros(4)
    for j, color in enumerate([INK, GREEN, ORANGE]):
        widths = profiles[:, j] * 100
        ax.barh(y, widths, left=left, height=0.64, color=color, label=ADMISSIONS[j])
        for position, start, width in zip(y, left, widths):
            label = f"{width:.1f}".rstrip("0").rstrip(".").replace(".", ",")
            ax.text(start + width/2, position, label + " %", color="white",
                    ha="center", va="center", fontsize=11)
        left += widths
    totals = list(COUNTS.sum(axis=1).astype(int)) + [int(COUNTS.sum())]
    ax.set_yticks(y, [f"{name}\n(n = {total})" for name, total in
                     zip(PROGRAMMES + ["Ensemble"], totals)])
    ax.axhline(0.5, color="#acb9c0", lw=0.7)
    ax.set_xlim(0, 100)
    ax.set_xticks([0, 25, 50, 75, 100], ["0 %", "25 %", "50 %", "75 %", "100 %"])
    ax.tick_params(length=0, labelsize=11, colors=INK, pad=7)
    for spine in ax.spines.values():
        spine.set_visible(False)
    fig.legend(*ax.get_legend_handles_labels(), loc="lower center",
               bbox_to_anchor=(0.58, 0.005), frameon=False, ncol=3,
               fontsize=10.5, handlelength=1, columnspacing=1.2)
    save(fig, "afc_profils.svg")


def plot_map(F, G, eigenvalues):
    percentages = 100 * eigenvalues / eigenvalues.sum()
    fig, ax = plt.subplots(figsize=(6.4, 4.9))
    fig.subplots_adjust(left=0.14, right=0.98, bottom=0.15, top=0.97)
    ax.set_aspect("equal")
    ax.set_xlim(-1, 0.9)
    ax.set_ylim(-0.65, 0.8)
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", lw=0.6)
    ax.axhline(0, color="#acb9c0", lw=0.8)
    ax.axvline(0, color="#acb9c0", lw=0.8)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors="#74838b", labelsize=10)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    for points, labels, color, marker, group, offsets in [
        (F, PROGRAMMES, GREEN, "o", "Programmes",
         [(-25, -25, "right"), (-15, -20, "right"), (-5, 18, "right")]),
        (G, ADMISSIONS, ORANGE, "^", "Admissions",
         [(14, 10, "left"), (14, -20, "left"), (-15, -10, "right")]),
    ]:
        ax.scatter(points[:, 0], points[:, 1], s=65, marker=marker, color=color,
                   edgecolors="white", lw=0.8, label=group, zorder=4)
        for point, label, (dx, dy, align) in zip(points, labels, offsets):
            ax.annotate(label, xy=point, xytext=(dx, dy), textcoords="offset points",
                        ha=align, va="center", fontsize=12, color=color,
                        bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
                        arrowprops={"arrowstyle": "-", "color": color, "lw": 0.7,
                                    "shrinkA": 3, "shrinkB": 4}, zorder=5)
    for k, setter in enumerate([ax.set_xlabel, ax.set_ylabel]):
        percent = f"{percentages[k]:.2f}".replace(".", ",")
        setter(f"Axe {k + 1} · {percent} % de l'inertie", color=INK, labelpad=8)
    ax.legend(loc="upper right", frameon=False, fontsize=11)
    save(fig, "afc_plan.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 12,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "afc-exemple"})
    P, r, c, row_profiles, F, G, eigenvalues = compute_ca()
    plot_profiles(c, row_profiles)
    plot_map(F, G, eigenvalues)
    print("Inertie et chi-deux :", eigenvalues.sum(), COUNTS.sum() * eigenvalues.sum())
    print("Valeurs propres :", eigenvalues)
    print("Pourcentages :", 100 * eigenvalues / eigenvalues.sum())
    print("Coordonnées principales des lignes :\n", F)
    print("Coordonnées principales des colonnes :\n", G)
    print("Contributions des lignes (%) :\n", 100 * r[:, None] * F**2 / eigenvalues)
    print("Cosinus carrés des lignes (%) :\n", 100 * F**2 / np.sum(F**2, axis=1)[:, None])
    print("Contributions des colonnes (%) :\n", 100 * c[:, None] * G**2 / eigenvalues)


if __name__ == "__main__":
    main()
