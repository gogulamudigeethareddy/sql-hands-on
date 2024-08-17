SELECT 'Hello','World';
SELECT 'Hello' as FirstWord,'World' as SecondWord;

USE contacts;
SELECT DISTINCT p.FirstName,p.LastName
FROM person p;

SELECT p.LastName
FROM person p
WHERE p.FirstName = 'Tom';

SELECT p.LastName
FROM person p
WHERE p.FirstName = 'Tom'
AND p.contactNumber > 50;

SELECT p.FirstName,
p.LastName
FROM person p
WHERE p.FirstName = 'Emma' 
OR p.contactNumber > 50;

SELECT p.FirstName,
p.LastName
FROM person p
WHERE p.ContactNumber 
BETWEEN 20 AND 50;

SELECT p.FirstName,p.LastName
FROM person p
WHERE p.FirstName
LIKE '%o%';

SELECT p.FirstName,
p.LastName
FROM person p
WHERE p.FirstName
IN ('John','Tom');

SELECT p.FirstName,
p.LastName
FROM person p
WHERE p.LastName
IS NULL;

SELECT p.FirstName,
p.LastName
FROM person p
WHERE p.LastName
IS NOT NULL;

SELECT p.FirstName,p.LastName
FROM person p
ORDER BY FirstName;

SELECT COUNT(p.FirstName)
FROM person p;

SELECT COUNT(p.FirstName)
FROM person p
WHERE p.FirstName = 'Tom';

SELECT MAX(p.ContactNumber)
FROM person p;

SELECT MIN(p.ContactNumber)
FROM person p;

SELECT AVG(p.ContactNumber)
FROM person p;

SELECT SUM(p.ContactNumber)
FROM person p;

SELECT COUNT(DISTINCT p.FirstName)
FROM person p;

SELECT COUNT(p.FirstName),p.FirstName
FROM person p
GROUP BY p.FirstName;

SELECT COUNT(p.FirstName),p.FirstName
FROM person p
GROUP BY p.FirstName
HAVING COUNT(p.FirstName)>1;

SELECT COUNT(p.FirstName) as FirstNameCount,
p.FirstName
FROM person p
GROUP BY p.FirstName
HAVING FirstNameCount>1;
                           JOIN
SELECT p.FirstName,
p.LastName,
e.EmailAddress
FROM person p,
email e;

SELECT p.FirstName,p.LastName,
e.EmailAddress
FROM person p
INNER JOIN
email e
ON 
p.id = e.Email_id;

SELECT p.FirstName,p.LastName,
e.EmailAddress
FROM person p
LEFT OUTER JOIN
email e
ON 
p.id = e.Email_id;

SELECT p.FirstName,p.LastName,
e.EmailAddress
FROM person p
RIGHT OUTER JOIN
email e
ON 
p.id = e.Email_id;

SELECT p.FirstName,p.LastName,
e.EmailAddress
FROM person p
LEFT OUTER JOIN
email e
ON 
p.id = e.Email_id
UNION DISTINCT
SELECT p.FirstName,p.LastName,
e.EmailAddress
FROM person p
RIGHT OUTER JOIN
email e
ON 
p.id = e.Email_id;

          INSERT
          
INSERT INTO 
person(Id,FirstName,LastName,ContactNumber,DateLastContacted)
VALUES(7,'George','Hans',65,'2022-10-10 11:15:32');
        BULK INSERT
INSERT INTO 
person(Id,FirstName,LastName,ContactNumber,DateLastContacted)
VALUES(8,'George1','Hans',65,'2022-10-10 11:15:32');
INSERT INTO 
person(Id,FirstName,LastName,ContactNumber,DateLastContacted)
VALUES(9,'George2','Hans',65,'2022-10-10 11:15:32');
INSERT INTO 
person(Id,FirstName,LastName,ContactNumber,DateLastContacted)
VALUES(10,'George3','Hans',65,'2022-10-10 11:15:32');
           UPDATE
UPDATE email e
SET e.EmailAddress = 'tuv123@gmail.com'
WHERE e.id = 3;
             DELETE 
DELETE FROM person 
WHERE Id = 10

              CREATING DATABASE

CREATE DATABASE contacts_2;

USE contacts_2;

CREATE TABLE person
(person_id INTEGER NOT NULL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50)
);
CREATE TABLE Email_Address
(email_address_id INTEGER NOT NULL PRIMARY KEY,
email_address VARCHAR(50),
email_address_person_id VARCHAR(50)
);

ALTER TABLE Email_Address
ADD CONSTRAINT
FK_Email_Address_person
FOREIGN KEY
(email_address_person_id)
REFERENCES 
person
(person_id);













