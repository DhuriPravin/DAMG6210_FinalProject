USE ORMS_copy;

GO
SELECT *
FROM Customer;
GO
SELECT *
FROM Orders;
GO
SELECT *
FROM Shipments;
GO
SELECT *
FROM Category;
GO
SELECT *
FROM Product;
GO
SELECT *
FROM Vendor;
GO
SELECT *
FROM SupplyChain;
GO
SELECT *
FROM Orderline;
GO
SELECT *
FROM Reviews;
GO
SELECT *
FROM Cart;
GO
SELECT *
FROM Payment;



DECLARE @revenue DECIMAL(18,2), @totalOrders INT;
EXECUTE sp_fetchRevenue_ForGivenMonthandYear 03,2020,'pending', @revenue OUTPUT, @totalOrders OUTPUT

DECLARE @categoryType varchar(50);
EXECUTE sp_getCategoryType "Nike shirt", @categoryType OUTPUT
PRINT 'Category Type : ' + @categoryType



UPDATE Vendor SET vendorAddress ='test_address' WHERE vendorID = '106'
select *
from [dbo].[VendorAudit]
select *
from [dbo].[Vendor]

UPDATE Product SET sellingPrice = 100 WHERE productID = '104'
select *
from [dbo].[ProductAudit]
select *
from [dbo].[Product]



GO
SELECT *
FROM Cart
GO
SELECT *
FROM Product
GO
SELECT *
FROM customer


--Select Views
GO
SELECT *
FROM TotalSales;
GO
SELECT *
FROM ExtendedPrice;
GO
SELECT *
FROM SalesByCategory;
GO
SELECT *
FROM FeedbackDate;
GO
SELECT *
FROM TotalBilling;
GO
SELECT *
FROM QuantityCheck;
GO
SELECT *
FROM StockAvail;
GO
