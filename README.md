# Course Data Analysis

Typst source for lecture notes for a data analysis course.

## Structure

- `main.typ` is the document entry point.
- `config/course.typ` stores course metadata.
- `styles/notes.typ` stores shared formatting and helper blocks.
- `styles/math.typ` stores shared mathematical shortcuts; see the
  [notation and presentation conventions](styles/README.md).
- `styles/slides.typ` stores the shared Touying Metropolis theme and components
  for all presentations in `slides/`.
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

Compile presentations from the repository root so that shared styles and
figures remain accessible:

```sh
typst compile --root . slides/introduction.typ
```


## Topics

- [X] Analyse exploratoire (~~notes~~, ~~slides~~, ~~code~~, ~~exercices~~)

- [ ] Réduction de dimension
    * [ ] ACP (~~notes~~, ~~slides~~, ~~code~~, exercices)
    * [ ] AFC (~~notes~~, ~~slides~~, code, exercices)
    * [ ] ACM (notes, slides, code, exercices)

- [ ] Apprentissage supervisée
    * [ ] kNN (~~notes~~, ~~slides~~, ~~code~~, exercices)
    * [ ] Analyse discriminante de Fisher (~~notes~~, ~~slides~~, ~~code~~, exercices)
    * [ ] LDA / QDA (notes, slides, code, exercices)
    * [ ] Arbres de classification (notes, slides, code, exercices)
    * [ ] Foréts aléatoires (notes, slides, code, exercices)
    * [ ] Bagging (notes, slides, code, exercices)
    * [ ] Boosting (notes, slides, code, exercices)

- [ ] Apprentissage non-supervisée
    * [ ] Concepts (~~notes~~, ~~slides~~, ~~code~~, exercices)
    * [ ] k-means (~~notes~~, ~~slides~~, ~~code~~, exercices)
    * [ ] Modèles hiérarchiques (notes, slides, code, exercices)
    * [ ] Mélanges de Gaussiennes (notes, slides, code, exercices)

- [ ] Données manquantes 
