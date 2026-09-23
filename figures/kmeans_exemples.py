"""Figures des exemples numériques du cours sur les k-moyennes.

Exécution : python figures/kmeans_exemples.py
Dépendance : Matplotlib. Les calculs utilisent la bibliothèque standard.
Source des observations : lectures/unsupervised.typ, section k-moyennes.
"""

from itertools import combinations
from math import isclose
from pathlib import Path
from statistics import mean

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter


VERT, ORANGE, ENCRE = "#347663", "#b77244", "#486976"
VALEURS = (0, 1, 2, 8, 9, 10)
VALEURS_COUDE = (0, 1, 2, 10, 11, 12, 20, 21, 22)
PARTITIONS_COUDE = (
    (VALEURS_COUDE,),
    ((0, 1, 2), (10, 11, 12, 20, 21, 22)),
    ((0, 1, 2), (10, 11, 12), (20, 21, 22)),
    ((0,), (1, 2), (10, 11, 12), (20, 21, 22)),
)


def affecter(valeurs, centres):
    """Le premier centre l'emporte en cas d'égalité."""
    return [min(range(len(centres)), key=lambda g: (x - centres[g]) ** 2)
            for x in valeurs]


def critere(valeurs, groupes, centres):
    return sum((x - centres[g]) ** 2 for x, g in zip(valeurs, groupes))


def trajectoire_lloyd():
    centres = (0, 2)
    groupes = affecter(VALEURS, centres)
    etapes = [(groupes, centres, critere(VALEURS, groupes, centres))]
    for _ in range(2):
        groupes = affecter(VALEURS, centres)
        centres = tuple(mean(x for x, h in zip(VALEURS, groupes) if h == g)
                        for g in range(2))
        etapes.append((groupes, centres, critere(VALEURS, groupes, centres)))
    assert [e[2] for e in etapes] == [150, 39.25, 4]
    assert etapes[1][1] == (0.5, 7.25)
    assert centres == (1, 9)
    assert affecter(VALEURS, centres) == groupes
    return etapes


def inertie(groupes):
    return sum(sum((x - mean(g)) ** 2 for x in g) for g in groupes)


def silhouette_moyenne(groupes):
    scores = []
    for g in groupes:
        for x in g:
            if len(g) == 1:
                scores.append(0.0)
                continue
            a_i = mean(abs(x - y) for y in g if y != x)
            b_i = min(mean(abs(x - y) for y in h) for h in groupes if h != g)
            scores.append((b_i - a_i) / max(a_i, b_i))
    return mean(scores)


def verifier_coude():
    """Énumérer toutes les découpes consécutives pour vérifier les minima."""
    n = len(VALEURS_COUDE)
    resultats = []
    for k, groupes in enumerate(PARTITIONS_COUDE, start=1):
        couts = []
        for coupures in combinations(range(1, n), k - 1):
            bornes = (0, *coupures, n)
            partition = tuple(VALEURS_COUDE[a:b]
                              for a, b in zip(bornes[:-1], bornes[1:]))
            couts.append(inertie(partition))
        w = inertie(groupes)
        assert isclose(w, min(couts))
        assert isclose(w, (606, 156, 6, 4.5)[k - 1])
        sil = silhouette_moyenne(groupes) if k > 1 else None
        ch = ((606 - w) / w) * (n - k) / (k - 1) if k > 1 else None
        if k > 1:
            assert isclose(sil, (0.641, 0.862, 0.628)[k - 2], abs_tol=0.0005)
            assert isclose(ch, (20.19, 300, 222.78)[k - 2], abs_tol=0.005)
        resultats.append((k, w, sil, ch))
        print(f"k={k}, W={w}, silhouette={sil}, CH={ch}")
    return resultats


def enregistrer(fig, nom):
    fig.savefig(Path(__file__).with_name(nom), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def tracer_lloyd(etapes):
    fig, ax = plt.subplots(figsize=(9.4, 4.4))
    fig.subplots_adjust(left=0.25, right=0.98, top=0.96, bottom=0.23)
    for ligne, (groupes, centres, _) in enumerate(etapes):
        y = 2 - ligne
        ax.hlines(y, -0.5, 10.5, color="#d6e1e2", linewidth=1, zorder=0)
        for g, (couleur, marqueur) in enumerate(((VERT, "o"), (ORANGE, "^"))):
            points = [x for x, h in zip(VALEURS, groupes) if h == g]
            ax.scatter(points, [y] * len(points), s=90, marker=marqueur,
                       color=couleur, edgecolors="white", linewidths=0.7)
            ax.scatter(centres[g], y - 0.25, s=140, marker="X", color=couleur,
                       edgecolors="white", linewidths=0.6, zorder=4)
    ax.set(xlim=(-0.6, 10.6), ylim=(-0.6, 2.4))
    ax.set_xticks(VALEURS)
    ax.set_yticks([2, 1, 0], [
        "Centres initiaux\nQ = 150",
        "Après mise à jour 1\nW = 39,25",
        "Après mise à jour 2\nW = 4",
    ])
    ax.tick_params(length=0, colors=ENCRE, labelsize=13, pad=10)
    for bord in ax.spines.values():
        bord.set_visible(False)
    symboles = [
        Line2D([], [], color=VERT, marker="o", linestyle="none",
               markersize=7, label="Groupe 1"),
        Line2D([], [], color=ORANGE, marker="^", linestyle="none",
               markersize=7, label="Groupe 2"),
        Line2D([], [], color=ENCRE, marker="X", linestyle="none",
               markersize=9, label="Centre"),
    ]
    fig.legend(handles=symboles, loc="lower center", ncol=3,
               frameon=False, labelcolor=ENCRE, fontsize=13)
    enregistrer(fig, "kmeans_lloyd_etapes.svg")


def tracer_coude(resultats):
    fig, axes = plt.subplots(1, 2, figsize=(9.2, 4.3))
    fig.subplots_adjust(left=0.09, right=0.98, top=0.89, bottom=0.19, wspace=0.34)
    for ax in axes:
        ax.set_axisbelow(True)
        ax.grid(color="#e8edef", linewidth=0.6)
        ax.axvline(3, color=ORANGE, linestyle="--", linewidth=1.2)
        ax.set_xticks([1, 2, 3, 4])
        ax.set_xlabel("Nombre de groupes k", color=ENCRE, labelpad=9)
        ax.tick_params(length=0, colors=ENCRE, labelsize=12)
        ax.yaxis.set_major_formatter(FuncFormatter(
            lambda v, _: f"{v:g}".replace(".", ",")))
        for bord in ax.spines.values():
            bord.set_visible(False)
    axes[0].plot([r[0] for r in resultats], [r[1] for r in resultats],
                 color=VERT, marker="o", linewidth=2, markersize=6)
    axes[0].set(xlim=(0.8, 4.2), ylim=(-25, 700))
    axes[0].set_title("Inertie minimale", color=ENCRE, fontsize=14, pad=12)
    axes[0].set_ylabel("W", color=ENCRE)
    for k, w, _, _ in resultats:
        axes[0].annotate(f"{w:g}".replace(".", ","), xy=(k, w),
                         xytext=(0, 11), textcoords="offset points",
                         ha="center", fontsize=12, color=ENCRE)
    axes[1].plot([r[0] for r in resultats[1:]], [r[2] for r in resultats[1:]],
                 color=VERT, marker="o", linewidth=2, markersize=6)
    axes[1].set(xlim=(1.8, 4.2), ylim=(0, 1))
    axes[1].set_xticks([2, 3, 4])
    axes[1].set_title("Silhouette moyenne", color=ENCRE, fontsize=14, pad=12)
    for k, _, sil, _ in resultats[1:]:
        axes[1].annotate(f"{sil:.3f}".replace(".", ","), xy=(k, sil),
                         xytext=(0, 11), textcoords="offset points",
                         ha="center", fontsize=12, color=ENCRE)
    enregistrer(fig, "kmeans_coude_exemple.svg")


if __name__ == "__main__":
    etapes_lloyd = trajectoire_lloyd()
    resultats_coude = verifier_coude()
    with plt.rc_context({
        "font.family": "DejaVu Sans", "font.size": 14,
        "svg.fonttype": "path", "svg.hashsalt": "kmeans-exemples",
    }):
        tracer_lloyd(etapes_lloyd)
        tracer_coude(resultats_coude)
