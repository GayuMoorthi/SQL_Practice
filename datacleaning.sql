--Replace NULL values with a default value or remove them based on the context
select coalesce(col_name, 'Default_value') as col_name from table_name;
select coalesce(ph.name, '000-000-0000') as ph.name from contact;

--Identify and delete duplicate rows based on key columns
with CTE AS(
    SELECT id, col1, col2,
    ROW_NUMBER() OVER(PARTITION BY col1, col2 ORDER BY id) AS rn
    FROM table_name
)
DELETE FROM table_name
WHERE id IN(
    SELECT id,
    FROM CTE
    WHERE rn > 1
)

--Convert text to lower/upper case to ensure consistency
SELECT LOWER( col_name) AS cleaned_col 
FROM table_name;

--Remove extra spaces from text fields
SELECT TRIM(col_name) AS Cleaned_col 
FROM table_name;

--Convert date strings into a consistent date format
SELECT STR_DATE(col_name, '%m%d%y') AS formatted_date 
FROM table_name;

--Identify and manage outliers in numerical data.
SELECT * 
FROM table_name
WHERE col_name BETWEEN lower_limit AND upper_limit;

--replace or remove special characters in text fields
SELECT REGEXP_REPLACE(col_name, '[^azA0-9]') AS cleaned_date
FROM table_name;

--Standardize values in categorical columns
UPDATE table_name
SET col_name = 'Male'
WHERE col_name IN ('M', 'male');

