use WideWorldImporters
go
create table ods.ConfirmedDeviveryJson (
    id int primary key not null,
    date date not null,
    value NVARCHAR(max) not null
)
go

create table #temp(
	InvoiceID int, 
	Event nvarchar(100), 
	EventTime datetime2(7), 
    ConNote nvarchar(50), 
	DriverID int, 
	Latitude decimal(10,7), 
	Longitude decimal(10,7), 
    Status nvarchar(50), 
	DeliveredWhen datetime2(7), 
	ReceivedBy nvarchar(100))

INSERT INTO #temp
    select sales.Invoices.InvoiceID,Events.Event,Events.EventTime,Events.ConNote,
    Events.DriverID,Events.Latitude,Events.Longitude,Events.Status,
    ReturnedDeliveryData.DeliveredWhen, ReturnedDeliveryData.ReceivedBy
    from Sales.Invoices
    cross apply 
    openjson(ReturnedDeliveryData) 
    with(
        Events nvarchar(max) AS JSON,
        DeliveredWhen datetime2(7),
        ReceivedBy nvarchar(100)
    )
    as ReturnedDeliveryData
    cross apply
    openjson(ReturnedDeliveryData.Events)
    with(
        Event nvarchar(100),
        EventTime datetime2(7),
        ConNote nvarchar(50),
        DriverID int,
        Latitude decimal(10,7),
        Longitude decimal(10,7),
        Status nvarchar(50)
    ) as Events

go
create or alter proc ods.load_invoice_info
    @date date,
    @custid int
as
begin

    insert into ods.ConfirmedDeviveryJson
    select InvoiceID id, 
	cast(ConfirmedDeliveryTime as date) date,
    (select i.InvoiceID,CustomerID,BillToCustomerID,OrderID,DeliveryMethodID,ContactPersonID,
    AccountsPersonID,SalespersonPersonID,PackedByPersonID,InvoiceDate,CustomerPurchaseOrderNumber,
    IsCreditNote,CreditNoteReason,Comments,DeliveryInstructions,InternalComments,TotalDryItems,
    TotalChillerItems,DeliveryRun,RunPosition,
    (select Event,EventTime,ConNote,DriverID,Latitude,Longitude,Status from #temp
    where InvoiceID = i.InvoiceID for json path) as 'ReturnedDeliveryData.Events',
    (select distinct DeliveredWhen from #temp where InvoiceID = i.InvoiceID) as 'ReturnedDeliveryData.DeliveredWhen',
    (select distinct ReceivedBy from #temp where InvoiceID = i.InvoiceID) as 'ReturnedDeliveryData.DReceivedBy',
    ConfirmedDeliveryTime,ConfirmedReceivedBy,i.LastEditedBy 'InvoiceLastEditedBy',i.LastEditedWhen 'InvoiceLastEditedWhen',
    (select * from Sales.InvoiceLines where InvoiceID = i.InvoiceID for json path) 'InvoiceLines'
    from Sales.Invoices i
    where InvoiceID = main.InvoiceID
    for json path) value
    from Sales.Invoices main
    where cast(ConfirmedDeliveryTime as date) = @date and CustomerID = @custid
end

select * from ods.ConfirmedDeviveryJson

DECLARE @deliverydate date
DECLARE myCursor CURSOR FORWARD_ONLY FOR
    SELECT distinct cast(ConfirmedDeliveryTime as date) deliverydate from Sales.Invoices
OPEN myCursor
FETCH NEXT FROM myCursor INTO @deliverydate
WHILE @@FETCH_STATUS = 0 BEGIN
    EXEC ods.load_invoice_info @date = @deliverydate,@custid = 1
    FETCH NEXT FROM myCursor INTO @deliverydate
END;
CLOSE myCursor;
DEALLOCATE myCursor;

select * from ods.ConfirmedDeviveryJson