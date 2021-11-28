-- List of Stock Items and total quantity for each stock item in Purchase Orders 
-- in Year 2013

use WideWorldImporters
go
select ws.StockItemID, ws.StockItemName, PT.TotalQuantity from Warehouse.StockItems ws
join (select ppl.StockItemID, sum(ppl.OrderedOuters) as TotalQuantity from Purchasing.PurchaseOrderLines ppl
 join Purchasing.PurchaseOrders ppo on ppl.PurchaseOrderID = ppo.PurchaseOrderID
 where year(ppo.OrderDate) = 2013
 group by ppl.StockItemID) as PT 
 on ws.StockItemID = PT.StockItemID


