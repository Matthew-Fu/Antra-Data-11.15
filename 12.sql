/*List all the Order Detail (Stock Item name, delivery address, delivery state, city, country, 
customer name, customer contact person name, customer phone, quantity) for the date of 2014-07-01. 
Info should be relevant to that date.*/

use WideWorldImporters
go
select sc.CustomerID,sc.CustomerName,sc.PhoneNumber, sc.DeliveryAddressLine1,sc.DeliveryAddressLine2, ol.Quantity,
ap.FullName as customer_contact_person_name, ac.CityName, asp.StateProvinceName,c.CountryName
from Sales.orders so
join Sales.Customers sc on so.CustomerID= sc.CustomerID
join  Sales.OrderLines ol on so.OrderID= ol.OrderID
join Application.People ap on sc.PrimaryContactPersonID = ap.PersonID
join Application.Cities  ac on  sc.DeliveryCityID= ac.CityID
join Application.StateProvinces asp on ac.StateProvinceID= asp.StateProvinceID
join Application.Countries c on asp.CountryID= c.CountryID
where so.OrderDate = '2014-07-01'