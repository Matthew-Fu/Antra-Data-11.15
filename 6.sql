/* List of stock items that are not sold to the state of Alabama and 
Georgia in 2014.*/
use WideWorldImporters 
go
select distinct ws.StockItemID, ws.StockItemname from WareHouse.StockItems ws
join Sales.OrderLines sol on ws.StockItemID = sol.StockItemID
join Sales.Orders so on so.OrderID = sol.OrderID
join sales.Customers sc on so.CustomerID = sc.CustomerID
join Application.Cities ac on ac.CityID=sc.DeliveryCityID
join Application.StateProvinces a on a.StateProvinceID = ac.StateProvinceID
where year(so.OrderDate) = 2014 and a.StateProvinceName not in ('Alabama', 'Georgia')
