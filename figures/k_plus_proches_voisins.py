"""Illustrations of k-nearest neighbors for lectures/supervised.typ.

Run: python figures/k_plus_proches_voisins.py
Requires NumPy and Matplotlib. No external data or network access is needed.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.lines import Line2D
from matplotlib.patches import Circle
from matplotlib.ticker import FuncFormatter
import numpy as np


GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
COLORS = [GREEN, ORANGE]
MARKERS = ["o", "^"]


def decorate(ax):
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", linewidth=0.6)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=9)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.set_aspect("equal")
    ax.set_xlabel("$x_1$", color=INK)


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def class_legend(include_query=False):
    handles = [Line2D([], [], color=COLORS[g], marker=MARKERS[g], linestyle="none",
                      markersize=6, label=f"Classe {'AB'[g]}") for g in range(2)]
    if include_query:
        handles.append(Line2D([], [], color=INK, marker="*", linestyle="none",
                              markersize=10, label="Point à classer"))
    return handles


def plot_neighbors():
    # First five rows reproduce the distances and labels in the lesson table.
    points = np.array([[0.2, 0], [0, 0.4], [-0.5, 0], [0, -0.7], [0.8, 0.6],
                       [1.5, -0.6], [-1.2, 0.8]])
    labels = np.array([1, 0, 0, 1, 1, 0, 0])
    distances = np.linalg.norm(points, axis=1)
    order = np.argsort(distances, kind="stable")
    np.testing.assert_allclose(distances[:5], [0.2, 0.4, 0.5, 0.7, 1.0])
    offsets = [(8, 10), (8, 9), (-13, 9), (8, -15), (9, 7)]
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.8), sharex=True, sharey=True)
    fig.subplots_adjust(left=0.09, right=0.98, bottom=0.23, top=0.86, wspace=0.15)
    for ax, k in zip(axes, [3, 5]):
        selected = order[:k]
        votes = np.bincount(labels[selected], minlength=2)
        winner = np.argmax(votes)
        assert winner == (0 if k == 3 else 1)
        radius = distances[selected[-1]]
        ax.add_patch(Circle((0, 0), radius, facecolor=COLORS[winner], alpha=0.08,
                            edgecolor="none", zorder=0))
        ax.add_patch(Circle((0, 0), radius, fill=False, edgecolor=INK,
                            linestyle="--", linewidth=1.2, zorder=1))
        for i, point in enumerate(points):
            inside = i in selected
            ax.scatter(*point, s=48, color=COLORS[labels[i]], marker=MARKERS[labels[i]],
                       alpha=1 if inside else 0.4, edgecolors="white",
                       linewidths=0.7, zorder=4)
            if i < 5:
                ax.annotate(str(i + 1), point, xytext=offsets[i],
                            textcoords="offset points", color=INK, fontsize=10)
        ax.scatter(0, 0, s=130, color=INK, marker="*", zorder=5)
        decorate(ax)
        ax.set(xlim=(-1.65, 1.8), ylim=(-1.25, 1.25))
        ax.set_xticks([-1, 0, 1])
        ax.set_yticks([-1, 0, 1])
        ax.set_title(f"$k = {k}$ : classe {'AB'[winner]} ({votes[winner]}/{k} voix)",
                     fontsize=11, color=INK, pad=12)
    axes[0].set_ylabel("$x_2$", color=INK)
    fig.legend(handles=class_legend(True), loc="lower center",
               bbox_to_anchor=(0.5, 0.015), ncol=3, frameon=False, fontsize=10)
    save(fig, "knn_voisinage.svg")


def plot_boundaries():
    rng = np.random.default_rng(2200)
    angle = np.linspace(0, np.pi, 65)
    first = np.column_stack([np.cos(angle), np.sin(angle)])
    second = np.column_stack([1 - np.cos(angle), 0.5 - np.sin(angle)])
    points = np.vstack([first, second]) + rng.normal(0, 0.16, size=(130, 2))
    labels = np.repeat([0, 1], 65)
    flipped = rng.choice(len(points), size=8, replace=False)
    labels[flipped] = 1 - labels[flipped]
    xx, yy = np.meshgrid(np.linspace(-1.55, 2.5, 260), np.linspace(-1.05, 1.6, 180))
    grid = np.column_stack([xx.ravel(), yy.ravel()])
    distances2 = np.sum((grid[:, None, :] - points[None, :, :]) ** 2, axis=2)
    order = np.argsort(distances2, axis=1, kind="stable")
    fig, axes = plt.subplots(1, 3, figsize=(7.4, 3.1), sharex=True, sharey=True)
    fig.subplots_adjust(left=0.075, right=0.985, bottom=0.25, top=0.86, wspace=0.13)
    for ax, k in zip(axes, [1, 9, 51]):
        proportion = labels[order[:, :k]].mean(axis=1).reshape(xx.shape)
        ax.contourf(xx, yy, proportion, levels=[-0.01, 0.5, 1.01],
                    cmap=ListedColormap(["#e6f0eb", "#f5eade"]), zorder=0)
        ax.contour(xx, yy, proportion, levels=[0.5], colors=INK, linewidths=0.8)
        for g in range(2):
            selected = labels == g
            ax.scatter(*points[selected].T, color=COLORS[g], marker=MARKERS[g],
                       s=9, edgecolors="white", linewidths=0.2, zorder=3)
        decorate(ax)
        ax.set(xlim=(-1.55, 2.5), ylim=(-1.05, 1.6))
        ax.set_xticks([-1, 0, 1, 2])
        ax.set_yticks([-1, 0, 1])
        ax.set_title(f"$k = {k}$", color=INK, fontsize=11, pad=10)
    axes[0].set_ylabel("$x_2$", color=INK)
    fig.legend(handles=class_legend(), loc="lower center", bbox_to_anchor=(0.5, 0.01),
               ncol=2, frameon=False, fontsize=10)
    save(fig, "knn_frontieres.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "k-plus-proches-voisins"})
    plot_neighbors()
    plot_boundaries()


if __name__ == "__main__":
    main()
