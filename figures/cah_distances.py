"""Distances entre groupes et coût de Ward sur les mêmes nuages en deux dimensions.

Depuis la racine : python figures/cah_distances.py (NumPy et Matplotlib).
Les données sont fictives ; les distances et les inerties sont calculées ici.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.ticker import FuncFormatter
import numpy as np


OUT = Path(__file__).resolve().parent
GREEN, ORANGE, INK = "#347663", "#b77244", "#486976"
A = np.array([[0.5, 0.7], [0.8, 2.6], [2.0, 1.2]])
B = np.array([[3.5, 0.8], [4.0, 2.7], [5.2, 0.5], [5.3, 2.0]])


def french(value):
    return f"{value:.2f}".replace(".", ",")


def hull(points):
    """Enveloppe convexe, pour repérer visuellement les groupes."""
    points = sorted(map(tuple, points))

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    def chain(sequence):
        result = []
        for point in sequence:
            while len(result) >= 2 and cross(result[-2], result[-1], point) <= 0:
                result.pop()
            result.append(point)
        return result

    return np.array(chain(points)[:-1] + chain(reversed(points))[:-1])


def prepare(ax, title, merged=False):
    ax.set(xlim=(0, 6), ylim=(0, 3.4), xticks=[0, 2, 4, 6], yticks=[0, 1, 2, 3])
    ax.set_aspect("equal", adjustable="box")
    ax.set_axisbelow(True)
    ax.grid(color="#e8edef", lw=0.65)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(length=0, colors=INK, labelsize=9)
    formatter = FuncFormatter(lambda value, _: f"{value:g}".replace(".", ","))
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.set_xlabel("$x_1$", color=INK, labelpad=3)
    ax.set_ylabel("$x_2$", color=INK, labelpad=3)
    ax.set_title(title, color=INK, fontsize=11, pad=12)

    clouds = [(np.vstack([A, B]), INK)] if merged else [(A, GREEN), (B, ORANGE)]
    for points, color in clouds:
        ax.add_patch(Polygon(hull(points), facecolor=color, edgecolor=color,
                             alpha=0.09, lw=1, zorder=1))
    for points, color in [(A, GREEN), (B, ORANGE)]:
        ax.scatter(points[:, 0], points[:, 1], s=30, color=color,
                   edgecolors="white", linewidths=0.65, zorder=4)
    if merged:
        ax.text(3, 3.08, "Groupe réuni : 7 points", ha="center", color=INK, fontsize=9)
    else:
        ax.text(1.1, 3.08, "A : 3 points", ha="center", color=GREEN, fontsize=9)
        ax.text(4.5, 3.08, "B : 4 points", ha="center", color=ORANGE, fontsize=9)


def segment(ax, a, b, **kwargs):
    ax.plot([a[0], b[0]], [a[1], b[1]], **kwargs)


def center(ax, point, label, color, offset):
    ax.scatter(*point, marker="*", s=150, color=color, edgecolors="white",
               linewidths=0.6, zorder=6)
    ax.annotate(label, point, xytext=offset, textcoords="offset points",
                color=color, fontsize=11, ha="center", va="center", zorder=7,
                bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.85, "pad": 0.5})


def footer(ax, text):
    ax.text(0.5, -0.38, text, transform=ax.transAxes, ha="center",
            va="center", fontsize=10, color=INK)


def canvas():
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.35))
    fig.subplots_adjust(left=0.065, right=0.985, bottom=0.27, top=0.85, wspace=0.24)
    return fig, axes


def save(fig, name):
    fig.savefig(OUT / name, facecolor="white", metadata={"Date": None})
    plt.close(fig)


def extreme_distances(distances):
    fig, axes = canvas()
    for ax, title, selector, description in [
        (axes[0], "Liaison simple", np.argmin, "Distance minimale"),
        (axes[1], "Liaison complète", np.argmax, "Distance maximale"),
    ]:
        prepare(ax, title)
        i, j = np.unravel_index(selector(distances), distances.shape)
        segment(ax, A[i], B[j], color=INK, lw=2.2, zorder=3)
        ax.scatter(*np.vstack([A[i], B[j]]).T, s=65, facecolors="none",
                   edgecolors=INK, linewidths=1.1, zorder=5)
        footer(ax, f"{description} : {french(distances[i, j])}")
    save(fig, "cah_distances_extremes.svg")


def average_and_centroids(distances, mu_a, mu_b):
    fig, axes = canvas()
    prepare(axes[0], "Liaison moyenne")
    for a in A:
        for b in B:
            segment(axes[0], a, b, color=INK, lw=0.85, alpha=0.55, zorder=2)
    footer(axes[0], f"12 distances, moyenne : {french(distances.mean())}")

    prepare(axes[1], "Liaison par centroïdes")
    segment(axes[1], mu_a, mu_b, color=INK, lw=2.2, zorder=3)
    center(axes[1], mu_a, r"$\bar{x}_A$", GREEN, (-1, 17))
    center(axes[1], mu_b, r"$\bar{x}_B$", ORANGE, (0, -19))
    footer(axes[1], f"Distance entre centres : {french(np.linalg.norm(mu_a - mu_b))}")
    save(fig, "cah_distances_moyennes.svg")


def ward(mu_a, mu_b, mu_all, before, after):
    fig, axes = canvas()
    prepare(axes[0], "Ward : avant la fusion")
    for points, mu, color in [(A, mu_a, GREEN), (B, mu_b, ORANGE)]:
        for point in points:
            segment(axes[0], point, mu, color=color, lw=1.3, zorder=2)
    center(axes[0], mu_a, r"$\bar{x}_A$", GREEN, (-1, 17))
    center(axes[0], mu_b, r"$\bar{x}_B$", ORANGE, (0, -19))
    footer(axes[0], f"$W(A)+W(B)$ = {french(before)}")

    prepare(axes[1], "Ward : après la fusion", merged=True)
    for points, color in [(A, GREEN), (B, ORANGE)]:
        for point in points:
            segment(axes[1], point, mu_all, color=color, lw=1.3, alpha=0.85, zorder=2)
    center(axes[1], mu_all, r"$\bar{x}_{A\cup B}$", INK, (0, 21))
    footer(axes[1], f"$W(A\\cup B)$ ≈ {french(after)}")
    save(fig, "cah_ward_inertie.svg")


def main():
    plt.rcParams.update({
        "font.family": "DejaVu Sans", "font.size": 10,
        "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
        "svg.hashsalt": "cah-distances",
    })
    distances = np.linalg.norm(A[:, None, :] - B[None, :, :], axis=2)
    mu_a, mu_b = A.mean(axis=0), B.mean(axis=0)
    merged = np.vstack([A, B])
    mu_all = merged.mean(axis=0)
    before = np.sum((A - mu_a)**2) + np.sum((B - mu_b)**2)
    after = np.sum((merged - mu_all)**2)
    delta = len(A) * len(B) / len(merged) * np.sum((mu_a - mu_b)**2)

    assert np.unravel_index(np.argmin(distances), distances.shape) == (2, 0)
    assert np.unravel_index(np.argmax(distances), distances.shape) == (0, 3)
    np.testing.assert_allclose([distances.min()**2, distances.max()**2], [2.41, 24.73])
    np.testing.assert_allclose(np.linalg.norm(mu_a - mu_b), 3.4)
    np.testing.assert_allclose(before, 8.76)
    np.testing.assert_allclose(after - before, delta)
    np.testing.assert_allclose(mu_all, (len(A) * mu_a + len(B) * mu_b) / len(merged))

    extreme_distances(distances)
    average_and_centroids(distances, mu_a, mu_b)
    ward(mu_a, mu_b, mu_all, before, after)
    print(f"Simple : {distances.min():.6f} ; complète : {distances.max():.6f}")
    print(f"Moyenne : {distances.mean():.6f} ; centroïdes : {np.linalg.norm(mu_a - mu_b):.6f}")
    print(f"W avant : {before:.6f} ; W après : {after:.6f} ; variation : {delta:.6f}")
    print("Trois figures générées ; distances et identité de Ward vérifiées.")


if __name__ == "__main__":
    main()
