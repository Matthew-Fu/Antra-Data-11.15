/*List any orders that had more than one delivery attempt 
(located in invoice table).*/
use WideWorldImporters
go
select OrderID from Sales.Invoices
where json_value(ReturnedDeliveryData,'$.Events[1].Comment') is not null


