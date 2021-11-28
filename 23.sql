/* Rewrite your stored procedure in (21). Now with a given date, it should wipe out all the order 
data prior to the input date and load the order that was placed in the next 7 days following 
the input date. */
create or alter  proc get_order(@OrderDate datetime)
As 
	BEGIN try
		begin transaction
		delete from ods.Orders where OrderDate < @orderdate
		select orderId, OrderDate,CustomerID, sales.invoice_total_order(OrderID) total_order
		FROM Sales.Orders so
		where so.OrderDate>=@orderDate and OrderDate <= @orderdate + 7
		commit transaction
    END TRY
	 BEGIN CATCH   
        print 'Error: Entered date is already existing in the new table.'
        select ERROR_MESSAGE() as error
        rollback transaction   
    END CATCH;  

EXEC get_order @orderdate = '2014-03-01';
select * from ods.Orders 