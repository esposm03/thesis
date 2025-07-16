#pagebreak(to: "odd")

= Conclusioni <chap:future-work>

È stato descritta l'attività svolta durante lo _stage_ presso UNOX S.p.A.
Lo stage si è articolato in più fasi:
1. *Presa di familiarità col codice del progetto*:
  in questa fase ho implementato alcune piccole modifiche,
  con lo scopo di acquisire dimestichezza con la _codebase_.
2. *Ricerca in ambito _GPU_*:
  durante questa fase, io e l'altro stagista
  ci siamo concentrati sul cercare di capire come funzionasse la programmazione di _GPU_;
  sono stati molto utili alcuni concetti imparati durante il corso di Algebra Lineare.
3. *Progettazione della composizione*:
  qui, ci siamo occupati di come applicare le conoscenze acquisite sulla _GPU_
  al problema da risolvere.
  Questa è stata sicuramente la fase più interessante,
  anche se relativamente breve.
  Durante questa fase abbiamo sviluppato numerosi prototipi,
  che ci sono serviti per comprendere meglio il lavoro da fare.
4. *Implementazione*:
  infine, ci siamo concentrati principalmente sull'implementazione
  di ciò che avevamo appreso precedentemente all'interno del prototipo.

== Possibili sviluppi futuri

Come discusso in @chap:composition:approccio-3d,
l'approccio attualmente adattato è relativamente lento,
in quanto effettua una _draw call_ separata per ogni _layer_.
Una possibile soluzione sarebbe quella di implementare "batching":
ogni _draw call_ potrebbe comporre fino a un certo numero (fisso, non variabile a _runtime_)
di _layer_ nello stesso passaggio, ognuno con la propria _texture_.
Nella pratica, però, questo è sembrato non essere un grande collo di bottiglia;
al contrario, l'impatto maggiore sulle prestazioni sembrava essere
il caricamento sulla _GPU_ delle _texture_ dei _layer_
(in quanto un _layer_ può essere potenzialmente anche molto grande).

Una soluzione che avevamo proposto era quella di
effettuare anche la fase di _layering_ sulla _GPU_;
così facendo, sarebbe stato necessario caricare
solamente i risultati della fase di _raster_,
con la conseguenza che, qualora uno di essi venisse modificato
(pensiamo, per esempio, al cambio di colore di un bottone quando viene cliccato),
il suo _buffer_ (potenzialmente molto più piccolo del _buffer_ di _layer_)
sarebbe l'unico da caricare.

Un altro potenzialmente miglioramento sarebbe quello di
effettuare anche la fase di _raster_ in _GPU_,
sfruttando librerie come Vello @vello create appositamente per questo scopo.

Purtroppo, entrambi questi cambiamenti si sono
scontrati contro la volontà dell'azienda,
in quanto avrebbero necessitato di notevoli _refactor_
che, a loro detta, non avevano tempo di ricontrollare
prima di inserirli "in produzione".

== Valutazione personale

Ho trovato estremamente interessante il progetto di _stage_;
è raro, in Italia, avere la possibilità di toccare nello stesso momento
temi come la programmazione di _GPU_ o utilizzare linguaggi avanzati come _Rust_,
e, anche se già avevo qualche base di programmazione di _GPU_,
sicuramente questo progetto ha aiutato moltissimo nel consolidarle.

Purtroppo, ai fattori positivi del progetto in sé
se ne aggiungono di negativi relativi all'ambiente in azienda:
prima di tutto, il codice su cui io e l'altro stagista ci siamo ritrovati a lavorare
era incredibilmente inadatto all'integrazione della _GPU_.
Questo era evidente, ma nonostante ciò ci è stato
negato il permesso di effettuare i _refactor_ necessari.
Di conseguenza, il codice che abbiamo prodotto durante lo _stage_ non è utilizzabile,
ma andrà sicuramente riscritto quasi completamente.

Inoltre, questi _refactor_ sono inizialmente stati rifiutati
con la motivazione che l'azienda non aveva sufficiente tempo
per fare _review_ del codice entro la fine dello _stage_,
quindi era necessario fare tutto più semplice in modo che la _review_ fosse rapida.
Verso la fine dello _stage_, però, ci è stato detto che la _review_
non sarebbe comunque avvenuta prima della fine dello _stage_ stesso.

Un altro elemento che personalmente ho trovato come di attrito è stato che lo _stage_
era adatto a un singolo stagista, mentre oltre al
sottoscritto era stato selezionato anche un secondo stagista.
La conseguenza è che è stato, spesso, difficile fare lavoro significativo.
Inoltre, capitava spesso che passassero anche settimane
tra un contatto di natura tecnica con il tutor, e il successivo.

In conclusione, personalmente mi sono sentito
poco significativo al progresso dell'azienda
per mancanze non mie.
Nonostante questo il progetto è stato interessante
e probabilmente lo sceglierei una seconda volta se potessi,
nonostante l'ambiente poco accogliente che mi sento di aver trovato.
