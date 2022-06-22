/*
===== Session-13 (22 Jun 22) SQL Programming with T-SQL ========
*/

/* =================== Pre-Class ====================== */

USE Instructors
;

-- create a procedure
CREATE PROCEDURE sp_FirstProc AS
BEGIN
	SELECT 'Welcome to procedural world.' AS message
END
;

EXECUTE sp_FirstProc
;

ALTER PROCEDURE sp_FirstProc AS
BEGIN	
	PRINT 'Hello SQL enhusiasts!'
END
;

EXECUTE sp_FirstProc
;

DROP PROCEDURE sp_FirstProc
;

SELECT *
FROM	departments
;

-- ////// creating a procedure //////

-- Create a procedure that takes one input parameter and returns one output parameter and a return code.

CREATE PROCEDURE sp_SecondProc @name varchar(20), @salary INT OUTPUT
AS
BEGIN

-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM departments
WHERE name = @name

-- Returns salary of @name
RETURN @salary
END
GO

-- /////  call/execute the procedure  //////

-- Declare the variables for the output salary.
DECLARE @salary_output INT

-- Execute the stored procedure and specify which variable are to receive the output parameter.
EXEC sp_SecondProc @name = 'Eric', @salary = @salary_output OUTPUT

-- Show the values returned.
PRINT CAST(@salary_output AS VARCHAR(10)) + '$'
GO

--run all of these together

-- /////  modify the procedure  //////

ALTER PROCEDURE sp_SecondProc @name varchar(20) = 'Jack', @salary INT OUTPUT
AS
BEGIN

-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM departments
WHERE name = @name

-- Returns salary of @name
RETURN @salary
END
GO

-- ///// Variables /////

DECLARE @myfirstvar INT;

DECLARE @LastName NVARCHAR(20), @FirstName NVARCHAR(20), @State NCHAR(2);

-- QUERY

--Declare a variable
DECLARE @Var1 VARCHAR(5)
DECLARE @Var2 VARCHAR(20)

--Set a value to the variable with "SET"
SET @Var1 = 'MSc'

--Set a value to the variable with "SELECT"

SELECT @Var2 = 'Computer Science'

--Get a result by using variable value
SELECT *
FROM departments
WHERE graduation = @Var1
AND dept_name = @Var2
;

/*  Note: If a SELECT statement returns more than one row and the variable references a non-scalar expression, 
the variable is set to the value returned for the expression in the last row of the result set. */

--Declare a variable
DECLARE @Var1 bigint

--Set a value to the variable with "SELECT"
SELECT @Var1 = id
FROM departments

--Call the variable
SELECT @var1 AS last_id;

-- ///// IF Statements /////

IF DATENAME(weekday, GETDATE()) IN (N'Saturday', N'Sunday')
       SELECT 'Weekend' AS day_of_week;
ELSE 
       SELECT 'Weekday' AS day_of_week;

/* In the query above, If statement checks if today is saturday or sunday. 
If today is saturday or sunday, Query returns "Weekend", If not returns "Weekday". */ 


IF 1 = 1 PRINT 'Boolean_expression is true.'  
ELSE PRINT 'Boolean_expression is false.' ;

/* In the query above, If statement checks "1 = 1" equality. 
If the equality is confirmed, Query returns the first message, 
If not returns the second message. */

-- ///// WHILE Loops /////

-- syntax
WHILE Boolean_expression   
     { sql_statement | statement_block | BREAK | CONTINUE };  

-- example: We'll give a limit for the while loop, and we want to break the loop when the variable divisible by 3

-- Declaring a @count variable to delimited the while loop.
DECLARE @count as int

--Setting a starting value to the @count variable
SET @count=1

--Generating the while loop

WHILE  @count < 30 -- while loop condition
BEGIN  	 	
	SELECT @count, @count + (@count * 0.20) -- Result that is returned end of the statement.
	SET @count +=1 -- the variable value raised one by one to continue the loop.
	IF @count % 3 = 0 -- this is the condition to break the loop.
		BREAK -- If the condition is met, the loop will stop.
	ELSE
		CONTINUE -- If the condition isn't met, the loop will continue.
END;


-- ///// User Defined Functions /////

-- Scalar-Valued Function Example:

-- create user-defined function
CREATE FUNCTION dbo.ufnGetAvgSalary(@seniority VARCHAR(15))  
RETURNS BIGINT   
AS   
	BEGIN  
		DECLARE @avg_salary BIGINT
	
		SELECT @avg_salary = AVG(salary)
		FROM departments   
		WHERE seniority = @seniority   
 
		RETURN @avg_salary  
	END; 

-- call the function
SELECT dbo.ufnGetAvgSalary('Senior') as avg_salary;

-- Table-Valued Function Example-1:

-- create user-defined function
CREATE FUNCTION dbo.dept_of_employee (@dept_name VARCHAR(15))  
RETURNS TABLE  
AS  
RETURN   
(  
	SELECT id, name, salary
	FROM departments
	WHERE	dept_name=@dept_name
); 

-- call the function
SELECT * FROM dbo.dept_of_employee('Music');

-- Table-Valued Function Example-2:

-- create user-defined function
CREATE FUNCTION dbo.raised_salary (@name varchar(20))  
RETURNS @raised_salary TABLE   
(  
    id BIGINT,  
    name NVARCHAR(20),  
    raised_salary BIGINT 
)  
AS  
BEGIN  
	INSERT @raised_salary
	SELECT id, name, salary + (salary * 0.20)
	FROM departments
	WHERE name = @name
RETURN
END;

-- call the function
SELECT * FROM dbo.raised_salary('Eric');



/* =================== In-Class ====================== */

-- ///////////////// SQL Programming //////////////////////

-- *** Stored Procedures ***

CREATE PROCEDURE sp_sampleproc1
AS
	BEGIN
		SELECT	'Hello World!'
	END
;

EXEC sp_sampleproc1;

DROP PROCEDURE sp_sampleproc1;

ALTER PROCEDURE sp_sampleproc1
AS
	BEGIN
		SELECT 'Hello world! 3'
	END;

EXEC sp_sampleproc1;

--@allen
DROP PROCEDURE IF EXISTS hello
GO

CREATE OR ALTER PROCEDURE hello
as
SELECT 'Hello MSSQL'
GO

EXECute hello
GO

-- Example: Procedures

CREATE TABLE ORDER_TBL 
(
ORDER_ID TINYINT NOT NULL,
CUSTOMER_ID TINYINT NOT NULL,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE--estimated delivery date
);

INSERT INTO ORDER_TBL VALUES (1, 1, 'Adam', GETDATE()-10, GETDATE()-5 ),
						(2, 2, 'Smith',GETDATE()-8, GETDATE()-4 ),
						(3, 3, 'John',GETDATE()-5, GETDATE()-2 ),
						(4, 4, 'Jack',GETDATE()-3, GETDATE()+1 ),
						(5, 5, 'Owen',GETDATE()-2, GETDATE()+3 ),
						(6, 6, 'Mike',GETDATE(), GETDATE()+5 ),
						(7, 6, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 7, 'Johnson',GETDATE(), GETDATE()+5 )
						;

SELECT	*
FROM	ORDER_TBL;

---

CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- completed delivery date
);

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
SELECT	*
FROM	ORDER_DELIVERY;

CREATE PROCEDURE sp_sum_order
AS
	BEGIN
			SELECT	COUNT(*) AS total_order
			FROM	ORDER_TBL
	END
;

EXEC sp_sum_order;

---

CREATE PROCEDURE sp_target_day_order 
	(
	@DAY DATE
	)
AS
	BEGIN
			SELECT	COUNT(*) AS total_order
			FROM	ORDER_TBL
			WHERE	ORDER_DATE = @DAY
	END
;

EXECUTE sp_target_day_order '2022-06-22';

DECLARE
	@order_id INT,
	@customer_name nvarchar(100)
	
SET @order_id = 5 --assign

SELECT	@customer_name = CUSTOMER_NAME --assign
FROM	ORDER_TBL
WHERE	ORDER_ID = @order_id

SELECT @customer_name -- display
;



EXECUTE sp_target_day_order(select cast(getdate() as date)) --this doesn't work, input statement returns table value, not single date value 
;

SELECT	GETDATE();

-- better to assign value to a parameter and then use it as input
DECLARE
	@day DATE
set @day = GETDATE()-2
EXECUTE sp_tarsp_target_day_order@day
;

-- *** Functions ***

-- Create a function to convert text to uppercase (Scalar-valued Function)

CREATE FUNCTION fnc_uppertext
(
	@inputtext varchar (MAX)
)
RETURNS VARCHAR (MAX)
AS
BEGIN
	RETURN UPPER(@inputtext)
END
;

SELECT dbo.fnc_uppertext('hello world');

-- create a function takes customer name as parameter and returns customer's orders (Table-Valued Function)

CREATE OR ALTER FUNCTION fnc_getordersbycustomer
	(
	@CUSTOMER_NAME NVARCHAR(100)
	)
RETURNS TABLE
AS
RETURN
	SELECT	*
	FROM	ORDER_TBL
	WHERE	CUSTOMER_NAME = @CUSTOMER_NAME
;


SELECT	*
FROM	dbo.fnc_getordersbycustomer('Smith')
;

-- *** If / Else ***

-- write a function that returns 'Even', 'Odd' or 0 per input

DECLARE
	@input INT,
	@modulus INT

SET @input = 58

SELECT	@modulus = @input % 2

IF @input = 0
	BEGIN
		print 'Zero'
	END
ELSE IF @modulus = 0
	BEGIN
		print 'Even'
	END
ELSE print 'Odd'

--
CREATE FUNCTION dbo.fnc_evenodd 
(
@input INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE
		@modulus INT,
		@return NVARCHAR(MAX)
	
	SELECT	@modulus = @input % 2

	IF @input = 0
		BEGIN
			set @return = 'Zero'
		END
	ELSE IF @modulus = 0
		BEGIN
			set @return = 'Even'
		END
	ELSE set @return = 'Odd'

	return @return
END
;

SELECT dbo.fnc_evenodd(12) AS A, dbo.fnc_evenodd(0) AS B, dbo.fnc_evenodd(7) AS C;

-- *** While ***

DECLARE
	@counter INT,
	@total INT

	
SET @counter = 1
SET @total = 50

WHILE @counter <= @total
	BEGIN
		PRINT @counter
		SET @counter += 1
	END
;

-- Task: Classify orders 'Early', 'On Time', 'Late' by comparing EST_DELIVERY_DATE (ORDER_TBL) and DELIVERY_DATE(ORDER_DELIVERY) and create a function that displays order status.


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
select	dbo.fnc_orderstatus(3)
;
select	*, dbo.fnc_orderstatus(ORDER_ID) AS OrderStatus
from	ORDER_TBL
;
