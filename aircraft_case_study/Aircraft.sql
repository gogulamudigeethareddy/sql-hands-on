SELECT * FROM aircraft_cancellation
SELECT * FROM aircraft_delay
SELECT * FROM aircraft_code

               WINDOW FUNCTIONS
               
SELECT uniquecarrier,
      flightnum,
      origin,
      dest,
      arrdelay,
    ROW_NUMBER() over(ORDER BY flightnum) AS rn
FROM aircraft_delay
WHERE dayofmonth = '1'
AND uniquecarrier = 'AA'
AND origin='MCI'

SELECT uniquecarrier,
      flightnum,
      origin,
      dest,
      arrdelay,
     RANK() over(ORDER BY arrdelay DESC) AS delay_rank
FROM aircraft_delay
WHERE dayofmonth = '1'
AND uniquecarrier = 'AA'
AND origin='MCI'

SELECT uniquecarrier,
      flightnum,
      origin,
      dest,
      arrdelay,
    DENSE_RANK() over(ORDER BY arrdelay DESC) AS delay_rank
FROM aircraft_delay
WHERE dayofmonth = '1'
AND uniquecarrier = 'AA'
AND origin='MCI'

SELECT uniquecarrier,
      flightnum,
      origin,
      dest,
      arrdelay,
    DENSE_RANK() over(PARTITION BY dest ORDER BY arrdelay DESC) AS delay_rank
FROM aircraft_delay
WHERE dayofmonth = '1'
AND uniquecarrier = 'AA'
AND origin='MCI'
               
SELECT month,
      SUM(depdelay) AS depature_delay
 FROM aircraft_delay
WHERE origin = 'DTW'
GROUP BY month;

WITH monthly_delays AS(
SELECT month,
      SUM(depdelay) AS depature_delay
 FROM aircraft_delay
WHERE origin = 'DTW'
GROUP BY month)
SELECT month,
      depature_delay, 
      LAG(depature_delay,1) OVER(ORDER BY month) AS prior_month_delay
  FROM monthly_delays

WITH monthly_delays AS(
SELECT month,
      SUM(depdelay) AS depature_delay
 FROM aircraft_delay
WHERE origin = 'DTW'
GROUP BY month)
SELECT month,
      depature_delay, 
      LAG(depature_delay,1) OVER(ORDER BY month) AS prior_month_delay,
      departure_delay - LAG(depature_delay,1) OVER(ORDER BY month) AS change
-   FROM monthly_delays


SELECT d.month,
      d.uniquecarrier,
      c.aircraft_name,
      d.flightnum,
      d.origin,
      d.dest,
      d.arrdelay,
      d.depdelay
  FROM aircraft_delay d
INNER JOIN aircraft_code c
       ON d.uniquecarrier = c.code
  WHERE dest = 'ICT';

SELECT d.uniquecarrier,
      c.aircraft_name,
      AVG(arrdelay) AS avg_arrdelay
   FROM aircraft_delay d
INNER JOIN aircraft_code c
      ON c.code = d.uniquecarrier
     WHERE dest = 'ICT' 
      AND arrdelay <> 0
   GROUP BY d.uniquecarrier,
            c.aircraft_name   
   ORDER BY avg_arrdelay;
    





