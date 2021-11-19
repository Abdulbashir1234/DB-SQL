--  1 Produrre l'elenco dei film (title, rating e rental_rate) ordinato per rental_rate decrescente.
SELECT title, rating, rental_rate
    FROM film
    ORDER BY rental_rate DESC;
--  2 Produrre l'elenco dei film (title, rental_rate e replacement_cost) per i quali il triplo del rental_rate è maggiore del replacement_cost.
SELECT title, rental_rate, replacement_cost
    FROM film
    WHERE 3 * rental_rate > replacement_cost;
--  3 Produrre l'elenco dei clienti (last_name, first_name) per i quali la lunghezza complessiva di nome e cognome è maggiore di 15 caratteri.
SELECT last_name, first_name
    FROM customer
    WHERE LENGTH(last_name) + LENGTH(first_name) > 15;
--  4 Determinare il numero di film la cui descrizione è più lunga di 100 caratteri.
SELECT COUNT(*)
    FROM film
    WHERE LENGTH(description) > 100;
--  5 Elencare il numero di film usciti (release_year) in ciascun anno, ma solo per gli anni in cui sono usciti almeno 10 film.
SELECT release_year, COUNT(*) AS numero_film
    FROM film
    GROUP BY release_year
    HAVING numero_film >= 10;
--  6 Produrre un elenco dei film (title, replacement_cost, payment) per il cui noleggio è stata pagata una somma maggiore del replacement_cost.
SELECT title, replacement_cost, SUM(amount) AS payment
    FROM film f
        JOIN inventory i USING(film_id)
        JOIN rental r USING(inventory_id)
        JOIN payment p USING(rental_id)
    GROUP BY film_id
    HAVING payment > replacement_cost;
--  7 Elenco dei film (title, rental_date, return_date) noleggiati dal cliente 'SUSAN WILSON'.
SET @CLIENT = 'SUSAN WILSON';
SELECT title, rental_date, return_date
    FROM film f
        JOIN inventory i USING(film_id)
        JOIN rental r USING(inventory_id)
        JOIN customer c USING(customer_id)
    WHERE CONCAT(last_name, ' ', first_name) = @CLIENT OR
            CONCAT(first_name, ' ', last_name) = @CLIENT;

--  8 Elenco dei film (title, n_clienti) noleggiati da almeno 5 clienti diversi.
SELECT title, COUNT(DISTINCT customer_id) AS n_clienti
    FROM film f
        JOIN inventory i USING(film_id)
        JOIN rental r USING(inventory_id)
    GROUP BY film_id
    HAVING n_clienti >= 5;
--  9 Elenco degli attori (last_name, first_name) che hanno recitato in almeno cinque film.
SELECT last_name, first_name
    FROM actor a
        JOIN film_actor fa USING(actor_id)
    GROUP BY actor_id
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
