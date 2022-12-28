/* DA102.2 SQL Aggregations */
-- 7. Quiz SUM
-- Question 1
SELECT SUM(poster_qty) AS total_poster_sales
  FROM orders;
-- Question 2
SELECT SUM(standard_qty) AS total_standard_sales
  FROM orders;
-- Question 3
SELECT SUM(total_amt_usd) AS total_dollar_sales
  FROM orders;
-- Question 4
--WRONG
SELECT SUM(standard_amt_usd) AS standard_amt_usd, 
       SUM(gloss_amt_usd) AS gloss_amt_usd
  FROM orders;
-- SOLUTION
SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
  FROM orders;
-- Question 5
-- WRONG
SELECT SUM(o.standard_amt_usd/(o.standard_qty+0.01)) AS standard_amt_usd_per_qty
  FROM orders o;
-- SOLUTION
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
  FROM orders;

-- 11. Quiz: MIN,MAX, & AVERAGE
-- Question 1
SELECT MIN(occurred_at)
  FROM orders;
-- Question 2
SELECT occurred_at
  FROM orders
  ORDER BY occurred_at
  LIMIT 1;
-- Question 3
SELECT MAX(occurred_at)
  FROM web_events;
-- Question 4
SELECT occurred_at
  FROM web_events
  ORDER BY occurred_at DESC
  LIMIT 1;
-- Question 5
-- WRONG
SELECT AVG(standard_amt_usd)/AVG(standard_qty) AS standard_amt_per_order,
AVG(gloss_amt_usd)/AVG(gloss_qty) AS gloss_amt_per_order,
AVG(poster_amt_usd)/AVG(poster_qty) AS poster_amt_per_order,
AVG(standard_qty)/AVG(total) AS standard_qty_per_order,
AVG(gloss_qty)/AVG(total) AS gloss_qty_per_order,
AVG(poster_qty)/AVG(total) AS poster_qty_per_order
  FROM orders;
-- SOLUTION
SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss, 
        AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd, 
        AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders;
-- Question 6
SELECT total_amt_usd
  FROM orders
  ORDER BY total_amt_usd DESC
  LIMIT 3456;
-- CORRECT
SELECT *
FROM (SELECT total_amt_usd
   FROM orders
   ORDER BY total_amt_usd
   LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
-- Since there are 6912 orders - we want the average of the 3457 and 3456 order amounts when ordered. This is the average of 2483.16 and 2482.55. This gives the median of 2482.855. This obviously isn't an ideal way to compute. If we obtain new orders, we would have to change the limit. SQL didn't even calculate the median for us. The above used a SUBQUERY, but you could use any method to find the two necessary values, and then you just need the average of them.

-- 14. QUIZ: GROUP BY
-- Question 1
SELECT a.name,
       o.occurred_at
  FROM accounts a
INNER JOIN orders o
    ON a.id = o.account_id
ORDER BY o.occurred_at
LIMIT 1;
-- Question 2
SELECT a.name AS company_name,
       SUM(o.total_amt_usd) AS total_usd
  FROM accounts a
       INNER JOIN orders o
       ON o.account_id = a.id
 GROUP BY a.name;
-- Question 3
SELECT w.occurred_at AS date,
       w.channel,
       a.name AS account_name
  FROM web_events w
       JOIN accounts a
       ON w.account_id = a.id
 ORDER BY w.occurred_at DESC
 LIMIT 1;
-- Question 4
SELECT w.channel,
       COUNT(*)
  FROM web_events w
 GROUP BY w.channel;
-- Question 5
 SELECT a.primary_poc,
       w.occurred_at
  FROM web_events w
       JOIN accounts a
       ON a.id = w.account_id
 ORDER BY w.occurred_at
 LIMIT 1;
-- Question 6
-- WRONG
SELECT a.name,
       MIN(o.total)
  FROM accounts a
       JOIN orders o
       ON o.account_id = a.id
 GROUP BY a.name
 ORDER BY o.total;
-- SOLUTION
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;
-- Question 7
SELECT s.region_id AS region,
       COUNT(*) AS number_sales_reps
  FROM sales_reps s
 GROUP BY region
 ORDER BY number_sales_reps;

--17. QUIZ: GROUP BY Part II
-- Question 1
SELECT a.name,
       AVG(o.standard_qty) AS standard,
       AVG(o.gloss_qty) AS gloss,
       AVG(o.poster_qty) AS poster
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY a.name;
-- Question 2
SELECT a.name,
       AVG(o.standard_amt_usd) AS standard_amt_spent,
       AVG(o.gloss_amt_usd) AS gloss_amt_spent,
       AVG(o.poster_amt_usd) AS poster_amt_spent
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY a.name;
-- Question 3
-- WRONG
SELECT s.name AS sales_rep,
       w.channel AS channel,
       COUNT(w.channel) AS occurrences
  FROM sales_reps s
       INNER JOIN web_events w
       ON s.id = w.account_id
 GROUP BY sales_rep, channel
 ORDER BY occurrences DESC; -- INCORRECT PK and FK join
-- SOLUTION
SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;
-- Question 4
-- INCORRECT
SELECT r.name AS region,
       w.channel AS channel,
       COUNT(*) AS occurences
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
       INNER JOIN region r
       ON r.id = a.id
 GROUP BY region, channel
 ORDER BY occurences DESC;
-- SOLUTION: had to do another INNER JOINs
SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;

-- QUIZ 20. DISTINCT
-- Question 1
SELECT DISTINCT a.id,
       r.name AS region
  FROM accounts a
       INNER JOIN sales_reps s
       ON a.sales_rep_id = s.id
       INNER JOIN region r
       ON s.region_id = r.id;

SELECT DISTINCT id, name
  FROM accounts;
-- Now we know that every account is associated with only one region (both queries have the same amount of rows)
-- Question 2
SELECT s.name AS sales_rep,
       a.id
  FROM sales_reps s
       INNER JOIN accounts a
       ON s.id = a.sales_rep_id;

SELECT DISTINCT s.name AS sales_rep,
       a.id
  FROM sales_reps s
       INNER JOIN accounts a
       ON s.id = a.sales_rep_id;
-- OR SOLUTION
SELECT DISTINCT id, name
FROM sales_reps; 
-- All the sales reps worked on more than one account 

--23. Quiz: HAVING
-- Question 1 
-- WRONG
SELECT s.name AS sales_rep,
       a.id AS account,
       COUNT(*) num_accounts
  FROM sales_reps s
       INNER JOIN accounts a
       ON s.id = a.sales_rep_id
 GROUP BY num_accounts
HAVING num_accounts > 5;
-- TRY AGAIN WRONG
SELECT s.name AS sales_rep,
       a.id AS account,
       COUNT(*)
  FROM sales_reps s
       INNER JOIN accounts a
       ON s.id = a.sales_rep_id
 GROUP BY sales_rep, account
HAVING COUNT(*) > 5;
-- CORRECT
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;
-- ANOTHER ATTEMPT
SELECT s.name AS sales_rep,
       COUNT(*) num_accounts
  FROM sales_reps s
       INNER JOIN accounts a
       ON s.id = a.sales_rep_id
 GROUP BY sales_rep
HAVING COUNT(*) > 5
 ORDER BY num_accounts;
-- Question 2
SELECT a.id account,
       COUNT(*) num_orders
  FROM accounts a
       INNER JOIN orders o
       ON a.id = account_id
 GROUP BY account
HAVING COUNT(*) > 20
 ORDER BY num_orders; -- Answer 120 rows
-- Question 3
SELECT a.name account_name,
       COUNT(*) num_orders
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY account_name
 ORDER BY COUNT(*) DESC
 LIMIT 1;
-- Question 4
SELECT a.id account,
       a.name account_name,
       MAX(o.total_amt_usd) amt_spent
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY account, account_name
HAVING MAX(o.total_amt_usd) > 30000
 ORDER BY amt_spent; -- 21 results
-- WRONG Should be SUM not MAX
-- Question 5
SELECT a.id account,
       a.name account_name,
       SUM(o.total_amt_usd) amt_spent
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY account, account_name
HAVING SUM(o.total_amt_usd) < 1000
 ORDER BY amt_spent;
-- Question 6
SELECT a.id account,
       a.name account_name,
       SUM(o.total_amt_usd) amt_spent
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY account, account_name
 ORDER BY amt_spent DESC
 LIMIT 1;
-- Question 7
SELECT a.id account,
       a.name account_name,
       SUM(o.total_amt_usd) amt_spent
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY account, account_name
 ORDER BY amt_spent ASC
 LIMIT 1;
-- Question 8
-- WRONG syntax error on HAVING
SELECT a.id account,
       w.channel channel,
       COUNT(*) num_customers
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
 GROUP BY account, channel
HAVING w.channel = 'facebook'
   AND HAVING COUNT(*) > 6
-- Fixed
SELECT a.id account,
       w.channel channel,
       COUNT(*) num_customers
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
 GROUP BY account, channel
HAVING w.channel = 'facebook'
   AND COUNT(*) > 6 -- 46 results
-- Question 9 
SELECT a.id account,
       w.channel channel,
       COUNT(*) num_customers
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
 GROUP BY account, channel
HAVING w.channel = 'facebook'
 ORDER BY COUNT(*) DESC
 LIMIT 1;
-- Question 10 
SELECT a.id acc_id,
       a.name account,
       w.channel channel,
       COUNT(*) times_used
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
 GROUP BY acc_id, account, channel
 ORDER BY COUNT(*) DESC; 

-- 27. QUIZ: DATE Functions
-- Question 1
SELECT DATE_TRUNC('year',w.occurred_at) AS year,
       SUM(o.total_amt_usd) AS total_usd
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY 1
 ORDER BY 2 DESC; 
-- Didn't need to use DATE_TRUNC, just DATE_PART, and I guess you don't need to do JOINs?
-- Quesstion 2
SELECT DATE_TRUNC('month',w.occurred_at) AS month,
       SUM(o.total_amt_usd) AS total_usd
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 1;
-- WRONG
-- SOLUTION because 2013 and 2017 only have 1 month of data for those years, so it isn't fair
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 
-- Question 3
SELECT DATE_TRUNC('years',w.occurred_at) AS year,
       SUM(o.total) AS total_qty
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 1;
-- Question 4
SELECT DATE_TRUNC('month',w.occurred_at) AS year,
       SUM(o.total) AS total_qty
  FROM web_events w
       INNER JOIN accounts a
       ON w.account_id = a.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 1;
-- Question 5
-- WRONG
SELECT DATE_PART('month', w.occurred_at) AS month,
       DATE_PART('year', w.occurred_at) AS year,
       w.channel channel,
       COUNT(o.gloss_amt_usd) gloss_amt_usd
  FROM orders o
       INNER JOIN accounts a
       ON o.account_id = a.id
       INNER JOIN web_events w
       ON a.id = w.account_id
 GROUP BY 1, 2, 3
 ORDER BY COUNT(o.gloss_amt_usd) DESC
 LIMIT 1; 
-- try again
SELECT DATE_PART('month', w.occurred_at) AS month,
       DATE_PART('year', w.occurred_at) AS year,
       a.name acc_name,
       COUNT(o.gloss_amt_usd) gloss_amt_usd
  FROM orders o
       INNER JOIN accounts a
       ON o.account_id = a.id
       INNER JOIN web_events w
       ON a.id = w.account_id
 GROUP BY 1, 2, 3
HAVING a.name = 'Walmart'
 ORDER BY COUNT(o.gloss_amt_usd) DESC
 LIMIT 1; -- Should be SUM
-- try again 2
SELECT DATE_PART('month', w.occurred_at) AS month,
       DATE_PART('year', w.occurred_at) AS year,
       a.name acc_name,
       SUM(o.gloss_amt_usd) gloss_amt_usd
  FROM orders o
       INNER JOIN accounts a
       ON o.account_id = a.id
       INNER JOIN web_events w
       ON a.id = w.account_id
 GROUP BY 1, 2, 3
HAVING a.name = 'Walmart'
 ORDER BY SUM(o.gloss_amt_usd) DESC
 LIMIT 1; -- COULD OF JUST USED DATE_TRUNC('month')

-- 31. QUIZ: Case
-- Question 1
SELECT account_id,
       total,
       CASE WHEN total_amt_usd >= 3000 THEN 'Large' 
       ELSE 'Small' END AS level_of_order
  FROM orders;
-- OR
SELECT account_id,
       total,
  CASE WHEN total_amt_usd >= 3000 THEN  'Large'
       WHEN total_amt_usd < 3000 THEN 'Small' 
       END AS level_of_order
  FROM orders;
-- Question 2
SELECT CASE WHEN total < 1000 THEN 'Less than 1000'
            WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
            WHEN total > 2000 THEN 'At Least 2000'
            END AS levels,
            COUNT (*) num_of_items
  FROM orders
 GROUP BY levels;
-- don't forget to include some of the values like 2000 and 1000 
-- Question 3
SELECT account_id,
       SUM(total_amt_usd) AS total_sales,
  CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
       WHEN SUM(total_amt_usd) BETWEEN 100000 AND 200000 THEN 'second'
       WHEN SUM(total_amt_usd) < 100000 THEN 'lowest'
       END AS level
  FROM orders
 GROUP BY account_id
 ORDER BY SUM(total_amt_usd) DESC; 
-- Question 4
SELECT account_id,
       SUM(total_amt_usd) AS total_sales,
  CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
       WHEN SUM(total_amt_usd) BETWEEN 100000 AND 200000 THEN 'second'
       WHEN SUM(total_amt_usd) < 100000 THEN 'lowest'
       END AS level
  FROM orders
 GROUP BY account_id, occurred_at
HAVING occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
 ORDER BY SUM(total_amt_usd) DESC; 
-- Question 5
SELECT s.name,
       COUNT(o.total) num_orders,
  CASE WHEN COUNT(o.total) > 200 THEN 'top'
       ELSE 'not'
       END AS top_or_not
  FROM sales_reps s
       INNER JOIN accounts a
       ON a.sales_rep_id = s.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY s.name
 ORDER BY COUNT(*) DESC;
-- Question 6
SELECT s.name,
       SUM(o.total)AS total_orders,
       SUM(o.total_amt_usd) AS total_sales,
  CASE WHEN COUNT(o.total) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
       WHEN COUNT(o.total) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
       ELSE 'low'
       END AS level
  FROM sales_reps s
       INNER JOIN accounts a
       ON a.sales_rep_id = s.id
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY s.name
 ORDER BY SUM(o.total_amt_usd) DESC;