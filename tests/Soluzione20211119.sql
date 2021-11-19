
--  1 Produrre l'elenco dei film (title, rating e rental_duration) ordinato per rental_duration decrescente.
SELECT title, rating, rental_duration
    FROM film
    ORDER BY rental_duration DESC;

--  2 Produrre l'elenco dei pagamenti (amount, payment_date, customer_id) del mese di giugno 2005 con importo superiore a 3,00.
SELECT amount,  payment_date, customer_id
    FROM payment
    WHERE payment_date BETWEEN '2005-06-01' AND '2005-06-30' AND amount > 3.00;

--  3 Produrre l'elenco degli attori (last_name, first_name) per i quali la lunghezza del nome è maggiore di quella del cognome.
SELECT last_name, first_name
    FROM actor
    WHERE LENGTH(first_name) > LENGTH(last_name);

--  4 Determinare il numero di film con rating ‘PG-13’ (PG-13: Parents Strongly Cautioned, Some Material May Be Inappropriate for Children Under 13).
SELECT COUNT(*)
    FROM film
    WHERE rating = 'PG-13';

--  5 Elencare il numero di film usciti (release_year) in ciascun anno, ma solo per gli anni in cui sono usciti almeno 10 film.
SELECT release_year, COUNT(*) AS numero_film
    FROM film
    GROUP BY release_year
    HAVING numero_film >= 10;

--  6 Produrre un elenco dei DVD (inventory_id, film.title, replacement_cost, payment) per il cui noleggio è stata pagata una somma maggiore del replacement_cost.
SELECT inventory_id, title, replacement_cost, SUM(amount) AS payment
    FROM inventory i
        JOIN film f USING(film_id)
        JOIN rental r USING(inventory_id)
        JOIN payment p USING(rental_id)
    GROUP BY inventory_id
    HAVING payment > replacement_cost;

--  7 Elenco dei noleggi (film.title, rental_date, return_date) effettuati dal cliente 'SUSAN WILSON'.
SET @CLIENT = 'SUSAN WILSON';
SELECT title, rental_date, return_date
    FROM film f
        JOIN inventory i USING(film_id)
        JOIN rental r USING(inventory_id)
        JOIN customer c USING(customer_id)
    WHERE CONCAT(last_name, ' ', first_name) = @CLIENT OR
            CONCAT(first_name, ' ', last_name) = @CLIENT;

--  8 Elenco dei DVD (inventory_id, n_clienti) noleggiati da almeno 5 clienti diversi.
SELECT inventory_id, COUNT(DISTINCT customer_id) AS n_clienti
    FROM inventory i
        JOIN rental r USING(inventory_id)
    GROUP BY inventory_id
    HAVING n_clienti >= 5;

--  9 Elenco dei film (title) in cui hanno recitato almeno cinque attori.
SELECT title
    FROM film f
        JOIN film_actor fa USING(film_id)
    GROUP BY film_id
    HAVING COUNT(*) >= 5;
-- 10 Elenco dei DVD (inventory_id) per i quali risultano noleggi contemporanei (cioè per i quali risultano almeno due noleggi temporalmente sovrapposti).
SELECT DISTINCT r1.inventory_id -- , r1.rental_date, r1.return_date, r2.rental_date, r2.return_date
    FROM rental r1, rental r2
    WHERE r1.rental_id != r2.rental_id          -- escluso lo stesso noleggio 2 volte
        AND r1.inventory_id = r2.inventory_id   -- stesso DVD
        AND r1.rental_date BETWEEN r2.rental_date AND IFNULL(r2.return_date, NOW());

SELECT DISTINCT r1.inventory_id -- , r1.rental_date, r1.return_date, r2.rental_date, r2.return_date
    FROM rental r1
        JOIN rental r2 ON(r1.rental_id != r2.rental_id AND r1.inventory_id = r2.inventory_id)
    WHERE r1.rental_date BETWEEN r2.rental_date AND IFNULL(r2.return_date, NOW());
