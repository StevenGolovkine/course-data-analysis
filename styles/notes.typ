#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: *

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
        #block(width: 100%)[
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

  show: show-theorion
  set-inherited-levels(1)
  set-zero-fill(true)
  set-leading-zero(true)
  set-theorion-numbering("1.1")

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
            Chapitre #context counter(heading).display()
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
