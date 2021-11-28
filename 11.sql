--List all the cities that were updated after 2015-01-01
use WideWorldImporters
go
select CityName from Application.Cities
where year(ValidFrom) > 2014
