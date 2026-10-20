"""Comparer trois liaisons sur les mêmes quatre observations fictives.

Depuis la racine : python figures/cah_liaisons.py (NumPy et Matplotlib).
Les fusions sont calculées exactement avec des fractions, sans dépendance à R.
"""

from fractions import Fraction
from itertools import combinations

from classification_hierarchique import INK, decorate, dendrogram, plt, save


def agglomerate(values, method):
    """Recherche exhaustive, adaptée au petit exemple pédagogique."""
    active = {-(i + 1): [i] for i in range(len(values))}
    rows, heights, groups = [], [], None
    for step in range(1, len(values)):
        candidates = []
        ordered = sorted(active, key=lambda node: min(active[node]))
        for a, b in combinations(ordered, 2):
            distances = [abs(values[i] - values[j])
                         for i in active[a] for j in active[b]]
            if method == "single":
                height = min(distances)
            elif method == "complete":
                height = max(distances)
            elif method == "average":
                height = sum(distances) / len(distances)
            else:
                raise ValueError(f"Liaison inconnue : {method}")
            candidates.append((height, a, b))
        # À égalité, conserver le premier candidat dans l'ordre des observations.
        height, a, b = min(candidates, key=lambda candidate: candidate[0])
        rows.append({"gauche": a, "droite": b, "hauteur": float(height)})
        heights.append(height)
        active[step] = active.pop(a) + active.pop(b)
        if len(active) == 2:
            groups = [0] * len(values)
            for label, node in enumerate(sorted(active, key=lambda c: min(active[c])), 1):
                for i in active[node]:
                    groups[i] = label
    return rows, heights, groups


def main():
    plt.rcParams.update({
        "font.family": "DejaVu Sans", "font.size": 10,
        "mathtext.fontset": "dejavusans", "svg.fonttype": "path",
        "svg.hashsalt": "cah-liaisons",
    })
    values = [Fraction(s) for s in ["0", "1", "3.2", "5.8"]]
    labels = ["A\n0", "B\n1", "C\n3,2", "D\n5,8"]
    settings = [
        ("single", "Liaison simple", ["1", "2.2", "2.6"],
         [1, 1, 1, 2], "{A, B, C} et {D}"),
        ("complete", "Liaison complète", ["1", "2.6", "5.8"],
         [1, 1, 2, 2], "{A, B} et {C, D}"),
        ("average", "Liaison moyenne", ["1", "2.6", "4"],
         [1, 1, 2, 2], "{A, B} et {C, D}"),
    ]
    fig, axes = plt.subplots(1, 3, figsize=(7.4, 3.6))
    fig.subplots_adjust(left=0.07, right=0.985, bottom=0.24, top=0.87, wspace=0.23)
    for ax, (method, title, expected, expected_groups, partition) in zip(axes, settings):
        rows, heights, groups = agglomerate(values, method)
        assert heights == [Fraction(h) for h in expected]
        assert groups == expected_groups
        decorate(ax)
        dendrogram(ax, rows, groups, labels)
        ax.set(ylim=(0, 6.5), yticks=[0, 1, 2, 3, 4, 5, 6])
        ax.set_title(title, fontsize=11, color=INK, pad=10)
        ax.set_xlabel(partition, fontsize=9, color=INK, labelpad=10)
        cut = float((heights[-2] + heights[-1]) / 2)
        ax.axhline(cut, color=INK, ls="--", lw=0.9)
        final_height = f"{float(heights[-1]):g}".replace(".", ",")
        ax.text(1.5, float(heights[-1]) + 0.18, final_height,
                ha="center", color=INK, fontsize=9)
    axes[0].set_ylabel("Hauteur de fusion", color=INK)
    save(fig, "cah_liaisons.svg")
    print("Trois hiérarchies vérifiées ; figure cah_liaisons.svg générée.")


if __name__ == "__main__":
    main()
