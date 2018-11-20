#Zadanie1
SHOW tables;

#Zadanie2
SELECT film.title FROM film WHERE film.length > 120;

#Zadanie3
SELECT film.title, language.name
FROM film JOIN language ON film.language_id = film.language_id
WHERE film.description LIKE '%Documentary%';

#Zadanie4
SELECT film.title
FROM film JOIN film_category ON film.film_id = film_category.film_id JOIN category ON film_category.category_id = category.category_id
WHERE category.name LIKE 'Documentary' AND film.description NOT LIKE '%Documentary%';

#Zadanie5
SELECT DISTINCT actor.first_name, actor.last_name
FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id JOIN film ON film.film_id = film_actor.film_id
WHERE film.special_features LIKE '%Deleted Scenes%';

#Zadanie6
SELECT film.rating, COUNT(film.film_id)
FROM film
GROUP BY film.rating;

#Zadanie7
SELECT film.title
FROM film JOIN inventory ON film.film_id = inventory.film_id JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE (DAY(rental.rental_date) BETWEEN 25 AND 30) AND (MONTH(rental.rental_date) = 5) AND (YEAR(rental.rental_date) = 2005);

#Zadanie8
SELECT film.title, rating, length
FROM film
WHERE film.rating LIKE 'R'
ORDER BY film.length DESC [LIMIT 5]; (opcjonalnie)

#Zadanie9
SELECT DISTINCT customer.first_name, customer.last_name
FROM
 (SELECT rental.customer_id, rental.staff_id FROM rental) AS A
 LEFT OUTER JOIN
 (SELECT rental.customer_id, rental.staff_id FROM rental) AS B
 ON A.customer_id = B.customer_id JOIN customer ON customer.customer_id = A.customer_id
WHERE A.staff_id < B.staff_id;

#Zadanie10
SELECT tmp.country
FROM
    (SELECT country.country_id, country.country, COUNT(city.city_id) AS quantity
	FROM country JOIN city ON country.country_id = city.country_id
	GROUP BY country.country_id) AS tmp
WHERE tmp.quantity >= (SELECT COUNT(city.city_id)
						FROM country JOIN city ON country.country_id = city.country_id
                        WHERE country.country LIKE 'Canada' );

#Zadanie11
SELECT tmp.customer_id, tmp.quantity
FROM
	(SELECT rental.customer_id, COUNT(rental.inventory_id) as quantity
	FROM rental
	GROUP BY rental.customer_id) AS tmp
WHERE tmp.quantity > (SELECT COUNT(rental.inventory_id)
						FROM customer JOIN rental ON customer.customer_id = rental.customer_id
						WHERE customer.email LIKE 'PETER.MENARD@sakilacustomer.org');

#Zadanie12
SELECT tmp.A1, tmp.A2, COUNT(tmp.film_id)
FROM
	(SELECT a.film_id, a.actor_id AS A1, b.actor_id AS A2
	FROM
		(SELECT film_actor.actor_id, film_actor.film_id FROM film_actor) AS a
		 JOIN
		(SELECT film_actor.actor_id, film_actor.film_id FROM film_actor) AS b
		ON a.film_id = b.film_id
	WHERE a.actor_id < b.actor_id) AS tmp
GROUP BY tmp.A1, tmp.A2
HAVING COUNT(tmp.film_id) > 1;

#Zadanie13
SELECT DISTINCT actor.last_name
FROM
	(SELECT film_actor.actor_id, film_actor.film_id, film.title
	FROM film_actor JOIN film ON film_actor.film_id = film.film_id
	WHERE film.title NOT LIKE "B%") AS TMP
	JOIN actor ON TMP.actor_id = actor.actor_id;

#Zadanie14
SELECT actor.last_name
FROM
    ((SELECT film_actor.actor_id, count(film_actor.film_id) AS QUANTITY
	FROM film_actor JOIN film_category ON film_actor.film_id = film_category.film_id
	JOIN category ON category.category_id = film_category.category_id
	WHERE category.name LIKE "Action"
	GROUP BY film_actor.actor_id)
	UNION
	(SELECT film_actor.actor_id, 0 AS QUANTITY
	FROM film_actor JOIN actor ON film_actor.actor_id = actor.actor_id
	WHERE actor.actor_id NOT IN(SELECT DISTINCT actor.actor_id
								FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id
								JOIN film_category ON film_actor.film_id = film_category.film_id
								JOIN category ON category.category_id = film_category.category_id
								WHERE category.name LIKE "Action") )
	ORDER BY actor_id) AS ACT
    JOIN
	(SELECT actor.actor_id, count(film_actor.film_id) AS QUANTITY
	FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id
		JOIN film_category ON film_actor.film_id = film_category.film_id
		JOIN category ON category.category_id = film_category.category_id
	WHERE category.name LIKE "Horror"
	GROUP BY actor.actor_id, category.name) AS HOR
    ON HOR.actor_id = ACT.actor_id
    JOIN
	actor ON ACT.actor_id = actor.actor_id
WHERE HOR.QUANTITY > ACT.QUANTITY;
################################################################################
SELECT actor.last_name
FROM
    (SELECT film_actor.actor_id, count(category.name) AS QUANTITY
	FROM film_actor JOIN film_category ON film_actor.film_id = film_category.film_id
	LEFT JOIN category ON category.category_id = film_category.category_id
	AND category.name LIKE "Action"
	GROUP BY film_actor.actor_id) AS ACT
    JOIN
	(SELECT actor.actor_id, count(film_actor.film_id) AS QUANTITY
	FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id
		JOIN film_category ON film_actor.film_id = film_category.film_id
		JOIN category ON category.category_id = film_category.category_id
	WHERE category.name LIKE "Horror"
	GROUP BY actor.actor_id, category.name) AS HOR
    ON HOR.actor_id = ACT.actor_id
    JOIN
	actor ON ACT.actor_id = actor.actor_id
WHERE HOR.QUANTITY > ACT.QUANTITY;
#Zadanie15
SELECT A.customer_id
FROM
    (SELECT TMP.customer_id, (TMP.SUMA/TMP.QUANTITY) AS AV, (SELECT SUM(payment.amount)/COUNT(payment.rental_id)
															FROM payment
															WHERE DAY(payment.payment_date) = 7 AND MONTH(payment.payment_date) = 7 AND YEAR(payment.payment_date) = 2005) AS AVE
	FROM
		(SELECT rental.customer_id, COUNT(rental.rental_id) AS QUANTITY, SUM(payment.amount) AS SUMA
		FROM rental JOIN payment ON rental.rental_id = payment.rental_id
		GROUP BY rental.customer_id) AS TMP) AS A
WHERE A.AV > A.AVE;

#Zadanie16
