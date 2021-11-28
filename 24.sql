/* Consider the JSON file:
Looks like that it is our missed purchase orders. Migrate these data into Stock Item, Purchase Order 
and Purchase Order Lines tables. Of course, save the script.*/
declare @json NVARCHAR(max) = 
N'{"PurchaseOrders":
    [
        {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":[
            6,
            7
         ],
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
         },
         {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":"7",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-02",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
         }
    ]
}'
-- insert into Purchasing.PurchaseOrders
insert into Purchasing.PurchaseOrders
    select (select max(PurchaseOrderID) + 1 from Purchasing.PurchaseOrders nolock),
    JSON_VALUE(oj.value, '$.Supplier'),
    JSON_VALUE(oj.value, '$.OrderDate'),
    (select DeliveryMethodID from Application.DeliveryMethods where DeliveryMethodName = JSON_VALUE(oj.value, '$.DeliveryMethod')),
    (select PrimaryContactPersonID from Purchasing.Suppliers where SupplierID = JSON_VALUE(oj.value, '$.Supplier')),
    JSON_VALUE(oj.value,'$.ExpectedDeliveryDate'),
    JSON_VALUE(oj.value,'$.SupplierReference'),
    0,
    null,
    null,
    (select min(LastEditedBy) from Purchasing.PurchaseOrders where SupplierID = JSON_VALUE(oj.value, '$.Supplier')),
    getdate()
    from openjson(@json,'$.PurchaseOrders') oj

-- insert into Warehouse.StockItems
insert into Warehouse.StockItems
select
    (select max(StockItemID) + 1 from Warehouse.StockItems),
    JSON_VALUE(@json,'$.PurchaseOrders[0].StockItemName'),
    cast(JSON_VALUE(@json,'$.PurchaseOrders[0].Supplier') as int), null,
    cast(JSON_VALUE(@json,'$.PurchaseOrders[0].UnitPackageId') as int),
    cast(JSON_VALUE(@json,'$.PurchaseOrders[0].OuterPackageId[0]') as int),
    JSON_VALUE(@json,'$.PurchaseOrders[0].Brand'), null,
    JSON_VALUE(@json,'$.PurchaseOrders[0].LeadTimeDays'),
    JSON_VALUE(@json,'$.PurchaseOrders[0].QuantityPerOuter'),
    cast(0 as bit), null,
    JSON_VALUE(@json,'$.PurchaseOrders[0].TaxRate'),
    JSON_VALUE(@json,'$.PurchaseOrders[0].UnitPrice'),
    JSON_VALUE(@json,'$.PurchaseOrders[0].RecommendedRetailPrice'),
    JSON_VALUE(@json,'$.PurchaseOrders[0].TypicalWeightPerUnit'),null,null,null,null,null,null,
    7, SYSDATETIME(),
    (select max(ValidTo) from Warehouse.StockItems)
/*
insert into Purchasing.PurchaseOrderLines
values(
    (select max(PurchaseOrderLineID) + 1 from Purchasing.PurchaseOrderLines)
)
*/