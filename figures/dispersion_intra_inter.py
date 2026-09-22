"""Illustrer les dispersions intra-groupe et inter-groupe dans un plan.

Exécution : python figures/dispersion_intra_inter.py
Dépendances : NumPy et Matplotlib. Données déterministes, sans hasard.
Le SVG est enregistré à côté du script, quel que soit le dossier courant.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import numpy as np


COULEURS = ("#347663", "#b77244")
ENCRE = "#486976"
MARQUEURS = ("o", "^")


def tracer_dispersions(chemin=None):
    """Générer le SVG et retourner les matrices de dispersion W, B et T."""
    if chemin is None:
        chemin = Path(__file__).with_name("discriminante_dispersions.svg")

    centres = np.array([[-2.0, -0.6], [2.3, 1.0]])
    ecarts = [
        np.array([
            [-1.0, -0.4], [1.0, 0.4], [-0.65, 0.65], [0.65, -0.65],
            [-0.2, -0.95], [0.2, 0.95], [-0.75, 0.15], [0.75, -0.15],
        ]),
        np.array([
            [-0.8, -0.4], [0.8, 0.4], [-0.45, 0.8], [0.45, -0.8],
            [-0.1, -0.6], [0.1, 0.6],
        ]),
    ]
    groupes = [centre + ecart for centre, ecart in zip(centres, ecarts)]
    effectifs = np.array([len(groupe) for groupe in groupes])
    observations = np.vstack(groupes)
    moyenne_globale = observations.mean(axis=0)

    # Les croix représentent les moyennes empiriques exactes des groupes.
    moyennes_empiriques = np.array([groupe.mean(axis=0) for groupe in groupes])
    np.testing.assert_allclose(moyennes_empiriques, centres, atol=1e-12, rtol=0)
    moyenne_ponderee = np.average(centres, axis=0, weights=effectifs)
    np.testing.assert_allclose(
        moyenne_globale, moyenne_ponderee, atol=1e-12, rtol=0,
    )

    # Vérifier la décomposition matricielle T = W + B, sans normalisation.
    ecarts_intra = [groupe - centre for groupe, centre in zip(groupes, centres)]
    intra = sum(ecart.T @ ecart for ecart in ecarts_intra)
    ecarts_inter = centres - moyenne_globale
    inter = ecarts_inter.T @ (effectifs[:, None] * ecarts_inter)
    ecarts_totaux = observations - moyenne_globale
    totale = ecarts_totaux.T @ ecarts_totaux
    np.testing.assert_allclose(totale, intra + inter, atol=1e-10, rtol=0)

    style = {
        "font.family": "DejaVu Sans",
        "font.size": 11,
        "mathtext.fontset": "dejavusans",
        "svg.fonttype": "path",
        "svg.hashsalt": "dispersion-intra-inter",
    }
    with plt.rc_context(style):
        fig, ax = plt.subplots(figsize=(7.4, 4.6))
        fig.subplots_adjust(left=0.08, right=0.99, bottom=0.23, top=0.97)
        ax.set_aspect("equal")
        ax.set_axisbelow(True)
        ax.grid(color="#e8edef", linewidth=0.6)
        for bord in ax.spines.values():
            bord.set_visible(False)
        ax.tick_params(length=0, colors=ENCRE, labelsize=9)
        ax.set(xlim=(-3.6, 4.2), ylim=(-1.9, 2.5))
        ax.set_xticks(np.arange(-3, 5))
        ax.set_yticks(np.arange(-1, 3))
        ax.set_xlabel("$x_1$", color=ENCRE)
        ax.set_ylabel("$x_2$", color=ENCRE)

        # Intra-groupe : relier chaque observation à la moyenne de son groupe.
        for g, groupe in enumerate(groupes):
            for observation in groupe:
                ax.plot(
                    [centres[g, 0], observation[0]],
                    [centres[g, 1], observation[1]],
                    color=COULEURS[g], alpha=0.5, linewidth=0.8, zorder=1,
                )
            ax.scatter(
                *groupe.T, marker=MARQUEURS[g], s=35, color=COULEURS[g],
                edgecolors="white", linewidths=0.5, zorder=3,
            )

        # Inter-groupe : du centre global vers chaque moyenne de groupe.
        # Les flèches s'arrêtent avant les croix pour rester lisibles.
        for g, centre in enumerate(centres):
            direction = ecarts_inter[g]
            arrivee = centre - 0.12 * direction / np.linalg.norm(direction)
            ax.annotate(
                "", xy=arrivee, xytext=moyenne_globale,
                arrowprops={
                    "arrowstyle": "->", "color": ENCRE, "linewidth": 2,
                    "shrinkA": 0, "shrinkB": 0, "mutation_scale": 13,
                },
                zorder=2,
            )
            ax.scatter(
                *centre, marker="x", s=85, color=COULEURS[g],
                linewidths=2, zorder=4,
            )
        ax.scatter(
            *moyenne_globale, marker="D", s=55, color=ENCRE,
            edgecolors="white", linewidths=0.6, zorder=5,
        )

        for g, hauteur in enumerate((1.02, 2.2)):
            ax.text(
                centres[g, 0], hauteur,
                f"Groupe {g + 1} ($n_{g + 1} = {effectifs[g]}$)",
                color=COULEURS[g], ha="center", va="center",
            )
        ax.text(-2.35, -0.9, r"$\bar{x}_1$", color=COULEURS[0], ha="center")
        ax.text(2.65, 0.75, r"$\bar{x}_2$", color=COULEURS[1], ha="center")
        ax.plot(
            [moyenne_globale[0], 0.35], [moyenne_globale[1] - 0.12, -0.75],
            color="#aebbc1", linewidth=0.6,
        )
        ax.text(
            0.35, -1.05, "Moyenne globale\n" + r"$\bar{x}$",
            color=ENCRE, fontsize=10, ha="center", va="center",
        )

        # Réserver un espace sous les axes aux formules de la légende.
        symboles = [
            Line2D(
                [], [], color="#83a699", linewidth=0.8,
                label=r"Intra-groupe : $x_i - \bar{x}_g$",
            ),
            Line2D(
                [], [], color=ENCRE, linewidth=2,
                label=r"Inter-groupe : $\bar{x}_g - \bar{x}$",
            ),
        ]
        fig.legend(
            handles=symboles, loc="lower center", bbox_to_anchor=(0.5, 0.025),
            ncol=2, frameon=False, fontsize=10, labelcolor=ENCRE,
        )
        fig.savefig(chemin, facecolor="white", metadata={"Date": None})
        plt.close(fig)

    return {"intra": intra, "inter": inter, "totale": totale}


if __name__ == "__main__":
    tracer_dispersions()
