/* DA102.3 Deforestation Project*/
/* Pre-Step: Create Forestation View*/
CREATE VIEW forestation
AS
(
	SELECT 
		f.country_code,
		f.country_name,
		f.year,
		f.forest_area_sqkm,
		l.total_area_sq_mi,
		r.region,
		r.income_group,
		f.forest_area_sqkm/(l.total_area_sq_mi * 2.59) AS percent_forest_area	
	  FROM forest_area AS f 
	       INNER JOIN land_area AS l 
	       ON f.country_code = l.country_code
	       AND f.year = l.year
	       INNER JOIN regions AS r
	       ON r.country_code = f.country_code
);
-- Check to see if it works
SELECT *
  FROM forestation
 LIMIT 10;

/* Create a new column that provides the percent of the land area that is designated as forest */
f.forest_area_sqkm/(l.total_area_sq_mi * 2.59)

-- Create a DROP VIEW
DROP VIEW IF EXISTS forestation;

CREATE VIEW forestation
AS
(
	SELECT 
		f.country_code,
		f.country_name,
		f.year,
		f.forest_area_sqkm,
		l.total_area_sq_mi,
		r.region,
		r.income_group,
		100*f.forest_area_sqkm/(l.total_area_sq_mi * 2.59) AS percent_forest_area	
	  FROM forest_area AS f 
	       INNER JOIN land_area AS l 
	       ON f.country_code = l.country_code
	       AND f.year = l.year
	       INNER JOIN regions AS r
	       ON r.country_code = f.country_code
);

-- Step 1: Global Outlook
/*What was the total forest area (in sq km) of the world in 1990? 
Please keep in mind that you can use the country record denoted as “World" in the region table.*/
SELECT
	forest_area_sqkm AS forest_area_sqkm_1990
  FROM forestation
 WHERE year = '1990' AND country_name = 'World';

/* What was the total forest area (in sq km) of the world in 2016? 
Please keep in mind that you can use the country record in the table is denoted as “World.”*/
SELECT
	forest_area_sqkm AS forest_area_sqkm_2016
  FROM forestation
 WHERE year = '2016' AND country_name = 'World';

/* What was the change (in sq km) in the forest area of the world from 1990 to 2016? */
WITH forest_area_1990 
AS (
	SELECT
		forest_area_sqkm AS forest_area_sqkm_1990
	  FROM forestation
	 WHERE year = '1990' AND country_name = 'World'
	),

forest_area_2016 
AS (
	SELECT
		forest_area_sqkm AS forest_area_sqkm_2016
	  FROM forestation
	 WHERE year = '2016' AND country_name = 'World'
	)
-- Option 1
SELECT 
	(SELECT forest_area_sqkm_2016
	   FROM forest_area_2016),
	(SELECT forest_area_sqkm_1990 
	   FROM forest_area_1990),
	(SELECT forest_area_sqkm_2016 FROM forest_area_2016 ) - (SELECT forest_area_sqkm_1990 FROM forest_area_1990) 
	AS difference
-- Option 2
-- SELECT 
-- 	fa_2016.forest_area_sqkm_2016 - fa_1990.forest_area_sqkm_1990 
-- 	AS difference
--   FROM forest_area_1990 AS fa_1990
--        INNER JOIN forest_area_2016 AS fa_2016
--        ON fa_2016.country_name = fa_1990.country_name -- BUT you have to include country name in your WITH as a column

/* What was the percent change in forest area of the world between 1990 and 2016? */
-- Include WITH statement
SELECT
	((SELECT forest_area_sqkm_2016 FROM forest_area_2016)*100)/
	(SELECT forest_area_sqkm_1990 FROM forest_area_1990)
	AS percent_diff

/* If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to? */
-- Include WITH statement
-- Abs value is 1324449
SELECT 
	(SELECT forest_area_sqkm_2016
	   FROM forest_area_2016),
	(SELECT forest_area_sqkm_1990 
	   FROM forest_area_1990),
	country_name,
	ABS((SELECT forest_area_sqkm_2016 FROM forest_area_2016 ) - (SELECT forest_area_sqkm_1990 FROM forest_area_1990)) 
	AS abs_difference_forest_area_lost,
	(total_area_sq_mi * 2.59) AS total_area_sqkm
  FROM forestation
 WHERE year = '2016'
       AND (total_area_sq_mi * 2.59) BETWEEN 1250000 AND 1400000
 ORDER BY total_area_sqkm DESC;

-- Step 2: Regional Outlook
/* Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) 
in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).*/
WITH forest_percentage_1990
AS (
	SELECT 
		region AS rn1990,
		100*(SUM(forest_area_sqkm))/((SUM(total_area_sq_mi)*2.59)) AS fp1990
    FROM forestation
   WHERE year = '1990'
   GROUP BY region
   ORDER BY fp1990 DESC  
),

forest_percentage_2016
AS (
	SELECT 
		region AS rn2016,
		100*(SUM(forest_area_sqkm))/((SUM(total_area_sq_mi)*2.59)) AS fp2016
    FROM forestation
   WHERE year = '2016'
   GROUP BY region
   ORDER BY fp2016 DESC 
),

joined_forest_percentage
AS (
	SELECT
		rn2016 AS region_name,
		fp1990.fp1990 AS fp_1990,
		fp2016.fp2016 AS fp_2016	
	FROM forest_percentage_1990 AS fp1990
	     INNER JOIN forest_percentage_2016 AS fp2016
	     ON rn2016 = rn1990
	ORDER BY rn2016 
	 )

/*What was the percent forest of the entire world in 2016? */
-- Using the WITH statement
SELECT 
	ROUND(fp2016::numeric,2)
FROM forest_percentage_2016
WHERE rn2016 = 'World'
/* Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places? */
SELECT 
	rn2016,
	ROUND(fp2016::numeric,2)
FROM forest_percentage_2016

/* What was the percent forest of the entire world in 1990? */
SELECT
	rn1990,
	ROUND(fp1990::numeric,2)
	FROM forest_percentage_1990
 WHERE rn1990 = 'World'
/* Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places? */
SELECT
	rn1990,
	ROUND(fp1990::numeric,2)
	FROM forest_percentage_1990

/* Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016? */
SELECT 
	region_name,
	fp_1990,
	fp_2016,
	fp_1990 - fp_2016 AS percent_difference
  FROM joined_forest_percentage
 ORDER BY percent_difference DESC; 


/* Success Story */
WITH fa1990 
AS (
		SELECT
			country_name AS cn1990,
			country_code AS cc1990,
			region AS r1990,
			forest_area_sqkm 
		  FROM forestation
		 WHERE year = '1990'
		 ORDER BY forest_area_sqkm DESC
		),

fa2016 
AS (
	  SELECT
			country_name AS cn2016,
			country_code AS cc2016,
			region AS r2016, 
			forest_area_sqkm 
		  FROM forestation
		 WHERE year = '2016'
		 ORDER BY forest_area_sqkm DESC
	  ),

joined_fa
AS (
		SELECT
			cn2016,
			cc2016,
			r2016,
			fa2016.forest_area_sqkm AS fa2016,
			fa1990.forest_area_sqkm AS fa1990
			FROM fa2016 
			     INNER JOIN fa1990  
			     ON  cc2016 = cc1990
		)


SELECT 
	cn2016,
	cc2016,
	r2016,
	fa2016,
	fa1990,
	fa2016 - fa1990 AS fadiff
  FROM joined_fa
 WHERE fa2016 - fa1990 IS NOT NULL 
 ORDER BY fadiff DESC;

SELECT
	cn2016,
	cc2016,
	r2016,
	((fa2016 - fa1990)/fa1990)*100 AS pdfa
  FROM joined_fa
 WHERE ((fa2016 - fa1990)/fa1990)*100 IS NOT NULL
 ORDER BY pdfa DESC; 

/* Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
What was the difference in forest area for each? */
-- Using the WITH Statements
SELECT 
	cn2016,
	cc2016,
	r2016,
	fa2016,
	fa1990,
	fa2016 - fa1990 AS fadiff
  FROM joined_fa 
 ORDER BY fadiff ASC;

/* Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
What was the percent change to 2 decimal places for each? */
-- Using the WITH Statements
SELECT
	cn2016,
	cc2016,
	r2016,
	((fa2016 - fa1990)/fa1990)*100 AS pdfa
  FROM joined_fa
 ORDER BY pdfa ASC; 

/* If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016? */
SELECT
	CASE
		WHEN percent_forest_area <= 25
		THEN '0-25%'

		WHEN percent_forest_area > 25
		AND percent_forest_area <= 50
		THEN '25-50%'

		WHEN percent_forest_area > 50
		AND percent_forest_area <=75
		THEN '50-75%'
		ELSE '75-100%'
	END AS quartiles,
	COUNT(country_code) AS country_count
  FROM forestation
 WHERE forest_area_sqkm IS NOT NULL
       AND total_area_sq_mi IS NOT NULL
       AND country_name != 'World'
       AND year = '2016'
 GROUP BY quartiles
 ORDER BY quartiles ASC 

/* List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016. */
SELECT
	CASE
		WHEN percent_forest_area <= 25
		THEN '0-25%'

		WHEN percent_forest_area > 25
		AND percent_forest_area <= 50
		THEN '25-50%'

		WHEN percent_forest_area > 50
		AND percent_forest_area <=75
		THEN '50-75%'
		ELSE '75-100%'
	END AS quartiles,
	country_name,
    country_code,
    region,
    percent_forest_area
  FROM forestation
 WHERE forest_area_sqkm IS NOT NULL
       AND total_area_sq_mi IS NOT NULL
       AND country_name != 'World'
       AND year = '2016'
 GROUP BY quartiles, country_name, country_code, percent_forest_area, region 
 ORDER BY quartiles DESC , percent_forest_area DESC
 LIMIT 9

/* How many countries had a percent forestation higher than the United States in 2016? */
WITH fp_usa_2016
AS (
		SELECT
			percent_forest_area
		  FROM forestation
		 WHERE country_name = 'United States'
		       AND year = '2016'
		)

SELECT
	COUNT(country_code) AS country_count_greater
  FROM forestation
 WHERE forestation.percent_forest_area > (
																						SELECT
																						percent_forest_area
																					  FROM forestation
																					 WHERE country_name = 'United States'
																					       AND year = '2016'
																					) 
