CREATE DATABASE ORMS;

GO

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
    CONSTRAINT chk_phone CHECK (phone not like '%[^0-9]%'),
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
