--find second largest salary in each department
SELECT dep_id, MAX(salary) AS second_highest_salary
FROM emp
where salary < (
    SELECT MAX(salary)
    FROM emp e
    WHERE e.dep_id = emp.dep_id
)
GROUP BY dep_id;

--Retrieve all orders placed between 9 AM to 5 PM
SELECT order_id, order_time
FROM orders
WHERE CAST(order_time AS TIME) BETWEEN '09:00:00' AND '17:00:00';

--Identify dates where no sales were recorded for each product
SELECT p.product_id, d.date 
FROM products p 
CROSS JOIN dates d 
LEFT JOIN sales s ON p.product_id = s.product_id AND d.date = s.sale_date 
WHERE s.sale_date IS NULL;

--Identify dates where sales were recorded for each product
SELECT p.product_id, d.date 
FROM products p 
CROSS JOIN dates d 
LEFT JOIN sales s ON p.product_id = s.product_id AND d.date = s.sale_date 
WHERE s.sale_date IS NOT NULL;

--Find customer who made their first order in the last month
--MIN() finds the first purchase date.
SELECT customer_id, MIN(order_date)
FROM orders
GROUP BY customer_id
HAVING MIN(order_id) >= DATEADD(month, -1, GETDATE());

--Retrive customers who have purchased multiple products in the same order
SELECT order_id, customer_id
FROM orders
GROUP BY order_id, customer_id
HAVING COUNT(DISTINCT product_id) > 1;

--Retrive customers who purchased multiple products
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT product_id) > 1;

