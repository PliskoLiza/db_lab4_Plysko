--DROP TABLE IF EXISTS rating_changers
CREATE TABLE rating_changers(
	change_id    serial       PRIMARY KEY,
	user_name    varchar(50)  NOT NULL,
	changed      varchar(255) NOT NULL,
	old_rating   NUMERIC, 
	new_rating   NUMERIC, 
	update_time  TIMESTAMP    NOT NULL
);

CREATE OR REPLACE FUNCTION table_rating_changes() RETURNS trigger 
LANGUAGE 'plpgsql'
AS $$
BEGIN
 	INSERT INTO rating_changers(user_name, changed, old_rating, new_rating, update_time)
		VALUES((SELECT DISTINCT user from filmrating), 
			   (SELECT '['||film_id||', '||platform_id||', '||rating_date||']' FROM filmrating WHERE rating = NEW.rating), 
			   OLD.rating, NEW.rating, (SELECT CURRENT_TIMESTAMP));
	RETURN NULL;
END;
$$ ;

CREATE TRIGGER rating_update_details 
AFTER UPDATE ON filmrating
FOR EACH ROW EXECUTE FUNCTION table_rating_changes();

----
DROP FUNCTION IF EXISTS get_films(varchar); 
CREATE OR REPLACE FUNCTION get_films(genre varchar) 
    RETURNS TABLE (film_name text, release_date date)
    LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY
        SELECT result.film_name, result.release_date
		FROM (film INNER JOIN filmgenres ON filmgenres.film_id = film.film_id) as result 
        INNER JOIN genres ON genres.genre_id = result.genre_id
		WHERE genres.genre_name = genre;
END;
$$

----
DROP PROCEDURE IF EXISTS insert_film(text, date, integer, varchar);
CREATE OR REPLACE PROCEDURE insert_film(f_name text, r_date date, r_time integer, prod varchar)
LANGUAGE 'plpgsql'
AS $$
BEGIN
    INSERT INTO film(film_id, film_name, release_date, runtime, production) 
	VALUES ((SELECT MAX(film_id)+1 FROM film), f_name, r_date, r_time, prod);
	RAISE INFO 'Додання успішне';
END;
$$;
----


-- Перевірка роботи функції

SELECT * FROM get_films('Biography')
SELECT * FROM get_films('Drama')

--SELECT film_name, release_date, genres.genre_name FROM (film INNER JOIN filmgenres ON filmgenres.film_id = film.film_id) as result 
--INNER JOIN genres ON genres.genre_id = result.genre_id

-- Перевірка роботи тригера
SELECT * FROM filmrating

UPDATE filmrating SET rating = 80.0 WHERE film_id = 1 AND platform_id = 'Metascore' AND rating_date = '2022-10-05'

SELECT * FROM rating_changers

-- Перевірка роботи процедури
CALL insert_film('f_name', CURRENT_DATE, 11, 'prod')

--DELETE FROM film WHERE film.film_name = 'f_name'
SELECT * FROM film
