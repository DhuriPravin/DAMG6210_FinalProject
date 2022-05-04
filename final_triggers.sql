USE ORMS_copy;

/*-- Non Cluseted index on Table shipments on Columns  orderID,customerID --*/
Create NonClustered index IX_Shipments_ids on shipments(orderID, customerID);
/*-- Non Cluseted index on Table Supplychain on Columns  productID,vendorID --*/
Create NonClustered index IX_Supplychain_ids on Supplychain(productID, vendorID);
/*-- Non Cluseted index on Table Customer on Columns  email,userName --*/
Create NonClustered index IX_Customer_email on Customer(email ASC, userName ASC);
/*-- Non Cluseted index on Table Orderline on Columns  productID,customerID --*/
Create NonClustered index IX_Orderline_ids on Orderline(orderID, productID, customerID);



CREATE TABLE [dbo].[VendorAudit]
(
    [VendorAuditID] [int] IDENTITY(1,1) NOT NULL,
    [vendor_id] [char](4) NOT NULL,
    [vendor_name] [varchar](25) NOT NULL,
    [vendor_address] [varchar](25) NULL,
    [Action] [char](1) NULL,
    [ActionDate] [datetime] NULL,
    PRIMARY KEY CLUSTERED 
(
 [VendorAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*-- Trigger to insert record into VendorAudit table when vendor table is changed --*/
CREATE TRIGGER vendorHistory ON [dbo].[Vendor]
 FOR UPDATE
AS
BEGIN
    INSERT INTO  VendorAudit
        (
        [vendor_id]
        ,[vendor_name]
        ,[vendor_address]
        ,[Action]
        ,[ActionDate]
        )
    SELECT [vendorID]
     , [vendorName]
     , [vendorAddress]
     , 'U' as [action]
     , getdate()
    FROM inserted

END



/*-- ProductAudit Table to insert data when productHistory trigger is initiated  --*/
 CREATE TABLE [dbo].[ProductAudit]
(
    [productAuditID] [int] IDENTITY(1,1) NOT NULL,
    [productID] [int] NOT NULL,
    [productName] [varchar](100) NOT NULL,
    [oldSellingPrice] [int] NOT NULL,
    [newSellingPrice] [int] NOT NULL,
    [Action] [char](1) NULL,
    [ActionDate] [datetime] NULL,
    PRIMARY KEY CLUSTERED 
(
 [ProductAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*-- Trigger to insert record into ProductAudit table when Product table is changed --*/
CREATE TRIGGER productHistory ON [dbo].[Product]
 FOR UPDATE
AS
BEGIN
    INSERT INTO  [ProductAudit]
        (
        [productID]
        ,[productName]
        ,[oldSellingPrice]
        ,[newSellingPrice]
        ,[Action]
        ,[ActionDate]
        )
    SELECT i.[productID]
     , i.[productName]
     , d.[sellingPrice]
	 , i.[sellingPrice]
     , 'U' as [action]
     , getdate()
    FROM deleted d join inserted i on i.productID = d.productID

END




GO
CREATE VIEW TotalSales
AS
    SELECT YEAR(orderDate) [year],
        MONTH(orderDate) [month],
        SUM(payment) totalSales
    FROM Orders
    WHERE orderDate IS NOT NULL
    GROUP BY MONTH(orderDate), YEAR(orderDate);

--Calculates the Extended Price, the discounted total for each line item (order detail) in all orders, using data from the Order Details and Products tables :
GO
CREATE VIEW ExtendedPrice
AS
    SELECT
        ol.orderID, ol.productID, p.productName, p.sellingPrice, ol.quantity,
        (p.sellingPrice * ol.quantity) AS ExtendedPrice
    FROM Product p
        INNER JOIN [Orderline] ol
        ON p.productID = ol.productID
--ORDER BY ol.orderID;


--The Sales by Category query summarizes sales data ($ figures) for all products, sorted by category, using data from three tables (Products, Orders, and Order Details) and the Order Details Extended query
GO
CREATE VIEW SalesByCategory
AS
    SELECT c.categoryID, c.categoryType, p.productName, Sum(o.payment) AS ProductSales
    FROM Category c
        INNER JOIN (Product p
        INNER JOIN (Orders o
        INNER JOIN Orderline ol
        ON o.orderID = ol.orderID)
        ON p.productID = ol.productID )
        ON c.categoryID = p.categoryID
    GROUP BY c.categoryID, c.categoryType, p.productName
--ORDER BY c.categoryType;

--Find the order id, order amount and date and time of ordering, feedback date (this 15 days after the order has been shipped), arranged in ascending order by feedback date.
GO
CREATE VIEW FeedbackDate
AS
    SELECT
        o.orderID,
        o.orderDate,
        o.payment,
        DATEADD(Day,15,shipmentDate) As 'Feedback_date'
    FROM Shipments s
        JOIN Orders o
        ON s.orderID = o.orderID
--ORDER BY DATEADD(Day,15,shipmentDate);

GO
CREATE VIEW TotalBilling
AS
    SELECT RANK() OVER(ORDER BY COUNT(o.OrderID) DESC) AS [CustomerRank],
        o.customerID, c.name, COUNT(o.orderID) AS [Total Orders of Customer],
        SUM(ca.productPrice) AS [Total Billing Amt of each Customer]
    FROM Orders o INNER JOIN Customer c ON
o.customerID = c.customerID INNER JOIN Cart ca ON o.customerID = ca.customerID
    GROUP BY o.customerID, c.name;

GO
CREATE VIEW QuantityCheck
AS
    SELECT c.customerID, c.name, s.orderID, pro.quantity
    FROM
        (
SELECT orderID, quantity
        FROM Orderline
        GROUP BY orderID, quantity
        HAVING SUM(quantity) > 10
) pro
        INNER JOIN Shipments s ON pro.orderID = s.orderID AND
            s.shipmentStatus = 'SHIPPED'
        INNER JOIN
        (
SELECT DISTINCT customerID,
            [name]
        FROM
            Customer
) c ON s.customerID = c.customerID
--ORDER BY c.customerID;

GO
CREATE VIEW StockAvail
AS
    SELECT productID, productQuantityAvail,
        CASE
WHEN productQuantityAvail = 0 THEN 'Out of stock'
WHEN productQuantityAvail BETWEEN 1 and 10 THEN 'Low stock'
WHEN productQuantityAvail BETWEEN 11 and 30 THEN 'In stock'
WHEN productQuantityAvail > 31 THEN 'Enough stock'
END AS stockStatus
    FROM Product;
GO









-----/** User Defined Function (UDF) to implement Computed Column on Table Cart to calculate amount of each product by passing its price and quantity  **/-------------
GO
CREATE FUNCTION udf_calculateProductsPayment(@quantity INT, @productPrice DECIMAL(18,2))
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN @quantity * @productPrice
END
GO


ALTER TABLE Cart ADD amount AS [dbo].udf_calculateProductsPayment(quantity, productPrice) ;




-----/** User Defined Function (UDF) to implement Computed Column on Table Product to calculate profit by giving purchase price and selling price **/-------------
GO
CREATE FUNCTION udf_calculateProductProfit (@purchasePrice INT, @sellingPrice INT)
RETURNS INT
AS
BEGIN
    RETURN  (@sellingPrice - @purchasePrice)
END

GO
ALTER TABLE product ADD profit as [dbo].udf_calculateProductProfit(purchasePrice, sellingPrice) ;




-----/** User Defined Function (UDF) to implement Computed Column on Customer to calculate age by passing Birthdate **/-------------
GO
CREATE FUNCTION udf_calculateAge (@dob DATETIME)
RETURNS INT
AS
BEGIN
    RETURN  DATEDIFF(hour,@dob,GETDATE())/8766
END
GO

GO
ALTER TABLE customer ADD age as [dbo].udf_calculateAge(birthdate) ;
GO
