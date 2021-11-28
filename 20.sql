/* Create a function, input: order id; return: total of that order. 
List invoices and use that function to attach the order total 
to the other fields of invoices. */

create or alter function sales.invoice_order_total (@orderid int)
returns decimal(18,2)
as
begin
    declare @OrderTotal decimal(18,2);
    select @OrderTotal = sum(Quantity * UnitPrice)
    from Sales.OrderLines
    where OrderID = @orderid;
    return @OrderTotal;
end
