with table1 
AS
			(
			SELECT product_id,
					SUM(CASE WHEN counts >= 2 THEN 1 ELSE 0 END) AS cust_count,
					COUNT(customer_id) AS total_cust 
			FROM ( 
				SELECT OI.product_id, SO.customer_id,
						COUNT(SO.customer_id) OVER (Partition by OI.product_id, SO.customer_id) AS counts
				FROM sale.orders SO, sale.order_item OI
				WHERE SO.order_id = OI.order_id				
			) as table2
			GROUP BY product_id
			)
SELECT product_id, CAST(1.0*cust_count/total_cust AS NUMERIC (3,2)) perc
from table1

-------------------
/*
From the following table of user IDs, actions, and dates, write a query to return the
publication and cancellation rate for each user.
*/
CREATE TABLE WeeklyAgenda ([User_id] int, [Action] nvarchar (20), [Date] datetime
					
) ;
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

CREATE VIEW table3
AS 
SELECT user_id, strt, Publish, Cancel
FROM (

		SELECT User_id,
				SUM(CASE WHEN Action='Start' THEN 1 ELSE 0 END) as Strt,
				SUM(CASE WHEN Action='Publish' THEN 1 ELSE 0 END)as Publish,
				SUM(CASE WHEN Action='Cancel' THEN 1 ELSE 0 END) as Cancel
		FROM WeeklyAgenda
		GROUP BY [User_id]
		) AS table2

