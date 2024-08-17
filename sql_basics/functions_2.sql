--Double Abstraction
CREATE GROUP cust_reps_group;
CREATE USER Alice        IN GROUP cust_reps_group PASSWORD 'Abcd1234';
CREATE USER John        IN GROUP cust_reps_group PASSWORD 'Abcd1234';
CREATE USER lucy        IN GROUP cust_reps_group PASSWORD 'Abcd1234';
CREATE USER Grace        IN GROUP cust_reps_group PASSWORD 'Abcd1234';
CREATE USER Harry       IN GROUP cust_reps_group PASSWORD 'Abcd1234';

--Granting permissions
CREATE ROLE cust_reps_role;
GRANT SELECT,INSERT,UPDATE,DELETE
        ON TABLE customers
        TO cust_reps_role;
--connecting user group to the role to grant permissions
GRANT cust_reps_role to cust_reps_group;

--Function security attributes
--Volatility(Immutable)
CREATE OR REPLACE FUNCTION phi()
        RETURNS DOUBLE PRECISION
LANGUAGE SQL
IMMUTABLE 
AS '    
   SELECT (1 + |/ 5)/2;
';
SELECT phi();
  
--Volatility(Stable)  

DROP FUNCTION IF EXISTS get_cust_name(integer);

CREATE OR REPLACE FUNCTION get_cust_name(id INTEGER)
        RETURNS VARCHAR
LANGUAGE SQL
STABLE
AS '    
   SELECT CONCAT_WS('' '', firstname, lastname)
   FROM customers
   WHERE customer_id = id;
';

SELECT get_cust_name(5);
UPDATE customers
SET firstname = 'Hazel', lastname = 'Brown'
WHERE customer_id = 5;
SELECT get_cust_name(5);

--Volatility(Volatile) 
CREATE OR REPLACE FUNCTION get_random_int()
        RETURNS INTEGER
LANGUAGE SQL
VOLATILE 
AS '
  SELECT (random()*10)::INTEGER;
';

SELECT get_random_int();

--Volatility(Leakproof)
CREATE OR REPLACE FUNCTION sometimes_error(flag BOOLEAN)
        RETURNS VOID
LANGUAGE plpgsql
NOT LEAKPROOF
AS '
   BEGIN 
       IF flag THEN
                RAISE NOTICE ''Parameter is true'';
       END IF;
   END;
';

SELECT sometimes_error(TRUE);
SELECT sometimes_error(FALSE);

--Security Definer|Invoker
CREATE OR REPLACE FUNCTION get_customer(id INT)
        RETURNS SETOF customers
LANGUAGE SQL
SECURITY DEFINER
AS '
   SELECT * FROM customers
   WHERE customer_id = id;
';

SELECT get_customer(2);

CREATE USER Nancy PASSWORD 'Abcd1234';
REVOKE SELECT ON customers FROM Nancy;
GRANT EXECUTE ON FUNCTION get_customer(INT) TO Nancy;

--Handling null input
CREATE OR REPLACE FUNCTION nulls_ok(n INT) RETURNS INT
LANGUAGE SQL
CALLED ON NULL INPUT
AS ' 
  SELECT CASE WHEN n IS NOT NULL THEN n ELSE -2 END;
';
SELECT nulls_ok(2);
SELECT nulls_ok(NULL);

CREATE OR REPLACE FUNCTION no_nulls(n INT) RETURNS INT
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS ' 
  SELECT CASE WHEN n IS NOT NULL THEN n ELSE -2 END;
';
SELECT no_nulls(2);
SELECT no_nulls(NULL);

--SET search_path
CREATE OR REPLACE FUNCTION restrict_path()
        RETURNS DOUBLE PRECISION
LANGUAGE SQL
SET search_path = public, pg_temp
AS 'SELECT phi()';              

SELECT restrict_path();

CREATE OR REPLACE FUNCTION restrict_path()
        RETURNS DOUBLE PRECISION
LANGUAGE SQL
SET search_path = pg_temp
AS 'SELECT phi()';              --ERROR: function phi() does not exist

SELECT restrict_path();

DROP FUNCTION IF EXISTS get_cust_name(id INTEGER);

--USING SCHEMAS
SELECT * FROM public.customers;  

--Letting Basic permissions
CREATE ROLE cust_owner;
CREATE SCHEMA cust AUTHORIZATION cust_owner;
GRANT USAGE ON SCHEMA cust to cust_owner;

ALTER DEFAULT PRIVILEGES
        IN SCHEMA cust
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cust_owner;

--copy customers table to new schema
CREATE TABLE cust.customers AS
        SELECT * FROM public.customers;

--create function to read name from customers table
CREATE OR REPLACE FUNCTION cust.get_cust_name(id INTEGER)
        RETURNS VARCHAR
        LANGUAGE SQL
        STABLE LEAKPROOF
        SET search_path = cust
        SECURITY DEFINER
AS '
   SELECT CONCAT_WS('' '',firstname,lastname)
   FROM cust.customers c
   WHERE c.customer_id = id;
';

ALTER FUNCTION cust.get_cust_name(id INTEGER)
        OWNER to cust_owner;   

--Create report analyst role and users and revoke privileges    
CREATE GROUP report_analysts;
CREATE USER Joe IN GROUP report_analysts PASSWORD 'Abcd1234';
GRANT USAGE ON SCHEMA cust TO report_analysts;

REVOKE SELECT,INSERT,UPDATE,DELETE
       ON ALL TABLES IN SCHEMA cust FROM report_analysts;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cust TO report_analysts;






