--a.Create above table (Actions) and insert values,
CREATE DATABASE E_Commerce_Company;
USE E_Commerce_Company;
CREATE SCHEMA Actions;
CREATE TABLE Actions.Actions(
	[Visitor_ID] [int] PRIMARY KEY ,
	[Adv_Type] [nvarchar](50) ,
	[Action] [nvarchar](50));
INSERT INTO Actions.Actions(Visitor_ID, Adv_Type, Action)
VALUES (1, 'A', 'Left'),
       (2, 'A', 'Order'),
	   (3, 'B', 'Left'),
	   (4, 'A', 'Order'),
	   (5, 'A', 'Review'),
	   (6, 'A', 'Left'),
	   (7, 'B', 'Left'),
	   (8, 'B', 'Order'),
	   (9, 'B', 'Review'),
	   (10, 'A', 'Review');
SELECT * FROM Actions.Actions;
--b.Retrieve count of total Actions and Orders for each Advertisement Type,
SELECT Adv_Type, Action,COUNT(Action) AS Conversion INTO order1
FROM Actions.Actions
GROUP BY Action,Adv_Type;
SELECT * FROM order1;
--c.Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.
SELECT  Adv_Type, SUM(CASE WHEN Action='Order' AND Adv_Type='A' THEN Conversion ELSE 0 END)*1.0/(SELECT SUM(CASE WHEN Adv_Type='A' THEN Conversion ELSE 0 END)
FROM order1) AS Conversion_Rate INTO table1
FROM order1
GROUP BY Adv_Type
UNION ALL
SELECT Adv_Type, SUM(CASE WHEN Action='Order' AND Adv_Type='B' THEN Conversion ELSE 0 END)*1.0/(CASE WHEN Adv_Type='B' THEN Conversion ELSE 0 END)
FROM order1) AS Conversion_Rate
FROM order1
GROUP BY Adv_Type
DELETE FROM table1 WHERE Conversion_Rate=0.000000
;
SELECT * FROM table1
----RESULT-----------------
SELECT Adv_Type, CAST(ROUND(Conversion_Rate, 2) AS DECIMAL(2,2)) AS Conversion_Rate
FROM table1
