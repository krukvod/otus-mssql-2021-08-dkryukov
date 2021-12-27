use WideWorldImporters;
SET STATISTICS io, time on;

select 
	op.OrderID, op.OrderDate, 
	ol.Quantity, ol.UnitPrice
from Sales.OrdersPartitioned op
join Sales.OrderLines ol
on op.OrderID = ol.OrderID --and Inv.InvoiceDate = Details.InvoiceDate
where op.CustomerID = 57
	AND op.OrderDate > '20160101'
		AND op.OrderDate < '20160501';
	
/*
SELECT  $PARTITION.fnOrderYearPartition(OrderDate) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(OrderDate)
		,MAX(OrderDate) 
FROM Sales.OrdersPartitioned
GROUP BY $PARTITION.fnOrderYearPartition(OrderDate) 
ORDER BY Partition ;  

*/