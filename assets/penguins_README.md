# Palmer Penguins

`penguins.csv` is an unchanged copy of the simplified `penguins` dataset from
the official [palmerpenguins repository](https://github.com/allisonhorst/palmerpenguins).
It contains 344 rows and preserves the original column names, row order and
`NA` values.

- [CSV source](https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv), downloaded 2026-09-13.
- [Variable documentation](https://allisonhorst.github.io/palmerpenguins/reference/penguins.html).
- SHA-256: `f204db2c753b0937caac3cb35258562c14f073e4bbc76be24b4c51ce22767a93`.
- Data license: [CC0](https://allisonhorst.github.io/palmerpenguins/#license).

The data were collected by Kristen Gorman and the Palmer Station LTER program.
Package citation: Horst AM, Hill AP, Gorman KB (2020), *palmerpenguins: Palmer
Archipelago (Antarctica) penguin data*, [doi:10.5281/zenodo.3960218](https://doi.org/10.5281/zenodo.3960218).
Original study: Gorman KB, Williams TD, Fraser WR (2014),
[doi:10.1371/journal.pone.0090081](https://doi.org/10.1371/journal.pone.0090081).

The course PCA uses `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`, and
`body_mass_g`. Only rows missing one of these four measurements are excluded:
rows 4 and 272, counting data rows from 1, without the header. This leaves 342
observations, including 9 with missing `sex`. Run
`python figures/acp_palmerpenguins.py` from the repository root to regenerate
the figure offline with NumPy, pandas and Matplotlib.
