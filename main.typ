#import "config/course.typ": *
#import "styles/notes.typ": apply_notes_style, main-outline

#show: apply_notes_style.with(
  title: course_title,
  author: course_author,
)

#main-outline()

#pagebreak()

#include "lectures/introduction.typ"
#include "lectures/exploratory.typ"
#include "lectures/dimension_reduction.typ"
#include "lectures/supervised.typ"
#include "lectures/unsupervised.typ"
#include "lectures/missing_data.typ"
#include "lectures/others.typ"
