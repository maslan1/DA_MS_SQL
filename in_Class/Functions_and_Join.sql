
SELECT TRIM(' CHARACTER');

SELECT ' CHARACTER';

SELECT GETDATE();

SELECT TRIM(' CHARACTER ')

SELECT TRIM( ' CHAR ACTER ')

SELECT TRIM('ABC' FROM 'CCCCBBBAAAFRHGKDFKSLDFJKSDFACBBCACABACABCA')

SELECT TRIM('X' FROM 'ABCXXDE')

SELECT LTRIM ('     CHARACTER ')


SELECT RTRIM ('     CHARACTER ')

SELECT REPLACE('CH ARA CT  ER STR ING', ' ', '/')


SELECT REPLACE('CHARACTER STRING', 'CHARACTER STRING', 'CHARACTER')

SELECT REPLACE('CHA   RACTER     STR   ING', ' ', '/')

SELECT STR (5454)

SELECT STR (2135454654)

SELECT STR (2135454654)

SELECT STR (133215.654645, 11, 2)

-- 11 karakter olacak, virgülden sonra 2 karakter kullanilacak

--CAST  -CONVERT

SELECT CAST (12345 AS CHAR)

SELECT CAST (123.65 AS INT)

SELECT CONVERT(int, 30.60)

SELECT CONVERT (VARCHAR(10), '2020-10-10')

SELECT CONVERT (DATETIME, '2020-10-10' )

SELECT CONVERT (NVARCHAR, GETDATE(),112 ) -- cast e göre avantaji var

SELECT CAST ('20201010' AS DATE)

SELECT COALESCE(NULL, 'Hi', 'Hello', NULL)

SELECT NULLIF (20,25)

SELECT isnull(NULLIF (10,10),20)

SELECT CONVERT (NVARCHAR, CAST ('20201010' AS DATE),103 )

SELECT 'customer' + '_' + CAST(1 AS VARCHAR(1)) AS col;

SELECT NULLIF ('Hellomda', 'Hello')

SELECT ROUND (432.368, 2, 2.5)

SELECT ISNULL(NULL, 'ABC')

SELECT ISNULL('', 'ABC')

SELECT ISNULL('', 'ABC')

select ISNUMERIC(123)

select ISNUMERIC('abs')

SELECT ISNUMERIC(123)
SELECT ISNUMERIC(STR(123))

SELECT	A.product_id, A.product_name,
		B.category_id, B.category_name
FROM	product.product AS A
INNER JOIN product.category AS B
on A.category_id = B.category_id

SELECT staff.first_name, staff.last_name, store.store_name
FROM sale.staff
INNER JOIN sale.store
ON staff.store_id = store.store_id

SELECT A.first_name, A.last_name, B.store_name
from sale.staff AS A 
inner join sale.store AS B 
on A.store_id = B.store_id

SELECT	a.first_name, a.last_name, 
		b.store_name
FROM	sale.staff as a
INNER JOIN	sale.store as b
		ON a.store_id=b.store_id

select	A.product_id, A.product_name, B.order_id
from	product.product A
left join sale.order_item B
on	A.product_id = B.product_id
where	B.order_id is null

SELECT A.product_id,A.product_name,B.store_id,B.product_id,B.quantity
FROM product.product A
left join product.stock B
on A.product_id = B.product_id
where A.product_id > 310 ;

-- right join
select	B.product_id, B.product_name, A.*
from	product.stock A
right join product.product B
	ON	A.product_id = B.product_id
where	B.product_id > 310

-- FULL OUTER JOIN --- Ürünlerin stok miktarları ve sipariş bilgilerini birlikte listeleyin
SELECT top 100 A.product_id,B.quantity,  B.store_id, C.order_id, C.list_price
from product.product A
FULL outer join product.stock B
on A.product_id = B.product_id
FULL OUTER JOIN sale.order_item C 
on A.product_id = C.product_id
ORDER BY B.store_id

-- FULL OUTER JOIN
select	top 100 A.product_id, B.store_id, B.quantity, C.order_id, C.list_price
from	product.product A
FULL OUTER JOIN product.stock B
ON		A.product_id = B.product_id
FULL OUTER JOIN sale.order_item C
ON		A.product_id = C.product_id
order by B.store_id
-----
--stock tablosunda olmayıp product tablosunda mevcut olan ürünlerin stock tablosuna tüm storelar için kayıt edilmesi gerekiyor. 
--stoğu olmadığı için quantity leri 0 olmak zorunda
--Ve bir product id tüm store' ların stockuna eklenmesi gerektiği için cross join yapmamız gerekiyor.

SELECT	B.store_id, A.product_id, 0 quantity
FROM	product.product A
CROSS JOIN sale.store B
WHERE	A.product_id NOT IN (SELECT product_id FROM product.stock)
ORDER BY A.product_id, B.store_id
