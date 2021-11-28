/* Revisit your answer in (19). Convert the result in JSON string and 
save it to the server using TSQL FOR JSON PATH.*/
select year, isnull([Airline Novelties],0) as 'StockGroup.Airline Novelties',
isnull(Clothing,0) as 'StockGroup.Clothing',
isnull([Computing Novelties],0) as 'StockGroup.Computing Novelties',
isnull([Furry Footwear],0) as 'StockGroup.Furry Footwear',
isnull(Mugs,0) as 'StockGroup.Mugs',
isnull([Novelty Items],0) as 'StockGroup.Novelty Items',
isnull([Packaging Materials],0) as 'StockGroup.Packaging Materials',
isnull([T-Shirts],0) as 'StockGroup.T-Shirts',
isnull(Toys,0) as 'StockGroup.Toys',
isnull([USB Novelties],0) as 'StockGroup.USB Novelties'
from sales.stock_quantity_year
order by year
for json path