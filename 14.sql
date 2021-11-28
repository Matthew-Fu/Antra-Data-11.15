/* List of Cities in the US and the stock item that the city got the most deliveries in 2016. 
If the city did not purchase any stock items in 2016, print “No Sales”. */

use WideWorldImporters
go
select us.CityName, us.StateProvinceName, 
ISNULL(cast(StockItemID as varchar), 'No Sales') most_delivered_stockitem
from
(select CityID, cityname, StateProvinceName, StockItemID, count(InvoiceID) deliveries,
rank() over (partition by cityname, StateProvinceName order by count(InvoiceID) desc) rank_d
from Sales.Invoices i 
join Sales.OrderLines sol on i.OrderID = sol.OrderID
join Sales.Orders so on so.OrderID = sol.OrderID
join Sales.Customers sc on sc.CustomerID = so.CustomerID 
right join Application.Cities ac  on DeliveryCityID = ac.cityid
join Application.StateProvinces sp on sp.StateProvinceID = ac.StateProvinceID
join Application.Countries co on co.CountryID = sp.CountryID 
where year(OrderDate) = 2016
group by CityID, cityname, StateProvinceName, StockItemID ) us
order by StateProvinceName, CityName