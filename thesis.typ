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

// Appendix

// #include "./appendix/appendice-a.typ"

// Backmatter

#set heading(numbering: none)

#include "glossary.typ"

#v(9em)

// Bibliography

#include "./03-bibliography/bibliography.typ"

