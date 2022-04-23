

/*-- Non Cluseted index on Table shipments on Columns  orderID,customerID --*/
Create NonClustered index IX_Shipments_ids on shipments(orderID, customerID);
/*-- Non Cluseted index on Table Supplychain on Columns  productID,vendorID --*/
Create NonClustered index IX_Supplychain_ids on Supplychain(productID, vendorID);
/*-- Non Cluseted index on Table Customer on Columns  email,userName --*/
Create NonClustered index IX_Customer_email on Customer(email ASC, userName ASC);
/*-- Non Cluseted index on Table Orderline on Columns  productID,customerID --*/
Create NonClustered index IX_Orderline_ids on Orderline(orderID, productID, customerID);