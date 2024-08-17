--Character Type
SELECT CAST('Tom' AS CHARACTER(20)) AS "FirstName",
        'Hunt'::CHAR(20) AS "LastName";

SELECT CAST('Emma' AS CHARACTER VARYING(50)) AS "FirstName",
        'Rose'::VARCHAR(50) AS "LastName";

SELECT VARCHAR 'Hello, good morning.' AS "Hello",
        CHAR VARYING 'How are you.' AS "How",
        TEXT 'Have a nice day' AS "Nice";
        
--Binary Type
SELECT '\xAbcdEFG' AS "Hex Format",
        '\0123'::BYTEA AS "Escape Format";
        
--Numeric Type 

--Integer type
SELECT CAST(2^15-1 AS SMALLINT) AS "smallint or int2",   --2 bytes
       CAST(2^31-1 AS INTEGER) AS "integer,int or int4", --4 bytes
       CAST(-2^63 AS BIGINT) AS "bigint or int8";        --8 bytes
--Arbitary precision numbers      
SELECT CAST(3.1415936 AS NUMERIC(8,7)) AS pi;     --NUMERIC/DECIMAL

CREATE TABLE hi (bar NUMERIC(1000));
DROP TABLE hi;

SELECT CAST('NAN' AS NUMERIC) AS "NaN";
--Floating point types
SELECT 3.1415936 :: REAL                AS "Real Pi",
       3.1415936 :: DOUBLE PRECISION    AS "Double Precision Pi";
       
SELECT '3.1415936' :: FLOAT(53) = '3.1415936' :: REAL AS "are they equal?";   --FLOAT(n) ->in bits, ranges between 1 and 53
--Monetary type
SELECT CAST('$1,000.00' AS MONEY) AS "Dollar Amount";        
        
--Date and Time Types
  
SELECT '20230515'               :: TIMESTAMP(6)            AS "Timestamp, no time zone",
       'August 20, 2023 PST'    :: TIMESTAMP WITH TIME ZONE AS "Timestamp with time zone";  
--Interval
SELECT CURRENT_TIMESTAMP -  'July 15 2022' :: TIMESTAMP AS "Time since July 12 2022",
        '15 hours, 30 swminutes ago'         :: INTERVAL AS "15 and half hours ago";     
--Date
SELECT 'June 25, 2023' :: DATE AS "Previous date";         
--Time
SELECT '00:00:00'               :: TIME(6)      AS "Midnight Hour",
       '12:00:00 PST'    :: TIME WITH TIME ZONE AS "Noon in California";  
       
--Boolean Types       
        
SELECT 1 :: BOOLEAN AS "True",        --1 byte.,TRUE/FALSE/NULL
       0 :: BOOLEAN AS "False",           
      't':: BOOLEAN AS "True",
      'f':: BOOLEAN AS "False",
      'y':: BOOLEAN AS "True",
      'n':: BOOLEAN AS "False",
    NULL :: BOOL AS "unknown";
SELECT TRUE AS BOOL, FALSE AS BOOL

--Array Type

SELECT ARRAY[1,2,3] :: INTEGER[] AS "Array of Integers",
        CAST('{4,5,6}' AS FLOAT[]) AS "Real numbers array",
        '{7,8,9}' :: VARCHAR[] AS "Text items array";
SELECT (ARRAY['a','b','c'] :: CHAR[])[1] AS "First entry in character array";

--UUID Type(Universally Unique IDentifier)

SELECT '476bfaae-420d-11ee-be56-0242ac120002' :: UUID AS "lower case",   --32 hexadecimal digits
       '8D3198F0-420D-11EE-8F23-0800200C9A66' :: UUID AS "upper case",
       '56NRHF4J3I2H3H59D8SHW8SHR7C6C6SY'     :: UUID AS "ungrouped uuid",
       '5JGDIW92NE91-W9J2H38S-D92JD8A5C9S9'   :: UUID AS "non-standard grouping";

--XML Type(Unlimited length,xml data)
SELECT '<a>42</a>' :: XML AS "XML Content";
SELECT XML 
        '<?xml version = "1.0"?>
        <book>
          <title>Manual</title>
              <chapter>...</chapter>
        </book>'
        AS "XML Document";

--JSON Type
SELECT '{"name":"Tom"}'::JSON,      --unlimited length
       '{"name":"Henry"}'::JSONB,   --unlimited length,binary format
       JSON '{"name":"Blue"}'

--Range Types

--Numbers
SELECT INT4RANGE(10,20)     AS "Range of integers",
       NUMRANGE(2.15,5.10)  AS "Range of numerics"
--Dates and Times
SELECT TSRANGE('20230810 00:00:00', '20231006 11:00:00') AS "Timestamp range",
       DATERANGE('20230501', '20230702') AS "Date range"















        
        
        