


---------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 13 --
----------- 22.06.2022 ----------------
---------------------------------------


--Basit Procedure Syntaxı
create procedure sp_sampleproc1
AS 

begin
select 'Hello World!'
end
;

--Proceduru cağırma yöntemleri:
EXECUTE sp_sampleproc1;
EXEC sp_sampleproc1;


-- Database de bulunan (önceden create edilmiş) bir prosedürü silme syntax ı
drop procedure sp_sampleproc1;
;


create procedure sp_sampleproc1
AS 
begin
select 'Hello World!'
end
;

-- var olan bir prosedürü yenisiyle değiştirme için: ALTER PROCEDURE
alter procedure sp_sampleproc1
AS 
begin
select 'Hello World 3 !'
end
;

EXECUTE sp_sampleproc1
;

-- Dersimizde kullanacağımız bir tablo create ediyoruz.
CREATE TABLE ORDER_TBL 
(
ORDER_ID TINYINT NOT NULL,
CUSTOMER_ID TINYINT NOT NULL,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE--estimated delivery date
);

-- Create ettiğimiz tabloya birkaç satır veri girişi yapıyoruz.
INSERT INTO ORDER_TBL VALUES (1, 1, 'Adam', GETDATE()-10, GETDATE()-5 ),
						(2, 2, 'Smith',GETDATE()-8, GETDATE()-4 ),
						(3, 3, 'John',GETDATE()-5, GETDATE()-2 ),
						(4, 4, 'Jack',GETDATE()-3, GETDATE()+1 ),
						(5, 5, 'Owen',GETDATE()-2, GETDATE()+3 ),
						(6, 6, 'Mike',GETDATE(), GETDATE()+5 ),
						(7, 6, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 7, 'Johnson',GETDATE(), GETDATE()+5 )
;

-- Tablomuza bakalım veriler insert edilmiş mi?
select	*
from	ORDER_TBL

-- İkinci bir tablo create ediyoruz.
CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- tamamlanan delivery date
);

-- Birkaç satır veri girişi yapıyoruz
SET NOCOUNT ON
INSERT ORDER_DELIVERY VALUES (1, GETDATE()-6 ),
				(2, GETDATE()-2 ),
				(3, GETDATE()-2 ),
				(4, GETDATE() ),
				(5, GETDATE()+2 ),
				(6, GETDATE()+3 ),
				(7, GETDATE()+5 ),
				(8, GETDATE()+5 )
;


-- Toplam sipariş sayısını döndüren bir prosedür create edelim.
-- Prosedürü her çalıştırdığımızda ORDER_TBL tablosunun son halindeki toplam satır sayısını döndürecektir.
CREATE PROCEDURE sp_sum_order
AS

BEGIN
	SELECT	COUNT(*) AS TOTAL_ORDER
	FROM	ORDER_TBL
END
;

-- BEGIN / END ifadeleri sql sorgularının başladığınız ve bittiğini belirtmek için kullanılır.
-- Sanki bir parantez aç/kapa gibi düşünebilirsiniz.


EXECUTE sp_sum_order;

-- Belli bir tarihteki toplam sipariş sayısını döndüren başka bir prosedür create edelim.
-- Bu durumda istenen tarihi input parametresi olarak prosedüre göndermemiz gerekiyor.
-- parametre ile çalışan proc örneği.
-- istenilen güne ait order sayısını getirecek procedure
-- Burada @DAY procedure parametresidir = girdi parametresi
create PROCEDURE sp_wantedday_order
	(
	@DAY DATE
	)
AS

BEGIN
	SELECT	COUNT(*) AS TOTAL_ORDER
	FROM	ORDER_TBL
	WHERE	ORDER_DATE = @DAY
	;
END
;

-- Parametre istenen prosedürlerde parametreler prosedür adından sonra yazılır.
EXECUTE sp_wantedday_order '2022-06-22';


-- DECLARE ile parametre tanımlama ve parametrelere veri atama
-- sorgu parametreleri
-- Declare ile tanımlanır. data type belirlenir, değer de atanabilir.
-- set veya select ile değer atanır.
-- bu değişkenler sabit olmayan, farklı durumlara göre değişebilecek ve sorgu sonucuna etki edebilecek nitelikteki değerler için belirlenir.
-- örneğin aşağıda @p1 ve @p2 parametreleri bizim vereceğimiz değere göre değişebilir.
-- @sum parametresi ise @p1 ve @p2 ye göre değişebilir.
DECLARE @P1 INT, @P2 INT, @SUM INT

SET @P1 = 5

SELECT @P2 = 4

SELECT @SUM = @P1+@P2

SELECT @SUM
;

-- Yukarıdaki DECLARE örneğinde bulunan parametrelerin DECLARE bloğunda tanımlandığını, SET ya da SELECT ile değer atandığını unutmayın.
-- En son satırda ise @SUM parametresi yazdırılmaktadır.
-- Dolayısıyla bu satırların tamamını ondan sonra Execute etmelisiniz.


-- Başka bir DECLARE örneği:
-- Order_id parametresine göre customer_name i başka bir parametreye atama ve son olarak bu parametreyi dönderme:
DECLARE 
	@order_id INT,
	@customer_name nvarchar(100)

SET @order_id = 5

SELECT @customer_name = customer_name
from ORDER_TBL
where order_id = @order_id

select @customer_name
;



-- Yukarıda tanımlanan sp_wantedday_order prosedürüne parametre olarak bugünün tarihini ya da dünün tarihini göndermek istersek aşağıdaki gibi yapabiliriz:
declare
	@day date

set @day = getdate()-2

EXECUTE sp_wantedday_order @day
;



-- FONKSIYONLAR

---SCALAR VALUED FUNC

--Sonuçta tek bir değer getirir. 
--Getirilen değer, farklı yerlerde kullanılabilir, istenilen yerde fonksiyon çağırılabilir.
--Fonksiyonlar aldığı input parametreye göre bir sonuç üretir veya input parametre üzerinde bir değişiklik yapar.

-- Metni büyük harfe çeviren bir fonksiyon yazalım
CREATE FUNCTION fnc_uppertext
(
	@inputtext varchar (MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN UPPER(@inputtext)
END
;

SELECT dbo.fnc_uppertext('hello world');



--table valued function

-- Bize From statement' ta tablo gibi kullanabileceğimiz bir tablo oluşturur.
-- Store proceduru bir tablo olarak kullanamayız. Sadece çalıştırıp sonucu alırız.
-- table valued functions bize SP'lerden farklı olarak tabloları kullanabilme imkanı sunar.
-- Birçok işlem silsilesi sonucunda ulaştığımız bir tabloyu aslında fonksiyon olarak kaydeder.
-- fonksiyonu çalıştırdığımızda arkada tüm işlemler çalışıp bize tablo olarak geri döner.

-- Müşteri adını parametre olarak alıp o müşterinin alışverişlerini döndüren bir fonksiyon yazınız.

alter function fnc_getordersbycustomer
(
@CUSTOMER_NAME NVARCHAR(100)
)
RETURNS TABLE 
AS
	return 
		select	*
		from	ORDER_TBL
		where	CUSTOMER_NAME = @CUSTOMER_NAME
;

SELECT	*
FROM	dbo.fnc_getordersbycustomer('Owen')
;





--IF, ELSE IF, ELSE YAPILARI
--sorgu sonucunun bazı durumlara veya parametrenin bazı değerlerine göre değişebileceği durumlarda
--bu kriterleri if else yapılarıyla tanımlarız.
--Aşağıda Customer_id' nin 3 ten küçük olma durumuna göre veya
--Customer_id' nin 3 ten büyük olma durumuna göre veya
--Customer_id' nin 3  olmaksı durumuna göre getirilecek değerlerin değişmesini istediğimizde kullanacağımız scripti görüyorsunuz.
DECLARE @CUST_ID INT

	SET @CUST_ID = 3

	IF @CUST_ID < 3
		BEGIN
			SELECT *
			FROM
			ORDER_TBL
			WHERE
			CUSTOMER_ID = @CUST_ID
		END
	ELSE IF @CUST_ID > 3
		BEGIN
			SELECT *
			FROM
			ORDER_TBL
			WHERE
			CUSTOMER_ID = @CUST_ID		
		END
	ELSE
		PRINT 'THE CUSTOMER ID EQUAL TO 3'
;



-- Bir fonksiyon yaziniz. Bu fonksiyon aldığı rakamsal değeri çift ise Çift, tek ise Tek döndürsün. Eğer 0 ise Sıfır döndürsün.
create FUNCTION dbo.fnc_tekcift
(
	@input int
)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE
		-- @input int,
		@modulus int,
		@return nvarchar(max)

	-- SET @input = 100

	SELECT @modulus = @input % 2 


	IF @input = 0
		BEGIN
		 set @return = 'Sıfır'
		END
	ELSE IF @modulus = 0
		BEGIN
		 set @return = 'Çift'
		END
	ELSE set @return = 'Tek'

	return @return
	
END
;

-- Create ettiğimiz fonksiyonu şimdi kullanalım
select dbo.fnc_tekcift(100) A, dbo.fnc_tekcift(9) B, dbo.fnc_tekcift(0) C

-- Fonksiyon ya da prosedür create ederken ilk olarak rastgele seçtiğiniz sabit değerlere göre sorgunuzu oluşturunuz.
-- Sorgunuz tam olarak çalışıyor ve isteneni veriyorsa artık bu sabit değerler yerine sırasıyla parametre atayınız.
-- Parametreleri de atadıktan sonra artık fonksiyon ya da prosedür create etme scriptlerini yazabilirsiniz.


-- WHILE
-- döngü oluşturmak için kullanılır
-- while statement' ta yazdığımız koşul sağlanana kadar sorgunun tekrar tekrar çalıştırılmasını sağlar.
-- döngüyü tekrar ettirecek bir mantıksal işleme de gerek duyar bu da genelde sorgu sonunda yazılır.
-- SQL Server da for döngüsü yoktur.
DECLARE
	@counter int,
	@total int

set @counter = 1
set @total = 50

while @counter <= @total
	begin
		PRINT @counter
		set @counter += 1
	end
;





--Siparişleri, tahmini teslim tarihleri ve gerçekleşen teslim tarihlerini kıyaslayarak
--'Late','Early' veya 'On Time' olarak sınıflandırmak istiyorum.
--Eğer siparişin ORDER_TBL tablosundaki EST_DELIVERY_DATE' i (tahmini teslim tarihi) 
--ORDER_DELIVERY tablosundaki DELIVERY_DATE' ten (gerçekleşen teslimat tarihi) küçükse
--Bu siparişi 'LATE' olarak etiketlemek,
--Eğer EST_DELIVERY_DATE>DELIVERY_DATE ise Bu siparişi 'EARLY' olarak etiketlemek,
--Eğer iki tarih birbirine eşitse de bu siparişi 'ON TIME' olarak etiketlemek istiyorum.

--Daha sonradan siparişleri, sahip oldukları etiketlere göre farklı işlemlere tabi tutmak istiyorum.

--istenilen bir order' ın status' unu tanımlamak için bir scalar valued function oluşturacağız.
--çünkü girdimiz order_id, çıktımız ise bir string değer olan statu olmasını bekliyoruz.


create FUNCTION dbo.fnc_orderstatus
(
	@input int
)
RETURNS nvarchar(max)
AS
BEGIN

	declare
		@result nvarchar(100)

	-- set @input = 1

	select	@result = 
				case
					when B.DELIVERY_DATE < A.EST_DELIVERY_DATE
						then 'EARLY'
					when B.DELIVERY_DATE > A.EST_DELIVERY_DATE
						then 'LATE'
					when B.DELIVERY_DATE = A.EST_DELIVERY_DATE
						then 'ON TIME'
				else NULL end
	from	ORDER_TBL A, ORDER_DELIVERY B
	where	A.order_id = B.order_id AND
			A.order_id = @input
	;

	return @result
end
;

-- Bu fonksiyonu şu şekilde çağırabiliriz.
select	dbo.fnc_orderstatus(3)
;

-- Ya da order tablosundaki herbir order ın yanına fonksiyon sonucunun yazılmasını istiyorsanız şu şekilde de çalıştırabilirsiniz:
select	*, dbo.fnc_orderstatus(ORDER_ID) OrderStatus
from	ORDER_TBL
;