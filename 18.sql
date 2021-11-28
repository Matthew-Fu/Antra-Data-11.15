/*Create a view that shows the total quantity of stock items 
of each stock group sold (in orders) by year 2013-2017. 
[Stock Group Name, 2013, 2014, 2015, 2016, 2017] */
use WideWorldImporters
go
create view sales.quantity_sold_by_group_2013_2017
as
(select StockGroupName, [2013], [2014], [2015], [2016], [2017]
from 
(select StockGroupName, year(orderdate) yr, Quantity
from Warehouse.StockGroups sg 
join Warehouse.StockItemStockGroups ssg on sg.StockGroupID = ssg.StockGroupID
join Warehouse.StockItems s on ssg.StockItemID = s.StockItemID
join Sales.OrderLines ol on ol.StockItemID = s.StockItemID
join Sales.Orders o on o.OrderID = ol.OrderID) p
pivot
(
    sum(quantity) for yr in ([2013], [2014], [2015], [2016], [2017])
) pvt);