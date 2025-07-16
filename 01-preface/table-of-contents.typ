#import "/common/constants.typ": codeListingsList, equationsList, figuresList
#set page(numbering: "i")

#[
  #show outline.entry.where(level: 1): it => {
    linebreak()
    link(it.element.location(), strong(it))
    //    h(1fr)
  }
  #outline(indent: auto, depth: 5)
]

#v(5em)

#outline(title: figuresList, target: figure.where(kind: image))

#v(5em)

#outline(title: equationsList, target: figure.where(kind: "equation"), indent: auto)

#v(5em)

#outline(title: codeListingsList, target: figure.where(kind: raw), indent: auto)
