#import "/common/constants.typ": abstract
#set page(numbering: "i")
#counter(page).update(1)

#v(10em)

#text(24pt, font: "Merriweather", weight: "semibold", abstract)

#v(2em)

Il presente documento descrive il lavoro svolto durante il periodo di _stage_,
della durata di trecentododici ore,
dal laureando Samuele Esposito presso l'azienda UNOX S.p.A.

Il progetto consisteva nell'integrazione della _GPU_#sub[G]
all'interno di una libreria per creare interfacce utente
destinate ai forni di nuova generazione.
Nel documento si tratta di ciò che abbiamo appreso per il progetto di _stage_,
oltre ad alcuni accenni all'implementazione.

Durante il periodo di _stage_,
è stato necessario prima di tutto prendere confidenza con il codice esistente
e con la programmazione di _GPU_#sub[G].
Successivamente, si è proceduto a integrare ciò che avevamo appreso
con il codice esistente;
infine, si è proceduto a effettuare test di prestazioni,
per verificare se l'integrazione della _GPU_#sub[G]
avesse portato ai miglioramenti sperati.

#pagebreak()
