CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    film_category AS category,
    SUM(payment_amount) AS total_sales_revenue
FROM
    film
    JOIN inventory USING (film_id)
    JOIN rental USING (inventory_id)
    JOIN payment USING (rental_id)
WHERE
    QUARTER(rental_date) = QUARTER(NOW()) AND YEAR(rental_date) = YEAR(NOW())
GROUP BY
    film_category
HAVING
    total_sales_revenue > 0;

DELIMITER //
CREATE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE
AS
RETURN
    SELECT * FROM sales_revenue_by_category_qtr
    WHERE QUARTER(NOW()) = current_quarter;
//

DELIMITER //
CREATE PROCEDURE new_movie(IN new_title VARCHAR(255))
BEGIN
    DECLARE new_film_id INT;
    DECLARE lang_exists INT;

    SET new_film_id = (SELECT MAX(film_id) + 1 FROM film);
    SET lang_exists = (SELECT COUNT(*) FROM language WHERE name = 'Klingon');

    IF lang_exists > 0 THEN
        INSERT INTO film (film_id, title, language_id, rental_rate, rental_duration, replacement_cost, release_year)
        VALUES (new_film_id, new_title, (SELECT language_id FROM language WHERE name = 'Klingon'), 4.99, 3, 19.99, YEAR(NOW()));
    END IF;
END;
//

DROP PROCEDURE IF EXISTS new_movie;
