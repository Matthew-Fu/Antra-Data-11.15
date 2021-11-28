/*List all stock items that are manufactured in China. 
(Country of Manufacture)*/
use WideWorldImporters
go
select StockItemID
from Warehouse.StockItems
where json_value(CustomFields,'$.CountryOfManufacture') = 'China'