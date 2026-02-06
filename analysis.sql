### ROUTE WISE ANALYSIS
use flight_analysis;
select f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID,
a1.CITY_NAME AS ORIGIN_CITY,
a2.CITY_NAME AS DEST_CITY, 
SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM FLIGHT f
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
JOIN airport a1 ON f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
JOIN airport a2 ON f.DEST_AIRPORT_ID = a2.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC;

### TOTAL PASSENGERS SERVED IN THE DURATION 

SELECT f.YEAR, f.MONTH, round(sum(fm.PASSENGERS)/1000000,2) as TOTAL_PASSENGERS
FROM flight f
join flightmetrics fm on f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY f.YEAR,f.MONTH
order by f.YEAR, f.MONTH;

-- DETERMINE AVG PASSENGERS PER FLIGHT FOR VARIOUS ROUTES AIRPORTS 
SELECT avg(fm.PASSENGERS) as AVG_PASSENGERS, f.ORIGIN_AIRPORT_ID, COUNT(f.FLIGHT_ID),
a.CITY_NAME AS ORIGIN_CITY from FLIGHT f
join FLIGHTMETRICS fm ON f.FLIGHT_ID = fm. FLIGHT_ID
join AIRPORT a ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID
ORDER BY AVG_PASSENGERS DESC;

-- AVERAGE PASSENGER PER DESTINATION CITY 

SELECT avg(fm.PASSENGERS) as AVG_PASSENGERS, f.DEST_AIRPORT_ID, COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS,
a.CITY_NAME AS DEST_CITY 
from FLIGHT f
join FLIGHTMETRICS fm ON f.FLIGHT_ID = fm. FLIGHT_ID
join AIRPORT a ON f.DEST_AIRPORT_ID = a.AIRPORT_ID
GROUP BY f.DEST_AIRPORT_ID
ORDER BY AVG_PASSENGERS DESC;

### Assess flight frequency and identify high-traffic corridors.
# To assess flight frequency and identify high-traffic corridors, we will:
# 1.Count how often each route (origin → destination) appears — that’s flight frequency.
# 2.Identify routes with the highest number of flights — these are high-traffic corridors.

SELECT f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID,
a1.city_name as origin_city,
a2.city_name as dest_city,
count(*) as FLIGHT_COUNT from FLIGHT f 
join airport a1 on f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
join airport a2 on f.DEST_AIRPORT_ID = a2.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY FLIGHT_COUNT DESC
limit 10;

-- TOTAL PASSENGERS AND TOTAL CITIES
SELECT  a.city_name as ORIGIN_CITY,
SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
COUNT(f.FLIGHT_ID) as TOTAL_FLIGHTS from flight f 
join flightmetrics fm on f.FLIGHT_ID = fm.FLIGHT_ID
join AIRPORT a on f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
GROUP BY a.CITY_NAME 
ORDER BY TOTAL_FLIGHTS DESC;

SELECT  a.city_name as DEST_CITY,
SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
COUNT(f.FLIGHT_ID) as TOTAL_FLIGHTS from flight f 
join flightmetrics fm on f.FLIGHT_ID = fm.FLIGHT_ID
join AIRPORT a on f.DEST_AIRPORT_ID = a.AIRPORT_ID
GROUP BY a.CITY_NAME 
ORDER BY TOTAL_FLIGHTS DESC;
use flight_analysis;

## Corelation Between Population and Air Traffic.
SELECT * FROM CITY;
SELECT * FROM ALL_CITY_POP;
SET SQL_Safe_Updates = 0;
update city
set CityName = SUBSTRING_INDEX(cityname,',',1);
SELECT * FROM CITY;

create table city_new(select substring_index(CityName,',',1) as City_Name,c.State_ABR,
c.State_NM, a.Population
from city c
left join all_city_pop as a
on a.city_name = c.Cityname);

select * from city_new;

### Analyse the relation between city population and airport traffic. 

SELECT c.CITY_NAME, c.POPULATION,
SUM(fm.PASSENGERS)AS TOTAL_PASSENGERS
FROM CITY_NEW c
JOIN AIRPORT a ON SUBSTRING_INDEX(a.CITY_NAME, ',', 1) = c.CITY_NAME
JOIN FLIGHT f ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY TOTAL_PASSENGERS DESC;

SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio  
FROM City_NEW c
JOIN Airport a ON SUBSTRING_INDEX(a.CITY_NAME, ',',1) = c.CITY_NAME
JOIN Flight f ON f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY Pass_Pop_ratio DESC;

## Cities as Destination

SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM City_new c
JOIN Airport a ON SUBSTRING_INDEX(a.CITY_NAME, ',',1) = c.CITY_NAME
JOIN Flight f ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY TOTAL_PASSENGERS DESC;

SELECT 
    c.CITY_NAME,
    c.POPULATION,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    round(sum(fm.PASSENGERS)/c.POPULATION,2) AS POP_PASS_RATIO
FROM City_new c
JOIN Airport a ON SUBSTRING_INDEX(a.CITY_NAME, ',',1) = c.CITY_NAME
JOIN Flight f ON f.Dest_AIRPORT_ID = a.AIRPORT_ID
JOIN Flightmetrics fm ON f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY c.CITY_NAME, c.POPULATION
ORDER BY TOTAL_PASSENGERS DESC;