"""Generate the correlation circle for the two-exam PCA example.

Run from the repository root: python figures/acp_cercle_correlations.py
Requires NumPy and Matplotlib.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Arc, Circle
from matplotlib.ticker import FuncFormatter
import numpy as np


def main():
    eigenvalues = np.array([1.8, 0.2])
    directions = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
    correlations = directions * np.sqrt(eigenvalues)
    np.testing.assert_allclose(np.sum(correlations ** 2, axis=1), [1, 1])
    np.testing.assert_allclose(correlations[0] @ correlations[1], 0.8)
    half_angle = np.degrees(np.arctan2(correlations[0, 1], correlations[0, 0]))

    ink, green, orange = "#486976", "#347663", "#b77244"
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-cercle-correlations",
    })
    fig, ax = plt.subplots(figsize=(5.4, 4.8))
    fig.subplots_adjust(left=0.15, right=0.97, bottom=0.15, top=0.97)
    ax.set_aspect("equal")
    ax.set_xlim(-1.2, 1.3)
    ax.set_ylim(-1.2, 1.2)
    ax.set_xticks([-1, -0.5, 0, 0.5, 1])
    ax.set_yticks([-1, -0.5, 0, 0.5, 1])
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.grid(color="#e8edef", lw=0.6, zorder=0)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, labelsize=9, colors="#74838b")
    ax.axhline(0, color="#acb9c0", lw=0.8, zorder=1)
    ax.axvline(0, color="#acb9c0", lw=0.8, zorder=1)
    ax.add_patch(Circle((0, 0), 1, fill=False, edgecolor=ink, lw=1.2, zorder=2))

    for point, label, color, label_y in [
        (correlations[0], "Intermédiaire\n$Z_1$", green, 0.67),
        (correlations[1], "Final\n$Z_2$", orange, -0.67),
    ]:
        ax.annotate("", xy=point, xytext=(0, 0),
                    arrowprops={"arrowstyle": "->", "color": color, "lw": 2}, zorder=4)
        ax.scatter(*point, s=24, color=color, zorder=5)
        ax.annotate(label, xy=point, xytext=(0.9, label_y),
                    ha="center", va="center", color=color, fontsize=11,
                    bbox={"facecolor": "white", "edgecolor": "none", "pad": 1},
                    arrowprops={"arrowstyle": "-", "color": color, "lw": 0.7,
                                "shrinkA": 4, "shrinkB": 4}, zorder=6)

    ax.add_patch(Arc((0, 0), 0.8, 0.8, theta1=-half_angle, theta2=half_angle,
                     color=ink, lw=1, zorder=4))
    ax.text(0.5, 0, r"$\approx 37^\circ$", ha="left", va="center", color=ink,
            fontsize=10, bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.5})
    ax.set_xlabel("Corrélation avec $Y_1$ · 90 %", color=ink, labelpad=8)
    ax.set_ylabel("Corrélation avec $Y_2$ · 10 %", color=ink, labelpad=8)
    fig.savefig(Path(__file__).with_suffix(".svg"), metadata={"Date": None}, facecolor="white")
    plt.close(fig)
    print(f"Corrélations : {correlations.round(6).tolist()}; angle : {2 * half_angle:.3f} degrés.")


if __name__ == "__main__":
    main()
