--Функція, яка повертає список фільмів з заданим жанром


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


SELECT * FROM get_films('Biography')
SELECT * FROM get_films('Drama')

--Перевірка результату
--SELECT film_name, release_date, genres.genre_name FROM (film INNER JOIN filmgenres ON filmgenres.film_id = film.film_id) as result 
--INNER JOIN genres ON genres.genre_id = result.genre_id
