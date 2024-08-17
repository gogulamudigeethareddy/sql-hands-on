SELECT * FROM customers

SELECT * FROM orders

DROP FUNCTION IF EXISTS get_cust_names(id1 INT, id2 INT)  

--RETURNING TABLE
CREATE OR REPLACE FUNCTION get_cust_names(id1 INT, id2 INT)
        RETURNS TABLE (firstname VARCHAR,lastname VARCHAR)
AS '
BEGIN
        RETURN QUERY
        SELECT c.firstname,c.lastname FROM customers c
        WHERE c.customer_id BETWEEN id1 AND id2;
END;
' LANGUAGE plpgsql;

SELECT * FROM get_cust_names(1,3);

--SYNTAX
[ <<label>> ]  --label is used to identify code blocks,also serves as name space identifier and DECLARE is used to declare variables
[DECLARE        
   declarations]
BEGIN          --This is code block
   statements
end[ label ]; 

DO ' BEGIN NULL; END; '  --This program does nothing

DO LANGUAGE plpgsql '
        <<get_ans>>
        DECLARE
               the_answer INT := 20;
        BEGIN
               RAISE NOTICE ''The answer is %'', get_ans.the_answer;
        END get_ans; 
'

DO LANGUAGE plpgsql '
--name [CONSTANT] type [COLLATE collation_name] [NOT NULL] [ {DEFAULT | := | = } expression ];
DECLARE
       myint          INTEGER NOT NULL = 0;
       the_answer     NUMERIC(2) := 15;
       phi CONSTANT   DOUBLE PRECISION DEFAULT (1+ |/5)/2;
       cust_row       customers%ROWTYPE;
       cust_firstname customers.firstname%TYPE;
       myrow          RECORD;
BEGIN
       myint := -1; --myint = -1
       SELECT * FROM customers       INTO cust_row LIMIT 1;
       SELECT cust_row.firstname     INTO cust_firstname LIMIT 1;
       SELECT 42::INT AS the_answer  INTO myrow;
       RAISE NOTICE ''Last Name: %; First Name: %; How Young? %'',
                cust_row.lastname, cust_firstname, myrow.the_answer;
END;
'    

CREATE OR REPLACE FUNCTION foo() RETURNS TABLE(the_answer int)
LANGUAGE plpgsql AS '
BEGIN 
    SELECT 16 as "The Answer";
END;
';

SELECT * FROM foo(); --ERROR: query has no destination for result data

CREATE OR REPLACE FUNCTION foo() RETURNS TABLE(the_answer int)
LANGUAGE plpgsql AS '          
BEGIN 
RETURN QUERY                    --can overcome by using RETURN QUERY statement 
    SELECT 16 as "The Answer";     
END;
';

SELECT * FROM foo();

CREATE OR REPLACE FUNCTION foo() RETURNS TABLE(the_answer int)
LANGUAGE plpgsql AS '          
BEGIN 
    PERFORM 16 as "The Answer";      -- PERFORM also works
END;
';

SELECT foo();

CREATE OR REPLACE FUNCTION bar(OUT a int)
LANGUAGE plpgsql AS '          
BEGIN 
    SELECT 16 as "The Answer" INTO bar. a;     --INTO is used
END;
';

SELECT bar();

CREATE TABLE categories
(
 id INT,
 category INT,
 categoryname VARCHAR
);

DO '
DECLARE 
       the_answer INT;
       cust_row customers%ROWTYPE;
       firstname VARCHAR;
       lastname VARCHAR;
       new_cat INT;
       old_catname VARCHAR;
BEGIN
       SELECT 5 INTO the_answer;
       SELECT * INTO cust_row FROM customers c
          WHERE c.customer_id =5;
       SELECT c.firstname,c.lastname INTO firstname,lastname
          FROM customers c
          WHERE c.customer_id = 5;
       INSERT INTO categories (categoryname)
          VALUES (''My Category'')
          RETURNING category INTO new_cat;
       DELETE FROM categories
          WHERE category = new_cat
          RETURNING categoryname INTO old_catname;
       RAISE NOTICE ''id: %, name: %'', new_cat, old_catname;
END;
';

DROP FUNCTION IF EXISTS foo();

CREATE OR REPLACE FUNCTION foo() RETURNS TABLE (firstname VARCHAR)
LANGUAGE plpgsql AS '
BEGIN
RETURN QUERY
        UPDATE customers c
                SET firstname = c.firstname
                WHERE c.customer_id = 10
        RETURNING c.firstname;
END;
';

SELECT foo();      --firstname is returned
DO ' BEGIN PERFORM foo();  END; ';     --no value is returned


CREATE OR REPLACE FUNCTION foo() RETURNS INT
LANGUAGE plpgsql AS '
BEGIN
        RETURN 15;   
END;
';

SELECT foo();


DROP FUNCTION IF EXISTS foo();

CREATE OR REPLACE FUNCTION foo(OUT i INT) --RETURNS INT
LANGUAGE plpgsql AS '
BEGIN
        i = 20
        RETURN;   --i;
END;
';

SELECT foo();

--Returning a result set:RETURN QUERY and RETURN NEXT
DROP FUNCTION IF EXISTS foo(OUT i INT);

CREATE OR REPLACE FUNCTION foo() RETURNS SETOF INT  --Returns a set of integers
LANGUAGE plpgsql AS '
BEGIN
        RETURN NEXT 10;   
        RETURN NEXT 15;
END;
';

SELECT foo();

--Returning a set of table type
CREATE OR REPLACE FUNCTION get_cat()
        RETURNS SETOF categories
        --RETURNS TABLE (category INT, categoryname VARCHAR)
LANGUAGE plpgsql AS '
DECLARE 
        cat categories%ROWTYPE;
BEGIN
        cat.category := 1; cat.categoryname := ''One'';
        RETURN NEXT cat;
        cat.category := 2; cat.categoryname := ''Two'';
        RETURN NEXT cat;
END;
';

SELECT * FROM get_cat();;

--Conditional execution
DO '
BEGIN
    IF true THEN
                RAISE NOTICE ''True!'';
    ELSE
                RAISE NOTICE ''False!'';
    END IF;
END;
'

DO '
BEGIN
    IF 1<0 THEN
                RAISE NOTICE ''One is less than zero'';
    ELSIF 1>0 THEN 
                RAISE NOTICE ''One is greater than zero!'';
    ELSE
                RAISE NOTICE ''False!'';
    END IF;
END;
'

--Simple CASE statement
DO '
BEGIN
  CASE 20
    WHEN 5,10 THEN
                RAISE NOTICE ''Odd'';
    WHEN 12,20 THEN
                RAISE NOTICE ''Even'';
  END CASE;
END;
'

--Search CASE statement
DO '
BEGIN
  CASE
    WHEN 2 in (5,10) THEN
                RAISE NOTICE ''Odd'';
    WHEN 12 in (12,20) THEN
                RAISE NOTICE ''Even'';
  END CASE;
END;
'

--Iteration 
DO '
DECLARE 
     i INT := 1;
BEGIN 
     <<loop_label>>   --optional
     LOOP
        RAISE NOTICE ''In a loop, iteration %'',i;
        i = i+1;
        IF i>3 THEN
                EXIT loop_label;
        END IF;
     END LOOP loop_label;
RAISE NOTICE ''Finally out!'';
END ';

DO '
DECLARE 
     i INT := 1;
BEGIN 
     LOOP
        RAISE NOTICE ''In a loop, iteration %'',i;
        i = i+1;
        EXIT WHEN i>3;
         CONTINUE WHEN i<=3;
     END LOOP;
RAISE NOTICE ''Finally out!'';
END ';

--While loop
DO '
DECLARE 
     i INT := 1;
BEGIN 
     WHILE i <= 3 LOOP
        RAISE NOTICE ''In a loop, iteration %'',i;
        i = i+1;
     END LOOP;
RAISE NOTICE ''Finally out!'';
END ';

--FOR LOOP
DO '
<<outside>>
DECLARE 
     i int= 15;
BEGIN 
    <<inside>>
     FOR i IN 1..3 LOOP
        RAISE NOTICE ''In a loop, iteration %, outer "i" %'', inside.i, outside.i;
     END LOOP;
RAISE NOTICE ''Finally out!'';
END ';

DO '
DECLARE 
     i customers.customer_id%TYPE;
BEGIN 
     FOR i IN 
        SELECT c.customer_id FROM customers c
        WHERE c.customer_id <= 3
        LOOP
           RAISE NOTICE ''In a loop, iteration %'', i;
     END LOOP;
RAISE NOTICE ''Finally out!'';
END ';

--Looping through Arrays
DO '
DECLARE i INT;
BEGIN
   FOREACH i IN ARRAY ARRAY[11,12,13] LOOP
        RAISE NOTICE ''In a loop, value %'',i;
   END LOOP;
RAISE NOTICE ''Finally out!'';
END ';

--Iteration using Cursors
DO '
DECLARE                                                 
     cur CURSOR FOR SELECT * from customers;    --Bound Cursor
     rc INT = 3;
BEGIN 
     FOR rec in cur LOOP
        IF rc > 0 THEN
           RAISE INFO ''(%, %)'', rec.customer_id, rec.firstname;
        END IF;
        rc = rc-1;
        IF rc = 0 THEN
                EXIT;
        END IF;
     END LOOP; 
END ';

DO '
DECLARE                                                 
     cur REFCURSOR;
     fn customers.firstname%TYPE;    --Unbound Cursor
BEGIN 
     OPEN cur FOR SELECT firstname FROM customers;
     FOR rc in 1..3 LOOP
        FETCH NEXT FROM cur INTO fn;
           RAISE INFO ''(%, %)'', rc, fn;
           rc = rc+1;
     END LOOP; 
     CLOSE cur;
END ';

--Cursor with parameter
CREATE OR REPLACE FUNCTION get_cur(prefix VARCHAR)                                              
     RETURNS refcursor
LANGUAGE plpgsql AS '
DECLARE cur CURSOR (p VARCHAR)  FOR
     SELECT * from customers WHERE firstname LIKE p || ''%'';
BEGIN 
     OPEN cur (prefix);
     RETURN cur;
END ';

BEGIN;
SELECT get_cur(''AZ'');
FETCH 2 FROM cur;
COMMIT;

--Dynamic Query
DO '
DECLARE i INT;
BEGIN 
   EXECUTE ''SELECT 10'' INTO STRICT i;   --Dynamic Query contains EXECUTE keyword, STRICT keyword is used to return one row
   RAISE NOTICE ''i = %'', i;                   
END ';

DO '
DECLARE 
     tablename NAME;
     tablenames NAME[] = ARRAY[''customers'', ''orders''];
     rc BIGINT;
BEGIN                                               
     tablename = tablenames[1+RANDOM()];
     SELECT COUNT(*) from tablename INTO rc;           --This doesnot execute
     --EXECUTE ''SELECT COUNT(*) FROM'' || quote_ident(tablename) INTO rc;
     RAISE NOTICE ''% has % rows'',tablename, rc;
END ';

DO '
DECLARE 
     tablename NAME;
     tablenames NAME[] = ARRAY[''customers'', ''orders''];
     rc BIGINT;
BEGIN                                               
     tablename = tablenames[1+RANDOM()];
     --SELECT COUNT(*) from tablename INTO rc;           
     EXECUTE ''SELECT COUNT(*) FROM'' || quote_ident(tablename) INTO rc;  --This executes,it uses identifier function
     RAISE NOTICE ''% has % rows'',tablename, rc;
END ';

DO '
DECLARE
     firstname VARCHAR;
     firstnames VARCHAR[] = ARRAY[''A'',''B''];
     tbl_name NAME = ''customers'';
     col_name NAME = ''firstname'';
     rc BIGINT;
BEGIN
     firstname = firstname[1+RANDOM()];
     EXECUTE
          ''SELECT COUNT(*) FROM ''
          || quote_ident(tb1_name)
          || ''WHERE''
          || quote_ident(col_name)
          || ''LIKE''
          || quote_literal(firstname || ''%'') INTO rc;
     RAISE NOTICE ''% firstnames start with "%"'', rc, firstname;
END ';

SELECT 
    lastname,
    'quoted:' || quote_literal(lastname),
    'nullable:' || quote_nullable(lastname)
FROM
    (SELECT 'O''Neil' AS lastname UNION SELECT NULL) s

--SQL injection and the USING clause
DROP TABLE IF EXISTS foo;
CREATE TABLE foo (a INT);
DO '
DECLARE 
       baddata VARCHAR = ''0;DROP TABLE IF EXISTS foo;'';
BEGIN
       EXECUTE 
            ''SELECT count(*) FROM orders where order_id = '';
            || baddata;
END ';
SELECT * from information_schema.tables where table_name = ''foo'';

DO '
DECLARE
     firstname VARCHAR;
     firstnames VARCHAR[] = ARRAY[''A'',''B''];
     tbl_name NAME = ''customers'';
     col_name NAME = ''firstname'';
     rc BIGINT;
BEGIN
     firstname = firstname[1+RANDOM()];
     EXECUTE
          ''SELECT COUNT(*) FROM ''
          || quote_ident(tb1_name)
          || ''WHERE''
          || quote_ident(col_name)
          || ''LIKE $1''
          INTO rc
          USING firstname || ''%'';
     RAISE NOTICE ''% firstnames start with "%"'', rc, firstname;
END ';

DO '
DECLARE
     firstname VARCHAR;
     firstnames VARCHAR[] = ARRAY[''A'',''B''];
     tbl_name NAME = ''customers'';
     col_name NAME = ''firstname'';
     rc BIGINT;
BEGIN
     firstname = firstname[1+RANDOM()];
     EXECUTE
          format(
                ''SELECT COUNT(*) FROM %I WHERE %I LIKE $1'',
                tbl_name,
                col_name)
          INTO rc
          USING firstname || ''%'';
     RAISE NOTICE ''% firstnames start with "%"'', rc, firstname;
END ';



  