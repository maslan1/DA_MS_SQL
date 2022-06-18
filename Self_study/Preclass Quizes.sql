Use SampleRetail;
--

-- FUNCTIONS
/*
List the product names in ascending order where the part from the beginning to the first space character
is "Samsung" in the product_name column.
*/

SELECT		PP.product_name
FROM		product.product PP
WHERE		PP.product_name LIKE ('Samsung %')
ORDER BY	PP.product_name
;

-- Alternative Method
SELECT	PP.product_name
FROM	product.product PP
WHERE	SUBSTRING(PP.product_name, 1, 8) = 'Samsung '
ORDER BY	PP.product_name
;

--
/*
Write a query that returns streets in ascending order. 
The streets have an integer character lower than 5 after the "#" character end of the street. 
(use sale.customer table)
*/

SELECT	SC.street
FROM	sale.customer SC
WHERE	ISNUMERIC(SUBSTRING(SC.street, CHARINDEX('#', SC.street)+1, 4)) = 1 AND SUBSTRING(SC.street, CHARINDEX('#', SC.street)+1, 4)< 5
ORDER BY	SC.street
;

SELECT *
FROM	sale.customer

-- Joins and View
/*
Write a query that returns orders of the products branded "Seagate". 
It should be listed Product names and order IDs of all the products ordered or not ordered. 
(order_id in ascending order)
*/

SELECT		PP.product_name, OI.order_id
FROM		product.product PP
LEFT JOIN	sale.order_item OI ON PP.product_id = OI.product_id
LEFT JOIN	product.brand PB ON PB.brand_id = PP.brand_id
WHERE		PB.brand_name = ('Seagate')
ORDER BY	OI.order_id
;

--
/*
Write a query that returns the order date of the product named "Sony - 5.1-Ch. 3D / Smart Blu-ray 
Home Theater System - Black".
*/

SELECT		SO.order_date
FROM		sale.orders SO
LEFT JOIN	 sale.order_item OI ON OI.order_id = SO.order_id
LEFT JOIN	 product.product PP ON OI.product_id = PP.product_id
WHERE		PP.product_name = ('Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black')
ORDER BY	SO.order_date
;


-- ADVANCED GROUPING OPERATIONS
/*
Please write a query to return only the order ids that have an average amount of more than $2000. 
Your result set should include order_id. Sort the order_id in ascending order.
*/

SELECT OI.order_id
FROM sale.order_item OI
GROUP BY OI.order_id
HAVING AVG((OI.list_price-OI.discount)*OI.quantity) > 2000;


--
/*
Write a query that returns the count of orders of each day between '2020-01-19' and '2020-01-25'. 
Report the result using Pivot Table.

Note: The column names should be day names (Sun, Mon, etc.).
*/

SELECT [sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [saturday]
FROM
	(
	SELECT SO.order_id, DATENAME(WEEKDAY, SO.order_date) day_name
	FROM   sale.orders SO
	WHERE SO.order_date BETWEEN '2020-01-19' AND '2020-01-25'
	) AS dayOrderCnt
PIVOT 
	(
	 COUNT(order_id)
	 FOR day_name
	 IN ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [saturday])
	) AS pivot_table
;


-- SET OPERATOR
/*
Detect the store that does not have a product named "Samsung Galaxy Tab S3 Keyboard Cover" in its stock. 
*/

SELECT	SS.store_name
FROM	sale.store SS
GROUP BY SS.store_name
EXCEPT
SELECT	SS.store_name
FROM	sale.store SS, product.stock PS, product.product PP
WHERE	SS.store_id = PS.store_id 
AND		PS.product_id = PP.product_id
AND		PP.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
GROUP BY SS.store_name
;

--
/*
List in ascending order the stores where both "Samsung Galaxy Tab S3 Keyboard Cover" and 
"Apple - Pre-Owned iPad 3 - 64GB - Black" are stocked.
*/

SELECT	SS.store_name
FROM	sale.store SS, product.stock PS, product.product PP
WHERE	SS.store_id = PS.store_id 
AND		PS.product_id = PP.product_id
AND		PP.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
AND		PS.quantity > 0
GROUP BY SS.store_name
INTERSECT
SELECT	SS.store_name
FROM	sale.store SS, product.stock PS, product.product PP
WHERE	SS.store_id = PS.store_id 
AND		PS.product_id = PP.product_id
AND		PP.product_name = 'Apple - Pre-Owned iPad 3 - 64GB - Black'
AND		PS.quantity > 0
GROUP BY SS.store_name
;



-- CASE EXPRESSIONS
/*
List counts of orders on the weekend and weekdays
*/

-- USE DATENAME IN CASE EXP.
SELECT SUM([weekend])
FROM
(
	SELECT	
			CASE
			WHEN DATENAME(WEEKDAY, SO.order_date) IN ('SATURDAY', 'SUNDAY') THEN COUNT(SO.order_id)
			END [weekend]
	FROM	sale.orders SO
	GROUP BY SO.order_date
)
UNION
SELECT	
		CASE 
		WHEN DATENAME(WEEKDAY, SO.order_date) IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') THEN COUNT(SO.order_id)
		END [weekday]
FROM	sale.orders SO
GROUP BY SO.order_date

--
SELECT	COUNT(SO.order_id) [weekend]
FROM	sale.orders SO
WHERE (SELECT DATENAME(WEEKDAY, SO.order_date) AS [weekend]) IN ('SATURDAY', 'SUNDAY')

SELECT	COUNT(SO.order_id) [weekday]
FROM	sale.orders SO
WHERE (SELECT DATENAME(WEEKDAY, SO.order_date) AS [weekday]) IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY')
;
--

SELECT	COUNT(SO.order_id) [weekend]
FROM	sale.orders SO
WHERE (SELECT DATENAME(WEEKDAY, SO.order_date) AS [weekend]) IN ('SATURDAY', 'SUNDAY')

WITH table1 AS	
		(
		SELECT	
			CASE
			WHEN DATENAME(WEEKDAY, SO.order_date) IN ('SATURDAY', 'SUNDAY') THEN 1
			END [weekend]
	FROM	sale.orders SO
		)
SELECT SUM([weekend]) [weekend]
FROM table1
UNION ALL
WITH table2 AS	
		(
		SELECT	
		CASE 
		WHEN DATENAME(WEEKDAY, SO.order_date) IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') THEN 1
		END [weekday]
FROM	sale.orders SO
		)
SELECT SUM([weekday]) [weekday]
FROM table2
;
-- Result

SELECT
--CASE WHEN DATENAME(WEEKDAY, SO.order_date) IN ('Samstag','Sonntag') THEN 'Weekend' ELSE 'Weekday' END AS WED,
	SUM(CASE WHEN DATENAME(WEEKDAY, SO.order_date) IN ('Saturday','Sunday')   THEN 1 ELSE 0 END) AS [weekend],
	SUM(CASE WHEN DATENAME(WEEKDAY, SO.order_date) IN ('Monday','Tuesday','Wednesday','Thursday','Friday')   THEN 1 ELSE 0 END) AS [weekday]
FROM sale.orders SO

--
/*
Classify staff according to the count of orders they receive as follows:

a) 'High-Performance Employee' if the number of orders is greater than 400
b) 'Normal-Performance Employee' if the number of orders is between 100 and 400
c) 'Low-Performance Employee' if the number of orders is between 1 and 100
d) 'No Order' if the number of orders is 0

Then, list the staff's first name, last name, employee class, and count of orders.
(Count of orders and first names in ascending order)
*/

SELECT		SS.first_name, 
			SS.last_name, 
			CASE
				WHEN COUNT(SA.order_id) > 400 THEN 'High-Performance Employee'
				WHEN COUNT(SA.order_id) BETWEEN 100 AND 400 THEN 'Normal-Performance Employee'
				WHEN COUNT(SA.order_id) BETWEEN 1 AND 100 THEN 'Low-Performance Employee'
				WHEN COUNT(SA.order_id) = 0 THEN 'No Order'
			END AS employee_class,
			COUNT(SA.order_id) Count_of_Orders
FROM		sale.staff SS
LEFT JOIN	sale.orders SA
ON			SA.staff_id = SS.staff_id
GROUP BY	SS.first_name, SS.last_name
ORDER BY	4, 1
;



-- SUBQUERIES AND COMMON TABLE EXPRESSIONS
/*
List the store names in ascending order that 
did not have an order between "2018-07-22" and "2018-07-28".
*/

SELECT		DISTINCT SS.store_name
FROM		sale.store SS, sale.orders SO
WHERE		SS.store_name 
IN			(
			SELECT	SS.store_name
			FROM	sale.orders SO, sale.store SS
			WHERE	SO.store_id = SS.store_id
			EXCEPT
			SELECT	SS.store_name
			FROM	sale.orders SO, sale.store SS
			WHERE	SO.order_date BETWEEN '2018-07-22' AND '2018-07-28'
AND			SO.store_id = SS.store_id
			)
AND			SO.store_id = SS.store_id
ORDER BY	SS.store_name
;

-- 
/*
List customers with each order over 500$ and reside in the city of Charleston. 
List customers' first name and last name ( both of the last name and first name in ascending order). 
*/
WITH table2 AS
				(
				SELECT		SC.first_name, SC.last_name, SC.city, OI.quantity, OI.list_price, OI.discount
				FROM		sale.customer SC, sale.orders SO, sale.order_item OI
				WHERE		SC.customer_id = SO.customer_id
				AND			SO.order_id = OI.order_id
				AND			city = 'Charleston'
				HAVING		SUM(OI.quantity*OI.list_price*(1-OI.discount)) > 500
				)
SELECT		first_name, last_name
FROM		table2
GROUP BY	first_name, last_name
ORDER BY	first_name, last_name


-- Result

SELECT first_name, last_name
FROM sale.customer SC
WHERE city='Charleston' and EXISTS (
			SELECT O.customer_id
			FROM sale.order_item I, sale.orders O WHERE O.order_id=I.order_id
			AND SC.customer_id = O.customer_id
			GROUP BY O.order_id, O.customer_id
			HAVING SUM(quantity*list_price*(1-discount)) > 500
			EXCEPT
			SELECT O.customer_id
			FROM sale.order_item I, sale.orders O WHERE O.order_id=I.order_id
			AND SC.customer_id = O.customer_id
			GROUP BY O.order_id, O.customer_id
			HAVING SUM(quantity*list_price*(1-discount)) <= 500
			)
ORDER BY last_name, first_name
		

-- WINDOW FUNCTIONS
/*
Write a query using the window function that returns the cumulative total turnovers of the Burkes Outlet
by order date between "2019-04-01" and "2019-04-30".

Columns that should be listed are: 'order_date' in ascending order and 'Cumulative_Total_Price'.
*/
SELECT DISTINCT	SO.order_date,
			SUM(OI.quantity*OI.list_price) OVER (ORDER BY SO.order_date) ord_total
FROM		sale.store SS, sale.order_item OI, sale.orders SO
WHERE		SS.store_id = SO.store_id
AND			SO.order_id = OI.order_id
AND			SS.store_name = 'Burkes Outlet'
AND			SO.order_date BETWEEN '2019-04-01' AND '2019-04-30'

--
/*
Write a query using the window function that returns staffs' first name, last name, and their total net amount of orders in descending order.
*/
SELECT DISTINCT	SS.first_name, SS.last_name, 
			SUM(OI.quantity*OI.list_price*(1-OI.discount)) OVER (PARTITION BY SS.first_name) net_amount
FROM		sale.staff SS, sale.order_item OI, sale.orders SO
WHERE		SO.order_id = OI.order_id
AND			SS.staff_id = SO.staff_id
ORDER BY	3 DESC

--
/*
List the employee's first order dates by month in 2020. Expected columns are: first name, last name, month and the first order date. 
(last name and month in ascending order)
*/
SELECT DISTINCT	first_name, last_name, 
			MONTH(order_date) [month],
			FIRST_VALUE(order_date) OVER (PARTITION BY SS.staff_id, MONTH(order_date) ORDER BY order_date) first_order
FROM		sale.staff SS, sale.orders SO
WHERE		SS.staff_id = SO.staff_id
AND			YEAR(SO.order_date) = 2020
GROUP BY	first_name, last_name, SS.staff_id, order_date
ORDER BY	2, 4
;

