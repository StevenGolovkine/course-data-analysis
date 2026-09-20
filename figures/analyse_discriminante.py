"""Generate the two synthetic illustrations for lectures/supervised.typ.

Run from the repository root: python figures/analyse_discriminante.py
Requires NumPy and Matplotlib. The random seed is fixed for reproducibility.
The figures illustrate geometry, not performance on an independent test set.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.lines import Line2D
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


def save(fig, name):
    fig.savefig(Path(__file__).with_name(name), facecolor="white",
                metadata={"Date": None})
    plt.close(fig)


def normal_density(x, mean, sd):
    return np.exp(-0.5 * ((x - mean) / sd) ** 2) / (sd * np.sqrt(2 * np.pi))


def plot_fisher():
    rng = np.random.default_rng(2200)
    means = np.array([[0.0, -1.0], [0.0, 1.0]])
    covariance = np.diag([9.0, 0.25])
    samples = [rng.multivariate_normal(mu, covariance, 90) for mu in means]
    fig = plt.figure(figsize=(7.4, 4.5))
    grid = fig.add_gridspec(2, 2, width_ratios=[1.25, 1],
                           left=0.08, right=0.98, bottom=0.20, top=0.91,
                           wspace=0.35, hspace=0.9)
    cloud = fig.add_subplot(grid[:, 0])
    pca = fig.add_subplot(grid[0, 1])
    fisher = fig.add_subplot(grid[1, 1])
    for ax in [cloud, pca, fisher]:
        decorate(ax)
    for g, sample in enumerate(samples):
        cloud.scatter(*sample.T, s=14, color=COLORS[g], marker=MARKERS[g],
                      alpha=0.65, edgecolors="none")
    cloud.annotate("", xy=(6, 0), xytext=(-6, 0),
                   arrowprops={"arrowstyle": "<->", "color": INK, "lw": 1.5})
    cloud.text(6.1, 0.08, "ACP", color=INK, fontsize=10)
    cloud.annotate("", xy=(0, 2.7), xytext=(0, -2.7),
                   arrowprops={"arrowstyle": "<->", "color": INK, "lw": 1.5})
    cloud.text(0.5, 2.45, "Fisher", color=INK, fontsize=10)
    cloud.set(xlim=(-9.5, 9.5), ylim=(-3.2, 3.2), xlabel="$x_1$", ylabel="$x_2$")
    cloud.set_title("Deux classes connues", color=INK, fontsize=11, pad=10)
    for ax, dim, title in [(pca, 0, "Projection sur $x_1$ (ACP)"),
                           (fisher, 1, "Projection sur $x_2$ (Fisher)")]:
        xx = np.linspace(-9.5, 9.5, 500) if dim == 0 else np.linspace(-3.2, 3.2, 500)
        for g in range(2):
            density = normal_density(xx, means[g, dim], np.sqrt(covariance[dim, dim]))
            ax.fill_between(xx, density, color=COLORS[g], alpha=0.12)
            ax.plot(xx, density, color=COLORS[g], lw=1.8,
                    linestyle="--" if dim == 0 and g == 1 else "-")
        ax.set_xlim(xx[0], xx[-1])
        ax.set_ylim(bottom=0)
        ax.set_ylabel("Densité", fontsize=9, color=INK)
        ax.set_title(title, fontsize=11, color=INK, pad=8)
        ax.set_xlabel(f"Score $x_{dim + 1}$", fontsize=9, color=INK)
    handles = [Line2D([], [], marker=MARKERS[g], color=COLORS[g], linestyle="none",
                      label=f"Classe {g + 1}", markersize=6) for g in range(2)]
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.5, 0.015),
               ncol=2, frameon=False, fontsize=10)
    save(fig, "discriminante_fisher.svg")


def gaussian_scores(x, means, covariances, priors):
    scores = []
    for mu, covariance, prior in zip(means, covariances, priors):
        sign, logdet = np.linalg.slogdet(covariance)
        assert sign > 0
        centered = x - mu
        quadratic = np.sum(centered * np.linalg.solve(covariance, centered.T).T, axis=1)
        scores.append(-0.5 * (logdet + quadratic) + np.log(prior))
    return np.column_stack(scores)


def plot_lda_qda():
    rng = np.random.default_rng(2210)
    means = np.array([[-1.0, 0.0], [1.0, 0.0]])
    covariances = np.array([[[0.6, 0.25], [0.25, 1.5]],
                            [[1.5, -0.5], [-0.5, 0.4]]])
    samples = [rng.multivariate_normal(mu, cov, 80) for mu, cov in zip(means, covariances)]
    fitted_means = np.array([x.mean(axis=0) for x in samples])
    fitted_covariances = np.array([np.cov(x.T, ddof=1) for x in samples])
    # Equal group sizes make the pooled covariance their arithmetic mean.
    pooled = fitted_covariances.mean(axis=0)
    priors = np.array([0.5, 0.5])
    xx, yy = np.meshgrid(np.linspace(-4.5, 5.5, 300), np.linspace(-4.0, 4.0, 250))
    points = np.column_stack([xx.ravel(), yy.ravel()])
    fig, axes = plt.subplots(1, 2, figsize=(7.4, 3.9), sharex=True, sharey=True)
    fig.subplots_adjust(left=0.08, right=0.99, bottom=0.22, top=0.88, wspace=0.15)
    for ax, covs, title in zip(axes, [[pooled, pooled], fitted_covariances],
                               ["LDA : covariance commune", "QDA : covariances distinctes"]):
        scores = gaussian_scores(points, fitted_means, covs, priors)
        difference = (scores[:, 1] - scores[:, 0]).reshape(xx.shape)
        regions = (difference > 0).astype(int)
        ax.contourf(xx, yy, regions, levels=[-0.5, 0.5, 1.5],
                    cmap=ListedColormap(["#e6f0eb", "#f5eade"]), zorder=0)
        ax.contour(xx, yy, difference, levels=[0], colors=INK, linewidths=1.6)
        for g, sample in enumerate(samples):
            ax.scatter(*sample.T, color=COLORS[g], marker=MARKERS[g], s=14,
                       alpha=0.75, edgecolors="white", linewidths=0.3, zorder=3)
        decorate(ax)
        ax.set(xlim=(-4.5, 5.5), ylim=(-4, 4), xlabel="$x_1$")
        ax.set_aspect("equal")
        ax.set_title(title, fontsize=10.5, color=INK, pad=10)
    axes[0].set_ylabel("$x_2$")
    handles = [Line2D([], [], marker=MARKERS[g], color=COLORS[g], linestyle="none",
                      label=f"Classe {g + 1}", markersize=6) for g in range(2)]
    handles.append(Line2D([], [], color=INK, label="Frontière de décision", lw=1.6))
    fig.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.5, 0.015),
               ncol=3, frameon=False, fontsize=10)
    # Verify cancellation of the common quadratic term in the LDA log-odds.
    weights = np.linalg.solve(pooled, fitted_means.T)
    linear = points @ weights - 0.5 * np.sum(fitted_means.T * weights, axis=0) + np.log(priors)
    gaussian = gaussian_scores(points, fitted_means, [pooled, pooled], priors)
    np.testing.assert_allclose(linear[:, 1] - linear[:, 0],
                               gaussian[:, 1] - gaussian[:, 0], atol=1e-12)
    save(fig, "discriminante_lda_qda.svg")


def main():
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                         "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
                         "svg.hashsalt": "analyse-discriminante"})
    plot_fisher()
    plot_lda_qda()


if __name__ == "__main__":
    main()
