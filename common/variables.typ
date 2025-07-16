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
