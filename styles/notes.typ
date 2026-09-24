#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: *
#import "math.typ": *

// Même vocabulaire, même compteur par chapitre et mêmes règles de coupure.
// Les variantes *-box du package restent disponibles pour les anciens textes.
#let definition = cosmos.fancy.definition.with(
  supplement: "Définition", breakable: false,
)
#let property = cosmos.fancy.property.with(
  supplement: "Propriétés", breakable: false,
)
#let theorem = cosmos.fancy.theorem.with(
  supplement: "Théorème", breakable: false,
)
#let example = cosmos.fancy.example.with(
  supplement: "Exemple", breakable: false,
  get-border-color: loc => rgb("#655080"),
  get-body-color: loc => rgb("#f6f2f9"),
)
#let remark = cosmos.fancy.remark.with(
  supplement: "Remarque", breakable: false,
  get-border-color: loc => rgb("#5f6f7a"),
  get-body-color: loc => rgb("#f2f5f6"),
)
#let proof = cosmos.default.proof.with(title: "Preuve")

#let exercises(body) = {
  heading(level: 2, outlined: false)[Exercices]
  body
}


#let before-location(a, b) = {
  let pa = a.position()
  let pb = b.position()
  pa.page < pb.page or (pa.page == pb.page and pa.y < pb.y)
}

#let outline-link(dest, body) = {
  show underline: it => it.body
  link(dest, body)
}

#let page-number-at(loc) = {
  let values = counter(page).at(loc)
  if values.len() > 0 {
    str(values.at(0))
  }
}

#let chapter-outline(chapter) = context {
  let current = chapter.location()
  let chapters = query(heading.where(level: 1, outlined: true))
  let later-chapters = chapters.filter(
    it => before-location(current, it.location())
  )
  let next = if later-chapters.len() > 0 {
    later-chapters.at(0).location()
  } else {
    none
  }
  let sections = query(heading.where(level: 2, outlined: true)).filter(
    it => {
      let loc = it.location()
      (
        before-location(current, loc) and
          (next == none or before-location(loc, next))
      )
    }
  )

  if sections.len() > 0 {
    v(2.6em)
    text(size: 14pt, weight: "bold", fill: rgb("#5f6f7a"))[Plan du chapitre]
    v(0.8em)
    for section in sections {
      let loc = section.location()
      let nr = page-number-at(loc)
      outline-link(loc)[
        #block(width: 100%, above: 0.8em, below: 0.8em)[
          #text(
            size: 11pt, weight: "thin", fill: rgb("#24313a")
          )[#section.body]
          #h(1fr)
          #text(
            size: 10pt, weight: "thin", fill: rgb("#6b7c86")
          )[#nr]
        ]
      ]
    }
  }
}

#let main-outline() = {
  text(size: 16pt, weight: "bold", fill: rgb("#5f6f7a"))[Table des matières]
  v(1.4em)

  context {
    let chapters = query(heading.where(level: 1, outlined: true))

    for chapter in chapters {
      let loc = chapter.location()
      let nr = page-number-at(loc)
      outline-link(loc)[
        #block(width: 100%)[
          #text(
            size: 11pt, weight: "thin", fill: rgb("#24313a")
          )[#chapter.body]
          #h(1fr)
          #text(
            size: 10pt, weight: "thin", fill: rgb("#6b7c86")
          )[#nr]
        ]
      ]
    }
  }
}

#let apply_notes_style(title: "", author: "", body) = {
  set document(title: title, author: author)
  set page(
    paper: "a4",
    margin: (x: 1in, y: 1in),
    numbering: "1",
  )
  set text(
    font: "Palatino",
    size: 12pt,
    lang: "fr",
  )
  set heading(numbering: "1.1")
  set par(justify: true, leading: 0.65em)
  set list(indent: 1.2em, body-indent: 0.4em)
  set enum(indent: 1.2em, body-indent: 0.4em)
  set table(
    inset: 5pt,
    stroke: 0.4pt + rgb("#cfd8dc"),
    fill: (x, y) => if y == 0 { rgb("#eef3f1") },
  )
  show figure.caption: set align(left)

  show: show-theorion
  set-inherited-levels(1)
  set-zero-fill(true)
  set-leading-zero(true)
  set-theorion-numbering("1.1")
  set-qed-symbol[$square$]
  set-primary-border-color(rgb("#527660"))
  set-primary-body-color(rgb("#f0f6f2"))
  set-secondary-border-color(rgb("#8a642f"))
  set-secondary-body-color(rgb("#fbf6ed"))
  set-tertiary-border-color(rgb("#426680"))
  set-tertiary-body-color(rgb("#eff4f8"))
  set-primary-symbol(none)
  set-secondary-symbol(none)
  set-tertiary-symbol(none)
  set-quaternary-symbol(none)

  show link: underline
  show raw.where(block: true): block.with(
    fill: luma(245),
    inset: 8pt,
    radius: 3pt,
  )

  show heading.where(level: 1, outlined: true): it => {
    pagebreak(weak: true)
    page(numbering: none)[
      #align(center + horizon)[
        #block(width: 75%)[
          #text(size: 11pt, weight: "bold", fill: rgb("#7b9e89"))[
            #if repr(it.body).starts-with("sequence([Annexe]") {
              [Annexe]
            } else {
              [Chapitre #context counter(heading).display()]
            }
          ]

          #v(1.1em)
          #box(width: 100%, height: 0.8pt, fill: rgb("#8ba0ad"))
          #v(2.2em)
        ]
        #block(width: 100%)[
          #text(size: 28pt, weight: "bold", fill: rgb("#24313a"))[
            #it.body
          ]
        ]
        #block(width: 75%)[
          #chapter-outline(it)
        ]
      ]
    ]
  }

  show heading.where(level: 2): it => {
    v(1.3em)
    text(size: 17pt, weight: "bold", fill: rgb("#24313a"))[
      #it
    ]
    v(0.35em)
    box(width: 100%, height: 0.7pt, fill: rgb("#d9e1e5"))
    v(0.6em)
  }

  show heading.where(level: 3): it => {
    v(0.9em)
    text(size: 14pt, weight: "bold", fill: rgb("#4c5a63"))[
      #it
    ]
    v(0.25em)
  }

  {
    set page(numbering: none)
    place(bottom + right)[
      #text(size: 10pt, fill: rgb("#5f6f7a"))[
        Dernière mise à jour : #datetime.today().display("[day]/[month]/[year]")
      ]
    ]

    align(center + horizon)[
      #block(width: 75%)[
        #text(size: 13pt, weight: "regular", fill: rgb("#5f6f7a"))[
          Notes de cours
        ]

        #v(1.2em)
        #box(width: 100%, height: 0.8pt, fill: rgb("#8ba0ad"))
        #v(2.8em)

        #text(size: 32pt, weight: "bold", fill: rgb("#24313a"))[
          #title
        ]

        #v(1.1em)
        #text(size: 15pt, fill: rgb("#4c5a63"))[
          #author
        ]

        #v(3.2em)
        #box(width: 28%, height: 3pt, fill: rgb("#7b9e89"))
      ]
    ]
    pagebreak()
  }

  counter(page).update(1)

  body
}
