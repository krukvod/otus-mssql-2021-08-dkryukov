if OBJECT_ID('CreateReport_proc') is not null
	drop procedure CreateReport_proc
GO

create procedure CreateReport_proc @CustomerId int, @dateFrom datetime, @dateTo datetime
as
begin
	
	insert into dbo.reporttable (CustomerId, OrderDate, StockItemID, Quantity, UnitPrice, TaxRate)
	 select o.CustomerID, o.OrderDate, ol.StockItemID, ol.Quantity, ol.UnitPrice, ol.TaxRate
	from Sales.Orders o
	join Sales.OrderLines ol
	on o.OrderId = ol.OrderID
	where o.CustomerId = @CustomerID and o.OrderDate between @DateFrom and @DateTo;

	update dbo.reporttable
	set ConfirmForProcessing = Getutcdate() 
	where CustomerId = @CustomerID and OrderDate between @DateFrom and @DateTo and ConfirmForProcessing is null;
end
GO