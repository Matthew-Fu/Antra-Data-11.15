/*List of stock item groups and total quantity purchased, total quantity sold, and 
the remaining stock quantity (quantity purchased – quantity sold) */

use WideWorldImporters
go
select ws.stockitemid, a.quantity_order, a.quantity_sale, a.quantity_order-a.quantity_sale as remaining_stock_quantity 
from Warehouse.StockItems ws
join
(select ws.StockItemID,sum(ppl.OrderedOuters) as quantity_order,sum(sol.Quantity) as quantity_sale
from Warehouse.StockItems ws
join Purchasing.PurchaseOrderLines ppl
on ws.StockItemID =ppl.StockItemID
join Sales.OrderLines sol
on ppl.StockItemID=sol.StockItemID
group by ws.StockItemID) a 
on ws.stockitemid = a.StockItemID