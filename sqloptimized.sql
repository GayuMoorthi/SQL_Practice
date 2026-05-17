--Excluse <col> is not standard in SQL, features found in BigQuery
--It allows you to easily sellect all co from table except one ot more specified columns.

SELECT col1, col2, col4 -- here excluding col3
FROM table_name;

     -- instead
SELECT * EXCLUDE col3
FROM table_name;

--EXISTS, it returns a TRUE if the subquery returns at least one row. MORE performant than using IN or JOIN
SELECT dep_name
FROM dep d
WHERE EXISTS (
    SELECT 1
    FROM emp e1
    WHERE e.dep_id = d.dep_id
);

--COALESCE, this function handles NULL values gracefully.
--Allows you to provide a fallback value when encountering NULL
--Rather than using complex CASE statement or multiple IFNULL/ISNULL functions, COALESCE provides a cleaner syntax
--You can use COALESCE to choose the first non-NULL value across multiple columns.
SELECT COALESCE(hm_pn, mb_ph, off_ph) AS contact_number
FROM contacts;

-- SYSCAT / SYSINFO Helps you obtain metadata on the underlying database platform that you are using. 
-- Querying syscat or sysinfo to find out what schemas, tables, columns, etc are available.
-- For example, you can query SYS.COLUMNS to get details about all the columns in a particular table.
-- SYS.KEYS and SYS.CONSTRAINTS can be used to get info about primary keys, foreign keys, and other constraints applied to tables
SELECT *FROM SYS.COLUMNS
WHERE table_name = ' empl';

