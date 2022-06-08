USE SampleRetail;
SELECT DISTINCT C.customer_id, D.first_name, D.last_name
INTO #join1
FROM product.product AS A
JOIN sale.order_item AS B ON A.product_id=B.product_id
JOIN sale.orders AS C ON B.order_id=C.order_id
JOIN sale.customer AS D ON C.customer_id=D.customer_id
WHERE  A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY C.customer_id ASC;
--1---
SELECT DISTINCT C.customer_id, D.first_name, D.last_name, A.product_name as First_product
INTO #first_
FROM product.product AS A
JOIN sale.order_item AS B ON A.product_id=B.product_id
JOIN sale.orders AS C ON B.order_id=C.order_id
JOIN sale.customer AS D ON C.customer_id=D.customer_id
WHERE  A.product_name = 'Polk Audio - 50 W Woofer - Black'
ORDER BY C.customer_id ASC;
select * from #first_;
--2---
SELECT DISTINCT C.customer_id, D.first_name, D.last_name, A.product_name as Second_product
INTO #second_
FROM product.product AS A
JOIN sale.order_item AS B ON A.product_id=B.product_id
JOIN sale.orders AS C ON B.order_id=C.order_id
JOIN sale.customer AS D ON C.customer_id=D.customer_id
WHERE  A.product_name = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)'
ORDER BY C.customer_id ASC;
select * from #second_;
--3---
SELECT DISTINCT C.customer_id, D.first_name, D.last_name, A.product_name as Third_product
INTO #third_
FROM product.product AS A
JOIN sale.order_item AS B ON A.product_id=B.product_id
JOIN sale.orders AS C ON B.order_id=C.order_id
JOIN sale.customer AS D ON C.customer_id=D.customer_id
WHERE  A.product_name = 'Virtually Invisible 891 In-Wall Speakers (Pair)'
ORDER BY C.customer_id ASC;
--SELECT * FROM #third_;
---
--join1 ve 1--
--SELECT #join1.customer_id, #join1.first_name, #join1.last_name, #first_.First_product
--INTO #join2
--FROM #join1
--LEFT JOIN #first_ ON #join1.customer_id=#first_.customer_id
/*SELECT * FROM #join2;
--join2 ve 2--
SELECT #join2.customer_id, #join2.first_name, #join2.last_name, #join2.First_product, #second_.Second_product
INTO #join3
FROM #join2
LEFT JOIN #second_ ON #join2.customer_id=#second_.customer_id
select * from #join3;
--join3 ve 3--
SELECT #join3.customer_id, #join3.first_name, #join3.last_name,#join3.First_product, #join3.Second_product, #third_.Third_product
INTO #join4
FROM #join3
LEFT JOIN #third_ ON #join3.customer_id=#third_.customer_id;
select * from #join4;
*/
SELECT *,
CASE WHEN #join4.First_product = 'Polk Audio - 50 W Woofer - Black'
         THEN 'YES' ELSE 'NO' END AS First_product ,
CASE WHEN #join4.Second_product = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)'
         THEN 'YES' ELSE 'NO' END AS Second_product,
CASE WHEN #join4.Third_product = 'Virtually Invisible 891 In-Wall Speakers (Pair)'
         THEN 'YES' ELSE 'NO' END AS Third_product
FROM #join4
--- result--
SELECT #join1.customer_id, #join1.first_name, #join1.last_name,
CASE WHEN #first_.First_product = 'Polk Audio - 50 W Woofer - Black'
         THEN 'YES' ELSE 'NO' END AS First_product ,
CASE WHEN #second_.Second_product = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)'
         THEN 'YES' ELSE 'NO' END AS Second_product,
CASE WHEN #third_.Third_product = 'Virtually Invisible 891 In-Wall Speakers (Pair)'
         THEN 'YES' ELSE 'NO' END AS Third_product
FROM #join1
LEFT JOIN #first_ ON #join1.customer_id=#first_.customer_id
LEFT JOIN #second_ ON #join1.customer_id=#second_.customer_id
LEFT JOIN #third_ ON #join1.customer_id=#third_.customer_id
/*DROP TABLE IF EXISTS #join1
DROP TABLE IF EXISTS #join2
DROP TABLE IF EXISTS #join3
DROP TABLE IF EXISTS #join4
DROP TABLE IF EXISTS #first_
DROP TABLE IF EXISTS #second_
DROP TABLE IF EXISTS #third_
*/
