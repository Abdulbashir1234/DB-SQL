-- Soluzione quinto Esercizio
use sakila
SET @DELAY = 2;

SELECT "Produrre una lista (nome, cognome ed email) dei clienti per lo store con id *STORE*" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @STORE = 1
SELECT first_name, last_name, email
    FROM customer
    WHERE store_id = @STORE;

SELECT "Produrre un elenco dei membri dello staff, con il rispettivo indirizzo completo" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT first_name, last_name, address, postal_code, city, country
    FROM staff s
        JOIN address a ON(s.address_id = a.address_id)
        JOIN city c ON(a.city_id = c.city_id)
        JOIN country co ON(c.country_id = co.country_id);

SELECT "Calcolare il numero di noleggi effettuati dai clienti di ciascuno store" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT store_id, COUNT(*) AS Noleggi
    FROM rental
        JOIN customer USING(customer_id)
    GROUP BY store_id;
    
SELECT "Verificare se nello store 1 esiste almeno una copia disponibile (non attualmente noleggiata da alcun cliente) del film 'ACADEMY DINOSAUR'." AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @TITLE = 'ACADEMY DINOSAUR';
-- 1a Versione: con subqueries
SELECT IF(COUNT(*) > 0, 'Disponibile', 'Non disponibile') AS Disponibilità
    FROM (
        SELECT inventory_id
            FROM inventory i JOIN film f USING(film_id)
            WHERE title = @TITLE AND store_id = 1 AND NOT EXISTS (
                    SELECT *
                        FROM rental r
                        WHERE r.inventory_id = i.inventory_id AND return_date IS NULL
                )
         ) Disponibili;
-- 2a Versione: con left join "anomalo"
SELECT IF(COUNT(*) > 0, 'Disponibile', 'Non disponibile') AS Disponibilità
    FROM inventory i
        JOIN film f USING(film_id)
        LEFT JOIN rental r ON (i.inventory_id = r.inventory_id AND return_date IS NULL)
    WHERE title = @TITLE AND i.store_id = 1 AND rental_id IS NULL;

SELECT "Determinare quanti noleggi sono attualmente in corso" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT COUNT(*) AS 'Noleggi in corso'
    FROM rental
    WHERE return_date IS NULL;

SELECT "Elenco dei clienti con più di tre noleggi attualmente in corso" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, first_name, COUNT(*) AS Noleggi
    FROM customer
        JOIN rental USING(customer_id)
    WHERE return_date IS NULL
    GROUP BY customer_id
    HAVING Noleggi > 3;

SELECT "Elenco dei clienti con un noleggio attualmente in corso da più di rental_duration giorni." AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, first_name, MAX(DATEDIFF(NOW(), rental_date) - rental_duration) AS eccesso
    FROM customer
        JOIN rental USING(customer_id)
        JOIN inventory USING(inventory_id)
        JOIN film USING(film_id)
    WHERE return_date IS NULL
    GROUP BY customer_id
    HAVING eccesso > 0;

SELECT "Determinare una lista delle categorie (distinte) di film in cui hanno recitato gli attori 'SUSAN DAVIS' o 'DAVIS SUSAN'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT DISTINCT c.name
    FROM category c
        JOIN film_category USING(category_id)
        JOIN film USING(film_id)
        JOIN film_actor USING(film_id)
        JOIN actor USING(actor_id)
    WHERE CONCAT(last_name, ' ', first_name) IN('SUSAN DAVIS', 'DAVIS SUSAN');

SELECT "Produrre un elenco dei DVD noleggiati più di *volte* volte (con un numero di noleggi maggiore di *volte*)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @VOLTE = 4;
SELECT inventory_id, COUNT(*) AS noleggi
    FROM inventory i
        JOIN rental r USING(inventory_id)
    GROUP BY inventory_id
    HAVING noleggi > @VOLTE;

SELECT "Produrre un elenco dei DVD noleggiati più di *giorni* giorni (con un totale di giorni di noleggio maggiore di *giorni*)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @GIORNI = 15;
SELECT inventory_id, SUM(DATEDIFF(return_date, rental_date)) AS giorni
    FROM inventory i
        JOIN rental r USING(inventory_id)
    GROUP BY inventory_id
    HAVING giorni > @GIORNI;

SELECT "Elenco dei clienti che hanno noleggiato il DVD con *inventory_id* = 17" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT DISTINCT last_name, first_name
    FROM customer
        JOIN rental USING(customer_id)
    WHERE inventory_id = 17;

SELECT "Elenco dei clienti che hanno noleggiato un DVD più di una volta" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT inventory_id, last_name, first_name
    FROM customer
        JOIN rental USING(customer_id)
    GROUP BY inventory_id, customer_id
    HAVING COUNT(*) > 1;

SELECT "Elenco dei clienti che hanno noleggiato lo stesso film più di una volta" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT title, last_name, first_name
    FROM customer
        JOIN rental USING(customer_id)
        JOIN inventory USING(inventory_id)
        JOIN film USING(film_id)
    GROUP BY film_id, customer_id
    HAVING COUNT(*) > 1;
