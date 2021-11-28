--- List of Persons’ full name, all their fax and phone numbers, 
--- as well as the phone number and fax of the company they are working for (if any). 

use WideWorldImporters
go
select ap.FullName, ap.FaxNumber, ap.PhoneNumber, ps.PhoneNumber, ps.FaxNumber 
from Application.People ap left join Purchasing.suppliers ps
on ap.PersonID = ps.PrimaryContactPersonID