/*List of StockItems that the company 
purchased more than sold in the year of 2015*/
use WideWorldImporters
go
select w2.StockItemName
from Warehouse.StockItems w2
left join 
(select w1.StockItemID , sum(pl.OrderedOuters) quantity from Warehouse.StockItems w1
left join Purchasing.PurchaseOrderLines pl on w1.StockItemID=pl.StockItemID
left join Purchasing.PurchaseOrders po on po.PurchaseOrderID = pl.PurchaseOrderID
where YEAR(po.OrderDate)=2015
group by w1.StockItemID ) ip on ip.StockItemID = w2.StockItemID
left join
(select w3.StockItemID , sum(sl.Quantity) quantity from Warehouse.StockItems w3
left join sales.OrderLines sl on w3.StockItemID=sl.StockItemID
left join sales.orders so on so.OrderID = sl.OrderID
where YEAR(so.OrderDate)=2015
group by w3.StockItemID
) sd on ip.StockItemID=sd.StockItemID 
where ip.quantity>sd.quantity 