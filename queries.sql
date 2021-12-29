/*Question 1: We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out

Direction for query formation: For this query, you will need 5 tables: Category, Film_Category, Inventory, Rental and Film. Your solution should have three columns: Film title, Category name and Count of Rentals.*/

SELECT
   category_name,
   SUM(rental_count) 
FROM
   (
      SELECT
         f.title as title,
         c.name as category_name,
         COUNT(r.rental_id) as rental_count 
      FROM
         film_category fc 
         JOIN
            category c 
            ON c.category_id = fc.category_id 
         JOIN
            film f 
            ON f.film_id = fc.film_id 
         JOIN
            inventory i 
            ON i.film_id = f.film_id 
         JOIN
            rental r 
            ON r.inventory_id = i.inventory_id 				--These are the categories considered as family movies--
      WHERE
         c.name IN 
         (
            'Animation',
            'Children',
            'Classics',
            'Comedy',
            'Family',
            'Music' 
         )
      GROUP BY
         1,
         2 
      ORDER BY
         2,
         1
   )
   t1 
GROUP BY
   1;


/*Question 2 : Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with the movie titles 
and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all 
categories? Make sure to also indicate the category that these family-friendly movies fall into.

Direction for query formation: If you correctly split your data. You should only need the category, film_category, and film tables to answer this.*/

SELECT
   f.title,
   c.name,
   f.rental_duration,
   NTILE(4) OVER (
ORDER BY
   f.rental_duration) AS standard_quartile,
   COUNT(*) 
FROM
   film_category fc 
   JOIN
      category c 
      ON c.category_id = fc.category_id 
   JOIN
      film f 
      ON f.film_id = fc.film_id 
WHERE
   c.name IN 
   (
      'Animation',
      'Children',
      'Classics',
      'Comedy',
      'Family',
      'Music'
   )
GROUP BY
   1,
   2,
   3;


/*Question 3: Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each 
corresponding rental duration category. The resulting table should have three columns:

a. Category
b. Rental length category
c. Count

Direction for query formation: The Count column should be sorted first by Category and then by Rental Duration category.*/

SELECT
   t1.name,
   t1.standard_quartile,
   COUNT(t1.standard_quartile) 
FROM
   (
      SELECT
         f.title,
         c.name,
         f.rental_duration,
         NTILE(4) OVER (
      ORDER BY
         f.rental_duration) AS standard_quartile 
      FROM
         film_category fc 
         JOIN
            category c 
            ON c.category_id = fc.category_id 
         JOIN
            film f 
            ON f.film_id = fc.film_id 
      WHERE
         c.name IN 
         (
            'Animation',
            'Children',
            'Classics',
            'Comedy',
            'Family',
            'Music'
         )
   )
   t1 
GROUP BY
   1,
   2 
ORDER BY
   1,
   2;



/*Question 4: We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a 
query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?

Direction for query formation: The results are sorted first by customer name and then for each month. Also, total amounts per month will be listed for each customer.*/

SELECT
   DATE_TRUNC('month', p.payment_date) pay_month,
   c.first_name || ' ' || c.last_name AS full_name,
   COUNT(p.amount) AS pay_countpermon,
   SUM(p.amount) AS pay_amount 
FROM
   customer c 
   JOIN
      payment p 
      ON p.customer_id = c.customer_id 
WHERE
   c.first_name || ' ' || c.last_name IN 
   (
      SELECT
         t1.full_name 
      FROM
         (
            SELECT
               c.first_name || ' ' || c.last_name AS full_name,
               SUM(p.amount) as amount_total 
            FROM
               customer c 
               JOIN
                  payment p 
                  ON p.customer_id = c.customer_id 
            GROUP BY
               1 
            ORDER BY
               2 DESC LIMIT 10
         )
         t1
   )
   AND 
   (
      p.payment_date BETWEEN '2007-01-01' AND '2008-01-01'
   )
GROUP BY
   2,
   1 
ORDER BY
   2,
   1,
   3;
