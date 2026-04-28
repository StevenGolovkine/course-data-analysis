#import "config/course.typ": *
#import "styles/notes.typ": apply_notes_style

#show: apply_notes_style.with(
  title: course_title,
  author: course_author,
)

#align(center)[
  #text(size: 22pt, weight: "bold")[#course_title]
  #v(0.4em)
  #course_term \
  #course_author
]

#v(2em)

#outline(title: [Contents])

#pagebreak()

#include "lectures/lecture-01.typ"

