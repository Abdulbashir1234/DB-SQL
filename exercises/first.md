# Primo Esercizio
(Si suppone che abbiate a disposizione un server DB)

Creare il database *sakila* ed inserirvi i dati di esempio forniti.

([qui trovate gli script necessari](https://dev.mysql.com/doc/index-other.html))

> Per eseguire uno script, potete usare, ad es.:
> * mysql -u user -p < script.sql
> 
> oppure, dal prompt di mysql:
> * *MariaDB [(none)]>* source script.sql


Rispondere alle seguenti domande:
> Comandi utili:
> * SHOW *objects* (dove *objects* = tables, triggers, ...)
> * SHOW CREATE TABLE *table*|*view*
> * SHOW CREATE *object_type* *object_name*
> * DROP *object_type* *object_name*
* Quante e quali tabelle ci sono?
* Quante sono tabelle di dati e quante sono tabelle virtuali (*views)?
* Quale istruzione SQL ci consente di creare la tabella *store*?
* Quale istruzione SQL ci consente di creare la view *actor_info*?
* Quanti *triggers* ci sono nel database?
* Quale istruzione SQL ci consente di creare il trigger *payment_date*?
* Si può eliminare la tabella *actor*? Perché?
* Si può eliminare la view *actor_info*? Perché?

Tramite l'applicazione DBeaver, collegarsi al server DB.
* Visualizzare il diagramma ER del database *sakila*.
* Rispondere alle domande precedenti utilizzando l'interfaccia grafica.
* Quali altri oggetti (oltre a tables, views e triggers) ci sono nel database?
* Eliminare il database e ricrearlo tramite l'interfaccia grafica.
