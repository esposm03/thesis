#import "../config/variables.typ": myDegree, myName, myTime, myTitle

#set page(numbering: none)

#align(
  left + bottom,
  [
    #text(myName): #text(style: "italic", myTitle), #text(myDegree). \
    #sym.copyright #text(myTime)
  ],
)
