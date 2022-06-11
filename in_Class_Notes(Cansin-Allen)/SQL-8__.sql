--%% SQL-8. ders_11.06.2022(session-7)

--%% Subqueries
-- SUBQUERIES/INNER QUERY/NESTED QUERY

-- Subquery, baþka bir query içerisinde bir parantez içinde tanýmlanmýþ alt query dir
-- Select bloðunda, where bloðunda ve from bloðunda kullanabiliyoruz. Sonuç tablo mu, deðer mi olduðuna göre kullaným yeri deðiþmektedir
-- FROM da olursa--> tablo döndürür
-- SELECT, WHERE --> tablo veya value dönebilir

-- SELECT
select order_id, list_price,
(select avg(list_price) from product.product) AS avg_price
from sale.order_item

-- Tek bir deðer kullandýðým için select bloðunda kullandým
-- Sonuçta bütün satýrlarda ayný deðerin dönmesini istiyorsak select bloðu içerisinde kullanabiliriz subquery yi

-----------------
-- WHERE 
Select order_id, order_date from sale.orders
where order_date IN (select TOP 5 order_date from sale.orders ORDER BY order_date DESC) 

-- Sipariþin verildiði son 5 gün

-- Eðer ayný tarihler gelmiþ olsaydý, tekilleþtirmek isteseydik;
select Top 5 order_date from 
(Select distinct order_date from sale.orders) A
where order_date IN (select TOP 5 order_date from sale.orders ORDER BY order_date DESC) 

------------------

-- FROM 
SELECT order_id, order_date from
(select top 5 * from sale.orders order by order_date desc) A

-- FROM bloðunda tanýmlanan subqueries lerde "Alias" olmalý
-- Alias istedi ancak kullanmamýza gerek kalmadý, Çünkü from bloðundan sadece 1 adet order_id sütunu dönüyor 
-- Eðer from bloðundan ikinci bir order_id sütunu dönseydi hangi tabloyu kastettiðimizi belirtmek için kullanmamýz gerekirdi


-- Types of subqueries
-- 1.Single-row Subqueries(Yukarda yaptýðýmýz gibi, liste fiyat ortalamasýný döndüren)
-- 2.Multiple- row subqueries
-- 3.Correlated subqueries(inner query ile outer query arasýnda iliþki kuruyorsak)
    -- Correlated subquery çok performanslý deðil, çok kullanýlmýyor, djoinlerle daha iyi sonuçlar geliyor

-- Single-row Subqueries : Bir sütun bir hücre döndürüyor
    -- Karþýlaþtýrma yapacaðýmýz deðerler arasýnda =,>,>=,<= gibi karþýlaþtýrma araçlarý kullanýyoruz
    -- where ve select ile kullanýlabiliyor
    -- Bir çok query joinle kullanýlabiliyor. Hangi durumda daha anlamlý bir query yazacaksa ihtiyaca göre


--%% Dersin 2. bölümü
-- Soru: Her bir order_id ye göre toplam fiyat
select	so.order_id,
		(select	sum(list_price) sum_list_price from sale.order_item
		where order_id=so.order_id
		) AS sum_price
from	sale.order_item so
group by so.order_id

--- select so.order_id  ... from sale.order_item so  order_id  : order id leri seç
--- select	sum(list_price) sum_list_price from sale.order_item: her bir satýrda subquerydeki list_price ýn toplamýný getir
--- ancak where order_id=so.order_id olduðu durumda bunu yap
--- group by so.order_id : order id ye göre grupla

-- list_price neden hem product tablosunda hem de order_item da var?
-- product tablosunda her bir ürüne ait fiyat var. Fiyat deðiþirse eski fiyat gidip yenisi gelecek ve bilgi kaybý olacak
-- Her bir ürünün sipariþ verildiði gündeki fiyatýný bilmemiz gerekiyorsa o order_item tablosunda tutuluyor. Yani bilgi
-- .. kaybedilmemiþ oluyor(Yani eski fiyatý order_item tablosundan istediðimde görebilirim)

---- NOT: Sub query olmadan aþaðýdaki gibi de yapýlabilirdi
select	order_id, sum(list_price) avg_list_price
from	sale.order_item
group by order_id

--------------------------
--NOT
--iKÝSÝ ARASINDAKÝ FARKIN NEDENLERÝNIN MANTIKSAL AÇIKLAMASI ???
--1. KOD
SELECT  B.order_id, (SELECT SUM(list_price*quantity*(1-discount)) FROM sale.order_item WHERE order_id = B.order_id ) AS TOTAL
FROM sale.order_item B
GROUP BY B.order_id
--2. KOD
SELECT  order_id, (SELECT SUM(B.list_price*B.quantity*(1-B.discount)) FROM sale.order_item B WHERE B.order_id = order_id ) AS TOTAL
FROM sale.order_item
GROUP BY order_id

-- 2 kod arasýndaki tek fark alias kullanýlmasý 2. tabloda alias kullanýlmamýþ
-- 1. sorguda subqueries de order_item dan sum(list_pirce* quantity*(1-discount)) hesaplanmýþ
-- .. where order_id = B.order_id : Buradaki order_id tek deðer o yüzden alias kullanmama gerek yok, Burdaki B.order_id yi
-- .. diðer tablodan çekiyor
-- 2. tabloda sbuquery deki tabloya alias verilmiþ
-- Where B.order_id = order_id : Buradaki B.order_id , from sale.order_item B den gelen , bu subquery içerisinde olduðu için
-- .. 2. tabloda subquery hata vermez ama 1. tabloda B tablosu olmadýðý için hata veriyor
-- 1. subqueries, 2. subquery gibi tek bir deðer döndürüyor ama 1. subquery 2. subquery ye baðlý

-----------------------------
-- soru :Davis Thomas'nýn çalýþtýðý maðazadaki tüm personelleri listeleyin

select	*
from	sale.staff
where	store_id = (
					select	store_id
					from	sale.staff
					where	first_name = 'Davis' and last_name = 'Thomas'
					)

-- subquery -- davis thomas ýn çalýþtýðý store_id

--- alternatif çözüm
select *
from (
    select store_id
    from sale.staff
    where first_name = 'Davis' and last_name= 'Thomas'
) as a, sale.staff b
where a.store_id = b.store_id

------------------------------------
--- Soru: Charles Cussona nýn manager ý olduðu kiþileri listeleyin
select	*
from	sale.staff
where	manager_id = (
					select	staff_id
					from	sale.staff
					where	first_name = 'Charles' and last_name = 'Cussona'
					)

-- Staff_id ye karþýlýk gelen baþka bir id var. Bu sütun manager_id
-- charles ýn manager ý olduðu kiþileri bulmam için charles ýn id sini buldum. 2 imiþ
--- sonra manager_id si 2 olanlara bakacaðýz
-- manager_id  = :  manager_id si sale.staff dan  where first_name = 'Charles' and last_name = 'Cussona' þartýný
-- saðlayan ý getirdik

--------------------------------------------
-- Soru: -- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' isimli üründen pahalý olan ürünleri listeleyin.
-- Product id, product name, model_year, fiyat, marka adý ve kategori adý alanlarýna ihtiyaç duyulmaktadýr
select A.product_id, a.product_name, a.model_year, a.list_price, b.brand_name, c.category_name
from product.product A, product.brand B, product.category C
where list_price >
	(select list_price
	from product.product
	where product_name='Pro-Series 49-Class Full HD Outdoor LED TV (Silver)')
	and A.brand_id = B.brand_id
	and A.category_id = C.category_id

-- Önce ürünümüzü product tablosundan bulmamýz lazým. Bunu subquery de buldum, list_price ýný seçtim
-- subquery outer query den baðýmsýz.
-- Bizden istenen sütunlarý da select ten sonra yazalým
-- En son o tablolarý hangi tablodan aldýysam
-- NOT: where list_price : liste fiyatý sadece A tablosundan döneceði için A.list_price yazmadýk

--- Alternatif çözüm
SELECT * 
from product.product
where list_price > (
    select list_price
    from product.product
    where product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'
)

--%% Dersin 3. bölümü
-- Multiple-row Subqueries
-- Tek fark; Sonuç olarak birden fazla satýr dönmesi. O yüzden direk büyüktür, küçüktür gibi
--.. operatörler kullanamayýz direkt olarak
-- Içindedir, içinde deðildir, herhangi birinden büyüktür/küçüktür gibi þeyler yapacaðýz

-- Soru: List all customers who orders on the same dates as Laurel Goldammer
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

--- Subquery ile outer query arasýnda bir iliþki tanýmlamadýk
-- Burada subquey tek baþýna çalýþýyor çünkü subquey içinden SO.order_date veya SC.customer_id yazarken
--- SO ve SC ile tablolarý subquery içinde tanýmlandýðý için hata veremiyoruz
--- Önce Laurel Goldammer alýþveriþ yaptýðý tarihleri istiyorum.
-- Önce customer tablosundan isim buluyorum, sipariþ bilgileri orders tablosunda
-- hangi müþterinin hangi tarihlerde alýþveriþ yaptýðýný alttaki sorgu sonucunda elde ettim
--- select * from sale.customer A, sale.orders B where A.customer_id = B.customer_id
-- Bütün müþterilerden Laurel goldammer ý seçiyoruz  WHERE first_name = 'Laurel' AND last_name='Goldammer'
-- Bu subqueyden bir satýr dönseydi eþittir operatörü kullanacaktýk ama burada eþittir kullanamayacaðým
-- O yüzden burada "IN" operatörünü kullandýk.
--- WHERE order_date IN: outer query de bu tarihlerden(subquery sonuçlarýndan) herhangi birisi olmalý
--- AND SO.order_status = 4 : Alýþveriþi tamamlayanlar

---------------------------------------------
-- Soru: List products made in 2021 and their categories other than Game, gps or Home Theater
-- 2021 yýlýnda yapýlmýþ olan kategorileri  Game, gps or Home Theater dýþýnda olanlar   
--- 2 küme olacak 1.2021 yýlýnda üretilen ürünler 2.kategori tablomuz

select	*
from	product.product
where	model_year = 2021 and
		category_id NOT IN (
						select	category_id
						from	product.category
						where	category_name in ('Game', 'GPS', 'Home Theater')
						)

------ Alternatif yol : NOT IN yerin IN ,  IN yerinde NOT IN getirerek yapabiliriz
select	*
from	product.product
where	model_year = 2021 and
		category_id IN (
						select	category_id
						from	product.category
						where	category_name NOT in ('Game', 'GPS', 'Home Theater')
						)

------------------------------------
--- Soru: List products made in 2020 and its prices more than "all" products in the Receivers Amplifiers category
-- Ürün adý, model_yýlý ve fiyat bilgilerini yüksek fiyattan düþük fiyata doðru sýralayýnýz.

--- 1. yol -- maximum liste fiyatýný çekip 
select	*
from	product.product
where	model_year = 2020 and list_price >
(select	max(B.list_price)
 from	product.category A, product.product B
				where	A.category_name = 'Receivers Amplifiers' And
                        A.category_id = B.category_id
						)   ---  A.category_name = 'Receivers Amplifiers' deki en pahalý fiyat

---- 2. yol -- Eðer subquery tek deðer döndürmüyorsa , IN, NOT IN , > ALL vs gibi þeyler kullanýyoruz

select * from	product.product
where	model_year = 2020 and
		list_price > ALL (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
			)

--- Burada çoklu satýr döndürür subquery o yüzden ">" operatörünü kullanamayýz. "> ALL" kullanmalýyýz
--- Subquery den dönen bütün hepsinden büyük mü diye bakýyor.(97.13 den , 105 den büyük mü vs mi diye bakýyor)
-- 6 ürünümüz , bizim ürünümüzün bulunduðu kategorideki bütün ürünlerin fiyatlarýndan büyük
--- ALL () : Subquery içinden dönen tüm deðerlerden büyük olan

------------------------------------------
--- Soru: List products made in 2020 and its prices more than "any" products in the Receivers Amplifiers category

--- 1. yol -- minimum liste fiyatýný çekip 
select	*
from	product.product
where	model_year = 2020 and list_price >
(select	min(B.list_price)
 from	product.category A, product.product B
				where	A.category_name = 'Receivers Amplifiers' And
                        A.category_id = B.category_id
						)   ---  A.category_name = 'Receivers Amplifiers' deki en pahalý fiyat

--- 2. yol
select * from	product.product
where	model_year = 2020 and
		list_price > ANY (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
			)

--- bizim ürünümüzün categorysindeki minimum fiyatý baz almamýz lazým bunu "> ALL" yerine "> ANY" yazarak saðlayabiliriz
--- ANY () : Subquery içinden dönen herhangi bir deðerlerden büyük olan

--- Burada SON 2 örnekte yukarda ki çözümlerden 1. yolu kullanmamýz performans açýsýndan daha iyi olacaktýr
--- Bu bir text verisi ise ya da farklý tablolardan gelen UNION lardan oluþan bir veri setiyse
--- Yani group by la bir deðer çýkartmanýn mümkün olmadýðý durumlarda 2. yolu kullanmalýydýk

--- Common Table Expressions -- BIR SONRAKI DERS