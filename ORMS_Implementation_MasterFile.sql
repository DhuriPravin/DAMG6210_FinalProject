--CREATE DATABASE ORMS
CREATE DATABASE ORMS;

GO

-- USE DATABASE ORMS
USE ORMS;

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



--Creating Table Customer
CREATE TABLE Customer
(
    customerID INT NOT NULL PRIMARY KEY IDENTITY(1000,1),
    [name] VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    userName VARCHAR(50)  NOT NULL, 
    [password] VARBINARY(MAX) NOT NULL,
    [address] VARCHAR(50) NOT NULL,
    [state] CHAR(3) NOT NULL,
    city VARCHAR(20) NOT NULL,
    zipcode INT NOT NULL,
    gender VARCHAR(50) NOT NULL,
    birthdate DATETIME NOT NULL,
    
    CONSTRAINT chk_gender CHECK (gender = 'M' OR gender = 'F'),
    CONSTRAINT chk_email CHECK (email LIKE '%@%'),
    CONSTRAINT chk_birthday CHECK (birthdate < GetDate()),
    CONSTRAINT chk_phone CHECK (phone not like '%[^0-9+-.]%'),
    CONSTRAINT chk_unique_user UNIQUE (email,userName)
)




GO

--CREATE TABLE Orders
CREATE TABLE Orders
(
    orderID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    customerID INT NOT NULL,
    shipmentID INT NULL,
    orderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending', -- Trigger Completed To-do
    payment DECIMAL(18,2) NOT NULL,
    orderDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT fk_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID),
    CONSTRAINT chk_orderdate CHECK (orderDate < GetDate())

)  

GO

--CREATE TABLE Shipments
CREATE TABLE Shipments
(
    shipmentID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    customerID INT NOT NULL,
    orderID INT NOT NULL,
    shipmentDate DATETIME NOT NULL,
    shipmentStatus VARCHAR(50) NOT NULL, -- Pending, Shipped, Delivered
    shippingVendor VARCHAR(50) NOT NULL,

    CONSTRAINT fk_shipments_orderid FOREIGN KEY(orderID) REFERENCES Orders(orderID),
    CONSTRAINT fk_shipments_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID)
)

GO

--ADD CONSTRAINT TO Orders Table
ALTER TABLE Orders
ADD CONSTRAINT fk_shipmentsid FOREIGN KEY(shipmentID) REFERENCES Shipments(shipmentID);

GO

--CREATE TABLE Category
CREATE TABLE Category
(
    categoryID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    categoryType VARCHAR(50) NOT NULL,
    categorySize VARCHAR(25),

    --CONSTRAINT chk_size CHECK (categorySize > 0)

)  

GO

--CREATE TABLE Product
CREATE TABLE Product
(
    productID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    categoryID INT NOT NULL,
    productName VARCHAR(50) NOT NULL,
    productDescription  VARCHAR(50) NULL,
    purchasePrice DECIMAL(18,2) NOT NULL, --Can be null
    sellingPrice DECIMAL(18,2) NOT NULL,
    productQuantityAvail INT NOT NULL Default 0,

    CONSTRAINT fk_categoryid FOREIGN KEY(categoryID) REFERENCES Category(categoryID)
)  

GO

--CREATE TABLE Vendor
CREATE TABLE Vendor
(
    vendorID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    vendorName VARCHAR(50) NOT NULL DEFAULT 'Unknown Vendor',
    vendorAddress VARCHAR(50) NOT NULL
)  

GO

--CREATE TABLE SupplyChain
CREATE TABLE SupplyChain
(
    supplyID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    productID INT NOT NULL,
    vendorID INT NOT NULL,
    supplyDate DATETIME NOT NULL DEFAULT GETDATE(),
    quantity INT NOT NULL,

    CONSTRAINT fk_productid FOREIGN KEY(productID) references Product(productID),
    CONSTRAINT fk_vendorid FOREIGN KEY(vendorID) references Vendor(vendorID),
    CONSTRAINT chk_quantity CHECK (quantity > 0)
)  

GO
--CREATE TABLE Orderline
CREATE TABLE Orderline
(
    orderlineID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    customerID INT NOT NULL,
    orderID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    price DECIMAL(18,2) NOT NULL,

    CONSTRAINT fk_orderline_orderid FOREIGN KEY(orderID) REFERENCES Orders(orderID),
    CONSTRAINT fk_orderline_productsid FOREIGN KEY(productID) REFERENCES Product(productID),
    CONSTRAINT fk_orderline_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID)
) 

GO
--CREATE TABLE Reviews
CREATE TABLE Reviews
(
    reviewID INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    customerID INT NOT NULL,
    productID INT NOT NULL,
    ratings INT NOT NULL,
    comments VARCHAR(150) NOT NULL,

    CONSTRAINT fk_review_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID),
    CONSTRAINT fk_review_productsid FOREIGN KEY(productID) REFERENCES Product(productID),
    CONSTRAINT chk_rating CHECK (ratings between 1 and 5)
)

GO
--CREATE TABLE Cart
CREATE TABLE Cart
(
    cartID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    customerID INT NOT NULL,
    orderID INT NOT NULL,
    quantity INT NOT NULL,
    productPrice DECIMAL(18,2) NOT NULL,
    --totalPrice computed column

    CONSTRAINT fk_cart_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID),
    CONSTRAINT fk_cart_orderid FOREIGN KEY(orderID) REFERENCES Orders(orderID)
)  

--CREATE TABLE Payment
CREATE TABLE Payment
(
    paymentID INT NOT NULL PRIMARY KEY IDENTITY(1000,1),
    customerID INT NOT NULL,
    cartID INT NOT NULL,
    orderID INT NOT NULL,
    finalAmount DECIMAL(18,2) NOT NULL,

    CONSTRAINT fk_payment_customerid FOREIGN KEY(customerID) REFERENCES Customer(customerID),
    CONSTRAINT fk_payment_orderid FOREIGN KEY(orderID) REFERENCES Orders(orderID),
    CONSTRAINT fk_payment_cartid FOREIGN KEY(cartID) REFERENCES Cart(cartID)

)



-----/** Column Level Encryption Begins **/-------------

--Creation of Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P455w0rd';   

--Creation of Certificate
CREATE CERTIFICATE EncryptionCert WITH SUBJECT = 'Certificate for column level encryption'; 

--Check if Certificate Got Created
SELECT name, pvt_key_encryption_type_desc FROM sys.certificates


--Creation of Symmetric Key
CREATE SYMMETRIC KEY EncryptionKey WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE EncryptionCert  

--Check if 2 rows exists in the symmetric key table, one is default key and the other is the one we created
SELECT name, algorithm_desc FROM sys.symmetric_keys

----Open and Close Statements of Symmetric keys to execute before performing something related to Encryption
-- OPEN SYMMETRIC KEY EncryptionKey DECRYPTION BY CERTIFICATE EncryptionCert
-- CLOSE SYMMETRIC KEY EncryptionKey

-----Sample Statements to Insert by encrypting and Fetching by Decrypting
-- INSERT INTO loginDetails VALUES  ('test','Check@23', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Check@23'))
-- SELECT  CAST(DECRYPTBYKEY(passwordEncrypted) AS VARCHAR) FROM loginDetails

-----/** Column Level Encryption Ends **/-------------







-----/** Stored Procedure to Fetch Revenue(Total Payments) and Total Orders of the Given Month, Year and Order Status(Pending, Completed) and **/-------------
Go
CREATE PROCEDURE sp_fetchRevenue_ForGivenMonthandYear
    (@month INT,
    @year INT,
    @status VARCHAR(20),
    @revenue DECIMAL(18,2) OUTPUT,
    @totalOrders INT OUTPUT)
AS
BEGIN

    IF (UPPER(@status) <> 'COMPLETED')
    BEGIN
        IF (UPPER(@status) <> 'PENDING')
        BEGIN
            PRINT 'Please Provide Valid Status!'
            RETURN;
        END
    END

    IF (@month < 1 and @month > 12)
    BEGIN
        PRINT 'Pleae Provide Valid Month!'
        RETURN;
    END

    IF (@year < 2000)
    BEGIN
        PRINT 'Pleae Provide Year Greater than 2000!'
        RETURN;
    END

    SELECT @revenue = SUM(payment), @totalOrders = COUNT(*)
    from Orders
    WHERE orderStatus=@status and MONTH(orderDate) = @month and YEAR(orderDate) = @year
    GROUP BY MONTH(orderDate)



    IF @@ROWCOUNT =0 PRINT 'No Orders in the given Month and Year!'

    ELSE PRINT ' For the Month ' +   CAST(@month AS VARCHAR)  + ', Year ' +  CAST(@year AS VARCHAR) + ' Orders Generated were: ' + CAST(@totalOrders AS VARCHAR) + ' and Total Revenue is : ' + CAST(@revenue AS VARCHAR) ;
END

DECLARE @revenue DECIMAL(18,2), @totalOrders INT;
EXECUTE sp_fetchRevenue_ForGivenMonthandYear 12,2020,'pending', @revenue OUTPUT, @totalOrders OUTPUT
PRINT @revenue
PRINT @totalOrders


-----/** Stored Procedure to Fetch Category type of the product, Given Product Name **/-------------
CREATE PROCEDURE sp_getCategoryType(@productName varchar(50),
    @categoryType varchar(50) OUTPUT)
AS
BEGIN
    Select @categoryType = C.categoryType
    from Category C
        inner join Product P on C.categoryID = P.categoryID
    WHERE @productName = P.productName;
    IF @@ROWCOUNT =0 PRINT 'Product Not Found!'
END


DECLARE @categoryType varchar(50);
EXECUTE sp_getCategoryType 'Toy car', @categoryType OUTPUT
PRINT 'Category Type : ' + @categoryType 

-----/** Stored Procedure to Insert into Customer Table, It encrypts and inserts the password field **/-------------
Go
CREATE PROC [dbo].[sp_createCustomer] (
  @customerID INT OUTPUT,
  @name VARCHAR(50),
  @phone VARCHAR(50),
    @email VARCHAR(50),
    @userName VARCHAR(50), 
    @password VARCHAR(50),
    @address VARCHAR(50),
    @state CHAR(3),
    @city VARCHAR(20),
    @zipcode INT,
    @gender VARCHAR(50),
    @birthdate DATETIME
) AS
BEGIN
    ---Opening Symmetric Key
    OPEN SYMMETRIC KEY EncryptionKey DECRYPTION BY CERTIFICATE EncryptionCert;
  
    ---Print Error if Email Already Exists
    IF EXISTS(SELECT 1 FROM Customer WHERE email = @email)
    BEGIN
        PRINT 'Email Already Exists!!'
        RETURN
    END 

    ---Print Error if User Name Already Exists
    IF EXISTS(SELECT 1 FROM Customer WHERE userName = @userName)
    BEGIN
        PRINT 'User Name Already Being Used!!'
        RETURN
    END 

    INSERT INTO Customer ([name], phone, email, userName, [password], [address], [state], [city], zipcode, gender, birthdate)
    VALUES (@name, @phone, @email, @userName, ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),@password), @address, @state, @city, @zipcode, @gender, @birthdate);

    ---Closing Symmetric Key
    CLOSE SYMMETRIC KEY EncryptionKey;
    SET @customerID = SCOPE_IDENTITY();
    IF(@@ROWCOUNT > 0)
        BEGIN
            PRINT 'Customer Created Successfully With customerID : ' + CAST(@customerID AS VARCHAR) ;
        END
    ELSE IF (@@ERROR <> 0)
        BEGIN
            PRINT 'Error Creating Customer!' ;
        END
END




---Insertion Into Customer Table-------
DECLARE @customerID INT;
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer1', '857896101', 'customer2@gmail.com', 'custUser1', 'custUser@22', 'garrison1 st', 'MA', 'Boston', 02120, 'M', '2000-01-05';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer10','857896110','customer10@gmail.com','custUser10', 'custUser@10','garrison2 st','CA','California',02122,'F','1997-01-05';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer3','857896103','customer3@gmail.com','custUser3', 'custUser@03','garrison3 st','TX','Dallas',02123,'M','1999-03-05';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer4','857896104','customer4@gmail.com','custUser4', 'custUser@04','garrison4 st','RI','Island',02124,'F','1990-04-06';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer5','857896105','customer5@gmail.com','custUser5', 'custUser@05','garrison5 st','NY','Newyork',02125,'F','1995-01-05';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer6','857896106','customer6@gmail.com','custUser6', 'custUser@06','garrison6 st','NJ','Jersey',02126,'M','1993-01-04';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer7','857896107','customer7@gmail.com','custUser7', 'custUser@07','garrison7 st','NH','Mountains',02127,'F','2003-02-03';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer8','857896108','customer8@gmail.com','custUser8', 'custUser@08','garrison8 st','WA','Washington',02128,'M','1998-03-02';
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer9','857896109','customer9@gmail.com','custUser9', 'custUser@09','garrison9 st','CT','Connecticut',02129,'F','1992-08-01';

INSERT INTO category VALUES ('Clothing','S');
INSERT INTO category VALUES ('Shoes','Uk10');
INSERT INTO category VALUES ('Jwellery','L');
INSERT INTO category VALUES ('Watches','M');
INSERT INTO category VALUES ('Textiles','U');
INSERT INTO category VALUES ('Gifts','U');
INSERT INTO category VALUES ('Sports','U');
INSERT INTO category VALUES ('Toys','L');
INSERT INTO category VALUES ('Kitchen','X');
INSERT INTO category VALUES ('Instrument','X');

INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (102,'Nike t-shirt',null,20,30);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (102,'Adidas t-shirt','T Shirt',15,25);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (106,'Ali cartoon pillow','Pillow',10,20);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (107,'Toy car',null,23,33);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (103,'Rebook Shoes',null,50,100);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (106,'Tennis racket',null,70,80);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (103,'Puma Shoes','Classic Shoes',30,50);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (102,'AllenSolly Jeans',null,17,30);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (106,'Blanket','Comfirtable Down Blanket',35,50);
INSERT INTO product (categoryID,productName,productDescription,purchasePrice,sellingPrice)VALUES (106,'MRF Bat','Signed by Dhoni',60,120);


INSERT INTO orders (customerID,shipmentID,orderStatus,payment) VALUES (1001,null,'Pending',50);
INSERT INTO orders VALUES (1002,null,'Finished',150,'2021-03-16');
INSERT INTO orders VALUES (1004,null,'Sending',234,'2022-03-26');
INSERT INTO orders VALUES (1005,null,'Finished',345,'2022-03-26');
INSERT INTO orders VALUES (1006,null,'Finished',34,'2021-10-16');
INSERT INTO orders VALUES (1007,null,'Pending',545,'2022-04-16');
INSERT INTO orders VALUES (1008,null,'Pending',55,'2022-04-02');
INSERT INTO orders VALUES (1007,null,'Sending',66,'2022-12-06');
INSERT INTO orders VALUES (1005,null,'Finished',88,'2020-01-02');
INSERT INTO orders VALUES (1001,null,'Finished',99,'2020-12-13');
INSERT INTO orders VALUES (1002,null,'Sending',13,'2022-03-30');
INSERT INTO orders VALUES (1003,null,'Sending',66,'2022-4-02');




INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1001, 103,'2022-02-06','Sending','UPS');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1004, 101,'2021-03-16','Shipped','UPS');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1005, 110,'2020-12-13','Shipped','FedEx');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1006, 104,'2022-03-26','Finished','FedEx');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1007, 103,'2022-03-26','Sending','USPS');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1008, 105,'2021-10-16','Shipped','FedEx');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1002, 108,'2022-12-07','Sending','USPS');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1001, 102,'2022-04-02','Sending','FedEx');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1003, 111,'2022-03-30','Sending','UPS');
INSERT INTO shipments (customerID, orderID, shipmentDate,shipmentStatus,shippingVendor)VALUES (1004, 109,'2020-01-02','Shipped','UPS');
s


INSERT INTO vendor VALUES ('vendor1','addr_vendor1');
INSERT INTO vendor VALUES ('vendor2','addr_vendor2');
INSERT INTO vendor VALUES ('vendor3','addr_vendor3');
INSERT INTO vendor VALUES ('vendor4','addr_vendor4');
INSERT INTO vendor VALUES ('vendor5','addr_vendor5');
INSERT INTO vendor VALUES ('vendor6','addr_vendor6');
INSERT INTO vendor VALUES ('vendor7','addr_vendor7');
INSERT INTO vendor VALUES ('vendor8','addr_vendor8');
INSERT INTO vendor VALUES ('vendor9','addr_vendor9');
INSERT INTO vendor VALUES ('vendor10','addr_vendor10');

INSERT INTO Orderline VALUES (1001,101,101,4,100)
INSERT INTO Orderline VALUES (1002,102,102,2,100)
INSERT INTO Orderline VALUES (1003,103,103,5,100)
INSERT INTO Orderline VALUES (1004,104,104,6,100)
INSERT INTO Orderline VALUES (1005,105,105,7,100)
INSERT INTO Orderline VALUES (1006,106,106,9,100)
INSERT INTO Orderline VALUES (1007,102,102,1,100)
INSERT INTO Orderline VALUES (1008,103,103,3,100)
INSERT INTO Orderline VALUES (1009,104,104,2,100)
INSERT INTO Orderline VALUES (1004,102,101,5,100)


INSERT INTO SupplyChain VALUES (101,101,'2022-01-01',500);
INSERT INTO SupplyChain VALUES (102,102,'2021-01-01',50);
INSERT INTO SupplyChain VALUES (103,103,'2020-01-03',700);
INSERT INTO SupplyChain VALUES (104,104,'2020-01-04',900);
INSERT INTO SupplyChain VALUES (105,105,'2019-01-05',100);
INSERT INTO SupplyChain VALUES (106,106,'2018-01-06',50);
INSERT INTO SupplyChain VALUES (107,107,'2017-01-07',60);
INSERT INTO SupplyChain VALUES (108,108,'2016-01-08',70);
INSERT INTO SupplyChain VALUES (109,109,'2015-01-09',10);
INSERT INTO SupplyChain VALUES (101,102,'2012-01-10',20);


INSERT INTO reviews VALUES (1001,102,2,'I have never worn such comfortable clothes!');
INSERT INTO reviews VALUES (1002,103,4,'A great shopping experience');
INSERT INTO reviews VALUES (1003,105,2,'This toy is so cute!');
INSERT INTO reviews VALUES (1002,106,3,'This quality is great');
INSERT INTO reviews VALUES (1001,102,5,'I really like the color of these pants so much!');
INSERT INTO reviews VALUES (1006,107,1,'Bad quality, Bad express!');
INSERT INTO reviews VALUES (1007,103,3,'Good Strings, But a little expensive');
INSERT INTO reviews VALUES (1008,104,4,'This pillow feels so soft,I like it!');
INSERT INTO reviews VALUES (1004,107,3,'express is slow, the quality is good tho');
INSERT INTO reviews VALUES (1006,104,5,'I can play it for whole day and day!');


INSERT INTO cart VALUES (1001,102,4,200);
INSERT INTO cart VALUES (1002,101,4,100);
INSERT INTO cart VALUES (1003,103,2,300);
INSERT INTO cart VALUES (1004,104,1,400);
INSERT INTO cart VALUES (1005,105,9,500);
INSERT INTO cart VALUES (1006,106,2,20);
INSERT INTO cart VALUES (1007,102,5,100);
INSERT INTO cart VALUES (1008,101,3,20);
INSERT INTO cart VALUES (1004,105,8,800);
INSERT INTO cart VALUES (1005,104,7,900);


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



CREATE TABLE [dbo].[VendorAudit](
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

CREATE TRIGGER vendorHistory ON [dbo].[Vendor]
 FOR UPDATE
AS
BEGIN
 INSERT INTO  VendorAudit( 
      [vendor_id]
     ,[vendor_name]
     ,[vendor_address]
     ,[Action]
     ,[ActionDate]
     )
     SELECT [vendorID]
     ,[vendorName]
     ,[vendorAddress]
     ,'U' as [action]
     , getdate()
     FROM inserted

END

-- select * from [dbo].[VendorAudit]
-- select * from [dbo].[Vendor]

-- update 
--  Vendor SET vendorAddress ='test_address' WHERE vendorID = '109'




 CREATE TABLE [dbo].[ProductAudit](
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

CREATE TRIGGER productHistory ON [dbo].[Product]
 FOR UPDATE
AS
BEGIN
 INSERT INTO  [ProductAudit]( 
      [productID]
     ,[productName]
     ,[oldSellingPrice]
	 ,[newSellingPrice]
     ,[Action]
     ,[ActionDate]
     )
     SELECT i.[productID]
     ,i.[productName]
     ,d.[sellingPrice]
	 ,i.[sellingPrice]
     ,'U' as [action]
     , getdate()
     FROM deleted d join inserted i on i.productID = d.productID 

END

-- select * from [dbo].[ProductAudit]
-- select * from [dbo].[Product]

-- update 
--  Product SET sellingPrice = 100 WHERE productID = '102'




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


/*-- Non Cluseted index on Table shipments on Columns  orderID,customerID --*/
Create NonClustered index IX_Shipments_ids on shipments(orderID, customerID);
/*-- Non Cluseted index on Table Supplychain on Columns  productID,vendorID --*/
Create NonClustered index IX_Supplychain_ids on Supplychain(productID, vendorID);
/*-- Non Cluseted index on Table Customer on Columns  email,userName --*/
Create NonClustered index IX_Customer_email on Customer(email ASC, userName ASC);
/*-- Non Cluseted index on Table Orderline on Columns  productID,customerID --*/
Create NonClustered index IX_Orderline_ids on Orderline(orderID, productID, customerID);
