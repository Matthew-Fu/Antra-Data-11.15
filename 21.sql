/*Create a new table called ods.Orders. Create a stored procedure, with proper error handling 
and transactions, that input is a date; when executed, it would find orders of that day, 
calculate order total, and save the information (order id, order date, order total, customer id) 
into the new table. If a given date is already existing in the new table, throw an error and roll back. 
Execute the stored procedure 5 times using different dates. */

go
drop table ods.Orders
create table ods.Orders (
    OrderID int primary key not null, 
    OrderDate date not null, 
    OrderTotal decimal(18,2), 
    CustomerID int not null
)
go
create or alter  proc get_order(@OrderDate datetime)
As 
	BEGIN try
		begin transaction 
		select orderId, OrderDate,CustomerID, sales.invoice_total_order(OrderID) total_order
		FROM Sales.Orders so
		where so.OrderDate=@orderDate
		commit transaction
    END TRY
	 BEGIN CATCH   
        print 'Error: Entered date is already existing in the new table.'
        select ERROR_MESSAGE() as error
        rollback transaction   
    END CATCH;  

EXEC get_order @orderdate = '2013-01-01';
select * from ods.Orders 
