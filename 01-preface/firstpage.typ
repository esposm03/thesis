#let logo = "/images/unipd-logo.svg"
#import "/common/variables.typ": *
#import "/common/constants.typ": ID, academicYear, supervisor, undergraduate

#set page(numbering: none)
#set align(center)

#grid(
  columns: auto,
  rows: (1fr, auto, 20pt),
  // Intestazione
  [
    #text(18pt, weight: "semibold", myUni)
    #v(1em)
    #text(14pt, weight: "light", smallcaps(myDepartment))
    #v(1em)
    #text(12pt, weight: "light", smallcaps(myFaculty))
  ],
  // Corpo
  [
    // Logo
    #image(logo, width: 50%)
    #v(30pt)

    // Titolo
    #box(width: 30em)[
      #set text(font: "Merriweather")
      #set par(justify: false)

      #text(19pt, weight: "semibold", myTitle)
      #v(10pt)
      #text(14pt, weight: "light", font: "Merriweather", myDegree)
      #v(60pt)
    ]

    // Relatore e laureando
    #grid(
      columns: (auto, 1fr, auto),
      align(left)[
        #text(12pt, weight: 400, style: "italic", supervisor)
        #v(5pt)
        #text(11pt, profTitle + myProf)
      ],
      align(right)[
        #text(12pt, weight: 400, style: "italic", undergraduate)
        #v(5pt)
        #text(11pt, myName)
        #v(5pt)
        #text(11pt, [_ #ID _ ] + myMatricola)
      ],
    )
    #v(16pt)

  ],
  // Piè di pagina
  [
    // Anno accademico
    #line(length: 100%)
    #text(10pt, weight: 400, smallcaps(academicYear + " " + myAA))
  ],
)
