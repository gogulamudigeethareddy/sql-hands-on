--METADATA FUNCTIONS


--Information schema views

--Databases and Schemas
SElECT catalog_name AS "Database Name"
FROM information_schema.information_schema_catalog_name; 

SElECT STRING_AGG(schema_name, ',') AS "Non-PostgreSQL Schemas"
FROM information_schema.schemata
WHERE schema_name NOT LIKE 'pg%';

SElECT *
FROM information_schema.schemata
--Tables and views
SELECT STRING_AGG(table_name, ',') AS "Tables in the public schema"
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT table_name AS "Information_schema views"
FROM information_schema.views
WHERE table_schema = 'information_schema';
--Columns
SELECT column_name, data_type, dtd_identifier --unique identifier for each datatype
FROM information_schema.columns
WHERE table_name = 'orders';
--Array Metadata
DROP TABLE IF EXISTS demo;
CREATE TEMP TABLE demo(i INT[], t TEXT[]);
SELECT c.table_name, c.column_name, c.data_type, e.data_type AS element_type
FROM information_schema.columns c
LEFT JOIN information_schema.element_types e
       ON ((c.table_catalog, c.table_schema, c.table_name, 'TABLE', c.dtd_identifier)
                = (e.object_catalog, e.object_schema, e.object_name, e.object_type, e.collection_type_identifier))
WHERE c.table_schema like '%temp%'
ORDER BY c.ordinal_position;
--Function metadata       
SELECT r.routine_name     AS "Function name",
       p.parameter_name   AS "Parameter name",
       p.ordinal_position AS "Parameter position",
       p.data_type        AS "Data type"
FROM information_schema.parameters p
JOIN information_schema.routines r
  ON p.specific_name = r.specific_name
WHERE p.specific_schema = 'public'
ORDER BY p.specific_name, p.ordinal_position;

--System Information functions

--System metadata
SELECT CURRENT_CATALOG,
       CURRENT_DATABASE(),
       CURRENT_SCHEMA,
       CURRENT_USER,
       SESSION_USER;
SELECT VERSION();
--Privileges
SELECT has_database_privilege('geethareddy','CREATE'),
       has_schema_privilege('public','USAGE'),
       has_table_privilege('customers','SELECT'),
       has_any_column_privilege('customers','SELECT');
SELECT has_column_privilege('postgres','customers','firstname','UPDATE');
--Catalog information
SELECT unnest(string_to_array(
                           pg_get_functiondef(
                                        'login'::regproc::int
                                        ),
                            E'\n')
               ) AS "login function definition";

--System Administration functions

--configuration
SELECT current_setting('timezone');
SELECT set_config('timezone','EST',true);
--Database object functions
SELECT pg_size_pretty(pg_database_size('geethareddy'))  AS "geethareddy database size",
       pg_size_pretty(pg_table_size('customers'))       AS "size of customers table",
       pg_column_size(ARRAY[1,2,3])                     AS "size of a small array in bytes";
--File accesss functions
SELECT pg_stat_file('/etc/aliases');
SELECT pg_read_file('/etc/aliases');

SELECT pg_ls_dir('/tmp');











