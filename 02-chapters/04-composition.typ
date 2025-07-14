#pagebreak(to: "odd")

= Composizione <chap:composition>

L'obiettivo dello _stage_ era quello di aumentare
le prestazioni del _renderer_ mediante l'utilizzo della _GPU_.
Almeno nelle fasi iniziali si è preferito limitare
l'ambito al solo stadio di Composizione,
lasciando potenzialmente _performance_ non sfruttate,
ma riducendo anche il numero di cambiamenti
da fare a codice preesistente.

Inizialmente, avevamo previsto di applicare un approccio
ispirato a quelli adottati per il _rendering_ 3D,
con l'obiettivo migliorare l'efficienza;
successivamente, però, ci siamo accorti che questo miglioramento non era possibile
e abbiamo quindi cambiato approccio,
passando a una implementazione più semplice.


== Approccio iniziale: grafica 3D

Le _GPU_ sono state progettate per la grafica 3D,
e utilizzarle per produrre grafica 2D non è,
strettamente parlando, ciò per cui sono state progettate.
Abbiamo quindi, almeno inizialmente,
pensato di produrre una scena tridimensionale
che rappresentasse una specie di "pila" di _layer_,
in modo da successivamente implementare una "telecamera"
che riprendesse la scena dall'alto in proiezione ortografica,
producendo il risultato desiderato.
Un sistema simile a quello che stavamo implementando è mostrato in @grafico:composizione.

Per fare questo, avevamo scritto del codice che calcolava,
per ogni _layer_, la dimensione e la posizione;
questa informazione veniva inserita all'interno di un _vertex buffer_,
e una _vertex shader_ successivamente inseriva

#import "../vis/sheets.typ": layer, sheet

#let graphic = {
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red))
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red), is-3d: false)
}
#figure(graphic, caption: [Esempio di composizione di layer (colorati) sullo schermo]) <grafico:composizione>

== Approccio semplificato

Mentre implementavamo l'approccio precedente, ci siamo resi conto che, in realtà,
le _GPU_ lavorano su vertici in coordinate già relative allo schermo.
Di conseguenza, implementare un sistema 3D con telecamera ortogonale
risultava più complicato del necessario.
Allora abbiamo implementato un sistema in 2D,
dove i vertici del rettangolo avevano già le coordinate corrette.
