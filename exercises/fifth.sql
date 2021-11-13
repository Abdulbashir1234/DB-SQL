-- Soluzione quinto Esercizio
use sakila
SET @DELAY = 2;

SELECT "Elenco dei clienti, ordinati per nazione e città" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT country, city, last_name, first_name
    FROM customer c
        JOIN address a ON(c.address_id = a.address_id)
        JOIN city ci ON(a.city_id = ci.city_id)
        JOIN country co ON(ci.country_id = co.country_id)
    ORDER BY country, city;
-- prolisso, ma si possono usare subquery...
SELECT (SELECT country
            FROM country
            WHERE country_id = (SELECT country_id
                                    FROM city
                                    WHERE city_id = (SELECT city_id
                                                        FROM address
                                                        WHERE address_id = c.address_id)
                                )
        ) AS nazione,
       (SELECT city
            FROM city
            WHERE city_id = (SELECT city_id
                                FROM address
                                WHERE address_id = c.address_id)
        ) AS citta,
        last_name, first_name
    FROM customer c
    ORDER BY nazione, citta;
-- oppure si usano le view, magari già esistenti
SELECT country, city, name
    FROM customer_list
    ORDER BY country, city;
SELECT "Numero di clienti attivi per ciascuna nazione" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- solo country con almeno un cliente
SELECT country, COUNT(*) AS clienti
    FROM customer c
        JOIN address a ON(c.address_id = a.address_id)
        JOIN city ci ON(a.city_id = ci.city_id)
        JOIN country co ON(ci.country_id = co.country_id)
    WHERE active
    GROUP BY co.country_id; -- consente country omonime !!!
    -- GROUP BY country;    -- raggruppa country omonime !!!
-- anche country senza clienti
SELECT country,
        (SELECT COUNT(*)
            FROM customer
            WHERE active AND address_id IN
                (SELECT address_id
                    FROM address
                    WHERE city_id IN
                        (SELECT city_id
                            FROM city
                            WHERE country_id = c.country_id
                        )
                )
        ) AS clienti
    FROM country c;
-- oppure si usano le view, magari già esistenti
SELECT country, COUNT(*) AS Clienti
    FROM customer_list
    WHERE notes = 'active'
    GROUP BY country;
SELECT "Numero di clienti attivi per ciascuna città" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- solo city con almeno un cliente
SELECT city, COUNT(*) AS clienti
    FROM customer c
        JOIN address a ON(c.address_id = a.address_id)
        JOIN city ci ON(a.city_id = ci.city_id)
    WHERE active
    GROUP BY ci.city_id; -- consente city omonime !!!
    -- GROUP BY city;    -- raggruppa city omonime !!!
-- anche city senza clienti
SELECT city,
        (SELECT COUNT(*)
            FROM customer
            WHERE active AND address_id IN
                (SELECT address_id
                    FROM address
                    WHERE city_id = c.city_id
                )
        ) AS clienti
    FROM city c;
-- oppure si usano le view, magari già esistenti
SELECT city, COUNT(*) AS Clienti
    FROM customer_list
    WHERE notes = 'active'
    GROUP BY city;
SELECT "Elenco dei clienti che non hanno effettuato noleggi da almeno 30 giorni" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT last_name, first_name, MIN(DATEDIFF(NOW(), IFNULL(rental_date, '1900-01-01'))) AS giorni
    FROM customer
        LEFT JOIN rental USING(customer_id)
    GROUP BY customer_id
    HAVING giorni > 30;    
SELECT "Elenco dei clienti che hanno effettuato almeno un noleggio nel periodo in un dato periodo (data inizio, data fine)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SET @INIZIO = '2005-05-01';
SET @FINE = '2005-05-31';
SELECT last_name, first_name
    FROM customer
    WHERE customer_id IN
        (SELECT customer_id
            FROM rental
            WHERE rental_date BETWEEN @INIZIO AND @FINE
        );
SELECT "Elenco dei clienti che hanno effettuato almeno dieci noleggi" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con subquery
SELECT last_name, first_name
    FROM customer c
    WHERE 10 <= (SELECT COUNT(*)
                    FROM rental r
                    WHERE r.customer_id = c.customer_id
                );
-- 2a Versione: con JOIN
SELECT last_name, first_name
    FROM customer c
        JOIN rental USING(customer_id)
    GROUP BY customer_id
    HAVING 10 <= COUNT(*)
    ORDER BY last_name, first_name;
-- Si noti che "invertendo" la condizione
-- (cioè: hanno effettuato meno di dieci noleggi
-- e quindi cambiando il <= in >)
-- il risultato è diverso !!!!
SELECT "Elenco di link 'mailto:<indirizzo>?Subject=Sollecito' per i clienti che non hanno ancora pagato un noleggio effettuato" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con JOIN
SELECT CONCAT('mailto:', email, '?Subject=Sollecito') AS link
    FROM customer c
        JOIN rental USING(customer_id)
        LEFT JOIN payment p USING(rental_id)
    WHERE payment_id IS NULL;
-- 2a Versione: con subquery
SELECT CONCAT('mailto:', email, '?Subject=Sollecito') AS link
    FROM customer c
    WHERE 1 <= (SELECT COUNT(*)
                    FROM rental r
                    WHERE r.customer_id = c.customer_id
                        AND rental_id NOT IN (SELECT rental_id FROM payment WHERE rental_id IS NOT NULL)
                );
-- IS NOT NULL nella subquery è NECESSARIO!!! (altrimenti NOT IN ritorna NULL)
SELECT "Elenco di link 'mailto:<indirizzo>?Subject=Bonus' per i clienti che hanno fatto incassare un importo >= 100" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
SELECT CONCAT('mailto:', email, '?Subject=Bonus') AS link
    FROM customer c
        JOIN payment p USING(customer_id)
    GROUP BY customer_id
    HAVING SUM(amount) >= 100;
SELECT "Elenco dei clienti con categoria preferita (quella con maggiore numero di film noleggiati)" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- tramite view per semplificare
CREATE OR REPLACE VIEW customer_category AS
    SELECT customer.*, name, COUNT(*) AS noleggi
        FROM customer
            JOIN rental USING(customer_id)
            JOIN inventory USING(inventory_id)
            JOIN film_category USING(film_id)
            JOIN category USING(category_id)
        GROUP BY customer_id, category_id;
SELECT last_name, first_name, name
    FROM customer_category c
    WHERE noleggi = (SELECT MAX(noleggi) FROM customer_category cc WHERE cc.customer_id = c.customer_id);
SELECT last_name, first_name, GROUP_CONCAT(name,', ') AS preferite
    FROM customer_category c
    WHERE noleggi = (SELECT MAX(noleggi) FROM customer_category cc WHERE cc.customer_id = c.customer_id)
    GROUP BY customer_id;
SELECT "Elenco dei film che non sono mai stati noleggiati" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- 1a Versione: con subquery
SELECT title
    FROM film
    WHERE film_id NOT IN (SELECT film_id
                            FROM inventory
                            WHERE inventory_id IN (SELECT inventory_id FROM rental)
                        );
-- 2a Versione: con JOIN
SELECT title
    FROM film f
        LEFT JOIN inventory USING(film_id)
        LEFT JOIN rental USING(inventory_id)
    WHERE rental_id IS NULL;
SELECT "Elenco dei film che sono stati noleggiati almeno 5 volte" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- tramite view per semplificare
CREATE OR REPLACE VIEW film_rental AS
    SELECT film.*, COUNT(*) AS noleggi
        FROM film
            JOIN inventory USING(film_id)
            JOIN rental USING(inventory_id)
        GROUP BY film_id;
SELECT title
    FROM film_rental
    WHERE noleggi >= 5;
SELECT "Numero di noleggi per ciascuna categoria di film" AS Query;
SET @DELAY = @DELAY + SLEEP(@DELAY)
-- tramite la view customer_category
SELECT name, SUM(noleggi) AS noleggi
    FROM customer_category
    GROUP BY name;
