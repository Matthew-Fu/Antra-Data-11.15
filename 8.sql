/* List of States and Avg dates for processing 
(confirmed delivery date – order date) by month*/
use WideWorldImporters
go
select StateProvinceCode,  
[1] as Jan, [2] as Feb, [3] as Mar, [4] as Apr, [5] as May, [6] as Jun, 
[7] as Jul, [8] as Aug, [9] as Sep, [10] as Oct, [11] as Nov, [12] as Dec
from 
(select asp.StateProvinceCode, month(so.OrderDate) as month_, 
avg(datediff(dayofyear, so.OrderDate, si.ConfirmedDeliveryTime)) avg_date_processing
from sales.Invoices si join sales.Orders so on so.OrderID = si.OrderID
join sales.customers sc on sc.CustomerID = so.CustomerID
join Application.Cities ac on sc.DeliveryCityID = ac.CityID
join Application.StateProvinces asp on asp.StateProvinceID = ac.StateProvinceID
group by asp.StateProvinceCode, month(so.OrderDate)) as a
pivot 
(avg(a.avg_date_processing) 
for month_ in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) as PivotTable

