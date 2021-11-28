/*Total quantity of stock items sold in 2015, 
group by country of manufacturing. */
use WideWorldImporters
go
select sum(quantity), json_value(CustomFields,'$.CountryOfManufacture') CountryOfManufacture
from Warehouse.StockItems s 
join Sales.OrderLines ol on ol.StockItemID = s.StockItemID
join Sales.Orders o on o.OrderID = ol.OrderID
where year(OrderDate) = 2015
group by json_value(CustomFields,'$.CountryOfManufacture')