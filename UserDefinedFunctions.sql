
-----/** User Defined Function (UDF) to implement Computed Column on Table Cart to calculate amount of each product by passing its price and quantity  **/-------------
GO
CREATE FUNCTION udf_calculateProductsPayment(@quantity INT, @productPrice INT)
RETURNS INT
AS
BEGIN
    RETURN @quantity * @productPrice
END
GO


ALTER TABLE Cart ADD amount AS [dbo].udf_calculateProductsPayment(quantity, productPrice) ;

select * from Cart


-----/** User Defined Function (UDF) to implement Computed Column on Table Product to calculate profit by giving purchase price and selling price **/-------------
GO
CREATE FUNCTION udf_calculateProductProfit (@purchasePrice INT, @sellingPrice INT)
RETURNS INT
AS
BEGIN
    RETURN  @sellingPrice - @purchasePrice
END

GO
ALTER TABLE product ADD profit as [dbo].udf_calculateProductProfit(purchasePrice, sellingPrice) ;

SELECT * from Product


-----/** User Defined Function (UDF) to implement Computed Column on Customer to calculate age by passing Birthdate **/-------------
GO
CREATE FUNCTION udf_calculateAge (@dob DATETIME)
RETURNS INT
AS
BEGIN
    RETURN  DATEDIFF(hour,@dob,GETDATE())/8766
END

ALTER TABLE customer ADD age as [dbo].udf_calculateAge(birthdate) ;

select * from customer
