SELECT * 
FROM aircraft_code;

ALTER TABLE aircraft_code
DROP COLUMN id;

SELECT code || ',' || aircraft_name
FROM aircraft_code;

SELECT CONCAT(code,':',aircraft_name)AS aircrafts
FROM aircraft_code;

SELECT code,aircraft_name,
	   SUBSTRING(aircraft_name,1,8)AS craft_name
FROM aircraft_code;

SELECT code,aircraft_name,
REPLACE(SUBSTRING(aircraft_name,1,8),' ','')AS craft_name
FROM aircraft_code;

SELECT code,aircraft_name,
UPPER(REPLACE(SUBSTRING(aircraft_name,1,8),' ',''))AS craft_name
FROM aircraft_code;

 							CREATING TABLE
CREATE TABLE aircraft_delay
(
	id SERIAL PRIMARY KEY,Year INT,Month INT,DayofMonth INT,DayOfWeek INT,DepTime TIME,CRSDepTime TIME,ArrTime TIME,CRSArrTime TIME,UniqueCarrier CHAR varying,FlightNum INT,TailNum CHAR varying,ActualElapsedTime NUMERIC(5,1),CRSElapsedTime NUMERIC(5,1),AirTime NUMERIC(5,1),ArrDelay NUMERIC(5,1),DepDelay NUMERIC(5,1),Origin CHAR varying,Dest CHAR varying,Distance NUMERIC(5,1),TaxiIn NUMERIC(5,1),TaxiOut NUMERIC(5,1),Cancelled NUMERIC(5,1),CancellationCode CHAR,Diverted NUMERIC(5,1),CarrierDelay NUMERIC(5,1),WeatherDelay NUMERIC(5,1),NASDelay NUMERIC(5,1),SecurityDelay NUMERIC(5,1),LateAircraftDelay NUMERIC(5,1)
);

SELECT * FROM aircraft_delay;

COPY aircraft_delay(id,Year,Month,DayofMonth,DayOfWeek,DepTime,CRSDepTime,ArrTime,CRSArrTime,UniqueCarrier,FlightNum,TailNum,ActualElapsedTime,CRSElapsedTime,AirTime,ArrDelay,DepDelay,Origin,Dest,Distance,TaxiIn,TaxiOut,Cancelled,CancellationCode,Diverted,CarrierDelay,WeatherDelay,NASDelay,SecurityDelay,LateAircraftDelay)
FROM '/Users/geethareddy/Documents/SQL/DelayedFlights.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE aircraft_delay
ALTER COLUMN DepTime TYPE CHAR varying,
ALTER COLUMN crsdeptime TYPE CHAR varying,
ALTER COLUMN ArrTime TYPE CHAR varying,
ALTER COLUMN CRSArrTime TYPE CHAR varying;

SELECT * FROM aircraft_delay limit 10;

						GETTING AVERAGE DELAY
SELECT uniquecarrier,
	   AVG(depdelay)
FROM aircraft_delay
GROUP BY uniquecarrier

SELECT d.uniquecarrier,
       c.aircraft_name,
	   AVG(d.depdelay)
FROM aircraft_delay d
INNER JOIN aircraft_code c
		ON d.uniquecarrier = c.code
GROUP BY d.uniquecarrier,
		 c.aircraft_name
ORDER BY AVG(d.depdelay);

SELECT d.uniquecarrier,
       c.aircraft_name,
	   AVG(d.depdelay) AS dept_delay,
	   AVG(d.arrdelay) AS arr_delay
FROM aircraft_delay d
INNER JOIN aircraft_code c
		ON d.uniquecarrier = c.code
GROUP BY d.uniquecarrier,
		 c.aircraft_name
ORDER BY AVG(d.depdelay);




