# Original dataset source: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
# CREATING TABLES WITH IMPORT ISSUES (AFTER IMPORTING ONLY 1/10 OF ROWS HAVE BEEN IMPORTED, MANUALY CREATED TABLES SOLVE THIS PROBLEM) 
# Creating lap_times table 
CREATE TABLE lap_times (
raceId INT,
driverId INT,
lap	VARCHAR(50),
position VARCHAR(50),
time VARCHAR(50),
milliseconds VARCHAR(50)
)

# Creating results table 

CREATE TABLE results (
    resultId INT PRIMARY KEY,
    raceId INT,
    driverId INT,
    constructorId INT,
    number VARCHAR(50),
    grid VARCHAR(50),
    position VARCHAR(50),
    positionText VARCHAR(50),
    positionOrder VARCHAR(50),
    points VARCHAR(50),
    laps VARCHAR(50),
    Time VARCHAR(50), 
    fastestLap VARCHAR(50),
    rank VARCHAR(50),
    fastestLapTime VARCHAR(50),
    fastestLapSpeed VARCHAR(50),
    statusId VARCHAR(50)
)

# Creating drivers table 

CREATE TABLE drivers (
driverId INT Primary Key,
number Varchar(50),
code Varchar(50),
forename Varchar(50),
surname Varchar(50),
dob Varchar(50),
nationality Varchar(50) 
)

# Looking for missing ID's

SELECT DISTINCT driverid +1
FROM drivers
WHERE driverid + 1 NOT IN (SELECT DISTINCT driverid FROM drivers);

# Change names with issues 

UPDATE f1.circuits
SET Name = CASE 
    WHEN Name = 'NĂĽrburgring' THEN 'Nurburgring'
    WHEN Name = 'AutĂłdromo JosĂ© Carlos Pace' THEN 'Autódromo José Carlos Pace'
    WHEN Name = 'AutĂłdromo Juan y Oscar GĂˇlvez' THEN 'Autódromo Juan y Oscar Gálvez'
    WHEN Name = 'AutĂłdromo do Estoril' THEN 'Autódromo do Estoril'
    WHEN Name = 'AutĂłdromo Hermanos RodrĂ­guez' THEN 'Autódromo Hermanos Rodríguez'
    WHEN Name = 'AutĂłdromo Internacional Nelson Piquet' THEN 'Autódromo Internacional Nelson Piquet'
    WHEN Name = 'MontjuĂŻc' THEN 'Montjuïc'
    ELSE Name
END,
Location = CASE 
    WHEN Location = 'MontmelĂł' THEN 'Montmeló'
    WHEN Location = 'SĂŁo Paulo' THEN 'São Paulo'
    WHEN Location = 'NĂĽrburg' THEN 'Nürburg'
    WHEN Location = 'PortimĂŁo' THEN 'Portimão'
    ELSE Location
END;

UPDATE drivers
SET forename = CASE 
    WHEN forename = 'SĂ©bastien' THEN 'Sébastien'
    WHEN forename = 'AntĂ´nio' THEN 'António'
    WHEN forename = 'GastĂłn' THEN 'Gastón'
    WHEN forename = 'TomĂˇĹˇ' THEN 'Tomáš'
    WHEN forename = 'StĂ©phane' THEN 'Stéphane'
    WHEN forename = 'Ă‰rik' THEN 'Érik'
    WHEN forename = 'Ă‰ric' THEN 'Éric'
    WHEN forename = 'MaurĂ­cio' THEN 'Maurício'
    ELSE forename
END,
surname = CASE 
    WHEN surname = 'RĂ¤ikkĂ¶nen' THEN 'Räikkönen'
    WHEN surname = 'GenĂ©' THEN 'Gené'
    WHEN surname = 'HĂ¤kkinen' THEN 'Häkkinen'
    WHEN surname = 'DĂ©lĂ©traz' THEN 'Délétraz'
    WHEN surname = 'JĂ¤rvilehto' THEN 'Järvilehto'
    ELSE surname
END;

# Join tables to create one for visualizations 

SELECT 
	year,
	ci.circuitId,
	re.resultId,
	re.raceId,
	driverId,
	co.constructorId,
	date AS date_of_race,
	ci.name AS track_name,
	ci.location AS city,
	ci.country,
	co.name AS manufacturer,
	grid,
	position,
	points,
	laps,
	ra.time,
	fastestLapTime,
	fastestLapSpeed
FROM f1.results AS re
	JOIN f1.races AS ra ON re.raceId = ra.raceId
	JOIN f1.constructors AS co ON re.constructorId = co.constructorId
	JOIN f1.circuits AS ci ON ra.circuitId = ci.circuitId
ORDER BY driverId, year DESC

# List of drivers and their participation years 

SELECT 
    CONCAT(forename," ",surname) AS Driver_name,
    REPLACE(dob, '.', '-') AS day_of_birth,
    nationality,
    CONCAT(MIN(year),"-",MAX(year)) AS paticipation  
FROM f1.drivers AS dr
	JOIN f1.results AS re ON re.driverid = dr.driverid 
	JOIN f1.races AS ra  ON ra.raceid = re.raceid 
    WHERE year > 'day_of_birth'
GROUP BY Driver_name,nationality,day_of_birth
    
# How many races provided by each year 

SELECT 
	year,
	count(round) as number_of_races 
FROM f1.races
GROUP BY year
ORDER BY year

# Which countries have hosted the most F-1 races

SELECT 
	country, 
	count(raceid) AS races_score 
FROM f1.races AS r
	JOIN f1.circuits AS c
	ON r.circuitId = c.circuitId
GROUP BY country
ORDER BY races_score DESC

# Distribution of races across different tracks 

SELECT 
	country,
	location AS city,
	c.name,
    count(raceid) AS races_score 
FROM f1.races AS r
	JOIN f1.circuits AS c
	ON r.circuitId = c.circuitId
GROUP BY country, location, c.name
ORDER BY country

# Distribution of F-1 winners by nationality

SELECT
	Year,
	nationality,
	SUM(points)AS points_score 
FROM f1.drivers AS d
	JOIN f1.results AS r
		ON r.driverid = d.driverid
    JOIN f1.races AS ra 
		ON ra.raceid = r.raceid
GROUP BY nationality, year
ORDER BY year, points_score desc

# Which F-1 drivers have won the most races

WITH CTE_points AS 
(SELECT
    DISTINCT year, 
    CONCAT(d.forename, ' ', d.surname) AS name, 
    d.driverid,
    points
FROM f1.drivers AS d
	JOIN f1.results AS r ON r.driverid = d.driverid
	JOIN f1.races AS ra ON ra.raceid = r.raceid
WHERE points != 0 ) 
SELECT  
	year, 
	name, 
    SUM(points) AS sum_points
FROM CTE_points
GROUP BY year,name
ORDER BY year, sum_points DESC

# Average lap time in F-1 races over time and race track 

SELECT 
    year,
    name,
    TIME_FORMAT(SEC_TO_TIME(AVG(TIME_TO_SEC(STR_TO_DATE(lt.Time, '%i:%s.%f')))), '%i:%s.%f') AS avg_lap_time
FROM f1.lap_times AS lt
	JOIN f1.races AS ra ON lt.raceId = ra.raceId
GROUP BY year, name

# The average number of pit stops by race over the years

SELECT 
DISTINCT year,
name,
SUM(stop) OVER (PARTITION BY year, ps.raceId) AS total_stops
FROM f1.pit_stops AS ps
	JOIN f1.races AS ra ON ps.raceid=ra.raceid

# Which F-1 teams have been the most successful in terms of championships won?

SELECT
year,
constructorRef,
sum(points) AS points 
FROM f1.constructors AS c
	JOIN f1.results AS r ON c.constructorId = r.constructorId
	JOIN f1.races AS ra ON r.raceId = ra.raceId
WHERE points != 0
GROUP BY constructorRef,year
ORDER BY year desc

# Amount of drivers of different nationality

SELECT 
nationality,
count(nationality) AS number
FROM f1.drivers
GROUP BY nationality 
ORDER BY number DESC

# Max and average speed 

SELECT 
	DISTINCT year,
    CONCAT(d.forename, ' ', d.surname) AS name,
    CASE 
        WHEN fastestLapSpeed = '\\N' THEN 'no data'
        ELSE MAX(fastestLapSpeed) OVER (PARTITION BY year, r.driverid)
    END AS MAX_speed,
    CASE 
        WHEN fastestLapSpeed = '\\N' THEN 'no data'
		ELSE ROUND(AVG(fastestLapSpeed) OVER (PARTITION BY year, r.driverid), 3) 
	END AS avg 
FROM f1.results AS r 
JOIN f1.drivers AS d ON r.driverid = d.driverid
JOIN f1.races AS ra ON r.raceId = ra.raceId
ORDER BY MAX_speed DESC

# Fastest lap time 
    
WITH CTE_Laptime AS
(SELECT Driverid, raceid, fastestlaptime FROM results)
SELECT 
	ra.raceid,
    c.Driverid,
	year,
    ra.name AS track_name, 
    CONCAT(d.forename, ' ', d.surname) AS driver_name,
    fastestlaptime
From  CTE_Laptime AS c 
	JOIN f1.races AS ra
		ON C.raceId = ra.raceId
	JOIN f1.drivers AS d 
		ON C.driverid=d.driverid
        
# Fastest pit stops 

WITH CTE_pitstop AS (
    SELECT 
    year,
    c.name AS Manufacturer,
    ra.name AS track_name,
	ps.duration
    FROM f1.pit_stops AS ps
        JOIN f1.constructor_results AS cr ON ps.raceid = cr.raceid
        JOIN f1.constructors AS c ON cr.constructorId = c.constructorId
        JOIN f1.races AS ra ON ps.raceId = ra.raceId
)
SELECT 
	year,
	manufacturer,
	track_name,
	ROUND(AVG(duration), 3) AS average_pitstop,
	ROUND(MIN(duration), 3) AS fastest_pitstop
FROM CTE_pitstop
GROUP BY Year, manufacturer, track_name
ORDER BY year DESC

# The most popular race track from all the time 

SELECT 
c.name, 
COUNT(raceid) AS races_score 
FROM f1.races AS r
JOIN f1.circuits AS c
	ON r.circuitId = c.circuitId
GROUP BY c.name
ORDER BY races_score DESC
