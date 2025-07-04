#import "/common/variables.typ": *
#import "/common/thesis-config.typ": *

#show: config.with(myAuthor: myName, myTitle: myTitle, myLang: myLang)

// Frontmatter

#include "/01-preface/firstpage.typ"
#include "/01-preface/copyright.typ"
#include "/01-preface/dedication.typ"
#include "/01-preface/summary.typ"
#include "/01-preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)

#include "./02-chapters/01-introduction.typ"
#include "./02-chapters/02-rendering-process.typ"
#include "./02-chapters/03-gpu-programming.typ"
#include "./02-chapters/04-composition.typ"
#include "./02-chapters/05-future-work.typ"
// #include "./chapters/process.typ"
// #include "./chapters/stage-description.typ"
// #include "./chapters/requirements.typ"
// #include "./chapters/product-design.typ"
// #include "./chapters/product-testing.typ"
// #include "./chapters/conclusion.typ"

// // Appendix

// #include "./appendix/appendice-a.typ"

// // Backmatter

// // Praticamente il glossario

// Bibliography

#include "./03-bibliography/bibliography.typ"

