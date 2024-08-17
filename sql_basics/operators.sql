--MATH OPERATORS


--ANSI Standard
SELECT 2+3      AS "Addition",
       2-3      AS "Subtraction",
       2*3      AS "Multiplication",
       5/2      AS "Division(Integer)",
       5.0/2    AS "Division(Non-integer)";
--Convenience Operators
SELECT 5%2 AS  "Modulo(remainder)" ,
       5^2 AS  "Exponent",
       |/16 AS "Square root",
       @ -10 AS "Absolute value";
--PostgreSQL Extensions  
SELECT ||/27 AS "Cube root",
       5!   AS "Factorial",
       !!5   AS "Factorial(prefix)";
--Bitwise Operators
SELECT 10 & 15 AS "And",
       10 | 15 AS "Or",
       10 # 15 AS "Xor",
       ~10     AS "Negation",
       10 << 1 AS "Left shift",
       10 >> 1 AS "Right shift";       
       
--Scalar Functions
SELECT ABS(-10) AS "Absolute value",
       MOD(5,2) AS "Modulus",
       LOG(2,8) AS "General logarithm",
       LN(10)   AS "Natural logarithm";   --e as base
       
SELECT EXP(1)     AS "Exponential of e",
       POWER(5,2) AS "Power",
       SQRT(25)    AS "Square root",
       FLOOR(3.14159) AS "Floor",
       CEIL(3.14159)  AS "Ceiling";
--PostgreSQL extensions
SELECT CBRT(8) AS "Cube root",
       DEGREES(10) AS "Radians to degrees",
       RADIANS(10) AS "Degrees to radians",
       LOG(10)     AS "Base 10 logarithm",
       PI()        AS "Pi constant";
       
SELECT ROUND(10.8)     AS "Round to nearest integer",
       ROUND(15.986,2) AS "Round to a number of decimal places",
       SCALE(12.7632)  AS "Number of digits after decimal point";
SELECT SIGN(-1)        AS "Sign",
       TRUNC(17.67)    AS "Truncate toward zero",
       TRUNC(27.873,2) AS "Truncate to a number of decimal places";   
--Random number functions   
--SELECT SETSEED(.10)   (same result produces all the time for random function)    
SELECT RANDOM();
--WIDTH_BUCKET(ANSI Standard)
SELECT WIDTH_BUCKET(3.14159,0,5,10)     AS "10 buckets from 0 to 5(ANSI)",
       WIDTH_BUCKET(10, ARRAY[5,10,15]) AS "Array of buckets";
       
--Trigonometric Functions    
   
SELECT SIN(.45),
       COS(.45),
       TAN(.45);
SELECT ASIN(.45),
       ACOS(.45),
       ATAN(.45);   
--PostgreSQL Extensions    
SELECT COT(.45),
       ATAN2(1,45);
SELECT SIND(.45),   --Degrees
       COSD(.45),    
       TAND(.45);     
SELECT ASIND(.45),
       ACOSD(.45),
       ATAND(.45);
       
--Aggregate Functions       

SELECT COUNT(*)                 AS "Number of customers",
       COUNT(DISTINCT "state")  AS "Number of states",
       MIN(age)                 AS "minimum age",
       AVG(age)                 AS "Average age",
       MAX(age)                 AS "Maximum age",
       SUM(income)              AS "Total inncome",
       AVG(age) FILTER(WHERE "state" IN ('NY','CA'))
FROM customers;

SELECT "state", AVG(INCOME) AS "Average Income"
FROM customers
GROUP BY "state"
HAVING MAX(age) > 50
ORDER BY "state";
--PostgreSQL extensions
SELECT BIT_AND(age) AS "the bitwise AND of all non_null ages",
       BIT_OR(age)  AS "the bitwise OR of all non-null ages"
FROM customers;
 
--Statistical Functions
SELECT STDDEV_POP(age),   --of population
       STDDEV_SAMP(age) FILTER (WHERE "state" = "NY"),  --of sample
       VAR_SAMP(income) FILTER (WHERE "age" < 25),
       VAR_POP(income),
       VARIANCE(income)
FROM customers;

SELECT c.state,
       CORR(c.age, o.netamount),
       COVAR_POP(c.age, o.netamount),
       REGR_INTERCEPT(c.age, o.netamount)   --regression analysis
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
WHERE c.state in ('NY','CA','TX')
GROUP BY c.state;

--Ordered-set aggregate functions
SELECT MODE() WITHIN GROUP(ORDER BY age),
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY age),
       PERCENTILE_DISC(ARRAY[0, 0.25, 0.5, 0.75, 1]) WITHIN GROUP(ORDER BY age)
FROM customers;
       
--Formatting Functions

SELECT '10'::INT,
       '10'::REAL,
       '10'::NUMERIC(5,2),
       '10'::MONEY;          
--Input formatting using TO_NUMBER function
SELECT '1,000'::INT     --Error due to comma
SELECT TO_NUMBER('1,000','9,999')::INT;

SELECT TO_NUMBER('-$15.00','SL99999D9999'):: MONEY AS "Text to money",
       TO_NUMBER('15000','99V999')        :: INT AS "Text to int with right shift";
--Output formatting using TO_CHAR function
SELECT TO_CHAR(15,'000')           AS "Keep leading zeros",     
       TO_CHAR(15.000,'15.000')    AS "keep trailing zeros",    
       TO_CHAR(15.000,'FM99.999')  AS "Strip trailing zeros";
SELECT TO_CHAR(15,'999th')                AS "Ordinary suffix",     
       TO_CHAR(15.000,'FMRN')             AS "Roman numerals",    
       TO_CHAR(15.000,'LFM99999D0099SG')  AS "Currency with trailing sign";


--STRING FUNCTIONS AND OPERATORS


--ANSI Functions and operators  

--Concatenation  
SELECT 'foo' || 'bar' AS "Concatenation";
SELECT 'The ' || 'answer ' || 'is ' || 15;
SELECT 'pi = '  || 3.14159 :: float8;
SELECT 'Today is: ' || CURRENT_DATE;
  
--Functions
SELECT UPPER('abc')             AS "Uppercase",
       LOWER('ABC')             AS "Lowercase",
       CHAR_LENGTH('ABC')       AS "Length in characters",
       OCTET_LENGTH('π')        AS "Length in octets",          --no of bytes the string is occupied
       TRIM('  ABC  ')          AS "Trim the spaces",
       TRIM(LEADING '-' FROM '---ABC---')  AS "Selective trim";   --Also trailing end and both ends
SELECT POSITION('HENRY' IN 'JOHN AND HENRY') AS "Character position",
       SUBSTRING('JOHN AND HENRY' FROM 10 FOR 4) AS "Extracted substring", --"For n" can be omitted
       OVERLAY('JOHN AND HENRY' PLACING 'Abcde' FROM 1 FOR 6) AS "Replaced substring";
  
--PostgreSQL String functions
SELECT ASCII('X'),
       CHR(88),
       LENGTH('50'),
       INITCAP('robert brown'),  --Initial captial
       LEFT('The answer', 5),
       RIGHT('The answer', 3),
       LTRIM('   15'),
       RTRIM('15----', '-X'),
       LPAD('20',5),        --Reverse to trim
       RPAD('25',5,'-X'),   --Reverse to trim
       REPEAT('ab',5);
SELECT REPLACE('JOHN AND HENRY', 'JOHN', 'FIRST'),
       REVERSE('ABCDEFGH'),
       SPLIT_PART('/tmp/my/dir', '/', 3),
       STRPOS('JOHN AND HENRY', 'HENRY'),  --first occurance of the substring
       SUBSTR('Abcdef', 2, 3),
       TRANSLATE('Robert Brown', 'o', 'u'),
       TRANSLATE('Robert Brown', 'rbn', 'xyz');    
       
--STRING_AGG(Vertical concatenation with a seperator)

SELECT STRING_AGG(categoryname, ',')                                       AS  "Unsorted",
       STRING_AGG(categoryname, ',' ORDER BY categoryname DESC)            AS  "Sorted",
       STRING_AGG(categoryname, ',') FILTER(WHERE categoryname LIKE '%s')  AS  "Filtered and unsorted"
FROM categories;
  
SELECT "state",
       STRING_AGG(DISTINCT age::TEXT, ',' ORDER BY age::TEXT ASC)
          FILTER(WHERE MOD(age, 2) = 0 AND age<30)
              AS "Evens under thirty",
       STRING_AGG(DISTINCT age::TEXT, ',' ORDER BY age::TEXT DESC)
          FILTER(WHERE MOD(age, 2) = 1 AND age<50)
              AS "Odds over fifty"
FROM customers             
WHERE "state" LIKE "%A%" 
GROUP BY "state"
ORDER BY "state"
LIMIT 3;
--CONCAT and CONCAT_WS(Horizontal concatenation with an optional seperator)
SELECT CONCAT(age,income,"state")  --like ||
FROM customers
WHERE customerid < 5;
  
SELECT CONCAT_WS(',', age, income, "state")
FROM customers
WHERE customerid < 5;  
  
--Pattern Matching
SELECT categoryname --case sensitive
FROM categories
WHERE categoryname LIKE 'S%'
   OR categoryname LIKE '%s'
   OR categoryname LIKE '%s%'
   OR categoryname LIKE '_r%'  -- '_' means one character
   OR categoryname ILIKE 'a%';  --'ILIKE' means case insensitive
  
SELECT categoryname
FROM categories
WHERE categoryname ~~ 'S%'   --LIKE
   OR categoryname ~~* 'a%'  --ILIKE
   OR categoryname !~~ 'M%'  --NOT LIKE
   OR categoryname !~~* '%z' --NOT ILIKE
  
SELECT '%_' AS "Must be escaped"
WHERE '%_' LIKE '#%#_' ESCAPE '#'
  
SELECT '10' SIMILAR TO '10'             AS "Exact",
       '10' SIMILAR TO '1%'             AS "Wildcard",
       '10' SIMILAR TO '1_'             AS "Single character",
       '10' SIMILAR TO '%(1|0)%'        AS "Alternation",
       '10' SIMILAR TO '[1234][0987]'   AS "Character class";
       
--Regular expressions 
 
SELECT 'John' ~ '.*John.*',  
       'John' ~* '.*John.*',  
       'John' !~ '.*John.*',  
       'John' !~* '.*John.*';  
--Substring
SELECT SUBSTRING('John & Henry' FROM 'n . H');    
--REGEX_ Functions
SELECT REGEXP_MATCH('John & Henry', 'n . H'),
       (REGEXP_MATCH('John & Henry', 'n . H'))[1],
       REGEXP_MATCH('John & Henry', '(.*hn) & (.*ry)');
SELECT REGEXP_MATCHES('Hello hackhikerhopehere', '(h[^h]+)(h[^h]+)', 'g');  --'g' means global     
       
SELECT REGEXP_REPLACE('Heart of Dark', 'D.*', 'Gold');
          
SELECT REGEXP_SPLIT_TO_ARRAY('hack transit hope guide here', ' (transit|guide) ');      
       
SELECT REGEXP_SPLIT_TO_TABLE('hack transit hope guide here', ' (transit|guide) ');      
      
--Text search types
SELECT 'John and Henry travelled with Ford and Benz'::TSVECTOR @@ 'John & Henry'::TSQUERY;

SELECT TO_TSVECTOR('John and Henry travelled with Ford and Benz') @@ TO_TSQUERY('John & Henry');

SELECT 'John and Henry travelled with Ford and Benz' @@ 'John & Henry';

--Converting and formatting functions

SELECT CONVERT('sql demo', 'UTF8', 'WIN1252');
SELECT CONVERT_FROM('I am already in UTF8!', 'UTF8');
SELECT CONVERT_TO('π', 'WIN1252');         -- ERROR: character with byte sequence 0xcf 0x80 in encoding "UTF8" has no equivalent in encoding "WIN1252"
--Encoding and decoding
SELECT ENCODE('lorem ipsum' :: bytea, 'base64'),
       DECODE('01000010', 'hex');
--Formatting
SELECT FORMAT('Hello %s', 'World')      AS "Hello World",
       FORMAT('The answer is %s', 2+3)  AS "The answer";
--Format Specifiers(starts with % and ends with the type of formatted argument)
SELECT FORMAT('%2$-4s is 2nd, %1$s is 1st', -1, 15);
SELECT FORMAT('%s again %1$s', '15');
       
SELECT FORMAT('INSERT INTO %I VALUES(%L, %L, %L)', 'Value Table', 1,2,3);       
       
    
--DATE AND TIME FUNCTIONS    
    
--Constructors
SELECT MAKE_DATE(2023,08,02),  
       MAKE_TIME(1,2,3.56),   
       MAKE_TIMESTAMP(2023,08,02,1,2,3.56);  --Year, month, day, hour, minute, second
SELECT MAKE_INTERVAL(15,10,11,12,1,2,3.15),  --Years, months, weeks, days
       MAKE_TIMESTAMPTZ(2023,10,11,1,2,3.15),
       MAKE_TIMESTAMPTZ(2023,10,11,1,2,3.15, 'CET');      
--Extractors
SELECT EXTRACT(DAY FROM CURRENT_TIMESTAMP)                              AS "ANSI EXTRACT Function",
       DATE_PART('DAY', CURRENT_TIMESTAMP)                              AS "PostgreSQL date_part function",
       DATE_PART('YEAR', CURREN T_DATE)                                  AS "Just the year",
       EXTRACT(CENTURY FROM INTERVAL '200 years, 10 months, 11 days')   AS "Extracting from an INTERVAL";
       
--Using math operators

SELECT DATE '20230301' + 13                     AS "pi day, 2023",
       '20230328'::DATE - 13                    AS "Ides of March",
       TIME '23:59:59' + INTERVAL '1 SECOND'    AS "The Midnight Hour";
SELECT DATE '20230314' + TIME '1:59:25.5423810740174501975142940269362749854133810'  AS "pi time!",
       pg_typeof(DATE '20230314' + TIME '1:59:25.6412673851674336567454875980'),
       DATE '20221224' + INTERVAL '1 DAY'       AS "Christmas,2022",
       -INTERVAL '1 HOUR' = INTERVAL '1 HOUR AGO' AS "An hour ago";
       
SELECT INTERVAL '30 MINUTES' - INTERVAL '15 MINUTES'                      AS "A quarter hour",
       INTERVAL '30 MINUTES' + INTERVAL '1 DAY' - INTERVAL '1800 SECONDS' AS "One day", 
       INTERVAL '1:00' * 2                                                AS "Two hours",      
       INTERVAL '2:00' / 2                                                AS "One Hour";              
--ANSI OVERLAPS Operator
SELECT (DATE '2022-02-15', DATE '2022-12-20') OVERLAPS (DATE '2022-10-26', DATE '2023-03-18'),
       (DATE '2022-02-15', INTERVAL '100 days') OVERLAPS (DATE '2022-10-26', DATE '2023-03-18')
SELECT * FROM orders
WHERE (order_date, INTERVAL '0 days') OVERLAPS (DATE '2023-06-12', DATE '2023-06-28')
             
--Date/Time Functions    
 
SELECT CURRENT_DATE,    
       CURRENT_TIME, 
       CURRENT_TIMESTAMP, 
       LOCALTIME,
       LOCALTIMESTAMP;
--Using Precision    
SELECT CURRENT_TIME(0), 
       CURRENT_TIMESTAMP(2), 
       LOCALTIME(4),
       LOCALTIMESTAMP(6);
--postgreSQL extensions
SELECT NOW(),
       TRANSACTION_TIMESTAMP(),
       STATEMENT_TIMESTAMP(),
       CLOCK_TIMESTAMP();        

SELECT TIMEOFDAY() AS "Current date and time",
       AGE(TIMESTAMP 'March 14, 1879') AS "Age of Albert Einstein",
       AGE(TIMESTAMPTZ '1945-08-14 12:34:56', TIMESTAMPTZ '2000-01-01 01:02:03');

--Date Math using EPOC

SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ '2022-12-25 15:30:14.37-01:00') -
       EXTRACT(EPOCH FROM TIMESTAMPTZ '2022-10-25 15:30:14.37+01:00') AS "Difference in seconds";

SELECT (EXTRACT(EPOCH FROM TIMESTAMPTZ '2023-07-10 12:08:22') - 
        EXTRACT(EPOCH FROM TIMESTAMPTZ '2023-04-10 12:08:22'))/60/60/24
                AS "Difference in hours using EPOC",
       TIMESTAMPTZ '2022-12-25 15:30:14' - TIMESTAMPTZ '2022-10-25 15:30:14' AS "Difference in hours",
       AGE(TIMESTAMPTZ '2022-12-25 15:30:14', TIMESTAMPTZ '2022-10-25 15:30:14') AS "Difference using AGE()";
--TO_TIMESTAMP(epoc)
SELECT CURRENT_TIMESTAMP                                    AS "Current timestamp",
       TO_TIMESTAMP(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP))  AS "Current time round trip";
SELECT TO_EPOC(CURRENT_TIMESTAMP);   --Error:function doesnot exist

--Converting and formatting Dates and Times

--strings to dates and times
SELECT TO_DATE('2022-10-06', 'YYYY-MM-DD')            AS "From ISO time",
       TO_DATE('October 5, 2022', 'Month DD, YYYY')    AS "From long date",
       TO_DATE('8th Oct 2022', 'DDth Mon YYYY')       AS "From short date";

SELECT TO_TIMESTAMP('2023-07-20 10:30:00', 'YYYY-MM-DD HH:MI:SS')                 AS "From ISO time",
       TO_TIMESTAMP('2023-07-20 10:30:00+5.50', 'YYYY-MM-DD HH:MI:SS+TZH.TZM')    AS "Non-standard timestamp with timezone";
--Formating Timestamps for output
SELECT CURRENT_TIMESTAMP,
       TO_CHAR('2023-02-11T11:55:55-4:00'::TIMESTAMPTZ, 'FMMonth DDth YYYY hh:mm:ss tz');

SELECT prod_id,
       quantity,
       TO_CHAR(orderdate, 'FMDay DD FMMonth YYYY') AS "Order Date"
FROM orders;
















