# Progetto Reti logiche 2019/2020
## Specifica
La specifica è ispirata al metodo di codifica a bassa dissipazione di potenza denominato “Working Zone”: lo scopo del progetto è implementare un componente hardware, descritto in VHDL, che, preso in ingresso un address (8 bit con indirizzi validi tra 0 e 127) ed un pool di 8 working zone definita come un intervallo di indirizzi di dimensione fissa che parte da un indirizzo base (anch’esso ad 8 bit), calcola se l’address appartiene ad una working zone.
Maggiori dettagli nel file **specifiche.pdf**

## Metodo di progettazione
Per progettare il componente ho utilizzato un approccio a due fasi, progettando prima il datapath (il percorso dei dati tra componenti di operazioni algebriche, selettori e condizioni) e poi la vera e propria macchian a stati.
Progettare prima il datapath e gestire i segnali in entrata e uscita dai componenti indipendentemente dalla macchina a stati mi ha semplificato di molto il lavoro sull'ultima.
