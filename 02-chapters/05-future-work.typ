#pagebreak(to: "odd")

= Conclusioni <chap:future-work>

Il progetto di _stage_ svolto presso l'azienda UNOX S.p.A. ha prodotto
risultati interessanti per quanto riguarda le prestazioni del _rendering_ di
interfacce grafiche.

È stato possibile implementare un sistema di composizione che permette di
ottenere prestazioni migliori rispetto al sistema precedente, in quanto il
_rendering_ avviene in modo più efficiente sfruttando le capacità della _GPU_.

A discapito delle previsioni, i tentativi iniziali di sviluppo
dell'integrazione non hanno portato a risultati concreti: l'approccio
inizialmente adottato per la composizione in _GPU_ si è rilevato essere non
implementabile a causa delle limitazioni dello standard di _WebGPU_. Nonostante
ciò, la problematica è stata risolta optando per una composizione progressiva
degli elementi, gestiti singolarmente tramite il sistema di composizione.

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

Tuttavia, non è stato possibile implementare nessuno di questi miglioramenti,
poiché avrebbero richiesto importanti _refactor_ del codice esistente, non
sostenibili da effettuare nei tempi imposti per la consegna del _Proof of
Concept_ imposto dagli _stakeholder_ al _team_ di sviluppo _software_.

== Valutazione personale

Personalmente, ritengo estremamente interessante il progetto di _stage_: in
Italia individuare un progetto che combini la programmazione di _GPU_ o
utilizzare linguaggi avanzati come _Rust_ è estremamente raro. Nonostante le
conoscenze di base da me possedute relative a queste due tecnologie, questo
progetto ha sicuramente contribuito a consolidarle.

Tuttavia, il codice su cui è stato sviluppata la funzionalità oggetto della
tesi risultava inadatto a tale scopo, in quanto lo sviluppo dello stesso non
era stato progettato per l'integrazione della _GPU_.

Ritengo inoltre che, nonostante la natura del progetto, ovvero un prototipo non
pienamente stabile, siano state prese delle decisioni a mio parere poco adatte
e che, se evitate, avrebbero potuto portare valore aggiunto al prodotto finale
al termine dello _stage_.

In conclusione, nonostante le problematiche riscontrate durante il periodo di
tirocinio, ritengo che quest'ultimo sia risultato interessante e formativo,
permettendomi di consolidare le conoscenze in merito alle tecnologie
utilizzate.
