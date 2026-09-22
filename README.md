# Course Data Analysis

Typst source for lecture notes for a data analysis course.

## Structure

- `main.typ` is the document entry point.
- `config/course.typ` stores course metadata.
- `styles/notes.typ` stores shared formatting and helper blocks.
- `lectures/` contains one Typst file per lecture.
- `figures/` and `assets/` are placeholders for images, datasets, or other supporting files.

## Build

Compile the notes with:

```sh
typst compile main.typ
```

For live preview while editing:

```sh
typst watch main.typ
```


## Topics

[X] Analyse exploratoire (~~notes~~, ~~slides~~, ~~code~~)
[ ] Réduction de dimension
    [X] ACP (~~notes~~, ~~slides~~, ~~code~~)
[ ] Apprentissage supervisée
    [X] kNN (~~notes~~, ~~slides~~, ~~code~~)
    [ ] Analyse discriminante de Fisher (~~notes~~, slides, code)
    [ ] LDA / QDA (notes, slides, code)
[ ] Apprentissage non-supervisée
    [ ] k-means (notes, slides, code)
[ ] Données manquantes 

