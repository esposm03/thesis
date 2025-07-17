// All reusable variables here
#let myLang = "it"
#let myName = "Samuele Esposito"
#let myMatricola = "2068233"
#let myTitle = "Ottimizzazione di un renderer 2D mediante integrazione di GPU"
#let myDegree = "Tesi di laurea"
#let myUni = "Università degli Studi di Padova"
#let myDepartment = "Dipartimento di Matematica \"Tullio Levi-Civita\""
#let myFaculty = "Corso di Laurea in Informatica"
#let profTitle = "Prof. "
#let myProf = "Marco Zanella"
#let myCompany = "Unox S.p.A."
#let myTutor = "Marco Giraldo"
#let myLocation = "Padova"
#let myAA = "2024-2025"
#let myTime = "Luglio 2025"

#let digid = [_Digital.ID_#sym.trademark]

#let in-outline = state("in-outline", false)

#let flex-caption(long, short) = context if in-outline.get() { short } else { long }

#let code(..args) = {
  figure(supplement: [Codice], ..args)
}

#let equation(..args) = {
  figure(supplement: [Equazione], kind: "equation", ..args)
}

#let chart(a, b) = {
  import "@preview/cetz:0.4.0"
  import cetz.draw: *

  grid(
    a,
    b,
    stroke: 0.1pt,
  )

  line((a.at(0), 0), (b.at(0), 0), stroke: 0.5pt, mark: (end: (symbol: ">")))
  line((0, a.at(1)), (0, b.at(1)), stroke: 0.5pt, mark: (end: (symbol: ">")))

  content((a.at(0) - 0.3, 0), [$x$])
  content((0, a.at(1) - 0.3), [$y$])
}

#let my_point(x, y, name, my-fill: red, dx: -0.3, dy: -0.3) = {
  import "@preview/cetz:0.4.0"
  import cetz.draw: *

  circle((x, y), radius: 0.1, fill: my-fill, name: name)
  content((x + dx, y + dy), name)
}
