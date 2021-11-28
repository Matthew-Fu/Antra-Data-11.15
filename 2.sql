/* If the customer's primary contact person has the same phone number 
   as the customer’s phone number, list the customer companies. */

use WideWorldImporters
go

select sc.CustomerName 
from sales.Customers sc
join Application.People ap 
on sc.PrimaryContactPersonID = ap.PersonID
where sc.PhoneNumber = ap.PhoneNumber