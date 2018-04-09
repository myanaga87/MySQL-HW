USE sakila;
-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(actor.first_name," ",actor.last_name) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT *
FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name varchar(30) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY middle_name blob;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor
DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

SELECT * 
FROM actor
WHERE last_name = 'Williams';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = '172';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = '172';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESCRIBE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.film_id, film.title, COUNT(film_actor.actor_id)
FROM film
JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory.inventory_id), film.title
FROM inventory
JOIN film
ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)

SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM payment
JOIN customer
ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY last_name;
    
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id = '1' AND title LIKE 'Q%' OR title LIKE 'K%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id in(
	SELECT actor_id
	FROM film_actor
	WHERE film_id in(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip')
        );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, address.address
FROM customer
JOIN address
ON address.address_id = customer.address_id
WHERE customer.address_id IN(
	SELECT address.address_id
	FROM address
	JOIN city
	ON city.city_id = address.city_id
	WHERE address.city_id IN(
		SELECT city.city_id
		FROM city
		JOIN country
		ON city.country_id = country.country_id
		WHERE country.country = 'Canada')
        );

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT title
FROM film
WHERE film_id IN(
	SELECT film_id
	FROM film_category
	WHERE category_id IN(
		SELECT category_id
		FROM category
		WHERE name = 'family')
        );

-- 7e. Display the most frequently rented movies in descending order.

SELECT COUNT(rental.rental_id), rental.inventory_id, film.title
FROM rental
JOIN inventory
ON inventory.inventory_id = rental.inventory_id
JOIN film
ON film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY COUNT(rental.rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT SUM(payment.amount), store.store_id
FROM payment
JOIN store
ON payment.staff_id = store.manager_staff_id
GROUP BY payment.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
JOIN country
ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT rental.inventory_id, SUM(payment.amount), inventory.film_id, film_category.category_id, category.name
FROM payment
JOIN rental
ON payment.rental_id = rental.rental_id
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film_category
ON inventory.film_id = film_category.film_id
JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_grossing_genres AS
SELECT rental.inventory_id, SUM(payment.amount), inventory.film_id, film_category.category_id, category.name
FROM payment
JOIN rental
ON payment.rental_id = rental.rental_id
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film_category
ON inventory.film_id = film_category.film_id
JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC LIMIT 5;

SELECT *
FROM top_five_grossing_genres;

-- 8b. How would you display the view that you created in 8a?

SELECT *
FROM top_five_grossing_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_grossing_genres;