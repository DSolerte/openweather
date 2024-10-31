-- How many distinct weather conditions were observed
--  (rain/snow/clear/…) in a certain period? (October 15th - Today)

SELECT distinct main FROM weather w
JOIN fact_temp t ON W.ID = T.weather_id 
WHERE T.DT >= CAST('2024-10-15' AS DATE)

--Rank the most common weather conditions in a certain period of time per city? (October 15th - Today)
WITH WeatherCounts AS (
    SELECT 
        c.city_id,
        c.city_des,
        w.main AS weather_condition,
        COUNT(*) AS condition_count
    FROM 
        temp_facts tf
    JOIN 
        cities c ON tf.city_id = c.city_id
    JOIN 
        weather w ON tf.weather = w.id
    WHERE 
        tf.dt >= CAST('2024-10-15'AS DATE)
    GROUP BY 
        c.city_id, c.city_des, w.main
),
RankedWeather AS (
    SELECT 
        city_id,
        city_des,
        weather_condition,
        condition_count,
        RANK() OVER (PARTITION BY city_id ORDER BY condition_count DESC) AS rank
    FROM 
        WeatherCounts
)
SELECT 
    city_id,
    city_des,
    weather_condition,
    condition_count,
    rank
FROM 
    RankedWeather
ORDER BY 
    city_id, rank;


-- What are the temperature averages observed in a certain period per city?

SELECT 
    c.city_id,
    c.city_des,
    AVG(tf.temp) AS average_temperature,
    AVG(tf.feels_like) AS average_feels_like
FROM 
    temp_facts tf
JOIN 
    cities c ON tf.city_id = c.city_id
WHERE 
    tf.dt >= '2024-10-15'  
GROUP BY 
    c.city_id, c.city_des
ORDER BY 
    c.city_id;

--What city had the highest absolute temperature in a certain period of time?


SELECT 
    c.city_id,
    c.city_des,
    tf.dt,
    MAX(tf.temp),
FROM 
    temp_facts tf
JOIN 
    cities c ON tf.city_id = c.city_id
WHERE 
    tf.dt >= '2024-10-15' 
GROUP BY 
    c.city_id, c.city_des
ORDER BY 
    c.city_id;

-- Which city had the highest daily temperature variation in a certain
--  period of time?

-- Considering 1 hour granularity:

-- Get all differences for a day
WITH DailyTemperatures AS (
    SELECT 
        city_id,
        DATE(dt) AS date,  
        MAX(temp) AS max_temp,
        MIN(temp) AS min_temp
    FROM 
        temp_facts
    WHERE 
        dt >= '2024-10-15'  
    GROUP BY 
        city_id, DATE(dt)  
),
-- Calculate variation
DailyVariation AS (
    SELECT 
        city_id,
        (max_temp - min_temp) AS temp_variation
    FROM 
        DailyTemperatures
)
-- Get the highest
SELECT 
    c.city_id,
    c.city_des,
    MAX(dv.temp_variation) AS highest_variation
FROM 
    DailyVariation dv
JOIN 
    cities c ON dv.city_id = c.city_id
GROUP BY 
    c.city_id, c.city_des
ORDER BY 
    highest_variation DESC
LIMIT 1;  


-- What city had the strongest wing in a certain period of time?
SELECT
    c.city_id,
    c.city_des,
    MAX(wind_speed)
FROM 
    fact_temp t
JOIN 
    cities c ON t.city_id = c.city_id
 WHERE 
    t.dt >= '2024-10-15' 