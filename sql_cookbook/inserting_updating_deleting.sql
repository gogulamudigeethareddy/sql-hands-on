INSERT INTO dept(deptno, dname, loc)
VALUES(50, 'PROGRAMMING', 'BALTIMORE');

SELECT * FROM dept;

--Inserting default values
CREATE TABLE D (id integer default 0, foo varchar(10));

INSERT INTO D values (default);

SELECT * FROM d;

INSERT INTO D (foo) values ('Bar');

--Overriding a default value with NULL
INSERT INTO D (id, foo) values (null, 'Bright');

INSERT INTO D (id, foo) values (1, 'Bright');

SELECT * FROM d;

--Copying rows from one table into another
CREATE TABLE dept_east (
deptno numeric, 
dname varchar(20), 
loc varchar(20));

INSERT INTO dept_east(deptno, dname, loc)
SELECT deptno, dname, loc
FROM dept
WHERE loc IN ('NEW YORK', 'BOSTON');

SELECT * FROM dept_east;

--Copying table defnition
CREATE TABLE dept_2 AS
SELECT * FROM dept WHERE 1 = 0;

SELECT * FROM dept_2;

SELECT * INTO dept_2
FROM dept WHERE 1=0;

--Inserting into multiple tables at once supported only in Oracle

-- INSERT ALL WHEN loc IN ('NEW YORK', 'BOSTON') THEN
-- INTO dept_east (deptno, dname, loc) VALUES (deptno, dname, loc)
-- WHEN loc = 'CHICAGO' THEN
-- INTO dept_mid (deptno, dname, loc) VALUES (deptno, dname, loc)
-- ELSE
-- INTO dept_west (deptno, dname, loc) VALUES (deptno, dname, loc)
-- SELECT deptno, dname, loc
-- FROM dept;

--Blocking Inserts to certain columns












