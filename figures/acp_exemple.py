"""Generate the two-variable PCA example figures using NumPy and Matplotlib.

Run from the repository root: python figures/acp_exemple.py
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import numpy as np


INK = "#486976"
GREEN = "#347663"
ORANGE = "#b77244"
DARK = "#24313a"
PROFILES = [(40, "A", GREEN, "^"), (41, "B", ORANGE, "D"), (44, "C", DARK, "s")]


def make_data():
    """Include A, B and C in a centered sample with exactly the stated covariance."""
    rng = np.random.default_rng(21)
    raw = rng.normal(size=(40, 2))
    raw -= raw.mean(axis=0)
    orthogonal, _ = np.linalg.qr(raw)
    directions = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
    # A, B, -A and -B contribute 4 to each principal sum of squares.
    # With 45 observations, the target sums are 44 * (1.8, 0.2).
    background_scores = orthogonal * np.sqrt(np.array([79.2, 8.8]) - 4)
    background = background_scores @ directions.T
    profiles = np.array([[1, 1], [1, -1], [-1, -1], [-1, 1], [0, 0]])
    points = np.vstack([background, profiles])
    scores = points @ directions
    np.testing.assert_allclose(points.mean(axis=0), 0, atol=1e-12)
    np.testing.assert_allclose(np.cov(points, rowvar=False), [[1, 0.8], [0.8, 1]], atol=1e-12)
    np.testing.assert_allclose(np.cov(scores, rowvar=False), np.diag([1.8, 0.2]), atol=1e-12)
    return points, scores, directions


def setup_axes(ax, extent, xlabel, ylabel):
    ax.set_aspect("equal")
    ax.set_xlim(-extent, extent)
    ax.set_ylim(-extent, extent)
    ax.set_xticks(np.arange(-3, 4))
    ax.set_yticks(np.arange(-3, 4))
    ax.grid(color="#e8edef", lw=0.6, zorder=0)
    ax.axhline(0, color="#acb9c0", lw=0.85, zorder=1)
    ax.axvline(0, color="#acb9c0", lw=0.85, zorder=1)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, labelsize=9, colors="#74838b")
    ax.set_xlabel(xlabel, fontsize=11, labelpad=7, color=INK)
    ax.set_ylabel(ylabel, fontsize=11, labelpad=6, color=INK)


def draw_points(ax, points, offsets=None):
    ordinary = np.ones(len(points), dtype=bool)
    ordinary[[item[0] for item in PROFILES]] = False
    ax.scatter(*points[ordinary].T, s=23, color=INK, edgecolors="white",
               linewidths=0.5, alpha=0.85, zorder=3)
    offsets = offsets or {"A": (-23, 19), "B": (8, -18), "C": (-28, 12)}
    for index, name, color, marker in PROFILES:
        ax.scatter(*points[index], s=65, color=color, marker=marker,
                   edgecolors="white", linewidths=0.7, zorder=6)
        ax.annotate(name, points[index], xytext=offsets[name], textcoords="offset points",
                    fontsize=11, weight="bold", color=color, zorder=7,
                    bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
                    arrowprops={"arrowstyle": "-", "color": color, "lw": 0.7,
                                "shrinkA": 2, "shrinkB": 5})


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), metadata={"Date": None}, facecolor="white")
    plt.close(fig)


def main():
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-exemple",
    })
    points, scores, directions = make_data()
    extent = max(3.3, np.ceil(2 * np.max(np.abs(np.vstack([points, scores])))) / 2 + 0.2)

    fig, axes = plt.subplots(1, 2, figsize=(7.8, 4.05))
    fig.subplots_adjust(left=0.08, right=0.98, bottom=0.16, top=0.95, wspace=0.33)
    setup_axes(axes[0], extent, "$Z_1$ · note standardisée", "$Z_2$ · note standardisée")
    setup_axes(axes[1], extent, "$Y_1$ · 90 % de la variance", "$Y_2$ · 10 % de la variance")
    for k, color in [(0, GREEN), (1, ORANGE)]:
        endpoint = 0.82 * extent * np.sqrt(2) * directions[:, k]
        axes[0].annotate("", xy=endpoint, xytext=-endpoint,
                         arrowprops={"arrowstyle": "<->", "color": color, "lw": 1.4}, zorder=2)
        offset = (0, 8) if k == 0 else (0, -16)
        axes[0].annotate(f"CP{k + 1}", endpoint, xytext=offset, textcoords="offset points",
                         ha="center", color=color, fontsize=10, weight="bold")
    draw_points(axes[0], points)
    draw_points(axes[1], scores, {"A": (8, 12), "B": (8, 10), "C": (-28, -28)})
    save(fig, "acp_exemple_reperes.svg")

    reconstructed = np.outer(scores[:, 0], directions[:, 0])
    np.testing.assert_allclose(reconstructed[[40, 41, 44]], [[1, 1], [0, 0], [0, 0]], atol=1e-12)
    np.testing.assert_allclose(np.sum((points - reconstructed) ** 2) / (len(points) - 1), 0.2)
    fig, ax = plt.subplots(figsize=(5.6, 5.1))
    fig.subplots_adjust(left=0.13, right=0.96, bottom=0.21, top=0.96)
    setup_axes(ax, extent, "$Z_1$ · note standardisée", "$Z_2$ · note standardisée")
    for point, projected in zip(points, reconstructed):
        ax.plot(*np.array([point, projected]).T, color=GREEN, lw=0.8,
                alpha=0.35, linestyle=(0, (3, 3)), zorder=2)
    ax.plot([-extent, extent], [-extent, extent], color=GREEN, lw=1.8, zorder=2)
    ax.text(0.73 * extent, 0.84 * extent, "CP1", ha="center", color=GREEN, weight="bold")
    ax.scatter(*reconstructed.T, s=23, facecolors="white", edgecolors=GREEN,
               linewidths=0.8, zorder=4)
    ax.plot([1, 0], [-1, 0], color=ORANGE, lw=2, linestyle=(0, (4, 3)), zorder=5)
    draw_points(ax, points)
    handles = [
        Line2D([], [], marker="o", linestyle="none", color=INK, markersize=4.5,
               label="Observations"),
        Line2D([], [], marker="o", linestyle="none", color=GREEN, markerfacecolor="white",
               markersize=4.5, label="Reconstructions"),
    ]
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.53, 0.025),
               ncol=2, frameon=False, fontsize=9)
    save(fig, "acp_exemple_projection.svg")
    print("45 observations : variances 1 et 1, corrélation 0,8; composantes de variances 1,8 et 0,2.")


if __name__ == "__main__":
    main()
