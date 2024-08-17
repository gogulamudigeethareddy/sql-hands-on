--WINDOWING FUNCTIONS

--finding max age of customers based on region and state
SELECT region, state, MAX(age)
FROM customers c
GROUP BY region,state;
--finding rows that match max age
SELECT c.region, c.state, c.firstname, c.lastname, c.age
FROM customers c
JOIN(SELECT c.region, c.state, MAX(age) AS max_age
     FROM customers c
     GROUP BY region, state) s
  ON c.region = s.region
AND c.state = s.state
AND c.age = s.max_age
ORDER BY c.region, c.state;
--Using window function
SELECT c.region, c.firstname, c.lastname, c.age,
       MAX(age) OVER(PARTITION BY region, state) AS max_age
FROM customers c
ORDER BY c.region, c.state;
--Only matching rows
SELECT s.region, s.state, s.firstname, s.lastname, s.age
FROM ( SELECT c.region, c.state, c.firstname, c.lastname, c.age,
              MAX(age) OVER(PARTITION BY region,state) AS max_age
        FROM CUSTOMERS c) s
WHERE s.age = s.max_age
ORDER BY s.region, s.state;

--Basic Windowing syntax

SELECT order_id          AS "OrderId",
       prod_id          AS "Product",
       quantity         AS "Quantity",
       SUM(quantity) OVER(PARTITION BY prod_id) AS "Total Quantity",
       MIN(quantity) OVER(PARTITION BY prod_id) AS "Minimum Quantity",
       AVG(quantity) OVER(PARTITION BY prod_id) AS "Average Quantity",
       MAX(quantity) OVER(PARTITION BY prod_id) AS "Maximum Quantity"
FROM orders;       

SELECT "state", firstname, lastname,
        ROW_NUMBER() OVER(PARTITION BY "state" ORDER BY lastname DESC) AS row_num
FROM customers
WHERE LENGTH("state") > 0;

SELECT n, 
       ROW_NUMBER()      OVER(ORDER BY n),
       RANK()            OVER(ORDER BY n),
       DENSE_RANK()      OVER(ORDER BY n),
       PERCENT_RANK()    OVER(ORDER BY n),   --relative rank
       CUME_DIST()       OVER(ORDER BY n)    --cummulative distribution
FROM (VALUES (1),(1),(2),(3),(3)) v(n)
ORDER BY n;

--Ordered Aggregation

SELECT order_id,
       product_id,
       quantity,
       SUM(quantity) OVER(PARTITION BY order_id)                   AS "Sum Unordered",
       SUM(quantity) OVER(PARTITION BY order_id ORDER BY prod_id)  AS "Sum Product Ordered",
       SUM(quantity) OVER(PARTITION BY order_id ORDER BY quantity) AS "Sum Quantity Ordered"
FROM orders
WHERE order_id = 1
ORDER BY prod_id;
--Functions relative to current row
SELECT a, n,
       LAG(n)           OVER(PARTITION BY a ORDER BY n ASC) AS "Previous row",
       LEAD(n)          OVER(PARTITION BY a ORDER BY n ASC) AS "Next row",
       LAG(n,2)         OVER(PARTITION BY a ORDER BY n DESC) AS "Lag by 2,DESC",
       LEAD(n,2,5)      OVER(PARTITION BY a ORDER BY n DESC) AS "Default value",
       FIRST_VALUE(n)   OVER(PARTITION BY a ORDER BY n ASC),
       LAST_VALUE(n)    OVER(PARTITION BY a ORDER BY n ASC),
       NTH_VALUE(n,2)   OVER(PARTITION BY a ORDER BY n DESC) AS "2nd from end",
       ROW_NUMBER()     OVER(PARTITION BY a ORDER BY n ASC) AS "rn"
FROM (VALUES ('a',1), ('a',2), ('b',1), ('b',2), ('b',3)) v(a,n)
ORDER BY a, n;
--Ordering by date
SELECT order_id, order_date,
       LEAD(order_id) OVER(ORDER BY order_date) AS "Next Order ID",
       LEAD(order_date) OVER(ORDER BY order_date) AS "Next Order Date"
FROM orders;

--Limiting rows to be used by the window function

--filtering data
SELECT "state", city, age,
        AVG(age) 
        --FILTER(WHERE CITY LIKE 'B%') 
        OVER(PARTITION BY "state")
FROM customers 
WHERE "state" LIKE '0%'
ORDER BY "state", city;
--Using the frame clause
SELECT order_id, prod_id, quantity,
       SUM(quantity) OVER(PARTITION BY orderid ORDER BY prod_id   --here, frame clause is "ROWS"
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "Default frame", 
       SUM(quantity) OVER(PARTITION BY orderid ORDER BY prod_id
               ROWS 2 PRECEDING)                                 AS "2 preceding", 
       SUM(quantity) OVER(PARTITION BY orderid ORDER BY prod_id
               ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)         AS "2 following", 
       SUM(quantity) OVER(PARTITION BY orderid ORDER BY prod_id
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "Entire window" 
FROM orders
WHERE order_id = 1;       
--Using RANGE as frame type
SELECT customer_id, order_id, order_date, net_amount,
       SUM(net_amount) OVER(ORDER BY order_date
                            RANGE BETWEEN '2 days' PRECEDING AND '2 days' FOLLOWING)
FROM orders
WHERE order_date BETWEEN '1 Jan 2023' AND '30 June 2023';
--Using GROUP and EXCLUDE, rows can be limited

--Full syntax for window function
{
SELECT window_function(exp1,exp2,....) --0/more arguments(SUM,MIN,..)
       FILTER (WHERE filter_clause)
       OVER(
            PARTITION BY exp1,exp2,...
            ORDER BY exp1,exp2,...
            {RANGE | ROWS | GROUPS }  --Optional clause
                {frame_start
                  | frame_start frame_exclusion
                  | BETWEEN frame_start AND frame_end
                  | BETWEEN frame_start and frame_end frame_exclusion})
frame_start and frame_end:
      UNBOUNDED PRECEDING
      offset PRECEDING     --Offset can be numeric or interval(for dates)
      CURRENT ROW
      offset FOLLOWING
      UNBOUNDED FOLLOWING 
frame_exclusion:
      EXCLUDE { CURRENT_ROW | GROUP | TIES | NO OTHERS }
}
--WINDOW Clause
SELECT a, n,
       LAG(n)          OVER w1 AS "Previous row",
       LEAD(n)         OVER w1 AS "Next row",
       LAG(n,2)        OVER w2 AS "Lag by 2,DESC",
       LEAD(n,2,5)     OVER w2  AS "Default value",
       FIRST_VALUE(n)  OVER w1 ,
       LAST_VALUE(n)   OVER w1 ,
       NTH_VALUE(n,2)  OVER w2 AS "2nd from end",
       ROW_NUMBER()    OVER w1  AS "rn"
FROM (VALUES ('a',1), ('a',2), ('b',1), ('b',2), ('b',3)) v(a,n)
WINDOW
     w1 AS (PARTITION BY a ORDER BY n ASC),
     w2 AS (PARTITION BY a ORDER BY n DESC)
ORDER BY a, n;


--LIMITING RESULTS WITH SUBQUERY AND CONDITIONAL FUNCTIONS

--Using EXISTS function
SELECT c.* 
FROM customers c
WHERE EXISTS(
        SELECT *
        FROM orders o
        WHERE c.customer_id = o.customer_id
        );
--Equivalent query using JOIN
SELECT DISTINCT c.*
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id;
--Showing equivalence
WITH e AS (
    SELECT c.*
    FROM customers c
    WHERE EXISTS (
       SELECT *
       FROM orders o
       WHERE c.customer_id = o.customer_id
    )
),
j AS ( 
  SELECT DISTINCT c.*
  FROM customers c
  JOIN orders o
    ON o.customer_id = c.customer_id
)

--SELECT COUNT(*) over(), * FROM e
--EXCEPT 
SELECT COUNT(*) over(), * FROM j
EXCEPT
SELECT COUNT(*) over(), * FROM e
;
--Using NOT EXISTS
SELECT c.* 
FROM customers c
WHERE NOT EXISTS(
               SELECT *
               FROM orders o
               WHERE c.customer_id = o.customer_id
               );
SELECT c.* 
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
--Trouble with NULLS
WITH cte1 AS(
       SELECT * 
       FROM (VALUES (1), (2), (NULL)) v(n)
),
cte2 AS(
   SELECT * 
   FROM (VALUES(NULL::INT)) v(n)
)
SELECT cte1.*
FROM cte1
WHERE NOT EXISTS (
              SELECT *
              FROM cte2
              WHERE cte2.n = cte1.n
);

--IN Function

SELECT c.*
FROM customers c
WHERE customer_id IN ( SELECT o.customer_id 
                       FROM orders o);
--NOT IN Function
SELECT *
FROM customers c
WHERE customer_id NOT IN ( SELECT o.customer_id 
                            FROM orders o
                          );
SELECT c.*
FROM customers c
WHERE customer_id IN ( SELECT o.customer_id 
                       FROM orders o);
SELECT c.* 
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
--Trouble with NULLS
WITH cte1 AS(
       SELECT * 
       FROM (VALUES (1), (2), (NULL)) v(n)
),
cte2 AS(
   SELECT * 
   FROM (VALUES(NULL::INT)) v(n)
)
SELECT cte1.*
FROM cte1
WHERE cte1.n NOT IN(
              SELECT cte2.n
              FROM cte2
);

--ANY(SOME) function

SELECT c.*                                
FROM customers c                --similar to "IN"
WHERE customer_id = ANY ( SELECT o.customer_id 
                            FROM orders o
                          );
--Not expressions and ANY(SOME)
SELECT *                      
FROM (VALUES (1),(2)) v(n)      --not same as "NOT IN"
WHERE v.n <> ANY
               (SELECT *
                FROM (VALUES (1),(2)) v(n))

--ALL Function

SELECT c.*
FROM customers c
WHERE customer_id = ALL ( 
                        SELECT o.customer_id 
                        FROM orders o
);
--Not expressions and ALL
SELECT *                      
FROM (VALUES (1),(2)) v(n)      --same as "NOT IN"
WHERE v.n <> ALL
               (SELECT *
                FROM (VALUES (1),(2)) v(n))


--ARRAY AND RANGE FUNCTIONS


SELECT INT4RANGE(1,4)                                   AS "Default [) = closed-open",  --Closed--> included, open --> not included
       NUMRANGE(1.618033, 3.141592, '[]')               AS "Pi to Pi [] closed",
       DATERANGE('20230101', '20230306', '()')          AS "Dates () = open",
       TSRANGE(LOCALTIMESTAMP, LOCALTIMESTAMP + INTERVAL '5 days', '(]') AS "Timestamp (] = open-closed";
    
SELECT ARRAY[1,2,3]                             AS "Int aaray using type inference",
       ARRAY[3.14159::FLOAT]                    AS "Floating numbers, explicit typing",
       ARRAY[CURRENT_DATE, CURRENT_DATE+1]      AS "Two dates, inferred";

CREATE TEMP TABLE a_table(a TEXT[]);
INSERT INTO a_table VALUES('{a,b,c}');
SELECT * FROM a_table;

DROP TABLE IF EXISTS a_table;

SELECT ARRAY[1,2,3] = ARRAY[2,3,4]      AS "Equality",
       ARRAY[1,2,3] <> ARRAY[2,3,4]     AS "Inequality",
       ARRAY[1,2,3] < ARRAY[2,3,4]      AS "Less than",
       ARRAY[1,2,3] <= ARRAY[2,3,4]     AS "Less than or equal to",
       ARRAY[1,2,3] > ARRAY[2,3,4]      AS "Greater than",
       ARRAY[1,2,3] >= ARRAY[2,3,4]     AS "Greater than or equal to";
      
SELECT INT4RANGE(1,3) = INT4RANGE(1,3)   AS "Equality",
       INT4RANGE(1,3) <> INT4RANGE(1,3)  AS "Inequality",
       INT4RANGE(1,3) < INT4RANGE(1,3)   AS "Less than",
       INT4RANGE(1,3) <= INT4RANGE(1,3)  AS "Less than or equal to",
       INT4RANGE(1,3) > INT4RANGE(1,3)   AS "Greater than",
       INT4RANGE(1,3) >= INT4RANGE(1,3)  AS "Greater than or equal to"
                                  
SELECT ARRAY[1,2,3] @> ARRAY[2,3]         AS "Contains",
       ARRAY['a','b'] <@ ARRAY['a','b']   AS "Contained by",                      
       ARRAY[1,2,3]  &&  ARRAY[2,3,4]     AS "Overlaps";

SELECT INT4RANGE(1,5) @> INT4RANGE(2,3)                              AS "Contains",
       DATERANGE(CURRENT_DATE, CURRENT_DATE+30) @> CURRENT_DATE+15  AS "Containes value",
       INT4RANGE(1,5) <@ INT4RANGE(2,3)                             AS "Contained by",
       CURRENT_DATE+15 <@ DATERANGE(CURRENT_DATE, CURRENT_DATE+30)  AS "Value contained by",
       NUMRANGE(1.618, 3.14159) && NUMRANGE(0, 5)                   AS "Overlaps";

SELECT INT4RANGE(1,5) << INT4RANGE(5,6)  AS "Left",
       INT4RANGE(1,5) >> INT4RANGE(5,6)  AS "Right",
       INT4RANGE(1,5) &< INT4RANGE(5,6)  AS "Does not extend to the right of",
       INT4RANGE(1,5) &> INT4RANGE(5,6)  AS "Does not extend to the left of";
 
SELECT INT4RANGE(1,5) -|- INT4RANGE(5,6)  AS "Adjacent to",
       INT4RANGE(1,5) + INT4RANGE(5,6)  AS "Union",
       INT4RANGE(1,5) * INT4RANGE(5,6)  AS "Intersection",
       INT4RANGE(1,5) - INT4RANGE(5,6)  AS "Difference";
 
SELECT ARRAY[1,2,3] || ARRAY[4,5,6]     AS "Concatenation",
       ARRAY_CAT(ARRAY[1,2,3], ARRAY[4,5,6]);
SELECT 3 || ARRAY[4,5,6]                AS "Adding value to array",
       ARRAY_PREPEND(3, ARRAY[4,5,6]);
SELECT ARRAY[4,5,6] || 7                AS "Adding value to the end",
       ARRAY_APPEND(ARRAY[4,5,6], 7);

--Range and array functions

SELECT ARRAY_NDIMS(ARRAY[[1],[2]])    AS "Dimensions",
       ARRAY_DIMS(ARRAY[[1],[2]])     AS "Dimensions as text",
       ARRAY_LENGTH(ARRAY[1,2,3],1)   AS "Length",
       ARRAY_LOWER(ARRAY[1,2,3],1)    AS "Lower bound",
       ARRAY_UPPER(ARRAY[1,2,3],1)    AS "Upper bound",
       CARDINALITY(ARRAY[[1],[2]])    AS "Cardinality";  --total number of elements

SELECT ARRAY_POSITION(ARRAY[4,5,6],5)  AS "Item position",
       ARRAY_POSITIONS(ARRAY[1,2,2],2) AS "Item positions";    

SELECT ARRAY_CAT(ARRAY[1,2], ARRAY[3,4])  AS "Concatenate", 
       ARRAY_APPEND(ARRAY[1,2,3],4)       AS "Append",
       ARRAY_PREPEND(0, ARRAY[1,2,3])     AS "Prepend",
       ARRAY_REMOVE(ARRAY[1,2,2],2)       AS "Remove",     
       ARRAY_REPLACE(ARRAY[1,2,3],3,4)    AS "Replace";
       
SELECT LOWER(INT4RANGE(1,5))          AS "Lower bound",
       UPPER(INT4RANGE(1,5))          AS "Upper bound",
       ISEMPTY('[4,4)'::INT4RANGE)    AS "Is range empty",
       LOWER_INC(INT4RANGE(1,5))      AS "Inclusive lower",
       UPPER_INC(INT4RANGE(1,5))      AS "Inclusive upper",
       LOWER_INF('(,)'::INT4RANGE)    AS "Infinite lower", 
       UPPER_INF('(,)'::INT4RANGE)    AS "Infinite upper";
    
SELECT RANGE_MERGE(INT4RANGE(1,5),INT4RANGE(6,10));
       
--Array Comparisions

SELECT 2 IN (1,2,3)             AS "IN",
       2 NOT IN (1,2,3)         AS "NOT IN",
       2 = ALL(ARRAY[2,2,2])    AS "ALL",
       2 = ANY(ARRAY[1,2,3])    AS "ANY",
       2 = SOME(ARRAY[4,5,6])   AS "SOME",
       2 = ANY(ARRAY[2,NULL])   AS "= ANY with NULLs",
       2 <> ANY(ARRAY[2,NULL])  AS "!= ANY with NULLs",
       2 = ALL(ARRAY[2,NULL])   AS "= ALL with NULLs",
       2 <> ALL(ARRAY[2,NULL])  AS "!= ALL with NULLs";
       
SELECT 5 IN (RANGE(1,10))    AS "IN a range";       --Error : function does not exist
       
--Converting and formatting

SELECT INT4RANGE '(1,5)'        AS "Text to range",
       INT4RANGE(1,5)::TEXT     AS "Range to text";
       
SELECT STRING_TO_ARRAY('1,2,3',',')            AS "String to an array",
       STRING_TO_ARRAY('1,2,3,xx,5',',','xx')  AS "Value to null",
       STRING_TO_ARRAY('1,2,3,,5',',','')      AS "Empty value to null";
       
SELECT ARRAY_TO_STRING(ARRAY[1,2,3],'|')               AS "Array to string",    
       ARRAY_TO_STRING(ARRAY[1,2,null,4],'/','Hello')  AS "Array to string with nulls";
       
DROP TABLE IF EXISTS TestArrays;
CREATE TEMP TABLE TestArrays(AnArray INT[]);
INSERT INTO TestArrays(AnArray)
        VALUES('{1,2,3}');
SELECT AnArray          AS "As an array",
       AnArray::TEXT    AS "As a text string"
FROM TestArrays;        
        
               
       
       
       
       
       
       
       
       
       
       

