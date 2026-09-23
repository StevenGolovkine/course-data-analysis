"""Illustrer les partitions de l'introduction à l'apprentissage non supervisé.

Exécution : python figures/unsupervised_introduction.py
Dépendance : Matplotlib. Les calculs utilisent la bibliothèque standard.
Source des six observations et des partitions : lectures/unsupervised.typ.
"""

from math import isclose
from pathlib import Path
from statistics import mean

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter


VALEURS = (0, 1, 2, 8, 9, 10)
PARTITIONS = {
    "A": ((0, 1, 2), (8, 9, 10)),
    "B": ((0, 1, 8), (2, 9, 10)),
    "C": ((0,), (1, 2), (8, 9, 10)),
}
COULEURS = ("#347663", "#b77244", "#536da5")
MARQUEURS = ("o", "^", "s")
ENCRE = "#486976"


def silhouette(valeur, groupes):
    """Calculer la silhouette avec la distance absolue sur la droite réelle."""
    groupe = next(g for g in groupes if valeur in g)
    if len(groupe) == 1:
        return 0.0
    a_i = mean(abs(valeur - autre) for autre in groupe if autre != valeur)
    b_i = min(
        mean(abs(valeur - autre) for autre in g)
        for g in groupes if g is not groupe
    )
    return (b_i - a_i) / max(a_i, b_i) if max(a_i, b_i) > 0 else 0.0


def criteres(groupes):
    """Calculer les quatre indices du cours pour une partition donnée."""
    assert sorted(x for g in groupes for x in g) == list(VALEURS)
    n, k = len(VALEURS), len(groupes)
    moyenne = mean(VALEURS)
    total = sum((x - moyenne) ** 2 for x in VALEURS)
    intra = sum(sum((x - mean(g)) ** 2 for x in g) for g in groupes)
    inter = sum(len(g) * (mean(g) - moyenne) ** 2 for g in groupes)
    assert isclose(total, intra + inter)
    separation = min(
        abs(x - y)
        for i, g in enumerate(groupes)
        for h in groupes[i + 1:]
        for x in g for y in h
    )
    diametre = max(abs(x - y) for g in groupes for x in g for y in g)
    return {
        "K": k, "W": intra, "R2": inter / total,
        "CH": (inter / intra) * (n - k) / (k - 1),
        "silhouette": mean(silhouette(x, groupes) for x in VALEURS),
        "Dunn": separation / diametre,
    }


def verifier_calculs():
    """Contrôler toutes les valeurs arrondies présentées dans les diapositives."""
    attendus = {
        "A": (4.0, 0.96, 96.0, 0.831, 3.0),
        "B": (76.0, 0.24, 1.2631578947, 0.030, 0.125),
        "C": (2.5, 0.975, 58.5, 0.493, 0.5),
    }
    for nom, groupes in PARTITIONS.items():
        resultat = criteres(groupes)
        for cle, attendu in zip(("W", "R2", "CH", "silhouette", "Dunn"),
                                attendus[nom]):
            tolerance = 0.0005 if cle == "silhouette" else 1e-8
            assert isclose(resultat[cle], attendu, abs_tol=tolerance)
        print(nom, resultat)
    assert isclose(silhouette(2, PARTITIONS["A"]), 11 / 14)
    assert isclose(silhouette(2, PARTITIONS["B"]), -0.6)
    assert isclose(silhouette(8, PARTITIONS["B"]), -0.6)
    assert silhouette(0, PARTITIONS["C"]) == 0


def enregistrer(fig, nom):
    fig.savefig(Path(__file__).with_name(nom), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def tracer_partitions():
    fig, ax = plt.subplots(figsize=(9, 4.2))
    fig.subplots_adjust(left=0.16, right=0.97, bottom=0.25, top=0.96)
    for ligne, (nom, groupes) in enumerate(PARTITIONS.items()):
        y = 2 - ligne
        ax.hlines(y, -0.5, 10.5, color="#d6e1e2", linewidth=1, zorder=0)
        for g, groupe in enumerate(groupes):
            ax.scatter(groupe, [y] * len(groupe), s=155,
                       color=COULEURS[g], marker=MARQUEURS[g],
                       edgecolors="white", linewidths=0.9, zorder=3)
    ax.set(xlim=(-0.6, 10.6), ylim=(-0.5, 2.5))
    ax.set_xticks(VALEURS)
    ax.set_yticks([2, 1, 0], ["A  (K = 2)", "B  (K = 2)", "C  (K = 3)"])
    ax.tick_params(length=0, colors=ENCRE, labelsize=14, pad=9)
    for bord in ax.spines.values():
        bord.set_visible(False)
    legendes = [
        Line2D([], [], color=COULEURS[g], marker=MARQUEURS[g],
               linestyle="none", markersize=9, label=f"Groupe {g + 1}")
        for g in range(3)
    ]
    fig.legend(handles=legendes, loc="lower center", ncol=3,
               frameon=False, fontsize=13, labelcolor=ENCRE)
    enregistrer(fig, "unsupervised_partitions.svg")


def tracer_silhouettes():
    fig, axes = plt.subplots(1, 3, figsize=(9, 4.3), sharey=True)
    fig.subplots_adjust(left=0.09, right=0.98, bottom=0.19, top=0.80, wspace=0.18)
    for ax, (nom, groupes) in zip(axes, PARTITIONS.items()):
        scores = [silhouette(x, groupes) for x in VALEURS]
        couleurs = [
            COULEURS[next(g for g, groupe in enumerate(groupes) if x in groupe)]
            for x in VALEURS
        ]
        ax.barh(range(len(VALEURS)), scores, color=couleurs, height=0.62)
        ax.axvline(0, color=ENCRE, linewidth=0.8)
        for ligne, score in enumerate(scores):
            if score == 0:
                ax.plot(0, ligne, marker="o", color=couleurs[ligne], ms=6)
        moyenne = f"{mean(scores):.3f}".replace(".", ",")
        ax.set_title(f"Partition {nom}\nMoyenne : {moyenne}",
                     color=ENCRE, fontsize=14, pad=12)
        ax.set(xlim=(-1, 1), ylim=(5.6, -0.6), xlabel="$s_i$")
        ax.xaxis.label.set_color(ENCRE)
        ax.set_xticks([-1, 0, 1])
        ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _: f"{x:g}"))
        ax.tick_params(length=0, colors=ENCRE, labelsize=13, pad=7)
        for bord in ax.spines.values():
            bord.set_visible(False)
    axes[0].set_yticks(range(len(VALEURS)), [str(x) for x in VALEURS])
    axes[0].set_ylabel("Valeur observée", color=ENCRE, labelpad=10)
    enregistrer(fig, "unsupervised_silhouettes.svg")


if __name__ == "__main__":
    verifier_calculs()
    with plt.rc_context({
        "font.family": "DejaVu Sans", "font.size": 14,
        "svg.fonttype": "path", "svg.hashsalt": "unsupervised-introduction",
    }):
        tracer_partitions()
        tracer_silhouettes()
