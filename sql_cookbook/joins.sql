--stacking one rowset atop another
--UNION and UNION ALL
SELECT ename, deptno
FROM emp
WHERE deptno = 10
UNION ALL
SELECT dname, deptno
FROM dept;

SELECT deptno
FROM emp
UNION
SELECT deptno
FROM dept;

--JOIN
--combining related rows
SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.deptno = 10;

SELECT e.ename, d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dept_deptno
FROM emp e, dept d
WHERE e.deptno = 10;

SELECT e.ename, d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dept_deptno
FROM emp e, dept d
WHERE e.deptno = 10 AND d.deptno = 10;

--finding rows in common between two tables
CREATE view v1
AS 
SELECT ename, job, sal
FROM emp
WHERE job = 'CLERK';

SELECT * FROM v1;

SELECT e.empno, e.ename, e.job, e.sal, e.deptno --to get all common rows
FROM emp e JOIN v1
ON (e.ename =  v1.ename
	AND e.job = v1.job
	AND e.sal = v1.sal);

SELECT empno, ename, job, sal, deptno	--using INTERSECT
FROM emp
WHERE (ename, job, sal) IN (
SELECT ename, job, sal FROM emp
INTERSECT
SELECT ename, job, sal FROM v1);

--retrieving values from one table that donot exist in another(using SET operation EXCEPT)
SELECT deptno FROM dept
EXCEPT 
SELECT deptno FROM emp;

--in case any NULL values
SELECT d.deptno
FROM dept d
WHERE NOT EXISTS(
	SELECT 1
	FROM emp e
	WHERE d.deptno = e.deptno
);

--retrieving values from one table that donot corresponds to rows in another(to return other columns)
SELECT d.*
FROM dept d 
LEFT OUTER JOIN emp e
ON (d.deptno = e.deptno)
WHERE e.deptno IS NULL;

--adding joins to a query without interfering with other joins
CREATE TABLE emp_bonus(
empno numeric,
received date,
type numeric
);

INSERT INTO emp_bonus
VALUES(7369, '14-MAR-2005', 1),
	(7900, '14-MAR-2005', 2),
	(7788, '14-MAR-2005', 3)

SELECT * FROM emp_bonus;

SELECT e.ename, d.loc, eb.received
FROM emp e, dept d, emp_bonus eb
WHERE e.deptno = d.deptno AND e.empno = eb.empno;

SELECT e.ename, d.loc, eb.received --to get all rows
FROM emp e 
JOIN dept d
ON (e.deptno = d.deptno)
LEFT JOIN emp_bonus eb
ON (e.empno = eb.empno)
ORDER BY 2;

SELECT e.ename, d.loc,	--using scalar subquery(query in SELECT list)
	(SELECT eb.received FROM emp_bonus eb
	WHERE eb.empno = e.empno) AS received
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY 2;

--to determine whether two tables have same data
CREATE view v2
AS 
SELECT * FROM emp WHERE deptno != 10
UNION ALL
SELECT * FROM emp WHERE ename = 'WARD';

SELECT * FROM v2;

(
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
	COUNT(*) AS cnt
FROM v2
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
EXCEPT
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
	COUNT(*) AS cnt
FROM emp
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
)
UNION ALL
(
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
	COUNT(*) AS cnt
FROM emp
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
EXCEPT
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
	COUNT(*) AS cnt
FROM v2
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
);

SELECT count(*)
FROM emp
UNION 
SELECT count(*)
FROM dept;

--identifying and avoiding cartesian products
SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = 10;

SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = 10 AND e.deptno = d.deptno;

--performing joins when using aggregations
TRUNCATE TABLE emp_bonus;

INSERT INTO emp_bonus
VALUES(7934, '17-MAR-2005', 1),
	(7934, '15-FEB-2005', 2),
	(7839, '15-FEB-2005', 3),
	(7782, '15-FEB-2005', 1);
	
SELECT * FROM emp_bonus;

SELECT column_name, data_type --checking the datatype of the emp_bonus column
FROM information_schema.columns
WHERE table_name = 'emp';

ALTER TABLE dept 	--changing the datatype from numeric to int for empno column in emp_bonus
ALTER COLUMN deptno TYPE NUMERIC USING deptno::NUMERIC;

SELECT e.empno, e.ename, e.sal, e.deptno, e.sal * CASE WHEN eb.type = 1 then 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END as bonus
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno AND e.deptno = 10;

SELECT deptno, SUM(sal) AS total_sal, SUM(bonus) AS total_bonus --incorect total salary due to duplicate rows
FROM (
SELECT e.empno, e.ename, e.sal, e.deptno, e.sal * CASE WHEN eb.type = 1 then 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END as bonus
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno AND e.deptno = 10) AS X
GROUP BY deptno;

SELECT SUM(sal) FROM emp WHERE deptno = 10;

SELECT e.ename, e.sal --duplicate row:MILLER
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno
AND e.deptno = 10;

SELECT deptno, SUM(DISTINCT sal) AS total_sal, SUM(bonus) AS total_bonus --using DISTINCT to get unique rows
FROM (
SELECT e.empno, e.ename, e.sal, e.deptno, e.sal * CASE WHEN eb.type = 1 THEN 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END as bonus
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno AND e.deptno = 10) AS X
GROUP BY deptno;

SELECT d.deptno, d.total_sal, SUM(e.sal * CASE WHEN eb.type = 1 THEN 0.1 --alternative to add unique rows using joins
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END) AS bonus
FROM emp e, emp_bonus eb,
(
SELECT deptno, SUM(sal) AS total_sal
FROM emp e
WHERE deptno = 10
GROUP BY deptno) d
WHERE e.deptno = d.deptno AND e.empno = eb.empno
GROUP BY d.deptno, d.total_sal;

--performing outer joins when using Aggregates
TRUNCATE TABLE emp_bonus;

INSERT INTO emp_bonus
VALUES(7934, '17-MAR-2005', 1),
	(7934, '15-FEB-2005', 2);
	
SELECT * FROM emp_bonus;

SELECT deptno, SUM(sal) AS total_sal, SUM(bonus) AS total_bonus --toal salary is not correct(it returns total salary of miller)
FROM (
SELECT e.empno, e.ename, e.sal, e.deptno, e.sal * CASE WHEN eb.type = 1 THEN 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END AS bonus
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno AND e.deptno = 10
)
GROUP BY deptno;

SELECT deptno, SUM(DISTINCT sal) AS total_sal, SUM(bonus) AS total_bonus --calculating total salary of all the employees in deptno 10
FROM (
SELECT e.empno, e.ename, e.sal, e.deptno, e.sal * CASE WHEN eb.type = 1 THEN 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3
	END AS bonus
FROM emp e
LEFT OUTER JOIN emp_bonus eb
ON (e.empno = eb.empno)
WHERE e.deptno = 10
)
GROUP BY deptno;

	-- SELECT DISTINCT deptno, total_sal, total_bonus --using window function SUM OVER
	-- FROM (
	-- SELECT e.empno, e.ename, total_sal, SUM(e.sal * CASE WHEN eb.type = 1 THEN 0.1
	-- 		WHEN eb.type = 2 THEN 0.2
	-- 		ELSE 0.3
	-- 	END) OVER (PARTITION BY e.deptno) AS total_bonus
	-- FROM emp e
	-- JOIN (
	--     SELECT e.deptno, SUM(DISTINCT sal) AS total_sal
	--     FROM emp e
	--     GROUP BY deptno
	-- ) d ON e.deptno = d.deptno
	-- LEFT OUTER JOIN emp_bonus eb
	-- ON (e.empno = eb.empno)
	-- WHERE e.deptno = 10) X;

SELECT d.deptno, d.total_sal, SUM(e.sal * CASE WHEN eb.type = 1 THEN 0.1
		WHEN eb.type = 2 THEN 0.2
		ELSE 0.3 END) AS total_bonus
FROM emp e, emp_bonus eb,(
SELECT deptno, SUM(sal) AS total_sal
FROM emp
WHERE deptno = 10
GROUP BY deptno) d
WHERE e.deptno = d.deptno AND e.empno = eb.empno
GROUP BY d.deptno, d.total_sal;

--returning missing data from tables
SELECT d.deptno, d.dname, e.ename --returning missing rows from table dept that do not exist in table emp
FROM dept d
LEFT OUTER JOIN emp e
ON d.deptno = e.deptno;

INSERT INTO emp(empno,ename,job,mgr,hiredate,sal,comm,deptno)
SELECT 1111, 'YODA', 'JEDI', null, hiredate, sal, comm, null
FROM emp
WHERE ename = 'KING';

SELECT * FROM emp;

SELECT d.deptno, d.dname, e.ename --returning missing rows from table emp that do not exist in table dept
FROM dept d
RIGHT OUTER JOIN emp e
ON d.deptno = e.deptno;

SELECT d.deptno, d.dname, e.ename --returning missing rows from tables that do not exist
FROM dept d
FULL OUTER JOIN emp e
ON d.deptno = e.deptno;

--using NULLs in operations and comparisions
SELECT ename, comm, COALESCE(comm, 0) --to compare the commission of 'WARD' with other employees
FROM emp
WHERE COALESCE(comm, 0) < (SELECT comm FROM emp WHERE ename = 'WARD');



