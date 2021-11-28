/* Revisit your answer in (19). Convert the result into an XML string 
and save it to the server using TSQL FOR XML PATH.*/
select year, isnull([Airline Novelties],0) as 'StockGroup/AirlineNovelties',
isnull(Clothing,0) as 'StockGroup/Clothing',
isnull([Computing Novelties],0) as 'StockGroup/ComputingNovelties',
isnull([Furry Footwear],0) as 'StockGroup/FurryFootwear',
isnull(Mugs,0) as 'StockGroup/Mugs',
isnull([Novelty Items],0) as 'StockGroup/NoveltyItems',
isnull([Packaging Materials],0) as 'StockGroup/PackagingMaterials',
isnull([T-Shirts],0) as 'StockGroup/T-Shirts',
isnull(Toys,0) as 'StockGroup/Toys',
isnull([USB Novelties],0) as 'StockGroup/USBNovelties'
from sales.stock_quantity_year
order by year
for  xml path('stock_quantity_Year'), root('StockGroupQuantity')