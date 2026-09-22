"""Generate the k-means figures used in lectures/unsupervised.typ.

Run from the repository root: python figures/k_means.py
Requires NumPy, Matplotlib, Rscript and R's recommended package cluster.
The real-data computations are delegated to codes/k_means.R, with fixed seeds.
All data are local; no downloads are performed.
"""

import csv
from pathlib import Path
import subprocess
import tempfile

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
COLORS = [GREEN, ORANGE]
VARIABLES = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]


def decorate(ax):
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", linewidth=0.6)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=10)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def lloyd(points, initial_centers):
    centers = np.array(initial_centers, dtype=float)
    previous = None
    costs = []
    for _ in range(50):
        distances2 = np.sum((points[:, None, :] - centers[None, :, :]) ** 2, axis=2)
        labels = np.argmin(distances2, axis=1)
        assert all(np.any(labels == g) for g in range(len(centers)))
        centers = np.array([points[labels == g].mean(axis=0) for g in range(len(centers))])
        costs.append(np.sum((points - centers[labels]) ** 2))
        if np.array_equal(previous, labels):
            assert np.all(np.diff(costs) <= 1e-12)
            return labels, centers, costs
        previous = labels.copy()
    raise RuntimeError("Lloyd did not stabilize in the small illustrative example")


def plot_initializations():
    points = np.array([[-2, -1], [-2, 1], [2, -1], [2, 1]], dtype=float)
    initializations = [points[[0, 2]], points[[0, 1]]]
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.7), sharex=True, sharey=True)
    fig.subplots_adjust(left=0.08, right=0.98, bottom=0.22, top=0.85, wspace=0.16)
    for j, (ax, initial) in enumerate(zip(axes, initializations)):
        labels, centers, costs = lloyd(points, initial)
        assert np.isclose(costs[-1], [4, 16][j])
        if j == 0:
            ax.axvspan(-3, 0, color=GREEN, alpha=0.06)
            ax.axvspan(0, 3, color=ORANGE, alpha=0.06)
            ax.axvline(0, color=INK, ls="--", lw=1)
        else:
            ax.axhspan(-2.2, 0, color=GREEN, alpha=0.06)
            ax.axhspan(0, 2.2, color=ORANGE, alpha=0.06)
            ax.axhline(0, color=INK, ls="--", lw=1)
        for g, color in enumerate(COLORS):
            group = points[labels == g]
            for point in group:
                ax.plot([point[0], centers[g, 0]], [point[1], centers[g, 1]],
                        color=color, lw=1.1, zorder=2)
            ax.scatter(*group.T, s=55, color=color, edgecolors="white", zorder=3)
            ax.scatter(*centers[g], s=130, marker="X", color=color,
                       edgecolors="white", linewidths=0.7, zorder=4)
        decorate(ax)
        ax.set_aspect("equal")
        ax.set(xlim=(-3, 3), ylim=(-2.2, 2.2), xlabel="$x_1$")
        ax.set_xticks([-2, 0, 2])
        ax.set_yticks([-1, 0, 1])
        orientation = "Gauche / droite" if j == 0 else "Bas / haut"
        ax.set_title(f"{orientation} · $W = {costs[-1]:g}$", color=INK, fontsize=11, pad=12)
    axes[0].set_ylabel("$x_2$", color=INK)
    handles = [Line2D([], [], marker="o", linestyle="none", color=INK,
                      markersize=6, label="Observation"),
               Line2D([], [], marker="X", linestyle="none", color=INK,
                      markersize=8, label="Centroïde"),
               Line2D([], [], linestyle="--", color=INK, lw=1, label="Frontière")]
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.5, 0.02),
               ncol=3, frameon=False, fontsize=10)
    save(fig, "kmeans_initialisations.svg")


def read_columns(path):
    with path.open() as stream:
        rows = list(csv.DictReader(stream))
    return {name: np.array([float(row[name]) if row[name] != "NA" else np.nan
                            for row in rows]) for name in rows[0]}


def plot_criteria(criteria):
    K = criteria["K"]
    selected = int(K[np.nanargmax(criteria["silhouette"])])
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.8))
    fig.subplots_adjust(left=0.105, right=0.98, bottom=0.20, top=0.90, wspace=0.4)
    for ax in axes:
        decorate(ax)
        ax.set_xlabel("Nombre de groupes $K$", color=INK, labelpad=8)
        ax.axvline(selected, color=ORANGE, ls="--", lw=1.2)
    axes[0].plot(K, criteria["W"], marker="o", color=GREEN, ms=4, lw=1.5)
    axes[0].set(xlim=(0.7, 8.3), ylim=(0, 1500))
    axes[0].set_xticks(K)
    axes[0].set_ylabel("Inertie intra-groupe $W$", color=INK, labelpad=8)
    axes[0].annotate(f"$K = {selected}$ retenu", xy=(selected, criteria["W"][selected-1]),
                     xytext=(3.1, 1000), color=ORANGE, fontsize=10,
                     arrowprops={"arrowstyle": "-", "color": ORANGE, "lw": 0.8})
    axes[1].plot(K[1:], criteria["silhouette"][1:], marker="o", color=GREEN, ms=4, lw=1.5)
    axes[1].set(xlim=(1.7, 8.3), ylim=(0, 0.65))
    axes[1].set_xticks(K[1:])
    axes[1].set_ylabel("Silhouette moyenne", color=INK, labelpad=8)
    axes[1].text(3.1, 0.56, f"Maximum : $K = {selected}$", color=ORANGE, fontsize=10)
    save(fig, "kmeans_choix_k.svg")


def plot_penguins(observations):
    z = np.column_stack([observations[name] for name in VARIABLES])
    labels = observations["groupe"].astype(int)
    _, singular_values, Vt = np.linalg.svd(z, full_matrices=False)
    axes = Vt.T.copy()
    for j in range(axes.shape[1]):
        axes[:, j] *= np.sign(axes[np.argmax(np.abs(axes[:, j])), j])
    scores = z @ axes[:, :2]
    percentages = 100 * singular_values**2 / np.sum(singular_values**2)
    fig, ax = plt.subplots(figsize=(6.4, 4.6))
    fig.subplots_adjust(left=0.13, right=0.98, bottom=0.17, top=0.98)
    decorate(ax)
    ax.set_aspect("equal")
    for g, color, marker in zip([1, 2], COLORS, ["o", "^"]):
        selected = labels == g
        centroid = z[selected].mean(axis=0) @ axes[:, :2]
        np.testing.assert_allclose(centroid, scores[selected].mean(axis=0), atol=1e-12)
        ax.scatter(*scores[selected].T, s=21, marker=marker, color=color, alpha=0.8,
                   edgecolors="white", linewidths=0.3, label=f"Groupe {g} (n = {selected.sum()})")
        ax.scatter(*centroid, s=160, marker="X", color=color, edgecolors="white",
                   linewidths=1, zorder=5)
    for j, setter in enumerate([ax.set_xlabel, ax.set_ylabel]):
        percent = f"{percentages[j]:.2f}".replace(".", ",")
        setter(f"CP{j + 1} · {percent} % de la variance totale", color=INK, labelpad=8)
    ax.set(xlim=(-3.1, 4.1), ylim=(-2.6, 3.1))
    ax.legend(loc="upper right", frameon=False, fontsize=10)
    save(fig, "kmeans_palmerpenguins.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "k-means-course"})
    # Check the hand-worked one-dimensional Lloyd example from the lesson.
    labels, centers, costs = lloyd(np.array([0, 1, 2, 8, 9, 10])[:, None], [[0], [2]])
    np.testing.assert_allclose(costs[:2], [39.25, 4])
    np.testing.assert_allclose(centers[:, 0], [1, 9])
    plot_initializations()
    with tempfile.TemporaryDirectory(prefix="course-kmeans-") as directory:
        subprocess.run(["Rscript", str(ROOT / "codes" / "k_means.R"), directory],
                        cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
        plot_criteria(read_columns(Path(directory) / "criteres.csv"))
        plot_penguins(read_columns(Path(directory) / "observations.csv"))


if __name__ == "__main__":
    main()
