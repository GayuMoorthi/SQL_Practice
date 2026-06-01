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

-- Identify orders where the amount is more than twice the average order value
SELECT order_id, customer_id, order_amount
FROM orders
WHERE order_amount > 2 * (SELECT AVG(order_amount) FROM orders);

--Compute the avergae number of days between orders for each customers
--DATEDIFF() calculates the difference in days.
/*SELECT
    customer_id,
    AVG(
        DATE_DIFF(
            order_date,
            LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date),
            DAY
        )
    ) AS avg_days_between_orders
FROM `your_project.your_dataset.orders`
GROUP BY customer_id; */

--Highest revenue month per Year [RANK() if you want ties]
/*Result:
year	month	revenue
2023	B	150
2023	C	150
2024	A	200 */
SELECT year, month, revenue
FROM ( 
    SELECT year, month, revenue,
    RANK() OVER(PARTITION BY year ORDER BY revenue DESC)AS rnk
    FROM monthly_revenue
) t 
WHERE rnk = 1;

--Highest revenue exactly one month per Year [ROW_NUMBER() if you want one record per year]
/*Result:
year	month	revenue
2023	B	150
2024	A	200 */
SELECT year, month, revenue
FROM (
    SELECT year, month, revenue,
    ROW_NUMBER() OVER(PARTITION BY year ORDER BY revenue DESC ) AS rnk 
    FROM monthly_revenue
) t
WHERE rnk = 1;

-- Find the most popular product on sales in each category
SELECT product_name, MAX(sales) AS max_sales, cat_id 
FROM products
GROUP BY prodcut_name, cat_id
ORDER BY max_sales DESC;

-- Calculate the average order value(AOV) by month
SELECT AVG(order_id) AS avg_order, month
FROM orders
GROUP BY month;

-- Identify products with sales growth from Q1 to Q2
--Two subqueries calculate Q1 and Q2 sales for each product.
--The main query calculates the percentage growth.
/*SELECT p.product_id,  
       q1.sales AS q1_sales, q2.sales AS q2_sales, 
       (q2.sales - q1.sales) / NULLIF(q1.sales, 0) * 100 AS growth_rate 
FROM (SELECT product_id, SUM(sales) AS sales FROM sales WHERE quarter = 'Q1' GROUP BY product_id) q1 
JOIN (SELECT product_id, SUM(sales) AS sales FROM sales WHERE quarter = 'Q2' GROUP BY product_id) q2 
ON q1.product_id = q2.product_id; */

--Write a query to identify employee assigned to more than one depqartment
SELECT employee_id
FROM emp_dep
GROUP BY employee_id
HAVING COUNT(DISTINCT dep_id) > 1;

/*In SQL, Find Products with Zero Sales in the Last Quarter
quarter → use quarters (3‑month periods) as the unit.
-1 → go one quarter back.
GETDATE() → from today’s date.
"sales_date >= DATEADD(quarter, -1, GETDATE())""
So this expression gives you the date and time exactly one quarter before now. Then the WHERE clause:
*/
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM sales 
    WHERE sales_date >= DATEADD (quarter, -1, GETDATE())
);

/*In BIGQUERY, Find Products with Zero Sales in the Last Quarter
CURRENT_TIMESTAMP() → take the current date and time (now).
INTERVAL 3 MONTH → a time period of 3 calendar months.
TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 MONTH) → subtract 3 months from “now”, giving the timestamp exactly 3 months ago.
*/
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM sales
    WHERE sales_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 MONTH)
);
/*If sales_date is a DATE (not TIMESTAMP), you’d usually write:*/
WHERE sales_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)

/* Rank sales representatives based on quarterly sales. */
SELECT sales_rep_id, quarter, total_sales,
RANK() OVER(PARTITION BY quarter ORDER BY total_sales DESC) AS rnk
FROM quarterly_sales;

/*Write a query to find the month with the highest revenue for each year. */
SELECT year, month, revenue
FROM (
    SELECT year, month, revenue,
    RANK() OVER(PARTITION BY year ORDER BY revenue DESC) AS rnk
    FROM monthly_revenue
) AS yearly_revenue
WHERE rnk = l;

/*Identify customers who have never ordered product "P123". */
SELECT customer_id
FROM customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE product_id = 'P123'
);

/*Find customers who have placed at least one order in every month for the last 6 months.
--The CTE (monthly_orders) retrieves distinct order months for each customer.
--The HAVING COUNT(DISTINCT order_month) = 6 ensures orders exist in all 6 months. */
WITH monthly_orders AS (
    SELECT customer_id,
    EXTRACT(MONTH FROM order_date) AS order_month,
    EXTRACT(YEAR FROM order_date) AS order_year
    FROM orders
    WHERE order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    GROUP BY customer_id, order_month, order_year
)
SELECT customer_id
FROM monthly_orders
GROUP BY customer_id
HAVING COUNT(DISTINCT order_month) = 6;

/* Find employees with the longest continuous employment. 
--The DATEDIFF() calculates years of employment.
--ORDER BY tenure_years DESC LIMIT 1 retrieves the longest-serving employee. */
SELECT employee_id, hire_date, DATEDIFF(year, hire_date, GETDATE()) AS tenure_years
FROM employee
ORDER BY tenure_years DESC LIMIT 1;

/* Identify the top 3 customers who have spent the most.
--The SUM(order_amount) calculates total spending per customer.
--The LIMIT 3 retrieves the top spenders. */
SELECT customer_id, SUM(order_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 3;

/* Calculate the percentage revenue growth between two years.
--CTE revenue aggregates total revenue by year.

--Self‑join matches each year with the previous year (r1.order_year = r2.order_year + 1).

--Growth percentage is (this year − last year)/last year ∗ 100

--NULLIF(r2.total_revenue, 0) avoids division by zero when last year’s revenue is zero or missing. */

WITH revenue AS (
  SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(order_amount) AS total_revenue
  FROM orders
  GROUP BY order_year
)
SELECT
  r1.order_year,
  r1.total_revenue,
  (r1.total_revenue - r2.total_revenue)
    / NULLIF(r2.total_revenue, 0) * 100 AS growth_percentage
FROM revenue r1
LEFT JOIN revenue r2
ON r1.order_year = r2.order_year + 1
ORDER BY r1.order_year;

--Find products that have never been purchased.
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM orders
);

--Find products that have never been out of stock.
SELECT prodcut_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT prodcut_id FROM inventory WHERE stock_quantity = 0
);

--Rank employees by salary within their department.
SELECT employee_id, department_id, salary
RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) as salary_rank
FROM employees;

--Find customers who placed their first-ever order this year.
SELECT
  customer_id,
  MIN(order_date) AS first_order_date
FROM orders
GROUP BY customer_id
HAVING MIN(order_date) >= DATE_TRUNC(CURRENT_DATE(), YEAR);

--Find customers who haven’t placed an order in the last 6 months.
SELECT customer_id
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
  );

/* Identify the most common time of day when orders are placed.
--EXTRACT(HOUR FROM order_time) returns an integer hour from 0 to 23.
--Grouping by order_hour aggregates all orders in the same hour.
--Ordering by order_count DESC and LIMIT 1 gives the most common order hour. */
SELECT
  EXTRACT(HOUR FROM order_time) AS order_hour,
  COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_count DESC
LIMIT 1;

/*Identify the longest continuous order streak per customer.
--Use DATE_SUB(order_date, INTERVAL rn DAY) instead of DATEADD(day, -rn, order_date).
--Often deduplicate (customer_id, order_date) first so multiple orders on the same day don’t inflate the streak.
--Everything else (CTE, ROW_NUMBER, grouping) is valid Standard SQL and works in BigQuery. */
WITH ordered_dates AS (
  SELECT
    customer_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
  FROM (
    SELECT DISTINCT customer_id, order_date  -- avoid multiple orders per day
    FROM orders
  )
),
streaks AS (
  SELECT customer_id,
    DATE_SUB(order_date, INTERVAL rn DAY) AS grp_id,
    order_date
  FROM ordered_dates
)
SELECT customer_id,
  COUNT(*) AS consecutive_days
FROM streaks
GROUP BY customer_id, grp_id
ORDER BY consecutive_days DESC
LIMIT 1;