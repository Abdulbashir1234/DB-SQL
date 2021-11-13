use sakila
SET @DELAY = 2;
SELECT "Elenco degli attori in ordine alfabetico (cognome e nome)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT last_name, first_name
    FROM actor
    ORDER BY last_name, first_name;
SELECT "Elenco dei film in ordine di durata decrescente" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT title, length
    FROM film
    ORDER BY length DESC;
SELECT "Elenco dei film in ordine di numero di attori decrescente" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
-- 1a Versione: esclude i film senza attori !!!
SELECT title, COUNT(*) AS attori
    -- FROM film JOIN film_actor USING(film_id)
    FROM film f JOIN film_actor fa ON (f.film_id = fa.film_id)
    GROUP BY f.film_id
    ORDER BY attori DESC;
-- 2a Versione: NON esclude i film senza attori !!!
SELECT title, COUNT(actor_id) AS attori
    -- FROM film LEFT OUTER JOIN film_actor USING(film_id)
    FROM film f LEFT OUTER JOIN film_actor fa ON (f.film_id = fa.film_id)
    GROUP BY f.film_id
    ORDER BY attori DESC;
SELECT "Elenco dei film nel cui titolo compare la parola 'ISLAND'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT title
    FROM film
    WHERE title LIKE '%ISLAND%';
SELECT "Elenco dei film il cui titolo inizia per 'A'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT title
    FROM film
    WHERE title LIKE 'A%';
SELECT "Elenco dei film il cui titolo finisce per 'T'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT title
    FROM film
    WHERE title LIKE '%T';
SELECT "Elenco degli attori il cui nome inizia per 'A'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT first_name, last_name
    FROM actor
    WHERE first_name LIKE 'A%';
SELECT "Elenco degli attori il cui nome finisce per 'T'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT first_name, last_name
    FROM actor
    WHERE first_name LIKE '%T';
SELECT "Elenco degli attori nel cui nome compare la stringa 'land'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT first_name, last_name
    FROM actor
    WHERE first_name LIKE '%LAND%';
SELECT "Per ciascuno degli elenchi precedenti, il numero di voci presenti" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT "In generale: SELECT COUNT(*) FROM (la query che fornisce l'elenco) Tabella;" AS Soluzione;
-- Esempio (ovviamente ORDER BY qui diventa inutile!!!):
SELECT COUNT(*)
    FROM (
        SELECT last_name, first_name
            FROM actor
            ORDER BY last_name, first_name
    ) Tabella;
-- N.B. l'alias per la subquery è obbligatorio!!!

SELECT "Qual è l'id dell'attore << nome >> << cognome >>?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SET @NOME = 'BURT';
SET @COGNOME = 'DUKAKIS';
SELECT actor_id, CONCAT(first_name, ' ', last_name) AS 'Solo per verifica!'
    FROM actor
    WHERE first_name = @NOME AND last_name = @COGNOME;
SELECT "Quali attori hanno nome 'John'?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT first_name, last_name
    FROM actor
    WHERE first_name = 'John';
SELECT "Qual è il titolo dei film in cui ha recitato l'attore << nome >> << cognome >>?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
-- 1a versione con JOIN e filtro
SELECT title
    FROM film f
        JOIN film_actor fa ON (f.film_id = fa.film_id)
        JOIN actor a ON (a.actor_id = fa.actor_id)
    WHERE first_name = @NOME AND last_name = @COGNOME;
-- 2a versione con subqueries
SELECT title
    FROM film f
    WHERE film_id IN
        ( SELECT film_id
            FROM film_actor
            WHERE actor_id = ( SELECT actor_id FROM actor WHERE first_name = @NOME AND last_name = @COGNOME )
        );
    
SELECT "Qual è la coppia (o le coppie, se più di una) di attori che ha collaborato (recitato insieme) il maggior numero di volte?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
-- 1a fase: creazione view per semplificare la query
CREATE OR REPLACE VIEW Collaboration AS
    SELECT fa1.actor_id AS id1, fa2.actor_id AS id2, COUNT(*) AS times, GROUP_CONCAT(fa1.film_id separator ', ') AS films
        FROM film_actor fa1
            JOIN film_actor fa2 ON (fa1.film_id = fa2.film_id AND fa2.actor_id > fa1.actor_id)
        GROUP BY fa1.actor_id, fa2.actor_id;
-- 2a fase: uso della view come tabella
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, times, films
    FROM actor a1
        JOIN Collaboration ON (a1.actor_id = id1)
        JOIN actor a2 ON (id2 = a2.actor_id)
    WHERE times = ( SELECT MAX(times) FROM Collaboration );

-- Altra possibilità con una CTE (Common Table Expression)
WITH Collaborations AS
    ( SELECT fa1.actor_id AS id1, fa2.actor_id AS id2, COUNT(*) AS times, GROUP_CONCAT(fa1.film_id separator ', ') AS films
        FROM film_actor fa1
            JOIN film_actor fa2 ON (fa1.film_id = fa2.film_id AND fa2.actor_id > fa1.actor_id)
        GROUP BY fa1.actor_id, fa2.actor_id )
    SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, times, films
        FROM actor a1
            JOIN Collaborations ON (a1.actor_id = id1)
            JOIN actor a2 ON (id2 = a2.actor_id)
        WHERE times = ( SELECT MAX(times) FROM Collaborations );

SELECT "Quale film ha il cast più numeroso?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
SELECT title
    FROM film f
    WHERE ( SELECT COUNT(*) FROM film_actor fa WHERE f.film_id = fa.film_id ) =
        ( SELECT MAX(c) FROM ( SELECT COUNT(*) AS c FROM film_actor GROUP BY film_id ) AS counts );
-- N.B. l'alias per la subquery è obbligatorio!!!

SELECT "Quante volte hanno recitato insieme le possibili coppie di attori?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
-- Sfrutto la view Collaboration, ma questa esclude i valori 0!
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, IFNULL(times, 0), IFNULL(films, 'N/A')
    FROM actor a1
        JOIN actor a2 ON (a2.actor_id > a1.actor_id)
        LEFT JOIN Collaboration ON (a1.actor_id = id1 AND id2 = a2.actor_id);

SELECT "Quante volte hanno recitato insieme le possibili coppie di attori (escludendo i valori 0)?" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY);
-- Sfrutto la view Collaboration
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, times, films
    FROM actor a1
        JOIN Collaboration ON (a1.actor_id = id1)
        JOIN actor a2 ON (id2 = a2.actor_id);

