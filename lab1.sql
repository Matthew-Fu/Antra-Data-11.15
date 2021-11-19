-- top 10 customers who have most quantity of stockitems purchased (customerid, name, totalQuantity)
select top 10 sc.CustomerID, sc.CustomerName as name, sum(ws.QuantityOnHand) as totalQuantity
from sales.customers sc
join sales.orders so on sc.CustomerID = so.customerid
join sales.orderlines sol on so.OrderID = sol.OrderID
join warehouse.StockItemHoldings ws on sol.StockItemID = ws.StockItemID
group by sc.CustomerId, sc.CustomerName
order by 3 desc

-- top 10 customers who have most quantity of stockitems purchased, and the top 3 stockitems 
-- they purchased (customerid, name, item1, quantity1, item2, quantity 2, item3, quantity3)
with cte1 as (
select sc.CustomerID, ws.StockItemID as item, sum(ws.QuantityOnHand) as quantity, rank() over (partition by sc.CustomerID order by sum(ws.QuantityOnHand) desc) as RK
from sales.customers sc
join sales.orders so on sc.CustomerID = so.customerid
join sales.orderlines sol on so.OrderID = sol.OrderID
join warehouse.StockItemHoldings ws on sol.StockItemID = ws.StockItemID
group by sc.CustomerID, ws.StockItemID)

select a.CustomerID, a.name, b.item as item1, b.quantity as quantity1, c.item as item2, c.quantity as quantity2, d.item as item3, d.quantity as quantity3
from (select top 10 sc.CustomerID, sc.CustomerName as name, sum(ws.QuantityOnHand) as totalQuantity
from sales.customers sc
join sales.orders so on sc.CustomerID = so.customerid
join sales.orderlines sol on so.OrderID = sol.OrderID
join warehouse.StockItemHoldings ws on sol.StockItemID = ws.StockItemID
group by sc.CustomerId, sc.CustomerName 
order by 3 desc 
) a join (select * from cte1
where RK = 1) b on a.CustomerID = b.CustomerID
join (select * from cte1
where RK = 2) c on a.CustomerID = c.CustomerID
join (select * from cte1
where RK = 3) d on a.CustomerID = d.CustomerID

-- all stockitems that we imported (purchase order) more than we sell (orders) in the year 2015
select w2.StockItemName
from Warehouse.StockItems w2
left join 
(select w1.StockItemID , sum(pl.OrderedOuters) quantity from Warehouse.StockItems w1
left join Purchasing.PurchaseOrderLines pl on w1.StockItemID=pl.StockItemID
left join Purchasing.PurchaseOrders po on po.PurchaseOrderID = pl.PurchaseOrderID
where YEAR(po.OrderDate)=2015
group by w1.StockItemID ) ip on ip.StockItemID = w2.StockItemID
left join
(select w3.StockItemID , sum(sl.Quantity) quantity from Warehouse.StockItems w3
left join sales.OrderLines sl on w3.StockItemID=sl.StockItemID
left join sales.orders so on so.OrderID = sl.OrderID
where YEAR(so.OrderDate)=2015
group by w3.StockItemID
) sd on ip.StockItemID=sd.StockItemID 
where ip.quantity>sd.quantity 

-- All Cities in USA that we do not have a customer in
select distinct CityName from Application.Cities
where CityID not in (select DeliveryCityID from Sales.Customers) 
and StateProvinceID in (select StateProvinceID from Application.StateProvinces);

