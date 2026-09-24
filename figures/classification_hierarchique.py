"""Dendrogrammes pour le cours : exemple calculé et Palmer Penguins.

Depuis la racine : python figures/classification_hierarchique.py
NumPy, Matplotlib, Rscript et le paquet R cluster sont nécessaires.
Les fusions sont calculées par le script R du cours, puis dessinées ici.
"""

import csv
from pathlib import Path
import subprocess
import tempfile

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
COLORS = [GREEN, ORANGE]


def read_rows(path):
    with path.open(newline="") as stream:
        return list(csv.DictReader(stream))


def decorate(ax):
    ax.set_axisbelow(True)
    ax.grid(axis="y", color="#e8edef", lw=0.7)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=9)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.yaxis.set_major_formatter(formatter)


def dendrogram(ax, rows, groups, leaf_labels=None):
    """Draw R's merge table, rotating branches to order by the first input row."""
    n = len(rows) + 1
    children = {r+1: (int(row["gauche"]), int(row["droite"]))
                for r, row in enumerate(rows)}
    heights = {r+1: float(row["hauteur"]) for r, row in enumerate(rows)}
    members = {-i: [i-1] for i in range(1, n+1)}
    for r in range(1, n):
        a, b = children[r]
        members[r] = members[a] + members[b]
    order = []

    def visit(node):
        if node < 0:
            order.append(-node-1)
        else:
            for child in sorted(children[node], key=lambda c: min(members[c])):
                visit(child)

    visit(n-1)
    position = {-(i+1): (rank, 0.0) for rank, i in enumerate(order)}
    for r in range(1, n):
        a, b = children[r]
        xa, ya = position[a]
        xb, yb = position[b]
        height = heights[r]
        unique = set(groups[i] for i in members[r])
        color = COLORS[next(iter(unique))-1] if len(unique) == 1 else INK
        ax.plot([xa, xa, xb, xb], [ya, height, height, yb],
                color=color, lw=1.2 if n < 10 else 0.6)
        position[r] = ((xa+xb)/2, height)
    ax.set_xlim(-0.5, n-0.5)
    if leaf_labels is None:
        ax.set_xticks([])
    else:
        ax.set_xticks(range(n), [leaf_labels[i] for i in order])
        for tick, i in zip(ax.get_xticklabels(), order):
            tick.set_color(COLORS[groups[i]-1])
    return order


def save(fig, name):
    fig.savefig(ROOT / "figures" / name, facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def example(rows, points):
    labels = [f'{p["nom"]}\n{float(p["x"]):g}' for p in points]
    groups = [1, 1, 1, 2, 2, 2]
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.8))
    fig.subplots_adjust(left=0.08, right=0.98, top=0.87, bottom=0.22, wspace=0.28)
    for ax in axes:
        decorate(ax)
        dendrogram(ax, rows, groups, labels)
        ax.set_xlabel("Observation et valeur de $x$", color=INK, labelpad=8)
    axes[0].set_title("Hiérarchie complète", color=INK, fontsize=11, pad=10)
    axes[0].set_ylim(0, 15.4)
    axes[0].set_yticks([0, 1, 2.5, 5, 10, 15])
    axes[0].set_ylabel(r"Hauteur de Ward : $\sqrt{2\,\Delta W}$", color=INK)
    axes[0].axhline(2.5, color=INK, ls="--", lw=1)
    axes[0].text(2.5, 3.1, "$h=2{,}5$ : $K=2$", ha="center", color=INK, fontsize=9)
    axes[1].set_title("Zoom sur les premières fusions", color=INK, fontsize=11, pad=10)
    axes[1].set_ylim(0, 2.2)
    axes[1].set_yticks([0, 0.5, 1, 1.3, np.sqrt(3), 2])
    axes[1].set_yticklabels(["0", "0,5", "1", "1,3", "√3", "2"])
    axes[1].axhline(1.3, color=INK, ls="--", lw=1)
    axes[1].text(2.5, 2.04, "$h=1{,}3$ : $K=4$", ha="center", color=INK,
                 fontsize=9, bbox={"facecolor": "white", "edgecolor": "none", "pad": 1})
    save(fig, "cah_exemple.svg")


def penguins(rows, group_rows, criteria):
    groups = [int(row["groupe"]) for row in group_rows]
    candidates = np.array([int(row["K"]) for row in criteria])
    silhouettes = np.array([float(row["silhouette"]) for row in criteria])
    best = candidates[np.argmax(silhouettes)]
    assert best == 2 and sorted(set(groups)) == [1, 2]
    last_heights = [float(row["hauteur"]) for row in rows[-2:]]
    cut = sum(last_heights) / 2
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.8),
                             gridspec_kw={"width_ratios": [1.3, 1]})
    fig.subplots_adjust(left=0.08, right=0.98, top=0.85, bottom=0.17, wspace=0.30)
    for ax in axes:
        decorate(ax)
    order = dendrogram(axes[0], rows, groups)
    axes[0].set_ylim(0, 44)
    axes[0].set_yticks([0, 10, 20, 30, 40])
    axes[0].set_ylabel(r"Hauteur de Ward : $\sqrt{2\,\Delta W}$", color=INK)
    axes[0].set_xlabel("342 manchots (étiquettes masquées)", color=INK, labelpad=8)
    axes[0].axhline(cut, color=INK, lw=1, ls="--")
    axes[0].text(len(groups)/2, cut+1.3, "Coupe en deux groupes", ha="center",
                 fontsize=9, color=INK)
    for group, color in enumerate(COLORS, 1):
        ranks = [rank for rank, i in enumerate(order) if groups[i] == group]
        axes[0].text(np.mean(ranks), 22.5, f"Groupe {group}\n$n={len(ranks)}$",
                     ha="center", va="center", color=color, fontsize=9)
    axes[0].set_title("Ward sur les quatre mesures réduites", color=INK, fontsize=10.5, pad=10)
    axes[1].plot(candidates, silhouettes, "o-", color=INK, lw=1.4, ms=4)
    axes[1].scatter([best], [silhouettes.max()], color=GREEN, s=60, zorder=3)
    axes[1].axvline(best, color=GREEN, ls=":", lw=1)
    axes[1].set(xlim=(1.65, 8.3), ylim=(0.2, 0.59), xticks=candidates,
                yticks=[0.2, 0.3, 0.4, 0.5])
    axes[1].set_xlabel("Nombre de groupes $K$", color=INK)
    axes[1].set_ylabel("Silhouette moyenne", color=INK)
    axes[1].text(2.3, 0.548, "Maximum : 0,532", color=GREEN, fontsize=9)
    axes[1].set_title("Comparer les coupes du même arbre", color=INK, fontsize=10.5, pad=10)
    save(fig, "cah_palmerpenguins.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "cah-cours"})
    with tempfile.TemporaryDirectory(prefix="course-cah-") as output:
        subprocess.run(["Rscript", "codes/classification_hierarchique.R", output],
                       cwd=ROOT, check=True, stdout=subprocess.PIPE, text=True)
        output = Path(output)
        example(read_rows(output / "exemple_fusions.csv"),
                read_rows(output / "exemple_points.csv"))
        penguins(read_rows(output / "penguins_fusions.csv"),
                 read_rows(output / "penguins_groupes.csv"),
                 read_rows(output / "criteres.csv"))


if __name__ == "__main__":
    main()
