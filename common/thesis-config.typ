#import "/common/constants.typ": chapter
#import "/common/variables.typ": in-outline

#let config(
  myAuthor: "Nome cognome",
  myTitle: "Titolo",
  myLang: "it",
  myNumbering: "1",
  myHeadingNumbering: "1.",
  body,
) = {
  // Set the document's basic properties.
  set document(author: myAuthor, title: myTitle)
  set page(margin: (inside: 4cm, outside: 4cm, y: 3.5cm), numbering: myNumbering, number-align: center)
  set par(leading: 0.70em, spacing: 1.25em, justify: true)

  set text(font: "Source Serif 4", size: 10pt, lang: myLang)
  show raw: set text(font: "Iosevka Thesis", size: 10pt, lang: myLang)
  show math.equation: set text(weight: 400)
  set list(indent: 1em)
  set enum(indent: 1em)
  set terms(indent: 1em)

  set heading(numbering: myHeadingNumbering)
  show heading: set block(above: 1.4em, below: 1em)
  show heading: set text(font: "Merriweather", weight: "regular")
  show heading.where(level: 2): set text(weight: "regular")
  show heading.where(level: 1): it => stack(
    spacing: 1.2em,
    if it.numbering != none {
      text(size: 1.2em, weight: "semibold")[#chapter #counter(heading).display()]
    },
    text(size: 1.5em, weight: "bold", it.body),
    [],
  )

  show ref: it => {
    if it.element != none and it.element.func() == heading {
      let pos = counter(heading).at(it.element.location())
      link(it.element.location(), {
        "§"
        numbering(it.element.numbering, ..pos).trim(".")
      })
    } else {
      it
    }
  }

  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  body
}

#let useCase(useCaseDetails) = {
  let n = 1
  if useCaseDetails.number != "" and useCaseDetails.name != "" {
    text(12pt, [ *UC#useCaseDetails.number: #useCaseDetails.name* ])
  }
  let result = for (k, v) in useCaseDetails {
    if k != "number" and k != "name" {
      (
        text(k, weight: "bold"),
        v,
      )
    }
    n = n + 1
  }
  table(
    inset: 8pt,
    stroke: none,
    columns: 2,
    ..result
  )
}
