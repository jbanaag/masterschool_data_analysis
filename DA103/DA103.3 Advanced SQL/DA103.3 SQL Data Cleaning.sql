/* DA103.3 SQL Data Cleaning*/
/* 7.Quiz LEFT & RIGHT*/

/* Question 1 In the accounts table, there is a column holding the website for each company. 
The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. 
Pull these extensions and provide how many of each website type exist in the accounts table.*/
SELECT
    RIGHT(website,4) AS website_extension,
    COUNT(*)
  FROM accounts
 GROUP BY website_extension;

/* Question 2 There is much debate about how much the name (or even the first letter of a company name) matters. 
Use the accounts table to pull the first letter of each company name to see the distribution of company names 
that begin with each letter (or number). */
SELECT
	SUBSTR(website,5,1) AS first_letter,
	COUNT(*)
  FROM accounts
 GROUP BY first_letter;

/* Question 3 Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number and the second group of those company names that start with a letter. 
What proportion of company names start with a letter? */
WITH cases
AS (
	SELECT
		CASE WHEN LEFT(name,1) IN ('0','1','2','3','4','5','6','7','8','9')
		THEN 1
		ELSE 0
		END AS num,
		CASE WHEN LEFT(name,1) NOT IN('0','1','2','3','4','5','6','7','8','9')
		THEN 1
		ELSE 0
		END AS letters
	  FROM accounts
)

SELECT
	SUM(num) AS number,
	SUM(letters) AS letter
  FROM cases

/* Question 4 Consider vowels as a, e, i, o, and u. 
What proportion of company names start with a vowel, and what percent start with anything else? */
WITH cases
AS (
	SELECT
		CASE WHEN LEFT(name,1) IN ('A','E','I','O','U')
		THEN 1
		ELSE 0
		END AS vowel,
		CASE WHEN LEFT(name,1) NOT IN('A','E','I','O','U')
		THEN 1
		ELSE 0
		END AS consonant
	  FROM accounts
)

SELECT
	SUM(vowel) AS vow,
	SUM(consonant) AS cons
  FROM cases

/* 11. Quiz: CONCAT, LEFT, RIGHT, and SUBSTR*/
/* Question 1 Suppose the company wants to assess the performance of all the sales representatives. 
Each sales representative is assigned to work in a particular region. 
To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore), 
and region.name as EMP_ID_REGION for each sales representative */
SELECT
	CONCAT(s.id,'_',r.name) AS EMP_ID_REGION,
	s.name AS rep_name
  FROM region AS r 
  	   INNER JOIN sales_reps AS s 
  	   ON r.id = s.region_id;

/* Question 2 From the accounts table, display the name of the client, the coordinate as concatenated
(latitude, longitude), email id of the primary point of contact as <first letter of the primary_poc>
<last letter of the primary_poc>@<extracted name and domain from the website>.*/
SELECT
	a.name,
	CONCAT(a.lat,',',a.long) AS coordinate,
	CONCAT(LEFT(a.primary_poc,1),RIGHT(a.primary_poc,1),'@',SUBSTR(a.website,5)) AS email
  FROM accounts AS a;

/* Question 3 From the web_events table, display the concatenated value of account_id, '_' , channel, '_', 
count of web events of the particular channel.*/
WITH t1 AS (
	SELECT 
		account_id,
		channel,
		COUNT(*) AS num_web_events
	  FROM web_events
	 GROUP BY account_id, channel
)

SELECT
	CONCAT(account_id,'_',channel,'_',num_web_events)
  FROM t1 

/* 13.Quiz:CAST
1. Write a query to look up top 10 rows to understand the columns and the raw data in the dataset called sf_crime_data */
SELECT *
  FROM sf_crime_data
 LIMIT 10

/* 4. Write a query to change the date into the correct SQL date format (yyyy-mm-dd), use SUBSTR and CONCAT*/
WITH t1 AS
	(
	SELECT
	SUBSTR(date, 1, 2) AS month,
	SUBSTR(date, 4, 2) AS day,
	SUBSTR(date, 7, 4) AS year
  FROM sf_crime_data
  	)

SELECT
	CONCAT(year,'-', month, '-', day) AS date
  FROM t1
 LIMIT 10

/* CAST into a date*/ 
SELECT
	CAST(date,date) AS date 
  FROM sf_crime_data
-- Incorrect
-- Solution
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;

/* 17. Quiz: POSITION, STRPOS*/
/* Use the accounts table to create first and last name columns 
that hold the first and last names for the primary_poc.*/
SELECT
	primary_poc,
	LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
  FROM accounts 

/* Now see if you can do the same thing for every rep name in the 
sales_reps table. Again provide first and last name columns.*/
SELECT
	name,
	LEFT(name, POSITION(' ' IN name) - 1) AS first_name,
	RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) AS last_name
  FROM sales_reps

/* 19. Quiz: CONCAT & STRPOS - Bringing it together */
/* Question 1 Each company in the accounts table wants to create an email address for each primary_poc. 
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com. */
WITH t1 AS
	(
		SELECT
			primary_poc,
			name,
			LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS fn_poc,
			RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS ln_poc
		  FROM accounts	
	)

SELECT
	CONCAT(fn_poc, '.', ln_poc, '@', name, '.com')
  FROM t1

/* Question 2 You may have noticed that in the previous solution some of the company names include spaces, 
which will certainly not work in an email address. See if you can create an email address that will 
work by removing all of the spaces in the account name, but otherwise, your solution should be just as 
in question 1. Some helpful documentation is here.*/
WITH t1 AS
	(
		SELECT
			primary_poc,
			name,
			LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS fn_poc,
			RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS ln_poc
		  FROM accounts	
	)

SELECT
	REPLACE(CONCAT(fn_poc, '.', ln_poc, '@', name, '.com'), ' ', '')
  FROM t1

/* Question 3 We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter 
of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their 
last name (lowercase), the number of letters in their first name, the number of letters in their last name, and
then the name of the company they are working with, all capitalized with no spaces.*/
WITH t1 AS
	(
		SELECT
			primary_poc,
			name,
			LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS fn_poc,
			RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS ln_poc
		  FROM accounts	
	)

SELECT
	CONCAT(
	LOWER(LEFT(fn_poc,1)),
	LOWER(RIGHT(fn_poc,1)),
	LOWER(LEFT(ln_poc,1)),
	LOWER(RIGHT(ln_poc,1)),
	LENGTH(fn_poc),
	LENGTH(ln_poc),
	REPLACE(UPPER(name),' ','')) AS password
  FROM t1
