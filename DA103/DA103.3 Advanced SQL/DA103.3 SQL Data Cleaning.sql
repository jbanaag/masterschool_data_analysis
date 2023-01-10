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