/*
�������� ���������

����:
��������� �������� �������� 

�� ���� �������� �������� �������� ��������� / ������� � ������������������ �� �������������.
*/
-- 1. �������� ������� ������������ ������� � ���������� ������ �������.
if OBJECT_ID ('customer_max_pay') is not null
	drop function customer_max_pay
GO

create function customer_max_pay ()
returns int
as
begin
return
( 
	select CustomerID from (
		select sel.CustomerID, ROW_NUMBER() over(order by sum_summa desc) as num
		from (select o.CustomerID, sum(ol.UnitPrice * ol.Quantity) as sum_summa
			from Sales.OrderLines ol
			join Sales.Orders o
			on ol.OrderID = o.OrderID
			group by o.CustomerID
		) sel
	) res
	where num = 1
)
end;
GO

select dbo.customer_max_pay ()

-- 2. �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������. 
--    ������������ ������� : Sales.Customers Sales.Invoices Sales.InvoiceLines
if OBJECT_ID ('invoces_by_customer_proc') is not null
	drop procedure invoces_by_customer_proc
GO

create procedure invoces_by_customer_proc @CustomerID int
as
begin
	select sum(il.Quantity*il.UnitPrice)
	from Sales.Customers c
	join Sales.Invoices i
	on c.CustomerID = i.CustomerID
	join Sales.InvoiceLines il
	on i.InvoiceID = il.InvoiceID
	where c.CustomerID = @CustomerID
end
GO

exec invoces_by_customer_proc @CustomerID = 14

-- 3. ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
if OBJECT_ID ('invoces_by_customer_proc') is not null
	drop procedure invoces_by_customer_proc
GO

create procedure invoces_by_customer_proc @CustomerID int
as
begin
	select sum(il.Quantity*il.UnitPrice)
	from Sales.Customers c
	join Sales.Invoices i
	on c.CustomerID = i.CustomerID
	join Sales.InvoiceLines il
	on i.InvoiceID = il.InvoiceID
	where c.CustomerID = @CustomerID
end
GO

if OBJECT_ID ('invoces_by_customer_f') is not null
	drop function invoces_by_customer_f
GO

create function invoces_by_customer_f (@CustomerID int)
returns decimal(18,2)
as
begin
return(
	select sum(il.Quantity*il.UnitPrice)
	from Sales.Customers c
	join Sales.Invoices i
	on c.CustomerID = i.CustomerID
	join Sales.InvoiceLines il
	on i.InvoiceID = il.InvoiceID
	where c.CustomerID = @CustomerID
) 
end;
GO

set statistics time on

declare @id int
set @id = 14


select dbo.invoces_by_customer_f (@id)
exec invoces_by_customer_proc @CustomerID = @id
/*
������� ����������� �������, ��� ���������
*/


-- 4. �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.
if OBJECT_ID('invoices_f') is not null drop function invoices_f 
GO

create function invoices_f (@n int)
returns table
as
return(
	select top(@n) CustomerID, OrderID, DeliveryMethodID
	from Sales.Invoices
	)
;

EXEC (N'select CustomerID, OrderId, DeliveryMethodID from invoices_f(10)') 
WITH RESULT SETS
( 
	([Customer] int,
	[Order] int,
	[DeliveryMethod]  int	
	)
);

-- 5. �����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������.