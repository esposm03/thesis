#let logo = "../images/unipd-logo.svg"
#import "../config/variables.typ": (
  myAA,
  myDegree,
  myDepartment,
  myFaculty,
  myMatricola,
  myName,
  myProf,
  myTitle,
  myUni,
  profTitle,
)
#import "../config/constants.typ": ID, academicYear, supervisor, undergraduate

#set page(numbering: none)

#grid(
  columns: auto,
  rows: (1fr, auto, 20pt),
  // Intestazione
  [
    #align(center, text(18pt, weight: "semibold", myUni))
    #v(1em)
    #align(center, text(14pt, weight: "light", smallcaps(myDepartment)))
    #v(1em)
    #align(center, text(12pt, weight: "light", smallcaps(myFaculty)))
  ],
  // Corpo
  [
    // Logo
    #align(center, image(logo, width: 50%))
    #v(30pt)

    // Titolo
    #align(center, box(width: 26em, text(19pt, hyphenate: false, weight: "semibold", font: "Merriweather", myTitle)))
    #v(10pt)
    #align(center, text(14pt, weight: "light", style: "italic", font: "Merriweather", myDegree))
    #v(40pt)

    // Relatore e laureando
    #align(left, text(12pt, weight: 400, style: "italic", supervisor))
    #v(5pt)
    #align(left, text(11pt, profTitle + myProf))

    #align(right, text(12pt, weight: 400, style: "italic", undergraduate))
    #v(5pt)
    #align(right, text(11pt, myName))
    #v(5pt)
    #align(right, text(11pt, [_ #ID _ ] + myMatricola))
    #v(30pt)
  ],
  // Piè di pagina
  [
    // Anno accademico
    #line(length: 100%)
    #align(center, text(8pt, weight: 400, smallcaps(academicYear + " " + myAA)))
  ]
)
