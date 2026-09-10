"""Generate the inertia teaching figure with NumPy and Matplotlib.

Run from the repository root: python figures/acp_inertie.py
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def main():
    # Symmetry places the centroid at the origin.
    points = np.array([
        [sx * x, sy * y]
        for x, y in [(4, 3), (5, 1), (np.sqrt(7), np.sqrt(2))]
        for sx in [-1, 1]
        for sy in [-1, 1]
    ])
    center = points.mean(axis=0)
    selected = np.array([4.0, 3.0])
    ink = "#486976"
    pale = "#bdc8ce"
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-inertie",
    })
    fig, ax = plt.subplots(figsize=(5.4, 3.7))
    fig.subplots_adjust(left=0.02, right=0.98, bottom=0.04, top=0.96)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-6, 6)
    ax.set_ylim(-4.1, 4.1)
    for point in points:
        ax.plot(*np.array([center, point]).T, color=pale, lw=1, zorder=1)
    ax.scatter(*points.T, s=32, color=ink, edgecolors="white", linewidths=0.6, zorder=3)
    ax.plot([0, selected[0]], [0, selected[1]], color=ink, lw=2, zorder=2)
    ax.scatter(*center, marker="+", s=110, color="#24313a", linewidths=1.8, zorder=4)
    ax.text(0, -0.45, "$g$ : centre", ha="center", va="top", fontsize=10, color=ink,
            bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.5})
    ax.text(4.3, 3.12, "$z_i$", fontsize=11, color=ink)
    ax.text(1.15, 1.5, "$d_i$", color=ink, fontsize=12,
            bbox={"facecolor": "white", "edgecolor": "none", "pad": 1})

    target = Path(__file__).with_suffix(".svg")
    fig.savefig(target, metadata={"Date": None}, facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    main()
