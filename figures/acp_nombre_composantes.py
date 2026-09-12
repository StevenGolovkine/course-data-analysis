"""Plot the component-selection rules for the six-variable PCA example.

Run from the repository root: python figures/acp_nombre_composantes.py
Requires NumPy and Matplotlib.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter, PercentFormatter
import numpy as np


def main():
    eigenvalues = np.array([3.0, 1.5, 0.9, 0.3, 0.2, 0.1])
    ranks = np.arange(1, len(eigenvalues) + 1)
    cumulative = np.cumsum(eigenvalues) / eigenvalues.sum()
    kaiser = int(np.count_nonzero(eigenvalues > 1))
    jolliffe = int(np.count_nonzero(eigenvalues > 0.7))
    targets = [0.80, 0.90, 0.95]
    # Include equality at a threshold, allowing for floating-point rounding.
    choices = [int(np.flatnonzero(cumulative >= target - 1e-12)[0] + 1)
               for target in targets]
    elbow_rank = 4  # Visual elbow rank k; retaining through this rank gives q = k.
    elbow_count = elbow_rank
    np.testing.assert_allclose(eigenvalues.sum(), 6)
    np.testing.assert_allclose(cumulative, [0.50, 0.75, 0.90, 0.95, 59 / 60, 1])
    assert (kaiser, jolliffe, choices) == (2, 3, [3, 3, 4])

    ink, orange, green, purple = "#486976", "#b77244", "#347663", "#7a619a"
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "acp-nombre-composantes",
    })
    fig, axes = plt.subplots(1, 2, figsize=(8, 5.25))
    fig.subplots_adjust(left=0.09, right=0.975, top=0.9, bottom=0.36, wspace=0.32)
    for ax in axes:
        ax.set_xlim(0.75, 6.25)
        ax.set_xticks(ranks)
        ax.grid(axis="y", color="#e8edef", lw=0.7, zorder=0)
        ax.spines[["top", "right"]].set_visible(False)
        ax.spines[["left", "bottom"]].set_color("#bdc8ce")
        ax.tick_params(length=3, color="#bdc8ce", labelcolor=ink, labelsize=9)
        ax.set_axisbelow(True)

    ax = axes[0]
    ax.set_title("Valeurs propres", fontsize=12, color=ink, pad=12)
    ax.set_ylim(0, 3.3)
    ax.set_yticks([0, 0.5, 1, 1.5, 2, 2.5, 3])
    ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}".replace(".", ",")))
    ax.set_xlabel("Rang de la composante $k$", color=ink, labelpad=8)
    ax.set_ylabel("Valeur propre $\\lambda_k$", color=ink, labelpad=6)
    ax.plot(ranks, eigenvalues, "o-", color=ink, lw=1.8, ms=4.5, zorder=3)
    for threshold, q, color, style in [(1, kaiser, orange, "--"), (0.7, jolliffe, green, ":")]:
        ax.axhline(threshold, color=color, linestyle=style, lw=1.1, zorder=2)
        ax.text(6.1, threshold, f"$\\lambda_k = {threshold:g}$".replace("0.7", "0{,}7"),
                color=color, ha="right", va="center", fontsize=9,
                bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.5})
        ax.vlines(q, 0, eigenvalues[q - 1], color=color, linestyle=style, lw=1, zorder=2)
        ax.scatter(q, eigenvalues[q - 1], s=65, color=color, edgecolors="white", lw=0.7, zorder=4)
    ax.vlines(elbow_rank, 0, eigenvalues[elbow_rank - 1], color=ink, linestyle="--", lw=1, zorder=2)
    ax.scatter(elbow_rank, eigenvalues[elbow_rank - 1], s=65, color=ink, edgecolors="white", lw=0.7, zorder=4)
    ax.annotate(f"Coude au rang $k = {elbow_rank}$\nChoix : $q = {elbow_count}$",
                xy=(elbow_rank, eigenvalues[elbow_rank - 1]),
                xytext=(4.35, 2.35), ha="center", color=ink, fontsize=10,
                arrowprops={"arrowstyle": "->", "color": ink, "lw": 0.9,
                            "shrinkB": 7})

    ax = axes[1]
    ax.set_title("Variance expliquée cumulée", fontsize=12, color=ink, pad=12)
    ax.set_ylim(0.40, 1.055)
    ax.set_yticks([0.50, 0.60, 0.70, 0.80, 0.90, 1])
    ax.yaxis.set_major_formatter(PercentFormatter(xmax=1, decimals=0))
    ax.set_xlabel("Nombre de composantes $q$", color=ink, labelpad=8)
    ax.set_ylabel("Cumul $R_q$", color=ink, labelpad=6)
    ax.plot(ranks, cumulative, "o-", color=ink, lw=1.8, ms=4.5, zorder=3)
    for target, style, color in [(0.80, ":", green), (0.90, "--", green), (0.95, "-.", purple)]:
        ax.axhline(target, color=color, lw=1, linestyle=style, zorder=2)
        ax.text(1.0, target, f"{target:.0%}".replace("%", " %"), color=color,
                ha="left", va="center", fontsize=9,
                bbox={"facecolor": "white", "edgecolor": "none", "pad": 1.5})
    for q, color in [(choices[0], green), (choices[2], purple)]:
        ax.vlines(q, 0.40, cumulative[q - 1], color=color, linestyle="--", lw=1, zorder=2)
        ax.scatter(q, cumulative[q - 1], s=65, color=color, edgecolors="white", lw=0.7, zorder=4)

    left_choices = [
        (f"Kaiser ($\\lambda_k > 1$) : $q = {kaiser}$", orange),
        (f"Jolliffe ($\\lambda_k > 0{{,}}7$) : $q = {jolliffe}$", green),
        (f"Coude illustratif : $q = {elbow_count}$", ink),
    ]
    right_choices = [
        (f"Seuil de {target:.0%} : $q = {q}$".replace("%", " %"), green if q == 3 else purple)
        for target, q in zip(targets, choices)
    ]
    for ax, labels in zip(axes, [left_choices, right_choices]):
        left = ax.get_position().x0
        for height, (label, color) in zip([0.215, 0.153, 0.091], labels):
            fig.text(left, height, label, color=color, fontsize=10, va="center")

    fig.savefig(Path(__file__).with_suffix(".svg"), metadata={"Date": None}, facecolor="white")
    plt.close(fig)
    print(f"Kaiser : {kaiser}; Jolliffe : {jolliffe}; seuils 80 %, 90 %, 95 % : {choices}.")


if __name__ == "__main__":
    main()
