-- List of customers to whom we made a sale prior to 2016 but no sale since 2016-01-01

use WideWorldImporters
go
(select distinct ap.FullName from Application.People ap
join sales.CustomerTransactions sc on ap.PersonID = sc.CustomerID
where year(sc.TransactionDate) <= 2015)
except
(select distinct ap.FullName from Application.People ap
join sales.CustomerTransactions sc on ap.PersonID = sc.CustomerID
where year(sc.TransactionDate) >= 2016)
