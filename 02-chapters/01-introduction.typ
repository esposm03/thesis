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
L'azienda si è posta l'obiettivo di ridurre i costi dell'_hardware_ utilizzato da #digid,
in modo da poter iniziare a inserirlo anche nelle fasce più basse del proprio mercato.
Secondo test effettuati internamente, però, la precedente implementazione non riusciva
a fornire prestazioni adeguate per il cambio previsto, e di conseguenza
si è reso necessario sostituirla con una più veloce.

Da qualche mese, quindi, sta venendo sviluppato un _renderer_#sub[G] 2D#sub[G]) completamente nuovo,
capace di raggiungere prestazioni molto superiori alla piattaforma precedente.
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
  con una breve spiegazione del contesto che ha portato alla sua creazione.
  Successivamente, vengono fornite alcune indicazioni sulla struttura della tesi.
2. @chap:rendering-process: si spiega l'architettura adottata nello sviluppo del software.
3. @chap:gpu-programming: contiene un'introduzione ai concetti fondamentali di come lavorare con le moderne _GPU_.
4. @chap:composition: parla di come abbiamo utilizzato la _GPU_ per il progetto.
5. @chap:future-work: fornisce un riassunto del precedente documento.

Nel documento sono state adottate le seguenti convenzioni tipografiche:

- Gli acronimi, le abbreviazioni e i termini ambigui o di uso non comune menzionati vengono definiti nel glossario, situato alla fine del presente documento;
- Per la prima occorrenza dei termini riportati nel glossario viene utilizzata la seguente nomenclatura: _parola_#sub[G];
- I termini in lingua straniera o facenti parti del gergo tecnico sono evidenziati con il carattere _corsivo_.
