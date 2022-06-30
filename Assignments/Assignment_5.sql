CREATE FUNCTION dbo.Factorial(@fNum int)
RETURNS INT
AS
BEGIN
DECLARE @f int
    IF @fNum <= 1
        SET @f = 1
    ELSE
        SET @f = @fNum * dbo.Factorial(@fNum - 1)
RETURN (@f)
END;

SELECT dbo.Factorial(6) AS Factorial;