/*Instructions
Rank films by length.
Rank films by length within the rating category.
Rank languages by the number of films (as original language).
Rank categories by the number of films.
Which actor has appeared in the most films?
Most active customer.
Most rented film.*/
USE sakila;

-- Rank films by length.
SELECT film_id, title, length, dense_rank() over (order by length desc) as ranking FROM film;

-- Rank films by length within the rating category.
SELECT film_id, title, rating, length, dense_rank() over (partition by rating order by length desc) as ranking FROM film;

-- Rank languages by the number of films (as original language).
SELECT * FROM film;
SELECT original_language_id, count(film_id), dense_rank() over (order by count(film_id)) as ranking_on_num_films FROM film
GROUP BY original_language_id;

-- Rank categories by the number of films.
SELECT category.category_id, category.name, count(film_id), dense_rank() over(order by count(film_id) desc) as ranking FROM film_category
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category_id;

-- Which actor has appeared in the most films?

SELECT actor_id, actor_name, appearances FROM 
(SELECT actor.actor_id, concat(actor.first_name, ' ',actor.last_name) as actor_name, count(actor.actor_id) as appearances, dense_rank() over (order by count(actor_id) desc) as appearance_count_rank FROM film_actor
INNER JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY actor_id) as table_of_ranking 
WHERE appearance_count_rank = 1;

-- Most active customer. Customer with maximum rentals
SELECT customer_id, customer_name, all_rentals FROM (SELECT rental.customer_id, concat(customer.first_name, ' ',customer.last_name) as customer_name, count(rental_id) as all_rentals, dense_rank() over (order by count(rental_id) desc) as ranking_num_rentals FROM rental
INNER JOIN customer ON rental.customer_id = customer.customer_id
GROUP BY customer_id) AS table_num_renrtals
WHERE ranking_num_rentals = 1;


-- Most rented film
SELECT title, num_rentals FROM (SELECT film.film_id, title, count(rental_id) as num_rentals, 
dense_rank() over (order by count(rental_id) desc) as ranking 
FROM rental
	INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
	INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY film.film_id, title) as film_ranking 
WHERE ranking = 1;