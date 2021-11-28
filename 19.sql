/*Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
by year 2013-2017. [Year, Stock Group Name1, Stock Group Name2, Stock Group Name3, … , Stock Group Name10] 
*/
use WideWorldImporters
go
declare @cols nvarchar(max);
declare @query nvarchar(max);
select @cols = COALESCE(@cols + ', ','') + QUOTENAME(StockGroupName)
FROM
(select distinct StockGroupName
from Warehouse.StockGroups) wsg
order by wsg.StockGroupName
set @query = 
'create or alter view sales.stock_quantity_year
as 
(select year, ' + @cols + '
from 
(select StockGroupName, year(orderdate) as year, Quantity
from Warehouse.StockGroups wsg 
join Warehouse.StockItemStockGroups wsson wsg.StockGroupID = wss.StockGroupID
join Warehouse.StockItems wsi on wss.StockItemID = wsi.StockItemID
join Sales.OrderLines sol on sol.StockItemID = wsi.StockItemID
join Sales.Orders so on so.OrderID = sol.OrderID
where year(orderdate) in (2013, 2014, 2015, 2016, 2017)) p
pivot(
    sum(quantity) for StockGroupName in (' + @cols + ')
) pvt)'
exec(@query)
go