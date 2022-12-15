-- Процедура insert_film(назва фільму, дата релізу, тривалість, студія), яка додає в таблицю film новий рядок
-- з вказаними аргументами 

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

CALL insert_film('f_name', CURRENT_DATE, 11, 'prod')

--DELETE FROM film WHERE film.film_name = 'f_name'
SELECT * FROM film
