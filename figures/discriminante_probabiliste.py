"""Illustrate a QDA decision based on unequal variances and equal means.

Run from the repository root: python figures/discriminante_probabiliste.py
Requires NumPy and Matplotlib. The curves are population model quantities,
not estimates from simulated observations.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import numpy as np


GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "qda-variances"})
    x = np.linspace(-4.5, 4.5, 1001)
    density1 = np.exp(-x**2 / 2) / np.sqrt(2 * np.pi)
    density2 = np.exp(-x**2 / 8) / (2 * np.sqrt(2 * np.pi))
    difference = -np.log(2) + 3 * x**2 / 8
    posterior2 = 1 / (1 + np.exp(-difference))
    boundary = np.sqrt(8 * np.log(2) / 3)
    np.testing.assert_allclose(posterior2, density2 / (density1 + density2), atol=1e-14)
    np.testing.assert_allclose(-np.log(2) + 3 * boundary**2 / 8, 0, atol=1e-14)

    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.9))
    fig.subplots_adjust(left=0.085, right=0.99, bottom=0.20, top=0.88, wspace=0.32)
    for ax in axes:
        ax.set_axisbelow(True)
        ax.grid(color="#e8edef", lw=0.6)
        for spine in ax.spines.values():
            spine.set_visible(False)
        ax.tick_params(length=0, colors=INK, labelsize=9)
        formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
        ax.xaxis.set_major_formatter(formatter)
        ax.yaxis.set_major_formatter(formatter)
        ax.set_xlim(-4.5, 4.5)
        ax.set_xticks([-4, -2, 0, 2, 4])
        ax.set_xlabel("Mesure $x$", color=INK, labelpad=8)
        ax.axvspan(-4.5, -boundary, color=ORANGE, alpha=0.07)
        ax.axvspan(-boundary, boundary, color=GREEN, alpha=0.07)
        ax.axvspan(boundary, 4.5, color=ORANGE, alpha=0.07)
        for threshold in [-boundary, boundary]:
            ax.axvline(threshold, color=INK, lw=0.9, ls=":")
    axes[0].plot(x, density1, color=GREEN, lw=1.8, label="Classe 1 · variance 1")
    axes[0].plot(x, density2, color=ORANGE, lw=1.8, label="Classe 2 · variance 4")
    axes[0].set_ylim(0, 0.49)
    axes[0].set_ylabel("Densité conditionnelle", color=INK)
    axes[0].set_title("Même moyenne : 0", color=INK, fontsize=11, pad=10)
    axes[0].legend(loc="upper right", frameon=False, fontsize=8.5)
    axes[1].plot(x, posterior2, color=ORANGE, lw=1.8, label="QDA")
    axes[1].axhline(0.5, color=INK, lw=1.3, ls="--", label="LDA : 0,5 partout")
    axes[1].set_ylim(0, 1.04)
    axes[1].set_ylabel("Probabilité de la classe 2", color=INK)
    axes[1].set_title("Probabilités a priori égales", color=INK, fontsize=11, pad=10)
    axes[1].legend(loc="lower center", frameon=False, fontsize=9)
    for ax, y in [(axes[0], 0.03), (axes[1], 0.93)]:
        ax.text(0, y, "Classe 1", color=GREEN, ha="center", fontsize=9)
        ax.text(-3.15, y, "Classe 2", color=ORANGE, ha="center", fontsize=9)
        ax.text(3.15, y, "Classe 2", color=ORANGE, ha="center", fontsize=9)
    fig.savefig(Path(__file__).with_name("qda_variances.svg"), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


if __name__ == "__main__":
    main()
