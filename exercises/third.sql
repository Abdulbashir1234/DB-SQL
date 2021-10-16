-- Soluzione Terzo Esercizio
use sakila
SET @DELAY = 2;

SELECT "Elenco dei nomi di attori in ordine alfabetico, evitando duplicati" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT first_name
    FROM actor
    GROUP BY first_name;
SELECT "Elenco dei cognomi di attori in ordine alfabetico decrescente, evitando duplicati" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name
    FROM actor
    GROUP BY last_name DESC;
SELECT "L'elenco dei clienti non attivi, con nome, cognome ed e-mail" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, first_name
    FROM customer
    WHERE NOT active;
    -- WHERE !active;
    -- WHERE active = FALSE;
    -- WHERE active != TRUE;
SELECT "L'elenco dei clienti attivi dello store 1, con nome, cognome ed e-mail" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, first_name, email
    FROM customer
    WHERE active AND store_id = 1;
SELECT "L'elenco degli indirizzi in cui address2 è NULL" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    WHERE address2 IS NULL;
SELECT "L'elenco degli indirizzi in cui address2 è la stringa vuota" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    WHERE address2 = '';
SELECT "L'elenco degli indirizzi in cui district è 'Texas'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    WHERE district = 'Texas';
SELECT "Il distretto il cui abita il cliente con id 576" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con subqueries
SELECT district
    FROM address
    WHERE address_id = (SELECT address_id FROM );
SELECT "Il distretto il cui abita il cliente 'WILLARD LUMPKIN'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @CLIENTE = 'WILLARD LUMPKIN';
-- 1a Versione: con JOIN
SELECT district
    FROM address JOIN customer USING (address_id)
    WHERE CONCAT(first_name, ' ', last_name) = @CLIENTE;
-- 2a Versione: con subquery
SELECT district
    FROM address
    WHERE address_id = ( SELECT address_id
                            FROM customer
                            WHERE CONCAT(first_name, ' ', last_name) = @CLIENTE
                        );
SELECT "Elenco dei generi (category) dei film" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: elenco di TUTTE le categorie (anche senza film)
SELECT name
    FROM category;
-- 2a Versione: elenco delle categorie con almeno un film
SELECT DISTINCT name
    FROM category JOIN film_category USING(category_id);
SELECT "Elenco delle nazioni" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT country
    FROM country;
SELECT "Elenco delle città in Argentina, in ordine alfabetico" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con subquery
SELECT city
    FROM city
    WHERE country_id = (SELECT country_id FROM country WHERE country = 'Argentina');
-- 2a Versione: con JOIN
SELECT city
    FROM city JOIN country USING(country_id)
    WHERE country = 'Argentina';
SELECT "Elenco dei clienti di Cordoba (typo Crdoba) in ordine alfabetico" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT first_name, last_name
    FROM customer c
        JOIN address USING (address_id)
        JOIN city USING (city_id)
    WHERE city = 'Crdoba'
    ORDER BY last_name, first_name;
SELECT "Elenco delle lingue in ordine alfabetico inverso" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT name
    FROM language
    ORDER BY name DESC;
SELECT "Numero di film in ciascuna delle lingue registrate" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT name, COUNT(film_id)
    FROM language LEFT OUTER JOIN film USING(language_id)
    GROUP BY language_id;
-- N.B. - INNER JOIN visualizza solo le lingue con almeno un film!!!
SELECT "Elenco dei nomi degli attori, con numero di attori omonimi (= con lo stesso nome)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT first_name, COUNT(*) AS numero
    FROM actor
    GROUP BY first_name;
SELECT "Elenco dei cognomi degli attori, con numero di attori omonimi (= con lo stesso cognome)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, COUNT(*) AS numero
    FROM actor
    GROUP BY last_name;
SELECT "Presenza o meno di attori omonimi (uguali nome e cognome)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT IF(COUNT(*) > 0, 'Presenti', 'Non presenti')
    FROM ( SELECT COUNT(*)
                FROM actor
                GROUP BY first_name, last_name
                HAVING COUNT(*) > 1
        ) Omonimi;
SELECT "Numero di pagamenti effettuati dal cliente 'WILLARD LUMPKIN'" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @CLIENTE = 'WILLARD LUMPKIN';
-- 1a Versione: con JOIN
SELECT COUNT(*)
    FROM customer JOIN payment USING (customer_id)
    WHERE CONCAT(first_name, ' ', last_name) = @CLIENTE;
-- 2a Versione: con subquery
SELECT COUNT(*)
    FROM payment
    WHERE customer_id = ( SELECT customer_id
                            FROM customer
                            WHERE CONCAT(first_name, ' ', last_name) = @CLIENTE
                        );
SELECT "Elenco dei clienti, con numero di noleggi e numero di pagamenti effettuati da ciascun cliente" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con JOIN
SELECT CONCAT(first_name, ' ', last_name) AS customer,
       COUNT(DISTINCT r.rental_id) AS noleggi,
       COUNT(DISTINCT payment_id) AS pagamenti
    FROM customer
        LEFT OUTER JOIN rental r USING(customer_id)
        LEFT OUTER JOIN payment USING(customer_id)
    GROUP BY customer_id;
-- 2a Versione: con subquery
SELECT CONCAT(first_name, ' ', last_name) AS customer,
        (SELECT COUNT(*) FROM rental r WHERE r.customer_id = c.customer_id) AS noleggi,
        (SELECT COUNT(*) FROM payment p WHERE p.customer_id = c.customer_id) AS pagamenti
    FROM customer c;
SELECT "Elenco dei noleggi in corso il giorno 2005-06-18" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT *
    FROM rental
    -- WHERE rental_date <= '2005-06-18' AND IFNULL(return_date, '2005-06-18') >= '2005-06-18';
    WHERE '2005-06-18' BETWEEN rental_date AND IFNULL(return_date, '2005-06-18');
