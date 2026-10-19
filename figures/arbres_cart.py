"""Figures pédagogiques CART : lecture, régression et construction d'un arbre.

Depuis la racine : python figures/arbres_cart.py (NumPy et Matplotlib).
Les exemples sont fictifs ; le premier arbre est fixé pour expliquer sa lecture,
le deuxième minimise les carrés résiduels et le troisième utilise Gini.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.ticker import FuncFormatter
import numpy as np


GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
OUT = Path(__file__).parent


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


def partition():
    fig, (tree, plane) = plt.subplots(1, 2, figsize=(7.4, 3.5),
                                    gridspec_kw={"width_ratios": [1.05, 1]})
    fig.subplots_adjust(left=0.025, right=0.98, bottom=0.17, top=0.88, wspace=0.24)
    tree.set(xlim=(0, 1), ylim=(0, 1))
    tree.axis("off")
    tree.set_title("Questions successives", fontsize=11, color=INK, pad=10)
    nodes = {"root": (0.45, 0.86), "r1": (0.16, 0.48),
             "split": (0.71, 0.48), "r2": (0.52, 0.07), "r3": (0.90, 0.07)}
    for parent, child, label in [("root", "r1", "oui"), ("root", "split", "non"),
                                  ("split", "r2", "oui"), ("split", "r3", "non")]:
        start, end = nodes[parent], nodes[child]
        tree.plot([start[0], end[0]], [start[1], end[1]], color=INK, lw=1.2, zorder=1)
        tree.text((start[0]+end[0])/2, (start[1]+end[1])/2, label, fontsize=9,
                  ha="center", color=INK, bbox={"facecolor": "white", "edgecolor": "none", "pad": 1})
    labels = {"root": "$x_1 \\leq 2$ ?", "split": "$x_2 \\leq 1$ ?",
              "r1": "$R_1$\nClasse A", "r2": "$R_2$\nClasse B", "r3": "$R_3$\nClasse A"}
    for key, (x, y) in nodes.items():
        color = ORANGE if key == "r2" else GREEN if key in ("r1", "r3") else INK
        tree.text(x, y, labels[key], ha="center", va="center", fontsize=10,
                  color=color, zorder=2,
                  bbox={"boxstyle": "round,pad=0.4", "fc": "white", "ec": color, "lw": 1.1})

    style(plane)
    plane.set(xlim=(0, 4), ylim=(0, 3), xticks=[0, 1, 2, 3, 4], yticks=[0, 1, 2, 3])
    plane.set_xlabel("Variable $x_1$", color=INK)
    plane.set_ylabel("Variable $x_2$", color=INK)
    plane.set_title("Régions de prédiction", fontsize=11, color=INK, pad=10)
    for xy, width, height, color in [((0, 0), 2, 3, GREEN), ((2, 0), 2, 1, ORANGE),
                                     ((2, 1), 2, 2, GREEN)]:
        plane.add_patch(Rectangle(xy, width, height, fc=color, alpha=0.12, ec="none"))
    plane.axvline(2, color=INK, lw=1.6)
    plane.plot([2, 4], [1, 1], color=INK, lw=1.6)
    for x, y, label, color in [(1, 1.5, "$R_1$\nClasse A", GREEN),
                               (3, 0.25, "$R_2$\nClasse B", ORANGE),
                               (3, 2, "$R_3$\nClasse A", GREEN)]:
        plane.text(x, y, label, color=color, ha="center", va="center", fontsize=11)
    plane.scatter([3], [0.6], c=INK, s=24, zorder=5)
    plane.annotate(r"$x=(3\,;\,0{,}6)$", (3, 0.6), xytext=(2.25, 0.84), fontsize=8, color=INK)
    save(fig, "cart_partition.svg")


def regression():
    x = np.arange(1, 7)
    y = np.array([1, 2, 3, 8, 9, 10])
    thresholds = (x[:-1] + x[1:]) / 2
    costs = []
    for threshold in thresholds:
        left, right = y[x <= threshold], y[x > threshold]
        costs.append(np.sum((left-left.mean())**2) + np.sum((right-right.mean())**2))
    np.testing.assert_allclose(costs, [53.2, 29.5, 4, 29.5, 53.2])
    assert thresholds[np.argmin(costs)] == 3.5
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.5))
    fig.subplots_adjust(left=0.075, right=0.98, bottom=0.18, top=0.88, wspace=0.29)
    for ax in axes:
        style(ax)
    ax = axes[0]
    ax.axhline(y.mean(), color=INK, ls="--", lw=1.1, label="Sans coupure : 5,5")
    ax.plot([0.5, 3.5, 3.5, 6.5], [2, 2, 9, 9], color=GREEN, lw=1.8,
            label="Deux feuilles : 2 et 9")
    prediction = np.where(x <= 3.5, 2, 9)
    ax.vlines(x, prediction, y, color=ORANGE, lw=1.5)
    ax.scatter(x, y, s=28, c=ORANGE, zorder=3, label="Observations")
    ax.set(xlim=(0.5, 6.5), ylim=(0, 12.5), xticks=x, yticks=[0, 2, 4, 6, 8, 10])
    ax.set_xlabel("Variable $x$", color=INK)
    ax.set_ylabel("Réponse $y$", color=INK)
    ax.set_title("Prédiction constante dans chaque feuille", fontsize=10.5, color=INK, pad=10)
    ax.legend(loc="upper left", fontsize=7.5, frameon=False)
    ax = axes[1]
    ax.plot(thresholds, costs, "o-", color=INK, lw=1.3, ms=4)
    ax.scatter([3.5], [4], c=GREEN, s=55, zorder=4)
    ax.annotate("Minimum : 4", (3.5, 4), xytext=(3.5, 16), ha="center", fontsize=10,
                color=GREEN, arrowprops={"arrowstyle": "-", "color": GREEN})
    ax.set(xlim=(1.2, 5.8), ylim=(0, 62), xticks=thresholds, yticks=[0, 20, 40, 60])
    ax.set_xlabel("Seuil candidat $s$", color=INK)
    ax.set_ylabel("Somme des carrés après coupure", color=INK)
    ax.set_title("Comparaison des cinq coupures", fontsize=10.5, color=INK, pad=10)
    save(fig, "cart_regression.svg")


def construction():
    x = np.arange(1, 13)
    y = np.array(["A"] * 4 + ["B"] * 4 + ["A"] * 4)

    def gini(labels):
        _, counts = np.unique(labels, return_counts=True)
        return 1 - np.sum((counts / len(labels)) ** 2)

    # Deux observations au minimum dans chaque feuille.
    thresholds = (x[1:-2] + x[2:-1]) / 2
    gains = [
        gini(y) - np.mean(x <= s) * gini(y[x <= s])
        - np.mean(x > s) * gini(y[x > s])
        for s in thresholds
    ]
    np.testing.assert_allclose(
        gains, [2/45, 2/27, 1/9, 8/315, 0, 8/315, 1/9, 2/27, 2/45],
        atol=1e-14,
    )
    np.testing.assert_array_equal(thresholds[np.isclose(gains, max(gains))], [4.5, 8.5])
    prediction = np.where((x > 4.5) & (x <= 8.5), "B", "A")
    np.testing.assert_array_equal(prediction, y)

    fig, (tree, plane) = plt.subplots(
        1, 2, figsize=(7.4, 3.8), gridspec_kw={"width_ratios": [1.15, 1]}
    )
    fig.subplots_adjust(left=0.025, right=0.98, bottom=0.17, top=0.87, wspace=0.23)
    tree.set(xlim=(0, 1), ylim=(0, 1))
    tree.axis("off")
    tree.set_title("Deux coupures, trois feuilles", fontsize=11, color=INK, pad=14)
    nodes = {
        "root": (0.43, 0.88), "left": (0.15, 0.47),
        "right": (0.71, 0.47), "middle": (0.51, 0.06), "last": (0.91, 0.06),
    }
    for parent, child, answer in [
        ("root", "left", "oui"), ("root", "right", "non"),
        ("right", "middle", "oui"), ("right", "last", "non"),
    ]:
        start, end = nodes[parent], nodes[child]
        tree.plot([start[0], end[0]], [start[1], end[1]], color=INK, lw=1.2, zorder=1)
        tree.text(
            (start[0] + end[0]) / 2, (start[1] + end[1]) / 2, answer,
            ha="center", va="center", fontsize=8.5, color=INK,
            bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
        )
    labels = {
        "root": "$x \\leq 4{,}5$ ?\n8 A · 4 B",
        "right": "$x \\leq 8{,}5$ ?\n4 A · 4 B",
        "left": "Classe A\n4 A · 0 B",
        "middle": "Classe B\n0 A · 4 B",
        "last": "Classe A\n4 A · 0 B",
    }
    for key, (px, py) in nodes.items():
        color = ORANGE if key == "middle" else GREEN if key in ("left", "last") else INK
        tree.text(
            px, py, labels[key], ha="center", va="center", fontsize=9,
            color=color, zorder=2,
            bbox={"boxstyle": "round,pad=0.4", "fc": "white", "ec": color, "lw": 1.1},
        )

    style(plane)
    plane.set(
        xlim=(0.5, 12.5), ylim=(0, 1.9), xticks=[1, 4, 5, 8, 9, 12],
        yticks=[0.4, 1.1],
    )
    plane.set_yticklabels(["B", "A"])
    plane.set_xlabel("Variable $x$", color=INK)
    plane.set_ylabel("Classe observée", color=INK)
    plane.set_title("Observations et prédictions", fontsize=11, color=INK, pad=14)
    plane.grid(axis="x", visible=False)
    for lower, upper, label, color in [
        (0.5, 4.5, "A", GREEN), (4.5, 8.5, "B", ORANGE), (8.5, 12.5, "A", GREEN)
    ]:
        plane.axvspan(lower, upper, color=color, alpha=0.1, ec="none")
        plane.text(
            (lower + upper) / 2, 1.63, f"Prédit\n{label}", color=color,
            ha="center", va="center", fontsize=9,
        )
    for threshold in [4.5, 8.5]:
        plane.axvline(threshold, color=INK, ls="--", lw=1.1)
    for label, level, color in [("A", 1.1, GREEN), ("B", 0.4, ORANGE)]:
        selected = x[y == label]
        plane.scatter(selected, np.full(len(selected), level), color=color, s=25, zorder=3)
    save(fig, "cart_construction.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "cart-exemples"})
    partition()
    regression()
    construction()


if __name__ == "__main__":
    main()
