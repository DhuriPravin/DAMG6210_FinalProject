--Dropping Database

USE master;
GO
ALTER DATABASE ORMS_COPY 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE ORMS_COPY;

--Creating Database
CREATE DATABASE ORMS_Copy;

--Use Database
USE ORMS_Copy;

--Creating Table Customer
CREATE TABLE Customer
(
    customerID INT NOT NULL PRIMARY KEY IDENTITY(1000,1),
    [name] VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    userName VARCHAR(50) NOT NULL,
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
    orderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    -- Trigger Completed To-do
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
    shipmentStatus VARCHAR(50) NOT NULL,
    -- Pending, Shipped, Delivered
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
    productDescription VARCHAR(50) NULL,
    purchasePrice DECIMAL(18,2) NOT NULL,
    --Can be null
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
CREATE CERTIFICATE EncryptionCertC WITH SUBJECT = 'Certificate for column level encryption';

--Check if Certificate Got Created
SELECT name, pvt_key_encryption_type_desc
FROM sys.certificates


--Creation of Symmetric Key
CREATE SYMMETRIC KEY EncryptionKeyC WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE EncryptionCertC

--Check if 2 rows exists in the symmetric key table, one is default key and the other is the one we created
SELECT name, algorithm_desc
FROM sys.symmetric_keys

----Open and Close Statements of Symmetric keys to execute before performing something related to Encryption
-- OPEN SYMMETRIC KEY EncryptionKey DECRYPTION BY CERTIFICATE EncryptionCert
-- CLOSE SYMMETRIC KEY EncryptionKey

-----Sample Statements to Insert by encrypting and Fetching by Decrypting
-- INSERT INTO loginDetails VALUES  ('test','Check@23', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Check@23'))
-- SELECT  CAST(DECRYPTBYKEY(passwordEncrypted) AS VARCHAR) FROM loginDetails

-----/** Column Level Encryption Ends **/-------------



/*-- STORED PROCEDURES  --*/
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

GO
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

Go
CREATE PROC [dbo].[sp_createCustomer]
    (
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
)
AS
BEGIN
    ---Opening Symmetric Key
    OPEN SYMMETRIC KEY EncryptionKeyC DECRYPTION BY CERTIFICATE EncryptionCertC;

    ---Print Error if Email Already Exists
    IF EXISTS(SELECT 1
    FROM Customer
    WHERE email = @email)
    BEGIN
        PRINT 'Email Already Exists!!'
        RETURN
    END

    ---Print Error if User Name Already Exists
    IF EXISTS(SELECT 1
    FROM Customer
    WHERE userName = @userName)
    BEGIN
        PRINT 'User Name Already Being Used!!'
        RETURN
    END

    INSERT INTO Customer
        ([name], phone, email, userName, [password], [address], [state], [city], zipcode, gender, birthdate)
    VALUES
        (@name, @phone, @email, @userName, ENCRYPTBYKEY(KEY_GUID('EncryptionKeyC'),@password), @address, @state, @city, @zipcode, @gender, @birthdate);

    ---Closing Symmetric Key
    CLOSE SYMMETRIC KEY EncryptionKeyC;
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





