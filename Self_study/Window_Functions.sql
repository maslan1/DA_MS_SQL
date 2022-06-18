select	product_id, category_id, list_price,
		ROW_NUMBER() over(partition by category_id order by list_price ASC) RowNum
from	product.product
order by 2, 3
;
-- Aynı soruyu aynı fiyatlı ürünler aynı sıra numarasını alacak şekilde yapınız (RANK fonksiyonunu kullanınız)
-- Lets try previous query again using DENSE_RANK() function.
select	product_id, category_id, list_price,
		ROW_NUMBER() over(partition by category_id order by list_price ASC) RowNum,
		RANK() over(partition by category_id order by list_price ASC) RowNum_rank,
		DENSE_RANK() over(partition by category_id order by list_price ASC) RowNum_dense_rank
from	product.product
order by 2, 3
;
--1. Herbir model_yili içinde ürünlerin fiyat sıralamasını yapınız (artan fiyata göre 1'den başlayıp birer birer artacak)
-- row_number(), rank(), dense_rank()
select	 product_id, model_year,category_id, list_price,
		ROW_NUMBER() over(partition by model_year order by list_price ASC) RowNum,
		RANK() over(partition by model_year order by list_price ASC) RowNum_rank,
		DENSE_RANK() over(partition by model_year order by list_price ASC) RowNum_dense_rank
from	product.product
order by 2, 3
;
--Alternatif cözüm --
SELECT product_id, model_year,list_price,
		ROW_NUMBER() OVER(PARTITION BY model_year ORDER BY list_price ASC) RowNum,
		RANK() OVER(PARTITION BY model_year ORDER BY list_price ASC) RankNum,
		DENSE_RANK() OVER(PARTITION BY model_year ORDER BY list_price ASC) DenseRankNum
FROM product.product; 
--
-- Write a query that returns the cumulative distribution of the list price in product table by brand.

-- product tablosundaki list price' ların kümülatif dağılımını marka kırılımında hesaplayınız

SELECT brand_id, list_price,
		ROUND(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price),3)
		  CUM_DIST

FROM product.product
--
SELECT brand_id, list_price,
		ROUND(percent_rank() OVER(PARTITION BY brand_id ORDER BY list_price),3)
		  CUM_DIST

FROM product.product
---- Write a query that returns the cumulative distribution of the list price in product table by brand.
-- product tablosundaki list price' ların kümülatif dağılımını marka kırılımında hesaplayınız
SELECT brand_id, list_price,
		round(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS CUM_DIST
FROM product.product
--


with tbl as (
	select	brand_id, list_price,
			count(*) over(partition by brand_id) TotalProductInBrand,
			row_number() over(partition by brand_id order by list_price) RowNum,
			rank() over(partition by brand_id order by list_price) RankNum
	from	product.product
)
select *
from tbl

-- Yukarıdaki sorguda CumDist alanını CUME_DIST fonksiyonunu kullanmadan hesaplayınız.
with tbl as (
	select	brand_id, list_price,
			count(*) over(partition by brand_id) TotalProductInBrand,
			row_number() over(partition by brand_id order by list_price) RowNum,
			rank() over(partition by brand_id order by list_price) RankNum
	from	product.product
)
select *,
	round(cast(RowNum as float) / TotalProductInBrand, 3) CumDistRowNum,
	round((1.0*RankNum / TotalProductInBrand), 3) CumDistRankNum
from tbl

--
--Write a query that returns both of the followings:
--The average product price of orders.
--Average net amount.


--Aşağıdakilerin her ikisini de döndüren bir sorgu yazın:
--Siparişlerin ortalama ürün fiyatı.
--Ortalama net tutar.
select DISTINCT order_id,
		AVG(list_price) over(partition by order_id) Avg_price ,
		AVG(list_price * quantity* (1-discount)) over() Avg_net_amount 
from sale.order_item
	
----List orders for which the average product price is higher than the average net amount.
--Ortalama ürün fiyatının ortalama net tutardan yüksek olduğu siparişleri listeleyin.
WITH temporary_table AS (
	SELECT DISTINCT order_id,
		AVG(list_price) OVER(PARTITION BY order_id) Avg_price,
		AVG(list_price*quantity*(1-discount)) OVER() Avg_net_amount
	from sale.order_item
)
SELECT *
FROM temporary_table
WHERE Avg_price > Avg_net_amount
;
 -------------------------------------------------
WITH temp_table AS
(SELECT 
	DISTINCT order_id, 
	AVG(list_price) OVER(PARTITION BY order_id ) avg_price,
	AVG(list_price * quantity* (1-discount)) OVER() avg_net_amount
FROM 
	sale.order_item)

SELECT *
FROM temp_table
WHERE avg_price > avg_net_amount

--Alternatif cözüm --
--List orders for which the average product price is higher than the average net amount.
--Ortalama ürün fiyatının ortalama net tutardan yüksek olduğu siparişleri listeleyin.
select distinct order_id, a.Avg_price,a.Avg_net_amount
from (
	select *,
	avg(list_price*quantity*(1-discount))  over() Avg_net_amount,
	avg(list_price)  over(partition by order_id) Avg_price
	from [sale].[order_item]
) A
where  a.Avg_price > a.Avg_net_amount
order by 2
;
------------------------------------------------
--Calculate the stores' weekly cumulative number of orders for 2018
--mağazaların 2018 yılına ait haftalık kümülatif sipariş sayılarını hesaplayınız

select distinct ss.store_id, ss.store_name,--so.order_date,
	datepart(ISO_WEEK, so.order_date) week_of_year,	
	COUNT(*) OVER(PARTITION BY ss.store_id,datepart(ISO_WEEK, so.order_date)) weeks_order,
	COUNT(*) OVER(PARTITION BY ss.store_id order by datepart(ISO_WEEK, so.order_date)) cume_total_order
	from sale.store ss, sale.orders so 
where ss.store_id = so.store_id and year(order_date) = 2018
order by 1,3

	--ROW_NUMBER() over(partition by store_id ) week_of_year
	--Count (order_id) over (partition by week(order_date) weeks_order

--Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.
--'2018-03-12' ve '2018-04-12' arasında satılan ürün sayısının 7 günlük hareketli ortalamasını hesaplayın.
with tbl as (
	select	B.order_date, sum(A.quantity) SumQuantity --A.order_id, A.product_id, A.quantity
	from	sale.order_item A, sale.orders B
	where	A.order_id = B.order_id
	group by B.order_date
)
select	*,
	avg(SumQuantity) over(order by order_date rows between 6 preceding and current row) sales_moving_average_7
from	tbl
where	order_date between '2018-03-12' and '2018-04-12'
order by 1
----------------------------------------------------------------
--Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.
--'2018-03-12' ve '2018-04-12' arasında satılan ürün sayısının 7 günlük hareketli ortalamasını hesaplayın.
with tbl as (
	select	B.order_date, sum(A.quantity) SumQuantity --A.order_id, A.product_id, A.quantity
	from	sale.order_item A, sale.orders B
	where	A.order_id = B.order_id
	group by B.order_date
)
select	*,
	avg(SumQuantity*1.0) over(order by order_date rows between 6 preceding and current row) sales_moving_average_7
from	tbl
where	order_date between '2018-03-12' and '2018-04-12'
order by 1
-- eksik tarihler
--
with tbl as (
	select	B.order_date, sum(A.quantity) SumQuantity --A.order_id, A.product_id, A.quantity
	from	sale.order_item A, sale.orders B
	where	A.order_id = B.order_id
	group by B.order_date
)
select	*
from	(
	select	*,
		avg(SumQuantity*1.0) over(order by order_date rows between 6 preceding and current row) sales_moving_average_7
	from	tbl
) A
where	A.order_date between '2018-03-12' and '2018-04-12'
order by 1
-----------------------------------------------------------------------------------------------------------------------------