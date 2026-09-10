"""Generate the PCA teaching figure with NumPy and Matplotlib.

Run from any directory: python figures/acp_principe.py
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import numpy as np


def main():
    rng = np.random.default_rng(24)
    scores = rng.normal(size=(36, 2))
    scores -= scores.mean(axis=0)
    # Make the sample scores exactly orthogonal, with a 9:1 variance ratio.
    scores[:, 1] -= (
        scores[:, 0] @ scores[:, 1] / (scores[:, 0] @ scores[:, 0])
    ) * scores[:, 0]
    scores /= scores.std(axis=0, ddof=1)
    scores *= [1.65, 0.55]
    angle = np.deg2rad(32)
    first = np.array([np.cos(angle), np.sin(angle)])
    second = np.array([-np.sin(angle), np.cos(angle)])
    points = scores @ np.array([first, second])
    projections = scores[:, :1] * first

    ink, green, orange = "#486976", "#347663", "#b77244"
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-principe",
    })
    fig, ax = plt.subplots(figsize=(7.2, 4.6))
    fig.subplots_adjust(left=0.06, right=0.97, top=0.98, bottom=0.12)
    ax.set_aspect("equal")
    ax.set_xlim(-4.5, 4.5)
    ax.set_ylim(-2.9, 2.9)
    ax.axis("off")

    for endpoint in [(4.35, 0), (0, 2.7)]:
        start = (-4.35, 0) if endpoint[1] == 0 else (0, -2.7)
        ax.annotate("", xy=endpoint, xytext=start,
                    arrowprops={"arrowstyle": "->", "color": "#a8b3bb", "lw": 1})
    ax.text(4.35, -0.25, "$x_1$", ha="right", color=ink, fontsize=12)
    ax.text(0.15, 2.63, "$x_2$", color=ink, fontsize=12)

    for point, projection in zip(points, projections):
        ax.plot(*np.array([point, projection]).T,
                color=green, alpha=0.45, lw=0.85, linestyle=(0, (3, 3)), zorder=1)
    for direction, length, color in [(first, 4.15, green), (second, 2.15, orange)]:
        ax.annotate("", xy=length * direction, xytext=-length * direction,
                    arrowprops={"arrowstyle": "<->", "color": color, "lw": 2},
                    zorder=2)

    # Equal aspect ratio preserves the geometric right angle on the page.
    corner = np.array([0.28 * first, 0.28 * (first + second), 0.28 * second])
    ax.plot(*corner.T, color="#74838b", lw=0.9, zorder=3)
    ax.scatter(*projections.T, s=23, facecolors="white", edgecolors=green,
               linewidths=1, zorder=4)
    ax.scatter(*points.T, s=30, color=ink, edgecolors="white",
               linewidths=0.65, zorder=5)
    ax.text(2.7, 2.48, "CP1 · 90 % de la variance", color=green,
            ha="center", fontsize=10, weight="bold")
    ax.text(-1.2, 2.18, "CP2 · 10 %", color=orange,
            ha="center", fontsize=10, weight="bold")

    handles = [
        Line2D([], [], marker="o", linestyle="none", color=ink,
               markersize=5, label="Observations"),
        Line2D([], [], marker="o", linestyle="none", markerfacecolor="white",
               color=green, markersize=5, label="Projections sur CP1"),
        Line2D([], [], color=green, linestyle="--", lw=1,
               label="Écarts à CP1"),
    ]
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.5, 0.01),
               ncol=3, frameon=False, fontsize=9, handlelength=1.6, columnspacing=1.7)
    target = Path(__file__).with_suffix(".svg")
    fig.savefig(target, metadata={"Date": None}, facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    main()
