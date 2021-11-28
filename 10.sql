/*List of Customers and their phone number, 
together with the primary contact person’s name, 
to whom we did not sell more than 10  mugs (search by name) 
in the year 2016*/
use WideWorldImporters
go
select CNT.CustomerName, sc.PhoneNumber, ap.FullName as PrimaryContactPerson
from
(select c.CustomerName,sum(sl.Quantity) as total
from sales.Customers c
join sales.Orders so on c.CustomerID=so.CustomerID
join sales.OrderLines sl on so.OrderID=sl.OrderID
join Warehouse.StockItems w1 on w1.StockItemID=sl.StockItemID
join Warehouse.StockItemStockGroups w2 on w1.StockItemID=w2.StockItemID
join Warehouse.StockGroups w3 on w2.StockGroupID=w3.StockGroupID
where w3.StockGroupName ='mugs' and YEAR(so.OrderDate)=2016 
group by c.CustomerName) as CNT
join sales.Customers sc
on CNT.CustomerName=sc.CustomerName
join Application.People ap
on sc.PrimaryContactPersonID=ap.PersonID
where CNT.total <= 10
