#pagebreak(to: "odd")

= Programmazione di GPU <chap:gpu-programming>

Le _GPU_ sono dispositivi estremamente potenti e flessibili.
Agiscono sostanzialmente come un acceleratore o un co-processore,
che agisce in maniera asincrona rispetto al processore principale,
il quale si occupa solamente di inviare comandi alla GPU,
che poi li eseguirà in autonomia.
La natura asincrona è estremamente importante,
dato che le _GPU_ presentano una memoria separata da quella principale,
e i trasferimenti da una all'altra sono relativamente lenti.

Inizialmente, le _GPU_ contenevano solamente una _pipeline_
esplicitamente progettata per il rendering di grafica 3D,
con l'obiettivo di consentire giochi con grafica sempre più avanzata.
Con il tempo, di conseguenza, si sono trasformate in veri e propri processori altamente paralleli.
Negli ultimi anni i progettisti si sono accorti, però,
che potevano esporre questo parallelismo direttamente agli utenti,
consentendo l'utilizzo di _GPU_ anche per operazioni non strettamente di grafica.

Al giorno d'oggi, le _GPU_ sono importantissime in ambiti scientifici o di intelligenza artificiale,
grazie alle elevate prestazioni raggiungibili negli algoritmi avanzati necessari per questi campi,
oltre che alla grafica. Segue una breve descrizione delle due _pipeline_ di una _GPU_ moderna.

== Pipeline grafica

La pipeline grafica una volta non era programmabile, ma ora presenta vertex shader e fragment shader.
È capace di disegnare solamente triangoli.

=== Tessellation

La _tessellation_, anche conosciuta come _triangulation_,
è una procedura che, dato una forma complessa, la trasforma in triangoli.

== Pipeline compute

La pipeline di compute è sostanzialmente un modo per
eseguire calcoli arbitrari in maniera estremamente parallela.
