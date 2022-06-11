--Session-7--
--select clause--
select order_id,
		list_price,
		(SELECT AVG(list_price)
		FROM sale.order_item
		) AS avg_price

		FROM sale.order_item
--where clause--
select	order_id, order_date
from	sale.orders
where	order_date in (
					select top 5 order_date
					from	sale.orders
					order by order_date desc
					)
;

--from clause-- 
-- alias zorunlu 
select	order_id, order_date
from	(
		select	top 5 *
		from	sale.orders
		order by order_date desc
		) A

-- her bir order_id icin toplam lis_price getiren Query yaziniz--
select 	so.order_id,
		
		(
		select	 sum(list_price)
		from	sale.order_item
		where	order_id=so.order_id
		) AS sum_price
from	sale.order_item so
group by so.order_id
-- Davis Thomas'nın çalıştığı mağazadaki tüm personelleri listeleyin.
select	*
from	sale.staff
where	store_id = (
					select	store_id
					from	sale.staff
					where	first_name = 'Davis' and last_name = 'Thomas'
					)
;

-- Charles Cussona 'ın yöneticisi olduğu personelleri listeleyin.
select	*
from	sale.staff
where	manager_id = (
					select	staff_id
					from	sale.staff
					where	first_name = 'Charles' and last_name = 'Cussona'
					)
;
-- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' isimli üründen pahalı olan ürünleri listeleyin.
-- Product id, product name, model_year, fiyat, marka adı ve kategori adı alanlarına ihtiyaç duyulmaktadır.
select A.product_id, a.product_name, a.model_year, a.list_price, b.brand_name, c.category_name
from product.product A, product.brand B, product.category C
where list_price >
	(select list_price
	from product.product
	where product_name='Pro-Series 49-Class Full HD Outdoor LED TV (Silver)')
	and A.brand_id = B.brand_id
	and A.category_id = C.category_id
;
--Alternatif cözüm--
--- SELECT	product_id, product_name, model_year, list_price
FROM	product.product
WHERE	list_price >	(
						SELECT list_price
						FROM product.product
						WHERE product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'
						);

------------------------------------------------------------------------------------------------
--Laurel Goldamer isimli müsterinin alisveris yaptigi tarihlerde alisveris yapan tüm müsterileri bulunuz 

SELECT *
FROM sale.customer AS SC, sale.orders AS SO
WHERE order_date IN (
				SELECT SO.order_date
				FROM sale.customer AS SC, sale.orders AS SO
				WHERE first_name = 'Laurel' AND last_name='Goldammer'
				AND SC.customer_id=SO.customer_id)
				AND SC.customer_id=SO.customer_id;
--Main solution
SELECT *
FROM sale.customer AS SC, sale.orders AS SO
WHERE order_date IN (
				SELECT SO.order_date
				FROM sale.customer AS SC, sale.orders AS SO
				WHERE first_name = 'Laurel' AND last_name='Goldammer'
				AND SC.customer_id=SO.customer_id
				)
				AND SC.customer_id=SO.customer_id
				AND SO.order_status = 4
;

-------------------------------------------------------------------
SELECT *
FROM product.product
WHERE model_year = 2021 AND category_id NOT IN(SELECT category_id
FROM product.category
WHERE category_name IN ('Game', 'gps', 'Home Theater'))

--Alternatif Cözüm--

select	*
from	product.product
where	model_year = 2021 and
		category_id NOT IN (
						select	category_id
						from	product.category
						where	category_name in ('Game', 'GPS', 'Home Theater')
						)
;
-- 2020 model olup Receivers Amplifiers kategorisindeki en pahalı üründen daha pahalı ürünleri listeleyin.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız.


select	*
from	product.product
where	model_year = 2020 and
		list_price > (
			select	max(B.list_price)
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
		)

--Alternatif cözüm--
select *
from	product.product
where	model_year = 2020 and
		list_price > ALL (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
			)
-- LISTE FIYATI yukardakilerin herhangi birinden yüksek olanlarin listesini bulunuz--
-- Receivers Amplifiers kategorisindeki en pahalı üründen daha pahalı olan ürünlerin
--model yılı 2020 olanlarını listeleyin.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız. *
select *
from	product.product
where	model_year = 2020 and
		list_price > ANY (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
)
