-- Window functions

-- Úkol 1:

SELECT
	cp.`category_code`,
	cpc.`name`,
	cp.`region_code`,
	CONCAT(YEAR(cp.`date_from`), '/', MONTH(`date_from`)) `year_and_month`,
	REPLACE(CONCAT(cp.`value`, ' Kč / ', cpc.`price_value`, ' ', cpc.`price_unit`), '.', ',') `price`,
	RANK() OVER (PARTITION BY cp.`category_code` ORDER BY cp.`value` DESC) `value_rank`
FROM czechia_price cp
JOIN czechia_price_category cpc
	ON cp.`category_code` = cpc.`code`
ORDER BY
	`value_rank`,
	cp.`value` DESC;
	
-- Úkol 2:

SELECT
	*
FROM (
	SELECT
		cp.`category_code`,
		cpc.`name`,
		cp.`region_code`,
		CONCAT(YEAR(cp.`date_from`), '/', MONTH(`date_from`)) `year_and_month`,
		REPLACE(CONCAT(cp.`value`, ' Kč / ', cpc.`price_value`, ' ', cpc.`price_unit`), '.', ',') `price`,
		RANK() OVER (PARTITION BY cp.`category_code` ORDER BY cp.`value` DESC) `value_rank`
	FROM czechia_price cp
	JOIN czechia_price_category cpc
		ON cp.`category_code` = cpc.`code`
	ORDER BY
		`value_rank`,
		cp.`value` DESC
) e
WHERE e.`value_rank` < 3;

-- Úkol 3:

SELECT
	cp.`category_code`,
	cpc.`name`,
	cp.`region_code`,
	CONCAT(YEAR(cp.`date_from`), '/', MONTH(`date_from`)) `year_and_month`,
	REPLACE(CONCAT(cp.`value`, ' Kč / ', cpc.`price_value`, ' ', cpc.`price_unit`), '.', ',') `price`,
	RANK() OVER (PARTITION BY cp.`category_code` ORDER BY cp.`value` DESC) `value_rank`,
	DENSE_RANK() OVER (PARTITION BY cp.`category_code` ORDER BY cp.`value` DESC) `value_dense_rank`,
	ROW_NUMBER () OVER (PARTITION BY cp.`category_code` ORDER BY cp.`value` DESC) `value_row_number`
FROM czechia_price cp
JOIN czechia_price_category cpc
	ON cp.`category_code` = cpc.`code`
ORDER BY
	cp.`category_code`,
	`value_row_number`;

-- Úkol 4:

SELECT
	`date`,
	`country`,
	`confirmed`,
	FIRST_VALUE(`confirmed`) OVER (ORDER BY `confirmed`) `first_value_in_confirmed`
FROM covid19_basic_differences cbd
WHERE
	`country` = 'Italy'
	AND `confirmed` IS NOT NULL
ORDER BY `date`;

-- Úkol 5:

SELECT
	`date`,
	`country`,
	`confirmed`,
	FIRST_VALUE(`confirmed`) OVER (ORDER BY `confirmed`) `first_value_in_confirmed`
FROM covid19_basic_differences cbd
WHERE `confirmed` IS NOT NULL
ORDER BY `date`;

-- Úkol 6:

SELECT
	`date`,
	`country`,
	`confirmed`,
	FIRST_VALUE(`confirmed`) OVER (ORDER BY `confirmed`) `first_value_in_confirmed_above_100000`
FROM covid19_basic_differences cbd
WHERE `confirmed` > 100000
ORDER BY
	`date`;

-- Další operace v klauzuli SELECT

-- Úkol 1:

SELECT SQRT(-16);
SELECT 10/0;
SELECT FLOOR(1.56);
SELECT FLOOR(-1.56);
SELECT CEIL(1.56);
SELECT CEIL(-1.56);
SELECT ROUND(1.56);
SELECT ROUND(-1.56);

-- Úkol 2:

SELECT
	*,
	ROUND(SUM(`value`) / COUNT(`value`), 2) `avg_value`
FROM czechia_price cp
GROUP BY `category_code`
ORDER BY `avg_value`;

-- Úkol 3:

SELECT 1;
SELECT 1.0;
SELECT 1 + 1;
SELECT 1 + 1.0;
SELECT 1 + '1';
SELECT 1 + 'a';
SELECT 1 + '12tatata';

-- Úkol 4:

SELECT CONCAT('Hi, ', 'Engeto lektor here!');

SELECT 
	CONCAT('We have ', COUNT(DISTINCT `category_code`), ' price categories.')  `info`
FROM czechia_price cp;

SELECT
	SUBSTRING(`name`, 1, 2) `prefix`,
	SUBSTRING(`name`, -2, 2) `sufix`,
	`name`,
	LENGTH(`name`) `name_length`
FROM czechia_price_category cpc;

-- Úkol 5:

SELECT 5 % 2;
SELECT 14 % 5;
SELECT 15 % 5;
SELECT 123456789874 % 11;
SELECT 123456759874 % 11;

-- Úkol 6:

SELECT
	`country`,
	`year`,
	`population`,
	`population` % 2 `division_rest`
FROM economies e
WHERE `population` IS NOT NULL;

SELECT
	`country`,
	`year`,
	`population`,
	NOT `population` % 2 `is_even`
FROM economies e
WHERE `population` IS NOT NULL;

SELECT
	`country`,
	`year`,
	`population`,
	NOT `population` % 2 `s_even`
FROM economies e
WHERE
	`population` IS NOT NULL
	AND `population` % 2 = 0;

-- Klauzule HAVING

-- Úkol 1

SELECT
	`country`,
	SUM(`confirmed`) `total_confirmed`
FROM covid19_basic_differences cbd
GROUP BY `country`
HAVING `total_confirmed` > 5000000;

-- Úkol 2

SELECT
	`country`,
	`year`,
	SUM(`population`) `overal_population`
FROM economies e
WHERE `country` != 'World'
GROUP BY
	`country`,
	`year`
HAVING `overal_population` > 4000000000
ORDER BY `year`;

-- Úkol 3

SELECT
	`name`,
	(6371 * ACOS(COS(RADIANS(49)) * COS(RADIANS(`latitude`)) * COS(RADIANS(`longitude`) - RADIANS(15)) + SIN(RADIANS(49)) * SIN(RADIANS(`latitude`)))) `distance`
FROM healthcare_provider hp
HAVING `distance` < 10
ORDER BY `distance`
LIMIT 20;

-- Common Table Expression

-- Úkol 1

WITH high_price AS (
	SELECT
		`category_code` `code`
	FROM czechia_price cp
	WHERE `value` > 150
)
SELECT
	DISTINCT cpc.`name`
FROM high_price hp
LEFT JOIN czechia_price_category cpc
	ON hp.`code` = cpc.`code`;

-- Úkol 2

WITH not_completed_provider_info_district AS (
	SELECT
		DISTINCT `district_code`
	FROM healthcare_provider hp
	WHERE
		`phone` IS NULL
		AND `fax` IS NULL
		AND `email` IS NULL
		AND `provider_type` = 'Samost. ordinace všeob. prakt. lékaře'
)
SELECT
	*
FROM czechia_district cd
WHERE `code` NOT IN (
	SELECT
		*
	FROM not_completed_provider_info_district
);

-- Úkol 3

WITH countries_christianity AS (
	SELECT
		*
	FROM countries c
	WHERE `religion` = 'Christianity'
),
countries_buddhism AS (
	SELECT
		*
	FROM countries c
	WHERE `religion` = 'Buddhism'
)
SELECT
	`capital_city`
FROM countries_christianity
UNION
SELECT
	`capital_city`
FROM countries_buddhism;

-- Úkol 4

WITH large_gdp_area AS (
	SELECT
		*
	FROM economies e
	WHERE `GDP` > 70000000000
)
SELECT
	ROUND(AVG(`taxes`), 2) `avg_taxes`
FROM large_gdp_area;