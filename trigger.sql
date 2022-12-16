-- Тригер, що викликається при зміні рейтингу в таблиці filmrating.
-- Тобто якщо рейтинг було оновлено (видалення і додання не фіксуються), зміни записуються в таблицю з іменем, часом та датою зміни,
-- ключем таблиці filmrating та змінами (нове і старе значення рейтингу)


--Таблиця для запису змін
--DROP TABLE IF EXISTS rating_changers
CREATE TABLE rating_changers(
	change_id    serial          PRIMARY KEY,
	user_name    varchar(50)  NOT NULL,
	changed      varchar(255) NOT NULL,
	old_rating   NUMERIC, 
	new_rating   NUMERIC, 
	update_time  TIMESTAMP    NOT NULL
);

-- Тригерна функція, що записує зміни в таблицю
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

-- Створення тригера
CREATE TRIGGER rating_update_details 
AFTER UPDATE ON filmrating
FOR EACH ROW EXECUTE FUNCTION table_rating_changes();

-- Таблиця, в якій змінюють рейтинг
SELECT * FROM filmrating

-- Зміна
UPDATE filmrating SET rating = 80.0 WHERE film_id = 1 AND platform_id = 'Metascore' AND rating_date = '2022-10-05'

-- Перевірка запису про зміну
SELECT * FROM rating_changers

