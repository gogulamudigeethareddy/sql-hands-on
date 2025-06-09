SELECT * FROM person;

SELECT id, concat(firstname, ' ', lastname) fullname
from 
(select id, firstname, lastname 
        from person 
        where id < 5) pers;
 
create view v as
select * from person
where (id = 5 and lastname = 'clark') or (id = 2 or lastname = 'cruise');

select * from v;

SELECT id, firstname, lastname 
FROM person
ORDER BY lastname, firstname;

SELECT id, firstname, lastname
FROM person
WHERE id BETWEEN 1 AND 5;

SELECT id, firstname, lastname
FROM person
WHERE firstname BETWEEN 'j' AND 'tol';

SELECT id, firstname, lastname
FROM person
WHERE id IN (1, 2, 5);

select id, firstname 
from person 
where left(firstname, 1) = 't';

select id, firstname 
from person 
where firstname like 't%';

SELECT firstname, lastname
from person
where firstname in (select firstname from person where lastname like 'C_a%');
 
SELECT firstname, lastname
FROM person
WHERE lastname LIKE 'j%' OR lastname LIKE 'p%'; 
 
SELECT lastname, firstname
FROM person
WHERE lastname REGEXP '^[JP]';

SELECT id, email_id, emailaddress
FROM email
WHERE emailaddress IS NULL; 

SELECT id, email_id, emailaddress
FROM email
WHERE emailaddress IS NULL OR email_id BETWEEN 1 and 3; 



SOURCE /Users/geethareddy/Downloads/sakila-db/sakila-schema.sql;
SOURCE /Users/geethareddy/Downloads/sakila-db/sakila-data.sql;


SOURCE /Users/geethareddy/Downloads/sakila-db/sakila-schema.sql;
SOURCE /Users/geethareddy/Downloads/world-db/world.sql;

