/* List of States and Avg dates for processing 
(confirmed delivery date – order date).*/
use WideWorldImporters
go
select asp.StateProvinceCode, 
avg(datediff(dayofyear, so.Orderdate,si.ConfirmedDeliveryTime)) Avg_dates
from sales.Invoices si join sales.Orders so on so.OrderID = si.OrderID
join sales.customers sc on sc.CustomerID = so.CustomerID
join Application.Cities ac on sc.DeliveryCityID = ac.CityID
join Application.StateProvinces asp on asp.StateProvinceID = ac.StateProvinceID
group by asp.StateProvinceCode

