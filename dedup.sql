--ROW_NUMBER() with CTE
-- use ROW_NUMBER() to assign a unique number to each record within the same group
-- The first occurrence of eachgroup gets ROW_NUMBER() = 1 and duplicates get ROW_NUMBER() > 1


with cte AS (
    SELECT id,
    ROW_NUMBER() OVER(PARTITION BY name, age, grade ORDER BY id) AS rnk
    FROM students
)
DELETE FROM students
WHERE id IN (
    SELECT id FROM cte WHERE rnk > 1
);

-- Delete duplicates using SELF_JOIN
--Deletes records where id > MIN(id), keeping only the foirst occurrence
DELETE s1
FROM stu s1
JOIN stu s2
ON s1.name = s2.name
AND s1.age =s2.age
AND s1.grade = s2.grade
WHERE s1.id > s2.id;

--DELETE with EXISTS
--Checks for duplicates using correlated subquery
--if duplicates exists, the outer query deletes the extra record (id>min(id))
--more optimized than JOINS in some database because it stops searching once a match is found.
DELETE FROM Empl e1
WHERE EXISTS (
    SELECT 1
    FROM Empl e2
    WHERE e1.name = e2.name
    AND e1.salary = e2.salary
    AND e1.id > e2.id
); 

--create backup table and truncate
-- create backup table with only unique records min(id) then truncate the original table (fastest way to remove all data)
CREATE TABLE bck_empl AS
SELECT MIN(id) AS id, name, salary
FROM Empl
GROUP By name, salary;

TRUNCATE TABLE Empl;

INSERT INTO Empl
SELECT * FROM bck_empl;

DROP TABLE bck_empl;

--NOT IN with MIN(id) method
--Find the smallest id (MIN(id)) for each duplicate group(item,m order_date)
--Deletes all other duplicate records while keeping the first occurence
--simple and effective for smaller datasets
-- **Caution: NOT IN can be slower on large datasets. Consider using JOIN or EXISTS for better performance.
DELETE FROM orders 
WHERE id NOT IN (
    SELECT MIN(id)
    FROM orders
    GROUP BY item, order_date
);



-- Summary & Best Method
1. ROW_NUMBER() with CTE – Uses window functions for precise deletion.
2. Self-Join Approach – Simple & universal, works in all databases.
3. DELETE with EXISTS – Optimized for performance, stops searching after 
finding a match.
4. Backup Table & TRUNCATE – Ensures data safety before deletion.
5. NOT IN with MIN(id) – Straightforward but less efficient on large datasets


�
 Best Method 
ROW_NUMBER() with CTE
→ Works efficiently on any database size!
→  Optimized execution with window functions.#--