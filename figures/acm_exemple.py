"""Generate the MCA illustrations in lectures/dimension_reduction.typ.

Run from the repository root: python figures/acm_exemple.py
Requires NumPy, Matplotlib and Rscript. R computations use base R; an installed
FactoMineR is also used to check the results. The questionnaire is fictional.
"""

import csv
from pathlib import Path
import subprocess
import tempfile

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import to_rgb
from matplotlib.ticker import FuncFormatter
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
VARIABLES = ["Rythme", "Support", "Travail"]
CATEGORIES = ["Régulier", "Ponctuel", "Livres", "Mixte", "Vidéos", "Seul", "Groupe"]
COLORS = [GREEN, GREEN, ORANGE, ORANGE, ORANGE, INK, INK]


def read_rows(path):
    with path.open(encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), facecolor="white", metadata={"Date": None})
    plt.close(fig)


def plot_coding(profiles, coding):
    columns = list(coding[0])[1:]
    Z = np.array([[float(row[col]) for col in columns] for row in coding])
    assert np.all(Z.sum(axis=1) == 3)
    colors = np.full((*Z.shape, 3), 0.96)
    for j, color in enumerate(COLORS):
        colors[Z[:, j] == 1, j, :] = to_rgb(color)
    fig, ax = plt.subplots(figsize=(7.4, 4.2))
    fig.subplots_adjust(left=0.18, right=0.98, bottom=0.19, top=0.83)
    ax.imshow(colors, aspect="auto", interpolation="nearest")
    for i in range(len(profiles)):
        for j in range(len(columns)):
            ax.text(j, i, str(int(Z[i, j])), ha="center", va="center", fontsize=11,
                    color="white" if Z[i, j] else "#9ca7ac")
    ax.set_yticks(range(len(profiles)),
                  [f"{r['profil']} (n = {r['effectif']})" for r in profiles])
    ax.set_xticks(range(len(columns)), CATEGORIES, rotation=25, ha="right")
    ax.tick_params(length=0, labelsize=11, colors=INK, pad=7)
    for start, end, name, color in [(0, 1, "Rythme", GREEN),
                                    (2, 4, "Support", ORANGE), (5, 6, "Travail", INK)]:
        ax.text((start + end) / 2, -1.15, name, ha="center", color=color,
                weight="bold", fontsize=12)
        ax.plot([start - 0.42, end + 0.42], [-0.65, -0.65], color=color, lw=2, clip_on=False)
    ax.set_xticks(np.arange(-0.5, len(columns), 1), minor=True)
    ax.set_yticks(np.arange(-0.5, len(profiles), 1), minor=True)
    ax.grid(which="minor", color="white", linewidth=2)
    ax.tick_params(which="minor", length=0)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.set_ylim(len(profiles) - 0.5, -0.5)
    save(fig, "acm_codage.svg")


def decorate(ax, percentages):
    ax.set_aspect("equal")
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", lw=0.6)
    ax.axhline(0, color="#acb9c0", lw=0.8)
    ax.axvline(0, color="#acb9c0", lw=0.8)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=9)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.set(xlim=(-1.65, 1.85), ylim=(-1.4, 1.45))
    for k, setter in enumerate([ax.set_xlabel, ax.set_ylabel]):
        percent = f"{percentages[k]:.2f}".replace(".", ",")
        setter(f"Axe {k + 1} · {percent} %", color=INK, labelpad=6, fontsize=10)


def plot_map(profiles, modalities, inertias):
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.9))
    fig.subplots_adjust(left=0.08, right=0.99, top=0.87, bottom=0.23, wspace=0.3)
    percentages = [float(r["pourcentage"]) for r in inertias]
    for ax in axes:
        decorate(ax, percentages)
    axes[0].set_title("Individus (profils A à H)", color=INK, fontsize=11, pad=12)
    for row in profiles:
        xy = np.array([float(row["axe1"]), float(row["axe2"])])
        axes[0].scatter(*xy, s=38 * int(row["effectif"]), color=INK,
                         edgecolor="white", linewidth=0.7, alpha=0.85, zorder=3)
        axes[0].annotate(row["profil"], xy, xytext=(7, 7), textcoords="offset points",
                         fontsize=10, color=INK)
    axes[1].set_title("Modalités", color=INK, fontsize=11, pad=12)
    offsets = [(-8, 14, "right"), (0, 15, "center"), (-3, -16, "center"),
               (-12, 14, "right"), (2, -16, "center"), (0, -16, "center"),
               (12, 14, "left")]
    markers = ["o", "o", "^", "^", "^", "s", "s"]
    for j, row in enumerate(modalities):
        xy = np.array([float(row["axe1"]), float(row["axe2"])])
        dx, dy, align = offsets[j]
        axes[1].scatter(*xy, color=COLORS[j], marker=markers[j], s=45,
                         edgecolor="white", linewidth=0.7, zorder=4)
        axes[1].annotate(CATEGORIES[j], xy, xytext=(dx, dy), textcoords="offset points",
                         ha=align, va="center", fontsize=9, color=COLORS[j],
                         arrowprops={"arrowstyle": "-", "color": COLORS[j], "lw": 0.6},
                         bbox={"facecolor": "white", "edgecolor": "none", "pad": 0.7})
    from matplotlib.lines import Line2D
    handles = [Line2D([], [], marker=marker, color=color, linestyle="none", label=name)
               for marker, color, name in zip(["o", "^", "s"], [GREEN, ORANGE, INK], VARIABLES)]
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.53, 0.035),
               ncol=3, frameon=False, fontsize=10)
    save(fig, "acm_plan.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                         "svg.fonttype": "path", "svg.hashsalt": "acm-exemple"})
    with tempfile.TemporaryDirectory(prefix="course-acm-") as directory:
        subprocess.run(["Rscript", str(ROOT / "codes" / "analyse_correspondances_multiples.R"),
                        directory], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
        out = Path(directory)
        profiles = read_rows(out / "profils.csv")
        plot_coding(profiles, read_rows(out / "disjonctif.csv"))
        plot_map(profiles, read_rows(out / "modalites.csv"), read_rows(out / "inerties.csv"))


if __name__ == "__main__":
    main()
