--- SQL-7. ders_09.06.2022(session-6)

---SET OPERATIONS

--Birden fazla sorgunun tek bir sorgu sonucu olarak gözükmesi(Buna python da append diyebilirsiniz)
-- 2 farklý sorgunun kesiþimi, birleþimi vs gibi düþünebilirsiniz
-- Satýrlarý alt alta gelecek þekilde birleþtirmek, aralarýndaki farký almak için
    -- Veri tipleri ayný olmalý
    -- Sütun sayýlarý ayný olmalý
    -- Bütün iþlemleri yaptýktan sonra ORDER BY ý  kullanabiliyoruz(VIEW de de izin vermiyordu mesela)

------------------------------------
--1.UNION
-- Ýki veri setini alt alta eklemeye yarar
-- Karþýmýza çýkan veri seti DISTINCT bir veri setidir. Ayný satýrdan 1 den fazla olmaz
-- ÖRNEK: SELECT emp_id, first_name, last_name, job_title from employees_A UNION SELECT emp_id, first_name, last_name, job_title from employees_B;
/*
TABLE_A      TABLE_B     TABLE_A UNION TABLE_B      
  A            C                    A
  B            D                    B
  C            E                    C
                                    D
                                    E

*/
------------------

-- SORU: Charlotte þehrindeki müþterilerle aurora þehrindeki müþterilerin soyisimlerini listeleyin
-- Normalde set operater kullanmadan da yapabiliriz ama biz burada göstermek için kullanacaðýz

SELECT last_name FROM sale.customer WHERE city ='Charlotte'  --- 49 rows
UNION
SELECT last_name FROM sale.customer WHERE city ='Aurora'     --- 79 rows

-- SONUÇ: 105 rows geldi. UNION sorgu sonucunda DISTINCT bir küme döndürdü
-- NOT: Sorgu sonucu sýralý olarak geldi. SQL server da bir sorguda DISTINCT uygulandýðýnda bu oluyor


-- Sütun ismi deðiþirse? 
SELECT last_name FROM sale.customer WHERE city ='Charlotte'  --- 49 rows
UNION
SELECT last_name soyisim FROM sale.customer WHERE city ='Aurora'     --- 79 rows

-- Deðiþkenlerin sýrasý ve sayýsý önemli, sütun ismini deðiþtirdiðimizde UNION ýn üstündeki sütun ismini baz alýr

-----------------------------

-- SORU:Çalýþanlarýn ve müþterilerin e-posta unique olacak þekilde listeleyiniz.
SELECT email FROM sale.staff     -- 10 rows
UNION
SELECT email FROM sale.customer  -- 2000 rows

-- 2004 rows

------------------------------------------
-- 2.UNION ALL
-- UNION gibi alt alta ekler ancak DISTINCT uygulamaz
-- ÖRNEK: SELECT emp_id, first_name, last_name, job_title from employees_A UNION ALL SELECT emp_id, first_name, last_name, job_title from employees_B;
/*
TABLE_A      TABLE_B     TABLE_A UNION ALL TABLE_B      
  A            C                    A
  B            D                    B
  C            E                    C
                                    C
                                    D
                                    E

*/
-- UNION ALL Duplicate yaptý. UNION dan farký bu. DISTINCT yapmadýðý için performansý ve hýzý daha iyi
-- Ancak unique deðerler istersek UNION kullanmalýyýz

---------------------------

-- SORU: Müþterilerin içinde Thomas isminde olanlar veya soyismi thomas olanlarý getirelim
SELECT first_name FROM sale.customer WHERE first_name ='Thomas'       -- 10 rows
UNION ALL
SELECT last_name soyisim FROM sale.customer WHERE last_name ='Thomas'  -- 27 rows

-- 37 rows


-------------------------------
-- 3.INSERSECT
-- iki tabloyu karþýlaþtýrýp 2 tablo sonucunda ortak(Kesiþim) olaný döndürüyor

/*
TABLE_A      TABLE_B     TABLE_A UNION TABLE_B      
  A            B                    B
  B            D                    D
  D            E                    
*/
-----------------------

-- SORU:brand ý getir, 2018 yýlýnda herhangi bir ürünü ve 2019 yyýlýnda herhangi bir ürünü olsn

-- Not INNER JOIN yerine altta tablo arasýna virgül koyarak yazabiliyorduk
SELECT A.brand_id, B.brand_name FROM product.product A, product.brand B
WHERE a.brand_id = b.brand_id AND a.model_year = 2018   -- 177 rows
INTERSECT
SELECT A.brand_id, B.brand_name FROM product.product A, product.brand B
WHERE a.brand_id = b.brand_id AND a.model_year = 2019   -- 140 rows

--35 rows. NOT: Toplamda 40 marka vardý

-----------------------
-- Dersin 2. bölümü

-- SORU: 2018,2019 ve 2020 de sipariþ veren müþterilerim?(Her 3 yýlda da sipariþ veren müþteriler)
SELECT A.first_name, A.last_name FROM sale.customer A, sale.orders B
WHERE A.customer_id = B.customer_id AND
		YEAR(B.order_date) = 2018   -- 635 rows
INTERSECT
SELECT A.first_name, A.last_name FROM sale.customer A, sale.orders B
WHERE A.customer_id = B.customer_id AND
		YEAR(B.order_date) = 2019   -- 688 rows
INTERSECT
SELECT A.first_name, A.last_name FROM sale.customer A, sale.orders B
WHERE A.customer_id = B.customer_id AND
		YEAR(B.order_date) = 2020   -- 292 rows
        
-- 14 rows

-- Üstteki sorguda müþterilerin yaptýklarý sipariþleri görüntüleyelim
select	*
from
	(
	select	A.first_name, A.last_name, B.customer_id
	from	sale.customer A , sale.orders B
	where	A.customer_id = B.customer_id and
			YEAR(B.order_date) = 2018
	INTERSECT
	select	A.first_name, A.last_name, B.customer_id
	from	sale.customer A, sale.orders B
	where	A.customer_id = B.customer_id and
			YEAR(B.order_date) = 2019
	INTERSECT
	select	A.first_name, A.last_name, B.customer_id
	from	sale.customer A , sale.orders B
	where	A.customer_id = B.customer_id and
			YEAR(B.order_date) = 2020
	) A, sale.orders B
where	a.customer_id = b.customer_id and Year(b.order_date) in (2018, 2019, 2020)
order by a.customer_id, b.order_date
;


-- HOCA: Serdar ve Heagle hocanýn sorularýna cevap verelim EXCEPT' e geçmeden önce 
-- SORU: AURORA VE CHARLOTTE  da YAÞAYAN KÝÞÝLERÝN SOYISIMLERÝ bu þehirlerde ayný soyisimli kiþiler yaþýyor olabilir

SELECT last_name FROM sale.customer WHERE city ='Charlotte'
INTERSECT
SELECT last_name FROM sale.customer WHERE city ='Aurora'
---- 9 rows
-----

SELECT email FROM sale.staff
INTERSECT
SELECT email FROM sale.customer

---- Boþ

----------------------------------------------
-- 4.EXCEPT
-- A kümesinde olup B kümesinde olmamayan
/*
TABLE_A      TABLE_B     TABLE_A EXCEPT TABLE_B      
  A            B                    A
  B            C                    
  C            D                   
  */

-- SORU: 2018 de olan 2019 da olmayan brandleri getiriniz

SELECT A.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
    AND A.model_year = 2018
EXCEPT
SELECT A.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
    AND A.model_year = 2019;
    
-- 2 rows. Sadece 2 marka bu þarta uyuyor.

--------------------------------------------

-- SORU: sadece 2019 da sipariþ verilen diðer yýllarda sipariþ verilmeyen ürünleri getiriniz

SELECT C.product_id, D.product_name FROM
(
SELECT B.product_id FROM sale.orders A, sale.order_item B
WHERE Year(A.order_date) = 2019 AND A.order_id = B.order_id
EXCEPT
SELECT B.product_id FROM sale.orders A, sale.order_item B
WHERE Year(A.order_date) <> 2019 AND A.order_id = B.order_id
) C, product.product D
WHERE C.product_id = D.product_id

-- 5 rows. Nested query ile product tablosunu birleþtirip product_name i de getirdik

------------------------------------

-- SORU:brand ý getir, 2018 yýlýnda herhangi bir ürünü ve 2019 yyýlýnda herhangi bir ürünü olsn DEMÝÞTÝK INTERSECT te
--Þimdi  Bunlarýn dýþýnda kalan 5 ürünü bulmak istiyoruz

select	brand_id, brand_name
from	product.brand
except
select	*
from	(
		select	A.brand_id, B.brand_name
		from	product.product A, product.brand B
		where	a.brand_id = b.brand_id and
				a.model_year = 2018
		INTERSECT
		select	A.brand_id, B.brand_name
		from	product.product A, product.brand B
		where	a.brand_id = b.brand_id and
				a.model_year = 2019
		) A

--------------------------

-- product_id ye göre 2019 yýlýnda sipariþ verilen diðer yýllarda sipariþ verilmeyen ürünler
-- Bunu except ile yaptýk. Bunu pivot table baþka bir çýktýya bakalým. O 5 tane þart gösterdiðimiz de geldi
-- .. burada product_id ye göre bir nevi indexleme yaparak bunu da görüyoruz

SELECT *
FROM
			(
			SELECT	b.product_id, year(a.order_date) OrderYear, B.item_id
			FROM	SALE.orders A, sale.order_item B
			where	A.order_id = B.order_id
			) A
PIVOT
(
	count(item_id)
	FOR OrderYear IN
	(
	[2018], [2019], [2020], [2021]
	)
) AS PIVOT_TABLE
order by 1


----------------------------------------------
-- 5.CASE Expression
-- Yeni bir sütun oluþtururken baþka bir sütunu referans gösteriyorsak kullanýyoruz
-- Yeni sütunda, örneðin departmanda DS e , "Data science", diðerlerine "others" yazdýrsýn gibi...

-------------------------------------------
--A.SIMPLE CASE
/*
CASE case_expression
     WHEN ...
     WHEN ...
     end give_table_name
from	table_1
*/
--------------------

--- SORU: Generate a new columns containing what the mean of the values in the Order_Status column
--- 1.Pending 2.Processing 3.Rejected, 4.Completed
select	order_id, order_status,
		case order_status
			when 1 then 'Pending'
			when 2 then 'Processing'
			when 3 then 'Rejected'
			when 4 then 'Completed'
		end order_status_desc
from	sale.orders

-- order_status =1 ise bunu "Pending", 2 ise "Processing", 3 ,se 'Rejected', 4 se 'Completed' olarak yaz..
-- NOT: Bu kalýcý bir deðiþiklik yapmýyor tablolarda
-- DDL kodlarýyla tablomuza yeni alan ekleriz sonra bu sorguyla update ederiz bu deðerler veritabanýmýzda kalýr
------------------------------------

--------------------------------
--- SORU: Add a column to sale.staff table containing the store names of the employees
--- Bunu normalde kendimiz staff ve store kullanarak alabiliriz ama bunu CASE ile yapalým
--- 1.Davi techno Retail; 2.The BFLO Store 3.Burkes Outlet
SELECT first_name, last_name, store_id,
	CASE store_id
		WHEN 1 THEN 'Davi techno Retail'
		WHEN 2 THEN 'The BFLO Store'
		WHEN 3 THEN 'Burkes Outlet'
	END AS store_name
FROM sale.staff
-- Bu simple case di  sonra searched case e geçeceðiz
-- Burada 1 deðiþken var buna eþitliðine bakýyoruz 1 ise þunu yap, 2 ise þunu yap vs gibi
-- searched case de 0 ile 1000 arasýndaysa þu, 1000 ile 2000 arasýnysa þu ya da detaylý koþul varsa search case yapýyoruz


---------------
--B.SEARCHED CASE

--- SORU: Generate a new columns containing what the mean of the values in the Order_Status column
--- 1.Pending 2.Processing 3.Rejected, 4.Completed
select	order_id, order_status,
		case
			when order_status = 1 then 'Pending'
			when order_status = 2 then 'Processing'
			when order_status = 3 then 'Rejected'
			when order_status = 4 then 'Completed'
			else 'other'
		end order_status_desc
from	sale.orders
;

--- Bu "WHEN" kýsýmlarý Boolean bir deðer döndürüyor gibi düþünebiliriz
--- Baþka bir alternatif yok ama olsaydý else 'other' yazdýrarak diðerlerine "other" yazdýrabilirdik

----------------------------

-- SORU:  MüþterilERÝN e-mail adreslerindeki servis saðlayýcýlarýný yeni bir sütun oluþturarak belirtiniz.
--  gmail ise gmail, hotmail ise hotmail, yahoo ise yahoo, ... ,  diðerleri ise "other" yazdýralým

SELECT first_name, last_name,email,
	CASE
		WHEN email LIKE '%gmail%' THEN 'Gmail'
		WHEN email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN email LIKE '%yahoo%' THEN 'Yahoo'
		ELSE 'Other'
	END AS email_service_provider
FROM sale.customer

-- '%gmail%'  : içinde gmail geçiyorsa
-- msn, outlook, aol gibi uzantýlar 'other' a döndü

-- Not: oluþturduðumuz email_service_provider deðiþkeni/sutünu bir yerde oluþmadý. Kalýcý deðil bu sorgu sonucu

--------------------------

-- Soru: Ayný sipariþte hem mp4 player, hem Computer Accessories hem de Speakers kategorilerinde ürün sipariþ veren müþterileri bulunuz.
-- Önce bu kategoriler veritabanýnda nasýl yazýlýyor bakalým
select * from product.category
---'Computer Accessories'
---'Speakers'
---'mp4 player'

Select * from product.category A, product.product B, sale.order_item C
WHERE A.category_name in ('Computer Accessories','Speakers','mp4 player') AND
A.category_id = B.category_id AND
    B.product_id = C.product_id

--- Eðer set operationlarý kullansaydýk farklý 
--- her bir order_id için belirtilen ürünlerden en az 1 tane almýþ olmasýna bakýyorum
--- her bir order_id ye göre gruplama yapacaðýz
--- Sonra herbir order_id içinden farklý category id sini saydýracaðým

select	c.order_id, count(distinct a.category_id) uniqueCategory
from	product.category A, product.product B, sale.order_item C
where	A.category_name in ('Computer Accessories', 'Speakers', 'mp4 player') AND
		A.category_id = B.category_id AND
		B.product_id = C.product_id
group by C.order_id
having	count(distinct a.category_id) = 3
;

--- her bir order_id için bir sonuç geldi.
--- 1: Tek kategoryden sipariþ verilmiþ
--- 2: 2 farklý kategoryden sipariþ verilmiþ
----3: --> Bize bu 3 lazým bunu da HAVING ile belirttik
--- Bir de bu sipariþi veren kiþilerin isim soyisimleri alalým. Bunu nested query yapýp isimleri getirelim
--- sipariþ nodan sipariþi veren kiþilere gideceðiz 

--- sipariþ veren müþterileri bulalým
select	C.first_name, C.last_name
from	(
		select	c.order_id, count(distinct a.category_id) uniqueCategory
		from	product.category A, product.product B, sale.order_item C
		where	A.category_name in ('Computer Accessories', 'Speakers', 'mp4 player') AND
				A.category_id = B.category_id AND
				B.product_id = C.product_id
		group by C.order_id
		having	count(distinct a.category_id) = 3
		) A, sale.orders B, sale.customer C
where	A.order_id = B.order_id AND
		B.customer_id = C.customer_id
;

------------------------

--Yukardaki sonucu baþka nasýl alabilirdik
--- hoca gönderecek

