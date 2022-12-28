/* DA102.3 SQL Part II Subqueries & Temporary Tables */
-- 7. QUIZ: Your First Subquery
-- Question 1
SELECT *
  FROM (SELECT DATE_TRUNC('day', occurred_at) AS day,
       channel,
       COUNT(*) AS event_count
  FROM web_events
 GROUP BY 1,2) AS sub_query
 ORDER BY event_count DESC;
-- Question 3
SELECT AVG(*) AS avg_num_events,
       channel
  FROM (SELECT *
  FROM (SELECT DATE_TRUNC('day', occurred_at) AS day,
       channel,
       COUNT(*) AS event_count
  FROM web_events
 GROUP BY 1,2) AS sub_query
 ORDER BY event_count DESC) AS sub_query2
 GROUP BY channel;
-- WRONG syntax error says avg() does not exist
-- SOLUTION
SELECT channel,
       AVG(event_count) AS avg_num_events
  FROM (SELECT *
  FROM (SELECT DATE_TRUNC('day', occurred_at) AS day,
       channel,
       COUNT(*) AS event_count
  FROM web_events
 GROUP BY 1,2) AS sub_query
 ORDER BY event_count DESC) AS sub_query
 GROUP BY channel;

-- 11. More Subquery Practice
-- Step 1
 SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
  FROM orders;
-- Step 2
SELECT id,
       AVG(standard_qty) AS avg_standard_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
  FROM orders
 WHERE DATE_TRUNC('month',occurred_at) = (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
                                            FROM orders) 
 GROUP BY id;
-- Didn't need id
SELECT
       AVG(standard_qty) AS avg_standard_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
  FROM orders
 WHERE DATE_TRUNC('month',occurred_at) = (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
          FROM orders)
-- Didn't include total amount spent
SELECT
       AVG(standard_qty) AS avg_standard_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty,
       SUM(total_amt_usd) AS total_amt
  FROM orders
 WHERE DATE_TRUNC('month',occurred_at) = (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
          FROM orders) 
-- SOLUTION
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

-- 15. Subequery Example: Challenge
-- Example step 1 by Udacity
SELECT
	accounts.name,
	web_events.channel,
	COUNT(*)
  FROM accounts
  	   INNER JOIN web_events
  	      ON accounts.id = Web_events.account_id
 GROUP BY accounts.name, web_events.channel 
 ORDER BY accounts.name, COUNT(*)
-- Example step 2 by Udacity, creating a subquery to find the maximum
SELECT 
	T1.name,
	MAX(T1.count)
  FROM (SELECT
	accounts.name,
	web_events.channel,
	COUNT(*)
  FROM accounts
  	   INNER JOIN web_events
  	      ON accounts.id = Web_events.account_id
 GROUP BY accounts.name, web_events.channel 
 ORDER BY accounts.name, COUNT(*)) AS T1
 GROUP BY T1.name

-- 16. Subquery Examples: Solution to Challenge
-- Me following along
-- Query 1
SELECT
	a.id,
	a.name,
	w.channel
  FROM accounts AS a
       INNER JOIN web_events AS w 
       ON a.id = w.account_id;
-- Query 2
SELECT
	a.id,
	a.name,
	w.channel,
	COUNT(*) AS count
 FROM accounts AS a 
      INNER JOIN web_events AS w
         ON w.account_id = a.id 
GROUP BY a.id, a.name, w.channel;
-- Query 3
SELECT
	a.id,
	a.name,
	w.channel,
	COUNT(*) AS count
 FROM accounts AS a 
      INNER JOIN web_events AS w
         ON w.account_id = a.id 
GROUP BY a.id, a.name, w.channel
ORDER BY a.id;
-- Query 4
SELECT T1.id, T1.name, MAX(count)
  FROM (SELECT
			a.id,
			a.name,
			w.channel,
			COUNT(*) AS count
		 FROM accounts AS a 
		      INNER JOIN web_events AS w
		         ON w.account_id = a.id 
		GROUP BY a.id, a.name, w.channel) AS T1
GROUP BY T1.id, T1.name;
-- Query 5, joining Query 4 and Query 3 together
SELECT T3.id, T3.name, T3.channel, T3.cnt
FROM (SELECT T1.id, T1.name, MAX(cnt) AS max_cnt
	  FROM (SELECT
				a.id,
				a.name,
				w.channel,
				COUNT(*) AS cnt
			 FROM accounts AS a 
			      INNER JOIN web_events AS w
			         ON w.account_id = a.id 
			GROUP BY a.id, a.name, w.channel) AS T1
	GROUP BY T1.id, T1.name) AS T2 -- This is Query 4
       INNER JOIN (SELECT
						a.id,
						a.name,
						w.channel,
						COUNT(*) AS cnt
					 FROM accounts AS a 
					      INNER JOIN web_events AS w
					         ON w.account_id = a.id 
					GROUP BY a.id, a.name, w.channel
					ORDER BY a.id) AS T3 -- This is Query 3
             ON T2.id = T3.id AND T2.max_cnt = T3.cnt
  ORDER BY T3.id;

-- 17. Quiz: Subquery Mania
-- Question 1
SELECT
	s.name AS sales_rep_name,
    r.name AS region_name,
    MAX(total_amt_usd) -- Should of been SUM
FROM sales_reps AS s
     INNER JOIN region AS r
        ON r.id = s.region_id
     INNER JOIN accounts AS a
        ON a.sales_rep_id = s.id
     INNER JOIN orders AS o
        ON o.account_id = a.id
GROUP BY s.name, r.name;
-- Correct from Solution
SELECT
	s.name AS sales_rep_name,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
FROM sales_reps AS s
     INNER JOIN region AS r
        ON r.id = s.region_id
     INNER JOIN accounts AS a
        ON a.sales_rep_id = s.id
     INNER JOIN orders AS o
        ON o.account_id = a.id
GROUP BY s.name, r.name;
-- Finding the max for each region
SELECT 
	T1.region_name,
    MAX(T1.sum_total_amt_usd) AS max_total_amt_usd,
    COUNT(*) AS num_orders -- Solution didn't include this
FROM
	(SELECT
		s.name AS sales_rep_name,
    	r.name AS region_name,
    	SUM(o.total_amt_usd) AS sum_total_amt_usd
	FROM sales_reps AS s
     	INNER JOIN region AS r
        	ON r.id = s.region_id
     	INNER JOIN accounts AS a
        	ON a.sales_rep_id = s.id
     	INNER JOIN orders AS o
        	ON o.account_id = a.id
	GROUP BY s.name, r.name) AS T1
 GROUP BY T1.region_name
 ORDER BY max_total_amt_usd DESC;
-- Question 1 JOIN the two tables together
-- This is me making the 2nd table
(SELECT 
	T1.region_name,
    MAX(T1.sum_total_amt_usd) AS max_total_amt_usd,
    COUNT(*) AS num_orders -- Solution didn't include this
FROM
	(SELECT
		s.name AS sales_rep_name,
    	r.name AS region_name,
    	SUM(o.total_amt_usd) AS sum_total_amt_usd
	FROM sales_reps AS s
     	INNER JOIN region AS r
        	ON r.id = s.region_id
     	INNER JOIN accounts AS a
        	ON a.sales_rep_id = s.id
     	INNER JOIN orders AS o
        	ON o.account_id = a.id
	GROUP BY s.name, r.name) AS T1
 GROUP BY T1.region_name) AS T2 -- making another T2
-- Join T1 and T2
SELECT 
	T1.sales_rep_name,
	T1.region_name,
	T2.sum_total_amt_usd
  FROM (SELECT 
		T1.region_name,
	    MAX(T1.total_amt_sales_usd) AS max_total_amt_usd,
	    COUNT(*) AS num_orders
	FROM
		(SELECT
			s.name AS sales_rep_name,
	    	r.name AS region_name,
	    	SUM(o.total_amt_usd) AS sum_total_amt_usd
		FROM sales_reps AS s
	     	INNER JOIN region AS r
	        	ON r.id = s.region_id
	     	INNER JOIN accounts AS a
	        	ON a.sales_rep_id = s.id
	     	INNER JOIN orders AS o
	        	ON o.account_id = a.id
		GROUP BY s.name, r.name) AS T1
	 GROUP BY T1.region_name) AS T2
INNER JOIN (SELECT 
		T1.region_name,
	    MAX(T1.sum_total_amt_usd) AS max_total_amt_usd,
	    COUNT(*) AS num_orders -- Solution didn't include this
	FROM
		(SELECT
			s.name AS sales_rep_name,
	    	r.name AS region_name,
	    	SUM(o.total_amt_usd) AS sum_total_amt_usd
		FROM sales_reps AS s
	     	INNER JOIN region AS r
	        	ON r.id = s.region_id
	     	INNER JOIN accounts AS a
	        	ON a.sales_rep_id = s.id
	     	INNER JOIN orders AS o
	        	ON o.account_id = a.id
		GROUP BY s.name, r.name) AS T1
	 GROUP BY T1.region_name) AS T2
 ON T1.sum_total_amt_usd = T2.sum_total_amt_usd AND T1.region_name = T2.region_name
-- RESTART AUGGHHHH
-- First subquery
SELECT
	s.name AS sales_rep_name,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM orders AS o
       INNER JOIN accounts AS a
       ON a.id = o.account_id
       INNER JOIN sales_reps AS s
       ON a.sales_rep_id = s.id
       INNER JOIN region AS r
       ON s.region_id = r.id
 GROUP BY sales_rep_name, region_name;
-- Make it into t1
(SELECT
	s.name AS sales_rep_name,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM orders AS o
       INNER JOIN accounts AS a
       ON a.id = o.account_id
       INNER JOIN sales_reps AS s
       ON a.sales_rep_id = s.id
       INNER JOIN region AS r
       ON s.region_id = r.id
 GROUP BY sales_rep_name, region_name) AS t1
-- Second query
SELECT
	t1.region_name,
    MAX(t1.sum_total_amt_usd) AS max_total_amt_usd
FROM
  (SELECT
      s.name AS sales_rep_name,
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM orders AS o
         INNER JOIN accounts AS a
         ON a.id = o.account_id
         INNER JOIN sales_reps AS s
         ON a.sales_rep_id = s.id
         INNER JOIN region AS r
         ON s.region_id = r.id
   GROUP BY sales_rep_name, region_name) AS t1
   GROUP BY t1.region_name
-- Make it as t2
(SELECT
	t1.region_name,
    MAX(t1.sum_total_amt_usd) AS max_total_amt_usd
FROM
  (SELECT
      s.name AS sales_rep_name,
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM orders AS o
         INNER JOIN accounts AS a
         ON a.id = o.account_id
         INNER JOIN sales_reps AS s
         ON a.sales_rep_id = s.id
         INNER JOIN region AS r
         ON s.region_id = r.id
   GROUP BY sales_rep_name, region_name) AS t1
   GROUP BY t1.region_name) AS t2
-- Join t1 and t2
SELECT 
	t1.sales_rep_name,
    t2.region_name,
    t2.max_total_amt_usd
  FROM (SELECT
	s.name AS sales_rep_name,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM orders AS o
       INNER JOIN accounts AS a
       ON a.id = o.account_id
       INNER JOIN sales_reps AS s
       ON a.sales_rep_id = s.id
       INNER JOIN region AS r
       ON s.region_id = r.id
 GROUP BY sales_rep_name, region_name) AS t1
INNER JOIN
(SELECT
	t1.region_name,
    MAX(t1.sum_total_amt_usd) AS max_total_amt_usd
FROM
  (SELECT
      s.name AS sales_rep_name,
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM orders AS o
         INNER JOIN accounts AS a
         ON a.id = o.account_id
         INNER JOIN sales_reps AS s
         ON a.sales_rep_id = s.id
         INNER JOIN region AS r
         ON s.region_id = r.id
   GROUP BY sales_rep_name, region_name) AS t1
   GROUP BY t1.region_name) AS t2
ON t2.max_total_amt_usd = t1.sum_total_amt_usd AND t2.region_name = t1.region_name
-- Praise the Lord
-- Question 2
-- First query
SELECT
	r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM region AS r
  	   INNER JOIN sales_reps AS s
       ON r.id = s.region_id
       INNER JOIN accounts AS a
       ON s.id = a.sales_rep_id
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY region_name;
-- Make as t1
SELECT
	r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM region AS r
  	   INNER JOIN sales_reps AS s
       ON r.id = s.region_id
       INNER JOIN accounts AS a
       ON s.id = a.sales_rep_id
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY region_name;
-- Getting the max of each region from t1
SELECT 
	t1.region_name,
    MAX(t1.sum_total_amt_usd) AS max_sum_total_amt_usd 
  FROM  
  (SELECT
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM region AS r
         INNER JOIN sales_reps AS s
         ON r.id = s.region_id
         INNER JOIN accounts AS a
         ON s.id = a.sales_rep_id
         INNER JOIN orders AS o
         ON a.id = o.account_id
   GROUP BY region_name) AS t1
 GROUP BY t1.region_name -- Don't need group by if you just want the max value
-- Create t2
(SELECT 
    MAX(t1.sum_total_amt_usd) AS max_sum_total_amt_usd 
  FROM  
  (SELECT
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM region AS r
         INNER JOIN sales_reps AS s
         ON r.id = s.region_id
         INNER JOIN accounts AS a
         ON s.id = a.sales_rep_id
         INNER JOIN orders AS o
         ON a.id = o.account_id
   GROUP BY region_name) AS t1) AS t2
-- Nest t2 (scalar) into query 1
SELECT
	r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM region AS r
  	   INNER JOIN sales_reps AS s
       ON r.id = s.region_id
       INNER JOIN accounts AS a
       ON s.id = a.sales_rep_id
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY region_name
HAVING sum_total_amt_usd = (SELECT 
    MAX(t1.sum_total_amt_usd) AS max_sum_total_amt_usd 
  FROM  
  (SELECT
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM region AS r
         INNER JOIN sales_reps AS s
         ON r.id = s.region_id
         INNER JOIN accounts AS a
         ON s.id = a.sales_rep_id
         INNER JOIN orders AS o
         ON a.id = o.account_id
   GROUP BY region_name) AS t1) AS t2 -- syntax error at or near "AS"
SELECT
	r.name AS region_name,
    SUM(o.total_amt_usd) AS sum_total_amt_usd
  FROM region AS r
  	   INNER JOIN sales_reps AS s
       ON r.id = s.region_id
       INNER JOIN accounts AS a
       ON s.id = a.sales_rep_id
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY region_name
HAVING SUM(o.total_amt_usd) = (SELECT 
    MAX(t1.sum_total_amt_usd) AS max_sum_total_amt_usd 
  FROM  
  (SELECT
      r.name AS region_name,
      SUM(o.total_amt_usd) AS sum_total_amt_usd
    FROM region AS r
         INNER JOIN sales_reps AS s
         ON r.id = s.region_id
         INNER JOIN accounts AS a
         ON s.id = a.sales_rep_id
         INNER JOIN orders AS o
         ON a.id = o.account_id
   GROUP BY region_name) AS t1)
-- Question 3
-- Finding the account name with the most standard_qty paper
SELECT
	a.name AS account_name,
    SUM(o.standard_qty) AS sum_standard_qty,
    SUM(o.total) AS sum_total -- value is 44750
  FROM accounts AS a
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY a.name
 ORDER BY sum_standard_qty DESC
 LIMIT 1;
-- my attempt
SELECT 
	COUNT(a.name) AS count_of_accounts
  FROM accounts AS a
       INNER JOIN orders AS o
       ON a.id = o.account_id
 HAVING SUM(o.total) > 44750;
-- WRONG, the first part was correct
-- Making the first part as a subquery
(SELECT
	a.name AS account_name,
    SUM(o.standard_qty) AS sum_standard_qty,
    SUM(o.total) AS sum_total -- value is 44750
  FROM accounts AS a
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY a.name
 ORDER BY sum_standard_qty DESC
 LIMIT 1) AS t1
-- We got it!
SELECT 
	a.name AS account_name
  FROM accounts AS a
 	   INNER JOIN orders AS o
       ON a.id = o.account_id
  GROUP BY a.name     
 HAVING SUM(o.total) > 
 (SELECT sum_total
 FROM 
 (SELECT
	a.name AS account_name,
    SUM(o.standard_qty) AS sum_standard_qty,
    SUM(o.total) AS sum_total
  FROM accounts AS a
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY a.name
 ORDER BY sum_standard_qty DESC
 LIMIT 1) AS t1)
-- Now just the count
SELECT COUNT(*)
FROM (SELECT 
	a.name AS account_name
  FROM accounts AS a
 	   INNER JOIN orders AS o
       ON a.id = o.account_id
  GROUP BY a.name     
 HAVING SUM(o.total) > 
 (SELECT sum_total
 FROM 
 (SELECT
	a.name AS account_name,
    SUM(o.standard_qty) AS sum_standard_qty,
    SUM(o.total) AS sum_total
  FROM accounts AS a
       INNER JOIN orders AS o
       ON a.id = o.account_id
 GROUP BY a.name
 ORDER BY sum_standard_qty DESC
 LIMIT 1) AS t1)) AS t2
-- Question 4
-- Finding the customer that spent the most 
SELECT
	a.name AS account_name,
	SUM(o.total_amt_usd) AS max_sum_total_amt_usd
  FROM accounts AS a
  	   INNER JOIN orders AS o
  	   ON a.id = o.account_id
 GROUP BY account_name
 ORDER BY SUM(o.total_amt_usd) DESC
 LIMIT 1; -- EOG Resources
-- Create a query that finds the number of web events they did for each channel
SELECT
	a.name,
	w.channel,
	COUNT(*) AS count_web_events
  FROM web_events AS w
       INNER JOIN accounts AS a 
       ON w.account_id = a.id 
 WHERE a.name = ( SELECT t1.account_name
                    FROM (SELECT
	a.name AS account_name,
	SUM(o.total_amt_usd) AS max_sum_total_amt_usd
  FROM accounts AS a
  	   INNER JOIN orders AS o
  	   ON a.id = o.account_id
 GROUP BY account_name
 ORDER BY SUM(o.total_amt_usd) DESC
 LIMIT 1) AS t1)      
 GROUP BY a.name, w.channel
-- Question 5
/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts? */
-- Find the top 10 spending accounts
SELECT
	a.name AS account_name,
	SUM(total_amt_usd) AS sum_total_amt_usd
  FROM orders AS o 
       INNER JOIN accounts AS a
       ON a.id = o.account_id
 GROUP BY a.name 
 ORDER BY SUM(total_amt_usd) DESC
 LIMIT 10;
-- Get the average
SELECT 
	ROUND(AVG(t1.sum_total_amt_usd),0) AS sum_total_amt_usd
  FROM (SELECT
	a.name AS account_name,
	SUM(total_amt_usd) AS sum_total_amt_usd
  FROM orders AS o 
       INNER JOIN accounts AS a
       ON a.id = o.account_id
 GROUP BY a.name 
 ORDER BY SUM(total_amt_usd) DESC
 LIMIT 10) AS t1
/* Question 6. What is the lifetime average amount spent in terms of total_amt_usd, 
including only the companies that spent more per order, on average, than the average of all orders?*/
