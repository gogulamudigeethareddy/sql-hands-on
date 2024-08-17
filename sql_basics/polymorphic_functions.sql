--Polymorphic functions

--Ad hoc Adding two numbers
CREATE OR REPLACE FUNCTION adhoc(x INT,y INT) RETURNS INT
LANGUAGE SQL AS 'SELECT x+y;';

CREATE OR REPLACE FUNCTION adhoc(x FLOAT,y FLOAT) RETURNS FLOAT
LANGUAGE SQL AS 'SELECT x+y;';

CREATE OR REPLACE FUNCTION phi() RETURNS FLOAT
LANGUAGE SQL AS 'SELECT (1::FLOAT + SQRT(5::FLOAT))/2::FLOAT;';

SELECT adhoc(5,8), adhoc(PI(),phi());

SELECT adhoc('A'::CHAR, 'B'::CHAR);  --here, the character values doesnot exist

SELECT * FROM customers;
ALTER TABLE customers
ADD age SMALLINT;

UPDATE customers SET age = 56 WHERE customer_id = 1;
UPDATE customers SET age = 25 WHERE customer_id = 2;
UPDATE customers SET age = 37 WHERE customer_id = 3;
UPDATE customers SET age = 42 WHERE customer_id = 4;
UPDATE customers SET age = 28 WHERE customer_id = 5;


--Based on parameter types
CREATE OR REPLACE FUNCTION getcol(age customers.age%TYPE) RETURNS INT
LANGUAGE SQL AS '
        SELECT customer_id FROM customers c WHERE c.age = getcol.age;
';

CREATE OR REPLACE FUNCTION getcol(id orders.order_id%TYPE) RETURNS NUMERIC
LANGUAGE SQL AS '
        SELECT net_amount FROM orders WHERE order_id = id;
';
       
SELECT  getcol(age) AS customer_id FROM customers;
SELECT getcol(order_id) from orders;    
        
SELECT getcol(age::INT) AS "customer_id (?)" FROM customers;
SELECT getcol(order_id::INT2) from orders;       
        
DROP FUNCTION IF EXISTS adhoc(INT,INT);      
DROP FUNCTION IF EXISTS adhoc(FLOAT,FLOAT);      
DROP FUNCTION IF EXISTS adhoc(INT2);      
DROP FUNCTION IF EXISTS adhoc(INT);      
        
ALTER TABLE orders
ADD order_date DATE;     

ALTER TABLE orders
ADD tax NUMERIC; 
  
ALTER TABLE orders
ADD total_amount NUMERIC; 

UPDATE orders SET order_date='20230612',tax=7.84,total_amount=642.71 WHERE customer_id = 1;
UPDATE orders SET order_date='20230615',tax=45.04,total_amount=4920.85 WHERE customer_id = 2;
UPDATE orders SET order_date='20230620',tax=4.89,total_amount=539.36 WHERE customer_id = 3;
UPDATE orders SET order_date='20230605',tax=3.44,total_amount=885.82 WHERE customer_id = 4;
UPDATE orders SET order_date='20230628',tax=2.37,total_amount=241.36 WHERE customer_id = 5;

SELECT * FROM orders; 
        
--Subtype using inheritance
CREATE TABLE expedited_orders (
        expedited_date DATE 
)
INHERITS (orders);

ALTER TABLE public.expedited_orders ALTER COLUMN order_id DROP NOT NULL;     

INSERT INTO expedited_orders (order_date,customer_id,net_amount,tax,total_amount,expedited_date)
VALUES('20230208',1,0,0,0,'20230609');
        
--Polymorphic functions to check tax values for normal and expedited orders
CREATE OR REPLACE FUNCTION has_tax(o_row orders) RETURNS TABLE(tb1 VARCHAR,tax BOOLEAN)
LANGUAGE SQL AS '
        SELECT ''orders'', o_row.tax = 0;
';

CREATE OR REPLACE FUNCTION has_tax(e_row expedited_orders) RETURNS TABLE(tb1 VARCHAR,tax BOOLEAN)
LANGUAGE SQL AS '
        SELECT ''expedited'',e_row.tax = 0;
';
    
SELECT has_tax(o.*) FROM orders o WHERE order_id = 1;    
SELECT has_tax(e.*) FROM expedited_orders e;

DROP FUNCTION IF EXISTS has_tax(expedited_orders);
    
--Parametric polymorphic functions
--Generic subtraction
CREATE OR REPLACE FUNCTION f(x anyelement, y anyelement)
        RETURNS anyelement
LANGUAGE SQL AS 'SELECT x-y;';   
        
SELECT pg_typeof(f(20,20)), f(30,30);
SELECT pg_typeof(f(22.5,35.2)), f(30.5,46.0);
SELECT pg_typeof(f(pi(),phi())), f(pi(),phi());
     
SELECT f(TRUE, FALSE);     --ERROR: operator does not exist: boolean - boolean(can't subtract booleans)
        
--Concatenation
CREATE OR REPLACE FUNCTION g(x anyarray, y anyarray)
        RETURNS anyarray
LANGUAGE SQL AS 'SELECT X|| Y;';

SELECT g(ARRAY[1,2,3], ARRAY[4,5,6]);
SELECT g(ARRAY['a','b'],ARRAY['c','d']);

CREATE OR REPLACE FUNCTION h(x anyenum)
        RETURNS void
LANGUAGE SQL AS '';             --ERROR: function h(integer) does not exist(unsupported type)

SELECT h(10);

CREATE OR REPLACE FUNCTION f(x anyelement, y anyelement)
        RETURNS anyelement
LANGUAGE plpgsql AS ' BEGIN
        IF pg_typeof(x) IN (''integer'',''numeric'',''double precision'')
        AND pg_typeof(y) IN (''integer'',''numeric'',''double precision'')
         THEN 
          RETURN x-y;
        ELSE
          RETURN null;
        END IF;
END ';

SELECT f(10,20) AS "ints", f(10.5,10.5) AS "nums", f(25::REAL,25::REAL) AS "reals";

--Variadic Functions
CREATE OR REPLACE FUNCTION v(VARIADIC x int[]) RETURNS SETOF int
LANGUAGE SQL AS '
        SELECT * FROM unnest(x);
';

SELECT * FROM v(1,2);
SELECT * FROM v(VARIADIC x:= ARRAY[1,2,3]);        

--Pseudo type
CREATE OR REPLACE FUNCTION v(VARIADIC x anyarray) RETURNS SETOF anyelement
LANGUAGE SQL AS '
        SELECT * FROM unnest(x);
';

SELECT * FROM v(1,2);
SELECT * FROM v('a'::CHAR,'b'::CHAR);

--Log
CREATE OR REPLACE FUNCTION logger(VARIADIC l VARCHAR[]) RETURNS VOID
LANGUAGE plpgsql AS '
DECLARE 
    le VARCHAR;
BEGIN
    SELECT STRING_AGG(x,''|'') FROM unnest(l) AS l(x) INTO le;
    RAISE NOTICE ''log entry: %'',le;
END;
';

SELECT logger('this','is','a','log','entry');

--Default parameters and Ambiguity
CREATE OR REPLACE FUNCTION f(a int, b int) RETURNS INT
LANGUAGE SQL AS 'SELECT 20';

CREATE OR REPLACE FUNCTION f(a int, b int, c int = 10) RETURNS INT
LANGUAGE SQL AS 'SELECT c';

SELECT f(1,2);  --ERROR: function f(integer, integer) is not unique(both functions match the function call),
                        --so,unique names should be used






     
        
        