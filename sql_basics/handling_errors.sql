--False Assumptions
--Pattern matching

ALTER TABLE foo
DROP COLUMN a

ALTER TABLE foo
ADD COLUMN t VARCHAR;

CREATE TABLE IF NOT EXISTS foo(t TEXT);
INSERT INTO foo(t) VALUES('the'),('answer'),('is'),('10');

CREATE OR REPLACE FUNCTION search_foo(what TEXT)
        RETURNS SETOF foo
        LANGUAGE SQL
AS '
  SELECT * FROM foo WHERE t LIKE what || ''%'';
';
SELECT * FROM search_foo('ans');

INSERT INTO foo(t) VALUES ('_hello');   
SELECT * FROM search_foo('_');

--WHERE AND CASE assumptions
SELECT * FROM customers
WHERE customer_id = 3 AND 1/0 IS NULL;  --ERROR: division by zero

SELECT age,
  CASE age
    WHEN 5 THEN 1
    WHEN 1/0 THEN 2     --ERROR: division by zero
  END 
FROM customers 
WHERE customer_id = 3

--Natural order
SELECT * FROM foo;

UPDATE foo
   SET t = 'ten is two times five'     --Data is rearranged(no natural order)
WHERE t = '10';

SELECT * FROM foo;

--Environment settings
--Data Style

ALTER TABLE foo
ADD COLUMN d DATE;

CREATE TABLE IF NOT EXISTS foo(d date);
SET DateStyle = ISO, DMY;
INSERT INTO foo(d) VALUES ('06/07/2023');
SET DateStyle = ISO, MDY;
INSERT INTO foo(d) VALUES ('10/08/2023');

SELECT to_char(d, 'mon dd, yyyy') FROM foo;

SELECT * FROM foo;

CREATE OR REPLACE FUNCTION insert_foo(ddmmyyyy VARCHAR)
        RETURNS VOID
        LANGUAGE SQL
        SET DateStyle = ISO, DMY
AS '
   INSERT INTO foo(d) VALUES(ddmmyyyy::DATE);
';

TRUNCATE TABLE foo;
SET DateStyle = ISO, DMY;
SELECT insert_foo('06/07/2023');
SET DateStyle = ISO, MDY;
SELECT insert_foo('10/08/2023');

SELECT to_char(d, 'mon dd, yyyy') FROM foo;

--Changing Database Objects

ALTER TABLE foo
ADD COLUMN a INTEGER;

ALTER TABLE foo
ADD COLUMN b VARCHAR;

CREATE TABLE IF NOT EXISTS foo(a int, b char);
INSERT INTO foo(a,b) VALUES(1,'a'),(2,'b');
    
CREATE OR REPLACE FUNCTION get_foo()
        RETURNS SETOF foo
        LANGUAGE SQL
AS 'SELECT * FROM foo;';

SELECT * FROM get_foo();

ALTER TABLE foo
ADD c VARCHAR;
INSERT INTO foo(a,b,c) VALUES(3,'c','3 is c');
SELECT * FROM get_foo();

--user code calls the function
SELECT a,b,c FROM get_foo();

ALTER TABLE foo DROP c;

DROP FUNCTION IF EXISTS get_foo();
CREATE OR REPLACE FUNCTION get_foo()
        RETURNS TABLE (a foo.a%TYPE, b foo.b%TYPE)
        LANGUAGE SQL
AS 'SELECT a, b FROM foo;';

SELECT * FROM get_foo();

--Error Handling

CREATE TABLE IF NOT EXITS foo(a INT PRIMARY KEY, question VARCHAR NOT NULL);
INSERT INTO foo(a, question) VALUES(15, 'The answer is 15');

CREATE OR REPLACE FUNCTION oops(a, INT, question VARCHAR)
        RETURNS VOID
        LANGUAGE plpgsql
AS '
   BEGIN 
       INSERT INTO foo(a, question) VALUES (oops.a, oops.question);
END ';

SELECT oops(25,'Hai');


CREATE OR REPLACE FUNCTION oops(a, INT, question VARCHAR)
        RETURNS VOID
        LANGUAGE plpgsql
AS '
   BEGIN 
       INSERT INTO foo(a, question) VALUES (oops.a, oops.question);
   EXCEPTION WHEN unique_violation THEN 
        RAISE NOTICE ''key "%" already exists in table.'', oops.a;
END ';
SELECT oops(25,'Hi');

CREATE OR REPLACE FUNCTION oops(a, INT, question VARCHAR)
        RETURNS VOID
        LANGUAGE plpgsql
AS '
DECLARE
     msg text;
     stt text;
     tb1 text;
     sch text;
     cst text;
BEGIN
    INSERT INTO foo(a, question) VALUES (oops.a, oops.question);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
               msg := MESSAGE_TEXT,
               stt := RETURNED_SQLSTATE,
               tb1 := TABLE_NAME,
               sch := SCHEMA_NAME,
               cst := CONTRAINT_NAME;
        RAISE NOTICE ''SQLSTATE=%, Table=%.%, Constraint=%'', stt,sch,tb1,cst;
        RAISE;
END ';
SELECT oops(25,'Hi');

--Using exceptions to handle deadlock recovery
CREATE TABLE IF NOT EXISTS foo(a INT, b VARCHAR);
INSERT INTO foo(a,b) VALUES(10, 'The answer.');

BEGIN TRANSACTION;
UPDATE foo                          --lock
     SET b = 'The answer'      
WHERE a = 15;
COMMIT;

CREATE OR REPLACE FUNCTION oops(a, INT, question VARCHAR)
        RETURNS VOID
        LANGUAGE plpgsql
        SET lock_timeout = 1000
AS '
DECLARE
    retires INT := 10;
    sleep DOUBLE PRECISION := .5;
BEGIN
    FOR i IN 1..retires LOOP
        BEGIN
           UPDATE foo
                SET b = update_foo.b
                WHERE foo.a = update_foo.a;
                RETURN;
        EXCEPTION
               WHEN lock_not_available THEN
                        IF i = retires THEN
                               RAISES NOTICE ''Update failed due to locking'';
                               RAISE;
                               RETURN;
                        ELSE
                           RAISE INFO ''Couldn''t get lock, attempt % of %.'', i, retires;
                           PERFORM pg_sleep(sleep);
                        END IF;
               WHEN OTHERS THEN
                        RAISE;
                        RETURN;
            END;
      END LOOP;
END;
';      
                        
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT update_foo(10,'The answer');
COMMIT;                    







