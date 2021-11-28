/*
32.	Remember the discussion about those two databases from the class, also remember, 
those data models are not perfect. You can always add new columns (but not alter or drop columns) 
to any tables. Suggesting adding Ingested DateTime and Surrogate Key columns. 
Study the Wide World Importers DW. Think the integration schema is the ODS. 
Come up with a TSQL Stored Procedure driven solution to move the data from WWI database 
to ODS, and then from the ODS to the fact tables and dimension tables. By the way, 
WWI DW is a galaxy schema db. Requirements:
a.	Luckily, we only start with 1 fact: Order. Other facts can be ignored for now.
b.	Add a new dimension: Country of Manufacture. It should be given on top of Stock Items.
c.	Write script(s) and stored procedure(s) for the entire ETL from WWI db to DW.
*/
----------------------------------------------------------------
-- create a memory-optimized table type
use WideWorldImportersDW
go
create type [dbo].[MemoryType]
    as TABLE
    ([Order Staging Key] bigint primary key NONCLUSTERED,
    [City Key] int,
    [Customer Key] int,
    [Stock Item Key] int,
    [Order Date Key] date,
    [Picked Date Key] date,
    [Salesperson Key] int,
    [Picker Key] int,
    [WWI Order ID] int,
    [WWI Backorder ID] int,
    [Description] nvarchar(100),
    Package nvarchar(50),
    Quantity int,
    [Unit Price] decimal(18,2),
    [Tax Rate] decimal(18,3),
    [Total Excluding Tax] decimal(18,2),
    [Tax Amount] decimal(18,2),
    [Total Including Tax] decimal(18,2),
    [Lineage Key] int,
    [WWI City ID] int,
    [WWI Customer ID] int,
    [WWI Stock Item ID] int,
    [WWI Salesperson ID] int,
    [WWI Picker ID] int,
    [Last Modified When] datetime2(7))
    with (memory_optimized = ON)
go
-- migrate data from WWI to Integration.Order_Staging and load into fact.order
create or alter procedure [Integration].[MigrateFromWWItoOrderStaging]
as
begin
    -- remove existing entries in Integration.Order_Staging
    delete from Integration.Order_Staging
    -- declare table variable utilizing the created type - MemoryType
    declare @inmem dbo.MemoryType
    -- populate table variable with all exisiting order details
    insert @inmem
    select row_number() over(order by o.OrderID) [Order Staging Key],
        (select DeliveryCityID from WideWorldImporters.Sales.Customers where CustomerID = i.CustomerID) [City Key],
        o.CustomerID [Customer Key],
        StockItemID [Stock Item Key],
        OrderDate [Order Date Key],
        cast(PickingCompletedWhen as date) [Picked Date Key],
        o.SalespersonPersonID, 
        PickedByPersonID, 
        o.OrderID [WWI Order ID], 
        BackorderOrderID [WWI Backorder ID], 
        [Description],
        (select PackageTypeName from WideWorldImporters.Warehouse.PackageTypes where PackageTypeID = il.PackageTypeID) Package,
        Quantity,UnitPrice,TaxRate,
        Quantity*UnitPrice [Total Excluding Tax], 
        cast(TaxRate/100*Quantity*UnitPrice as decimal(18,2)) [Tax Amount],
        cast((1+TaxRate/100)*Quantity*UnitPrice as decimal(18,2)) [Total Including Tax], 
        (select [Lineage Key] from Integration.[Lineage] where [Table Name] = 'Order') [Lineage Key], 
        (select DeliveryCityID from WideWorldImporters.Sales.Customers where CustomerID = i.CustomerID) [WWI City ID],
        o.CustomerID [WWI Customer ID], 
        StockItemID [WWI Stock Item ID], 
        O.SalespersonPersonID [WWI Salesperson ID], 
        PickedByPersonID [WWI Picker ID], 
        cast(SYSDATETIME() as datetime2(7)) [Last Modified When]
    from WideWorldImporters.Sales.Invoices i left join WideWorldImporters.Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
    join WideWorldImporters.Sales.Orders o on i.OrderID = o.OrderID
    -- insert into Integration.Order_Staging with memory-optimized table
    insert into WideWorldImportersDW.Integration.Order_Staging
        ([Order Staging Key],[City Key],[Customer Key],[Stock Item Key],[Order Date Key],[Picked Date Key],
        [Salesperson Key],[Picker Key],[WWI Order ID],[WWI Backorder ID],[Description],Package,Quantity,
        [Unit Price],[Tax Rate],[Total Excluding Tax],[Tax Amount],[Total Including Tax],[Lineage Key],
        [WWI City ID],[WWI Customer ID],[WWI Stock Item ID],[WWI Salesperson ID],[WWI Picker ID],[Last Modified When])
    select * from @inmem
    -- migrate data from Integration.Order_Staging to Fact.Order
    exec Integration.MigrateStagedOrderData
end

exec [Integration].[MigrateFromWWItoOrderStaging]

-- change the memory-optimized table type
drop type [dbo].[MemoryType]
create type [dbo].[MemoryType] as TABLE
    ([City Staging Key] int primary key NONCLUSTERED,
    [WWI City ID] int not null,
    City nvarchar(20) not null,
    [State Province] nvarchar(50) not null,
    Country nvarchar(60) not null,
    Continent nvarchar(30) not null,
    [Sales Territory] nvarchar(50) not null,
    Region nvarchar(30) not null,
    Subregion nvarchar(30) not null,
    [Location] nvarchar(150),
    [Latest Recorded Population] bigint not null,
    [Valid From] datetime2(7) not null,
    [Valid To] datetime2(7) not null
    ) 
    with (memory_optimized = ON)
go
-- migrate data from WWI to Integration.City_Staging
create or alter procedure [Integration].[MigrateFromWWItoCityStaging]
as begin
    -- remove existing entries in Integration.City_Staging 
    delete from Integration.City_Staging
    -- declare table variable utilizing the created type - MemoryType
    declare @inmem dbo.MemoryType
    -- populate table variable with all exisiting city details
    insert into WideWorldImportersDW.Integration.City_Staging
    select row_number() over(order by cityid), CityID,CityName,StateProvinceName, CountryName, Continent,SalesTerritory,Region, 
    (select distinct Subregion from dimension.City where Continent = cou.Continent) Subregion,
    [Location],c.LatestRecordedPopulation,c.ValidFrom,c.ValidTo
    from WideWorldImporters.Application.Cities c join WideWorldImporters.Application.StateProvinces sp on c.StateProvinceID = sp.StateProvinceID
    join WideWorldImporters.Application.Countries cou on sp.CountryID = cou.CountryID
end
