-- List of stock items that have at least 10 characters in description

use WideWorldImporters
go
select ws.StockItemID, ws.StockItemName
from Warehouse.Stockitems ws
where len(ws.SearchDetails) >= 10