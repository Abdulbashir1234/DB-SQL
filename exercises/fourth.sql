-- Soluzione Quarto Esercizio
use sakila
SET @DELAY = 2;

SELECT "Numero di DVD presenti in ciascun negozio e in totale" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT store_id, COUNT(*) AS 'Numero DVD'
    FROM inventory
    GROUP BY store_id
    WITH ROLLUP;
SELECT "Numero di film presenti in ciascun negozio e in totale" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT store_id, COUNT(DISTINCT film_id) AS 'Numero film'
    FROM inventory
    GROUP BY store_id
    WITH ROLLUP;
SELECT "Numero di DVD del film 'AIRPORT POLLOCK'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT COUNT(*) AS 'Numero DVD di AIRPORT POLLOCK'
    FROM inventory
    WHERE film_id IN (SELECT film_id FROM film WHERE title = 'AIRPORT POLLOCK');
SELECT "Numero di noleggi effettuati da ciascun cliente" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT customer_id, COUNT(*) AS Noleggi
    FROM rental
    GROUP BY customer_id;
SELECT "Elenco dei 10 clienti con maggior numero di noleggi" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- N.B. : il cliente all'11° posto, potrebbe essere a pari merito con il 10°...
SELECT customer_id, COUNT(*) AS Noleggi
    FROM rental
    GROUP BY customer_id
    ORDER BY Noleggi DESC
    LIMIT 10;
SELECT "La minima, massima e media durata di un noleggio (attenzione ai valori null!!!)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- Devo escludere le righe con return_date = NULL,
-- cioè considerare solo i noleggi conclusi !!!
SELECT MIN(TIMEDIFF(return_date, rental_date)) AS Minima,
       MAX(TIMEDIFF(return_date, rental_date)) AS Massima,
       AVG(TIMEDIFF(return_date, rental_date)) AS Media
    FROM rental
    -- WHERE return_date IS NOT NULL
    -- funziona anche senza WHERE perchè le funzioni
    -- MIN, MAX e AVG "trascurano" i valori NULL
    ;
SELECT "Il numero di noleggi per ciascun mese/anno (si consideri la data di inizio *rental_date*)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT YEAR(rental_date) AS Anno, MONTH(rental_date) AS Mese, COUNT(*)
    FROM rental
    GROUP BY Anno, Mese;
SELECT "L'incasso totale per ciascun film" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT title, SUM(amount) AS Incasso
    FROM payment
        JOIN rental USING(rental_id)
        JOIN inventory USING(inventory_id)
        JOIN film USING(film_id)
    GROUP BY title, film_id;
SELECT "I film che hanno fatto incassare di più" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- Creazione VIEW dei film con relativo incasso
-- (per film con almeno un pagamento)
CREATE OR REPLACE VIEW film_cash AS
    SELECT film.*, SUM(amount) AS incasso
        FROM payment
            JOIN rental USING(rental_id)
            JOIN inventory USING(inventory_id)
            JOIN film USING(film_id)
        GROUP BY film_id;
-- Esecuzione query tramite view film_cash
SELECT title, incasso
    FROM film_cash
    WHERE incasso = ( SELECT MAX(incasso) FROM film_cash );
SELECT "L'incasso totale per ciascuna categoria di film, in ordine decrescente di incasso" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- Esecuzione query tramite view film_cash
SELECT name, SUM(incasso) AS totale
    FROM film_cash
        JOIN film_category USING(film_id)
        JOIN category USING(category_id)
    GROUP BY category_id
    ORDER BY totale DESC;
SELECT "Le categorie di film che hanno fatto incassare di più" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- Un po' ambigua: si intende quella o quelle con incasso massimo
SELECT name, SUM(incasso) AS totale
    FROM film_cash
        JOIN film_category USING(film_id)
        JOIN category USING(category_id)
    GROUP BY category_id
    HAVING totale = (
            SELECT SUM(incasso) AS totale
                FROM film_cash
                    JOIN film_category USING(film_id)
                    JOIN category USING(category_id)
                GROUP BY category_id
                ORDER BY totale DESC
                LIMIT 1
        )
    ORDER BY name;
SELECT "Le dieci categorie di film che hanno fatto incassare di più" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT name, SUM(incasso) AS totale
    FROM film_cash
        JOIN film_category USING(film_id)
        JOIN category USING(category_id)
    GROUP BY category_id
    ORDER BY totale DESC
    LIMIT 10;
SELECT "L'incasso totale per ciascun cliente" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT customer_id, first_name, last_name, SUM(amount) AS incasso
    FROM payment
        JOIN customer USING(customer_id)
    GROUP BY customer_id;
SELECT "I clienti che hanno fatto incassare di più" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- Un po' ambigua: si intende quello o quelli con incasso massimo
SELECT customer_id, first_name, last_name, SUM(amount) AS incasso
    FROM payment
        JOIN customer USING(customer_id)
    GROUP BY customer_id
    HAVING incasso =
            (SELECT SUM(amount) AS incasso
                FROM payment
                GROUP BY customer_id
                ORDER BY incasso DESC
                LIMIT 1
            );
