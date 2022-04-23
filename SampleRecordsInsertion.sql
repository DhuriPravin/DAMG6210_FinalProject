

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

