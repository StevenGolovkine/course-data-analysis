#let apply_notes_style(title: "", author: "", body) = {
  set document(title: title, author: author)
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 0.9in),
    numbering: "1",
  )
  set text(
    font: "New Computer Modern",
    size: 11pt,
    lang: "en",
  )
  set heading(numbering: "1.1")
  set par(justify: true, leading: 0.65em)
  set list(indent: 1.2em, body-indent: 0.4em)
  set enum(indent: 1.2em, body-indent: 0.4em)

  show link: underline
  show raw.where(block: true): block.with(
    fill: luma(245),
    inset: 8pt,
    radius: 3pt,
  )
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  body
}

#let note(body) = block(
  fill: rgb("#f4f7fb"),
  stroke: rgb("#d8e2f0"),
  inset: 8pt,
  radius: 3pt,
  body,
)

#let example(body) = block(
  fill: rgb("#f7f6ef"),
  stroke: rgb("#e4dfc8"),
  inset: 8pt,
  radius: 3pt,
  body,
)

