USE SampleRetail;

/*
1- Report cumulative total turnover by months in each year in pivot table format.
*/

SELECT	*
FROM		
	(
	SELECT DISTINCT	YEAR(SO.order_date) ord_year, MONTH(SO.order_date) ord_month, 
					SUM(list_price * quantity) OVER (PARTITION BY YEAR(SO.order_date) ORDER BY YEAR(SO.order_date), MONTH(SO.order_date)) turnover
	FROM			sale.orders SO, sale.order_item OI
	WHERE			SO.order_id = OI.order_id
	) A
PIVOT
		(
		MAX(turnover)
		FOR ord_year
		IN ([2018], [2019],[2020])
		) AS pivot_table
		
---

/*
2- What percentage of customers purchasing a product have purchased the same product again?
*/

WITH	table1 
AS
		(
		SELECT DISTINCT product_id, 
				SUM(CASE WHEN counts >= 2 THEN 1 ELSE 0 END) AS cust_cnt,
				COUNT(customer_id) AS total_cust
		FROM	(
				SELECT DISTINCT	OI.product_id, SO.customer_id, 
								COUNT(SO.customer_id) OVER (PARTITION BY OI.product_id, SO.customer_id) AS counts
				FROM	sale.orders SO, sale.order_item OI
				WHERE	SO.order_id = OI.order_id
				) AS table2
		GROUP BY product_id
		)

SELECT	product_id, CAST(1.0 * cust_cnt / total_cust AS NUMERIC(3,2)) perc
FROM	table1
;
---

/*
3- From the following table of user IDs, actions, and dates, write a query to return 
the publication and cancellation rate for each user.
*/
USE Assignments;

CREATE TABLE WeeklyAgenda ([User_id] int, [Action] nvarchar (20), [Date] datetime);

--DROP TABLE IF EXISTS WeeklyAgenda;
INSERT INTO WeeklyAgenda ([User_id] , [Action] , [Date] )
VALUES (1,'Start','1-1-22'),
		(1,'Cancel','1-2-22'),
		(2,'Start','1-3-22'),
		(2,'Publish','1-4-22'),
		(3,'Start','1-5-22'),
		(3,'Cancel','1-6-22'),
		(1,'Start','1-7-22'),
		(1,'Publish','1-8-22')
		;

SELECT *
FROM WeeklyAgenda

CREATE VIEW		table3
AS			
SELECT		user_id, strt, Publish, Cancel
FROM		(
			SELECT User_id,
					SUM(CASE WHEN Action='Start' THEN 1 ELSE 0 END) as strt,
					SUM(CASE WHEN Action='Publish' THEN 1 ELSE 0 END) as Publish,
					SUM(CASE WHEN Action='Cancel' THEN 1 ELSE 0 END) as Cancel
			FROM WeeklyAgenda
			GROUP BY [User_id]
			) AS table2

SELECT	user_id, 
		CAST(1.0* Publish / strt AS NUMERIC(2,1)) AS publish_rate, 
		CAST(1.0* Cancel / strt AS NUMERIC(2,1)) AS cancel_rate
FROM	table3
---