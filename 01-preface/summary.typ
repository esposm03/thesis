#import "/common/constants.typ": abstract
#set page(numbering: "i")
#counter(page).update(1)

#v(10em)

#text(24pt, font: "Merriweather", weight: "semibold", abstract)

#v(2em)

Il presente documento descrive il lavoro svolto durante il periodo di _stage_, della durata di trecentododici ore, dal laureando Samuele Esposito presso l’azienda UNOX S.p.A..

L’obiettivo principale del progetto è stata l’integrazione della _GPU_#super[G] all’interno di una libreria adibita alla creazione di interfacce grafiche, destinata allo sviluppo del sistema operativo Digital.ID#sym.trademark installato nei forni di nuova generazione prodotti dall’azienda.

In particolar modo, il documento descrive le nozioni teoriche apprese durante lo svolgimento di suddetto _stage_, introducendo alcuni accenni relativi all’implementazione per fornire al lettore esempi pratici circa le scelte di sviluppo adottate.

Il periodo di _stage_ si è articolato in diverse fasi, ognuna della quali ha contribuito al raggiungimento degli obiettivi prefissati:
- *Prima fase*: analizzare e comprendere la struttura del codice sorgente già esistente
  all'inizio del periodo
- *Seconda fase*: acquisizione delle competenze necessarie per la programmazione di _GPU_#super[G]
- *Terza fase*: fase di sviluppo destinata all’integrazione della _GPU_#super[G] all’interno della libreria
- *Quarta fase*: esecuzione di _test_ di correttezza per verificare la presenza di problemi, originati dallo sviluppo della medesima integrazione, e analizzato le prestazioni tramite un _frame profiler_#super[G] in maniera tale da verificare se l’integrazione della _GPU_#super[G] avesse portato ai miglioramenti previsti.

#pagebreak()
