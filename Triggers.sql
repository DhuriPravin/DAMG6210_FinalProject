

/*-- VendorAudit Table to insert data when vendorHistory trigger is initiated  --*/

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

/*-- Trigger to insert record into VendorAudit table when vendor table is changed --*/
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


/*-- Execute this to test the vendorHistory Trigger  --*/
-- select * from [dbo].[VendorAudit]
-- select * from [dbo].[Vendor]

-- update 
--  Vendor SET vendorAddress ='test_address' WHERE vendorID = '109'

-- select * from [dbo].[VendorAudit]
-- select * from [dbo].[Vendor]



/*-- ProductAudit Table to insert data when productHistory trigger is initiated  --*/
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

/*-- Trigger to insert record into ProductAudit table when Product table is changed --*/
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

/*-- Execute this to test the productHistory Trigger  --*/
-- select * from [dbo].[ProductAudit]
-- select * from [dbo].[Product]

-- update 
--  Product SET sellingPrice = 100 WHERE productID = '102'

