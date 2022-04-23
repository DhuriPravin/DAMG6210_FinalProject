ALTER TABLE Payment DROP CONSTRAINT fk_payment_cartid;
DROP TABLE Cart;
DROP TABLE Reviews;
DROP TABLE Orderline;
DROP TABLE SupplyChain;
DROP TABLE Vendor;
DROP TABLE Product;
DROP TABLE Category;
ALTER TABLE Shipments DROP CONSTRAINT fk_shipments_orderid;
ALTER TABLE Orders DROP CONSTRAINT fk_shipmentsID;
DROP TABLE Shipments;
DROP TABLE Orders;
DROP TABLE Payment;
DROP TABLE Customer;

DROP PROCEDURE sp_createCustomer
DROP PROCEDURE sp_fetchRevenue_ForGivenMonthandYear
DROP PROCEDURE sp_getCategoryType

DROP SYMMETRIC KEY EncryptionKey;
DROP CERTIFICATE EncryptionCert;
DROP MASTER KEY;

DROP TABLE VendorAudit
DROP TABLE ProductAudit
DROP TRIGGER vendorHistory
DROP TRIGGER  productHistory

DROP FUNCTION [dbo].udf_calculateProductsPayment
DROP FUNCTION [dbo].udf_calculateProductProfit
DROP FUNCTION [dbo].udf_calculateAge







GO
SELECT * FROM Customer;
GO
SELECT * FROM Orders;
GO
SELECT * FROM Shipments;
GO
SELECT * FROM Category;
GO
SELECT * FROM Product;
GO
SELECT * FROM Vendor;
GO
SELECT * FROM SupplyChain;
GO
SELECT * FROM Orderline;
GO
SELECT * FROM Reviews;
GO
SELECT * FROM Cart;
GO
SELECT * FROM Payment;