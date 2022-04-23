USE ORMS

CREATE VIEW TotalSales
AS
SELECT YEAR(orderDate) [year],
    MONTH(orderDate) [month],
    SUM(payment) totalSales
FROM Orders
WHERE orderDate IS NOT NULL
GROUP BY MONTH(orderDate), YEAR(orderDate);

--Calculates the Extended Price, the discounted total for each line item (order detail) in all orders, using data from the Order Details and Products tables :

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


CREATE VIEW TotalBilling
AS
SELECT RANK() OVER(ORDER BY COUNT(o.OrderID) DESC) AS [CustomerRank],
    o.customerID, c.name, COUNT(o.orderID) AS [Total Orders of Customer],
    SUM(ca.totalPrice) AS [Total Billing Amt of each Customer]
FROM Orders o INNER JOIN Customer c ON
o.customerID = c.customerID INNER JOIN Cart ca ON o.customerID = ca.customerID
GROUP BY o.customerID, c.name;


CREATE VIEW QuantityCheck
AS
SELECT c.customerID, c.name, s.orderID,  pro.quantity
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


CREATE VIEW StockAvail
AS
SELECT productID, productQuantityAvail,
    CASE
WHEN productQuantityAvail = 0 THEN 'Out of stock'
WHEN productQuantityAvail BETWEEN 1 and 10 THEN 'Low stock'
WHEN productQuantityAvail BETWEEN 11 and 30 THEN 'In stock'
WHEN productQuantityAvail > 31 THEN 'Enough stock'
END AS stockStatus
FROM Product 
ORDER BY productID desc;
