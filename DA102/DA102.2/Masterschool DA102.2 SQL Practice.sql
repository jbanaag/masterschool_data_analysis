-- Masterschool DA102.2 SQL Practice
-- BASIC SQL Questions
-- Advanced

-- Question 4
SELECT *
  FROM orders
 WHERE occurred_at > '2016-01-01';

-- Question 5
SELECT account_id,
       occurred_at,
       total
  FROM orders
 WHERE occurred_at > '2016-01-01' AND occurred_at < '2016-06-01' AND total > 200
 ORDER BY occurred_at DESC;

-- Question 6
SELECT id, occurred_at, total_amt_usd
  FROM orders
 ORDER BY total_amt_usd DESC
 LIMIT 2;

-- Question 7
SELECT *
  FROM orders
 WHERE occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
 LIMIT 10;
-- OR
SELECT *
  FROM orders
 WHERE DATE_PART('year', occurred_at) = 2016
 LIMIT 10;
-- OR


 -- Question 8       
SELECT *
  FROM orders
 WHERE DATE_PART('year', occurred_at) = 2016
 ORDER BY total DESC
 LIMIT 10;

-- Question 9


-- Question 1 from SQL Aggregation functions
SELECT w.occurred_at
  FROM web_events w
 ORDER BY w.occurred_at
 LIMIT 1;
-- OR
SELECT MIN(occurred_at)
  FROM orders

-- Question 2
SELECT AVG(standard_qty)
  FROM orders
 
-- Question 3
SELECT a.id AS acc_id,
       SUM(o.total_amt_usd) AS total_amt_usd
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY a.id
HAVING a.id = '1001';
-- OR
SELECT 
	SUM(total_amt_usd) AS orders_1001_usd
FROM orders
WHERE 
	account_id = 1001

-- Question 4
SELECT SUM(total) AS total_1001_amount
  FROM orders
 WHERE account_id = '1001'; -- WRONG, that sums the total of all the orders this account sold to
-- SOLUTION
SELECT COUNT(*) AS total_1001_amount
  FROM orders
 WHERE account_id = '1001';

-- Question 5
SELECT a.id AS acc_id,
       COUNT(*) num_orders
  FROM accounts a
 GROUP BY acc_id;

-- Question 6
SELECT region_id,
       COUNT(*) representative_qty
  FROM sales_reps
 GROUP BY region_id;

-- Question 7
SELECT MIN(occurred_at) AS first_order_date,
       channel
  FROM web_events
 GROUP BY channel;

-- Question 8
SELECT o.account_id,
       AVG(o.total) avg_total
  FROM orders o
 GROUP BY o.account_id
 ORDER BY AVG(o.total) DESC
 LIMIT 2;

-- Question 9
SELECT w.account_id account,
       w.channel channel,
       COUNT(*) num_events
  FROM web_events w
 GROUP BY account, channel
 ORDER BY w.account_id ASC, w.channel DESC;

-- Question 1 from Questions at the bottom of the page
SELECT s.name sales_rep_name,
       r.name
  FROM sales_reps s
       INNER JOIN region r
       ON r.id = s.region_id;

-- Question 2
SELECT w.channel channel,
       a.name account_name
  FROM web_events w
       INNER JOIN accounts a
       ON a.id = w.account_id;

-- Question 3
SELECT a.name,
       SUM(o.total) total_quantity
  FROM accounts a
       INNER JOIN orders o
       ON a.id = o.account_id
 GROUP BY a.name;


