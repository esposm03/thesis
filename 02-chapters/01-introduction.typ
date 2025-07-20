#import "/common/variables.typ": digid

= Introduzione <chap:introduction>

== L'azienda

Il progetto di stage si è svolto presso la sede di Cadoneghe dell'azienda UNOX S.p.A.
L'azienda si occupa della progettazione e produzione di forni professionali
per i settori della ristorazione, del _retail_, della pasticceria, e della panificazione,
e vanta 690 dipendenti solo nella sede di Padova.

UNOX si occupa di tutte le fasi del ciclo di vita dei forni,
dalla progettazione e produzione alla commercializzazione e vendita.
Alcuni dei prodotti presentano un sistema _smart_, denominato #digid,
che fornisce funzionalità quali programmazione delle cotture, controllo remoto,
o emissione di notifiche in caso di particolari eventi.

== L'idea

Il sistema #digid, attualmente, è installato solo sui forni di fascia più alta che UNOX produce.
L'obiettivo dell'azienda è quello di ridurre i costi dell'_hardware_ utilizzato da #digid, // L'obiettivo dell'azienda è quello di ridurre ...
in maniera tale da poter essere utilizzato anche all'interno dei nuovi forni, garantendo un prezzo di commercializzazione inferiore.
Secondo test effettuati internamente, però, l'attuale implementazione adottata dai forni in commercio non è in grado di garantire le prestazioni adeguate, in quanto viene utilizzato _hardware_ di fascia più bassa per contenere i costi di produzione,
e, di conseguenza,
si è reso necessario sostituirla con una che potesse soddisfare le nuove esigenze.

Da alcuni mesi l'azienda sta sviluppando un _renderer_#sub[G] 2D#sub[G]) completamente nuovo,
in grado di raggiungere prestazioni migliori rispetto alla piattaforma precedente a parità di _hardware_.
Il progetto di stage prevede, quindi, di affiancare il _team_ di sviluppo
nell'ottimizzazione delle prestazioni, mediante l'integrazione
di codice capace di sfruttare la _GPU_ del sistema per accelerare le fasi più critiche.

== Organizzazione del testo

Il documento è suddiviso in #context { counter(heading).final().at(0) } capitoli:

#show ref: it => {
  let el = it.element
  if el.func() == heading {
    link(el.location(), text(weight: "bold", el.body))
  } else {
    it
  }
}

1. @chap:introduction: viene introdotto il progetto di stage,
  fornendo una breve spiegazione del contesto che ha portato alla sua creazione.
  Successivamente, vengono fornite le indicazioni relative alla struttura e alle convenzioni tipografiche adottate dal testo.
2. @chap:rendering-process: viene esposta l'architettura adottata nello sviluppo del _software_.
3. @chap:gpu-programming: introduce i concetti fondamentali di come lavorare con le moderne _GPU_. //introduce i concetti fondamentali...
4. @chap:composition: presenta l'integrazione della _GPU_ all'interno del progetto.
5. @chap:future-work: espone le considerazioni finali del progetto, portando alla luce i risultati ottenuti, le future possibilità di sviluppo e la valutazione personale relativamente all'esperienza di _stage_.

Nel documento sono state adottate le seguenti convenzioni tipografiche:

- Gli acronimi, le abbreviazioni e i termini ambigui o di uso non comune menzionati vengono definiti nel glossario, situato alla fine del presente documento;
- La prima occorrenza di un termine riportato nel glossario ed individuato all'interno del testo deve presentare la nomenclatura: _parola_#sub[G];
- I termini in lingua straniera o appartenenti al gergo tecnico vengono riportati in _corsivo_.
