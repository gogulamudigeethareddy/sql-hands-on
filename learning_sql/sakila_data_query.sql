SELECT * FROM actor;

--To return the title of every film in which an actor with the firstname is JOHN

SELECT f.title, a.first_name
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
WHERE a.first_name = 'JOHN';

--To return all addresses that are in the same city, each row should include two different addresses.

SELECT * FROM address;

SELECT a1.address, a2.address, a1.city_id
FROM address a1 
INNER JOIN address a2
WHERE a1.city_id = a2.city_id AND a1.address_id <> a2.address_id;

--To return first and last names of all actors and customers whose last name starts with L

SELECT first_name, last_name
FROM actor 
WHERE last_name LIKE 'L%'
UNION 
SELECT first_name, last_name
FROM customer 
WHERE last_name LIKE 'L%'
ORDER BY last_name;

--Finding substring 17th through 25th characters

SELECT SUBSTRING('Please find the substring in this string', 17, 9);

--To return absolute value, sign and rounded to nearest hundredth

SELECT ABS(-25.76823), SIGN(-25.76823), ROUND(-25.76823, 2);

--To return month from current date

SELECT MONTH(CURRENT_DATE());

SELECT EXTRACT(MONTH FROM CURRENT_DATE());

--To calculate maximum number of days between when a film rented and returned

SELECT MAX(DATEDIFF(return_date, rental_date))
FROM rental;

--To find total number of films for each film rating(G, PG, ....) for each actor

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor fa
JOIN film f ON f.film_id = fa.film_id
GROUP BY fa.actor_id, f.rating
ORDER BY 1, 2;

--Grouping with Expressions

SELECT EXTRACT(YEAR FROM rental_date) year, COUNT(*) rentals
FROM rental
GROUP BY EXTRACT(YEAR FROM rental_date);

--Using Rollup (to generate sub totals and grand totals)

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor fa
INNER JOIN film f ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating WITH ROLLUP
ORDER BY 1, 2;

--Using WHERE and HAVING

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor fa
INNER JOIN film f ON fa.film_id = f.film_id
WHERE f.rating IN ('G', 'PG')
GROUP BY fa.actor_id, f.rating 
HAVING COUNT(*) > 9;

--Number of rows in payment table

SELECT customer_id, COUNT(*) number_of_payments, SUM(amount) total_amount 
FROM payment
GROUP BY customer_id
HAVING number_of_payments >= 40;

--Subquery using IN operator

SELECT city_id, city
FROM city
WHERE country_id IN
    (SELECT country_id
     FROM country
     WHERE country IN ('Canada', 'Mexico'));

--Subquery using NOT IN operator

SELECT city_id, city
FROM city
WHERE country_id NOT IN
    (SELECT country_id
     FROM country
     WHERE country IN ('Canada', 'Mexico'));

--Subquery using ALL operator

SELECT customer_id, COUNT(*)
FROM rental
GROUP BY customer_id
HAVING COUNT(*) > ALL
    (SELECT COUNT(*)
     FROM rental r
      INNER JOIN customer c
      ON r.customer_id = c.customer_id
      INNER JOIN address a
      ON c.address_id = a.address_id
      INNER JOIN city ct
      ON a.city_id = ct.city_id
      INNER JOIN country co
      ON ct.country_id = co.country_id
     WHERE co.country IN ('United States', 'Mexico', 'Canada')
     GROUP BY r.customer_id
     );

--Subquery using ANY operator

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > ANY
    (SELECT SUM(amount)
     FROM payment p
      INNER JOIN customer c
      ON p.customer_id = c.customer_id
      INNER JOIN address a
      ON c.address_id = a.address_id
      INNER JOIN city ct
      ON a.city_id = ct.city_id
      INNER JOIN country co
      ON ct.country_id = co.country_id
     WHERE co.country IN ('Bolivia', 'Paraguay', 'Chile')
     GROUP BY co.country
     );

--Multicolumn Subqueries

SELECT actor_id, film_id
FROM film_actor
WHERE (actor_id, film_id) IN
    (SELECT a.actor_id, f.film_id
     FROM actor a
      CROSS JOIN film f
     WHERE a.last_name = 'MONROE'
     AND f.rating = 'PG');

--Correlatated Subquery

SELECT c.first_name, c.last_name
FROM customer c
WHERE 20 = 
    (SELECT COUNT(*) FROM rental r
     WHERE r.customer_id = c.customer_id);

SELECT c.first_name, c.last_name
FROM customer c
WHERE (SELECT SUM(p.amount) FROM payment p
       WHERE p.customer_id = c.customer_id)
      BETWEEN 180 AND 240;

--EXISTS Operator

SELECT c.first_name, c.last_name
FROM customer c
WHERE EXISTS
    (SELECT 1 FROM rental r
     WHERE r.customer_id = c.customer_id
        AND date(r.rental_date) < '2005-05-25');

SELECT c.first_name, c.last_name
FROM customer c
WHERE NOT EXISTS
    (SELECT 1 FROM rental r
     WHERE r.customer_id = c.customer_id
        AND date(r.rental_date) < '2000-02-20');

--Data Manipulation using Correlated Subqueries

UPDATE customer c
SET c.last_update = 
    (SELECT MAX(r.rental_date) FROM rental r
     WHERE r.customer_id = c.customer_id);

UPDATE customer c
SET c.last_update = 
    (SELECT MAX(r.rental_date) FROM rental r
     WHERE r.customer_id = c.customer_id)
     WHERE EXISTS
     (SELECT 1 FROM rental r
     WHERE r.customer_id = c.customer_id);

--Subqueries as Datasources

SELECT c.first_name, c.last_name, pymnt.num_rentals, pymnt.tot_payments
FROM customer c
INNER JOIN
        (SELECT customer_id, COUNT(*) num_rentals, SUM(amount) tot_payments
         FROM payment
         GROUP BY customer_id
        )pymnt
ON c.customer_id = pymnt.customer_id;

--Data Fabrication (can generate groups)

SELECT 'Small FRY' name, 0 low_limit, 74.99 high_limit
UNION ALL
SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit

SELECT pymnt_grps.name, COUNT(*) num_customers
FROM 
     (SELECT customer_id, COUNT(*) num_rentals, SUM(amount) tot_payments
      FROM payment
      GROUP BY customer_id
     )pymnt
INNER JOIN
     (SELECT 'Small FRY' name, 0 low_limit, 74.99 high_limit
      UNION ALL
      SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
      UNION ALL
      SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit
      )pymnt_grps
ON pymnt.tot_payments
BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit
GROUP BY pymnt_grps.name;

--Task oriented subqueries

SELECT c.first_name, c.last_name, ct.city, pymnt.tot_payments, pymnt.tot_rentals
FROM (
    SELECT customer_id, COUNT(*) AS tot_rentals, SUM(amount) AS tot_payments
    FROM payment
    GROUP BY customer_id
)pymnt
INNER JOIN customer c 
ON pymnt.customer_id = c.customer_id
INNER JOIN address a 
ON c.address_id = a.address_id
INNER JOIN city ct 
ON a.city_id = ct.city_id;

--Common Table Expressions(CTEs)

WITH actors_s AS (
    SELECT actor_id, first_name, last_name
    FROM actor
    WHERE last_name LIKE 'S%'
),
actors_s_pg AS (
    SELECT s.actor_id, s.first_name, s.last_name, f.film_id, f.title
    FROM actors_s s
    INNER JOIN film_actor fa ON s.actor_id = fa.actor_id
    INNER JOIN film f ON f.film_id = fa.film_id
    WHERE f.rating = 'PG'
),
actors_s_pg_revenue AS (
    SELECT spg.first_name, spg.last_name, p.amount
    FROM actors_s_pg spg
    INNER JOIN inventory i ON i.film_id = spg.film_id
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
)
SELECT spg_rev.first_name, spg_rev.last_name, SUM(spg_rev.amount) AS tot_revenue
FROM actors_s_pg_revenue spg_rev
GROUP BY spg_rev.first_name, spg_rev.last_name
ORDER BY tot_revenue DESC;

--Subqueries as Expression Generators

SELECT 
   (SELECT c.first_name FROM customer c
    WHERE c.customer_id = p.customer_id
)first_name,
   (SELECT c.last_name FROM customer c
    WHERE c.customer_id = p.customer_id
)last_name,
   (SELECT ct.city FROM customer c
    INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
    WHERE c.customer_id = p.customer_id
)city,
SUM(p.amount) AS tot_payments, COUNT(*) AS tot_rentals
FROM payment p
GROUP BY p.customer_id;

--To return films with a noncorrelated subquery against category table with filter in the category name 'Action'

SELECT title
FROM film f
WHERE film_id IN
(SELECT fc.film_id
 FROM film_category fc 
 JOIN category c
 ON c.category_id = fc.category_id
 WHERE c.name = 'Action');

--To return films with a correlated subquery against category table with filter in the category name 'Action'

SELECT title
FROM film f
WHERE EXISTS
(SELECT 1
 FROM film_category fc 
 JOIN category c
 ON c.category_id = fc.category_id
 WHERE c.name = 'Action'
 AND fc.film_id = f.film_id);

--To return the categories to show the level of each actor

SELECT actr.actor_id, grps.level
FROM 
(SELECT actor_id, COUNT(*) num_roles
 FROM film_actor
 GROUP BY actor_id
) actr
INNER JOIN
(SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles
 UNION ALL
 SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles
 UNION ALL
 SELECT 'Newcomer' level, 1 min_roles, 19 max_roles
) grps
ON actr.num_roles BETWEEN grps.min_roles AND grps.max_roles;

--Outer Join

SELECT f.film_id, f.title, COUNT(i.inventory_id) num_copies
FROM film f
LEFT OUTER JOIN inventory i
ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;

SELECT f.film_id, f.title, i.inventory_id
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

SELECT f.film_id, f.title, i.inventory_id
FROM film f
LEFT OUTER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

--Three-way Outer Joins

SELECT f.film_id, f.title, i.inventory_id, r.rental_date
FROM film f
LEFT OUTER JOIN inventory i
ON f.film_id = i.film_id
LEFT OUTER JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE f.film_id BETWEEN 13 AND 15;

--Cross Join (To generate Cartesian product)

SELECT c.name category_name, l.name language_name
FROM category c
CROSS JOIN language l;

--To return each customer name along with their total payments even if no payment records exist for that customer

SELECT c.customer_id, SUM(p.amount) total_amount
FROM customer c
LEFT OUTER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

--To generate the set {1,2,3,......,99,100}

SELECT ones.x + tens.x + 1
FROM 
(SELECT 0 x UNION ALL
 SELECT 1 x UNION ALL
 SELECT 2 x UNION ALL
 SELECT 3 x UNION ALL
 SELECT 4 x UNION ALL
 SELECT 5 x UNION ALL
 SELECT 6 x UNION ALL
 SELECT 7 x UNION ALL
 SELECT 8 x UNION ALL
 SELECT 9 x 
) ones
CROSS JOIN
(SELECT 0 x UNION ALL
 SELECT 10 x UNION ALL
 SELECT 20 x UNION ALL
 SELECT 30 x UNION ALL
 SELECT 40 x UNION ALL
 SELECT 50 x UNION ALL
 SELECT 60 x UNION ALL
 SELECT 70 x UNION ALL
 SELECT 80 x UNION ALL
 SELECT 90 x 
) tens
ORDER BY 1;

--Conditional Logic

SELECT first_name, last_name,
CASE 
    WHEN active = 1 THEN 'ACTIVE'
    ELSE 'INACTIVE'
END activity_type
FROM customer;

--CASE expression returns subquery

SELECT first_name, last_name, --returns number of rentals for active customers
CASE 
    WHEN active = 0 THEN 0
    ELSE (SELECT COUNT(*) FROM rental r
          WHERE r.customer_id = c.customer_id)
END num_rentals
FROM customer c;

--Cae Expression result set transformation

SELECT monthname(rental_date) rental_month, COUNT(*) num_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01'
GROUP BY monthname(rental_date);

SELECT 
    SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1 ELSE 0 END) May_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'June' THEN 1 ELSE 0 END) June_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'July' THEN 1 ELSE 0 END) July_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01'

--Checking for existence

SELECT a.first_name, a.last_name,
CASE
  WHEN EXISTS (SELECT 1 FROM film_actor fa
               INNER JOIN film f ON fa.film_id = f.film_id
               WHERE fa.actor_id = a.actor_id
               AND f.rating = 'G') THEN 'Y'
  ELSE 'N'
END g_actor,
CASE
  WHEN EXISTS (SELECT 1 FROM film_actor fa
               INNER JOIN film f ON fa.film_id = f.film_id
               WHERE fa.actor_id = a.actor_id
               AND f.rating = 'PG') THEN 'Y'
  ELSE 'N'
END pg_actor,
CASE
  WHEN EXISTS (SELECT 1 FROM film_actor fa
               INNER JOIN film f ON fa.film_id = f.film_id
               WHERE fa.actor_id = a.actor_id
               AND f.rating = 'NC-17') THEN 'Y'
  ELSE 'N'
END nc17_actor
FROM actor a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';

--Division-by-zero Errors

SELECT 100/0;

SELECT c.first_name, c.last_name, SUM(p.amount) tot_payment_amt, COUNT(p.amount) num_payments, 
       SUM(p.amount) / CASE WHEN COUNT(p.amount) = 0 THEN 1
                            ELSE COUNT(p.amount)
                        END avg_payment                 --calculating average payment amount for each customer
FROM customer c
LEFT OUTER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name;

--search case expression

SELECT name, CASE WHEN name IN ('English', 'Italian', 'French', 'German') THEN 'latin1'
                  WHEN name IN ('Japanese', 'Mandarin') THEN 'utf8'
                  ELSE 'Unknown'
              END character_set
FROM language;

SELECT 
    SUM(CASE WHEN rating = 'G' THEN 1 ELSE 0 END) g,
    SUM(CASE WHEN rating = 'PG' THEN 1 ELSE 0 END) pg,
    SUM(CASE WHEN rating = 'PG-13' THEN 1 ELSE 0 END) pg_13,
    SUM(CASE WHEN rating = 'R' THEN 1 ELSE 0 END) r,
    SUM(CASE WHEN rating = 'NC-17' THEN 1 ELSE 0 END) nc_17
FROM film;

--Indexes and Constraints

ALTER TABLE rental --to restrict a customer_id column from deleting
ADD CONSTRAINT fk_rental_customer_id FOREIGN KEY (customer_id)
REFERENCES customer (customer_id) ON DELETE RESTRICT;

CREATE INDEX idx_payment1 --Multicolumn index on payment table
ON payment (payment_date, amount);

--VIEWS

CREATE VIEW customer_vw
(customer_id, first_name, last_name, email)
AS
SELECT customer_id, first_name, last_name, CONCAT(SUBSTR(email, 1, 2), '******', SUBSTR(email, -4)) email
FROM customer;

SELECT * FROM customer_vw;

CREATE VIEW film_ctgry_actor
(title, category_name, first_name, last_name)
AS
SELECT f.title, c.name category_name, a.first_name, a.last_name
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN film_actor fa ON fa.film_id = f.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id;

--To create a view with total payments for customers who live in each country 

CREATE VIEW country_payments
AS
SELECT c.country,
(SELECT SUM(p.amount) 
 FROM city ct
        INNER JOIN address a ON ct.city_id = a.city_id
        INNER JOIN customer cst ON a.address_id = cst.address_id
        INNER JOIN payment p ON cst.customer_id = p.customer_id
 WHERE ct.country_id = c.country_id
) tot_payments
FROM country c;

--Metadata

SELECT DISTINCT table_name, index_name --To list all the indexes in Sakila Schema
FROM information_schema.statistics
WHERE table_schema = 'sakila';

--Analytical Functions

SELECT quarter(payment_date) quarter,
       monthname(payment_date) month_nm,
       SUM(amount) monthly_sales,
       MAX(SUM(amount)) OVER() max_overall_sales,
       MAX(SUM(amount)) OVER(PARTITION BY quarter(payment_date)) max_qrtr_sales
FROM payment
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date);
 
SELECT customer_id, COUNT(*) num_rentals, 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) row_number_rnk,
        RANK() OVER (ORDER BY COUNT(*) DESC) rank_rnk,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 DESC;

--Generating Multiple Rankings (For example, to offer free film rentals to top five customers every month)
SELECT customer_id, MONTHNAME(rental_date) rental_month, COUNT(*) num_rentals    
FROM rental
GROUP BY customer_id, MONTHNAME(rental_date)
ORDER BY 2, 3 desc;

SELECT customer_id, MONTHNAME(rental_date) rental_month, COUNT(*) num_rentals,
        RANK() OVER (PARTITION BY MONTHNAME(rental_date) ORDER BY COUNT(*) DESC) rank_rnk
FROM rental
GROUP BY customer_id, MONTHNAME(rental_date)
ORDER BY 2, 3 DESC;

SELECT customer_id, rental_month, num_rentals, rank_rnk ranking
FROM
(SELECT customer_id, MONTHNAME(rental_date) rental_month, COUNT(*) num_rentals, 
        RANK() OVER (PARTITION BY MONTHNAME(rental_date) ORDER BY COUNT(*) DESC) rank_rnk
FROM rental
GROUP BY customer_id, MONTHNAME(rental_date)
) cust_rankings
WHERE rank_rnk <= 5
ORDER BY rental_month, num_rentals DESC, rank_rnk;

--Reporting Functions (To find outliers or to genrate sums, averages

SELECT monthname(payment_date) payment_month, amount, 
        SUM(amount) OVER (PARTITION BY monthname(payment_date)) monthly_total,
        SUM(amount) OVER () grand_total
FROM payment
WHERE amount >= 10
ORDER BY 1;

SELECT monthname(payment_date) payment_month, 
        SUM(amount) month_total,
        ROUND(SUM(amount) / SUM(SUM(amount)) OVER() * 100, 2) pct_of_total --percentage of total payments for each month by summing monthly sums as denominator
FROM payment
GROUP BY monthname(payment_date);

--Reporting functions used for comparisions
SELECT monthname(payment_date) payment_month, SUM(amount) month_total,
     CASE SUM(amount)
        WHEN MAX(SUM(amount)) OVER () THEN 'Highest'
        WHEN MIN(SUM(amount)) OVER () THEN 'Lowest'
        ELSE 'Middle'
     END descriptor
FROM payment
GROUP BY monthname(payment_date);

--Window Frames (To calculate rolling sum and rolling average)

SELECT yearweek(payment_date) payment_week, 
        SUM(amount) week_total, 
        SUM(SUM(amount)) OVER (ORDER BY yearweek(payment_date) rows unbounded preceding) rolling_sum
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY payment_week;

SELECT yearweek(payment_date) payment_week, 
        SUM(amount) week_total, 
        AVG(SUM(amount)) OVER (ORDER BY yearweek(payment_date) rows between 1 preceding and 1 following) rolling_3wk_avg
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY payment_week;

--specifiying date interval rather than the rows for data window
SELECT date(payment_date), SUM(amount), 
        AVG(SUM(amount)) OVER (ORDER BY date(payment_date) range between interval 3 day preceding and interval 3 day following) 7_day_avg
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-01'
GROUP BY date(payment_date)
ORDER BY 1;

--LAG and LEAD

SELECT yearweek(payment_date) payment_week, 
        SUM(amount) week_total, 
        LAG(SUM(amount), 1) OVER (ORDER BY yearweek(payment_date)) prev_wk_total,
        LEAD(SUM(amount), 1) OVER (ORDER BY yearweek(payment_date)) next_wk_total
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY payment_week;

--Column Value Concatenation (To pivot a set of column values)

SELECT f.title, GROUP_CONCAT(a.last_name ORDER BY a.last_name SEPARATOR ', ') actors
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
INNER JOIN film f 
ON fa.film_id = f.film_id
GROUP BY f.title
HAVING COUNT(*) = 3;

