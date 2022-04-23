
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

DECLARE @customerID INT;
EXECUTE sp_createCustomer @customerID OUTPUT, 'customer1', '857896101', 'customer2@gmail.com', 'custUser1', 'custUser@22', 'garrison1 st', 'MA', 'Boston', 02120, 'M', '2000-01-05';