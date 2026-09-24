// Mise en forme commune des présentations STT-2200.
// Références visuelles : slides/exploratory.typ et slides/introduction.typ.
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let accent = rgb("#00897b")
#let accent-dark = rgb("#00695c")
#let ink = rgb("#24313a")
#let muted = rgb("#60747d")
#let pale = rgb("#edf7f5")
#let pale-blue = rgb("#eef4f8")
#let pale-orange = rgb("#fff4e5")
#let pale-purple = rgb("#f4eff8")
#let pale-red = rgb("#fcecec")
#let pale-gray = rgb("#f7f9fa")

// Une bordure assortie au fond, y compris pour les encadrés de synthèse.
#let panel-stroke(fill) = if fill == pale-blue {
  rgb("#c7d8e4")
} else if fill == pale-orange {
  rgb("#ead4ad")
} else if fill == pale-purple {
  rgb("#d9cbe4")
} else if fill == pale-red {
  rgb("#ecc1c1")
} else if fill == pale-gray {
  rgb("#d8e0e3")
} else {
  rgb("#bedbd5")
}

#let card(
  title,
  body,
  fill: pale,
  stroke: auto,
  height: auto,
  title-size: 20pt,
  body-size: 18pt,
) = block(
  width: 100%,
  height: height,
  inset: 11pt,
  radius: 5pt,
  fill: fill,
  stroke: 0.8pt + if stroke == auto { panel-stroke(fill) } else { stroke },
  breakable: false,
)[
  #align(left + top)[#layout(size => {
    let contents = [
      #set par(spacing: 0.55em)
      #text(size: title-size, weight: "bold", fill: accent-dark)[#title]
      #v(0.32em)
      #text(size: body-size, fill: ink)[#body]
    ]
    if sys.inputs.at("check-layout", default: "false") == "true" and height != auto {
      let needed = measure(contents, width: size.width).height + 22pt
      if needed > height + 1pt {
        metadata((kind: "card-overflow", title: title, needed: needed, height: height))
      }
    }
    contents
  })]
]

#let formula(body, fill: pale-gray, height: auto) = block(
  width: 100%,
  height: height,
  inset: 12pt,
  radius: 5pt,
  fill: fill,
  stroke: 0.7pt + panel-stroke(fill),
  breakable: false,
)[#align(center + horizon)[#text(size: 18pt, fill: ink)[#body]]]

#let takeaway(body, fill: pale) = block(
  width: 100%,
  inset: (x: 13pt, y: 10pt),
  radius: 5pt,
  fill: fill,
  stroke: 0.8pt + panel-stroke(fill),
  breakable: false,
)[#align(center)[#text(size: 18pt, weight: "bold", fill: accent-dark)[#body]]]

#let small(body) = text(size: 16pt, fill: muted)[#body]

#let tag(body, fill: accent, size: 14pt) = box(
  inset: (x: 8pt, y: 3pt),
  radius: 10pt,
  fill: fill,
)[#text(size: size, weight: "bold", fill: white)[#body]]

#let course-table(
  columns: (),
  align: center + horizon,
  fill: (x, y) => if y == 0 { pale } else { none },
  ..cells,
) = {
  set text(size: 17pt)
  table(
    columns: columns,
    inset: 8pt,
    align: align,
    stroke: 0.6pt + rgb("#d4dfe1"),
    fill: fill,
    ..cells,
  )
}

#let metric(title, equation, question, fill: pale, stroke: auto) = card(
  title,
  [
    #align(center)[#text(size: 18pt)[#equation]]
    #v(0.35em)
    #question
  ],
  fill: fill,
  stroke: stroke,
  height: 2.2in,
)

#let course-slides(
  title: [],
  subtitle: [STT-2200],
  footer-title: auto,
  author: [Steven Golovkine],
  date: [Automne 2026],
  institution: [Université Laval],
  body,
) = {
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    config-common(breakable: false, detect-overflow: true),
    footer: self => [STT-2200 · #if footer-title == auto { title } else { footer-title }],
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
    ),
  )
  set text(font: "Libertinus Serif", lang: "fr", size: 20pt, fill: ink)
  set par(justify: false, leading: 0.45em)
  set list(indent: 1.05em, body-indent: 0.45em, spacing: 0.32em)
  set enum(indent: 1.05em, body-indent: 0.45em, spacing: 0.3em)
  show raw: set text(size: 16pt)
  body
}
