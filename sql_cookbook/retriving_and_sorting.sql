SELECT * FROM emp;

--concatenating two columns
SELECT ename|| 'WORKS AS A ' || job as msg
FROM emp
WHERE deptno=10;

--returning random records 
SELECT ename, job
FROM emp
ORDER BY random() limit 5;

--transforming null values into real values
SELECT coalesce(comm, 0)
FROM emp;

--transforming null values into real values using CASE
SELECT case
WHEN comm IS NOT NULL THEN comm ELSE 0 END
FROM emp;

--using LIKE operator
SELECT ename, job
FROM emp
WHERE deptno in (10, 20)
AND (ename LIKE '%I%' OR job LIKE '%E_');

--sorting mutliple fields
SELECT empno, deptno, sal, ename, job
FROM emp
ORDER BY deptno, sal DESC;

--sorting substrings
SELECT ename, job
FROM emp
ORDER BY substr(job, LENGTH(job)-1); --(sorted by the last two characters in the job column)

--sorting alphanumeric data(TRANSLATE AND REPLACE functions remove either numbers or characters from each row to sort)
CREATE VIEW v
AS
SELECT ename ||' '||deptno AS data
FROM emp;

SELECT * FROM v;

SELECT data		--ORDER BY deptno
FROM v
ORDER BY REPLACE(data,
		REPLACE(
		TRANSLATE(data, '0123456789', '##########'), '#', ''), '');

SELECT data --ORDER BY ename
FROM v
ORDER BY REPLACE(
		TRANSLATE(data, '0123456789', '##########'), '#', '');

SELECT data,
	REPLACE(data,
	replace(
	TRANSLATE(data, '0123456789', '##########'), '#', ''),'') nums,
	REPLACE(
	TRANSLATE(data, '0123456789', '##########'), '#', '') chars
FROM v;

--sorting if there are nulls
SELECT ename, sal, comm
FROM emp
ORDER BY 3;

SELECT ename, sal, comm
FROM emp
ORDER BY 3 DESC;

--using CASE to sort 
SELECT ename, sal, comm
FROM (
SELECT ename, sal, comm,
	CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS IS_NULL
FROM emp
) x
ORDER BY IS_NULL DESC, comm;

SELECT ename, sal, comm
FROM (
SELECT ename, sal, comm,
	CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS IS_NULL
FROM emp
) x
ORDER BY IS_NULL, comm;

SELECT ename, sal, comm,
	CASE WHEN comm IS NULL THEN 0 ELSE 1 END AS IS_NULL
FROM emp;

SELECT ename, sal, job, comm
FROM emp
ORDER BY CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END;










