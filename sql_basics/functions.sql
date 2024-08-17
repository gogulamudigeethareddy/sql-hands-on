CREATE TABLE customers
(
        customer_id INT PRIMARY KEY,
        firstname VARCHAR,
        lastname VARCHAR
);

SELECT * FROM customers;

INSERT INTO customers(customer_id,firstname,lastname)
VALUES(1,'John','Clark');
INSERT INTO customers(customer_id,firstname,lastname)
VALUES(2,'Emma','Brown');
INSERT INTO customers(customer_id,firstname,lastname)
VALUES(3,'Joe','Tress');
INSERT INTO customers(customer_id,firstname,lastname)
VALUES(4,'Robert','Hue');
INSERT INTO customers(customer_id,firstname,lastname)
VALUES(5,'Alice','Berg');

CREATE TABLE orders
(
        order_id NUMERIC(10) PRIMARY KEY,
        net_amount NUMERIC(8,2),
        customer_id INT
);

SELECT * FROM orders;

INSERT INTO orders(order_id,net_amount,customer_id)
VALUES(1234,634.87,1);
INSERT INTO orders(order_id,net_amount,customer_id)
VALUES(2345,4875.8,4);
INSERT INTO orders(order_id,net_amount,customer_id)
VALUES(5234,534.47,3);
INSERT INTO orders(order_id,net_amount,customer_id)
VALUES(3534,882.38,2);
INSERT INTO orders(order_id,net_amount,customer_id)
VALUES(1286,238.99,5);


SELECT c.firstname,
       c.lastname,
       o.order_id,
       o.net_amount
FROM customers c
JOIN orders o
     ON c.customer_id = o.customer_id

--CREATING VIEW
CREATE OR REPLACE VIEW cust_orders AS 
  SELECT c.firstname,
         c.lastname,
         o.order_id,
         o.net_amount
  FROM customers c
  JOIN orders o
    ON c.customer_id = o.customer_id;

SELECT * FROM cust_orders;

--CREATING FUNCTION
--(Drop function if exists cust_orders()
CREATE FUNCTION cust_orders()
   RETURNS TABLE (firstname VARCHAR, lastname VARCHAR, order_id NUMERIC(10), net_amount NUMERIC(8,2))
AS '
   SELECT c.firstname,
          c.lastname,
          o.order_id,
          o.net_amount
   FROM customers c
   JOIN orders o ON c.customer_id = o.customer_id;
' LANGUAGE SQL;
   
SELECT * FROM cust_orders();   

CREATE OR REPLACE FUNCTION cust_orders(customer_id INT)
   RETURNS TABLE (firstname VARCHAR, lastname VARCHAR, order_id NUMERIC(10), net_amount NUMERIC(8,2))
AS '
   SELECT c.firstname,
          c.lastname,
          o.order_id,
          o.net_amount
   FROM customers c
   JOIN orders o ON c.customer_id = o.customer_id
   WHERE c.customer_id = cust_orders.customer_id;
' LANGUAGE SQL;
   
SELECT * FROM cust_orders(2);   


DROP VIEW IF EXISTS cust_orders;
DROP FUNCTION IF EXISTS cust_orders();
DROP FUNCTION IF EXISTS cust_orders(INT);

--INPUT ARGUMENTS AND RETURN VALUES
CREATE OR REPLACE FUNCTION pow(x DOUBLE PRECISION, y DOUBLE PRECISION)
        RETURNS DOUBLE PRECISION
AS '
        SELECT POWER(x,y);
' LANGUAGE SQL;

SELECT pow(PI(),LOG(4));

--DEFAULT VALUES FOR INPUT PARAMETERS
CREATE OR REPLACE FUNCTION defa(x INT = 30)
        RETURNS INT
AS '
        SELECT x;
' LANGUAGE SQL;

SELECT defa(-30) AS "Specify the argument",
       defa() AS "Take the default"; 

--USING ARRAYS FOR MULTIPLE INPUT VALUES
CREATE OR REPLACE FUNCTION array_sum(int_array INT[])
        RETURNS BIGINT
AS '
        SELECT SUM(e1)
        FROM UNNEST(int_array) AS arr(e1);
' LANGUAGE SQL;

SELECT array_sum(ARRAY[10,15,25]);

--MULTIPLE RETURN VALUES
CREATE OR REPLACE FUNCTION array_sum_avg(int_array INT[])
        RETURNS TABLE(array_sum BIGINT, array_avg NUMERIC)
AS '
        SELECT SUM(e1), AVG(e1)::NUMERIC(5,2)
        FROM UNNEST(int_array) AS arr(e1);
' LANGUAGE SQL;

SELECT array_sum_AVG(ARRAY[10,15,25]) AS "Record Type";
SELECT * FROM array_sum_AVG(ARRAY[10,15,25]);   --(two ways to call the function)

--OUTPUT ARGUMENTS
CREATE OR REPLACE FUNCTION get_cust_name(
        IN id INT,
        OUT firstname VARCHAR,
        OUT lastname VARCHAR)
AS '
        SELECT c.firstname,c.lastname FROM customers c
        WHERE c.customer_id = id;
' LANGUAGE SQL;

SELECT * FROM get_cust_name(3);

--RETURNING TABLE
CREATE OR REPLACE FUNCTION get_cust_names(id1 INT, id2 INT)
        RETURNS TABLE (firstname VARCHAR,lastname VARCHAR)
AS '
        SELECT c.firstname,c.lastname FROM customers c
        WHERE c.customer_id BETWEEN id1 AND id2;
' LANGUAGE SQL;

SELECT * FROM get_cust_names(1,3);

--BY USING OUTPUT ARGUMENTS

DROP FUNCTION IF EXISTS get_cust_names(id1 INT, id2 INT)   --(Drop function if exists get_cust_names(id1 INT, id2 INT)

CREATE OR REPLACE FUNCTION get_cust_names(
        INOUT id1 INT, id2 INT,
        OUT firstname VARCHAR,
        OUT lastname VARCHAR)
AS '
        SELECT c.customer_id, c.firstname, c.lastname FROM customers c
        WHERE c.customer_id BETWEEN id1 AND id2
' LANGUAGE SQL;        

SELECT id1 AS customer_id,
       firstname,
       lastname
FROM get_cust_names(1,5);

-- DROPPING FUNCTIONS
DROP FUNCTION IF EXISTS get_cust_name(id INT,OUT firstname VARCHAR,OUT lastname VARCHAR);
DROP FUNCTION IF EXISTS get_cust_names(id INT,OUT firstname VARCHAR,OUT lastname VARCHAR);
DROP FUNCTION IF EXISTS get_cust_names(INOUT id1 INT,id2 INT,OUT firstname VARCHAR,OUT lastname VARCHAR);
DROP FUNCTION IF EXISTS get_cust_names(id1 INT, id2 INT);

--CALLING FUNCTIONS
CREATE OR REPLACE FUNCTION call_me(x INT, y INT, sw BOOLEAN = TRUE)
        RETURNS INT
AS '
        SELECT x+y WHERE SW
        UNION ALL 
        SELECT x-y WHERE NOT sw;
' LANGUAGE SQL; 

SELECT 
        call_me(12,-15) AS "Positional Arguments",
        call_me(x := 10, y := -8) AS "Named Arguments",
        call_me(16,-13,FALSE) AS "Positional arguments with switch",
        call_me(45,-37,sw := FALSE) AS "Mixed positional and named"

SELECT call_me(x := 74, y := 56, FALSE) "Named followed by positional";  --positional argument cannot follow named argument
     
--CALLING FUNCTIONS
CREATE OR REPLACE FUNCTION call_me(x INT, y INT, sw BOOLEAN=TRUE)
        RETURNS INT
AS '
        SELECT x+y WHERE SW
        UNION ALL 
        SELECT x-y WHERE NOT sw;
' LANGUAGE SQL;       

SELECT 
        call_me(12,-15) AS "Positional Arguments",
        call_me(x := 10, y := -8) AS "Named Arguments",
        call_me(16,-13,FALSE) AS "Positional arguments with switch",
        call_me(45,-37,sw := FALSE) AS "Mixed positional and named"





