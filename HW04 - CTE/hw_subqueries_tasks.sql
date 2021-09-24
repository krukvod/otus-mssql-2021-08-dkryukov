/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select distinct p.PersonId, p.FullName
from Application.People p
left join (select SalespersonPersonID, InvoiceDate from Sales.Invoices 
	where InvoiceDate = '2015-07-04'
) i
on p.PersonID = i.SalespersonPersonID
where isnull(p.IsSalesperson,0) = 1	and i.SalespersonPersonID is not null

;with i as (select SalespersonPersonID, InvoiceDate from Sales.Invoices 
	where InvoiceDate = '2015-07-04'
)
select distinct p.PersonId, p.FullName
from Application.People p
left join i
on p.PersonID = i.SalespersonPersonID
where isnull(p.IsSalesperson,0) = 1	and i.SalespersonPersonID is not null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select si.StockItemID, StockItemName, UnitPrice
from Warehouse.StockItems si
where UnitPrice in (select min(UnitPrice) from Warehouse.StockItems)

select si.StockItemID, StockItemName, UnitPrice
from Warehouse.StockItems si
join (select min(UnitPrice) as minprice 
	from Warehouse.StockItems 
) mp
on si.UnitPrice = mp.minprice


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select * from (
select c.CustomerID, c.CustomerName, ct.TransactionAmount, 
	RANK() over(order by ct.TransactionAmount desc) as r
from Sales.Customers c
inner join Sales.CustomerTransactions ct
on c.CustomerID = ct.CustomerID
) sel
where r <= 5;

; with ct as (select top 5 CustomerID, TransactionAmount 
	from Sales.CustomerTransactions
	order by TransactionAmount desc
)
select c.CustomerID, c.CustomerName, ct.TransactionAmount 
from Sales.Customers c
inner join ct
on c.CustomerID = ct.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

; with s  as (select top 3 StockItemID, StockItemName, UnitPrice
	from Warehouse.StockItems
	order by UnitPrice desc
)
select distinct CityId, CityName, StockItemId, StockItemName, UnitPrice, FullName
from (
select ct.CityID, ct.CityName, il.StockItemID, s.StockItemName, i.InvoiceID, s.UnitPrice, p.FullName
	from s
	join Sales.InvoiceLines il
	on il.StockItemID = s.StockItemId
	join Sales.Invoices i
	on i.InvoiceID = il.InvoiceID

	join Sales.Customers c
	on i.CustomerID = c.CustomerID
	join Application.Cities ct
	on c.DeliveryCityID = ct.CityID
	join Application.People p
	on i.PackedByPersonID = p.PersonID
) sel
order by StockItemName, CityName, FullName


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

Запрос выводит данные по счетам, суммы которых больше 27 000, и итоговую стоимость неоконченных заказов по ним

SET STATISTICS IO, TIME ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC


SELECT 	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName	AS SalesPersonName,
	TotalSumm AS TotalSummByInvoice, 
	o.TotalSummForPickedItems
FROM (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals		
	join Sales.Invoices 
	ON Invoices.InvoiceID = SalesTotals.InvoiceID		
	join (select Orders.OrderID, 
		SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems
		from Sales.Orders
		join Sales.OrderLines
	on Orders.OrderID = OrderLines.OrderId
	where Orders.PickingCompletedWhen IS NOT NULL	
	group by Orders.OrderId
	) o
	on Invoices.OrderId = o.OrderId	
	join Application.People
	on People.PersonID = Invoices.SalespersonPersonID		
ORDER BY TotalSumm DESC

/*
Messages: чтений меньше, но пла на 2% хуже
(8 rows affected)
Table 'OrderLines'. Scan count 12, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 508, lob physical reads 4, lob read-ahead reads 790.
Table 'OrderLines'. Segment reads 1, segment skipped 0.
Table 'InvoiceLines'. Scan count 12, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 502, lob physical reads 3, lob read-ahead reads 778.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Orders'. Scan count 7, logical reads 725, physical reads 3, read-ahead reads 308, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 7, logical reads 11625, physical reads 3, read-ahead reads 11388, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'People'. Scan count 6, logical reads 28, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 171 ms,  elapsed time = 2364 ms.

(8 rows affected)
Table 'OrderLines'. Scan count 2, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 163, lob physical reads 0, lob read-ahead reads 0.
Table 'OrderLines'. Segment reads 1, segment skipped 0.
Table 'InvoiceLines'. Scan count 2, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 161, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'People'. Scan count 1, logical reads 11, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Orders'. Scan count 1, logical reads 692, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row affected)

 SQL Server Execution Times:
   CPU time = 46 ms,  elapsed time = 81 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

Completion time: 2021-09-24T20:05:31.7595397+03:00*/
/*
SELECT 	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName	AS SalesPersonName,
	TotalSumm AS TotalSummByInvoice, 
	SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) AS TotalSummForPickedItems
FROM (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals		
	join Sales.Invoices 
	ON Invoices.InvoiceID = SalesTotals.InvoiceID		
	join Sales.Orders
	on Orders.OrderId = Invoices.OrderId
	join Sales.OrderLines
	on Orders.OrderID = OrderLines.OrderId
	join Application.People
	on People.PersonID = Invoices.SalespersonPersonID
	where Orders.PickingCompletedWhen IS NOT NULL	
	group by Invoices.InvoiceID, Invoices.InvoiceDate, People.FullName, TotalSumm	
ORDER BY TotalSumm DESC
*/
-- --

